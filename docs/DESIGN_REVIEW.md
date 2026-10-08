# 디자인 절차·리뷰·기계 검사

UI가 있는 프로젝트에서 에이전트가 화면을 설계하고 검수하는 절차. UI가 없으면 적용 대상에서 제외.
무엇이 좋은 화면인지는 [시각 설계](VISUAL_DESIGN.md)·[UX 기준](UX_DESIGN.md)·[디자인 토큰](DESIGN_TOKENS.md)·[접근성](ACCESSIBILITY.md)이 정하고, 이 문서는 그 기준을 언제·어떻게 적용하고 무엇을 기계에 맡기는지 정함.
각 근거의 원문·확인 상태는 [디자인 참고자료](DESIGN_LIBRARY.md). 프로젝트가 바꾼 값과 예외는 `decisions.md`에 날짜와 이유를 남길 것.

## 왜 절차가 필요한가

언어 모델은 화면을 만들 때 학습 데이터의 중앙값으로 수렴함(Anthropic, "distributional convergence"). 결과는 흰 배경 보라 그라디언트, 기본 글꼴, 아이콘·제목·설명 카드 3열 반복 같은 화면. 금지 목록만 두면 다음 유행 클리셰로 옮겨 갈 뿐이므로(Anthropic `frontend-design` 스킬이 직전 권장 글꼴을 새 클리셰로 지목한 사례), 키트는 금지 목록보다 "선택마다 이유를 기록하고 렌더링된 화면을 기준표로 검수"하는 절차를 기본으로 둠.

## 절차

| 단계 | 할 일 | 산출물 | 완료 조건 |
| --- | --- | --- | --- |
| 1. 브리프 | 방문자·업종 관례·레퍼런스·시각 No-gos 정리 | `spec/DESIGN-BRIEF.md` (`--with-spec` 배치, 없으면 같은 슬롯을 `docs/`에) | `spec-lint` 통과, 결정자 확인 |
| 2. 디자인 시스템 | getdesign.md에서 고르거나 섞은 시스템을 적응하고 강조색을 사용자가 고름([디자인 시스템](DESIGN_SYSTEM.md)) | 루트 `DESIGN.md`, 생성 토큰, 선택 이유 ADR | `make design-md` 통과, DESIGN_TOKENS 검증표의 대비 표 |
| 3. 구조 | 화면별 주 행동 하나, 정보 위계, 상태 5종 | `spec/SCREENS.md` 또는 화면별 메모 | UX_DESIGN 상태 설계 충족 |
| 4. 구현 | 실제 콘텐츠(가장 긴·짧은 값)로 구현 | 코드 | `make check` 통과 |
| 5. 렌더 리뷰 | 브레이크포인트·테마별 스크린샷을 독립 리뷰어가 아래 리뷰표로 검수 | 리뷰표, 스크린샷 경로 | 위반마다 조치 또는 `decisions.md` 사유 |
| 6. 사람 확인 | 첫인상·과업 수행을 사람이 확인([UI_QUICKSTART](UI_QUICKSTART.md) 사람이 해야 하는 일) | `HANDOFF.md` 기록 | 미실행이면 "미실행"으로 남김 |

- 1단계 없이 화면을 그리지 말 것. 사용자가 "일단 아무거나"라고 하면 브리프 슬롯을 "가정:"으로 채워 확인받은 뒤 진행.
- 레퍼런스는 업종 관례(같은 업종 3곳 이상)와 업종 밖 레퍼런스를 구분. 관례를 따르면서 복잡도를 낮게 유지할 때 첫인상이 가장 좋고(Tuch 2012), 수상작이라고 대상 사용자에게 좋게 보이는 것은 아님(Reinecke 2013).
- 글꼴·주 색을 고를 때 "기본값이라서"는 이유가 아님. 기본값(Pretendard, Inter, Tailwind 기본 팔레트 등)을 유지해도 되지만 유지 이유를 한 줄 남길 것.

## 렌더 리뷰

