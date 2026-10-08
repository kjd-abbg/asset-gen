import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

export const outputRoot =
  process.env.ASSET_GEN_OUTPUT ||
  join(/* turbopackIgnore: true */ process.cwd(), "output");
const idPattern = /^[a-z0-9-]{8,64}$/;

export function isId(v: unknown): v is string {
  return typeof v === "string" && idPattern.test(v);
}

export type AssetRecord = {
  id: string;
  runId: string;
  mode: "explore" | "set";
  styleId: string;
  styleLabel: string;
  subject: string;
  palette: string;
  extra: string;
  file: string;
  note: string;
  reference: string | null;
  durationMs: number;
  createdAt: string;
  promptVersion: string;
  prompt: string;
};

export async function saveAsset(record: AssetRecord, png: Buffer) {
  const dir = join(outputRoot, record.runId);
  await mkdir(dir, { recursive: true });
  await writeFile(join(dir, record.file), png);
  await writeFile(
    join(dir, `${record.id}.json`),
    JSON.stringify(record, null, 2),
  );
}

export async function listAssets(limit = 300): Promise<AssetRecord[]> {
  const runs = await readdir(outputRoot).catch(() => [] as string[]);
  const records: AssetRecord[] = [];
  for (const run of runs.filter(isId)) {
    const files = await readdir(join(outputRoot, run)).catch(() => []);
    for (const f of files.filter((f) => f.endsWith(".json"))) {
      try {
        records.push(
          JSON.parse(await readFile(join(outputRoot, run, f), "utf8")),
        );
      } catch {
        /* 손상된 기록은 건너뛴다 */
      }
    }
  }
  return records
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt))
    .slice(0, limit);
}

// 경로 조작을 막기 위해 runId/파일명 두 단계만 허용한다.
export function assetPath(runId: unknown, file: unknown): string | null {
  if (!isId(runId) || typeof file !== "string") return null;
  if (!/^[a-z0-9-]{8,64}\.png$/.test(file)) return null;
  return join(outputRoot, runId, file);
}
