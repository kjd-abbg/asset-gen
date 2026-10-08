#!/bin/sh
# 역방향 동기화 — 이 프로젝트의 하네스가 상류 키트와 어디가 다른지 보여준다.
#
# `init.sh --update` 는 키트 → 프로젝트 방향이다. 이 스크립트는 반대다:
# **이 프로젝트에서 얻은 개선을 키트로 올릴지 판단**하게 해준다.
#
# 왜 필요한가: 하네스는 실제 작업 중에 좋아진다. 여기서 센서를 하나 고치고
# 저기서 훅을 하나 더하는데, 그것이 키트로 돌아가지 않으면 **다음 프로젝트는
# 같은 실패를 처음부터 다시 겪는다.** 래칫이 프로젝트 하나 안에서만 돌고
# 조직 전체로는 돌지 않는 상태다.
#
# ⚠ 이 스크립트는 아무것도 바꾸지 않는다. 항상 exit 0이다 — 센서가 아니다.
#    무엇이 다른지 보여줄 뿐, 올릴지 말지는 사람이 정한다.
#
# 사용법: make harness-upstream

set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

OK="\033[32m✓\033[0m"; WARN="\033[33m⚠\033[0m"; NO="\033[31m✗\033[0m"

# 비교하려면 키트가 로컬에 있어야 한다. 찾는 순서:
#   1) 인자        make harness-upstream KIT=~/somewhere
#   2) 환경변수    HARNESS_KIT
#   3) 흔한 위치   ~/harness-kit, 형제 디렉터리
#   4) .harness/ORIGIN (로컬 경로로 적혀 있을 때만)
ORIGIN=$(cat .harness/ORIGIN 2>/dev/null | tr -d '[:space:]')
KIT="${KIT:-${HARNESS_KIT:-}}"
# make 명령줄 인자(KIT=~/x)는 셸을 거치지 않아 ~ 가 확장되지 않는다.
case "$KIT" in "~/"*) KIT="$HOME/${KIT#\~/}" ;; esac
if [ -z "$KIT" ]; then
  for c in "$HOME/harness-kit" "../agent-harness-kit" "$ORIGIN"; do
    if [ -d "$c/template" ]; then KIT=$(cd "$c" && pwd); break; fi
  done
fi
MYVER=$(cat .harness/VERSION 2>/dev/null | tr -d '[:space:]')

printf '\n\033[1m하네스 역방향 동기화\033[0m — 이 프로젝트 → 키트\n\n'

if [ -z "$KIT" ] || [ ! -d "$KIT/template" ]; then
  printf "$NO 비교할 키트를 로컬에서 찾지 못했다\n\n"
  printf '  원격: %s\n\n' "${ORIGIN:-미상}"
  printf '  클론한 뒤 경로를 알려준다:\n'
  printf '    git clone %s ~/harness-kit\n' "${ORIGIN:-<키트 URL>}"
  printf '    make harness-upstream            # ~/harness-kit 를 자동으로 찾는다\n'
  printf '    make harness-upstream KIT=<경로>  # 다른 위치면 직접 지정\n\n'
  exit 0
fi

printf '  이 프로젝트: %s\n  상류 키트:   %s\n' "${MYVER:-미상}" "$KIT"

KITVER=$(cat "$KIT/VERSION" 2>/dev/null | tr -d '[:space:]')
printf '  상류 버전:   %s\n\n' "${KITVER:-미상}"

# 키트가 관리하는 인프라 파일 — init.sh의 infra() 목록과 같아야 한다.
# 빠진 파일은 --update가 덮어쓰는데도 여기서 차이가 보이지 않는다(selftest F23).
INFRA="tool/sensor-lib.sh tool/check-commands.sh tool/check-guide.sh
tool/harness-doctor.sh tool/harness-upstream.sh tool/check-prose.sh
hooks/session-start.sh hooks/mark-dirty.sh hooks/sensor-gate.sh hooks/guard-secrets.sh
hooks/check-on-stop.py .githooks/pre-commit .githooks/commit-msg HARNESS_ENGINEERING.md docs/UI_VALIDATION.md docs/UI_COPY.md tool/check-ui-copy.py tool/check-design-literals.sh docs/VISUAL_DESIGN.md docs/DESIGN_REVIEW.md docs/DESIGN_LIBRARY.md docs/UI_QUICKSTART.md
docs/DESIGN_SYSTEM.md tool/check-design-md.sh tool/gen-design-tokens.sh tool/design-candidates.py
docs/ACCESSIBILITY.md docs/UX_DESIGN.md docs/LOGO_DESIGN.md
docs/DESIGN_TOKENS.md docs/VISUAL_ASSETS.md docs/PRODUCT_PLANNING.md
docs/SECURITY.md docs/PRIVACY_LEGAL.md docs/OPERATIONS.md docs/SEO_GEO.md
docs/AI_FEATURES.md docs/EMAIL_DELIVERY.md docs/INDEX.md
.claude/skills/spec-lint/SKILL.md .claude/skills/implementability-review/SKILL.md
.claude/skills/adversarial-review/SKILL.md .claude/skills/harness-steer/SKILL.md
.claude/skills/drift-scan/SKILL.md .claude/skills/harness-upstream/SKILL.md"

