#!/bin/sh
# 하네스 6계층 상태 점검 (`make doctor`). **읽기만 한다 — 아무것도 고치지 않는다.**
#
# 목적은 "환경 때문에 못 돌린 센서를 통과로 착각하지 않는 것"과 "6계층 중
# 무엇이 아직 없는지 한눈에 보는 것"이다.
#
# 종료 코드는 항상 0이다 — doctor는 센서가 아니라 관찰 도구다. CI를 막지 않는다.
# 무엇을 막아야 한다면 그건 doctor가 아니라 센서(check-commands / check-guide)에
# 들어가야 한다.
#
# 스택 고유 점검(런타임 버전, DB 도달 여부, 에뮬레이터 상태 등)은 이 파일이 아니라
# 프로젝트가 소유하는 `tool/doctor-stack.sh`에 쓴다. 이 파일은 `init.sh --update`가
# 상류로 덮어쓰므로 여기에 쓴 점검은 업데이트 때 사라진다(docs/EVIDENCE.md §M).
# doctor-stack.sh 안에서는 row·head_ 함수와 OK·WARN·NO 변수를 쓸 수 있다.

set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

OK="\033[32m✓\033[0m"
WARN="\033[33m⚠\033[0m"
NO="\033[31m✗\033[0m"

# 표시 폭 계산: printf의 %-Ns는 바이트를 센다. 한글은 3바이트인데 2칸을
# 차지하므로 그대로 쓰면 표가 어긋난다. 문자 수(wc -m)와 바이트 수(wc -c)로
# 실제 폭을 구한다 — 폭2 문자 하나당 (바이트-문자)가 2씩 늘어난다.
# UTF-8 로케일을 못 찾으면 폭 계산을 포기하고 바이트 기준으로 떨어진다.
UTF8_LOC=""
for _loc in C.UTF-8 en_US.UTF-8 ko_KR.UTF-8; do
  if [ "$(printf '가' | LC_ALL="$_loc" wc -m 2>/dev/null | tr -d ' ')" = "1" ]; then
    UTF8_LOC="$_loc"; break
  fi
done

LABEL_W=30
row() {
  if [ -n "$UTF8_LOC" ]; then
    _c=$(printf '%s' "$2" | LC_ALL="$UTF8_LOC" wc -m | tr -d ' ')
    _b=$(printf '%s' "$2" | LC_ALL=C wc -c | tr -d ' ')
    _w=$(( _c + (_b - _c) / 2 ))
    _pad=$(( LABEL_W - _w ))
    [ "$_pad" -lt 1 ] && _pad=1
    printf "$1 %s%*s%s\n" "$2" "$_pad" "" "$3"
  else
    printf "$1 %-${LABEL_W}s %s\n" "$2" "$3"
  fi
}
head_() { printf "\n\033[1m%s\033[0m\n" "$1"; }

printf "\n\033[1m하네스 상태 점검\033[0m — %s\n" "$(basename "$ROOT")"
printf "  (관찰 도구다. 여기서 초록이어도 제품이 동작한다는 뜻은 아니다.)\n"

# ── Layer 1: Guides ──────────────────────────────────────────────────
head_ "Layer 1 — Guides"
if [ -f AGENTS.md ]; then
  holes=$(grep -c '<<<' AGENTS.md 2>/dev/null || true); holes=${holes:-0}
  if [ "$holes" -gt 0 ]; then
    row "$NO" "AGENTS.md" "미채움 자리 ${holes}곳 — make harness-check"
  else
    row "$OK" "AGENTS.md" "$(wc -l < AGENTS.md | tr -d ' ')줄"
  fi
else
  row "$NO" "AGENTS.md" "없음 — 하네스의 Layer 1이 비어 있다"
fi
if [ -f CLAUDE.md ]; then
  if grep -q '@AGENTS\.md' CLAUDE.md 2>/dev/null; then
    row "$OK" "CLAUDE.md" "AGENTS.md import"
  else
    row "$NO" "CLAUDE.md" "import이 아니다 — 본문이 이중화됐을 수 있다"
  fi
else
  row "$NO" "CLAUDE.md" "없음 — Claude Code가 AGENTS.md를 읽지 않는다"