검수 대상은 코드가 아니라 렌더링된 화면. 핵심 화면마다 320·360·768·1024·1280px, 라이트·다크(제공 시), 빈·오류·로딩 상태를 headless 브라우저로 캡처해 리뷰표를 채움. 캡처 방법과 사용자 브라우저를 건드리지 않는 규칙은 [UI 검증](UI_VALIDATION.md).

리뷰 형식은 목표 기반 크리틱(NN/g Design Critiques 2016, 원문. Connor & Irizarry 2015의 4문항 형식은 2차로만 확인): 이 화면의 목표 → 목표에 관련된 요소 → 그 요소가 목표에 효과적인가 → 왜. "깔끔함", "세련됨" 같은 취향 표현만으로 판정하지 말 것. 지적은 화면·상태·폭·영역(좌표나 선택자)과 함께 남김. 비전 모델로 스크린샷을 검수할 때도 같은 리뷰표를 체크리스트로 주고 항목별 판정과 영역 좌표를 요구할 것. 범용 모델의 단독 미적 판정은 사람과 일치도가 낮음(UIClip 2024, UICrit 2024).

### 리뷰표

항목마다 통과·위반·해당 없음. 위반은 심각도(차단·주요·경미)와 조치를 기록.

| 영역 | 확인할 것 | 기준 문서 |
| --- | --- | --- |
| 목적 | 첫 화면 상단에서 무엇을 하는 곳인지 한 문장으로 알 수 있음 | VISUAL_DESIGN 홈·랜딩 |
| 주 행동 | 화면당 가장 두드러지는 행동이 하나이고 2·3순위 버튼과 구분됨. 호버 전 기본 상태에서 버튼 면이 배경과 구분됨 | VISUAL_DESIGN 위계, DESIGN_TOKENS 색 |
| 위계 | 크기 단계·굵기·색 단계가 정한 개수 안에서만 쓰임 | VISUAL_DESIGN 위계, DESIGN_TOKENS |
| 그룹·간격 | 그룹 안 간격 < 그룹 사이 간격, 모든 간격이 토큰 | VISUAL_DESIGN 레이아웃 |
| 정렬 | 같은 열의 요소가 같은 정렬선, 의도 없는 정렬선이 늘어나지 않음 | VISUAL_DESIGN 레이아웃 |
| 복잡도 | 첫 화면 블록·이미지·강조 수가 브리프의 밀도 결정과 맞음 | VISUAL_DESIGN 첫인상 |
| 관례 | 로고·메뉴·검색·연락처가 업종 관례 위치 | DESIGN-BRIEF 3번 |
| 읽기 | 본문 크기·줄간격·줄 길이, 한국어 줄바꿈, 경고·오류·약관이 보조문 크기로 작아지지 않음 | VISUAL_DESIGN 읽기, DESIGN_TOKENS 역할별 크기, UI_COPY |
| 색 | 지배색·강조색 역할이 분명, 상태를 색만으로 구분하지 않음, 대비 표 일치 | DESIGN_TOKENS 색, ACCESSIBILITY |
| 이미지 | 실제 내용·사람을 보여 주는 이미지, 장식 스톡 사진 없음 | VISUAL_ASSETS |
| 내비게이션 | 현재 위치 표시, 데스크톱에서 주 메뉴 노출, 모호한 링크 라벨 없음 | VISUAL_DESIGN 내비게이션 |
| 반응형 | 각 폭에서 겹침·잘림·가로 스크롤 없음, 터치 대상 크기 | ACCESSIBILITY |
| 상태 | 빈·로딩·오류·성공·권한 없음이 실제 렌더됨 | UX_DESIGN 상태 설계 |
| 모션 | 목적 있는 모션만, reduced motion에서 꺼짐 | DESIGN_TOKENS 모션 |
| 범용 티 | 아래 "범용 AI 화면의 징후" 표 해당 없음, 해당하면 브리프 근거 | 이 문서 |
| 산출물 | 공개 페이지·PDF에 안내 문구·자리표시·내부 메모가 렌더되지 않음, 최종 로고·이미지가 들어간 상태에서 검수 | UI_COPY, LOGO_DESIGN 사용처 배치 |
| 정직성 | 다크 패턴 없음 | UX_DESIGN 정직한 설계 |

