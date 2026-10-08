import { stat } from "node:fs/promises";
import { buildAssetPrompt, promptVersion, readBrief } from "../../../prompt";
import { generateImage, release, tryAcquire } from "../../../server/codex";
import { localOnly } from "../../../server/guard";
import {
  assetPath,
  isId,
  saveAsset,
  type AssetRecord,
} from "../../../server/store";
import { findStyle } from "../../../styles";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const denied = localOnly(request);
  if (denied) return denied;
  if (!request.headers.get("content-type")?.includes("application/json"))
    return Response.json({ error: "JSON 요청이 필요합니다." }, { status: 415 });
  let body: Record<string, unknown>;
  try {
    const raw = await request.text();
    if (raw.length > 4000)
      return Response.json({ error: "입력이 너무 깁니다." }, { status: 400 });
    body = JSON.parse(raw);
  } catch {
    return Response.json(
      { error: "JSON 형식이 올바르지 않습니다." },
      { status: 400 },
    );
  }
  const style = findStyle(body.styleId);
  const brief = readBrief(body);
  const mode =
    body.mode === "set" ? "set" : body.mode === "explore" ? "explore" : null;
  if (!style || !brief || !isId(body.runId) || !isId(body.id) || !mode)
    return Response.json(
      { error: "대상과 스타일을 확인해 주세요." },
      { status: 400 },
    );
  let reference: string | null = null;
  let referenceKey: string | null = null;
  if (body.reference !== undefined && body.reference !== null) {
    const ref = body.reference as Record<string, unknown>;
    reference = assetPath(ref?.runId, ref?.file);
    if (!reference || !(await stat(reference).catch(() => null)))
      return Response.json(
        { error: "참고 이미지를 찾을 수 없습니다." },
        { status: 400 },
      );
    referenceKey = `${ref.runId}/${ref.file}`;
  }
  if (!tryAcquire())
    return Response.json(
      {
        error:
          "동시에 생성할 수 있는 수를 넘었습니다. 잠시 뒤 다시 시도해 주세요.",
      },
      { status: 429 },
    );
  try {
    const prompt = buildAssetPrompt(style, brief, reference !== null);
    const started = Date.now();
    const { png, note } = await generateImage(
      prompt,
      reference,
      request.signal,
    );
    const record: AssetRecord = {
      id: body.id,
      runId: body.runId,
      mode,
      styleId: style.id,
      styleLabel: style.label,
      ...brief,
      file: `${body.id}.png`,
      note,
      reference: referenceKey,
      durationMs: Date.now() - started,
      createdAt: new Date().toISOString(),
      promptVersion,
      prompt,
    };
    await saveAsset(record, png);
    return Response.json(record);
  } catch (e) {
    return Response.json(
      { error: e instanceof Error ? e.message : "생성에 실패했습니다." },
      { status: 502 },
    );
  } finally {
    release();
  }
}
