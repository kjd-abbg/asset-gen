#!/bin/sh
# SessionStart — 새 세션에 "지금 어디까지 했는지"를 먼저 쥐어준다.
#
# 왜 필요한가: 모델은 세션마다 맥락을 잃는다. AGENTS.md §0이 "세션 시작 시
# HANDOFF.md를 읽어라"라고 적어두지만, 읽었는지는 아무도 확인하지 않는다.
# SessionStart 훅의 stdout은 **Claude에게 그대로 전달되므로**, 읽으라고
# 부탁하는 대신 그냥 쥐어준다.
#
#   근거: Anthropic, "Harness design for long-running application development" —
#   진행 아티팩트(claude-progress.txt)를 fresh context가 먼저 읽게 해서
#   세션 간 상태를 잇는 패턴.
#
# ⚠ 항상 exit 0. 아무것도 막지 않는다.

PROJ="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJ" 2>/dev/null || exit 0

[ -f AGENTS.md ] || exit 0        # 하네스가 없는 저장소면 조용히 빠진다

printf '## 하네스 상태 (SessionStart 훅)\n\n'

if [ -f HANDOFF.md ]; then
  mt=$(date -r HANDOFF.md '+%Y-%m-%d' 2>/dev/null || echo '?')
  printf '**HANDOFF.md** (최종 갱신 %s) — 상단 발췌:\n\n' "$mt"
  sed -n '1,25p' HANDOFF.md | sed 's/^/> /'
  printf '\n'
else
  printf '⚠ HANDOFF.md가 없다 — 이전 세션의 진행 상황을 알 수 없다.\n\n'
fi

# 미검증 변경이 남아 있으면 알린다 (sensor-gate와 같은 표시를 본다)
if [ -f .harness/state/dirty ]; then
  n=$(sort -u .harness/state/dirty 2>/dev/null | grep -c . || echo 0)
  printf '⚠ **이전 세션이 %s개 파일을 고치고 `make check`를 통과시키지 않았다.**\n' "$n"
  printf '   먼저 `make check`로 현재 상태를 확인한다.\n\n'
fi

# 키트 버전 드리프트
if [ -f .harness/VERSION ]; then
  printf '하네스 키트 버전: %s (`make doctor`로 상류 갱신 여부 확인)\n' "$(cat .harness/VERSION)"
fi

exit 0
