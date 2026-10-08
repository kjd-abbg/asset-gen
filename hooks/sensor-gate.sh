#!/bin/sh
# Stop — 파일을 고쳐놓고 센서를 안 돌린 채 끝내려 하면 막는다.
#
# 이것이 하네스에서 **산문을 환경으로 승격시키는 지점**이다.
# AGENTS.md §3의 "센서를 돌리지 않은 변경은 완료가 아니다"는 마크다운일 때는
# 권고에 불과하다. 여기서는 턴이 실제로 끝나지 않는다.
#
#   근거: Böckeler, "Maintainability sensors for coding agents" —
#   "Verifying agent sensor compliance requires explicit hooks or extensions;
#    markdown guides alone prove unreliable."
#   그리고 신뢰도 사다리(HARNESS_ENGINEERING.md §10): 환경 > 센서 > 가이드.
#
# 동작:
#   .harness/state/dirty 가 있으면 → exit 2 (종료 거부). 사유가 Claude에게
#   되먹여지므로 Claude는 `make check`를 돌리고 다시 끝내려 한다.
#   `make check`가 성공하면 dirty가 지워지고 통과한다.
#
# ⚠ 무한 루프 방지: 같은 세션에서 GATE_MAX_FIRES(기본 2)번 막고 나면 그 뒤로는
#   통과시킨다. 센서가 계속 실패해서 끝낼 수 없는 상태에 사용자를 가두지 않기
#   위해서다. 그때는 막는 대신 "미검증 상태로 끝난다"는 사실을 남긴다.
#
# ⚠ fail-open: 이 스크립트가 깨지면 세션을 막지 않는다. 하네스가 작업을
#   불가능하게 만들면 사람은 하네스를 꺼버린다.
#
# 끄는 법: .claude/settings.json 의 hooks.Stop 항목을 지운다.
#          일시적으로는 HARNESS_GATE=off 환경변수.

[ "${HARNESS_GATE:-on}" = "off" ] && exit 0

PROJ="${CLAUDE_PROJECT_DIR:-.}"
STATE_DIR="$PROJ/.harness/state"
DIRTY="$STATE_DIR/dirty"
GATE_MAX_FIRES="${GATE_MAX_FIRES:-2}"

[ -f "$DIRTY" ] || exit 0

input=$(cat 2>/dev/null || true)

session="unknown"
if command -v python3 >/dev/null 2>&1 && [ -n "$input" ]; then
  session=$(printf '%s' "$input" | python3 -c '
import sys, json
try:
    print(json.load(sys.stdin).get("session_id") or "unknown")
except Exception:
    print("unknown")
' 2>/dev/null || echo "unknown")
fi

FIRES="$STATE_DIR/gate-$session"
n=0
[ -f "$FIRES" ] && n=$(cat "$FIRES" 2>/dev/null | tr -d '[:space:]')
case "$n" in ''|*[!0-9]*) n=0 ;; esac

changed=$(sort -u "$DIRTY" 2>/dev/null | head -5 | sed 's/^/    - /')
count=$(sort -u "$DIRTY" 2>/dev/null | grep -c . || echo 0)

if [ "$n" -ge "$GATE_MAX_FIRES" ]; then
  # 더는 막지 않는다. 대신 미검증 상태라는 사실을 명시적으로 남긴다.
  printf '{"systemMessage":"⚠ 센서 게이트: %s개 파일이 바뀌었으나 `make check`가 통과하지 않은 채 턴이 끝난다. 이 변경은 **미검증**이다 — HANDOFF.md에 그렇게 적는다."}\n' "$count"
  exit 0
fi

n=$((n + 1))
printf '%s\n' "$n" > "$FIRES"

# exit 2 = 종료 차단. stderr가 Claude에게 사유로 전달된다.
cat >&2 <<EOF
센서 미실행 — 아직 끝낼 수 없다.

이번 턴에 ${count}개 파일이 바뀌었다:
${changed}

AGENTS.md §3: 센서를 돌리지 않은 변경은 "완료"가 아니다.

다음을 실행하고 결과를 보고한 뒤 끝내라:

    make check

- 통과하면 이 게이트는 자동으로 열린다.
- 실패하면 고치거나, 못 고치면 **무엇이 왜 실패하는지 그대로 보고**한다.
  성공했다고 말하지 않는다 (§5).
- 환경 때문에 못 돌리는 센서는 "통과"가 아니라 "미실행"이다.

**\`make check\` 실행 자체가 권한으로 막히면** 이 게이트는 통과할 수 없다.
그때는 우회하려 하지 말고 그 사실을 그대로 보고한다. 흔한 원인은 워크스페이스
미신뢰다 — 신뢰되지 않은 워크스페이스에서는 \`.claude/settings.json\`의 allow가
**전부 무시된다**. \`make doctor\`가 이 상태를 표시한다.

(이 게이트는 세션당 ${GATE_MAX_FIRES}번까지만 막는다. 끄려면 HARNESS_GATE=off)
EOF
exit 2
