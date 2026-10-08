// 각자 자기 컴퓨터에서만 쓰는 도구다. 다른 컴퓨터가 접속해 이 컴퓨터의
// ChatGPT 구독을 쓰지 못하도록 루프백 Host와 같은 Origin만 허용한다.
const localHosts = new Set(["127.0.0.1", "localhost", "[::1]"]);

export function localOnly(request: Request): Response | null {
  const url = new URL(request.url);
  const host = request.headers.get("host") ?? url.host;
  const origin = request.headers.get("origin");
  let ok = false;
  try {
    const incoming = new URL(`${url.protocol}//${host}`);
    ok =
      localHosts.has(incoming.hostname) &&
      localHosts.has(url.hostname) &&
      (!origin || origin === incoming.origin);
  } catch {
    /* 잘못된 Host 거부 */
  }
  return ok
    ? null
    : Response.json(
        { error: "이 컴퓨터에서만 사용할 수 있습니다." },
        { status: 403 },
      );
}
