# 기획 절차와 근거

UI 유무와 무관하게 모든 프로젝트의 시작과 큰 기능 추가에 적용. 1인 프로젝트 기준이며, 검토자가 없는 자리는 사용자 결정과 외부 증거(사용자 대화·관찰·프로토타입)로 채움.
이 문서는 무엇을 만들지 정하는 앞 단계를 맡음. 정한 내용을 빠짐없이 적는 형식은 `spec/` 틀, 형식 검사는 `spec-lint`, 내용 검사는 `implementability-review`, 화면 기준은 [UX 설계](UX_DESIGN.md)가 맡음.
순서: `spec/PRODUCT-BRIEF.md`(프로젝트당 한 장) → `spec/PRD-*.md`(기능별) → `SCREENS`·`STATE-TRANSITIONS`·`PERMISSIONS`·`DATA-MODEL` → `GOLDEN-SCENARIOS` → 구현. `spec/`이 없으면(`--with-spec` 미사용) 키트의 `template/spec/PRODUCT-BRIEF.md`를 `spec/`에 복사해 시작.

## 단계와 종료 조건

| 단계 | 답할 질문 | 산출물 | 종료 조건 |
| --- | --- | --- | --- |
| 1. 문제 검증 | 누구의 어떤 문제인가, 지금 어떻게 처리하나 | 브리프 1·2 | 문제 문장과 현재 대안에 확인 근거(대화·관찰·문의 기록과 날짜) 또는 "가정:" 표시와 사용자 승인 |
| 2. 위험 확인 | 틀리면 프로젝트가 무의미해지는 가설은 무엇인가 | 브리프 3 | 4대 위험마다 확인 방법·반증 기준·결과(확인/반증/미확인). 가치 가설이 반증되면 1단계로 복귀 |
| 3. 범위·기간 고정 | 얼마의 시간을 쓰고 무엇을 하지 않나 | 브리프 4~7 | appetite·끊는 기준·Must·하지 않을 것을 사용자가 승인 |
| 4. PRD | 기능별로 무엇이 참이면 완료인가 | `spec/PRD-*.md` 외 | `spec-lint`와 `implementability-review` PASS |
| 5. 출시·측정 | 언제 내보내고 언제 무엇으로 판단하나 | 브리프 8·9, `GOLDEN-SCENARIOS` | 출시 기준 충족, 지표 수집 확인, 판단 날짜 기록 |

GOV.UK 단계와의 대응: discovery는 1~2단계(해결할 문제를 이해하는 단계이며 서비스를 만들지 않음), alpha는 2단계의 프로토타입(버릴 코드로 여러 해법 시험), beta는 4단계 이후의 실제 구축, live는 출시 후 운영과 개선. discovery 뒤 진행하지 않기로 정하는 것도 정상 결과로 취급(GOV.UK). discovery 4~8주, alpha 6~8주는 정부 서비스 팀 기준의 참고값이며 1인 프로젝트의 기간은 3단계 appetite로 정함.

## 문제와 사용자

- 문제 문장은 JTBD 형식: "[구체 사용자]가 [상황]에서 [이루려는 진행]을 하려 할 때 [막히는 점]". job은 특정 상황에서 고객이 이루려는 진행이며, 선택을 설명하는 데는 사용자 속성(나이·직급)보다 상황이 중요하다는 주장을 따름(Christensen et al. 2016). 기능적 측면과 함께 사회적·감정적 측면도 적을 것.
- 문제 칸에 기능·화면·기술 이름이 나오면 해결책을 적은 것으로 보고 다시 씀. 다시 쓰는 질문: "그것이 없으면 사용자가 지금 무엇을 못 하거나 어떻게 우회하나". 요청된 기능 뒤에서 실제로 끊기는 작업 흐름을 찾을 것(Shape Up, Set Boundaries).
- 현재 대안: 사용자가 지금 쓰는 방법(수작업, 스프레드시트, 메신저, 다른 제품, 포기)을 적음. 좋은 혁신은 기존 해법이 부족하거나 없던 문제를 푼다는 주장(Christensen et al. 2016)에 따라, 현재 대안이 충분하면 가치 위험을 높게 볼 것.
- 만들기 전에 이미 있는 해법(기존 SaaS, 공용 컴포넌트, 문서·공지)을 확인하고 재사용을 먼저 검토(GOV.UK Service Standard 2).
- 대상 사용자는 역할·상황·사용 빈도·현재 도구로 구체화. "모든 사용자", "일반인"은 PRD와 마찬가지로 답으로 치지 않음. 그룹이 둘 이상이면 그룹마다 문제 문장을 따로 씀.
- 브리프 1번은 프로젝트 전체의 문제, PRD 1번(문제 정의)은 그 안에서 기능 하나가 푸는 부분. PRD 2번 대상 사용자는 브리프 대상 사용자의 부분집합이어야 함.

