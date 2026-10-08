# AI 기능 사용자 경험·품질 기준

제품에 LLM·생성형 AI 기능(챗봇, 요약, 생성, 추천, 에이전트형 자동화)이 있을 때 설계·리뷰·평가에 적용. AI 기능이 없는 제품, 개발 과정에서만 AI를 쓰는 프로젝트는 적용 제외.
프롬프트 인젝션·출력 처리·도구 권한·요청 한도는 [보안](SECURITY.md) LLM 기능 절, 외부 LLM API 위탁·국외 이전·입력의 학습 활용·자동화된 결정은 [개인정보·법적 고지](PRIVACY_LEGAL.md), 상태·응답 시간·오류 화면은 [UX 설계](UX_DESIGN.md), 문구는 [제품 문구](UI_COPY.md), 상태 메시지 낭독은 [접근성](ACCESSIBILITY.md), 비용 상한은 [운영](OPERATIONS.md), 가치 위험과 지표는 [기획](PRODUCT_PLANNING.md), AI 생성 이미지는 [시각 에셋](VISUAL_ASSETS.md)이 맡으며 여기서는 중복 서술하지 않음.
프로젝트가 정한 예외·목표값은 `decisions.md`에 날짜와 이유를 남길 것.

## 쓸지 판단

- PRD에 AI 없이 푸는 방법(규칙, 검색, 필터, 템플릿)과 비교해 AI가 줄이는 일을 적을 것. 생성형 AI는 모든 상황의 해법이 될 수 없으며 시간 절약·소통·창작처럼 분명한 가치가 있을 때만 제공(Apple HIG). 사용자 필요와 AI 강점이 겹치는 지점을 찾는 것이 출발점(PAIR User Needs).
- AI 사용 자체를 가치 근거로 적지 말 것. 가치 가설은 PRODUCT_PLANNING 위험 먼저 절의 가치 행으로 확인.
- AI가 꺼져 있거나 공급자 장애일 때도 핵심 과업을 끝낼 수 있는 비AI 경로를 가능한 한 제공(Apple HIG non-AI fallback).

| 선택 | 맞는 작업 (PAIR User Needs) | 기본 동작 |
| --- | --- | --- |
| 자동화: AI가 대신 처리 | 지루·반복·위험하거나 사용자가 할 지식·능력이 없는 작업 | 적용 후 결과 확인과 되돌리기 제공 |
| 증강: AI가 제안, 사람이 결정 | 사용자가 즐기는 작업, 본인 책임이 중요한 작업, 판돈이 큰 작업 | 초안·후보를 보여 주고 사용자가 채택 |

| 실패 비용 (키트 규칙) | 예 | 실행 방식 |
| --- | --- | --- |
| 낮음: 즉시 되돌릴 수 있음 | 문장 다듬기, 태그·분류 추천 | 바로 적용, 되돌리기 1동작 |
| 중간: 사용자 업무에 영향 | 메일 초안, 회의 요약, 데이터 정리 | 사람이 확인한 뒤 저장·발송 |
| 높음: 되돌릴 수 없거나 돈·권리·타인에 영향 | 삭제, 결제, 외부 발송, 채용·대출·평가 판단 | 자동 실행 금지, 실행 직전 내용 표시와 사람 승인(Apple HIG Inputs, SECURITY LLM06) |

권리·의무에 영향을 주는 판단은 PRIVACY_LEGAL의 자동화된 결정 행과 아래 고영향 AI 확인을 함께 볼 것.

## 기대치 설정 (Initially)

