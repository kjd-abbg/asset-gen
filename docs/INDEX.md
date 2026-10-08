# 작업별 문서 목록

작업을 시작하기 전에 아래 표에서 해당하는 행을 모두 찾고, 그 행의 문서를 읽은 뒤 착수할 것. 여러 행에 해당하면 모든 행의 문서를 합쳐 적용.
여기 나온 문서는 키트 관리 가이드라 `--update`로 갱신됨. 프로젝트에서 다르게 정한 값은 `decisions.md`가 우선이며, 문서끼리 어긋나 보이면 임의로 고르지 말고 사용자에게 알릴 것.
UI가 없는 저장소(API·라이브러리·CLI)는 화면·디자인 행을, 메일·AI 기능·공개 페이지가 없는 제품은 해당 행을 건너뜀.

## 작업 유형 → 읽을 문서

| 작업 | 반드시 | 해당하면 |
| --- | --- | --- |
| 새 프로젝트 시작, 큰 기능 추가 | [PRODUCT_PLANNING](PRODUCT_PLANNING.md) | 화면이 있으면 [UI_QUICKSTART](UI_QUICKSTART.md)(디자인 브리프부터), 출시가 있으면 [OPERATIONS](OPERATIONS.md) |
| 화면·컴포넌트 구현 | [UI_QUICKSTART](UI_QUICKSTART.md), 거기서 가리키는 절 | 전환·로딩·캐시가 바뀌면 [UI_VALIDATION](UI_VALIDATION.md), 아이콘·이미지가 있으면 [VISUAL_ASSETS](VISUAL_ASSETS.md) |
| 폼·가입·로그인·계정 | [UX_DESIGN](UX_DESIGN.md), [ACCESSIBILITY](ACCESSIBILITY.md), [SECURITY](SECURITY.md), [PRIVACY_LEGAL](PRIVACY_LEGAL.md) | 인증·재설정 메일이 있으면 [EMAIL_DELIVERY](EMAIL_DELIVERY.md) |
| 디자인 시스템 정하기·바꾸기 (`DESIGN.md`) | [DESIGN_SYSTEM](DESIGN_SYSTEM.md), [DESIGN_TOKENS](DESIGN_TOKENS.md) | 강조색 대비는 [ACCESSIBILITY](ACCESSIBILITY.md) |
| 색·글꼴·간격·테마·모션 | [DESIGN_TOKENS](DESIGN_TOKENS.md), [ACCESSIBILITY](ACCESSIBILITY.md) | 값을 바꾸면 [DESIGN_SYSTEM](DESIGN_SYSTEM.md) 순서로 `DESIGN.md`부터, 모션 검증은 [UI_VALIDATION](UI_VALIDATION.md) |
| 페이지 레이아웃·홈·랜딩·내비게이션 | [UI_QUICKSTART](UI_QUICKSTART.md), [VISUAL_DESIGN](VISUAL_DESIGN.md) 해당 절 | 공개 페이지면 [SEO_GEO](SEO_GEO.md), 사진이 있으면 [VISUAL_ASSETS](VISUAL_ASSETS.md) |
| 회사·기관 소개 사이트 | [UI_QUICKSTART](UI_QUICKSTART.md), [VISUAL_DESIGN](VISUAL_DESIGN.md) 회사 사이트 절, [SEO_GEO](SEO_GEO.md) | 문의 폼이 있으면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md), 주문·결제가 있으면 PRIVACY_LEGAL 전자상거래 절 |
| 관리자 화면·표·차트·대시보드·필터 | [UI_QUICKSTART](UI_QUICKSTART.md), [VISUAL_DESIGN](VISUAL_DESIGN.md) 관리자 레이아웃·데이터 화면 절, [UX_DESIGN](UX_DESIGN.md) 상태 설계 | 권한별 데이터면 [SECURITY](SECURITY.md) |
| 디자인 검수, 디자인 근거 찾기·추가 | [DESIGN_REVIEW](DESIGN_REVIEW.md), [DESIGN_LIBRARY](DESIGN_LIBRARY.md) | |
| 로고·파비콘·앱 아이콘 | [LOGO_DESIGN](LOGO_DESIGN.md) | 팔레트를 파생하면 [DESIGN_TOKENS](DESIGN_TOKENS.md) |
| UI 아이콘·사진·일러스트·공유 이미지 | [VISUAL_ASSETS](VISUAL_ASSETS.md) | 사람이 나오거나 사용자 업로드면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md) |
| 사용자에게 보이는 문구 | [UI_COPY](UI_COPY.md) | 오류·빈 상태면 [UX_DESIGN](UX_DESIGN.md) |
| 랜딩·소개·글 등 공개 페이지 | [SEO_GEO](SEO_GEO.md), [VISUAL_ASSETS](VISUAL_ASSETS.md) | 분석 도구를 넣으면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md) |
| API·서버 로직·데이터 저장 | [SECURITY](SECURITY.md) | 개인정보 필드가 있으면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md), 스키마 변경이면 [OPERATIONS](OPERATIONS.md) 배포와 롤백 |
| 개인정보 수집·동의·처리방침·탈퇴 | [PRIVACY_LEGAL](PRIVACY_LEGAL.md) | 동의 화면이면 [UX_DESIGN](UX_DESIGN.md), 저장·암호화는 [SECURITY](SECURITY.md) |
| 결제·구독·환불 | [PRIVACY_LEGAL](PRIVACY_LEGAL.md) 전자상거래 절, [UX_DESIGN](UX_DESIGN.md) 정직한 설계 절, [SECURITY](SECURITY.md) | 결제 메일이 있으면 [EMAIL_DELIVERY](EMAIL_DELIVERY.md) |
| 메일 발송 | [EMAIL_DELIVERY](EMAIL_DELIVERY.md) | 광고·뉴스레터면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md) 광고성 정보 절 |
| LLM·생성형 AI 기능 | [AI_FEATURES](AI_FEATURES.md), [SECURITY](SECURITY.md) LLM 기능 절 | 외부 모델 API면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md) 위탁·국외 이전, 생성 이미지면 [VISUAL_ASSETS](VISUAL_ASSETS.md) |
| 새 의존성·외부 SDK 추가 | [SECURITY](SECURITY.md) 의존성과 공급망 절 | 데이터가 외부로 나가면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md) |
| 배포·환경 설정·감시·백업 | [OPERATIONS](OPERATIONS.md) | 비밀값은 [SECURITY](SECURITY.md), 스테이징 비노출은 [SEO_GEO](SEO_GEO.md) |
| 장애·보안 사고·유출 의심 | [OPERATIONS](OPERATIONS.md) 장애 대응 절 | 개인정보가 얽히면 [PRIVACY_LEGAL](PRIVACY_LEGAL.md) 유출 대응 절을 즉시 |
| 출시 직전 점검 | [PRODUCT_PLANNING](PRODUCT_PLANNING.md) 출시 기준, [OPERATIONS](OPERATIONS.md) 출시 전 표 | 각 문서의 검증 절, 공개 페이지는 [SEO_GEO](SEO_GEO.md) 검증 표 |