## 위험 먼저

Cagan의 4대 위험을 브리프 3번 표의 행으로 씀. 큰 위험, 특히 가치·사업 위험은 만들기 전에 다룰 것(Cagan, The Four Big Risks).

| 위험 (SVPG 정의) | 가장 싼 확인 방법 | 증거로 침 | 증거로 치지 않음 |
| --- | --- | --- | --- |
| 가치: 고객이 사거나 쓰기로 선택하나 | 과거 행동 인터뷰, 현재 대안에 드는 시간·비용 조사, 수동으로 대신 처리해 보기 | 이미 우회 수단에 시간·돈을 씀, 시험 사용·자료 제공 같은 다음 행동 약속 | 칭찬, "쓸 것 같다"는 미래 의향, 만든 사람의 확신 |
| 사용성: 사용자가 쓰는 법을 알아내나 | 종이·클릭 프로토타입으로 주요 과업 수행(사용자 그룹당 5명) | 과업 성공 여부, 막힌 지점 | 에이전트 리뷰, 만든 사람의 시연 |
| 구현 가능성: 지금의 시간·기술·역량으로 만드나 | 가장 불확실한 부분만 시간 제한 spike(버릴 코드), 외부 API 한도·비용·약관 확인 | 실제 호출·측정 결과 | "라이브러리가 있을 것" 같은 추정 |
| 사업 성립: 비용·법·운영·영업 측면에서 성립하나 | 운영비 계산, 개인정보·약관 확인 목록([PRIVACY_LEGAL](PRIVACY_LEGAL.md) 검증 체크리스트), 회사 결정자 확인 | 결정자 승인 기록, 비용 계산 | 확인 없이 둔 "나중에 처리" |

- 순서: 불확실성이 크고 틀렸을 때 손실이 큰 가설부터 확인. 확인 전에 "무엇이 관찰되면 틀린 것으로 보나"(반증 기준)를 먼저 적을 것.
- 확인 결과로 계속할지 방향을 바꿀지 정함(Build-Measure-Learn의 pivot or persevere, Lean Startup principles). MVP는 최소 노력으로 가장 많은 검증된 학습을 얻는 판(Ries 2009)이므로 기능을 줄인 첫 출시판과 구분할 것. 브리프 3번의 확인 방법이 MVP 후보.
- alpha 성격의 프로토타입 코드는 버린다는 전제로 만들고(GOV.UK alpha) 그대로 제품 코드로 승격하지 말 것.

## 사용자 확인

| 피할 질문 | 바꿀 질문 |
| --- | --- |
| 이런 기능이 있으면 쓰시겠어요? | 마지막으로 이 일을 했을 때 어떻게 했는지 처음부터 말씀해 주세요 |
| 보통 어떻게 하세요? | 지난주에 실제로 있었던 한 건을 예로 들어 주세요 |
| 이 방식이 불편하지 않으세요? | 그때 가장 시간이 많이 든 단계는 어디였나요 |
| 얼마면 사시겠어요? | 지금 이 문제에 돈이나 시간을 쓰고 있나요, 무엇에 얼마나 쓰나요 |

- 일반 과정 대신 구체적인 과거 사건을 묻고, 답을 정해 두는 유도 질문을 피하고, 개방형 질문을 씀. 인터뷰는 자기 보고라 기억 오류와 사회적 바람직성 편향이 있으므로 실제 행동은 관찰이나 로그로 확인(NN/g User Interviews 101). 가설은 빠르게 만들고 버리는 프로토타입으로 일찍, 자주 시험(GOV.UK Service Standard 1).
- 아이디어 설명과 해법 시연은 인터뷰 끝으로 미룸(키트 규칙). 기록 항목: 날짜, 익명 ID, 과거 사건, 현재 대안, 인용. 고객 실명·연락처는 저장소에 넣지 말 것.
- 사용성 테스트: 사용자 그룹당 5명으로 작은 테스트를 여러 번(Nielsen 2000: 5명이 문제의 약 85%를 찾음, 두 그룹이면 그룹당 3~4명, 정량 수치는 20명 이상). 인터뷰 인원은 확인한 출처에 근거 있는 수치가 없어 키트가 정하지 않음. 새로운 문제·대안이 더 나오지 않을 때까지 하고 인원·날짜를 브리프 근거 칸에 적음.
- 실제 사용자를 만날 수 없으면 대리 근거(현업 담당자, 문의·로그 기록)를 쓰되 대리임을 표시하고 해당 위험의 결과를 "미확인"으로 둠.
- 에이전트의 몫: 질문지 초안, 기록 정리, 문의·로그 같은 2차 자료 분석. 인터뷰·테스트 결과를 만들어 내거나 추측해 채우는 것은 금지.

