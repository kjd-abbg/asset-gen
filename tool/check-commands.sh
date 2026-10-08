#!/bin/sh
# [sensor:commands] 명령 계약 드리프트 — AGENTS.md §2 ↔ Makefile
#
# 왜 필요한가: 가이드가 **존재하지 않는 능력을 선언하는 것**이 이 하네스에서
# 가장 조용한 실패다. AGENTS.md §2에 `make run-web`이라 적혀 있는데 Makefile에
# 그 타깃이 없으면, 아무도 돌려보지 않는 한 그 거짓은 몇 주씩 살아남는다.
# 그동안 에이전트는 선언을 믿고 환경을 추측한다. (docs/EVIDENCE.md §A)
#
# 검사 3종:
#   1) AGENTS.md §2가 부르는 모든 `make <타깃>`이 Makefile에 실재하는가
#   2) SENSORS / SENSORS_CI 의 타깃이 실재하고 §2에 선언돼 있는가
#   3) Makefile이 문서화한(`## 이름:`) 타깃이 §2에 선언돼 있는가
#
# 출력 규약: agent-harness-kit/docs/SENSOR_CONTRACT.md
# 종료 코드: 0 통과 / 1 드리프트 있음 / 2 센서 자체 오류

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/tool/sensor-lib.sh"

GUIDE="$ROOT/AGENTS.md"
MAKEFILE="$ROOT/Makefile"

# §2에 없어도 되는 타깃 (진입점·도우미)
EXEMPT_TARGETS="help"

sensor_begin commands

[ -f "$GUIDE" ]    || sensor_broken "AGENTS.md가 없다" "sh <kit>/init.sh . 로 배치한다"
[ -f "$MAKEFILE" ] || sensor_broken "Makefile이 없다" "sh <kit>/init.sh . 로 배치한다"

targets=$(grep -E '^[a-z][a-z0-9_-]*:' "$MAKEFILE" | sed 's/:.*//' | sort -u)
documented=$(grep -E '^## [a-z][a-z0-9_-]*:' "$MAKEFILE" | sed 's/^## //; s/:.*//' | sort -u)

# AGENTS.md §2 블록에서 `make <타깃>` 추출
declared=$(awk '
  /^## 2\./       { inblk = 1; next }
  inblk && /^## / { inblk = 0 }
  inblk           { print }
' "$GUIDE" | grep -oE 'make [a-z][a-z0-9_-]*' | sed 's/^make //' | sort -u)

if [ -z "$declared" ]; then
  sensor_broken "AGENTS.md §2에서 \`make <타깃>\` 선언을 하나도 찾지 못했다" \
    "§2 제목이 '## 2.'로 시작하고 명령 블록에 make 타깃이 적혀 있는지 확인한다"
fi

# 1) 선언된 타깃이 실재하는가
for t in $declared; do
  if ! printf '%s\n' "$targets" | grep -qx "$t"; then
    sensor_issue "AGENTS.md §2" "선언한 \`make $t\`이 Makefile에 없다" \
      "Makefile에 $t 타깃을 만들거나, 안 쓸 명령이면 §2에서 그 줄을 지운다"
  fi
done

# 2) 센서 목록의 타깃이 실재하고 선언돼 있는가
# 줄 끝 주석(`# pre-commit ...`)을 먼저 떼지 않으면 주석 단어가 타깃으로 읽힌다.
sensors=$(grep -E '^SENSORS[[:space:]]*:?=' "$MAKEFILE" | head -1 | sed 's/^[^=]*=//; s/#.*//')
sensors_ci=$(grep -E '^SENSORS_CI[[:space:]]*:?=' "$MAKEFILE" | head -1 | sed 's/^[^=]*=//; s/#.*//')

if [ -z "$(printf '%s' "$sensors" | tr -d '[:space:]')" ]; then
  sensor_issue "Makefile" "SENSORS가 비어 있다 — \`make check\`가 아무것도 검증하지 않는다" \
    "pre-commit에서 돌릴 센서 타깃을 SENSORS에 적는다 (SENSOR_CONTRACT.md §1)"
fi

for t in $sensors $sensors_ci; do
  if ! printf '%s\n' "$targets" | grep -qx "$t"; then
    sensor_issue "Makefile" "센서 목록의 \`$t\`이 타깃으로 존재하지 않는다" \
      "$t 타깃을 만들거나 SENSORS/SENSORS_CI에서 뺀다"
  elif ! printf '%s\n' "$declared" | grep -qx "$t"; then
    sensor_issue "AGENTS.md §2" "센서 \`make $t\`이 §2에 선언돼 있지 않다" \
      "§2 명령 블록에 추가한다 — 선언되지 않은 센서는 에이전트가 존재를 모른다"
  fi
done

# 3) 문서화된 타깃이 가이드에 선언돼 있는가
for t in $documented; do
  skip=0
  for e in $EXEMPT_TARGETS; do [ "$t" = "$e" ] && skip=1; done
  [ "$skip" -eq 1 ] && continue
  if ! printf '%s\n' "$declared" | grep -qx "$t"; then
    sensor_issue "Makefile" "\`make $t\`을 AGENTS.md §2가 언급하지 않는다" \
      "§2에 선언하거나, 센서가 아니면 '## ' 문서 주석을 뗀다"
  fi
done

if [ "$(sensor_count)" -eq 0 ]; then
  n_decl=$(printf '%s\n' "$declared" | grep -c . || true)
  n_tgt=$(printf '%s\n' "$targets" | grep -c . || true)
  n_doc=$(printf '%s\n' "$documented" | grep -c . || true)
  printf '[sensor:commands] PASS (§2 선언 %s · Makefile 타깃 %s · 문서화 타깃 %s건 검사)\n' \
    "${n_decl:-0}" "${n_tgt:-0}" "${n_doc:-0}"
  exit 0
fi
sensor_end
