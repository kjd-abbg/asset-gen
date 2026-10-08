#!/bin/sh
# [sensor:design-md] 디자인 시스템 원본(DESIGN.md)이 깨지지 않았는지, 토큰 CSS가 원본과 같은지 본다.
#
# 왜 센서인가: 디자인 시스템 없이 화면을 만들면 에이전트가 화면마다 색·크기·간격을 새로
# 지어내 화면끼리 달라진다. 키트는 디자인 시스템을 루트 DESIGN.md(Google DESIGN.md 형식)
# 하나에 두고, 화면 코드는 거기서 생성한 토큰 CSS만 참조하게 한다(docs/DESIGN_SYSTEM.md).
# 원본을 고치고 생성을 잊거나, 생성물을 손으로 고치면 둘이 어긋난다.
#
# 실패 조건:
#   1. `design.md lint`의 error
#   2. 대비 warning(rule에 contrast가 든 것). 컴포넌트 글자 대비 WCAG AA 4.5:1
#   3. 허용 목록(DESIGN_MD_ALLOW)에 없는 그 밖의 warning
#   4. 토큰 CSS가 `sh tool/gen-design-tokens.sh` 결과와 다름
# 허용 기본값: 'borderColor'가 인식되지 않는 sub-token이라는 warning. DESIGN.md 0.4 사양에
#   테두리 색 sub-token이 없어 생기는 빈틈이다.
#
# 설정 (환경 변수, Makefile 타깃에서 지정):
#   DESIGN_MD_SRC     원본 (기본: DESIGN.md)
#   DESIGN_TOKENS_OUT 생성물 (기본: src/styles/tokens.css)
#   DESIGN_MD_BIN     lint·export 실행 파일 (기본: node_modules/.bin/design.md)
#   DESIGN_MD_ALLOW   허용할 warning 메시지 조각, `|` 구분 (기본: 'borderColor')
#   DESIGN_TOKENS_FORMAT·DESIGN_RESET_PALETTE는 gen-design-tokens.sh와 같다
#
# 고치는 법: DESIGN.md를 고친 뒤 `make design-tokens`. 생성물은 직접 고치지 않는다.
# 출력 규약: agent-harness-kit/docs/SENSOR_CONTRACT.md
# 종료 코드: 0 통과 / 1 위반 / 2 센서 자체 오류(원본·실행 파일 없음)

set -eu
ROOT=$(cd "${DESIGN_ROOT:-$(dirname "$0")/..}" && pwd)
TOOL=$(cd "$(dirname "$0")" && pwd)
. "$TOOL/sensor-lib.sh"
cd "$ROOT"

sensor_begin design-md
SRC="${DESIGN_MD_SRC:-DESIGN.md}"
OUT="${DESIGN_TOKENS_OUT:-src/styles/tokens.css}"
BIN="${DESIGN_MD_BIN:-node_modules/.bin/design.md}"

command -v python3 >/dev/null 2>&1 || sensor_broken "python3이 필요하다" "python3을 설치하거나 SENSORS에서 design-md를 뺀다"
[ -f "$SRC" ] || sensor_broken "디자인 시스템 원본이 없다: $SRC" \
  "docs/DESIGN_SYSTEM.md 순서로 DESIGN.md를 만든다. UI가 없는 저장소면 SENSORS에서 design-md를 뺀다"
[ -x "$BIN" ] || sensor_broken "$BIN 없음" "npm i -D -E @google/design.md@0.4.0 (버전 고정)"

tmp=$(mktemp -d 2>/dev/null || echo "/tmp/design-md.$$")
mkdir -p "$tmp"
trap 'rm -r "$tmp" 2>/dev/null || true' EXIT

"$BIN" lint --format json "$SRC" > "$tmp/lint.json" 2> "$tmp/lint.err" || true
python3 - "$tmp/lint.json" "${DESIGN_MD_ALLOW:-'borderColor'}" "$SRC" > "$tmp/issues" <<'PY' || sensor_broken "lint 출력을 읽지 못했다" "$BIN lint --format json $SRC 를 직접 실행해 오류를 본다"
import json, sys
path, allow, src = sys.argv[1], [a for a in sys.argv[2].split("|") if a], sys.argv[3]
data = json.load(open(path, encoding="utf-8"))
for f in data.get("findings", []):
    sev, rule = f.get("severity", ""), f.get("rule", "")
    where, msg = f.get("path", ""), f.get("message", "").replace("\t", " ")
    if sev == "error":
        fix = "DESIGN.md의 해당 토큰·참조를 고친다"
    elif sev == "warning" and "contrast" in rule:
        fix = "색 값을 바꾼다. 호버·눌림 같은 짝 색도 함께 확인한다"
    elif sev == "warning" and not any(a in msg for a in allow):
        fix = "DESIGN.md를 고친다. 사양 빈틈이면 DESIGN_MD_ALLOW에 조각을 더하고 이유를 decisions.md에"
    else:
        continue
    print(f"{src}:{where}\t{sev} {rule}: {msg}\t{fix}")
PY
while IFS="$(printf '\t')" read -r loc what fix; do
  sensor_issue "$loc" "$what" "$fix"
done < "$tmp/issues"

if DESIGN_MD_BIN="$BIN" DESIGN_MD_SRC="$SRC" sh "$TOOL/gen-design-tokens.sh" "$tmp/tokens.css" 2> "$tmp/gen.err"; then
  if [ ! -f "$OUT" ]; then
    sensor_issue "$OUT" "생성물이 없다" "make design-tokens"
  elif ! cmp -s "$tmp/tokens.css" "$OUT"; then
    sensor_issue "$OUT" "DESIGN.md에서 생성한 결과와 다르다(손으로 고쳤거나 재생성을 잊음)" \
      "make design-tokens. 값을 바꾸려면 DESIGN.md를 고친다"
  fi
else
  sensor_broken "토큰 생성 실패: $(head -1 "$tmp/gen.err")" "$BIN export --format css-tailwind $SRC 를 직접 실행해 본다"
fi

sensor_end