## 범위와 기간

- appetite: 추정치 대신 이 일에 쓰고 싶은 시간을 먼저 정하고 그 시간에 맞춰 해법을 설계(Shape Up: "Appetites start with a number and end with a design"). small batch 1~2주, big batch 6주는 디자이너 1명·프로그래머 1~2명 팀 기준이므로 1인 프로젝트는 일·주 단위로 직접 정함.
- 기간 고정, 범위 조정: 기간이 끝나면 기본값은 연장하지 않음(Shape Up circuit breaker). Must가 남으면 범위를 줄여 내보내거나 중단하고 문제를 다시 정의. 연장은 사용자가 결정하고 `decisions.md`에 이유와 함께 기록.
- 착수할 수 있는 상태의 세 조건(Shape Up, Principles of Shaping): rough(세부는 열려 있음), solved(주요 요소의 연결이 정해짐), bounded(어디서 멈출지 정해짐).
- 하지 않을 것(no-gos): appetite에 맞추거나 문제를 다룰 수 있게 하려고 의도적으로 제외한 기능·사용 사례(Shape Up, Write the Pitch). 브리프 6번이 프로젝트 수준, PRD 4번 비목표가 기능 수준이며, PRD 비목표는 브리프 목록을 이어받고 기능 고유 항목을 더함.
- 알려진 함정(rabbit holes): 너무 불확실하거나 복잡하거나 열려 있어 걸기 어려운 부분. 대응은 범위 밖 선언, 잘라내기, 단순한 방식으로 미리 결정, 기간 안에 가능한지 기술 확인(Shape Up, Risks and Rabbit Holes).
- MoSCoW: Must는 프로젝트가 보장하는 Minimum Usable SubseT. 판별 질문은 "이것이 빠지면 프로젝트를 취소해야 하나". Must 노력은 전체의 60% 이하, Could는 약 20%를 여유분으로 둠(DSDM, 항목 수 대신 노력 기준). Won't는 브리프 6번으로 보냄.
- 범위를 줄일 때 묻는 것(Shape Up, Decide When to Stop): 이것 없이 내보낼 수 있나, 새 문제인가 사용자가 이미 겪는 문제인가, 얼마나 자주 일어나나, 일어나면 영향이 얼마나 큰가. 비교 대상은 이상적인 결과보다 사용자의 현재 현실(baseline).

에이전트 범위 규칙: 브리프 5번과 PRD 수용 기준에 없는 기능·화면·설정을 추가하지 말 것. 인접 기능은 `plan.md`의 "막힌 것 / 결정이 필요한 것"에 제안으로만 남김. 있으면 좋은 작업은 앞에 `~`를 붙여 마지막에 두고 시간이 모자라면 먼저 뺌(Shape Up nice-to-haves). 기간 초과가 예상되면 연장 요청보다 줄일 범위 후보를 먼저 제시.

## 요구사항 품질

PRD 수용 기준과 브리프 Must는 ISO/IEC/IEEE 29148:2018 5.2.5 "Characteristics of individual requirements"로 점검. 아래 특성 이름은 2차 출처로만 확인(근거와 한계).

| 특성 (미확인) | 점검 질문 |
| --- | --- |
| Necessary | 빼면 Must나 사용자 문제에 빈틈이 생기나 |
| Appropriate | 문서 수준(브리프·PRD)에 맞고 불필요한 구현 방식을 강제하지 않나 |
| Unambiguous | 해석이 하나뿐인가 |
| Complete | 이 문장만으로 구현·판정에 필요한 정보가 있나 |
| Singular | 요구가 하나만 들어 있나("그리고", "또는"으로 묶지 않음) |
| Feasible | appetite와 기술 제약 안에서 가능한가 |
| Verifiable | 참/거짓으로 판정할 방법이 있나 |
| Correct | 브리프 1번 문제와 확인된 사용자 필요를 반영하나 |
| Conforming | 합의된 틀(PRD 슬롯, 아래 문형)을 따르나 |

