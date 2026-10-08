#!/bin/sh
# PostToolUse(Edit|Write|NotebookEdit) — 소스가 바뀌었음을 기록한다.
#
# 왜 필요한가: AGENTS.md §3은 "센서를 돌리지 않은 변경은 완료가 아니다"라고
# 선언하지만, 마크다운 선언만으로는 그것이 지켜졌는지 알 수 없다.
#   Böckeler: "Verifying agent sensor compliance requires explicit hooks or
#              extensions — markdown guides alone prove unreliable."
# 이 훅이 '고쳤다'를 기록하고, sensor-gate.sh(Stop)가 '검증했나'를 묻는다.
# `make check`가 성공하면 이 표시가 지워진다.
#
# ⚠ 이 훅은 아무것도 막지 않는다. 항상 exit 0이다.
#    막는 것은 Stop 훅 하나뿐이고, 그래야 편집 중 흐름이 끊기지 않는다.

STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.harness/state"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

# stdin의 JSON에서 파일 경로만 뽑는다. 실패하면 경로 없이 표시만 남긴다.
path=""
input=$(cat 2>/dev/null || true)
if command -v python3 >/dev/null 2>&1 && [ -n "$input" ]; then
  path=$(printf '%s' "$input" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get("tool_input") or {}
    print(ti.get("file_path") or ti.get("notebook_path") or "")
except Exception:
    print("")
' 2>/dev/null || echo "")
fi

printf '%s\n' "${path:-(경로 미상)}" >> "$STATE_DIR/dirty"
exit 0
