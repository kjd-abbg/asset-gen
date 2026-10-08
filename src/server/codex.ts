import { spawn } from "node:child_process";
import {
  mkdtemp,
  readdir,
  readFile,
  realpath,
  rm,
  stat,
  writeFile,
} from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join, sep } from "node:path";
import { deflateSync } from "node:zlib";
import { outputSchema } from "../prompt";
import { outputRoot } from "./store";

// 구독 사용량을 아끼기 위해 동시 생성 수를 제한한다.
export const maxParallel = Math.min(
  4,
  Math.max(1, Number(process.env.ASSET_GEN_PARALLEL) || 2),
);
const fake = process.env.ASSET_GEN_FAKE === "1";
// 데스크톱 앱은 앱 안에 넣은 Codex 실행 파일 경로를 넘긴다. 없으면 PATH의 codex.
const codexBin = process.env.ASSET_GEN_CODEX_BIN || "codex";
// 서버가 끝날 때 아직 도는 Codex 프로세스 그룹을 함께 끝낸다(앱 종료 시 고아 방지).
const live = new Set<number>();
process.once("exit", () => {
  for (const pid of live) {
    try {
      process.kill(-pid, "SIGKILL");
    } catch {
      /* 이미 종료됨 */
    }
  }
});
const state = globalThis as typeof globalThis & { assetGenRunning?: number };

export function tryAcquire() {
  const n = state.assetGenRunning ?? 0;
  if (n >= maxParallel) return false;
  state.assetGenRunning = n + 1;
  return true;
}
export function release() {
  state.assetGenRunning = Math.max(0, (state.assetGenRunning ?? 1) - 1);
}

function codex(
  args: string[],
  cwd: string,
  signal: AbortSignal,
  input = "",
  timeoutMs = 60000,
): Promise<string> {
  return new Promise((resolve, reject) => {
    // 사용자 셸의 다른 비밀값을 넘기지 않도록 필요한 변수만 전달한다.
    const env: NodeJS.ProcessEnv = { NODE_ENV: process.env.NODE_ENV };
    for (const key of ["PATH", "HOME", "CODEX_HOME", "TMPDIR"])
      if (process.env[key]) env[key] = process.env[key];
    const child = spawn(codexBin, args, {
      cwd,
      env,
      detached: true,
      stdio: ["pipe", "pipe", "pipe"],
    });
    let output = "";
    if (child.pid) live.add(child.pid);
    const stop = () => {
      if (child.pid) {
        try {
          process.kill(-child.pid, "SIGKILL");
        } catch {
          /* 이미 종료된 프로세스 */
        }
      }
    };
    const timer = setTimeout(stop, timeoutMs);
    signal.addEventListener("abort", stop, { once: true });
    if (signal.aborted) stop();
    // exec --json 출력은 이미지 이벤트로 커질 수 있어 앞부분만 보관한다.
    const collect = (data: Buffer) => {
      if (output.length < 20000) output += data.toString();
    };
    child.stdout.on("data", collect);
    child.stderr.on("data", (data: Buffer) => {
      if (args[0] === "login") collect(data);
    });
    child.stdin.on("error", () => {});
    child.stdin.end(input);
    const cleanup = () => {
      if (child.pid) live.delete(child.pid);
      clearTimeout(timer);
      signal.removeEventListener("abort", stop);
    };
    child.on("error", () => {
      cleanup();
      reject(
        new Error(
          "Codex CLI를 실행할 수 없습니다. 설치와 PATH를 확인해 주세요.",
        ),
      );
    });
    child.on("close", (code) => {
      cleanup();
      if (code === 0) resolve(output);
      else if (signal.aborted) reject(new Error("생성을 취소했습니다."));
      else
        reject(
          new Error(
            "생성이 중단되었습니다. 구독 사용량 한도나 로그인 상태를 확인한 뒤 다시 시도해 주세요.",
          ),
        );
    });
  });
}

export type CodexStatus = {
  installed: boolean;
  loggedIn: boolean;
  fake: boolean;
  maxParallel: number;
  outputDir: string;
  desktop: boolean;
};
const desktop = process.env.ASSET_GEN_DESKTOP === "1";

