# 디자인 토큰과 시각 기초값

UI가 있는 웹·앱 프로젝트에서 색·타이포·간격·레이아웃·모양·깊이·모션의 기초값을 정하고 코드에 연결하는 기준. UI가 없으면 적용 대상에서 제외.
대비·확대·대상 크기·reduced motion 수치는 [접근성 기준](ACCESSIBILITY.md), 문단 너비·줄바꿈은 [제품 문구 기준](UI_COPY.md), 화면 구성은 [UX 기준](UX_DESIGN.md)·[시각 설계](VISUAL_DESIGN.md), 모션·전환 측정은 [UI 검증](UI_VALIDATION.md), 로고 색값은 [로고 기준](LOGO_DESIGN.md), UI 아이콘·이미지 제작은 [시각 에셋](VISUAL_ASSETS.md)이 맡으며 여기서는 수치를 반복하지 않음.
사용자가 준 브랜드 가이드·기존 디자인 시스템이 우선이고, 공공 서비스는 KRDS 표준형·확장형 규칙을 먼저 확인. 값의 원본은 루트 `DESIGN.md`이며 고르는 절차는 [디자인 시스템](DESIGN_SYSTEM.md). 키트 기본값을 바꾸면 프로젝트 `decisions.md`에 날짜와 이유를 남길 것.

## 토큰 구조

| 계층 | 담는 것 | 예 | 규칙 |
| --- | --- | --- | --- |
| primitive (기본값) | 팔레트 단계, 글꼴, 크기·간격 수치 | `color.blue.60`, `space.16` | 화면·컴포넌트 코드에서 직접 참조 금지 (KRDS) |
| semantic (의미) | 역할·상태 | `color.text.secondary`, `color.action.primary.hover` | primitive를 별칭으로 참조. 라이트·다크·고대비 전환은 이 계층 값만 교체 |
| component | 특정 컴포넌트 속성 | `button.primary.bg` | semantic을 참조하고 코드에서 정의 (KRDS는 디자인 툴에 semantic까지만 둠) |

- 같은 3계층을 KRDS(primitive·semantic·component)와 Material(reference `--md-ref-*`·system `--md-sys-*`·component)이 사용. 이름은 큰 범주에서 세부로 `범주.역할.변형.상태` 순서, CSS 변수는 `--color-text-secondary`처럼 점을 하이픈으로 바꿈.
- 원본은 토큰 파일 하나(또는 한 디렉터리)로 두고 CSS 변수와 플랫폼 값(iOS asset catalog, Android 리소스)은 생성. 생성물을 손으로 고치지 말 것.
- 형식 기본값은 DTCG Format Module 2025.10: 확장자 `.tokens.json`, 토큰마다 `$value`와 `$type`(그룹에서 상속 가능), 선택 `$description`, 별칭 `"{group.token}"`. 2025-10-28 첫 안정판이지만 W3C Community Group 보고서라 W3C 표준이나 표준 트랙 문서에 해당하지 않음. 스택의 변환 도구가 이 형식을 읽지 못하면 CSS 변수 파일 하나를 원본으로 두고 그 결정을 기록. DTCG 이름에는 `.`, `{`, `}`, `$` 시작을 쓸 수 없어 계층은 그룹 중첩으로 표현. 타입은 color, dimension(`px`·`rem`), fontFamily, fontWeight, duration(`ms`·`s`), cubicBezier, number와 복합 타입 strokeStyle, border, transition, shadow, gradient, typography.
- 색 값은 Color Module 객체(`colorSpace`, `components`, 선택 `alpha`·`hex`)로 쓰고 `oklch` 원본이면 `hex` 폴백을 함께 기록. 라이트·다크 분기는 Resolver Module(`.resolver.json`)의 modifier나 테마별 semantic 파일로 표현.
- 컴포넌트·화면 스타일에는 색 리터럴(`#hex`, `rgb()`, `oklch()`)과 임의 px 간격을 쓰지 말고 토큰 변수만 참조. 서드파티 위젯 덮어쓰기 같은 예외는 주석에 이유를 적을 것.

```json
{
  "color": {
    "$type": "color",
    "blue": { "60": { "$value": { "colorSpace": "srgb", "components": [0, 0.4, 0.8], "hex": "#0066cc" } } },
    "action": { "primary": { "$value": "{color.blue.60}", "$description": "주 행동 배경. 흰 글자 대비 5.57:1" } }
  }
}
```

## 색

