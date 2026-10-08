# 웹·앱 접근성 기준

UI가 있는 웹·모바일 앱 프로젝트의 화면 구현과 검증 기준. UI가 없으면 적용 대상에서 제외.
키트 관리 문서로 신규 배치와 `--update`에 포함되며, 프로젝트별 예외·측정값은 해당 프로젝트의 상태 파일과 테스트에 기록.

## 기준선

- 키트 기준은 WCAG 2.2 Level AA (A와 AA 성공 기준 전부). AAA는 이 문서가 기본값으로 채택한 항목만 적용.
- 한국 서비스에는 KWCAG 2.2 (KS X OT0003:2022, 4원칙·14지침·33개 검사항목), 「디지털포용법」 제19·21·22조, 「장애인차별금지법」 제21조가 적용될 수 있음.
- KWCAG 2.2는 WCAG 2.1 기반이라 WCAG 2.2 신규 기준이 없음. 키트는 신규 AA 2.4.11·2.5.7·2.5.8·3.3.8과 신규 A 3.2.6·3.3.7도 기준에 포함.
- 4.1.1 Parsing은 WCAG 2.2에서 삭제(obsolete)됐지만 KWCAG 검사항목 32 "마크업 오류 방지"는 남아 있음. 한국 인증 대상이면 마크업 오류 검사 유지.
- WA 인증마크는 디지털포용법 제21조에 따라 과학기술정보통신부가 지정한 인증기관이 심사함. 전문가 심사는 33개 항목 평균 준수율 95% 이상, 사용자 심사는 과업 성공률 100%로 합격(한국정보접근성인증평가원 심사기준).
- 법적 의무 대상인지, 인증이 필요한지는 법무 확인 사항으로 넘기고 에이전트가 판정하지 말 것.

## 의미 구조와 네이티브 요소

- 필요한 의미와 동작을 가진 네이티브 HTML 요소·속성이 있으면 ARIA 대신 그것을 사용(APG Read Me First, "No ARIA is better than Bad ARIA"). `<button>`, `<a href>`, `<input>`, `<select>`, `<dialog>`, `<details>`부터 검토.
- `role`은 동작의 약속이며 브라우저가 키보드 동작을 주지 않음. `<div role="button">`을 쓰면 포커스, Enter·Space 처리, 상태 갱신을 직접 구현해야 함.
- 제목 계층(h1~h6), 랜드마크(`header`·`nav`·`main`·`footer`), 목록·표 마크업으로 구조 표현(1.3.1). 데이터 표는 `th`·`scope`·`caption` 사용. 포커스 가능한 요소에 `aria-hidden="true"`나 `role="presentation"` 금지.
- 반복 영역 건너뛰기 링크(2.4.1), 주제를 설명하는 `<title>`(2.4.2). 링크 목적은 링크 텍스트나 문맥으로 판단 가능해야 하고(2.4.4), 제목과 레이블은 주제·목적을 설명(2.4.6).
- 보이는 레이블 텍스트를 접근 가능한 이름에 포함(2.5.3). "검색" 버튼의 `aria-label`을 "찾기 실행"처럼 바꾸지 말 것.

## 텍스트 대체

- 정보 이미지는 같은 정보를 `alt`로, 장식 이미지는 `alt=""` 또는 CSS 배경으로 처리(1.1.1). 아이콘만 있는 버튼·링크는 `aria-label`이나 시각적으로 숨긴 텍스트로 이름 제공.
- 차트·지도·다이어그램은 인접 텍스트 요약이나 데이터 표를 함께 제공. 사전 녹화 영상의 음성에는 자막 제공(1.2.2).
- 로고 텍스트는 1.4.3 대비 예외지만 대체 텍스트는 필요함. 상세는 [로고 기준](LOGO_DESIGN.md).
- UI 아이콘·일러스트·사진·공유 이미지의 판단 순서와 구현은 [시각 에셋](VISUAL_ASSETS.md).

## 색과 대비

