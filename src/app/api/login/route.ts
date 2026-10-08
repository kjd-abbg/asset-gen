import { startLogin } from "../../../server/codex";
import { localOnly } from "../../../server/guard";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// ChatGPT 로그인 창을 연다. 완료 여부는 화면이 /api/status로 확인한다.
export async function POST(request: Request) {
  const denied = localOnly(request);
  if (denied) return denied;
  return startLogin()
    ? Response.json({ started: true }, { status: 202 })
    : Response.json(
        { error: "로그인을 시작하지 못했습니다. 앱을 다시 실행해 주세요." },
        { status: 500 },
      );
}