| 역할 | 토큰 예 | 대비 기준 (ACCESSIBILITY 색과 대비) | 측정 상대 |
| --- | --- | --- | --- |
| 배경·표면 | `color.bg`, `color.surface`, `color.surface.raised` | 위에 놓이는 텍스트·컨트롤 토큰과 쌍으로 측정 | 겹친 표면 경계가 식별에 필요하면 인접 면과 3:1 |
| 텍스트 | `color.text` | 4.5:1 | bg와 모든 surface 단계 |
| 보조 텍스트 | `color.text.secondary` | 4.5:1, 보조라는 이유로 낮추지 않음 | 같음 |
| 비활성 | `color.text.disabled`, `color.surface.disabled` | 요구 없음 (1.4.3 예외) | 투명도 대신 별도 단계 사용 (KRDS) |
| 컨트롤 테두리 | `color.border.control` | 3:1 | 인접 배경 |
| 장식 구분선 | `color.border.subtle` | 요구 없음, 정보 구분에 필요하면 3:1 | 인접 배경 |
| 주 행동 | `color.action.primary`(+`.hover`·`.pressed`), `color.on.action.primary` | 면 위 글자 4.5:1, 버튼 경계가 식별에 필요하면 면과 배경 3:1 | 상태마다 |
| 링크 | `color.link` | 4.5:1, 본문 링크는 색 외 단서 | 주변 배경 |
| 위험·성공·경고·안내 | `color.danger` 등과 `.text`·`.surface`·`.border` | 텍스트 4.5:1, 아이콘 3:1 | 해당 surface |
| 포커스 | `color.focus` | 3:1 | 인접 배경과 포커스된 요소 |

- semantic 색 토큰은 모두 라이트·다크 값을 쌍으로 정의. 다크 제공을 미루면 `color-scheme: light`를 명시하고 `decisions.md`에 기록. 배경 역할마다 그 위에 올 전경 토큰을 함께 정의(Material의 `on-<role>` 짝). 쌍을 만들 때 계산된 색으로 대비를 측정해 `$description`과 프로젝트 대비 표에 남길 것.
- 브랜드 색이 여러 개면 주도·보조·강조·중립 역할로 나누고 본문 글자색은 따로 둠. 네 역할을 한 색의 명도 변형으로만 채우지 말고, 역할색마다 위에 올 글자색(흑·백 중 대비가 높은 쪽)을 짝으로. 기준색에서 다른 색을 계산으로 파생하면 기준색을 조금씩 바꿔 가며 결과가 급변하지 않는지 확인(사례 D1).
- 주 행동 버튼은 호버 전 기본 상태에서 면과 주변 배경 3:1을 권장(1.4.11은 조건부라 키트 권장값). 반투명이면 조상 배경을 합성해 계산하고, 이미지·그라디언트 배경은 "미측정"으로 남김. 1px 테두리만으로 3:1을 맞추는 우회 금지.
- 대비를 자동 교정할 때는 글자/면과 면/바깥 두 쌍을 함께 다시 잼. 면을 바꿔 바깥 대비를 잃으면 면 대신 글자색을 옮기고, 교정 뒤 새 실패가 생기면 그 교정을 버림(사례 D2). 대비 수치는 표시할 때 내림, 판정은 반올림 전 값.
- 선택과 포커스는 다른 채널로: 선택은 테두리 색 변경, 포커스는 `:focus-visible` 링. 선택 상태에 링·inset 그림자를 겹쳐 굵게 만들지 말 것.
- 상태색은 아이콘·문구와 함께 쓰고(ACCESSIBILITY 1.4.1), 한 컴포넌트의 hover·pressed는 같은 색조 안에서 단계만 이동(KRDS 상태 값). 색 면적 비율은 [시각 설계](VISUAL_DESIGN.md) 색 사용 절.

로고 색에서 팔레트를 만드는 순서:
1. LOGO_DESIGN 브랜드 문서의 기본 HEX를 primitive `color.brand.*`의 기준값으로 등록.
2. 같은 색조로 명도 단계를 생성. 단계 이름은 KRDS 방식(5, 10, 20 … 90, 95의 11단계, 회색은 0·100을 더한 13단계)을 기본으로 사용. 생성은 OKLCH에서 L을 나누고 hue를 유지하며 C를 sRGB 영역 안으로 줄이는 방식이 기본값(CSS Color 4는 OkLCh 명도가 HSL보다 시각적 밝기를 잘 반영한다고 설명). KRDS 절차는 HSL로 시작해 대비를 맞춰 L을 조정하는 방식.
3. WCAG 대비는 상대 휘도로 계산하므로 L 간격만으로 대비가 보장되지 않음. 단계마다 흰색·검정 대비를 측정해 조정하고, 가능하면 KRDS 매직넘버(단계 번호 차 40→3:1, 50→4.5:1, 70→7:1, 90→15:1)가 성립하도록 맞출 것.
4. 로고 색이 텍스트·버튼 기준에 못 미치면 로고·그래픽에는 원래 색을 두고(1.4.3 로고 예외) 텍스트와 주 행동에는 기준을 넘는 인접 단계를 사용.
5. 상태색 조합(특히 빨강·초록)은 명도 차를 두고 색각 이상 시뮬레이터로 확인(KRDS). Display P3 색을 쓰면 sRGB 값도 함께 정의(Apple HIG Color).

