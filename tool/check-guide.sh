#!/bin/sh
# [sensor:guide] 가이드 위생 — AGENTS.md가 스스로에 대해 거짓말하지 않는지.
#
# 왜 필요한가: 가이드의 가치는 "적힌 것이 사실"이라는 전제에서만 나온다. 채우지
# 않은 자리, 날짜 없는 실패 사례, 실재하지 않는 파일을 가리키는 하네스 지도,
# "막으려는 실패"가 빈 인벤토리는 전부 그 전제를 깬다. 사람은 그런 문서를 대충
# 읽고 넘기지만 에이전트는 그대로 믿는다.
#
# 검사 6종:
#   1) 도구별 가이드 파일(CLAUDE.md·.cursorrules·copilot·windsurf·cline·GEMINI)이
#      전부 AGENTS.md를 가리키는 포인터인가 (본문 이중화 방지)
#   2) AGENTS.md에 <<<미채움>>> 자리가 남아 있지 않은가
#   3) AGENTS.md가 인덱스 분량을 지키는가 (기본 상한 200줄, 생성 블록 제외)
#   4) §1 하네스 지도가 가리키는 파일이 실재하는가
#   5) §B ANTI-PATTERNS 항목에 전부 날짜(YYYY-MM-DD)가 있는가
#   6) docs/HARNESS.md 인벤토리의 "막으려는 실패" 칸이 채워져 있는가
#
# 6번 근거: Anthropic — "Every component in a harness encodes an assumption about
# what the model can't do on its own, and those assumptions are worth stress
# testing." 왜 존재하는지 없으면 언제 제거해도 되는지 판단할 수 없다.
#
# ⚠ 배치 직후에는 2번 때문에 실패하는 것이 정상이다. 그것이 Day 1 exit test다.
#
# 출력 규약: agent-harness-kit/docs/SENSOR_CONTRACT.md
# 종료 코드: 0 통과 / 1 위생 위반 / 2 센서 자체 오류

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/tool/sensor-lib.sh"

GUIDE="$ROOT/AGENTS.md"
INVENTORY="$ROOT/docs/HARNESS.md"
GUIDE_MAX_LINES=${GUIDE_MAX_LINES:-200}

sensor_begin guide

# 검사 대상 개수. 0건 검사와 0건 위반이 구분되지 않으면 센서는 잠들 수 있다.
N_PTR=0; N_MAP=0; N_AP=0; N_INV=0

[ -f "$GUIDE" ] || sensor_broken "AGENTS.md가 없다" "sh <kit>/init.sh . 로 배치한다"

# ── 1) 도구별 가이드 파일은 전부 AGENTS.md를 가리키는 포인터여야 한다 ──
#
# AGENTS.md 하나만 본문이고 나머지는 포인터다. 본문을 복사해두고 "싱크를 맞춘다"는
# 접근은 반드시 갈라진다 — 갈라지는 순간 어느 쪽도 신뢰할 수 없다.
# 근거: Anthropic 공식 문서 — "create a CLAUDE.md that imports it so both tools
#       read the same instructions without duplicating them."
# 포인터 아래에 도구 전용 지시를 조금 덧붙이는 것은 허용된다(같은 문서).
# 그것이 본문 복제로 커지는 것만 막는다.
POINTER_MAX_LINES=${POINTER_MAX_LINES:-25}

check_pointer() { # $1=경로 $2=필수인가(1/0) $3=가리키는 방법 안내
  f="$ROOT/$1"
  if [ ! -e "$f" ]; then
    [ "$2" = "1" ] && sensor_issue "$1" "파일이 없다 — 이 도구가 AGENTS.md를 읽지 못한다" "$3"
    return 0
  fi
  # 심볼릭 링크로 AGENTS.md를 가리키면 그 자체로 동기화된다.
  if [ -L "$f" ]; then
    N_PTR=$((N_PTR + 1))
    tgt=$(readlink "$f")
    case "$tgt" in *AGENTS.md) return 0 ;; esac
    sensor_issue "$1" "심볼릭 링크가 AGENTS.md가 아닌 \`$tgt\`을 가리킨다" "ln -sf AGENTS.md $1"
    return 0
  fi
  N_PTR=$((N_PTR + 1))
  n=$(grep -vc '^[[:space:]]*$' "$f" 2>/dev/null || echo 0)
  if ! grep -q 'AGENTS\.md' "$f" 2>/dev/null; then
    sensor_issue "$1" "AGENTS.md를 가리키지 않는다 — 본문이 두 곳에 있으면 반드시 어긋난다" "$3"
  elif [ "${n:-0}" -gt "$POINTER_MAX_LINES" ]; then
    sensor_issue "$1" "${n}줄 — 포인터가 아니라 본문이 돼가고 있다 (상한 ${POINTER_MAX_LINES}줄)" \
      "공통 내용은 AGENTS.md로 옮기고 여기에는 이 도구 전용 지시만 남긴다"
  fi
}