| 대상 | 최소 대비 | 근거 |
| --- | --- | --- |
| 일반 텍스트, 텍스트 이미지 | 4.5:1 | 1.4.3 |
| 큰 텍스트: 18pt 이상 또는 14pt 이상 bold (CSS 환산 약 24px / 18.66px) | 3:1 | 1.4.3 |
| UI 컴포넌트 식별·상태 표시(입력 테두리, 체크 상태, 포커스 표시), 이해에 필요한 그래픽 | 인접 색 대비 3:1 | 1.4.11 |
| 비활성 컴포넌트, 순수 장식, 로고·브랜드명 | 요구 없음 | 1.4.3 예외 |

- 색만으로 정보 전달 금지(1.4.1). 오류 필드는 색과 함께 텍스트·아이콘, 본문 속 링크는 밑줄 등 색 외 단서 제공.
- 라이트·다크 두 테마 모두 측정. 테마별 전경/배경 토큰 쌍과 hover·focus·disabled·error 상태를 표로 기록.
- 반투명 오버레이, 그라디언트, 이미지 위 텍스트는 가장 불리한 지점에서 측정.

## 확대·리플로·텍스트 간격

| 조건 | 통과 기준 | 근거 |
| --- | --- | --- |
| 텍스트 200% 확대 (보조기술 없이) | 콘텐츠·기능 손실 없음 | 1.4.4 |
| 너비 320 CSS px (1280px에서 400% 확대와 같음) | 세로 스크롤 콘텐츠에 2차원 스크롤 없음 | 1.4.10 |
| 높이 256 CSS px | 가로 스크롤 콘텐츠에 2차원 스크롤 없음 | 1.4.10 |
| 줄 높이 1.5배, 문단 뒤 간격 2배, 자간 0.12배, 단어 간격 0.16배 (글꼴 크기 기준) | 사용자가 덮어써도 잘림·겹침·기능 손실 없음 | 1.4.12 |

- 1.4.10 예외는 지도·다이어그램·영상·게임·데이터 표처럼 2차원 배치가 의미에 필요한 부분에 한정.
- `user-scalable=no`, `maximum-scale=1` 같은 확대 차단 viewport 설정 금지(키트 규칙). 텍스트 컨테이너의 고정 `height`와 `overflow: hidden` 조합은 1.4.12 실패의 흔한 원인이므로 피할 것. 줄바꿈 판단은 [제품 문구 기준](UI_COPY.md)의 문단 너비 절과 함께 볼 것.

## 키보드와 포커스

- 모든 기능을 키보드로 조작 가능하게, 키 입력 타이밍 요구 없이(2.1.1). 경로 자체가 입력인 기능(자유 그리기 등)만 예외.
- 키보드 포커스가 갇히지 않게 할 것(2.1.2). 모달은 내부에서 순환하되 Escape와 닫기 버튼으로 빠져나오고, 닫으면 트리거로 포커스 복귀.
- 포커스 순서는 의미·조작 순서와 일치(2.4.3), 양수 `tabindex` 금지. 포커스 표시 제거 금지(2.4.7). `outline: none`을 쓰면 `:focus-visible`로 대체 표시를 주고, 그 표시도 1.4.11 기준 3:1로 측정.
- 고정 헤더, 쿠키 배너, 하단 탭 바가 포커스된 요소를 완전히 가리지 않게 할 것(2.4.11). `scroll-padding`·`scroll-margin`으로 보정.
- 포커스를 받는 것만으로 페이지 이동, 새 창, 제출 같은 맥락 변경 금지(3.2.1).
- 모달은 네이티브 `<dialog>`를 우선. 호출한 요소는 자식의 자동 포커스보다 먼저 저장해야 닫을 때 돌아갈 수 있음. 배경 스크롤 잠금은 `html`과 `body`를 함께(body만 잠그면 루트가 스크롤됨), 중첩 모달은 참조 카운트로. 외곽은 고정하고 본문만 스크롤. body에 창을 띄우는 외부 SDK(결제 등)는 top layer의 dialog를 이길 수 없으니 실행 전에 dialog를 닫고 취소 시 복원(사례 D14).
- 호버에서만 나타나는 조작(목록 행의 삭제 버튼 등)은 키보드·터치에서 보이지 않음. `display: none` 대신 투명도로 숨기고 포커스 시 보이게, 대상 크기는 24px 이상.

