---
version: alpha
name: asset-gen
description: 사내 에셋 생성기의 디자인 시스템. 회색 단계만으로 짠 밝은 도구 화면 위에서 생성 이미지가 유일한 색이 되고, 주 행동 "생성"에만 강조색 하나를 쓴다.

colors:
  primary: "#2453d6"
  on-primary: "#ffffff"
  primary-hover: "#1d44b3"
  primary-pressed: "#173792"
  focus: "#2453d6"
  canvas: "#fafafa"
  surface: "#ffffff"
  surface-soft: "#f2f2f2"
  on-dark: "#fafafa"
  ink: "#171717"
  body: "#4d4d4d"
  mute: "#6b6b6b"
  hairline: "#e6e6e6"
  hairline-control: "#8f8f8f"
  link: "#2453d6"
  error: "#c50000"
  error-surface: "#fdeeee"
  success: "#0a7b38"
  success-surface: "#e7f6ec"
  warning: "#8a5300"
  warning-surface: "#fff4dc"
  info: "#2453d6"
  info-surface: "#e8eefc"

typography:
  display:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 28px
    fontWeight: 700
    lineHeight: 36px
  title:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 20px
    fontWeight: 700
    lineHeight: 28px
  heading:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 16px
    fontWeight: 600
    lineHeight: 24px
  body-md:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 16px
    fontWeight: 400
    lineHeight: 24px
  body-sm:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
  body-sm-strong:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 14px
    fontWeight: 600
    lineHeight: 20px
  caption:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 12px
    fontWeight: 500
    lineHeight: 16px
  button:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 14px
    fontWeight: 600
    lineHeight: 20px
  button-lg:
    fontFamily: Pretendard Variable, Pretendard, -apple-system, system-ui, sans-serif
    fontSize: 16px
    fontWeight: 600
    lineHeight: 24px

rounded:
  none: 0px
  xs: 4px
  sm: 6px
  md: 8px
  lg: 12px
  full: 9999px

spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 40px
  3xl: 48px
  4xl: 64px

components:
  page:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.body}"
    typography: "{typography.body-md}"
  text-link:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.link}"
    typography: "{typography.body-sm-strong}"
  focus-ring:
    backgroundColor: "{colors.focus}"
    rounded: "{rounded.sm}"
  app-header:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.heading}"
    height: 56px
    padding: "0px {spacing.lg}"
  tab:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.mute}"
    typography: "{typography.body-sm-strong}"
    height: 40px
    padding: "0px {spacing.sm}"
  tab-active:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm-strong}"
    height: 40px
    padding: "0px {spacing.sm}"
  panel:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
  text-input:
    backgroundColor: "{colors.surface}"
    borderColor: "{colors.hairline-control}"
    textColor: "{colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.sm}"
    height: 40px
    padding: "0px {spacing.sm}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-lg}"
    rounded: "{rounded.sm}"
    height: 44px
    padding: "0px {spacing.lg}"
  button-primary-hover:
    backgroundColor: "{colors.primary-hover}"
    textColor: "{colors.on-primary}"
  button-primary-pressed:
    backgroundColor: "{colors.primary-pressed}"
    textColor: "{colors.on-primary}"
  button-secondary:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.sm}"
    height: 36px
    padding: "0px {spacing.sm}"
  style-chip:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.full}"
    height: 36px
    padding: "0px {spacing.md}"
  style-chip-active:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.on-dark}"
    typography: "{typography.button}"
    rounded: "{rounded.full}"
    height: 36px
    padding: "0px {spacing.md}"
  asset-card:
    backgroundColor: "{colors.surface}"
    borderColor: "{colors.hairline}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.md}"
    padding: "{spacing.sm}"
  badge-queued:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.body}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xxs} {spacing.xs}"
  badge-running:
    backgroundColor: "{colors.info-surface}"
    textColor: "{colors.info}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xxs} {spacing.xs}"
  badge-done:
    backgroundColor: "{colors.success-surface}"
    textColor: "{colors.success}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xxs} {spacing.xs}"
  badge-failed:
    backgroundColor: "{colors.error-surface}"
    textColor: "{colors.error}"
    typography: "{typography.caption}"
    rounded: "{rounded.full}"
    padding: "{spacing.xxs} {spacing.xs}"
  status-banner-warning:
    backgroundColor: "{colors.warning-surface}"
    textColor: "{colors.warning}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xs} {spacing.sm}"
---

## Overview

출발점: getdesign.md의 Vercel 분석(VoltAgent/awesome-design-md, MIT, `design-md/vercel/DESIGN.md`)을 뼈대로 면 구성·회색 단계·반경·폼 높이·겹친 그림자를 가져왔다. 생성 결과 카드와 상태 배지는 Replicate 분석, 스타일 칩은 Pinterest 분석에서 가져왔다(같은 저장소). 세 서비스의 로고·브랜드 이름·메시 그라디언트·고유 그래픽은 쓰지 않는다. getdesign.md 분석은 각 서비스의 공식 가이드가 아니다.