다크 테마:
- 제공 여부: 장문 읽기는 밝은 바탕이 수행에 유리하고(Piepenbrock 2013·2014) 다크는 선호의 문제라서, 공개 소개 사이트는 라이트만 제공하고 `color-scheme: light`를 명시하는 것도 정당함. 오래 켜 두는 관리자·업무 도구는 시스템 설정을 따르는 다크 제공을 검토. 어느 쪽이든 `decisions.md`에 기록하고, 제공하는 테마는 모두 ACCESSIBILITY 기준으로 측정.
- 웹은 `:root { color-scheme: light dark; }`로 폼 컨트롤·스크롤바도 테마를 따르게 하고(CSS Color Adjustment 1) `prefers-color-scheme`에서 semantic 값만 교체. 수동 전환을 두면 "시스템 설정" 선택지를 포함(KRDS 화면 표시 모드 예). iOS 앱은 앱 전용 화면 모드 설정을 피하라는 Apple HIG 권고를 따를 것.
- 라이트 값의 단순 반전 금지. 배경은 어둡게, 전경은 밝게 하되 반전하지 않는 색도 있음(Apple HIG Dark Mode). 주 색은 다크에서 밝은 단계로 옮김(Material 기본 스킴 primary: 라이트 tone 40, 다크 tone 80).
- 위로 올라온 면일수록 밝게 표현(Apple base·elevated, KRDS 선명한 화면 모드, Material surface container 단계). 넓은 흰 면은 눈부심을 주므로 한 단계 어두운 값 사용(KRDS). 기본 배경을 순수 검정으로 둘지는 키트가 정하지 않음. Material 기본 다크 스킴의 surface는 neutral tone 6이고, 순수 검정 회피를 명시한 원문 지침은 미확인.
- 공공 서비스의 선명한 화면 모드는 일반 다크와 별도 모드로 두고 KRDS 표(본문 15:1, 헤딩·레이블 7:1, 아이콘 4.5:1)를 적용.

## 타이포그래피

| 항목 | 키트 기본값 | 출처와 차이 |
| --- | --- | --- |
| 루트 크기 | `html`에 px 지정 금지, 100% 유지 | 사용자 브라우저 글꼴 설정 존중(WCAG 1.4.4 기법 C12·C14의 상대 단위). KRDS 토큰 CSS는 루트 62.5%(1rem=10px) 전제라 들여오면 기록하고 환산 |
| 본문 크기 | 웹 1rem 이상 (기본 설정 16px) | KRDS 최소 16px, Pretendard GOV는 17px. iOS 기본 17pt·최소 11pt (Apple HIG). Material body-large 1rem/1.5rem |
| 단위 | 글꼴 rem, 줄간격은 단위 없는 수, 자간 em | KRDS: 줄간격은 px 대신 상대 단위 |
| 본문 줄간격 | 1.5 이상 | KRDS 150% 이상, WCAG 1.4.8(AAA) 1.5. klreq는 표현 방식만 정리(예시 160%) |
| 본문 자간 | 0. 양의 자간은 짧은 고정 라틴 대문자 라벨에만(0.06em 이하), 한글·혼합·동적 문구는 0 | KRDS body 0px. 라틴 대문자 예외는 실무 |
| 역할별 크기 하한 | 본문·입력값 1rem, 버튼·탭·라벨 0.875~1rem, 보조문 0.875rem 이상, 0.75rem은 짧은 비핵심 메타데이터만. 결제·삭제 경고·오류·약관은 보조문이 아니라 본문 크기 | 한 제품 실측(사례 D18): 핵심 경고가 10~12px로 작아짐. 하한 값은 실무 기준 |
| 굵기 | 기본 400·700 두 단계, 필요하면 중간 굵기 하나(500 또는 600)를 더해 최대 3단계. KRDS는 4종까지 허용 | KRDS. 작은 글씨의 Ultralight·Thin·Light 회피 (Apple HIG) |
| 스케일 | 실제 쓰는 단계만 토큰화. 인접 단계 비율 1.2~1.5배, 히어로·랜딩 큰 제목은 별도 display 단계로 이 비율 밖 허용 | KRDS display·heading·body. Material은 display·headline·title·body·label × L·M·S 15단계 |
| 서체 수 | 최소화 | Apple HIG "Minimize the number of typefaces" |

- 앱은 플랫폼 텍스트 스타일(iOS Dynamic Type, Material type scale)을 우선 쓰고, 커스텀 글꼴도 사용자 글꼴 크기 변경에 반응하도록 구현(Apple HIG Typography).
- 한국어 줄바꿈은 음절 단위(`word-break: normal`)와 어절 단위(`keep-all`) 두 방식이 있고 문단별로 고를 수 있음(CSS Text 3, klreq 7.1.1). 키트 기본값(전역 `keep-all` + `overflow-wrap: anywhere`, 제목 balance)과 원인 조사·수동 개행 금지는 UI_COPY가 기준. 320px에서 확인.
- `ch`·`ic`로 한글 글자 수를 추정하지 말 것. `ic`도 "水" 글리프 기준값(CSS Values 4).

