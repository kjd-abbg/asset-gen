# UX·UI 화면 설계 기준

UI가 있는 웹·앱 프로젝트의 화면 설계·리뷰 기준. UI가 없으면 적용 대상에서 제외.
접근성 수치는 [접근성 기준](ACCESSIBILITY.md), 레이아웃·시각 위계·내비게이션·데이터 화면은 [시각 설계](VISUAL_DESIGN.md), 설계 절차와 렌더 리뷰는 [디자인 리뷰](DESIGN_REVIEW.md), 화면 문구는 [제품 문구 기준](UI_COPY.md), 전환·캐시·브라우저 검증은 [UI 검증](UI_VALIDATION.md), 색·글꼴·간격·모션 값은 [디자인 토큰](DESIGN_TOKENS.md), 로고·앱 아이콘은 [로고 기준](LOGO_DESIGN.md), UI 아이콘·공유 이미지·사진은 [시각 에셋](VISUAL_ASSETS.md), AI 기능은 [AI 기능](AI_FEATURES.md)이 맡으며 여기서는 중복 서술하지 않음.
프로젝트가 정한 예외와 선택은 해당 프로젝트의 `decisions.md`에 날짜와 이유를 남길 것.

## 설계 기준과 리뷰 체크리스트

화면 리뷰는 아래 두 목록으로 항목별 통과·위반·해당 없음을 기록. "전반적으로 괜찮음" 같은 총평으로 대신하지 말 것.

| ISO 9241-110:2020 상호작용 원칙 | 화면에서 확인할 것 |
| --- | --- |
| Suitability for the user's tasks | 과업에 불필요한 단계·입력·확인 화면 없음 |
| Self-descriptiveness | 현재 위치, 가능한 행동, 다음 결과가 화면만 보고 파악됨 |
| Conformity with user expectations | 플랫폼·제품 안 관례와 같은 위치·이름·동작 |
| Learnability | 처음 쓰는 사용자가 도움말 없이 주요 과업 완료 |
| Controllability | 취소·뒤로·되돌리기·일시정지 가능, 시스템이 임의로 흐름을 가져가지 않음 |
| Use error robustness | 오류 예방, 입력 보존, 복구 경로 |
| User engagement | 신뢰할 수 있고 계속 쓰고 싶은 경험. 조작적 유도로 충족하지 말 것(정직한 설계 절) |

Nielsen 10 Heuristics는 휴리스틱 평가의 항목으로 사용: 시스템 상태 가시성, 실제 세계와의 일치, 사용자 통제와 자유, 일관성과 표준, 오류 예방, 회상보다 재인, 사용의 유연성과 효율, 미적이고 최소한의 디자인, 오류 인식·진단·복구 지원, 도움말과 문서. 평가자는 위반마다 화면·상태·심각도를 남길 것.

Norman의 개념은 컴포넌트 단위 점검에 사용.
- signifier: 누를 수 있는 것, 입력할 수 있는 것, 끌 수 있는 것이 시각적으로 구분됨. 웹 UI의 "버튼처럼 보이게"는 affordance보다 signifier 문제로 다룰 것(Norman 2008). feedback: 모든 조작에 보이는 결과나 진행 상태(응답 시간 절). mapping: 컨트롤과 영향받는 대상의 배치가 대응(목록 항목의 동작 버튼은 그 행 안). constraints: 불가능한 값·조합은 입력 단계에서 막고 막힌 이유를 표시. conceptual model: 같은 대상은 화면마다 같은 이름·아이콘·위치.

## 상태 설계

모든 화면은 아래 상태를 설계·구현·검증할 것. `spec/SCREENS.md`(`--with-spec`으로 배치한 경우)의 빈 상태·에러 상태 칸이 비면 미완성이며, 칸이 없는 로딩·성공·권한 없음은 해당 행의 주요 동작·필요한 권한 칸이나 화면별 메모에 기록.