| EARS 유형 (Mavin et al. 2009) | 문형 | 예 |
| --- | --- | --- |
| Ubiquitous | <시스템>은 <응답>해야 함 | 앱은 모든 금액을 원 단위 정수로 저장해야 함 |
| Event-driven | <트리거>하면, <시스템>은 <응답>해야 함 | 주문이 접수되면, 시스템은 1분 안에 주문자에게 확인 메일을 보내야 함 |
| State-driven | <상태>인 동안, <시스템>은 <응답>해야 함 | 오프라인인 동안, 앱은 입력을 기기에 보관하고 "연결 대기 중"을 표시해야 함 |
| Unwanted behaviour | <조건>이면, <시스템>은 <응답>해야 함 | 결제 승인이 30초 안에 오지 않으면, 시스템은 주문을 "확인 필요"로 표시하고 다시 시도 버튼을 보여야 함 |
| Optional feature | <기능이 포함된 경우>, <시스템>은 <응답>해야 함 | 관리자 모드가 켜진 배포에서는, 시스템은 감사 로그 화면을 제공해야 함 |
| Complex | <상태>인 동안 <트리거>하면, <시스템>은 <응답>해야 함 | 업로드 중인 동안 취소를 누르면, 앱은 전송을 멈추고 받은 조각을 삭제해야 함 |

- EARS 문장 하나를 PRD 6번 체크박스 하나에 대응시키고, Unwanted behaviour 문형으로 PRD 5번 엣지 케이스 표의 기대 동작을 씀.
- `implementability-review`가 판정 불가 표현으로 지적한 문장은 위 문형으로 다시 쓰고 시간·개수·한도 수치를 채움.

## 출시 기준과 측정

- 지표는 Goals-Signals-Metrics 순서로 정함(Rodden et al. 2010). 목표는 사용자 경험 측면에서 이루려는 것, 신호는 목표 달성·실패가 드러나는 행동·태도와 그 데이터 출처, 지표는 시간에 따라 추적할 수치. 목표 단계에서는 측정 가능 여부를 걱정하지 말 것(같은 논문).
- HEART(Happiness, Engagement, Adoption, Retention, Task success)는 목표를 끌어내는 점검표로 씀. 모든 범주를 쓸 필요는 없고 범주마다 포함·제외를 명시적으로 결정. 업무용 도구에서는 Engagement가 의미 없을 수 있어 Task success·Happiness를 우선(같은 논문).
- 신호는 목표와 무관한 이유로 움직이지 않는 것을 고름. 과업 포기·되돌리기 같은 실패 신호가 성공 신호보다 잡기 쉬울 때가 있음. 원시 개수는 사용자 증가에 따라 늘므로 비율·사용자당 평균으로 정규화(같은 논문).

| HEART 범주 | 신호 예 | 지표 예 |
| --- | --- | --- |
| Task success | 신청 완료, 오류 화면 도달 | 시작 대비 완료율, 완료까지 걸린 시간의 중앙값 |
| Adoption | 첫 사용 | 기간 내 신규 사용자 중 핵심 기능을 처음 쓴 비율 |
| Retention | 다시 사용 | n주 뒤 재사용 비율 |
| Engagement | 사용 빈도 | 사용자당 주간 사용 횟수 |
| Happiness | 설문 응답, 불만 문의 | 만족도 평균, 사용자당 불만 문의 비율 |

- 출시 기준(브리프 8번 기본 항목, 키트 규칙): Must 전부 동작, `GOLDEN-SCENARIOS` 사람 확인 날짜 기록, `make check` 통과, 9번 지표의 이벤트가 실제로 수집됨, 문제 발생 시 되돌리거나 끄는 방법. 지표가 수집되지 않으면 출시 후 판단이 불가능하므로 출시 기준에 넣음. 공개 웹 페이지가 있으면 [SEO_GEO](SEO_GEO.md) 검증 표, 운영 기반은 [운영](OPERATIONS.md) 출시 전 표를 함께 확인.
- 출시 후 판단: 출시 전에 판단 날짜와 계속·수정·중단을 가를 기준값을 브리프 9번에 적음. 기준값은 출처 수치가 없으므로 현재 대안의 값(기준선)과 비교해 프로젝트가 정함. 문제를 얼마나 잘 푸는지 보여 주는 지표로 성과를 추적하고(GOV.UK Service Standard 10) 판단 결과는 `decisions.md`에 기록. PRD 3번 성공 지표는 브리프 9번 지표 중 해당 기능이 움직이는 것을 기능 수준으로 구체화한 값.