웹폰트:
- 키트 기본 한글 글꼴은 Pretendard(SIL OFL 1.1, 예약 글꼴 이름 'Pretendard'), 공공 서비스는 KRDS 표준형의 Pretendard GOV. 대안은 Noto Sans KR(SIL OFL 1.1, 가변 wght 100~900). 다른 글꼴은 라이선스 URL을 확인해 기록하고 로고 사용 가능 여부는 LOGO_DESIGN을 따를 것. 폴백 스택에 시스템 한글 글꼴(Apple SD Gothic Neo, Malgun Gothic 등)과 `sans-serif`를 포함.
- 직접 만든 서브셋·최적화본은 OFL의 Modified Version이라 예약 글꼴 이름을 쓸 수 없음(OFL-FAQ 2.5). 형식 변환한 WOFF2도 원본 데이터·메타데이터를 보존하지 않으면 수정본(OFL-FAQ 2.2). Pretendard는 공식 dynamic subset(가변판 포함)을 쓰고, 직접 서브셋을 만들면 family 이름을 바꿀 것.
- `font-display`는 본문에 `fallback`(block 100ms 이하·swap 약 3s, CSS Fonts 4가 본문용으로 제시), 로고처럼 짧고 그 글꼴이 중요한 텍스트에만 `swap`. Pretendard 공식 CSS는 `swap`을 선언하므로 그대로 쓰면 그 사실을 기록하거나 자체 `@font-face`로 지정. 버전을 고정하고(Pretendard 최신 릴리스 v1.3.9) 자체 호스팅·CDN 여부와 실제 쓰는 굵기를 기록.

## 간격·레이아웃

- 기본 단위 4px, 레이아웃·컴포넌트 간격은 8의 배수 우선(Android 8dp·4dp 그리드, KRDS 8-point grid).
- 키트 기본 간격 primitive는 0·4·8·12·16·20·24·32·40·48·64·80·96 (px 기준값, rem으로 출력). KRDS number 토큰의 4배수 부분집합. KRDS CSS의 `2.4rem`은 62.5% 루트 기준 24px이므로 100% 루트에서는 `1.5rem`으로 환산.
- semantic 간격은 요소 사이 `space.gap.*`, 내부 `space.padding.*`, 영역 사이 `space.layout.*`로 구분(KRDS 갭·패딩·레이아웃). 그룹 안 간격이 그룹 사이 간격보다 작게(UX 기준). 테두리 두께는 px 토큰.

| 대상 | 키트 기본값 | 출처 |
| --- | --- | --- |
| 웹 | 360 / 768 / 1024 / 1280px (small·medium·large·xlarge). 칼럼 4/8/12/12, 가터 16/16/24/24, 최소 화면 여백 16/24/24/24px | KRDS 표준형 레이아웃 |
| 웹 360px 미만 | 별도 단계 없이 small 배치, 320px에서 손실 없음 | ACCESSIBILITY 1.4.10 (KRDS 표준형은 xsmall 최적화 제외) |
| Android | window size class 너비: compact <600, medium 600–839, expanded 840–1199, large 1200–1599, extra-large ≥1600dp | Android Developers |
| iOS·iPadOS | 시스템 size class(compact·regular), 기기 종류·방향으로 판단 금지 | Apple HIG Layout |

- 웹 기본값을 KRDS로 둔 이유는 국내 공공 기준과 px 기반 미디어 쿼리에 맞기 때문. Android 앱과 같은 체계가 필요하면 Material 경계로 바꾸고 기록.
- 페이지 콘텐츠 최대 폭은 레이아웃 토큰 하나로 관리(KRDS 표준형 1200px 참고). 이 토큰을 결과·폼·상태 안내 문단의 폭 제한으로 재사용하지 말 것(UI_COPY).
- 페이지 골격은 미디어 쿼리, 여러 위치에 재사용하는 카드·목록 행의 내부 배치는 `container-type: inline-size`와 `@container`로 처리. 컨트롤 높이와 터치 대상 토큰은 웹 최소 24px(WCAG 2.5.8), 모바일 주요 버튼·탭은 44px 이상(ACCESSIBILITY 포인터·터치 대상 표).

## 모양·깊이

| 항목 | Material system 토큰 | KRDS 표준형 | 키트 기본값 |
| --- | --- | --- | --- |
| radius | none 0, extra-small 4, small 8, medium 12, large 16, extra-large 28, full 9999px (최신판 20·32·48 추가) | 2·4·6·10·12px, 최대 12. 컨테이너 높이 × 1/8을 짝수로 올림 | 크기별 4~5단계 + full. 값은 브랜드 성격으로 고르고 공공은 KRDS |
| elevation | level0~5 (0·1·3·6·8·12dp) | -1 묶음 컨테이너, 0 배경, +1 카드·탭·메뉴, +2 열린 셀렉트·메뉴, +3 툴팁·패널·모달·바텀시트, +4 긴급 알림 | KRDS 6단계 매핑, z-index도 같은 단계 이름 사용 |

