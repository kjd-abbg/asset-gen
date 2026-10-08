import { readFile } from "node:fs/promises";
import { localOnly } from "../../../../server/guard";
import { assetPath } from "../../../../server/store";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(
  request: Request,
  { params }: { params: Promise<{ path: string[] }> },
) {
  const denied = localOnly(request);
  if (denied) return denied;
  const { path } = await params;
  const file = path.length === 2 ? assetPath(path[0], path[1]) : null;
  const png = file ? await readFile(file).catch(() => null) : null;
  if (!png) return new Response("Not found", { status: 404 });
  const download = new URL(request.url).searchParams.get("download");
  const headers: Record<string, string> = {
    "content-type": "image/png",
    "cache-control": "private, max-age=31536000, immutable",
  };
  if (download && /^[\w가-힣 .-]{1,120}\.png$/.test(download))
    headers["content-disposition"] =
      `attachment; filename*=UTF-8''${encodeURIComponent(download)}`;
  return new Response(new Uint8Array(png), { headers });
}