fi
[ -f HARNESS_ENGINEERING.md ] \
  && row "$OK" "HARNESS_ENGINEERING.md" "레퍼런스 있음" \
  || row "$WARN" "HARNESS_ENGINEERING.md" "없음 (선택)"
if [ -f docs/HARNESS.md ]; then
  blank=$(awk -F'|' '
    !/^\|/ { why=0; next }
    /막으려는 실패/ && /추가일/ {
      for(i=2;i<NF;i++) { h=$i; gsub(/^[ \t]+|[ \t]+$/, "", h); if(h=="막으려는 실패") why=i }
      next
    }
    /^\|[ :-]*\|/ { next }
    why { w=$why; gsub(/^[ \t]+|[ \t]+$/,"",w); if(w=="" || w=="-" || w ~ /^<<</) c++ }
    END { print c+0 }' docs/HARNESS.md)
  if [ "${blank:-0}" -gt 0 ]; then
    row "$NO" "docs/HARNESS.md" "'막으려는 실패' 빈 칸 ${blank}개 — make harness-check"
  else
    n=$(grep -c '^|' docs/HARNESS.md 2>/dev/null || echo 0)
    row "$OK" "docs/HARNESS.md" "인벤토리 ${n}행"
  fi
else
  row "$NO" "docs/HARNESS.md" "없음 — 무엇이 왜 걸려 있는지 기록이 없다"
fi

# ── Layer 2: Sensors ─────────────────────────────────────────────────
head_ "Layer 2 — Sensors"
if [ -f Makefile ]; then
  sensors=$(grep -E '^SENSORS[[:space:]]*:?=' Makefile | head -1 | sed 's/^[^=]*=//; s/#.*//' | tr -s ' ')
  ntar=$(grep -cE '^[a-z][a-z0-9_-]*:' Makefile || true); ntar=${ntar:-0}
  row "$OK" "Makefile" "타깃 ${ntar}개"
  if [ -n "$(printf '%s' "$sensors" | tr -d '[:space:]')" ]; then
    row "$OK" "make check가 도는 센서" "$(printf '%s' "$sensors" | sed 's/^ *//')"
  else
    row "$NO" "make check가 도는 센서" "SENSORS가 비어 있다"
  fi
  # 뒷단이 안 채워진 변수 찾기
  empty=$(grep -E '^[A-Z_]+_CMD[[:space:]]*\?\?*=[[:space:]]*$' Makefile | sed 's/[[:space:]]*?*=.*//' | tr '\n' ' ')
  if [ -n "$(printf '%s' "$empty" | tr -d '[:space:]')" ]; then
    row "$NO" "뒷단 미채움" "$empty"
  else
    row "$OK" "뒷단 명령" "전부 채워짐"
  fi
else
  row "$NO" "Makefile" "없음 — 명령 진입점이 없다"
fi
for f in tool/check-commands.sh tool/check-guide.sh; do
  [ -f "$f" ] && row "$OK" "$f" "있음" || row "$NO" "$f" "없음"
done
if [ -d .github/workflows ]; then
  row "$OK" "CI 워크플로" "$(ls .github/workflows | tr '\n' ' ')"
else
  row "$WARN" "CI 워크플로" "없음 — 센서 실행이 자기 보고에 머문다"
fi

# ── Layer 3/6: Loop & Observability ──────────────────────────────────
head_ "Layer 3·6 — Loop / Observability"
if [ -f AGENTS.md ] && grep -q '재시도 상한' AGENTS.md 2>/dev/null; then
  row "$OK" "재시도·에스컬레이션 규칙" "AGENTS.md §5에 선언됨"
else
  row "$NO" "재시도·에스컬레이션 규칙" "AGENTS.md §5에 없다"
fi
if [ -f AGENTS.md ] && grep -q '^## A\.' AGENTS.md 2>/dev/null; then
  gaps=$(awk '/^## A\./{i=1;next} i&&/^## /{i=0} i&&/^\|/&&!/^\|[ -]*$/&&!/검증되지 않는 것/' AGENTS.md | grep -vc '<<<' || true); gaps=${gaps:-0}
  row "$OK" "알려진 센서 공백(§A)" "${gaps}건 명시됨"
else
  row "$WARN" "알려진 센서 공백(§A)" "섹션이 없다 — '센서 통과=안전' 오해가 남는다"
fi

# ── Layer 4: Memory ──────────────────────────────────────────────────
head_ "Layer 4 — Memory / State"
for f in HANDOFF.md plan.md decisions.md; do
  if [ -f "$f" ]; then
    mt=$(date -r "$f" '+%Y-%m-%d' 2>/dev/null || stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
    row "$OK" "$f" "최종 갱신 $mt"
  else
    row "$NO" "$f" "없음 — 세션이 끊기면 여기까지가 사라진다"
  fi
done

# ── Layer 5: Permissions ─────────────────────────────────────────────
head_ "Layer 5 — Permissions (Claude Code 전용 설정)"
if [ -f .claude/settings.json ]; then
  if command -v python3 >/dev/null 2>&1; then
    if python3 -c 'import json,sys;json.load(open(".claude/settings.json"))' 2>/dev/null; then
      na=$(python3 -c 'import json;d=json.load(open(".claude/settings.json"));p=d.get("permissions",{});print(len(p.get("allow",[])),len(p.get("ask",[])),len(p.get("deny",[])))' 2>/dev/null)
      row "$OK" ".claude/settings.json" "allow/ask/deny = $na"
    else
      row "$NO" ".claude/settings.json" "JSON 파싱 실패 — 권한이 적용되지 않는다"
    fi
  else
    row "$OK" ".claude/settings.json" "있음 (파싱 검사는 python3 필요)"
  fi
else
  row "$NO" ".claude/settings.json" "없음 — 권한이 산문에만 있다"
fi
# 워크스페이스 신뢰 — 신뢰되지 않으면 permissions.allow가 **전부 무시**된다.
# 그러면 Stop 게이트가 요구하는 make check조차 승인 대상이 되어 교착이 생긴다.
# (2026-09-14 헤드리스 실측 — docs/EVIDENCE.md §G)
if command -v python3 >/dev/null 2>&1 && [ -f "$HOME/.claude.json" ]; then
  trust=$(python3 -c '
import json, os, sys
try:
    d = json.load(open(os.path.expanduser("~/.claude.json")))
    e = d.get("projects", {}).get(os.getcwd())
    print("none" if e is None else ("yes" if e.get("hasTrustDialogAccepted") else "no"))
except Exception:
    print("unknown")
' 2>/dev/null || echo unknown)
  case "$trust" in
    yes)  row "$OK" "워크스페이스 신뢰" "수락됨 — allow 규칙이 적용된다" ;;
    no|none)
      row "$NO" "워크스페이스 신뢰" "미수락 — .claude/settings.json의 allow가 전부 무시된다"
      printf '  %-32s %s\n' "" "대화형으로 한 번 열어 신뢰 대화를 수락한다 (그 전까지 센서 실행이 막힌다)" ;;
    *) row "$WARN" "워크스페이스 신뢰" "확인 실패" ;;
  esac