- 비슷한 크기로 함께 놓이는 컴포넌트는 같은 radius 토큰을 사용(KRDS). 둥근·각진 형태의 인상은 LOGO_DESIGN 형태 원칙과 맞출 것. 깊이는 그림자·표면 색·경계선·딤으로 표현(KRDS)하고 다크에서는 표면 밝기를 우선. 컴포넌트 경계가 식별에 필요하면 그림자 대신 3:1 경계(ACCESSIBILITY 1.4.11).
- 최소 터치 높이 같은 전역 안전 CSS는 `:where()`로 감싸 특이도 0으로 둘 것. 그러지 않으면 작성자 스타일을 덮음(사례 D3).
- 아이콘 토큰: 의미 있는 아이콘 색 `color.icon.*`은 인접 배경 3:1(1.4.11, KRDS 기본 모드 매직넘버 40·선명한 화면 모드 70). 크기 단계는 쓰는 아이콘 세트가 제공하는 크기 안에서 고름(기준과 예외는 [시각 에셋](VISUAL_ASSETS.md)). KRDS 예: 16·20·24·32·40px. 선 두께·제작 규칙은 [시각 에셋](VISUAL_ASSETS.md).

## 모션

키트는 모션 고정 기본값을 두지 않음. 다른 프로젝트의 애니메이션 시간을 공통값으로 복사하지 말라는 UI_VALIDATION 규칙을 따름.
- 토큰은 역할 이름으로 정의: `motion.duration.feedback`(누름·선택 상태), `motion.duration.small`(툴팁·메뉴 등장과 퇴장), `motion.duration.large`(시트·화면 전환), `motion.easing.standard`·`.enter`·`.exit`. 값은 프로젝트가 정하고 이유와 프레임 측정 결과를 기록.
- 범위 참고(Material system motion 토큰): duration short1–4 50–200ms, medium1–4 250–400ms, long1–4 450–600ms, extra-long1–4 700–1000ms. easing standard `cubic-bezier(0.2, 0, 0, 1)`, standard-decelerate `(0, 0, 0, 1)`, standard-accelerate `(0.3, 0, 1, 1)`, emphasized-decelerate `(0.05, 0.7, 0.1, 1)`, emphasized-accelerate `(0.3, 0, 0.8, 0.15)`. 최신 토큰에는 spring(stiffness·damping)도 있음. 역할별 단계 매핑은 원문 미확인이라 키트가 정하지 않음.
- 원칙(Apple HIG Motion): 목적 있는 모션만 추가, 피드백 모션은 짧고 정확하게, 자주 반복하는 조작에는 커스텀 모션을 더하지 않음, 애니메이션이 끝날 때까지 입력을 막지 않음, 모션을 유일한 정보 전달 수단으로 쓰지 않음.
- 모든 모션 토큰에 reduce 값(0 또는 짧은 페이드)을 함께 정의하고 `prefers-reduced-motion: reduce`에서 교체. 끌 대상과 검증은 ACCESSIBILITY 모션 절과 UI_VALIDATION 회귀 행렬.

## 브랜드 자료가 없을 때

로고·브랜드 색이 없는 새 프로젝트의 기초값 절차. 사용자 자료가 생기면 그 자료로 바꿈. 출발점은 getdesign.md에서 고른 시스템이고([디자인 시스템](DESIGN_SYSTEM.md)), 아래는 그 시스템을 적응할 때의 기준.
- 주색: 서비스의 상품·장소·사용 장면에서 색의 이유를 찾아 후보 2~3개를 실제 화면(버튼, 큰 면, 링크)에 올려 비교하고 사용자가 고름. 업종 자동 연결(AI=파랑 등)은 이유가 아님([시각 설계](VISUAL_DESIGN.md) 색 사용 절).
- 중립 회색: 순수 회색 대신 주색의 색조를 아주 약하게 섞은 단계(OKLCH에서 hue는 주색, chroma는 낮게)를 기본으로 해 화면 전체의 온도를 맞춤(실무, Refactoring UI). 대비는 계산값으로 다시 측정.
- 모서리: 기준값 하나에서 크기별 2~3단계와 full. 브리프의 성격 축이 정돈·전문 쪽이면 작게(2~6px), 친근 쪽이면 크게(8~16px). 컴포넌트마다 다른 값을 즉흥적으로 쓰지 않음.
- 한글 제목 자간: 기본 0. KRDS는 display·큰 heading에 +1px, Pretendard는 별도 조정이 필요 없다고 밝히고, 일부 국내 디자인 시스템(원티드 Montage)은 32px 안팎 제목에 약 -0.025em을 씀. 근거 있는 단일 정답이 없으므로 어느 쪽인지 정해 기록.
- 글꼴: Pretendard 한 가족으로 시작. 서비스 성격에 맞는 제목용 글꼴을 쓰려면 한글 전 음절 지원·라이선스를 확인하고 렌더로 비교.

