import { localOnly } from "../../../server/guard";
import { listAssets } from "../../../server/store";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const denied = localOnly(request);
  if (denied) return denied;
  return Response.json({ assets: await listAssets() });
}