| 상태 | 구분할 경우 | 화면 요구 |
| --- | --- | --- |
| 빈 상태 | 첫 사용 / 검색·필터 결과 없음 / 삭제 후 비어 있음 | 비어 있는 이유와 다음 행동(만들기, 조건 해제) |
| 로딩 | 첫 진입 / 재조회 / 부분 영역 갱신 | 응답 시간 절의 구간 규칙, 레이아웃 이동 최소화 |
| 오류 | 입력 오류 / 요청 실패 / 일부 데이터만 실패 | 무엇이 실패했고 사용자가 할 수 있는 일. 입력값 보존 |
| 성공 | 저장·제출·삭제 완료 | 결과 확인과 이어지는 행동. 포커스 이동 없는 알림은 ACCESSIBILITY의 상태 메시지 기준 |
| 권한 없음 | 로그인 필요 / 권한 부족 / 만료된 세션 | 필요한 조치(로그인, 권한 요청). 권한 없는 데이터의 존재·내용을 노출하지 말 것 |

## 응답 시간과 피드백

| 응답 시간 | 사용자 지각 (NN/g, Miller 1968, Card et al. 1991) | 키트 기본값 |
| --- | --- | --- |
| 0.1초 이내 | 즉각 반응으로 느낌 | 클릭·탭 직후 눌림·선택·진행 중 상태 같은 첫 피드백을 이 범위에 표시 |
| 1초 이내 | 흐름은 유지되나 지연을 인지 | 별도 로딩 표시 없이 결과 표시 |
| 2~10초 | 주의가 흩어지기 시작 | 전체 화면 로딩은 정적 스켈레톤, 단일 모듈은 스피너 |
| 10초 초과 | 주의 유지 한계 | percent-done 진행 막대, 가능하면 남은 양·취소 수단 |

로딩 표시는 이 절이 기준이며 다른 문서는 여기를 가리킴. 상황별 기본값:

| 상황 | 기본값 |
| --- | --- |
| 제자리 동작(저장, 토글, 좋아요) | 0.1초 안에 눌림·진행 중 상태. 1초 안에 끝나면 별도 로딩 표시 없음 |
| 화면 이동(라우트 전환) | 소요를 미리 알 수 없으므로 첫 피드백(눌림 상태 또는 목적지 스켈레톤)을 0.1초 안에. 캐시 적중처럼 빨리 끝나는 경로에서 스켈레톤이 깜빡이는지 UI_VALIDATION으로 측정하고, 깜빡이면 표시 지연(예: 150~300ms)과 최소 유지 시간을 프로젝트가 정해 `decisions.md`에 기록 |
| 화면 일부 갱신(목록 재조회, 모듈) | 기존 내용을 유지한 채 그 영역에 스피너나 진행 표시. 영역을 비우지 않음 |
| 10초 넘는 작업 | 실제 진행률이나 단계 표시. 아래 생성 작업 규칙 |

- 수십 초 이상 걸리는 생성 작업: 퍼센트를 지어내지 말고 서버가 기록한 실제 단계와 경과 시간만 표시, 해당 없는 단계는 숨김. 대기 중 팁 회전은 진행 표시가 아님. 화면을 떠났다 돌아와도 같은 작업을 이어 보이게 하고, 상태를 모르는 채 오래 지나면 시한 뒤 복귀하며 과금·차감 여부를 알림(사례 D4). 운영 표본 전에는 예상 시간을 숫자로 말하지 않음.
- 1~2초 구간 표시 여부는 출처가 정하지 않음. 깜빡임 여부를 [UI 검증](UI_VALIDATION.md) 전환 계약대로 측정해 프로젝트에서 정할 것. 진행 막대는 실제 진행에 따라 갱신하고, 추정이 불가능하면 단계 표시(예: 업로드 2/5)로 대체.
- 스켈레톤은 정적 회색 블록이 기본이며 실제 본문과 같은 구조 컴포넌트·폭·분할·제목 영역 사용(비교 방법은 UI 검증 문서). 맥박·그라디언트 애니메이션은 산만함과 접근성 문제가 있어 기본값에서 제외(UI 라이브러리 스켈레톤이 기본으로 pulse를 켜면 끌 것), 헤더·푸터만 보이는 frame-display형 금지. 스피너처럼 실제 처리 중임을 알리는 표시만 반복 애니메이션을 씀.

## 폼