- AI 기능 진입점에 할 수 있는 일과 못 하는 일(예: 최신 정보, 정확한 계산, 법률·의료 판단)을 표시. 첫 사용 때는 기능을 쓰는 시점에 짧게 소개하고 긴 기능 목록 온보딩은 피할 것(PAIR Mental Models, Onboard in stages).
- 틀릴 수 있다는 고지는 결과 가까이에 두고 무엇을 확인할지(날짜, 수치, 인명, 인용) 함께 적음(Apple HIG hallucinations). 사실 정보 요청은 모델이 검증된 최신 정보에 접근할 때만 받고, 오답이 해를 끼칠 상황에는 생성 결과를 쓰지 말 것(Apple HIG).
- "AI가 알아서" 같은 과장 대신 사용자가 얻는 이득을 설명(PAIR). 사람 이름·사진을 붙여 상담원처럼 꾸미지 말고 AI임을 밝힘(Apple HIG Transparency, PAIR). 문구 작성은 UI_COPY.
- 빈 입력창에는 예시 요청을 텍스트 대신 누를 수 있는 버튼으로 제공(NN/g 10 Guidelines 4). 예시는 사람이 고른 것으로, 최근 활동에서 자동으로 뽑지 말 것(Neusesser & Moran 2025). placeholder를 예시 대신 쓰지 않는 규칙은 UX_DESIGN 폼 절.

## 상호작용 중 (During interaction)

- 첫 피드백 시점과 대기 구간 표시는 UX_DESIGN 응답 시간 표를 따름. 생성은 대개 1초를 넘으므로 스트리밍 표시나 실제 단계 문구("노트의 핵심 주제를 요약하는 중")를 쓰고 "처리 중…" 같은 막연한 문구는 피할 것(Apple HIG Outputs).
- 생성 중에는 중단 버튼을 항상 표시. 누르면 서버 요청까지 취소하고 받은 부분은 남겨 둠(키트 규칙). 비용 상한과 함께 확인.
- 스트리밍 중 스크롤을 응답 끝으로 끌고 가지 말고 새 메시지 시작 위치를 유지(NN/g 10 Guidelines 7). 토큰마다 라이브 영역을 갱신하지 말고 완료·오류 때 한 번 알림(ACCESSIBILITY 4.1.3의 키트 적용).
- 문서·검색 기반 답변은 문단 단위로 출처(문서명, 위치, 링크)를 붙이고, 출처가 없는 답변은 그 사실을 표시. 링크는 실제 검색 결과에서만 만들고 모델이 생성한 URL은 표시하지 말 것(키트 규칙, PAIR Articulate data sources).
- 불확실성: 숫자 확률은 기본값에서 제외(PAIR: 확률 이해를 가정해 혼란 유발). 범주(높음·중간·낮음)는 범주마다 사용자가 할 행동과 함께, 확신이 낮으면 여러 후보를 제시(PAIR N-best). 표시가 실제로 판단을 돕는지 사용자 테스트로 확인할 것.
- 요청이 모호하면 추측해 길게 생성하기보다 되묻거나 범위를 줄임(G10). 현재 화면의 문서·선택 영역을 기본 입력으로 쓰되 무엇을 모델에 보냈는지 표시(G4, 키트 규칙).
- 사람을 묘사하는 생성은 성별·관계·문화 속성을 추측하지 말고 필요한 정보를 물어볼 것. 다양한 사용자 입력으로 고정관념 출력을 테스트(Apple HIG inclusive, G6).

## 틀렸을 때 (When wrong)