### 범용 AI 화면의 징후

출처 대부분이 실무 의견(Anthropic 가이드, `frontend-design` 스킬, Impeccable, Refactoring UI)이라 금지가 아니라 "근거 없이 나타나면 위반"으로 판정. 브리프에 이유가 있으면 통과.

| 징후 | 대신 할 것 |
| --- | --- |
| 흰 배경 보라·인디고 그라디언트, 보라→파랑 그라디언트 | 브랜드·업종 맥락에서 색 도출. Tailwind 기본 indigo·violet은 근거 없으면 쓰지 않음 |
| 이유 없이 고른 기본 글꼴 하나로 모든 텍스트 | 선택 이유 기록. 제목과 본문의 대비를 크기·굵기로 분명히 |
| 고르게 흩어진 여러 색, 순수 검정·회색 | 지배색 1·강조색 1 중심, 회색에 브랜드 색조를 약하게 섞음 |
| 아이콘+제목+설명 카드 3열 반복 | 콘텐츠 중요도에 따라 크기·배치를 다르게. 같은 카드 반복은 실제로 같은 종류일 때만 |
| 카드 안의 카드, 모든 것을 카드로 감쌈 | 간격·배경 차이로 묶고 카드는 독립 단위일 때만 |
| 자간 넓은 대문자 eyebrow 라벨, 제목 속 한 단어만 색·이탤릭 | 정보가 있을 때만 라벨. 제목 장식 장치 쓰지 않음 |
| 의미 없는 01·02·03 번호, 장식 구분선 | 실제 순서·구분일 때만 |
| 요소마다 흩어진 fade·slide, bounce·elastic easing | 사용자 행동에 대한 응답 모션만. 페이지 로드 연출은 많아야 한 번 |
| 범용 스톡 인물 사진, 의미 없는 추상 일러스트 | 실제 사람·제품·장소. 없으면 이미지 없이 |
| lorem ipsum, 비슷한 길이의 가짜 데이터 | 실제 최장·최단 콘텐츠로 검증 |
| 호버해야 보이는 주 버튼, 1px 테두리로만 배경과 구분되는 버튼 | 기본 상태에서 면이 구분되게 |

## 독립 리뷰

같은 에이전트가 만들고 검수하면 자기 결과를 후하게 평가함(Anthropic 하네스 설계 글의 자기 평가 편향). 렌더 리뷰는 구현에 참여하지 않은 리뷰어가 함.
1. 리뷰어는 새 서브에이전트(구현 대화 맥락 없음) 또는 사람. 입력은 스크린샷(폭·테마·상태별), `spec/DESIGN-BRIEF.md`, 이 문서의 리뷰표, 브리프의 레퍼런스 캡처뿐. 코드와 구현 설명은 주지 않음.
2. 리뷰어는 리뷰표 모든 항목에 통과·위반·해당 없음을 적고, 위반은 스크린샷 파일·영역(좌표)·심각도와 함께. 통과 판정에도 근거가 된 영역을 적음.
3. 구현자는 리뷰 결과를 "통과"로 바꿀 수 없음. 위반을 고친 뒤 같은 리뷰어 조건으로 다시 받음.
4. 기계 보조(판정이 아니라 리뷰 입력): 스크린샷을 5~20px 블러 처리해 가장 두드러지는 영역이 브리프의 1순위 요소와 같은지 보는 스퀸트 테스트(NN/g Visual Hierarchy), 계산 스타일 집계.

```js
// headless 브라우저의 page.evaluate 안에서: 화면에 실제로 쓰인 글자 크기·굵기·색 종류 수
const els = [...document.querySelectorAll('body *')].filter(e => e.offsetParent && e.innerText?.trim());
const pick = k => [...new Set(els.map(e => getComputedStyle(e)[k]))];
({ fontSize: pick('fontSize'), fontWeight: pick('fontWeight'), color: pick('color') });
```

종류 수가 토큰 단계보다 많으면 토큰 밖 값이 섞였다는 신호. 이 집계를 시각 품질 판정으로 쓰지 말 것.