화면은 회색 단계로만 짠다. 색은 사용자가 만든 이미지와 주 행동 "생성"의 강조색 하나뿐이다. 이미지가 밝은 단색 배경 위 일러스트라서 바탕은 흰색에 가까운 `canvas`, 카드는 `surface` 흰색으로 둔다.

키트 기본값과 다르게 둔 것: 강조색은 결정자가 견본 비교로 고른다(현재 값은 후보 중 하나). 다크 모드는 제공하지 않는다(결정자 확인 필요, 생성 이미지가 밝은 배경이라 어두운 바탕에서 타일처럼 보임).

## Colors

- `primary`: "생성"·"세트 생성" 버튼, 포커스 링, 링크. 한 화면에 채운 면은 주 버튼 하나.
- `ink`·`body`·`mute`: 제목·본문·보조 글. `mute`도 `canvas`·`surface` 위에서 4.5:1 이상.
- `hairline`: 카드·패널 경계. 컨트롤 경계는 3:1을 넘는 `hairline-control`.
- 상태색: 생성 중 `info`, 완료 `success`, 실패 `error`, 구독·로그인 경고 `warning`. 각자 옅은 면(`*-surface`)과 짝.

## Typography

Pretendard Variable 한 가족(OFL, npm `pretendard` 자체 호스팅). 자간 0, 한국어 줄바꿈 `keep-all`. 본문 16px/24px, 도구 컨트롤은 14px. 숫자(진행 수·초)는 `tabular-nums`.

## Layout

- 최대 폭 1280px, 좌우 여백 24px(768px 미만 16px).
- 입력 영역과 결과 그리드는 위아래로 둔다. 결과 그리드는 `minmax(200px, 1fr)` 자동 채움, 간격 16px.
- 간격은 4 단위 `spacing` 토큰만 쓴다. 그룹 안 간격 < 그룹 사이 간격.

## Elevation & Depth

| 단계 | 처리 | 쓰는 곳 |
| --- | --- | --- |
| 0 | 그림자 없음 | 바탕, 탭 |
| 1 | 1px 안쪽 hairline | 카드·패널 기본 |
| 2 | 얕게 겹친 그림자 + hairline | 입력 상자, 마우스를 올린 카드 |
| 3 | 넓게 겹친 그림자 | 화면 아래에 붙는 실행 바 |

광원은 위쪽 하나. 그림자 값은 Known Gaps 참조.

## Shapes

컨트롤 6px(`sm`), 카드 8px(`md`), 패널 12px(`lg`), 칩·배지 `full`. 정돈된 도구 성격이라 작은 반경을 쓰고, 칩만 둥글게 해서 컨트롤과 구분한다.

## Components

- 결과 카드(`asset-card`): 이미지는 정사각형으로 카드 폭을 채우고 안쪽 여백은 아래 정보 영역에만 둔다. 상태는 배지로 표시(대기·생성 중·완료·실패).
- 스타일 칩(`style-chip`): 꺼짐은 옅은 면, 켜짐은 `ink`로 채움. 체크 표시를 함께 둬 색에만 의존하지 않는다.
- 주 버튼(`button-primary`): 화면당 하나, 화면 아래에 붙는 실행 바에 둔다. 진행 중에는 "남은 생성 모두 취소" 보조 버튼으로 바뀐다.
- 결과 카드 안 행동: 탐색 결과는 "이 스타일로 세트"가 보조 버튼, 다운로드는 링크. 세트·기록 결과는 다운로드가 보조 버튼.
- 생성을 시작하면 스타일 선택은 요약 한 줄로 접고 결과를 바로 아래에 둔다.

## Do's and Don'ts

- 이미지 위에 색 오버레이·그라디언트를 얹지 않는다.
- 카드마다 다른 색·그림자를 쓰지 않는다. 18개 결과를 같은 조건으로 비교해야 한다.
- 강조색을 장식에 쓰지 않는다.
- `transition: all`과 레이아웃 속성 전환을 쓰지 않는다.

## Responsive

검수 폭 320·360·768·1024·1280px. 768px 미만에서 입력 두 칸은 한 줄씩, 그리드는 2열, 320px에서 1~2열. 실제 사용은 데스크톱이지만 창을 좁혀도 가로 스크롤이 없어야 한다.

## Known Gaps

- DESIGN.md 0.4 사양에 그림자·모션 토큰이 없다. 그림자 3단계와 모션 시간은 `src/styles/tokens-extra.css`에 두고 화면 코드는 `var()`로만 참조한다.
- 테두리 색 토큰이 없어 카드·입력 경계는 `hairline`·`hairline-control`을 CSS에서 직접 연결한다.