- 결과 옆에 편집, 되돌리기, 다시 생성, 조정(짧게·길게) 컨트롤을 둠(Apple HIG Outputs). 사용자는 줄이기·늘리기를 반복하며 하나의 결과를 다듬는 경향이 있으므로 일부만 선택해 다시 생성하거나 직접 편집할 수 있게 할 것(Gibbons et al. 2023, accordion editing).
- 다시 생성해도 이전 결과를 지우지 말고 버전 전환(1/3)으로 남김. AI가 바꾼 문서·데이터는 한 번에 원래 상태로 되돌릴 수 있어야 함(키트 규칙). 수정이 반영되면 반영됐다는 신호를 보여 줄 것(Apple HIG).
- 제안은 닫기·무시 1동작, 닫은 제안을 같은 맥락에서 반복 노출하지 말 것(G8).
- 거절·차단 결과는 이유의 범주와 다음에 될 만한 요청 예시를 함께 안내(Apple HIG). 거절, 모델 장애, 한도 초과, 시간 초과를 구분해 표시하고 원인을 모르면 추측하지 말 것(UI_COPY).
- 실패해도 입력한 요청과 첨부를 보존하고 다시 시도를 1동작으로 제공. 오류 화면 일반 규칙은 UX_DESIGN.
- AI가 풀지 못할 때 사용자가 직접 처리하는 수동 경로와 그때 필요한 상황 정보를 제공(PAIR Errors: let the user take over). 상담형 챗봇은 사람 문의 경로를 화면 안에 둠.
- "왜 이 결과인가"를 열어 볼 수 있게 사용한 입력, 출처, 개인화 신호를 보여 줌(G11). 판돈이 큰 화면일수록 설명을 자세히(PAIR Explainability).

## 사용자 통제와 피드백

- 결과는 편집 가능한 형태로 주고, 복사·저장·공유를 지원(NN/g 10 Guidelines 9).
- 좋아요·싫어요는 수집한 피드백을 누가 언제 보고 어디에 쓸지(평가 세트 추가, 프롬프트 수정) 정해져 있을 때만 둠(키트 규칙). 피드백은 자발적으로, 흐름을 막지 않는 위치에(Apple HIG). 반영 시점을 알리거나 즉시 반영(PAIR Feedback + Control). 피드백에 입력·출력 원문이 담기면 PRIVACY_LEGAL의 자유 입력 행으로 관리.
- 개인화·대화 기억은 무엇을 기억하는지, 개인 단위인지 전체 사용자 단위인지, 삭제·초기화 방법을 표시하고 끌 수 있게 할 것(G12·G13·G17, PAIR Scope·Reach·Removal).
- 서버 전송 여부, 보관, 학습 사용 여부의 화면 고지(Apple HIG Privacy)와 법적 고지·동의는 PRIVACY_LEGAL을 따름.

### 생성 기능 화면 패턴

생성 서비스 실무 기준(사례 D19). 근거는 Zamfirescu-Pereira et al. 2023(비전문가는 프롬프트 작성에 실패), Subramonyam et al. 2024(원하는 결과를 말로 구상하기 어려움), Chernev et al. 2015(선택 과부하), Johnson & Goldstein 2003(기본값 효과).
- 자유 프롬프트를 주 입력으로 두지 말 것. 이미 아는 데이터(앞 단계 입력, 저장된 브랜드)로 미리 채우고 "가져옴"을 표시하며 수정 가능하게.
- 비싼 생성 전에 무료로 확인할 수 있는 구성안·개요 단계를 둠. 후보는 적게(실무 기본 3개 이하, 개수 근거는 없음) 두고 후보 사이의 차이 축을 라벨로.
- 결과는 "AI 초안"으로 표시하고 기존 결과를 자동으로 덮어쓰지 않음. 부분 수정 요청은 선택한 요소 범위로 한정하고 요청하지 않은 색·회전·배치를 바꾸지 않음. 다시 그리기는 별도 생성으로 분리.
- 확인창은 비용 차감이나 결과 교체가 일어나는 지점 한 곳에만. 보기만 하는 이동에는 두지 않음.

## 시간이 지나며 (Over time)

- 모델, 시스템 프롬프트, 검색 설정, 샘플링 파라미터 변경은 코드 변경으로 취급하고 품질 평가 절의 평가 세트를 다시 돌림(Apple HIG Continuous improvement: 기반 모델 교체 시 재테스트·프롬프트 조정).
- 모델은 별칭 대신 버전이 고정된 id로 호출하고 공급자의 폐기 일정을 `decisions.md`에 기록(키트 규칙). 모델 호출부를 화면 코드와 분리해 교체할 수 있게 둠(Apple HIG).
- 응답 형식·기능 범위가 눈에 띄게 바뀌면 사용자에게 알리고(G18), 한 번에 큰 동작 변화를 주지 말 것(G14).

