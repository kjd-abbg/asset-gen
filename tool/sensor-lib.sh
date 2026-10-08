# shellcheck shell=sh
# 센서 출력 규약 공통 라이브러리 — source해서 쓴다. 직접 실행하지 않는다.
#
# 규약 전문: agent-harness-kit/docs/SENSOR_CONTRACT.md
#
# 왜 라이브러리인가: 규약을 문서로만 두면 센서마다 조금씩 다르게 구현된다.
# 여기 함수를 쓰면 20줄 상한·FIX: 강제·로그 분리·종료 코드가 공짜로 따라온다.
#
# 사용법:
#   . "$(dirname "$0")/sensor-lib.sh"
#   sensor_begin lint
#   sensor_issue "src/a.ts:42" "미사용 import" "그 줄을 삭제한다"
#   sensor_end          # PASS면 exit 0, 아니면 exit 1
#
# 센서 자체가 돌 수 없는 상황(설정 누락 등)이면:
#   sensor_broken "린트 설정 파일이 없다" "npx eslint --init 으로 만든다"
#   → exit 2. 에이전트가 코드를 고쳐서 해결할 수 없는 문제라는 신호다.

SENSOR_MAX_SHOWN=${SENSOR_MAX_SHOWN:-5}
SENSOR_LOG_DIR=${SENSOR_LOG_DIR:-.harness/logs}

_sensor_slot=""
_sensor_file=""
_sensor_n=0

sensor_begin() {
  _sensor_slot="$1"
  _sensor_n=0
  mkdir -p "$SENSOR_LOG_DIR" 2>/dev/null || true
  _sensor_file=$(mktemp 2>/dev/null || echo "/tmp/sensor.$$")
  : > "$_sensor_file"
}

# sensor_issue <위치> <무엇이 문제인지> <어떻게 고치는지>
# 세 번째 인자가 비면 규약 위반이다 — 그 사실을 출력에 드러낸다.
sensor_issue() {
  _loc="$1"; _what="$2"; _fix="${3:-}"
  _sensor_n=$((_sensor_n + 1))
  if [ -z "$_fix" ]; then
    _fix="(FIX 없음 — 이 센서는 미완성이다. SENSOR_CONTRACT.md §2 참고)"
  fi
  printf '%s — %s — FIX: %s\n' "$_loc" "$_what" "$_fix" >> "$_sensor_file"
}

sensor_count() { echo "$_sensor_n"; }

sensor_end() {
  if [ "$_sensor_n" -eq 0 ]; then
    printf '[sensor:%s] PASS\n' "$_sensor_slot"
    rm -f "$_sensor_file"
    return 0
  fi

  _log="$SENSOR_LOG_DIR/$_sensor_slot.log"
  cp "$_sensor_file" "$_log" 2>/dev/null || _log=""

  printf '[sensor:%s] FAIL (%s issues)\n' "$_sensor_slot" "$_sensor_n"
  _i=0
  while IFS= read -r line; do
    _i=$((_i + 1))
    [ "$_i" -gt "$SENSOR_MAX_SHOWN" ] && break
    printf '  %s. %s\n' "$_i" "$line"
  done < "$_sensor_file"

  if [ "$_sensor_n" -gt "$SENSOR_MAX_SHOWN" ]; then
    if [ -n "$_log" ]; then
      printf '  (%s개 중 상위 %s개만 표시 — 전체는 %s)\n' \
        "$_sensor_n" "$SENSOR_MAX_SHOWN" "$_log"
    else
      printf '  (%s개 중 상위 %s개만 표시)\n' "$_sensor_n" "$SENSOR_MAX_SHOWN"
    fi
  fi

  rm -f "$_sensor_file"
  return 1
}

# 센서가 돌 수 없는 상태 — 코드 문제가 아니라 설정·환경 문제다.
sensor_broken() {
  printf '[sensor:%s] ERROR — %s\n' "$_sensor_slot" "$1" >&2
  [ -n "${2:-}" ] && printf '  FIX: %s\n' "$2" >&2
  printf '  (exit 2 = 센서 자체 오류. 코드를 고쳐서 해결되지 않는다)\n' >&2
  exit 2
}

# 래칫: 현재 위반 수를 baseline과 비교한다.
# 늘면 실패, 같거나 줄면 통과(줄었으면 갱신을 안내한다).
sensor_ratchet() {
  _baseline_file="$1"; _current="$2"
  if [ ! -f "$_baseline_file" ]; then
    printf '[sensor:%s] PASS (baseline 신규 생성: %s건)\n' "$_sensor_slot" "$_current"
    printf '%s\n' "$_current" > "$_baseline_file"
    return 0
  fi
  _base=$(cat "$_baseline_file" 2>/dev/null | tr -d '[:space:]')
  case "$_base" in ''|*[!0-9]*) _base=0 ;; esac

  if [ "$_current" -gt "$_base" ]; then
    printf '[sensor:%s] FAIL (%s issues, baseline %s)\n' "$_sensor_slot" "$_current" "$_base"
    printf '  1. (전체) — 위반이 baseline보다 %s건 늘었다 — FIX: 새로 추가한 위반을 없애거나, 의도한 것이면 %s를 갱신한다\n' \
      "$((_current - _base))" "$_baseline_file"
    return 1
  fi
  if [ "$_current" -lt "$_base" ]; then
    printf '[sensor:%s] PASS (%s건 — baseline %s보다 줄었다. 갱신하려면 baseline에 %s을 쓴다)\n' \
      "$_sensor_slot" "$_current" "$_base" "$_current"
    return 0
  fi
  printf '[sensor:%s] PASS (%s건 — baseline 이내)\n' "$_sensor_slot" "$_current"
  return 0
}
