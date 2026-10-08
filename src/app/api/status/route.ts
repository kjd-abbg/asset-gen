import { codexStatus } from "../../../server/codex";
import { localOnly } from "../../../server/guard";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const denied = localOnly(request);
  if (denied) return denied;
  return Response.json(await codexStatus(request.signal));
}