- 기본 배치는 단일 열 수직 정렬. 성·이름, 시작·종료일, 우편번호·주소처럼 하나의 정보를 이루는 필드만 한 줄에 배치(KRDS 입력폼).
- 라벨은 필드 위쪽이 안전한 기본값. 정량 우위가 확립된 배치는 없으므로(근거와 한계) 다단 폼은 프로젝트에서 검증 후 결정.
- 공공·일회성 신청 흐름은 한 페이지 한 질문(one thing per page)부터 시작하고 label이나 legend를 페이지 제목으로 사용. 숙련자가 반복 처리하는 업무 도구는 사용자 연구 근거가 있으면 묶음 허용(GOV.UK). 모달 안 입력 컴포넌트는 5개 이내, 단계형 입력은 단계 표시와 중간 저장 제공(KRDS).
- placeholder를 라벨·도움말 대신 쓰지 말 것. 형식 예시는 필드 밖 도움말에 둘 것(ACCESSIBILITY 3.3.2, NN/g). 필수·선택 표기는 수가 적은 쪽만 표시하고 제품 전체에서 같은 방식 사용. 꼭 필요한 정보만 요청. 오류나 화면 갱신 뒤에도 입력값을 지우지 말 것. 본인 정보 필드의 `autocomplete` 토큰은 ACCESSIBILITY 기준을 따름.

한국 개인정보 입력(KRDS 기본 패턴 "개인 식별 정보 입력"):

| 항목 | 규칙 |
| --- | --- |
| 이름 | 단일 입력 필드. 공백·기호 포함 모든 문자 허용, 한글 이름에 최소 3자 요구 금지, 중간 공백 자동 제거 금지, 로마자 대소문자를 입력 그대로 저장. 로마자 이름 필드 너비 320~360px 이상, 단일 열이면 가용 폭 100% |
| 생년월일 | 날짜 선택기, 연·일 셀렉트 금지. 단일 또는 분할 텍스트 입력과 형식 안내 |
| 성별 | 기본 선택값 없음. 신원 확인에 필요하지 않으면 선택 항목으로 두거나 "선택 안 함" 제공 |
| 전화번호 | 공백·하이픈 등 여러 형식 허용, 필요하면 자동 서식화. 용도별 라벨("휴대 전화번호") |
| 공통 | 수집 필요성 재확인, 용도 안내, 복사·붙여넣기 허용, 기본값 미설정 |

동의 화면: 항목마다 [필수]/[선택] 표기, 필수 항목을 위쪽에 묶음, "동의하지 않음" 선택지 제공. 일괄 동의는 개별 항목 중 하나라도 "동의 안 함"이면 해제 상태 유지. 선택 동의를 거부해도 서비스 이용이 가능하면 그 사실을 화면에 표시(KRDS 동의 패턴). 알릴 사항·분리 동의 같은 법적 요건은 [개인정보·법적 고지](PRIVACY_LEGAL.md) 동의 받기 절.

## 검증 시점과 버튼: 키트 기본값

출처끼리 충돌하는 세 항목은 아래를 기본값으로 사용. 다르게 정하면 프로젝트 `decisions.md`에 근거와 함께 기록.

| 항목 | 출처별 입장 | 키트 기본값 |
| --- | --- | --- |
| 검증 시점 | GOV.UK: 제출 시 검증. Wroblewski 2009: 복잡한 필드는 입력을 마친 뒤(blur) 검증이 유리 | 제출 시 검증과 오류 요약. 아이디·비밀번호처럼 형식 규칙이 복잡한 필드만 blur 검증 허용. 입력 중 실시간 오류 표시 금지 |
| 비활성 제출 버튼 | KRDS: 필수값 입력 전 비활성화 고려. GOV.UK: 대비가 낮고 혼란을 주므로 회피 | 활성 상태로 두고 제출 시 오류 안내. 이중 제출은 서버 중복 방지와 진행 중 상태 표시로 처리 |
| 주 버튼 위치 | KRDS: 폼 오른쪽 아래, 제출 버튼이 가장 오른쪽. GOV.UK: 왼쪽 정렬 | 제품 안에서 한 가지로 통일. 공공 서비스는 KRDS를 따름. 결정한 위치를 `decisions.md`에 기록 |

## 오류 처리