## 포인터·터치 대상

| 대상 | 크기 | 근거 |
| --- | --- | --- |
| 웹 포인터 대상 최소 | 24×24 CSS px | WCAG 2.5.8 (AA) |
| iOS·iPadOS 앱 권장 | 44×44 pt (최소 28×28 pt) | Apple HIG |
| Android 앱 권장 | 48×48 dp (약 9mm), 대상 간격 8dp 이상 | Android Developers, Google 접근성 도움말 |

- 2.5.8 예외: 24px 미만 대상의 중심에 지름 24px 원을 놓았을 때 다른 대상·원과 겹치지 않음(Spacing), 같은 기능의 기준 충족 컨트롤이 같은 페이지에 있음(Equivalent), 문장 안의 대상(Inline), UA 기본 크기를 수정하지 않음(User Agent Control), 특정 표현이 필수이거나 법적 요구(Essential).
- 슬라이더·색상 선택기처럼 위치로 값을 고르는 대상은 하나로 계산. 크기는 대상 bounding box와 간격으로 측정.
- 드래그 기능에는 단일 포인터 대안 제공(2.5.7). 순서 변경은 위/아래 버튼, 슬라이더는 값 입력이나 증감 버튼.
- 모바일 웹의 주요 버튼·탭·아이콘 버튼은 플랫폼 권장 크기(44pt/48dp 수준)를 목표로 할 것(키트 권장).

## 폼·오류·인증

- 모든 입력에 보이는 레이블이나 지시 제공(3.3.2). placeholder를 레이블 대신 쓰지 말고 `label for`나 `aria-labelledby`로 연결.
- 사용자 본인 정보 입력에는 `autocomplete` 토큰 지정(1.3.5). 예: `name`, `email`, `tel`, `postal-code`, `street-address`, `username`, `current-password`, `new-password`, `one-time-code`.
- 오류는 해당 필드를 식별하고 텍스트로 설명(3.3.1), 수정 방법을 알면 제안(3.3.3). `aria-invalid`와 `aria-describedby`로 메시지를 연결하고, 제출 실패 시 오류 요약이나 첫 오류 필드로 포커스 이동.
- 같은 과정에서 이미 입력한 정보는 자동 채움이나 선택으로 제공(3.3.7). 예: 배송지와 같은 청구지 체크박스. 재입력이 필수이거나 보안 확인용이거나 이전 값이 무효인 경우만 예외.
- 인증 단계에 인지 기능 테스트(비밀번호 기억, 퍼즐 풀이)만 두지 말 것(3.3.8). 비밀번호 관리자 자동 채움과 붙여넣기 허용이 충족 수단의 예(3.3.8 Note 2).
- 비밀번호·인증번호 입력의 붙여넣기 차단 금지. 칸 분할 OTP 입력도 붙여넣기와 `autocomplete="one-time-code"`가 동작해야 함. 이미지 CAPTCHA를 쓰면 다른 방식의 대안 제공(1.1.1, 3.3.8).
- 입력값 변경만으로 예고 없이 맥락을 바꾸지 말 것(3.2.2). `select` 변경 즉시 페이지 이동 금지.

## 동적 콘텐츠·상태 메시지

- 커스텀 탭·콤보박스·메뉴·아코디언은 APG 패턴의 role·키보드 동작을 따르고 `aria-expanded`, `aria-selected`, `aria-checked` 같은 상태를 실제 값과 동기화(4.1.2).
- 포커스 이동 없는 상태 메시지(저장 완료, 검색 결과 수, 업로드 진행)는 `role="status"`나 `aria-live="polite"`, 긴급 오류는 `role="alert"`로 전달(4.1.3). 라이브 영역 컨테이너는 내용을 넣기 전부터 DOM에 두는 방식으로 구현.
- hover·focus로 나타나는 툴팁·서브메뉴는 포인터·포커스 이동 없이 닫을 수 있고(Escape 등), 그 위로 포인터를 옮겨도 유지되며, 사용자가 닫거나 트리거가 해제될 때까지 남아 있어야 함(1.4.13). 브라우저 `title` 툴팁은 예외.
- 자동 시작해 5초를 넘게 움직이는 캐러셀·티커·자동 갱신은 일시정지·정지·숨김 제어 제공(2.2.2).

