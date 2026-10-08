#!/bin/bash
# 에셋 생성기 시작 (macOS). 더블클릭으로 실행한다.
# 필요한 것을 확인해 없으면 이 폴더 안에 준비하고, 서버를 띄운 뒤 브라우저를 연다.
set -euo pipefail
cd "$(dirname "$0")"
APP_DIR="$PWD"
RUNTIME="$APP_DIR/.runtime"
PORT=1230
URL="http://127.0.0.1:$PORT"

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
fail() {
  printf '\n\033[31m✗ %s\033[0m\n\n' "$*"
  read -r -p "엔터를 누르면 창을 닫습니다. " _ || true
  exit 1
}
# 테스트에서는 ASSET_GEN_NO_OPEN=1 로 브라우저 열기를 끈다.
open_browser() { if [ "${ASSET_GEN_NO_OPEN:-}" != "1" ]; then open "$URL"; fi; }
trap 'fail "예상하지 못한 오류로 멈췄습니다. 이 창을 캡처해서 전달해 주세요."' ERR

say "에셋 생성기를 준비합니다."

# 이미 켜져 있으면 브라우저만 연다.
STATUS="$(curl -fsS "$URL/api/status" 2>/dev/null || true)"
if [[ "$STATUS" == *loggedIn* ]]; then
  open_browser
  say "이미 실행 중이라 브라우저만 열었습니다."
  exit 0
fi
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  fail "$PORT 번 포트를 다른 프로그램이 쓰고 있습니다. 그 프로그램을 끄고 다시 실행해 주세요."
fi

# 1) Node.js: 없거나 22.12 미만이면 공식 사이트에서 이 폴더 안으로 받는다(관리자 권한 불필요).
mkdir -p "$RUNTIME"
if [ -x "$RUNTIME/node/bin/node" ]; then export PATH="$RUNTIME/node/bin:$PATH"; fi
node_ok() {
  command -v node >/dev/null 2>&1 &&
    node -e 'const [a,b]=process.versions.node.split(".").map(Number);process.exit(a>22||(a===22&&b>=12)?0:1)'
}
if ! node_ok; then
  say "Node.js를 내려받습니다. 처음 한 번만, 1~2분 걸립니다."
  case "$(uname -m)" in
    arm64) ARCH=arm64 ;;
    x86_64) ARCH=x64 ;;
    *) fail "지원하지 않는 컴퓨터입니다: $(uname -m)" ;;
  esac
  BASE="https://nodejs.org/dist/latest-v24.x"
  SUMS="$(curl -fsSL "$BASE/SHASUMS256.txt")" || fail "인터넷 연결을 확인하고 다시 실행해 주세요."
  LINE="$(printf '%s\n' "$SUMS" | grep -E "  node-v[0-9.]+-darwin-$ARCH\.tar\.gz$" | head -1)"
  [ -n "$LINE" ] || fail "Node.js 설치 파일을 찾지 못했습니다."
  SUM="${LINE%%  *}"
  FILE="${LINE##*  }"
  TMP="$(mktemp -d)"
  curl -fL --progress-bar "$BASE/$FILE" -o "$TMP/$FILE" || fail "Node.js를 내려받지 못했습니다. 인터넷 연결을 확인해 주세요."
  echo "$SUM  $TMP/$FILE" | shasum -a 256 -c - >/dev/null 2>&1 || fail "내려받은 파일 검증에 실패했습니다. 다시 실행해 주세요."
  tar -xzf "$TMP/$FILE" -C "$TMP"
  if [ -e "$RUNTIME/node" ]; then mv "$RUNTIME/node" "$TMP/old-node"; fi
  mv "$TMP/${FILE%.tar.gz}" "$RUNTIME/node"
  export PATH="$RUNTIME/node/bin:$PATH"
  node_ok || fail "Node.js 준비에 실패했습니다."
fi
echo "✓ Node.js $(node -v)"

# 2) 앱과 Codex 설치: package-lock.json이나 Node 버전이 바뀌었을 때만 다시 설치한다.
STAMP="$APP_DIR/node_modules/.install-stamp"
WANT="$(shasum -a 256 package-lock.json | cut -d' ' -f1)-$(node -v)"
if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "$WANT" ]; then
  say "필요한 파일을 설치합니다. 처음 한 번만, 1~2분 걸립니다."
  npm ci --no-audit --no-fund --loglevel=error || fail "설치에 실패했습니다. 인터넷 연결을 확인하고 다시 실행해 주세요."
  echo "$WANT" >"$STAMP"
fi
export PATH="$APP_DIR/node_modules/.bin:$PATH"
echo "✓ $(codex --version)"

# 3) ChatGPT 로그인: 각자 본인 계정의 구독으로 생성한다.
logged_in() {
  local out
  out="$(codex login status 2>&1 || true)"
  [[ "$out" == *"Logged in using ChatGPT"* ]]
}
if ! logged_in; then
  say "ChatGPT 로그인이 필요합니다. 브라우저가 열리면 본인 ChatGPT 계정으로 로그인해 주세요."
  codex login || fail "로그인을 마치지 못했습니다. 다시 실행해 주세요."
  logged_in || fail "ChatGPT 계정 로그인이 확인되지 않았습니다. 다시 실행해 주세요."
fi
echo "✓ ChatGPT 로그인 확인"

# 4) 빌드: 처음이거나 코드가 바뀌었을 때만.
if [ ! -f .next/BUILD_ID ] || [ -n "$(find src package-lock.json next.config.ts -newer .next/BUILD_ID -print -quit)" ]; then
  say "앱을 준비합니다. 1분 정도 걸립니다."
  if ! npx next build >"$RUNTIME/build.log" 2>&1; then
    tail -30 "$RUNTIME/build.log"
    fail "앱 준비에 실패했습니다. 이 창을 캡처해서 전달해 주세요."
  fi
fi

# 5) 실행: 준비되면 브라우저를 연다.
say "에셋 생성기를 켰습니다. 브라우저가 곧 열립니다."
echo "끄려면 이 창을 닫거나 Ctrl+C 를 누르세요."
(
  for _ in $(seq 1 60); do
    sleep 1
    if curl -fsS -o /dev/null "$URL"; then
      open_browser
      break
    fi
  done
) &
trap - ERR
exec npx next start --hostname 127.0.0.1 --port "$PORT"