## 18개 지침 점검표

AI 화면 리뷰는 Amershi et al.(2019) 지침 행마다 통과·위반·해당 없음을 기록. 위반을 유지하면 이유를 `decisions.md`에 남길 것.

| 단계 | 지침 | 화면에서 확인할 것 |
| --- | --- | --- |
| Initially | G1 Make clear what the system can do | 진입점에 할 수 있는 일·못 하는 일과 예시 요청 버튼 |
| Initially | G2 Make clear how well the system can do what it can do | 결과 근처의 오류 가능성 고지와 확인할 항목 |
| During interaction | G3 Time services based on context | 입력·작업 중에 제안 팝업이 끼어들지 않음 |
| During interaction | G4 Show contextually relevant information | 현재 문서·선택 영역을 기본 입력으로 쓰고 보낸 맥락을 표시 |
| During interaction | G5 Match relevant social norms | 존대·어조가 제품 문구 기준과 같음, 사람인 척하지 않음 |
| During interaction | G6 Mitigate social biases | 사람 묘사 생성에서 속성 추측 없음, 다양한 입력으로 테스트한 기록 |
| When wrong | G7 Support efficient invocation | 기능을 부르는 위치가 과업 화면 안에 있고 단축 경로 존재 |
| When wrong | G8 Support efficient dismissal | 제안 닫기 1동작, 닫은 제안 재노출 없음 |
| When wrong | G9 Support efficient correction | 편집·되돌리기·재생성·부분 재생성, 이전 버전 보존 |
| When wrong | G10 Scope services when in doubt | 모호한 요청에 되묻기나 범위 축소 |
| When wrong | G11 Make clear why the system did what it did | 출처·사용한 입력·개인화 신호를 열어 볼 수 있음 |
| Over time | G12 Remember recent interactions | 이전 대화·결과를 다시 참조 가능, 기억 범위 표시 |
| Over time | G13 Learn from user behavior | 개인화가 무엇을 학습하는지 표시, 끄기 가능 |
| Over time | G14 Update and adapt cautiously | 모델 교체 뒤 평가 결과 비교, 큰 동작 변화 없음 |
| Over time | G15 Encourage granular feedback | 결과 단위 피드백, 수집 목적이 정해져 있음 |
| Over time | G16 Convey the consequences of user actions | 피드백·설정 변경이 이후 동작에 주는 영향 안내 |
| Over time | G17 Provide global controls | 설정에서 개인화·기억·데이터 사용을 일괄 제어 |
| Over time | G18 Notify users about changes | 기능 추가·변경 시 화면 안 공지 |

## AI 생성물 고지·표시

「인공지능 발전과 신뢰 기반 조성 등에 관한 기본법」(2026-01-22 시행) 제31조 투명성 확보 의무 요약. 의무 주체 해당 여부와 적용 예외는 법무 확인으로 넘김.

| 의무 | 근거 | 화면 구현 예 (과기정통부 안내 지침 보도자료) |
| --- | --- | --- |
| 사전 고지: 고영향·생성형 AI 기반으로 운용된다는 사실 | 법 제31조①, 영 제23조① | 이용약관·계약서 기재, 이용 화면 표시, 오프라인은 보기 쉬운 곳에 게시 |
| 생성물 표시: 생성형 AI가 만든 결과물이라는 사실 | 법 제31조②, 영 제23조② | 서비스 화면 안에서만 쓰이면 UI·로고 표시(챗봇은 이용 전 안내나 화면 내 로고). 내려받기·공유로 밖에 나가면 워터마크 같은 사람이 인식하는 방법, 또는 문구·음성 안내 1회 이상과 메타데이터 같은 기계 판독 방법 |
| 실제와 구분하기 어려운 음향·이미지·영상 | 법 제31조③, 영 제23조③ | 이용자가 명확히 인식하는 방식, 주된 이용자의 나이·신체적·사회적 조건 고려. 예술적·창의적 표현물은 감상을 해치지 않는 방식 허용 |

