# 명령 진입점 — 이 프로젝트의 모든 명령은 `make <타깃>`이다.
#
# 왜 Makefile인가: 스택마다 명령이 다르다(npm run lint / dart analyze /
# cargo clippy / ruff check …). 가이드(AGENTS.md §2)가 그 차이를 그대로 안으면
# 스택이 바뀔 때마다 가이드를 다시 써야 하고, 에이전트는 저장소마다 다른 근육
# 기억을 요구받는다. **이름은 고정하고 뒷단만 바꾼다** — 그게 이 파일의 전부다.
#
# 센서 슬롯·출력 규약·실행 시점: agent-harness-kit/docs/SENSOR_CONTRACT.md
#
# ⚠ 이 파일은 단일 진실 공급원이 아니다. 뒷단 명령의 실체는 각 스택의 매니페스트
#    (package.json / pubspec.yaml / Cargo.toml / pyproject.toml …)에 있고, 여기
#    타깃은 그것을 부르는 얇은 별칭이다. 별칭을 두면 **드리프트**가 생긴다 —
#    뒷단에서 스크립트 이름을 바꿨는데 여기를 안 고치면 `make lint`가 조용히
#    깨진다. 그래서 그 드리프트 자체를 검사하는 센서를 뒀다 → `make harness-check`
#
# 새 타깃을 추가하면 (1) AGENTS.md §2에 적고 (2) 센서면 SENSORS/SENSORS_CI에 넣고
# (3) docs/HARNESS.md 인벤토리에 등록하고 (4) `make harness-check`를 통과시킨다.

# ─────────────────────────────────────────────────────────────────────
# 뒷단 명령 — 스택이 정해지면 여기만 채운다.
#
# 비워두면 해당 타깃은 **조용히 성공하지 않고 실패한다.** 선언만 하고 실체가
# 없는 명령이야말로 이 하네스가 막으려는 실패이기 때문이다.
#
# 이 프로젝트에 해당 개념이 아예 없다면(예: 정적 분석기가 타입체크를 겸해서
# typecheck가 따로 없다면) 변수를 비워두는 게 아니라 **타깃과 SENSORS 목록에서
# 함께 지우고, AGENTS.md §2에서도 그 줄을 지운다.**
#
# 아직 못 채운 슬롯은 지우지 말고 docs/HARNESS.md에 MISSING으로 적는다 —
# 센서가 안 울린 게 품질 때문인지 탐지가 없어서인지 구분돼야 한다.
# ─────────────────────────────────────────────────────────────────────

INSTALL_CMD ?= npm ci
DEV_CMD ?= npm run dev
LINT_CMD ?= npm run lint
FORMAT_CMD ?= npm run format
FORMAT_CHECK_CMD ?= npm run format:check
TYPECHECK_CMD ?= npm run typecheck
TEST_CMD ?= npm test
BUILD_CMD ?= npm run build

# 디자인 토큰: Tailwind가 아니라 CSS 변수로 낸다.
export DESIGN_TOKENS_FORMAT := css-vars
# arch·test-full·deps·deadcode·coverage는 지웠다. 파일 10여 개의 단일 앱이라
# 레이어 규칙이 없고, test가 이미 전체 테스트(가짜 생성 모드, 10초)다.

# ── 실행 시점 (quality left) ─────────────────────────────────────────
# 싸고 빠른 것은 앞으로, 비싸고 느린 것은 뒤로. 이 프로젝트에 없는 슬롯은 지운다.
SENSORS    := format-check lint typecheck design-md design-literals test prose  # pre-commit / make check
SENSORS_CI := build                                    # CI / make check-ci

.DEFAULT_GOAL := help
.PHONY: help install dev lint format format-check typecheck test \
        build app design-md design-tokens design-literals check check-ci harness-check \
        doctor prose harness-upstream

# 비어 있는 뒷단을 명확한 실패로 바꾼다.
define run
if [ -z "$(2)" ]; then \
  printf '\033[31m[sensor:$(1)] ERROR — 뒷단 명령이 비어 있다\033[0m\n\n'; \
  printf '  FIX: Makefile 상단의 $(1)을 채운다.\n'; \
  printf '       이 프로젝트에 해당 개념이 없다면 변수를 비워두지 말고\n'; \
  printf '       타깃·SENSORS·AGENTS.md §2에서 함께 지운다.\n'; \
  printf '       아직 못 채운 것이면 docs/HARNESS.md에 MISSING으로 적는다.\n\n'; \
  exit 2; \