# Claude Code는 AGENTS.md를 읽지 않으므로 CLAUDE.md가 필수다.
check_pointer "CLAUDE.md" 1 "printf '@AGENTS.md\\n' > CLAUDE.md  (또는 ln -s AGENTS.md CLAUDE.md)"

# 있으면 검사하고, 없으면 넘어간다 — 쓰지도 않는 도구 파일을 만들게 하지 않는다.
check_pointer ".cursorrules"                     0 "내용을 'AGENTS.md를 따른다'로 바꾸고 본문은 AGENTS.md에 둔다"
check_pointer ".github/copilot-instructions.md"  0 "내용을 'AGENTS.md를 따른다'로 바꾸고 본문은 AGENTS.md에 둔다"
check_pointer ".windsurfrules"                   0 "내용을 'AGENTS.md를 따른다'로 바꾸고 본문은 AGENTS.md에 둔다"
check_pointer ".clinerules"                      0 "내용을 'AGENTS.md를 따른다'로 바꾸고 본문은 AGENTS.md에 둔다"
check_pointer "GEMINI.md"                        0 "내용을 'AGENTS.md를 따른다'로 바꾸고 본문은 AGENTS.md에 둔다"

# ── 2) 미채움 자리 ───────────────────────────────────────────────────
# 파이프의 while은 서브셸이라 카운트가 부모로 올라오지 않는다. 파일로 받는다.
grep -n '<<<' "$GUIDE" > /tmp/hs_holes.$$ 2>/dev/null || true
if [ -s /tmp/hs_holes.$$ ]; then
  while IFS= read -r h; do
    ln=${h%%:*}
    txt=$(printf '%s' "${h#*:}" | sed 's/^[[:space:]]*//' | cut -c1-50)
    sensor_issue "AGENTS.md:$ln" "미채움 자리가 남아 있다 (${txt}…)" \
      "실제 값으로 채우거나, 해당 없으면 그 줄을 지운다"
  done < /tmp/hs_holes.$$
fi
rm -f /tmp/hs_holes.$$