- 필드 오류는 필드 바로 옆과 페이지 상단 오류 요약 두 곳에 같은 문구로 표시(GOV.UK). 오류 요약 위치는 메인 영역 상단, 페이지 제목 위. 항목마다 해당 필드로 이동하는 링크를 두며, 라디오·체크박스는 첫 선택지, 날짜처럼 여러 칸인 입력은 오류가 난 첫 칸을 대상으로 함. 오류가 하나여도 요약 표시.
- 오류가 있으면 문서 `<title>` 앞에 "오류: " 접두어. 요약으로의 포커스 이동과 `aria-*` 연결은 ACCESSIBILITY "폼·오류·인증" 기준. 심각도에 따라 표현을 나눔: 입력 오류는 인라인, 진행 불가 오류만 모달. 모달을 닫으면 오류 필드로 포커스 복귀(KRDS 오류 패턴).
- 오류 상태는 "처음부터 실패"와 "기존 결과가 남아 있는 재시도 실패"를 따로 설계·렌더 검증. 오류 상자 간격은 브라우저 기본 문단 여백에 기대지 말고 명시.
- 요금·사용량 제한은 원인을 구분해 안내: 미지원 등급, 이번 기간 사용량 소진(갱신일 안내, 업그레이드로 해결되지 않으면 업그레이드를 권하지 않음), 서버 거절, 인증·일반 오류. 기존 결과는 계속 보고 편집할 수 있게 두고, 요금표로 보내기 전에 원인부터 설명. 안내 모달 위에 요금 모달을 쌓지 않음(사례 D5).
- 내용은 원인과 해결 방법을 구체적으로, 사용자를 탓하지 않게(NN/g). 오류 코드만 표시 금지, 문구 작성 규칙은 UI_COPY. 탐색 중이거나 아직 입력하지 않은 필드에 오류를 미리 띄우지 말 것. 복구 불가 장애는 상황, 데이터 보존 여부, 다시 시도할 시점이나 대체 경로를 안내.

## 정보 구조와 시각 계층

- 게슈탈트 원리(근접·유사·공통 영역)는 정성 원리이며 px 수치의 근거로 쓰지 말 것. 점검은 측정 가능한 관계로 함: 같은 그룹 요소 간격이 그룹 사이 간격보다 작고, 같은 역할 요소는 같은 스타일 토큰 사용.
- 훑어보기 패턴(F-pattern 등)·주 행동 위계·색 비율은 [시각 설계](VISUAL_DESIGN.md) 위계와 훑어보기·색 사용 절이 기준. 상태(오류·경고·성공)를 색으로만 구분하지 말 것(대비 수치는 ACCESSIBILITY).

줄 길이·읽기 폭은 [제품 문구 기준](UI_COPY.md) 문단 너비 절이 기준.

## 정직한 설계

다크 패턴은 매출 지표가 개선되더라도 구현하지 말 것. 아래 6개 유형은 한국에서 개정 전자상거래법상 금지 행위로 2025-02-14부터 시행 중(공정위 2025-09-30 보도자료). 화면 점검 기준은 키트 해석이며 위반 여부 판정은 법무 확인 사항.

| 법정 유형 | 화면 점검 |
| --- | --- |
| 숨은갱신 | 무료→유료 전환·정기결제 금액 증액 전에 별도 동의·고지 절차가 있는지 |
| 순차공개 가격책정 | 가격을 처음 보여 주는 화면에 필수 지급 총액이 표시되는지(배송비·수수료를 결제 직전에 추가하지 않음) |
| 특정옵션 사전선택 | 유료 부가 상품·추가 동의가 미리 선택돼 있지 않은지 |
| 잘못된 계층구조 | 사업자에게 유리한 선택지만 크게·진하게, 불리한 선택지를 흐리게 처리하지 않았는지 |
| 취소·탈퇴 방해 | 해지·탈퇴 경로를 찾을 수 있고 가입보다 과도한 단계·채널을 요구하지 않는지 |
| 반복간섭 | 거절한 선택을 팝업 등으로 반복 요구하지 않는지 |

키트 규칙으로 함께 금지하는 유형(deceptive.design 분류): 허위 긴급성·희소성, 가짜 사회적 증거, 장바구니 몰래 추가(sneaking), 광고 위장, 강제 행동(가입 강요), 거절 수치심 유도(confirmshaming), 숨은 비용, 비교 방해. 공정위 「온라인 다크패턴 자율관리 가이드라인」(2023)의 4개 유형·19개 세부 유형은 2차 출처로만 확인해 분류 근거로 쓰지 않음.

## 미적 품질

시각 완성도는 사용성 결함을 덮지 못함. 아름다운 화면이 사용 후에도 쓰기 쉽다고 평가된 연구(Tractinsky et al. 2000)와, 사용성이 낮으면 사용 후 미적 평가까지 떨어지고 미적 수준은 지각된 사용성에 영향이 없던 연구(Tuch et al. 2012)가 엇갈림. 사용성 테스트에서는 과업 성공·오류·소요 시간을 만족도·선호와 따로 기록하고, 고품질 시안의 호감 평가를 과업 성공 근거로 쓰지 말 것.

