# 디자인 시스템 정하기

UI가 있는 프로젝트에서 화면을 그리기 전에 디자인 시스템을 저장소 루트 `DESIGN.md` 하나로 확정하는 절차. UI가 없으면 적용 대상에서 제외.
디자인 시스템 없이 화면부터 만들면 에이전트가 화면마다 색·크기·간격을 새로 지어내 화면끼리 달라짐. 출발점은 [getdesign.md](https://getdesign.md)에 공개된 실제 서비스의 DESIGN.md 중 브리프에 가장 맞는 것이고, 하나를 고르거나 여럿을 섞음.
사용자가 브랜드 가이드나 기존 디자인 시스템을 주면 그 자료를 같은 형식의 `DESIGN.md`로 옮기는 것으로 출발점을 대신함. 토큰 계층·대비 쌍·스택 연결의 상세 기준은 [디자인 토큰](DESIGN_TOKENS.md), 화면 설계 기준은 [시각 설계](VISUAL_DESIGN.md).

## 절차

| 단계 | 할 일 | 산출물 | 완료 조건 |
| --- | --- | --- | --- |
| 1. 브리프 | `spec/DESIGN-BRIEF.md` 2절(성격)·5절(보유 자료)을 먼저 채움 | 브리프 | 결정자 확인 |
| 2. 후보 조사 | getdesign.md 무료 공개분을 전부 받아 읽고 브리프로 거름 | 후보 2~3개와 가져올 것·버릴 것 표 | 제외 이유가 브리프 칸에 연결됨 |
| 3. 고르기·섞기 | 뼈대 하나를 고르고 필요한 부분만 다른 시스템에서 가져옴 | `DESIGN.md` 초안 | 출처와 라이선스가 Overview에 있음 |
| 4. 적응 | 한국어·접근성·보유 자료에 맞게 값 수정 | `DESIGN.md` | `design.md lint` 오류·대비 경고 0 |
| 5. 강조색 비교 | 색 후보 2~3개를 같은 견본에 렌더해 사용자가 고름 | `tool/design-candidates.py` 결과 | 사용자 선택 기록 |
| 6. 확정 | 토큰 생성·센서 연결·결정 기록 | 토큰 CSS, ADR | `make design-md` 통과 |

이후 색·크기를 바꿀 때는 `DESIGN.md`만 고치고 `make design-tokens`로 다시 생성함. 화면 코드나 생성물에서 값을 새로 만들지 않음.

## 후보 조사

- 무료 공개분: getdesign.md 홈의 featured 목록. 2026-10-07 기준 81개이며 그중 74개는 GitHub [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)(MIT)의 `design-md/<이름>/DESIGN.md`로 받을 수 있음. 저장소를 받아 전부 읽고 목록을 남김.
- 카탈로그(2026-10-07 기준 551개)는 대부분 SaaS이며 사이트별 분석은 유료(Catalog Pass)나 요청으로 제공됨. 유료 분석은 사용자 승인 없이 구매하지 않고, 필요하면 후보 이름과 이유를 들어 사용자에게 물음.
- 거르는 기준은 브리프 칸에서 가져옴. 실제 사진이 없으면 사진이 첫 화면을 채우는 시스템을 뺌. 성격 축(정돈·전문 ↔ 친근, 현장 실용 ↔ 감도)과 화면 밀도, 주 행동의 종류(구매·문의·가입)를 비교함. 업종이 같은 시스템이 없는 경우가 많으므로 업종보다 성격과 보유 자료를 우선함.
- 후보마다 가져올 것과 버릴 것을 표로 남김. "유명해서", "예뻐서"는 이유가 아님.

## 고르기·섞기·적응

- 뼈대 하나를 정함(면 구성, 모서리, 강조색 개수, 선·그림자 방식). 다른 시스템에서는 폼·표처럼 범위가 분명한 부분만 가져옴. 같은 역할을 두 시스템이 다르게 정하면 뼈대 쪽을 따름.
- getdesign.md 파일을 이름만 바꿔 그대로 쓰지 않음. 출발 서비스와 똑같아 보이고, 그 서비스의 로고·브랜드 이름·고유 그래픽은 가져오지 않음.
- 적응할 것: 한글 글꼴과 본문 크기·줄간격([화면 작업 시작점](UI_QUICKSTART.md) 기본값), 대비(텍스트 4.5:1, 컨트롤·포커스 3:1), 사진이 없을 때의 대체(도면·수치·타이포), 다크 모드 제공 여부. 키트 기본값과 다르게 둔 것은 이유를 Overview나 `decisions.md`에 남김.
- `DESIGN.md` Overview 첫머리에 출발 시스템과 출처(getdesign.md 분석, 저장소 라이선스)를 적음.

## DESIGN.md 작성 규칙

- 형식은 Google DESIGN.md(YAML 머리말의 토큰 + 산문). getdesign.md 파일과 같은 절 구성(Overview, Colors, Typography, Layout, Elevation, Shapes, Components, Do's and Don'ts, Responsive 등)을 따르고, 사양 빈틈은 Known Gaps 절에 적음.
- 색 이름은 역할로 씀: `primary` `on-primary` `primary-hover` `primary-pressed` `primary-on-light` `primary-on-dark` `focus` `canvas` `ink` `body` `mute` `hairline` `hairline-control` `surface-soft` `surface-dark` `on-dark` `on-dark-mute` `link` `error` `error-surface`. 후보 비교 도구와 대비 계산이 이 이름을 씀. 출발 시스템의 이름이 다르면 바꿈.
- 밝은 강조색(흰 바탕 대비 3:1 미만, 예: 라임 `#7cc242`는 2.2:1)은 어두운 글자를 얹은 버튼 면에는 쓸 수 있음. 흰 바탕의 글자·밑줄·현재 위치 표시·포커스에는 같은 색조에서 명도를 낮춘 `primary-on-light`·`focus`를 계산으로 정해 따로 둠.
- 컴포넌트 토큰은 `backgroundColor` `textColor` `typography` `rounded` `padding` `height` 등 사양이 인식하는 이름을 씀. 0.4 사양에는 테두리 색이 없어 `borderColor`는 경고가 나며, 센서는 이 경고만 허용함.

## 강조색 비교

- `python3 tool/design-candidates.py 후보.json`이 `DESIGN.md`의 색만 바꾼 후보별 파일, 견본 화면(`preview.html`), 나란히 보기(`index.html`)를 `artifacts/design/system-candidates/`에 만들고 역할 쌍의 대비를 계산함. 기준 미달이 있으면 exit 1이며, 미달 후보는 고치거나 사용자에게 미달 사실과 함께 보여 줌.
- 후보 색은 서비스의 상품·사용 장면에서 이유를 찾음([시각 설계](VISUAL_DESIGN.md) 색 사용 절). 업종 자동 연결은 이유가 아님.
- 견본은 색 비교용이고 레이아웃 시안이 아님. 견본 화면 맨 위에 그 표시가 들어가지만 사용자에게 보여 줄 때 말로도 함께 알림. 견본을 실제 페이지처럼 꾸며 보여 주면 사용자가 그 레이아웃으로 가는지 묻게 되고(사례: 아이비 2026-10-07), 실제 화면은 별도로 방향 2~3개를 와이어프레임으로 비교함([디자인 리뷰](DESIGN_REVIEW.md) 시안 승인 절).

## 코드 연결

- 린터·생성기: `npm i -D -E @google/design.md@0.4.0`(0.x라 형식이 바뀔 수 있어 버전 고정). `lint`는 구조 오류·깨진 참조·컴포넌트 대비를 JSON으로 내고, `export --format css-tailwind|css-vars|dtcg`가 토큰을 냄.
- 생성: `tool/gen-design-tokens.sh`가 `src/styles/tokens.css`를 만듦. Tailwind v4면 앞에 `@theme { --color-*: initial; }`를 넣어 기본 팔레트를 끔(`--color-white`·`--color-black`도 사라짐). Tailwind가 아니면 `DESIGN_TOKENS_FORMAT=css-vars`.
- 생성물은 직접 고치지 않고, Prettier 같은 포매터 대상에서 뺌(`.prettierignore`). 포맷하면 원본 일치 검사가 깨짐.
- `globals.css`는 생성물 import와 `var()` 참조만 둠. 디자인 리터럴 센서는 경로에 `tokens`가 든 파일을 기본으로 제외함.
- 센서: `tool/check-design-md.sh`(Makefile `design-md`)가 lint 오류, 대비 경고, 허용 목록 밖 경고, 생성물 불일치를 실패로 냄. 연결 절차는 stack-template README.
- 결정 기록: 고른 시스템, 섞은 부분, 버린 후보와 이유, 강조색 후보와 사용자 선택을 ADR이나 `decisions.md`에 남김.

## 근거와 한계

확인일 2026-10-07.

- getdesign.md(https://getdesign.md): 홈 featured 81개, 카탈로그 551개, 유료 Catalog Pass를 headless 브라우저로 확인. 무료 파일은 [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)(MIT) `design-md/<이름>/DESIGN.md`에서 74개를 받음.
- DESIGN.md 형식과 도구: npm `@google/design.md` 0.4.0, 저장소 [google-labs-code/design.md](https://github.com/google-labs-code/design.md)(Apache-2.0). `lint`·`export`·`diff` 명령과 sub-token 목록은 0.4.0 실행 결과로 확인.
- 적용 사례: 아이비 공식 사이트(2026-10-07)에서 NVIDIA 분석을 뼈대로 IBM Carbon 분석의 폼 규칙을 섞어 확정했고, 사용자가 강조색 후보 3개 중 하나를 고름. 실패와 수정은 [EVIDENCE](EVIDENCE.md) §N.
- getdesign.md 분석이 각 서비스의 공식 디자인 시스템 문서인지는 확인하지 않음. 값을 그 서비스의 공식 가이드로 인용하지 말 것. 무료 공개분과 카탈로그 수는 바뀌므로 조사할 때 다시 셈.
