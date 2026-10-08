// 실행 전 점검: Node 버전, Codex CLI 설치, ChatGPT 로그인.
import { spawnSync } from "node:child_process";

const fail = (msg) => {
  console.error(`\n✗ ${msg}\n`);
  process.exit(1);
};
const [major, minor] = process.versions.node.split(".").map(Number);
if (major < 22 || (major === 22 && minor < 12))
  fail(`Node.js 22.12 이상이 필요합니다. 현재 ${process.versions.node}`);
console.log(`✓ Node.js ${process.versions.node}`);

const version = spawnSync("codex", ["--version"], { encoding: "utf8" });
if (version.error)
  fail("Codex CLI가 없습니다. 시작하기.command로 실행하거나 npm install을 먼저 실행해 주세요.");
console.log(`✓ ${version.stdout.trim()}`);

const login = spawnSync("codex", ["login", "status"], { encoding: "utf8" });
if (!`${login.stdout}${login.stderr}`.includes("Logged in using ChatGPT"))
  fail(
    "ChatGPT 로그인이 필요합니다. 터미널에서 codex login 을 실행해 본인 계정으로 로그인해 주세요.",
  );
console.log("✓ ChatGPT 로그인 확인");