- 적용하지 않을 수 있는 경우(영 제23조④): 서비스명·화면 문구로 AI 활용이 명백함, 사업자 내부 업무용, 장관 고시 예외. 제31조① 고지 위반은 3천만원 이하 과태료(법 제43조①). 과기정통부는 1년 이상 계도기간 동안 사실조사·과태료를 유예한다고 발표(2026-01-21 보도자료).
- 의무 주체는 이용자에게 AI 제품·서비스를 직접 제공하는 사업자이며 외부 모델을 이용해 서비스를 만드는 인공지능이용사업자도 포함(법 제2조 제7호 나목). 국내 이용자 대상 해외 사업자도 포함되고, AI를 업무·창작 도구로만 쓰는 이용자는 제외(보도자료).
- 고영향 AI(법 제2조 제4호): 에너지 공급, 먹는물, 보건의료, 의료기기, 원자력, 범죄 수사의 생체인식 분석, 채용·대출 심사 등 권리·의무 판단, 교통, 공공 의사결정, 학생 평가 영역에서 생명·안전·기본권에 중대한 영향을 줄 우려가 있는 시스템. 이 영역이면 구현 전에 사용자에게 알리고 제33조 사전 검토와 제34조 책무(위험관리, 설명, 이용자 보호, 사람의 관리·감독, 문서 보관)를 법무와 확인.
- 표시 문구는 UI_COPY, 이미지 생성물 기록은 VISUAL_ASSETS. EU 이용자 대상 서비스는 EU AI Act 제50조(AI와 상호작용한다는 고지, 합성 콘텐츠의 기계 판독 표시)를 별도 검토.

## 품질 평가

- 평가 세트를 저장소(예: `eval/`)에 두고 입력, 기대 기준, 채점 방법을 함께 기록. 실제 과업 분포를 반영하고 빈 입력, 관련 없는 입력, 지나치게 긴 입력, 유해 입력, 사람도 판정이 갈리는 모호한 입력을 포함(Anthropic eval 가이드). 실제 사용자 입력은 비식별 처리 후 사용(PRIVACY_LEGAL).
- 출처가 정한 최소 개수는 없음. 키트 시작값은 기능당 30건이며, 사용자 신고나 리뷰에서 찾은 실패를 그때마다 추가(키트 규칙). 보안 인젝션 fixture(SECURITY)도 같은 실행에 묶을 수 있음.
- 모델·프롬프트·검색 설정 변경마다 실행하고 통과율과 실패 목록을 직전 결과와 비교해 PR이나 결과 인계에 남김. 유료 API를 호출하므로 `make check`에 넣을지는 프로젝트가 정하고, 넣지 않았으면 미실행으로 보고.
- 통과율 같은 수치 목표는 출처가 없으므로 프로젝트가 정해 `decisions.md`에 기록. 사람 확인 없이 품질을 "검증됨"으로 보고하지 말 것(PRODUCT_PLANNING 운용 규칙과 같음).

| 채점 방법 | 맞는 경우 | 주의 |
| --- | --- | --- |
| 코드 채점: 정확 일치, 스키마 검증, 필수·금지 문자열 | 분류, 추출, 구조화 출력, 형식 | 의미 품질은 판정하지 못함 |
| 사람 평가 | 사실성, 유용성, 어조 | 기준표와 예시 답을 먼저 정함. 1인 프로젝트는 모델명을 가린 쌍 비교로 기록 |
| LLM 심판 | 어조·기준 충족, 대량 비교 | 위치·장황함·자기 선호 편향(Zheng et al. 2023). 생성과 다른 모델 사용, 쌍 비교는 순서를 바꿔 두 번, 사람 평가 표본과의 일치율을 함께 기록 |