## 검증 방법

| 확인 | 방법 | 통과 기준 |
| --- | --- | --- |
| 상태 완비 | SCREENS.md 각 행과 구현된 상태를 대조, 상태별 스크린샷 | 빈·로딩·오류·성공·권한 없음 모두 존재 |
| 응답 피드백 | UI_VALIDATION의 늦춘 응답·실패 응답 조건에서 첫 피드백과 본문 표시 시각 측정 | 표의 구간 규칙 충족 |
| 폼 실패 경로 | 빈 제출, 형식 오류, 서버 오류, 연속 클릭 | 요약+필드 오류, 입력 보존, 중복 제출 없음 |
| 휴리스틱 리뷰 | ISO 7원칙·Nielsen 10항목 표 작성 | 위반 항목마다 화면·심각도·조치 기록 |
| 정직한 설계 | 가입·결제·구독·해지·동의 흐름을 끝까지 수행 | 법정 6개 유형과 키트 금지 유형 해당 없음 |
| 사용자 과업 | 대표 사용자 또는 대리 평가자로 주요 과업 수행 | 과업 성공 여부와 만족도를 분리 기록 |

에이전트 리뷰나 자동 검사 통과를 실제 사용자 테스트 결과로 보고하지 말 것. 미실행 항목은 인계에 남길 것.

## 근거와 한계

확인일 2026-10-01.