diverged=0
printf '\033[1m── 상류와 다른 인프라 파일\033[0m\n'
for f in $INFRA; do
  case "$f" in
    tool/*|hooks/*) up="$KIT/template/$f" ;;
    .githooks/*)    up="$KIT/template/githooks/$(basename "$f")" ;;
    .claude/skills/*) up="$KIT/template/skills/${f#.claude/skills/}" ;;
    *)              up="$KIT/$f" ;;
  esac
  [ -f "$f" ] || continue
  if [ ! -f "$up" ]; then
    printf "  $WARN %-34s 상류에 없다 — 이 프로젝트가 새로 만든 것인가?\n" "$f"
    diverged=$((diverged + 1)); continue
  fi
  if ! cmp -s "$f" "$up"; then
    n=$(diff "$up" "$f" 2>/dev/null | grep -c '^[<>]' || echo '?')
    printf "  $NO %-34s %s줄 다름\n" "$f" "$n"
    diverged=$((diverged + 1))
  fi
done
[ "$diverged" -eq 0 ] && printf "  $OK 인프라는 상류와 동일하다\n"

# 이 프로젝트가 독자적으로 만든 센서·훅 — 키트 후보다.
printf '\n\033[1m── 이 프로젝트에만 있는 센서·훅 (키트 후보)\033[0m\n'
local_only=0
for f in tool/* hooks/*; do
  [ -f "$f" ] || continue
  case "$f" in *-baseline.json|*.json) continue ;; esac
  base=$(basename "$f")
  case "$f" in
    tool/*)  up="$KIT/template/tool/$base" ;;
    hooks/*) up="$KIT/template/hooks/$base" ;;
  esac
  if [ ! -f "$up" ]; then
    printf "  $WARN %-34s 상류에 없다\n" "$f"
    local_only=$((local_only + 1))
  fi
done
[ "$local_only" -eq 0 ] && printf "  $OK 독자 추가 없음\n"

printf '\n\033[1m── 판단 기준\033[0m\n'
cat <<'JUDGE'
  각 차이에 대해 물어본다 — 답이 "모든 스택에서 참"이면 키트로 올린다.

  키트로 올린다                     이 프로젝트에 남긴다
  ─────────────────────────────    ─────────────────────────────
  모든 스택에서 참인 규칙            특정 도구·버전에 묶인 것
  실패의 **종류**를 막는 구조        특정 실패의 **증상**
  기계로 검사 가능한 것              주관적 판단이 필요한 것
  비어 있어도 해롭지 않은 뼈대       채워두면 낡는 내용

  애매하면 키트의 docs/EVIDENCE.md에 **사례로** 넣는다.
  사례는 낡아도 참고로 남지만, 코어에 박힌 거짓은 에이전트가 그대로 믿는다.
JUDGE

if [ "$diverged" -gt 0 ] || [ "$local_only" -gt 0 ]; then
  printf '\n\033[1m── 올리는 절차\033[0m\n'
  cat <<NEXT
  1) 차이를 본다        diff $KIT/template/tool/<파일> tool/<파일>
  2) 키트에서 브랜치    git -C $KIT checkout -b fix/<무엇>
  3) 키트를 고치고 **반드시** sh $KIT/tool/selftest.sh
  4) docs/HARNESS.md 인벤토리와 docs/SOURCES.md 근거를 함께 고친다
  5) PR을 올린다        gh pr create --repo ABBG-DevTeam/agent-harness-kit
  6) 머지 후 각 프로젝트에서  sh $KIT/init.sh . --update

  왜 손으로 복사하지 않는가: 키트를 고치면 셀프테스트와 근거 문서가
  함께 따라와야 한다. 파일만 옮기면 그 둘이 빠지고, 다음 사람은 그 규칙이 왜
  있는지 모른 채 지운다.
NEXT
else
  printf '\n  올릴 것이 없다 — 이 프로젝트의 하네스는 상류와 같다.\n'
fi
printf '\n'
exit 0