fi; \
printf '\033[2m$$ %s\033[0m\n' '$(2)'; \
$(2)
endef

## help: 사용 가능한 명령 목록
help:
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed -e 's/## /  make /'
	@echo ""
	@echo "  명령 이름은 스택과 무관하게 고정이다. 뒷단은 Makefile 상단에 있다."
	@echo "  센서 규약: agent-harness-kit/docs/SENSOR_CONTRACT.md"
	@echo ""

## install: 의존성 설치 + git 훅 연결
install:
	@$(call run,INSTALL_CMD,$(INSTALL_CMD))
	@git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
	  && git config core.hooksPath .githooks \
	  && chmod +x .githooks/* hooks/*.sh tool/*.sh 2>/dev/null \
	  && printf '\033[32m✓\033[0m core.hooksPath = .githooks\n' \
	  || printf '\033[33m⚠\033[0m git 저장소가 아니라 훅을 걸지 않았다\n'

## dev: 개발 서버 (장기 실행 — 센서가 아니다)
dev:
	@$(call run,DEV_CMD,$(DEV_CMD))

## lint: 린트 (경고도 실패로 취급해야 센서다)
lint:
	@$(call run,LINT_CMD,$(LINT_CMD))

## format: 포맷 적용 (워킹트리를 바꾼다 — 센서가 아니다)
format:
	@$(call run,FORMAT_CMD,$(FORMAT_CMD))

## format-check: 포맷 검사만 (워킹트리를 바꾸지 않는다)
format-check:
	@$(call run,FORMAT_CHECK_CMD,$(FORMAT_CHECK_CMD))

## typecheck: 타입체크 (린트나 빌드가 겸하면 이 타깃을 지운다)
typecheck:
	@$(call run,TYPECHECK_CMD,$(TYPECHECK_CMD))

## test: 빠른 단위 테스트 (반드시 종료된다 — watch 모드가 아니다)
test:
	@$(call run,TEST_CMD,$(TEST_CMD))

## build: 프로덕션 빌드
build:
	@$(call run,BUILD_CMD,$(BUILD_CMD))

## app: 맥 데스크톱 앱(.dmg·.zip)을 dist/에 만든다 (센서 아님, 몇 분 걸림)
app:
	@bash tool/build-app.sh

## design-md: DESIGN.md 린트(오류·대비) + 생성 토큰이 원본과 같은지
design-md:
	@sh tool/check-design-md.sh

## design-tokens: DESIGN.md에서 src/styles/tokens.css 생성 (생성물은 직접 고치지 않는다)
design-tokens:
	@sh tool/gen-design-tokens.sh && echo "src/styles/tokens.css 생성"

## design-literals: 화면 코드의 색·크기 리터럴 래칫 (토큰 원본 제외)
design-literals:
	@DESIGN_SRC="src" DESIGN_TOKEN_FILES="src/styles/tokens.css src/styles/tokens-extra.css" sh tool/check-design-literals.sh

## prose: 문서 글쓰기 버릇 검사 (래칫 — baseline보다 늘면 실패)
prose:
	@sh tool/check-prose.sh

## harness-check: 하네스 자체 검사 (명령 드리프트 + 가이드 위생)
harness-check:
	@sh tool/check-commands.sh
	@sh tool/check-guide.sh

## check: pre-commit 센서 전체 — 커밋 직전에 이것 하나를 돌린다
check: harness-check
	@set -e; for t in $(SENSORS); do \
	  $(MAKE) --no-print-directory "$$t"; \
	done
	@printf '\033[32m✓ 센서 전체 통과 (pre-commit)\033[0m\n'
	@rm -f .harness/state/dirty
	@printf '  센서 게이트 해제 — 이번 변경은 검증됐다.\n'

## check-ci: CI 센서 전체 (check + 느리고 비싼 것)
check-ci: check
	@set -e; for t in $(SENSORS_CI); do \
	  $(MAKE) --no-print-directory "$$t"; \
	done
	@printf '\033[32m✓ 센서 전체 통과 (CI)\033[0m\n'

## doctor: 환경·하네스 상태 점검 (읽기만 하고 항상 exit 0 — 센서가 아니다)
doctor:
	@sh tool/harness-doctor.sh

## harness-upstream: 이 프로젝트의 하네스 개선을 상류 키트로 올릴지 검토 (센서 아님)
harness-upstream:
	@sh tool/harness-upstream.sh