fi

hooks=$(git config core.hooksPath 2>/dev/null || echo "")
# Git이 사용하는 경로를 해석한다. 절대경로·정규화된 상대경로·심볼릭 링크도
# 프로젝트의 .githooks와 같은 폴더면 연결된 상태다.
hooks_path=$(git rev-parse --git-path hooks 2>/dev/null || echo "")
hooks_real=$(cd "$hooks_path" 2>/dev/null && pwd -P) || hooks_real=""
expected_hooks_real=$(cd .githooks 2>/dev/null && pwd -P) || expected_hooks_real=""
if [ -n "$expected_hooks_real" ] && [ "$hooks_real" = "$expected_hooks_real" ]; then
  row "$OK" "core.hooksPath" "${hooks:-미설정} — 프로젝트 .githooks 연결됨"
else
  row "$NO" "core.hooksPath" "${hooks:-미설정} — 프로젝트 .githooks 미연결. make install"
fi
for hook in pre-commit commit-msg; do
  if [ -x ".githooks/$hook" ]; then
    row "$OK" "$hook 실행 권한" "있음 (공통 Git 게이트)"
  else
    row "$NO" "$hook 실행 권한" "없음 — chmod +x .githooks/$hook"
  fi
done
for config in .codex/hooks.json .gemini/settings.json; do
  if [ -f "$config" ]; then
    row "$WARN" "$config" "파일 있음; 런타임 연결·신뢰 미확인"
  else
    row "$WARN" "$config" "턴 게이트 미설정 (공통 Git 게이트와 별개)"
  fi