## 스택 연결: Tailwind v4·shadcn/ui

Next.js 등에서 Tailwind CSS v4와 shadcn/ui를 쓸 때의 연결 방식(2026-10 공식 문서·소스 기준, 버전이 바뀌면 다시 확인).

파일 배치:
- 디자인 시스템을 `DESIGN.md`로 두면 `tokens.css`는 `tool/gen-design-tokens.sh` 생성물이고 직접 고치지 않음([디자인 시스템](DESIGN_SYSTEM.md) 코드 연결 절). 아래 배치 규칙은 같음.
- 토큰 원본 `src/styles/tokens.css`(경로는 스택 관례대로): primitive와 semantic 값, `:root`·`.dark` 값, shadcn 변수 정의, `@theme`의 기본 네임스페이스 초기화가 여기에만 있음. 리터럴 값이 존재할 수 있는 유일한 파일이며 `check-design-literals.sh`의 `DESIGN_TOKEN_FILES`로 제외.
- `globals.css`: `@import "tailwindcss"`, 애니메이션 import, `@import "./styles/tokens.css"`, `@custom-variant dark`, `@theme inline { --color-primary: var(--primary); ... }` 같은 `var()` 참조만.
- 런타임에 값이 바뀌는 semantic 변수는 `@theme inline`으로 노출해야 다크 전환이 동작함(Tailwind 문서: 다른 변수를 참조하는 테마 변수에는 inline).
- 기본 팔레트 제거: `@theme { --color-*: initial; }`. `--color-white`·`--color-black`도 사라지므로 shadcn 컴포넌트가 쓰는 `text-white`·`bg-black/50`을 위해 다시 선언하거나 컴포넌트를 고침. 브레이크포인트를 토큰 표대로 쓰려면 `--breakpoint-*: initial` 뒤 재정의(Tailwind 기본은 sm 640·md 768·lg 1024·xl 1280·2xl 1536px). 기본 단계를 그대로 쓰면 그 사실을 기록하고 검수 폭 320·360px를 따로 확인.
- Tailwind의 `--spacing`은 배수 단위라 `p-13` 같은 정수 배수가 모두 유효함. 간격 스케일을 강제하려면 린트로 막음(아래).

semantic 토큰 → shadcn 변수:

| semantic | shadcn 변수 | 주의 |
| --- | --- | --- |
| `color.bg` / `color.text` | `--background` / `--foreground` | |
| `color.text.secondary` | `--muted-foreground` | `--muted` 배경 위에서도 4.5:1인지 측정(기본값은 약 4.35:1로 미달) |
| `color.surface` | `--card`, `--popover` (+`-foreground`) | |
| `color.surface.subtle` | `--muted` | |
| `color.surface.hover` | `--accent` (+`-foreground`) | 브랜드 강조색이 아니라 hover·선택 배경 |
| `color.action.primary` / `color.on.action.primary` | `--primary` / `--primary-foreground` | |
| `color.border.subtle` / `color.border.control` | `--border` / `--input` | 입력 테두리가 경계의 유일한 단서면 3:1(기본값 약 1.26:1) |
| `color.focus` | `--ring` | 컴포넌트의 `ring-ring/50` 투명도 때문에 기본 약 1.5:1. 불투명·3:1 이상으로 클래스 수정 |
| `color.danger` / `color.on.danger` | `--destructive` + 새 `--destructive-foreground` | 버튼·배지가 `text-white`를 하드코딩하므로 교체 |
| `radius` | `--radius` | sm~4xl이 `--radius`의 배수로 계산됨 |

shadcn을 쓰면 바꿀 것(그대로 두면 다른 shadcn 사이트와 같아 보임): 무채색 base(chroma 0)와 검정 주색에 주색 색조 넣기, `--radius` 기본 0.625rem, 기본 글꼴(Inter·Geist), `Skeleton`의 `animate-pulse`(UX_DESIGN 기준대로 정적으로), Accordion의 height 키프레임(레이아웃 속성 애니메이션이므로 제거하거나 reduced motion에서 끄기), 버튼 hover의 `/90` 투명도(토큰 hover 색으로), 대시보드 블록의 카드 그라디언트. pulse·아코디언에는 reduced motion 처리가 내장돼 있지 않음.