# ── 3) 인덱스 분량 ───────────────────────────────────────────────────
#
# 도구가 생성해 넣는 블록은 세지 않는다. 상한은 **사람이 쓴 분량**을 제한하는
# 장치인데, 생성 블록까지 세면 사람에게 지울 수 없는 것을 지우라고 요구하게 된다.
# (Next 16.3이 `next dev`마다 AGENTS.md에 블록을 덧붙인다 — EVIDENCE.md §G)
#
# 규약: <!-- BEGIN:이름 --> ... <!-- END:이름 --> 사이는 기계 관리 구역이다.
n_total=$(wc -l < "$GUIDE" | tr -d ' ')
n_gen=$(awk '
  /<!--[[:space:]]*BEGIN:/ { g = 1 }
  g { c++ }
  /<!--[[:space:]]*END:/   { g = 0 }
  END { print c+0 }
' "$GUIDE")
n_lines=$((n_total - n_gen))
if [ "$n_lines" -gt "$GUIDE_MAX_LINES" ]; then
  sensor_issue "AGENTS.md" "사람이 쓴 ${n_lines}줄 — 인덱스 상한 ${GUIDE_MAX_LINES}줄을 넘었다" \
    "설명 산문을 docs/로 옮기고 여기는 계약(명령·센서·권한·완료조건)만 남긴다. 상한을 바꾸려면 GUIDE_MAX_LINES 환경변수"
fi

# ── 4) §1 하네스 지도가 실재하는가 ───────────────────────────────────
mapped=$(awk '
  /^## 1\./       { inblk = 1; next }
  inblk && /^## / { inblk = 0 }
  inblk && /^\|/  { print }
' "$GUIDE" \
  | grep -oE '`[^`]+`' | tr -d '`' \
  | grep -E '[./]' | grep -v '<<<' | sort -u || true)

for f in $mapped; do
  case "$f" in
    *\**) continue ;;
    # 확장자만 적은 것(`.css` `.ts`)은 경로가 아니라 산문이다.
    # 점 뒤 4자 이하 영숫자이고 슬래시가 없으면 건너뛴다.
    # (daebak-admin 도입 중 발견 — docs/EVIDENCE.md §G)
    .*) case "$f" in
          */*) : ;;
          .[A-Za-z0-9]|.[A-Za-z0-9][A-Za-z0-9]|.[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]|.[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]) continue ;;
        esac ;;
  esac
  N_MAP=$((N_MAP + 1))
  if [ ! -e "$ROOT/$f" ]; then
    sensor_issue "AGENTS.md §1" "하네스 지도가 가리키는 \`$f\`이 실재하지 않는다" \
      "그 파일을 만들거나 §1 표에서 그 줄을 지운다"
  fi
done

# ── 5) ANTI-PATTERNS 날짜 ────────────────────────────────────────────
awk '
  /^## B\./       { inblk = 1; next }
  inblk && /^## / { inblk = 0 }
  inblk && /^- /  { if ($0 !~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/) print NR"\t"$0 }
' "$GUIDE" > /tmp/hs_undated.$$ 2>/dev/null || true
N_AP=$(awk '/^## B\./{i=1;next} i&&/^## /{i=0} i&&/^- /{c++} END{print c+0}' "$GUIDE")
if [ -s /tmp/hs_undated.$$ ]; then
  while IFS="$(printf '\t')" read -r ln txt; do
    sensor_issue "AGENTS.md:$ln" "ANTI-PATTERN 항목에 날짜가 없다 ($(printf '%s' "$txt" | cut -c1-40)…)" \
      "'- (YYYY-MM-DD) 증상 → 원인 → 고친 계층' 형식으로 날짜를 붙인다"
  done < /tmp/hs_undated.$$
fi
rm -f /tmp/hs_undated.$$

# ── 6) 상태 파일 ─────────────────────────────────────────────────────
for f in HANDOFF.md plan.md decisions.md; do
  [ -f "$ROOT/$f" ] || sensor_issue "$f" "§6이 선언한 상태 파일이 없다" \
    "빈 파일이라도 만든다 — 세션이 끊기면 진행 상황이 사라진다"
done

# ── 7) HARNESS.md 인벤토리의 "막으려는 실패" ─────────────────────────
if [ ! -f "$INVENTORY" ]; then
  sensor_issue "docs/HARNESS.md" "하네스 인벤토리가 없다" \
    "sh <kit>/init.sh . 로 배치하거나 템플릿을 복사한다 — 무엇이 왜 걸려 있는지 모르면 제거 판단을 못 한다"
else
  # 헤더 이름으로 찾는다. 기존 6컬럼과 작동 도구가 추가된 표를 모두 읽는다.
  # LC_ALL=C: macOS awk는 문자열 ==를 strcoll로 비교해 UTF-8 로케일에서 서로 다른
  # 한글 헤더를 같다고 판정한다. 그러면 '막으려는 실패' 열을 놓쳐 빈 칸이 통과한다.
  LC_ALL=C awk -F'|' '
    !/^\|/ { why=0; tool=0; next }
    /막으려는 실패/ && /추가일/ {
      why=0; tool=0
      for(i=2;i<NF;i++) {
        h=$i; gsub(/^[ \t]+|[ \t]+$/, "", h)
        if(h=="막으려는 실패") why=i
        if(h=="작동 도구") tool=i
      }
      next
    }
    /^\|[ :-]*\|/ { next }
    why {
      w=$why; gsub(/^[ \t]+|[ \t]+$/, "", w)
      t=$tool; gsub(/^[ \t]+|[ \t]+$/, "", t)
      if(w=="" || w=="-" || w ~ /^<<</ || (tool && (t=="" || t=="-" || t ~ /^<<</)))
        print NR"\t"$2
    }
  ' "$INVENTORY" > /tmp/hs_why.$$
  N_INV=$(awk '
    !/^\|/ { inv=0; next }
    /막으려는 실패/ && /추가일/ { inv=1; next }
    /^\|[ :-]*\|/ { next }
    inv { c++ } END { print c+0 }
  ' "$INVENTORY")
  [ "$N_INV" -gt 0 ] || sensor_issue "docs/HARNESS.md" "인벤토리 0건 검사" "이름·막으려는 실패·추가일 헤더가 있는 표를 복원한다"
  if [ -s /tmp/hs_why.$$ ]; then
    while IFS="$(printf '\t')" read -r ln nm; do
      sensor_issue "docs/HARNESS.md:$ln" "'$(printf '%s' "$nm" | tr -d ' ')' 항목의 '막으려는 실패' 또는 '작동 도구'가 비어 있다" \
        "어떤 실패를 막는지 한 줄로 적는다 — 비면 이 항목을 언제 제거해도 되는지 판단할 수 없다"
    done < /tmp/hs_why.$$
  fi
  rm -f /tmp/hs_why.$$
fi

if [ "$(sensor_count)" -eq 0 ]; then
  if [ "${n_gen:-0}" -gt 0 ]; then
    printf '[sensor:guide] PASS (포인터 %s · 지도 경로 %s · 실패사례 %s · 인벤토리 %s건 검사 · 가이드 %s줄 + 도구 생성 %s줄)\n' \
      "$N_PTR" "$N_MAP" "$N_AP" "$N_INV" "$n_lines" "$n_gen"
  else
    printf '[sensor:guide] PASS (포인터 %s · 지도 경로 %s · 실패사례 %s · 인벤토리 %s건 검사)\n' \
      "$N_PTR" "$N_MAP" "$N_AP" "$N_INV"
  fi
  exit 0
fi
sensor_end