## 시안 승인

디자인 시스템의 강조색 견본은 색 비교용이며 시안이 아님([디자인 시스템](DESIGN_SYSTEM.md) 강조색 비교 절). 방향을 고를 때는 서로 다른 방향 2~3개를 같은 화면(대표 화면 하나)으로 렌더해 나란히 보여 주고, 각 안의 차이(색 온도, 밀도, 글자 대비)를 한 줄씩 붙임. 사용자가 고른 안과 날짜, 지시한 수정을 `decisions.md`에 기록. 고르지 않은 안의 요소를 섞어 달라는 요청이 아니면 섞지 않음.

## 기계 검사

기계가 확인할 수 있는 것은 기계에 맡기고, 통과를 시각 품질 통과로 보고하지 말 것. 아래는 키트가 제공하는 것과 스택에서 고르는 것.

| 검사 | 무엇을 잡나 | 제공 | 연결 |
| --- | --- | --- | --- |
| `tool/check-design-md.sh` | 디자인 시스템 원본 `DESIGN.md`의 구조 오류·깨진 참조·컴포넌트 글자 대비 미달, 생성 토큰 CSS가 원본과 다른 것(손 수정, 재생성 누락) | 키트 (`@google/design.md` 필요) | Makefile `design-md` 타깃 + `SENSORS` (stack-template README) |
| `tool/check-design-literals.sh` | 토큰 밖 색(hex·색 함수·이름 색), 0·0.5·1px 외 px, 임의 rem·em·pt·%, JSX 숫자 스타일, Tailwind 기본 팔레트. 값별 래칫, 기준선 없으면 exit 2 | 키트 (스택 무관) | Makefile `design-literals` 타깃 + `SENSORS` (stack-template README) |
| stylelint `declaration-strict-value`, `color-no-hex` | CSS 속성별 토큰 강제 (color, z-index, spacing) | 스택 | CSS·SCSS를 직접 쓰는 프로젝트 |
| eslint-plugin-tailwindcss `no-arbitrary-value` | Tailwind 임의값 | 스택 (v4용 최신판) | Tailwind 프로젝트 |
| Tailwind v4 `@theme`에서 기본 팔레트 초기화 (`--color-*: initial`) | 기본 팔레트 클래스(`bg-blue-500`) 자체를 없앰 | 스택 설정 | 토큰만 남겨 빌드에서 차단 |
| axe-core (Playwright 연동) | 자동 판정 가능한 WCAG 위반 | 스택 | 실패 규칙 ID 목록을 게이트로. 0건을 접근성 통과로 보고 금지 (Deque: 자동 검출은 이슈 건수의 약 57%) |
| Lighthouse / Web Vitals | LCP ≤2.5s, INP ≤200ms, CLS ≤0.1 (p75) | 스택 | 실험실 값은 회귀 감지용, 판정은 현장 데이터 |
| Playwright `toHaveScreenshot` | 의도하지 않은 시각 변화 | 스택 | 고정 컨테이너 이미지에서만 기준선 생성, 날짜·아바타 등은 `mask` |
| Aalto Interface Metrics 등 미적 지표 | 시각 복잡도·여백·색 분포 변화 | 외부 (MIT) | 변경 전후 비교용 참고 신호. 임계값이 없으므로 게이트 금지 |

그 밖에 실제 제품이 스택에 맞춰 구현해 효과를 본 검사(키트는 제공하지 않음, 스택에서 구현 후보):

| 후보 | 잡는 것 |
| --- | --- |
| 모션 린트 (CSS) | 레이아웃 속성·`all` 전환, 토큰 밖 ms 리터럴, 허용 목록 밖 무한 반복. Tailwind면 `transition-all`·`animate-*` |
| 토큰 쌍 대비·미정의 변수 | 선언한 전경/배경 토큰 쌍의 WCAG 대비, 정의 없는 `var()` 참조(폴백이 있어도 오타를 잡음) |
| 작은 글자 CSS 스캔 | 역할별 하한 미만 font-size, 허용 밖 굵기, 양의 자간 |
| headless 계산 스타일 | 보이는 글자 하한, 줄간격 비율, reduced motion 에뮬레이션 뒤에도 도는 CSS·Web Animations |