done

# Claude Code 훅 — 산문을 환경으로 승격시키는 지점
if [ -f .claude/settings.json ] && command -v python3 >/dev/null 2>&1; then
  hk=$(python3 -c 'import json;print(",".join(json.load(open(".claude/settings.json")).get("hooks",{}).keys()) or "없음")' 2>/dev/null || echo "?")
  if [ "$hk" = "없음" ]; then
    row "$NO" "Claude Code 훅" "없음 — Claude 턴 게이트 미설정"
  else
    row "$OK" "Claude Code 훅" "$hk"
  fi
fi
for h in session-start mark-dirty sensor-gate guard-secrets; do
  if [ -f "hooks/$h.sh" ]; then
    [ -x "hooks/$h.sh" ] && row "$OK" "hooks/$h.sh" "있음" \
      || row "$NO" "hooks/$h.sh" "실행 권한 없음 — chmod +x hooks/*.sh"
  else
    row "$WARN" "hooks/$h.sh" "없음"
  fi
done
[ "${HARNESS_GATE:-on}" = "off" ] && row "$WARN" "센서 게이트" "HARNESS_GATE=off 로 꺼져 있다"

# ── 키트 버전 / 미검증 변경 ──────────────────────────────────────────
head_ "하네스 버전 · 미검증 변경"
if [ -f .harness/VERSION ]; then
  v=$(cat .harness/VERSION 2>/dev/null | tr -d '[:space:]')
  row "$OK" "배치된 키트 버전" "${v:-미상}"
  printf '  %-32s %s\n' "" "상류와 비교: sh <kit>/init.sh . --update"
else
  row "$WARN" "배치된 키트 버전" "기록 없음 — 상류 갱신을 추적할 수 없다"
fi
if [ -f .harness/state/dirty ]; then
  n=$(sort -u .harness/state/dirty 2>/dev/null | grep -c . || echo 0)
  row "$NO" "미검증 변경" "${n}개 파일 — make check 필요"
else
  row "$WARN" "Claude 변경 마커" "없음; 다른 도구의 변경·센서 통과 여부는 미확인"
fi

# ── git 상태 ─────────────────────────────────────────────────────────
head_ "git"
br=$(git branch --show-current 2>/dev/null || echo "")
row "$OK" "현재 브랜치" "${br:-확인 실패}"
dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ "$dirty" = "0" ] \
  && row "$OK" "워킹트리" "깨끗" \
  || row "$WARN" "워킹트리" "변경 ${dirty}건"

# ── 스택 고유 점검 ───────────────────────────────────────────────────
# 프로젝트 소유 파일 tool/doctor-stack.sh를 하위 셸에서 실행한다. 예:
#   - 런타임 버전이 AGENTS.md §2 선언과 일치하는가
#   - 의존성이 설치돼 있는가 (node_modules / .dart_tool / .venv …)
#   - 화면·API 동작에 필요한 외부 의존이 떠 있는가 (DB, 에뮬레이터, 백엔드 …)
# 그 파일이 실패해도 doctor는 exit 0을 지킨다.
head_ "스택 고유"
if [ -f tool/doctor-stack.sh ]; then
  ( . tool/doctor-stack.sh ) \
    || row "$WARN" "tool/doctor-stack.sh" "실행 중 오류 — 그 파일을 고친다"
else
  row "$WARN" "스택 고유 점검" "없음 — tool/doctor-stack.sh에 런타임·의존성·외부 의존 점검을 추가"
fi

printf "\n참고: 센서(lint/test)는 외부 의존 없이도 통과할 수 있다.\n"
printf "      센서 통과는 '제품이 동작한다'를 의미하지 않는다 (AGENTS.md §3·§A).\n\n"
exit 0