린트:
- eslint-plugin-better-tailwindcss: `no-restricted-classes`로 임의값 금지(`\[([^\[\]]*?)\](?!:)` 패턴), `--color-*: initial` 뒤 `no-unknown-classes`를 켜면 기본 팔레트 클래스가 알 수 없는 클래스로 잡힘. eslint-plugin-tailwindcss 4.x의 `no-arbitrary-value`도 v4를 지원(설정에 v4 CSS 경로 지정).
- shadcn 컴포넌트 자체가 `ring-[3px]` 같은 임의값을 쓰므로 `components/ui/**`는 임의값 규칙에서 빼고 앱 코드에만 적용하거나, 고친 뒤 허용 목록으로 관리.
- CSS 파일은 stylelint `color-no-hex`, `color-named: "never"`, `function-disallowed-list`로 막고 토큰 파일만 `ignoreFiles`.

## 프로젝트 기록

- `decisions.md`: 토큰 원본 경로와 형식(DTCG 여부)·생성 도구, 기준 색과 팔레트 생성 방법, 다크·고대비 제공 범위, 본문 크기·스케일, 글꼴·라이선스 URL·버전·배포 방식·`font-display`, 브레이크포인트 체계, radius·elevation 단계, 모션 값과 이유, 키트 기본값에서 바꾼 항목. 토큰 파일에는 값과 `$description`(용도, 대비 측정값)을 두고, 대비 표는 ACCESSIBILITY 형식대로 테마별로 유지.

## 검증

| 확인 | 방법 | 통과 기준 |
| --- | --- | --- |
| 대비 표 | semantic 전경/배경 쌍과 hover·focus·disabled·error 상태를 라이트·다크에서 계산된 색으로 측정 | ACCESSIBILITY 기준 충족, 토큰 기록과 측정값 일치 |
| 하드코딩 | 아래 검색, 후보마다 문맥 확인 | 토큰 원본·생성물 밖 리터럴 0, 예외는 주석에 이유 |
| 글꼴 설정·확대 | 브라우저 기본 글꼴 크기를 20px로 변경, 200% 확대, 320px, 1.4.12 주입 | 본문이 설정에 비례해 커지고 손실·잘림 없음 |
| 다크 테마 | `page.emulateMedia({ colorScheme: 'dark' })`로 페이지·상태별 캡처 | 반전 누락, 넓은 흰 면, 표면 단계 구분 실패 없음 |
| 웹폰트 | 글꼴 요청 지연·차단 | 폴백 글꼴로 텍스트 즉시 표시, 레이아웃 손실 없음 |
| 브레이크포인트 | 각 경계 ±1px와 320px | 2차원 스크롤·겹침 없음 |
| 모션 | reduced motion 두 설정에서 프레임 기록 | UI_VALIDATION 기준 |

```sh
rg -n -e '#[0-9a-fA-F]{3,8}\b' -e '\b(rgba?|hsla?|oklch|oklab)\(' -e '\b[0-9.]+px\b' src --glob '!**/tokens/**'
```

경로는 스택에 맞게 바꾸고, 미디어 쿼리·1px 테두리처럼 정당한 px 결과는 제외 사유와 함께 기록. 검색 0건을 시각 품질 통과로 보고하지 말 것. 이 검색은 0·1px도 잡는 넓은 점검용이고, 커밋마다 돌리는 래칫은 `tool/check-design-literals.sh`([디자인 리뷰](DESIGN_REVIEW.md) 기계 검사 절).

## 근거와 한계

확인일 2026-10-01.