- 환각 점검 항목은 두 종류로 나눔(Huang et al. 2025): 사실과 어긋나거나 확인할 수 없는 내용(factuality), 지시·주어진 문서·자기 논리와 어긋나는 내용(faithfulness). 문서 기반 기능은 답 문장마다 출처가 있고 그 출처가 내용을 뒷받침하는지 확인.
- 출시 후 신호: 다시 생성 비율, 편집 후 채택 비율, 중단 비율, 싫어요 비율을 PRODUCT_PLANNING HEART의 Task success 신호로 사용.

## 운영·보안 연결

- 사용자별·일일 토큰 상한과 재시도 상한은 OPERATIONS 비용 절, 요청 레이트 리밋은 SECURITY. 한도에 도달하면 화면에 다시 쓸 수 있는 시점을 안내.
- 프롬프트·응답 로그는 개인정보가 섞일 수 있으므로 보존 기간은 PRIVACY_LEGAL, 로그 구조는 OPERATIONS 로그 절. 고위험 도구 실행 기록은 SECURITY 보안 이벤트 표.

## 검증

| 확인 | 방법 | 통과 기준 |
| --- | --- | --- |
| 18개 지침 | 점검표 행별 판정 | 전 행 판정, 위반은 사유 기록 |
| 기대치 | 첫 사용 화면 캡처 | 할 수 있는 일·한계·예시 요청 버튼이 보임 |
| 생성 중 | 긴 응답 요청 뒤 위로 스크롤하고 중단 | 스크롤 위치 유지, 서버 요청 취소, 부분 결과 남음 |
| 낭독 | VoiceOver 또는 NVDA로 생성 | 토큰 단위 낭독 없음, 완료 시 한 번 알림 |
| 실패 | 네트워크 차단, 한도 초과, 거절을 유도하는 입력 | 입력 보존, 원인별 안내, 다시 시도·수동 경로 |
| 수정 | 편집·되돌리기·재생성 반복 | 이전 버전으로 복구 가능 |
| 출처 | 문서 기반 답변 10건 표본 | 링크가 모두 열리고 내용이 답을 뒷받침 |
| 고지·표시 | 첫 사용 화면, 내려받은 파일·공유 결과 | 사전 고지, 화면 안 표시, 외부 반출물 표시 |
| 평가 세트 | 평가 명령 실행 | 결과 파일 저장, 직전 대비 비교, 목표값 기록 |

## 근거와 한계

확인일 2026-10-01.