- 사용자 콘텐츠·작품·축소 미리보기는 제품 UI 검사에서 명시적 선택자로 제외(작품의 작은 글자가 제품 UI 위반으로 잡힘).
- 래칫 센서의 기존 부채는 한 번에 고치지 않음. 새로 생기거나 늘어난 값만 막고, 줄면 기준선이 따라 내려감. 예외는 줄 끝 `design-literal-ok`와 이유. 위계·간격 리듬·정렬은 잡지 못함.
- 미적 지표(Miniukovich 2015: 웹 분산 설명 최대 49%)와 비전 모델 점수는 합격 기준이 아님.

## 센서 입력이 실제 결과물과 같은가

센서가 전부 통과했는데 실제 결과물이 깨진 사례가 반복됨(사례 D16). 공통 원인은 센서가 본 입력이 실제 파이프라인 순서나 저장된 결과와 달랐던 것.
- 대비 교정·검수가 최종 로고 주입 전에 실행돼 자리표시자만 검사(헤더 로고 대비 2.89:1, 글자 9.9px가 통과). 검수는 실제 순서대로 최종 자산을 넣은 뒤에.
- 글자 대비를 맞추려 버튼 면만 어둡게 해 면과 배경이 1.07:1로 묻혔는데, 1px 테두리 때문에 가시성 검사가 통과. 측정 대상이 실제로 보는 것(면)인지 확인.
- 합성 예제만 본 센서가 모두 통과한 상태에서 저장된 실제 생성물에 결함 10건. 실제 결과물을 읽는 감사 도구를 따로 두고, `make check`는 그 도구가 무력화되지 않았는지만 확인(실데이터는 로컬·권한 범위에서만).

## 보고 규칙

- 렌더 리뷰를 하지 않았으면 "디자인 검수 미실행". 코드 리뷰나 센서 통과로 대신하지 말 것.
- 사람이 보지 않은 첫인상·만족도 평가를 사용자 평가로 보고하지 말 것. 에이전트 리뷰는 "에이전트 리뷰"로 표기.
- 리뷰표의 위반을 고치지 않고 남기면 `HANDOFF.md`에 화면·항목·이유를 적음.

## 근거와 한계

확인일 2026-10-07. 원문·확인 상태와 상세 수치는 [디자인 참고자료](DESIGN_LIBRARY.md)의 해당 절.

- 수렴 문제와 대응: Anthropic, Prompting for frontend aesthetics (Claude Cookbook, 2025-10-21), Improving frontend design through Skills (Claude 블로그, 2025-11-12), `frontend-design` SKILL.md (anthropics/claude-code, 2026-10 열람). Paul Bakaus, Impeccable (Apache-2.0). Wathan & Schoger, Refactoring UI (2018).
- 리뷰 방법: Connor & Irizarry (2015), Discussing Design, O'Reilly (2차 출처로 확인). NN/g, Design Critiques (2016). Duan et al. (2024), UICrit, UIST '24, doi:10.1145/3654777.3676381 (초록). Wu et al. (2024), UIClip, UIST '24, doi:10.1145/3654777.3676408 (2차 출처).
- 기계 검사: stylelint-declaration-strict-value README, eslint-plugin-tailwindcss README, Deque Automated Accessibility Coverage Report, Lighthouse accessibility scoring, Playwright Visual comparisons, web.dev Web Vitals (2024-10-31), Oulasvirta et al. (2018), AIM, UIST '18 Adjunct, doi:10.1145/3266037.3266087, Miniukovich & De Angeli (2015), CHI '15, doi:10.1145/2702123.2702575.
- 한계: 범용 AI 징후 목록은 실무 의견이며 유행과 함께 낡음. 정기 리뷰 때 항목을 다시 확인할 것. 키트의 리터럴 센서는 색·px만 보며 위계·리듬·정렬은 판정하지 않음.