## 모션

- 1초에 3회를 넘게 번쩍이는 콘텐츠 금지(2.3.1). `prefers-reduced-motion: reduce`에서 시차 스크롤, 확대·회전 전환, 자동 반복 애니메이션을 끄거나 짧은 페이드로 대체. 2.3.3은 AAA지만 키트 기본값으로 대응(기법 C39). 의미 전달에 필수인 모션만 유지.
- [UI 검증](UI_VALIDATION.md) 최소 회귀 행렬의 reduced motion 항목에서 두 설정을 모두 실행하고 프레임 기록으로 확인.

## 언어와 일관된 도움

- `<html lang="ko">`처럼 페이지 기본 언어 지정(3.1.1). 다른 언어 구간은 해당 요소에 `lang` 지정(3.1.2).
- 연락처, 문의 수단, 도움말·FAQ, 챗봇 같은 도움 수단이 여러 페이지에 반복되면 페이지 콘텐츠 기준 같은 상대 순서로 배치(3.2.6).

## 검증 방법

자동 검사만으로 통과를 보고하지 말 것. Deque 데이터에서 axe-core 자동 검사가 찾은 이슈는 전체 이슈 건수의 57.38%였고(WCAG 2.1 기준 데이터), GOV.UK 2017 실험에서는 도구 10개를 합쳐도 심어 둔 장벽의 29%를 찾지 못함.

- 자동: axe-core(예: `@axe-core/playwright`)를 페이지와 상태(오류, 모달 열림, 다크 테마)별로 실행. 위반 0건은 자동 검사 범위 내 결과로만 기록. CI 시점 센서로 두면 CI 워크플로에 브라우저 설치 단계(`npx playwright install --with-deps chromium`)를 함께 넣음(빠뜨려 첫 CI가 실패한 사례, EVIDENCE §N).
- 브라우저 실행·종료·컨텍스트 원칙은 [UI 검증](UI_VALIDATION.md)을 따름. 테마·모션 에뮬레이션 예: `page.emulateMedia({ colorScheme: 'dark', reducedMotion: 'reduce' })`.

| 수동 검사 | 방법 | 통과 기준 |
| --- | --- | --- |
| 키보드 | 마우스 없이 Tab·Shift+Tab·Enter·Space·Escape·화살표로 주요 과업(가입, 로그인, 검색, 작성, 결제) 끝까지 수행 | 과업 완료, 포커스 항상 보임, 갇힘·가림 없음 |
| 확대 | 브라우저 200% 확대, 1280px 뷰포트 400% 확대(320px 너비) | 손실·잘림·2차원 스크롤 없음 |
| 텍스트 간격 | 1.4.12 값을 주입하는 북마클릿이나 테스트용 스타일시트 | 잘림·겹침 없음 |
| 스크린리더 | VoiceOver(macOS·iOS), NVDA(Windows), TalkBack(Android) 중 최소 하나 | 이름·역할·상태·상태 메시지 낭독 |
| 대비 | 라이트·다크 테마에서 계산된 색으로 측정 | 색과 대비 표 기준 |

결과 인계에는 자동 도구와 버전, 대상 페이지·상태·테마, 실행한 수동 검사, 사용한 스크린리더·브라우저·OS, 미실행 범위를 기록. 자동 검사만 했다면 수동 검사 미실행으로 남길 것. 한국 인증의 사용자 심사(장애 유형별 실사용자 과업)는 에이전트 검사로 대체할 수 없음.


포커스 가림(2.4.11)은 조작 요소마다 포커스를 준 뒤 그 요소의 보이는 영역 9개 지점을 hit-test해 확인할 수 있음. 키보드·모달 검사는 Chromium만이 아니라 WebKit headless에서도 돌릴 것(사례 D15). WebKit 통과가 Safari 통과는 아니고, 접근성 트리 검사는 스크린리더 확인이 아님.

## 근거와 한계

확인일 2026-10-01.

