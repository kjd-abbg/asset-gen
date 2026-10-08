# 하네스 인벤토리

이 저장소에 어떤 guide와 sensor가 걸려 있는지, **무엇을 막으려고** 걸었는지의 목록.

> **왜 "막으려는 실패" 칸이 필수인가**
>
> Anthropic: *"Every component in a harness encodes an assumption about what the
> model can't do on its own, and those assumptions are worth stress testing."*
>
> 하네스의 모든 구성요소는 "모델이 이걸 혼자 못한다"는 가정을 인코딩하고 있고,
> 그 가정은 **모델이 좋아지면 만료된다.** 왜 걸었는지가 적혀 있지 않으면
> 언제 떼도 되는지 판단할 수 없고, 결국 아무도 손대지 못하는 규칙 더미가 된다.
>
> `tool/check-guide.sh`가 이 칸이 빈 행을 실패로 잡는다.

---

## Guides (피드포워드 — 행동 전)

| 이름 | 종류 | 실행 | 시점 | 막으려는 실패 | 추가일 | 작동 도구 |
| --- | --- | --- | --- | --- | --- | --- |
| `AGENTS.md` | guide | computational | 세션 시작 | 매 세션 환경을 추측하는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `docs/HARNESS.md` (이 파일) | guide | — | 월 1회 리뷰 | 왜 걸었는지 모른 채 규칙이 쌓이는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `hooks/session-start.sh` | guide | computational | 세션 시작 | 이전 세션 진행 상황을 모른 채 시작하는 것 | 2026-10-07 | Claude Code 전용 |
| `docs/CODE-HEALTH.md` | guide | — | 월 1회 리뷰 | 약점과 부채를 아무도 추적하지 않는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `tool/harness-upstream.sh` | guide | computational | 월 1회 리뷰 | 여기서 얻은 개선이 다음 프로젝트에 안 가는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `spec/DESIGN-BRIEF.md`·`DESIGN.md` | guide | — | 화면 작업 전 | 화면마다 색·크기·간격을 새로 지어내 화면끼리 달라지는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |

## Sensors (피드백 — 행동 후)

슬롯 정의와 출력 규약: `agent-harness-kit/docs/SENSOR_CONTRACT.md`

| 이름 | 종류 | 실행 | 시점 | 막으려는 실패 | 추가일 | 작동 도구 |
| --- | --- | --- | --- | --- | --- | --- |
| `harness-check` | sensor | computational | pre-commit | 가이드가 존재하지 않는 명령을 선언하는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `lint` | sensor | computational | pre-commit | React 훅 규칙 위반·미사용 코드·Next 금지 패턴이 남는 것 (경고 0 허용) | 2026-10-07 | 공통: 에이전트·사람·CI |
| `format-check` | sensor | computational | pre-commit | 포맷 차이가 리뷰 diff를 오염시키는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `typecheck` | sensor | computational | pre-commit | API 응답·기록(AssetRecord) 형태가 화면과 서버에서 어긋나는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `test` | sensor | computational | pre-commit | 탐색→세트→기록 흐름, 실패 카드, 외부 Origin·경로 조작 거부가 깨지는 것 (가짜 생성 모드) | 2026-10-07 | 공통: 에이전트·사람·CI |
| `build` | sensor | computational | CI | 개발 서버에서만 통과하고 `npm run app`(next build)에서 깨지는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `design-md` | sensor | computational | pre-commit | DESIGN.md 구조 오류·대비 미달, 생성 토큰이 원본과 어긋나는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `design-literals` | sensor | computational | pre-commit | 화면 코드가 토큰 대신 색·크기 값을 직접 써서 화면마다 값이 달라지는 것 (기준선 0건) | 2026-10-07 | 공통: 에이전트·사람·CI |
| `prose` | sensor | computational | pre-commit | 문서가 읽기 어려운 방향으로 드리프트하는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |
| `.githooks/commit-msg` | sensor | computational | pre-commit | 커밋 메시지 컨벤션이 지켜지지 않는 것 | 2026-10-07 | 공통: 에이전트·사람·CI |