## 에이전트 운용 규칙

| 사용자가 정함 | 에이전트가 정하고 기록 |
| --- | --- |
| 대상 사용자와 문제 문장, 가설 결과 판정 | 질문지·테스트 시나리오 초안, 위험별 확인 방법 제안 |
| appetite, 연장, 중단·방향 전환 | EARS 문장화, 엣지 케이스 후보 목록 |
| Must, 하지 않을 것, 출시 여부 | 정렬·페이지 크기·재시도 같은 구현 세부(PRD 또는 `decisions.md`) |
| 수집할 개인정보, 비용이 드는 외부 서비스 | 측정 이벤트 이름과 수집 위치 |

- 근거 없이 채운 칸은 "가정:"으로 시작하고 확인 방법을 붙임. 확인되면 결과와 날짜로 바꿈.
- 새 프로젝트나 큰 기능(새 화면·새 엔티티·새 외부 연동 중 하나 이상, 키트 기준)은 구현 전에 `spec/PRODUCT-BRIEF.md`와 해당 PRD를 확인. 없거나 `spec-lint` 필수 슬롯이 비면 구현을 시작하지 말고 사용자에게 알린 뒤 작성할지 생략할지 결정을 받음. 생략하면 이유를 `decisions.md`에 기록. 버그 수정과 작은 변경은 대상 외.
- 범위·기간이 바뀌면 브리프를 고치고 `decisions.md`에 날짜와 이유를 남김. 브리프 10번 PRD 목록을 최신으로 유지. 사용자 확인이 없는 상태를 "검증됨"으로 보고하지 말 것(에이전트 리뷰와 자동 검사는 사용자 확인을 대신하지 못함).

## 검증 방법

| 확인 | 방법 | 통과 기준 |
| --- | --- | --- |
| 브리프 형식 | `spec-lint` | 필수 슬롯 채움, `<<<` 없음 |
| 문제 문장 | 브리프 1번에서 기능·화면·기술 이름 찾기 | 해결책 없이 사용자·상황·막히는 점 포함 |
| 위험 | 브리프 3번 표 | 4행 모두 확인 방법·반증 기준·결과(미확인 포함) |
| 범위 | 브리프 5·6번과 각 PRD 4번 대조 | Must 노력 60% 이하, PRD 비목표가 브리프 6번을 포함 |
| 요구사항 | `implementability-review` | PASS, 수용 기준이 EARS 문형 |
| 측정 | 출시 전 테스트 환경에서 이벤트 발생 | 9번 지표 값이 실제로 기록됨 |

## 근거와 한계

확인일 2026-10-01.