## 문서별 범위

| 문서 | 맡는 것 |
| --- | --- |
| [PRODUCT_PLANNING](PRODUCT_PLANNING.md) | 문제 검증, 위험 확인, 범위·기간 고정, PRD 연결, 출시 기준과 측정 |
| [UI_QUICKSTART](UI_QUICKSTART.md) | 화면 작업의 시작점: 읽을 절, 기본값, 반드시 지킬 것, 절차, 사람이 해야 하는 일 |
| [UX_DESIGN](UX_DESIGN.md) | 화면 리뷰 기준, 상태 설계, 응답 시간, 폼·오류, 정보 구조, 다크 패턴 금지 |
| [VISUAL_DESIGN](VISUAL_DESIGN.md) | 레이아웃·그리드, 위계·훑어보기, 첫 화면, 첫인상·복잡도·관례, 신뢰, 색 사용, 읽기 타이포, 이미지·캐러셀, 내비게이션·IA, 모바일, 목록, 데이터 화면, 체감 성능 |
| [DESIGN_SYSTEM](DESIGN_SYSTEM.md) | getdesign.md에서 디자인 시스템 고르기·섞기·적응, `DESIGN.md` 작성 규칙, 강조색 후보 비교, 토큰 생성·센서 연결 |
| [DESIGN_REVIEW](DESIGN_REVIEW.md) | 디자인 절차(브리프→디자인 시스템→구현→렌더 리뷰), 리뷰표, 범용 AI 화면 징후, 기계 검사 계층 |
| [DESIGN_LIBRARY](DESIGN_LIBRARY.md) | 디자인 근거 논문·조사·실무 저작 목록과 확인 수준, 근거로 쓰지 않는 통념 |
| [ACCESSIBILITY](ACCESSIBILITY.md) | WCAG 2.2 AA 수치와 수동 검사, KWCAG·관련 법령 |
| [DESIGN_TOKENS](DESIGN_TOKENS.md) | 토큰 구조, 색·대비 쌍, 타이포·웹폰트, 간격·브레이크포인트, 모양·깊이, 모션 역할 |
| [UI_COPY](UI_COPY.md) | 화면 문구 편집 기준, 문단 너비와 줄바꿈 |
| [UI_VALIDATION](UI_VALIDATION.md) | headless 브라우저, 전환·캐시 회귀 검증 |
| [LOGO_DESIGN](LOGO_DESIGN.md) | 로고 형태·변형·SVG, 파생 아이콘 규격, 상표 확인 |
| [VISUAL_ASSETS](VISUAL_ASSETS.md) | UI 아이콘, 공유 미리보기, 이미지 형식·성능, 사진 권리 |
| [SEO_GEO](SEO_GEO.md) | 크롤링·색인, 메타·구조화 데이터, 검색엔진 등록, AI 크롤러 정책과 생성형 검색 |
| [SECURITY](SECURITY.md) | ASVS 기준선, 인증·세션·권한, 입출력, 비밀값, 공급망, 헤더, LLM 기능 보안 |
| [PRIVACY_LEGAL](PRIVACY_LEGAL.md) | 개인정보 수집·동의·처리방침·파기·위탁, 유출 신고, 광고성 정보, 전자상거래 표시 |
| [OPERATIONS](OPERATIONS.md) | 환경, 배포·롤백, 감시·알림, 로그, 백업·복구, 장애 대응, 비용 |
| [AI_FEATURES](AI_FEATURES.md) | AI 기능 적합성 판단, 기대치·오류·통제 설계, AI 생성물 표시, 품질 평가 |
| [EMAIL_DELIVERY](EMAIL_DELIVERY.md) | 메일 종류 구분, SPF·DKIM·DMARC, 대량 발송 요건, 바운스, 메일 내용과 테스트 |

새 가이드를 키트에 추가하면 이 두 표에 행을 넣고, `AGENTS.md`에는 포인터를 늘리지 않음.