- DTCG [Format Module 2025.10](https://www.designtokens.org/TR/2025.10/format/), [Color Module](https://www.designtokens.org/TR/2025.10/color/), [Resolver Module](https://www.designtokens.org/TR/2025.10/resolver/) (2025-10-28 안정판): "It is not a W3C Standard nor is it on the W3C Standards Track". 후속 초안은 [designtokens.org/TR/drafts](https://www.designtokens.org/TR/drafts/).
- KRDS 스타일 가이드: [디자인 토큰](https://www.krds.go.kr/html/site/style/style_07.html), [색상](https://www.krds.go.kr/html/site/style/style_02.html), [타이포그래피](https://www.krds.go.kr/html/site/style/style_03.html), [형태](https://www.krds.go.kr/html/site/style/style_04.html), [레이아웃](https://www.krds.go.kr/html/site/style/style_05.html), [엘리베이션](https://www.krds.go.kr/html/site/style/style_08.html), [선명한 화면 모드](https://www.krds.go.kr/html/site/style/style_09.html), [아이콘](https://www.krds.go.kr/html/site/style/style_06.html). 토큰 CSS는 [KRDS-uiux/krds-uiux](https://github.com/KRDS-uiux/krds-uiux) `resources/css/token/krds_tokens.css`.
- Material: [material-web Theming](https://github.com/material-components/material-web/blob/main/docs/theming/README.md)(토큰 계층), [Color](https://github.com/material-components/material-web/blob/main/docs/theming/color.md), 토큰 값은 같은 저장소 `tokens/versions/latest/sass/`(motion·shape·typescale·color dark)와 `tokens/versions/v0_192/_md-sys-elevation.scss`. [Android window size classes](https://developer.android.com/develop/ui/compose/layouts/adaptive/use-window-size-classes), [Grids and units](https://developer.android.com/design/ui/mobile/guides/layout-and-content/grids-and-units) (둘 다 2026-09-22 갱신).
- Apple HIG: [Typography](https://developer.apple.com/design/human-interface-guidelines/typography) (변경 2025-12-16), [Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode) (2024-08-06), [Color](https://developer.apple.com/design/human-interface-guidelines/color), [Layout](https://developer.apple.com/design/human-interface-guidelines/layout), [Motion](https://developer.apple.com/design/human-interface-guidelines/motion).
- W3C: [CSS Color 4](https://www.w3.org/TR/css-color-4/) (CRD 2026-09-30, §9.2 비규범), [CSS Color Adjustment 1](https://www.w3.org/TR/css-color-adjust-1/) (CRS 2025-12-16), [CSS Fonts 4](https://www.w3.org/TR/css-fonts-4/) (WD 2026-09-13), [CSS Text 3](https://www.w3.org/TR/css-text-3/) (CRD 2026-08-14), [CSS Values 4](https://www.w3.org/TR/css-values-4/) (WD 2024-03-12), [CSS Containment 3](https://www.w3.org/TR/css-contain-3/) (WD 2022-08-18), [CSS Conditional 5](https://www.w3.org/TR/css-conditional-5/) (WD 2025-10-30), [klreq](https://www.w3.org/TR/klreq/) (Group Note Draft 2026-03-21), [Understanding 1.4.4](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html), [C14](https://www.w3.org/WAI/WCAG22/Techniques/css/C14). Media Queries 5와 WCAG 2.2 서지는 ACCESSIBILITY.
- 글꼴: [Pretendard](https://github.com/orioncactus/pretendard) LICENSE·README (v1.3.9, 2023-11-05), [google/fonts ofl/notosanskr](https://github.com/google/fonts/tree/main/ofl/notosanskr) OFL.txt·METADATA.pb, [OFL-FAQ](https://openfontlicense.org/ofl-faq/) 2.2·2.5. 지원 현황은 caniuse 데이터(LCH/Lab 94.27%, Container Queries 94.79%).

- Tailwind CSS v4: [Theme variables](https://tailwindcss.com/docs/theme), [Responsive design](https://tailwindcss.com/docs/responsive-design), [Dark mode](https://tailwindcss.com/docs/dark-mode). shadcn/ui: [Theming](https://ui.shadcn.com/docs/theming), [Tailwind v4](https://ui.shadcn.com/docs/tailwind-v4), [components.json](https://ui.shadcn.com/docs/components-json), 컴포넌트 소스(github.com/shadcn-ui/ui, apps/v4/registry). 기본값 대비 수치는 기본 oklch 값을 sRGB로 바꿔 계산한 추정이므로 프로젝트 값으로 다시 측정. eslint-plugin-better-tailwindcss 4.9.0, eslint-plugin-tailwindcss 4.4.0(npm). KRDS [타이포그래피](https://www.krds.go.kr/html/site/style/style_03.html) 자간, Pretendard README, wanteddev/montage-web typography(2026-10-07 확인).

오용 주의와 미확인 사항:
- m3.material.io는 본문이 렌더되지 않아 읽지 못함(미확인). Material의 순수 검정 회피 지침, 모션 역할별 duration 매핑, 8dp 그리드 원문이 여기에 해당하며, 본문 수치는 material-web 토큰 파일 값과 Android Developers 문서에서만 가져옴.
- Apple HIG Layout에서 8pt 그리드 문장을 찾지 못함(미확인). 4·8 단위 근거는 Android와 KRDS.
- KRDS 안에서도 기본 모드 본문 대비가 다름: 색상 페이지는 매직넘버 50(4.5:1), 선명한 화면 모드 페이지 표는 7:1. 키트 최소 기준은 ACCESSIBILITY의 4.5:1이며 7:1은 공공 서비스의 선택 기준.
- 매직넘버는 단계별 휘도를 맞춘 팔레트에서만 성립. 새 팔레트에서 측정 없이 성립한다고 가정하지 말 것.
- 16px는 KRDS가 적은 시스템 기본값이며 CSS Fonts 4는 medium의 px 값을 정하지 않음. 사용자가 기본 크기를 바꾸면 1rem도 따라 바뀌는 것이 의도된 동작.
- OKLCH의 지각 균일성 설명은 CSS Color 4 비규범 절. 대비 통과 여부는 WCAG 공식으로만 판정.
- Pretendard GOV 패키지에는 별도 LICENSE 파일이 없어 저장소 LICENSE 적용 여부는 미확인. KRDS 형태 페이지의 "심리학적 연구"는 출처가 표기되지 않아 근거로 쓰지 않음.