export async function codexStatus(signal: AbortSignal): Promise<CodexStatus> {
  if (fake)
    return {
      installed: true,
      loggedIn: true,
      fake,
      maxParallel,
      outputDir: outputRoot,
      desktop,
    };
  const dir = await mkdtemp(join(tmpdir(), "asset-gen-"));
  try {
    const out = await codex(["login", "status"], dir, signal, "", 15000);
    return {
      installed: true,
      loggedIn: out.includes("Logged in using ChatGPT"),
      fake,
      maxParallel,
      outputDir: outputRoot,
      desktop,
    };
  } catch (e) {
    const missing = e instanceof Error && e.message.includes("PATH");
    return {
      installed: !missing,
      loggedIn: false,
      fake,
      maxParallel,
      outputDir: outputRoot,
      desktop,
    };
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

const pngMagic = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

export async function generateImage(
  prompt: string,
  reference: string | null,
  signal: AbortSignal,
): Promise<{ png: Buffer; note: string }> {
  if (fake) return fakeImage(prompt, signal);
  const dir = await mkdtemp(join(tmpdir(), "asset-gen-"));
  try {
    const login = await codex(["login", "status"], dir, signal, "", 15000);
    if (!login.includes("Logged in using ChatGPT"))
      throw new Error(
        "ChatGPT 로그인이 필요합니다. 터미널에서 codex login을 실행해 주세요.",
      );
    const schema = join(dir, "schema.json");
    const result = join(dir, "result.json");
    await writeFile(schema, JSON.stringify(outputSchema));
    const started = Date.now();
    const events = await codex(
      [
        "exec",
        "--ignore-user-config",
        "--ephemeral",
        "--skip-git-repo-check",
        "--sandbox",
        "read-only",
        "-c",
        'forced_login_method="chatgpt"',
        "-c",
        'model_reasoning_effort="low"',
        // 이미지는 Codex 내장 image_gen(공식 문서상 gpt-image-2)이 그린다.
        // 대화 모델은 지정하지 않고 각자 Codex 기본값을 쓴다.
        "--enable",
        "image_generation",
        ...(reference ? ["--image", reference] : []),
        "--output-schema",
        schema,
        "--output-last-message",
        result,
        "--json",
        "-",
      ],
      dir,
      signal,
      prompt,
      300000,
    );
    const data = await readFile(result, "utf8")
      .then((t) => JSON.parse(t) as Record<string, unknown>)
      .catch(() => ({}) as Record<string, unknown>);
    // Codex는 실행(thread)마다 generated_images/<thread_id>/에 이미지를 저장한다.
    // 모델이 경로를 빠뜨리는 경우가 있어(2026-10-07 18장 중 6장) 폴더에서 직접 찾는다.
    const thread = /"thread_id":"([0-9a-f-]{36})"/.exec(events)?.[1];
    const root = await realpath(
      join(
        process.env.CODEX_HOME || join(homedir(), ".codex"),
        "generated_images",
      ),
    ).catch(() => "");
    if (!root || !thread)
      throw new Error("이미지 도구 실행 기록을 확인하지 못했습니다.");
    const file = await newestPng(join(root, thread), started);
    if (!file)
      throw new Error(
        "이미지 도구가 이미지를 만들지 않았습니다. 다시 시도해 주세요.",
      );
    const real = await realpath(file);
    if (!real.startsWith(root + sep))
      throw new Error("이미지 도구의 출력 경로가 아닙니다.");
    const info = await stat(real);
    if (info.size > 15000000) throw new Error("이미지 파일이 너무 큽니다.");
    const png = await readFile(real);
    if (!png.subarray(0, 8).equals(pngMagic))
      throw new Error("PNG 이미지가 아닙니다.");
    const note = typeof data.note === "string" ? data.note.slice(0, 300) : "";
    return { png, note };
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

async function newestPng(dir: string, since: number) {
  const names = await readdir(dir).catch(() => [] as string[]);
  let best: { file: string; at: number } | null = null;
  for (const name of names.filter((n) => n.endsWith(".png"))) {
    const file = join(dir, name);
    const info = await stat(file).catch(() => null);
    if (!info?.isFile() || info.mtimeMs < since - 2000) continue;
    if (!best || info.mtimeMs > best.at) best = { file, at: info.mtimeMs };
  }
  return best?.file ?? null;
}

// 테스트용: 구독을 쓰지 않고 프롬프트에서 색을 정한 단색 PNG를 만든다.
async function fakeImage(prompt: string, signal: AbortSignal) {
  await new Promise<void>((resolve, reject) => {
    const t = setTimeout(
      resolve,
      Number(process.env.ASSET_GEN_FAKE_DELAY) || 400,
    );
    signal.addEventListener("abort", () => {
      clearTimeout(t);
      reject(new Error("생성을 취소했습니다."));
    });
  });
  if (prompt.includes("FAIL-TEST")) throw new Error("테스트용 실패입니다.");
  let h = 0;
  for (const c of prompt) h = (h * 31 + c.charCodeAt(0)) >>> 0;
  return {
    png: solidPng(64, [h & 255, (h >> 8) & 255, (h >> 16) & 255]),
    note: "테스트 이미지",
  };
}

function solidPng(size: number, rgb: number[]) {
  const row = Buffer.alloc(1 + size * 3);
  for (let x = 0; x < size; x++) row.set(rgb, 1 + x * 3);
  const raw = Buffer.concat(Array.from({ length: size }, () => row));
  const chunk = (type: string, data: Buffer) => {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length);
    const body = Buffer.concat([Buffer.from(type), data]);
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(body));
    return Buffer.concat([len, body, crc]);
  };
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr.set([8, 2, 0, 0, 0], 8);
  return Buffer.concat([
    pngMagic,
    chunk("IHDR", ihdr),
    chunk("IDAT", deflateSync(raw)),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function crc32(buf: Buffer) {
  let c = ~0;
  for (const b of buf) {
    c ^= b;
    for (let k = 0; k < 8; k++) c = c & 1 ? (c >>> 1) ^ 0xedb88320 : c >>> 1;
  }
  return ~c >>> 0;
}

const loginState = globalThis as typeof globalThis & { assetGenLogin?: number };

export function startLogin(): boolean {
  if (fake) return true;
  if (loginState.assetGenLogin) {
    try {
      process.kill(loginState.assetGenLogin, 0);
      return true; // 이미 로그인 창이 떠 있다
    } catch {
      loginState.assetGenLogin = undefined;
    }
  }
  const env: NodeJS.ProcessEnv = { NODE_ENV: process.env.NODE_ENV };
  for (const key of ["PATH", "HOME", "CODEX_HOME", "TMPDIR"])
    if (process.env[key]) env[key] = process.env[key];
  const child = spawn(codexBin, ["login"], { env, stdio: "ignore" });
  child.on("error", () => (loginState.assetGenLogin = undefined));
  child.on("exit", () => (loginState.assetGenLogin = undefined));
  loginState.assetGenLogin = child.pid;
  // 10분 뒤에도 끝나지 않으면 정리한다
  setTimeout(() => child.kill("SIGTERM"), 600000).unref();
  return Boolean(child.pid);
}