- [W3C, WCAG 2.2](https://www.w3.org/TR/WCAG22/): W3C Recommendation, 12 December 2024. 성공 기준 번호·레벨·수치, 큰 텍스트 정의, 4.1.1 삭제, 신규 기준 9개.
- [W3C, Technique C39](https://www.w3.org/WAI/WCAG22/Techniques/css/C39), [Media Queries Level 5](https://www.w3.org/TR/mediaqueries-5/) (Working Draft, 19 February 2026): `prefers-reduced-motion`, `prefers-color-scheme`.
- [W3C APG, Read Me First](https://www.w3.org/WAI/ARIA/apg/practices/read-me-first/): "No ARIA is better than Bad ARIA", "A role is a promise". [W3C, Using ARIA](https://www.w3.org/TR/using-aria/): First rule of ARIA use.
- [국립전파연구원, KS X OT0003 한국형 웹 콘텐츠 접근성 지침 2.2](https://www.rra.go.kr/ko/reference/kcsList_view.do?nb_seq=5247&nb_type=6): 제·개정일 2022-12-28. [한국정보접근성인증평가원, 심사기준](https://www.wa.or.kr/m1/sub3.asp): 33개 검사항목, 합격 기준.
- 국가법령정보센터: [디지털포용법](https://www.law.go.kr/법령/디지털포용법) (법률 제20672호, 2026. 1. 22. 시행), [장애인차별금지법](https://www.law.go.kr/법령/장애인차별금지및권리구제등에관한법률) 제21조, [지능정보화 기본법](https://www.law.go.kr/법령/지능정보화기본법) 제46~49조 삭제.
- [Apple HIG, Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility): 플랫폼별 컨트롤 크기, 라이트·다크 대비 확인.
- [Android Developers, Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps), [Google 접근성 도움말, 터치 대상 크기](https://support.google.com/accessibility/android/answer/7101858): 48dp, 약 9mm, 8dp 간격.
- [Deque, Automated Accessibility Coverage Report](https://www.deque.com/automated-accessibility-testing-coverage/): 2,000건 이상 감사, 약 30만 이슈. [GOV.UK, What we found when we tested tools on the world's least-accessible webpage](https://accessibility.blog.gov.uk/2017/02/24/what-we-found-when-we-tested-tools-on-the-worlds-least-accessible-webpage/) (2017-02-24): 장벽 143개, 도구 10개.

오용 주의와 미확인 사항:
- WCAG 3.0은 Working Draft(10 September 2026)라 적용 기준으로 쓰지 말 것. 문서 스스로 WCAG 2를 대체하지 않는다고 밝힘. Using ARIA는 Discontinued Draft(24 February 2026)로 규칙 4개만 이력용으로 남아 있어 ARIA 판단의 주 근거는 APG로 둠.
- W3C WCAG2Mobile은 Group Draft Note(06 May 2025)이며 규범이 없는 참고 문서. 앱 수치는 플랫폼 가이드 권장값으로만 사용.
- Material Design 페이지(m3.material.io)는 본문을 확인하지 못함(미확인). 48dp는 Android Developers와 Google 접근성 도움말로만 근거를 둠.
- WCAG 2.2에는 다크모드 전용 기준이 없음. 두 테마 측정은 1.4.3·1.4.11을 테마마다 적용한 키트 해석이며 원문 문장에서 온 규칙은 없음. 원문 근거는 Apple HIG의 라이트·다크 대비 확인 문장뿐.
- 장애인차별금지법 시행령의 적용 대상·단계적 시행 세부는 미확인.
- Deque 57.38%는 이슈 건수 기준이며, 성공 기준 수로 세면 WCAG 2.1 AA 50개 중 16개만 자동 검사 대상. 원 발표 연도는 페이지에 없음.
- KWCAG 14지침·WCAG 2.1 기반 서술은 표준 PDF의 민간 미러본으로 확인했고, 공식 원본은 국립전파연구원 첨부 docx임.
- 큰 텍스트 px 값은 CSS 1pt = 4/3px 환산값이며 CJK 글꼴의 동등 크기는 WCAG가 수치로 정하지 않음.