- GOV.UK Service Manual: [Agile delivery](https://www.gov.uk/service-manual/agile-delivery), [How the discovery phase works](https://www.gov.uk/service-manual/agile-delivery/how-the-discovery-phase-works)(2021-06-21 갱신: 4~8주, discovery에서 만들지 않음, 중단도 실패로 보지 않음), [alpha](https://www.gov.uk/service-manual/agile-delivery/how-the-alpha-phase-works)(6~8주, 버릴 코드), [beta](https://www.gov.uk/service-manual/agile-delivery/how-the-beta-phase-works), [live](https://www.gov.uk/service-manual/agile-delivery/how-the-live-phase-works). [Service Standard](https://www.gov.uk/service-manual/service-standard) 14항목 중 1 Understand users and their needs, 2 Solve a whole problem for users, 10 Define what success looks like and publish performance data를 사용.
- [ISO 9241-210:2019](https://www.iso.org/standard/77520.html) Human-centred design for interactive systems, Ed.2, 2019-07. iso.org가 자동 접속을 차단해 제목·판·발행월·적용 범위는 검색 결과 요약으로만 확인. 인간 중심 설계 원칙의 이름과 문장은 미확인이라 본문 규칙의 근거로 쓰지 않음.
- Christensen, Hall, Dillon & Duncan (2016), Know Your Customers' "Jobs to Be Done", Harvard Business Review 2016년 9월호, 리프린트 R1609D([hbr.org](https://hbr.org/2016/09/know-your-customers-jobs-to-be-done)). job 정의와 원칙은 리프린트 본문으로 확인. 권·호·쪽수는 Crossref 미등재로 미확인.
- Cagan (2017-12-04), [The Four Big Risks](https://www.svpg.com/four-big-risks/), SVPG. Cagan (2017), Inspired: How to Create Tech Products Customers Love, 2nd ed., Wiley, ISBN 978-1-119-38750-3. Ries (2011), The Lean Startup, Crown Business, ISBN 978-0-307-88789-4. [Principles](https://theleanstartup.com/principles)(Build-Measure-Learn, validated learning). MVP 정의는 Ries (2009-08-03), [Minimum Viable Product: a guide](http://www.startuplessonslearned.com/2009/08/minimum-viable-product-guide.html). 책 본문의 MVP 문장은 미확인.
- Singer (2019), [Shape Up: Stop Running in Circles and Ship Work that Matters](https://basecamp.com/shapeup), Basecamp. Principles of Shaping, Set Boundaries, Risks and Rabbit Holes, Write the Pitch, The Betting Table, Decide When to Stop, Glossary 장을 원문으로 확인.
- Agile Business Consortium, [What is MoSCoW prioritization?](https://www.agilebusiness.org/resource/what-is-moscow-prioritization/)(DSDM): MUST 정의, 취소 질문, Must 노력 60% 이하, Could 약 20%.
- NN/g: Rosala & Pernice (2023-09-17), [User Interviews 101](https://www.nngroup.com/articles/user-interviews/). Nielsen (2000-03-18), [Why You Only Need to Test with 5 Users](https://www.nngroup.com/articles/why-you-only-need-to-test-with-5-users/). Fitzpatrick, The Mom Test, CreateSpace, ISBN 978-1-4921-8074-6(Open Library 기준 2014, 흔히 2013으로 인용되어 연도 미확인). [momtestbook.com](https://www.momtestbook.com/)에는 책 소개만 있어 핵심 규칙 문구는 미확인이며 본문 규칙의 근거로 쓰지 않음.
- ISO/IEC/IEEE 29148:2018, Systems and software engineering, Life cycle processes, Requirements engineering, 2nd ed., 2018-11. IEC 미리보기 PDF로 판·발행월과 5.2.5 절 제목만 확인. 9개 특성 이름은 2차 출처로만 확인(미확인)했고 정의 문장은 표준 원문과 대조할 것.
- Mavin, Wilkinson, Harwood & Novak (2009), Easy Approach to Requirements Syntax (EARS), 17th IEEE RE, 317–322, doi:10.1109/RE.2009.9. 문형은 [alistairmavin.com/ears](https://alistairmavin.com/ears/)에서 확인.
- Rodden, Hutchinson & Fu (2010), Measuring the user experience on a large scale: user-centered metrics for web applications, CHI '10, 2395–2398, doi:10.1145/1753326.1753687. HEART와 Goals-Signals-Metrics는 논문 본문으로 확인.
- Kano, Seraku, Takahashi & Tsuji (1984), 魅力的品質と当り前品質, 品質 14(2), 147–156, doi:10.20684/quality.14.2_147. J-STAGE 서지만 확인했고 본문은 미확인. McBride (2018-01-05), [RICE: Simple prioritization for product managers](https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/), Intercom 블로그.

오용 주의:
- Kano의 당연 품질·매력 품질 구분은 Must 선별에 참고할 개념으로 알려져 있으나 본문 미확인이라 키트 규칙에 쓰지 않음. RICE는 기업 블로그의 실무 기법으로 동료심사 근거가 없어 키트 기본값에서 제외하며, 쓰면 Confidence가 주관 추정값이라는 점을 함께 기록할 것.
- Nielsen의 5명은 정성 사용성 테스트의 문제 발견 기준이며 수요·지표 판단에 쓰지 말 것. 85%는 사용자 한 명이 문제의 31%를 찾는다는 가정의 모형 계산값.
- DSDM 60%·20%는 팀 단위 권장값, Shape Up 6주 주기는 Basecamp 조직 관행, GOV.UK 단계 기간은 정부 서비스 팀 기준이라 1인 프로젝트에 그대로 강제하지 말 것. 4대 위험의 확인 방법 열, 인터뷰 질문 예, 출시 기준 기본 항목, 큰 기능의 정의, 사용자·에이전트 결정 구분은 키트 규칙이며 출처가 정한 것이 아님.