- [ISO 9241-110:2020](https://www.iso.org/standard/75258.html) Interaction principles, Ed.2, 2020-05 (2025 재확인). [ISO 9241-11:2018](https://www.iso.org/standard/63500.html) Usability: Definitions and concepts, Ed.2, 2018-03. 공식 페이지에서는 제목·판·초록만 확인. [NN/g, 10 Usability Heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/). Nielsen & Molich (1990), Heuristic evaluation of user interfaces, CHI '90, 249–256, doi:10.1145/97243.97281. Nielsen (1994), Enhancing the explanatory power of usability heuristics, CHI '94, 152–158, doi:10.1145/191666.191729. Norman, D. A. (2013), The Design of Everyday Things: Revised and Expanded Edition, Basic Books, ISBN 978-0-465-05065-9. Norman (2008), [Signifiers, not affordances](https://jnd.org/signifiers-not-affordances/), Interactions 15(6), 18–19, doi:10.1145/1409040.1409044.
- [NN/g, Response Times: The 3 Important Limits](https://www.nngroup.com/articles/response-times-3-important-limits/). Miller, R. B. (1968), AFIPS Fall Joint Computer Conf., doi:10.1145/1476589.1476628. Card, Robertson & Mackinlay (1991), CHI '91, 181–186, doi:10.1145/108844.108874. Myers (1985), The importance of percent-done progress indicators, CHI '85, 11–17, doi:10.1145/317456.317459. [NN/g, Progress Indicators](https://www.nngroup.com/articles/progress-indicators/) (2014), [NN/g, Skeleton Screens 101](https://www.nngroup.com/articles/skeleton-screens/) (2023).
- GOV.UK Design System: [Question pages](https://design-system.service.gov.uk/patterns/question-pages/), [Validation](https://design-system.service.gov.uk/patterns/validation/), [Error message](https://design-system.service.gov.uk/components/error-message/), [Error summary](https://design-system.service.gov.uk/components/error-summary/), [Button](https://design-system.service.gov.uk/components/button/). [Service Manual, Structuring forms](https://www.gov.uk/service-manual/design/form-structure). [KRDS](https://www.krds.go.kr): 행정안전부 「디지털 정부서비스 UI/UX 가이드라인」 배포 2024-02-29, KRDS 서비스 개시 2025-01-16([행정안전부](https://mois.go.kr/frt/sub/a06/b04/uixInnovation/screen.do)). 디자인 원칙 7개, 기본 패턴(개인 식별 정보 입력, 입력폼, 동의, 오류, 도움), 색상 스타일.
- Wroblewski (2009), [Inline Validation in Web Forms](https://alistapart.com/article/inline-validation-in-web-forms/), A List Apart. Wroblewski (2008), Web Form Design, Rosenfeld Media, ISBN 978-1-933820-24-8. [NN/g, Placeholders in Form Fields Are Harmful](https://www.nngroup.com/articles/form-design-placeholders/) (2014). [NN/g, Error-Message Guidelines](https://www.nngroup.com/articles/error-message-guidelines/) (2023).
- [NN/g, F-Shaped Pattern (2006)](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content-discovered/), [재연구 (2017)](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/). Wagemans et al. (2012), A century of Gestalt psychology in visual perception I, Psychological Bulletin 138(6), 1172–1217, doi:10.1037/a0029333. [WCAG 2.2 Understanding 1.4.8](https://www.w3.org/WAI/WCAG22/Understanding/visual-presentation.html). Dyson & Kipping (1998), Visible Language 32(2). Dyson & Haselgrove (2001), IJHCS 54(4), 585–612, doi:10.1006/ijhc.2001.0458. Dyson (2004), Behaviour & IT 23(6), 377–393, doi:10.1080/01449290410001715714. Tractinsky, Katz & Ikar (2000), What is beautiful is usable, Interacting with Computers 13(2), 127–145, doi:10.1016/S0953-5438(00)00031-X. Tuch et al. (2012), Is beautiful really usable?, Computers in Human Behavior 28(5), 1596–1607, doi:10.1016/j.chb.2012.03.024. [공정위, 다크패턴 모니터링 및 시정사례 발표](https://www.ftc.go.kr/www/selectBbsNttView.do?key=12&bordCd=3&nttSn=46476) (2025-09-30): 시행일과 6개 유형. Mathur et al. (2019), Dark Patterns at Scale, Proc. ACM HCI 3(CSCW), doi:10.1145/3359183. Gray et al. (2018), The Dark (Patterns) Side of UX Design, CHI '18, doi:10.1145/3173574.3174108. [deceptive.design types](https://www.deceptive.design/types). [Vitsoe, Dieter Rams: ten principles for good design](https://www.vitsoe.com/gb/about/good-design).

오용 주의와 미확인 사항:
- ISO 9241-110의 7원칙 이름과 9241-11의 사용성 정의 문장(effectiveness·efficiency·satisfaction)은 표준 원문 미확인이며 2차 출처로만 확인. 원문 인용이 필요하면 표준 구매 후 대조할 것.
- 공정위 2023 자율관리 가이드라인의 유형 분류, 전자상거래법 조문 번호, 계도기간·과태료 세부는 2차 출처로만 확인(미확인). Gray et al.의 5개 전략 분류도 원문 미확인.
- KRDS와 GOV.UK는 버튼 위치·비활성 버튼·검증 시점에서 다르며, 키트 기본값은 위 표의 선택. KRDS 적용 수준(필수·권장·우수)은 서비스 패턴에만 정의됨. Wroblewski 2009 수치(성공률 +22%, 완료 시간 -42% 등)는 22명 대상 업체 수행 연구로 동료심사가 없어 수치를 일반화하지 말 것. 단순 필드에서는 30~50%만 검증 메시지를 인지함. 줄 길이 연구는 영문 기준이며 결과가 엇갈림(100cpl이 빠르고 55cpl이 선호됨). 한국어 수치는 WCAG 1.4.8의 CJK 40자뿐이고 AAA 기준임.
- 쓰지 않는 근거: Doherty & Thadhani(1982)는 IBM 발행물로 동료심사가 없고 원문 스캔에서 400ms 문장을 찾지 못함. 7±2를 메뉴 항목 수 제한으로 쓰는 해석은 NN/g가 오해로 지적하며, 단기기억 용량은 약 4청크(Cowan 2001, doi:10.1017/S0140525X01003922). "F자로 배치"는 F-pattern 연구의 오독. Penzo(2006, UXmatters) 라벨 위치 수치는 참가자 수 비공개 실무 기사이고, Das et al.(2008, NordiCHI, doi:10.1145/1463160.1463217)은 다단 폼에서 반대 결과를 보고함. Fitts(1954)·Hick(1952)의 법칙은 개념 설명용이며 대상 크기 수치는 ACCESSIBILITY의 WCAG 2.5.8·플랫폼 기준을 사용. Dieter Rams의 10원칙은 실증 연구가 아닌 디자이너의 가치 선언이므로 판정 기준으로 쓰지 말 것.