## Permissions & Gates (환경 — 구조적 차단)

| 이름 | 종류 | 실행 | 시점 | 막으려는 실패 | 추가일 | 작동 도구 |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/settings.json` | gate | computational | 툴 호출마다 | 되돌리기 어려운 행동이 승인 없이 실행되는 것 | 2026-10-07 | Claude Code 전용 |
| `hooks/guard-secrets.sh` | gate | computational | 쓰기 직전 | 비밀값 리터럴이 저장소에 들어가는 것 (비가역) | 2026-10-07 | Claude Code 전용 |
| `hooks/sensor-gate.sh` | gate | computational | 턴 종료 | 센서를 안 돌리고 "완료"라고 말하는 것 | 2026-10-07 | Claude Code 전용 |
| `.githooks/pre-commit` | gate | computational | 커밋 직전 | 센서 실패·미실행인 변경이 커밋되는 것 | 2026-10-07 | 공통: Git 훅 연결 필요 |
| `hooks/check-on-stop.py` | gate | computational | 턴 종료 | 쓰기 이벤트 누락으로 센서 실행이 생략되는 것 | 2026-10-07 | Codex·Gemini CLI: 설정·신뢰 필요 |
| `hooks/mark-dirty.sh` | gate | computational | 쓰기 직후 | Claude Stop이 변경을 모르고 넘어가는 것 | 2026-10-07 | Claude Code 전용 |

---

## 게이트의 보장 범위

Git 훅은 `core.hooksPath=.githooks`와 실행 권한이 있어야 작동한다.
매 커밋 작업 트리의 `make check`를 실행한다. 부분 스테이징·미추적 파일 때문에
커밋 스냅샷과 다를 수 있다. CI에서 `make check-ci`를 필수 검사로 연결한다.
`--no-verify`·설정 변경으로 우회할 수 있으므로 보안 경계로 취급하지 않는다.
턴 게이트의 `HARNESS_GATE=off`·재시도 상한은 Git 게이트를 해제하지 않는다.
Claude의 쓰기 직전 비밀값 검사는 다른 도구에 배치되지 않는다.
Codex는 `.codex/hooks.json`과 `/hooks` 신뢰가 필요하다. Gemini 설정은 선택 병합한다.
파일이 있다는 사실만으로 런타임 연결·센서 통과가 확인되는 것은 아니다.

## MISSING — 채우지 못한 슬롯

**조용히 건너뛰지 않는다.** 센서가 한 번도 울리지 않은 것이 품질이 좋아서인지
탐지가 없어서인지 구분되어야 한다. 여기 적은 항목은 `AGENTS.md` §A에도 올린다.

| 슬롯 | 왜 아직 없는가 | 대신 무엇을 하는가 | 언제 채울 것인가 |
| --- | --- | --- | --- |
| CI (`make check-ci` 강제) | 원격 저장소 없음 | 커밋 직전 `make check`(pre-commit) | 원격 저장소를 만들 때 |

---

## 만료 후보 — 떼도 되는지 재검토할 것

모델이 좋아지거나 도구가 바뀌면 불필요해지는 항목. 리뷰 때 여기를 먼저 본다.

| 항목 | 걸었을 때의 가정 | 아직 유효한가 | 마지막 확인 |
| --- | --- | --- | --- |
| `src/styles/tokens-extra.css` 타이포 사본 | `@google/design.md` 0.4 css-vars 출력에 typography가 없음 | 예 | 2026-10-07 |
| `src/server/codex.ts`의 thread_id 폴더 회수 | 모델이 최종 답에 이미지 경로를 빠뜨림 (2026-10-07 18장 중 6장) | 예 | 2026-10-07 |

---

## 월 1회 리뷰 체크리스트

`AGENTS.md` §C가 여기를 가리킨다.

- [ ] `make harness-check` 통과 (§2 명령 ↔ Makefile, 가이드 위생)
- [ ] `make doctor` — 환경 제약 표(§2)가 아직 사실인가
- [ ] 위 인벤토리의 모든 항목이 **실재**하는가
- [ ] "막으려는 실패" 칸이 전부 채워져 있는가
- [ ] **만료 후보** 표의 가정이 아직 유효한가 → 아니면 뗀다
- [ ] `MISSING` 중 이제 채울 수 있는 게 있는가
- [ ] `AGENTS.md` §4 산문과 `.claude/settings.json`이 일치하는가
- [ ] `AGENTS.md` §9 브랜치 이름이 실제와 같은가
- [ ] `AGENTS.md` §B 규칙 중 **센서로 대체된 것**이 있는가 → 있으면 §B에서 지운다
- [ ] 서로 모순되거나 주관적 판단이 필요한 규칙이 있는가
- [ ] 새로 만든 센서에 **위반을 주입해 실패를 확인**했는가
- [ ] [`CODE-HEALTH.md`](./CODE-HEALTH.md) 체크리스트도 같은 날 함께 봤는가
- [ ] `make harness-upstream` — 이번 달에 얻은 개선 중 **키트로 올릴 것**이 있는가

> **규칙이 늘어나는 속도가 줄고 있으면 하네스가 작동하는 것이다.** 초기에는 주에
> 다섯 줄씩 늘다가 성숙하면 주에 한 줄이 된다. 계속 다섯 줄씩 늘고 있다면 규칙이
> 아니라 센서가 부족한 것이다.

UI 프로젝트 추가 가이드: `docs/UI_VALIDATION.md`는 headless·전환·캐시 검증 기준이며 자동 UI 센서는 아님.
키트 관리 파일이므로 프로젝트별 측정값·예외는 별도 상태 파일에 기록.
`docs/ACCESSIBILITY.md`·`docs/UX_DESIGN.md`·`docs/LOGO_DESIGN.md`·`docs/DESIGN_TOKENS.md`·`docs/VISUAL_ASSETS.md`·`docs/PRODUCT_PLANNING.md`·`docs/SECURITY.md`·`docs/PRIVACY_LEGAL.md`·`docs/OPERATIONS.md`·`docs/SEO_GEO.md`·`docs/AI_FEATURES.md`·`docs/EMAIL_DELIVERY.md`·`docs/VISUAL_DESIGN.md`·`docs/DESIGN_REVIEW.md`·`docs/DESIGN_LIBRARY.md`·`docs/UI_QUICKSTART.md`·`docs/DESIGN_SYSTEM.md`도 키트 관리 가이드이며 `docs/INDEX.md`가 작업별로 묶는다. 접근성 자동 검사를 연결하지 않았으면 §A에 적는다.
`tool/check-design-md.sh`(디자인 시스템 원본 `DESIGN.md` lint·생성물 일치)도 배치만 된다. 연결했으면 Sensors 표에 `design-md` 행(막으려는 실패: 디자인 시스템 원본의 대비 미달·구조 오류, 생성 토큰을 손으로 고치거나 재생성을 잊어 원본과 어긋나는 것)을 추가한다.
`tool/check-design-literals.sh`는 배치만 되고 기본 `SENSORS`에 없다. UI가 있어 연결했으면 Sensors 표에 `design-literals` 행(막으려는 실패: 토큰 밖 색·px 리터럴이 화면마다 늘어나는 것)을 추가하고, 연결하지 않았으면 MISSING에 적는다. 렌더 리뷰(`docs/DESIGN_REVIEW.md`)를 하지 않으면 §A에 적는다.

`make doctor`의 Git 훅 연결은 설정 문자열 대신 실제 디렉터리로 비교. 상대경로·절대경로·심볼릭 링크가 같은 `.githooks`를 가리키면 정상, 없는 폴더·다른 폴더·미설정은 미연결.