- Amershi, Weld, Vorvoreanu, Fourney, Nushi, Collisson, Suh, Iqbal, Bennett, Inkpen, Teevan, Kikin-Gil & Horvitz (2019), Guidelines for Human-AI Interaction, CHI '19, 1–13, doi:10.1145/3290605.3300233 (Crossref 대조). 논문 PDF의 Table 1로 18개 지침 이름과 4단계 배정(Initially G1·G2, During interaction G3~G6, When wrong G7~G11, Over time G12~G18) 확인. 49명 실무자가 20개 제품으로 평가. [Microsoft HAX Toolkit Guidelines](https://www.microsoft.com/en-us/haxtoolkit/ai-guidelines/), [HAX Design Library](https://www.microsoft.com/en-us/haxtoolkit/library/).
- Google PAIR, [People + AI Guidebook](https://pair.withgoogle.com/guidebook/): User Needs + Defining Success(자동화·증강 판단), Data Collection + Evaluation, Mental Models, Explainability + Trust(신뢰 보정, 신뢰도 표시 방식, Scope·Reach·Removal), Feedback + Control, Errors + Graceful Failure 장을 원문으로 확인. 데이터 수집 장 본문은 읽지 않음.
- Apple, [Human Interface Guidelines: Generative AI](https://developer.apple.com/design/human-interface-guidelines/generative-ai) (2025-06-09 신설, 2026-06-08 갱신): Best practices, Transparency, Privacy, Inputs, Outputs, Continuous improvement 절.
- NN/g: Gibbons, Mugunthan & Nielsen (2023-09-24), [Accordion Editing and Apple Picking](https://www.nngroup.com/articles/accordion-editing-apple-picking/) (참가자 8명 정성 연구). Kenderova, Rosala & Kohler (2026-04-24), [10 Guidelines for Designing Your Site's AI Chatbots](https://www.nngroup.com/articles/ai-chatbots-design-guidelines/). Neusesser & Moran (2025-06-27), [Designing Use-Case Prompt Suggestions](https://www.nngroup.com/articles/designing-use-case-prompt-suggestions/).
- Zheng, Chiang, Sheng, Zhuang, Wu, Zhuang, Lin, Li, Li, Xing, Zhang, Gonzalez & Stoica (2023), Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena, Advances in Neural Information Processing Systems 36 (Datasets and Benchmarks), 46595–46623, doi:10.52202/075280-2020 (Crossref 대조), arXiv:2306.05685. GPT-4 심판과 사람 선호의 일치율 80% 이상, 위치·장황함·자기 선호 편향과 제한된 추론 능력 보고.
- Huang et al. (2025), A Survey on Hallucination in Large Language Models: Principles, Taxonomy, Challenges, and Open Questions, ACM Transactions on Information Systems 43(2), 1–55, doi:10.1145/3703155 (Crossref 대조), arXiv:2311.05232에서 분류 확인.
- Anthropic, [Define success criteria and build evaluations](https://platform.claude.com/docs/en/test-and-evaluate/develop-tests): 과업 특화, 자동 채점 우선, 엣지 케이스 목록, LLM 채점은 생성과 다른 모델 사용.
- 「인공지능 발전과 신뢰 기반 조성 등에 관한 기본법」 법률 제20676호(2025-01-21 제정, 2026-01-22 시행), 현행 법률 제21311호(2026-01-20 일부개정) 및 같은 법 시행령 대통령령 제36053호(2026-01-21 제정), 현행 제36580호, [국가법령정보센터](https://www.law.go.kr/법령/인공지능발전과신뢰기반조성등에관한기본법) 원문으로 제2조, 제31조, 제33조, 제34조, 제43조, 영 제23조 확인. 과기정통부 보도자료 「인공지능 투명성 확보 안내 지침(가이드라인)」 공개(2026-01-21, [정책브리핑](https://www.korea.kr/briefing/pressReleaseView.do?newsId=156740669) 첨부 원문).
- EU AI Act, Regulation (EU) 2024/1689 제50조. EUR-Lex 원문은 접속에 실패해 [artificialintelligenceact.eu](https://artificialintelligenceact.eu/article/50/)의 조문 전재로만 확인(2026-08-02 적용).

오용 주의와 미확인 사항:
- 18개 지침은 LLM 이전(2019) 제품으로 검증한 휴리스틱이며 지침 준수가 품질을 보장한다는 정량 근거는 없음. NN/g 기사는 소규모 정성 연구라 비율·효과 크기로 쓰지 말 것.
- Zheng et al.의 80% 일치율은 MT-Bench·Chatbot Arena의 영어 대화 기준이며 한국어·특정 도메인 과업에 그대로 적용하지 말 것.
- 「인공지능 투명성 확보 안내 지침」 본문은 읽지 않았고 보도자료로만 확인(미확인). 화면 구현 예는 보도자료 문장 범위에서만 씀. 고영향 AI 판단 가이드라인 본문과 "최종 결정에 사람이 개입하면 고영향에서 제외"라는 설명은 정책브리핑 기사로만 접해 근거로 쓰지 않음(미확인). 계도기간 종료 시점, 장관 고시 예외 목록, EU AI Act 후속 개정(digital omnibus)에 따른 적용일 변경 여부도 미확인.
- 실패 비용 3단계, 중단 버튼 동작, 버전 보존, 모델 버전 고정, 평가 세트 30건, 피드백 버튼 조건은 키트 규칙이며 출처가 정한 값이 아님. 법 조문 요약은 확인 기록이며 법적 판정은 법무 확인을 거칠 것.
