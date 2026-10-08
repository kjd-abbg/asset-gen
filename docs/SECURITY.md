# 제품 보안 기준선

웹·앱·API 제품 코드를 만들거나 고칠 때 따르는 보안 기준. 에이전트 자신의 권한과 저장소 비밀값 차단은 AGENTS §4와 `hooks/guard-secrets.sh`가 맡고, 이 문서는 사용자에게 배포되는 코드를 다룸.
키트 관리 문서로 신규 배치와 `--update`에 포함되며, 프로젝트별 수치(세션 만료, 레이트 리밋, 업데이트 기한)와 예외는 `decisions.md`에 기록.
개인정보 수집·보관·유출 신고는 [개인정보·법적 고지](PRIVACY_LEGAL.md), 로그 보존·알림·장애 대응은 [운영](OPERATIONS.md), 출시 기준은 [기획](PRODUCT_PLANNING.md)을 따를 것.

## 기준선과 위협 모델

- 기준은 OWASP ASVS 5.0.0. 키트 기본은 L1 전부, 계정·결제·개인정보를 다루면 V3(웹 프런트)·V6(인증)·V7(세션)·V8(권한)·V13(설정·비밀값)·V16(로그)의 L2까지(키트 규칙). ASVS는 L1을 출발점, L2를 대부분의 앱이 지향할 수준으로 설명함.
- 괄호의 숫자는 ASVS 5.0.0 요구사항 번호, 뒤의 L은 그 요구사항의 최소 레벨. OWASP Top 10:2025는 리뷰 때 빠뜨린 범주를 찾는 목록으로만 사용. 위협 모델은 기능 설계 시점에 아래 표 한 장으로 PRD 보안 절이나 `decisions.md`에 적고 진입점이 늘면 갱신.
- 한국: 「개인정보의 안전성 확보조치 기준」(개인정보보호위원회고시 제2026-9호, 2026. 7. 1. 시행)의 구현 항목은 비밀번호 일방향 암호화와 인증정보 송수신 암호화(제7조①), 주민등록번호·여권번호·계좌번호 등 암호화 저장(제7조②), 인터넷 구간 전송 암호화(제7조④), 반복 인증 실패 시 접근 제한(제5조⑥). 적용 판단과 접속기록 보관(제8조)은 PRIVACY_LEGAL.
- 행정안전부·KISA 「소프트웨어 개발보안 가이드」(2021. 11.)·「소프트웨어 보안약점 진단가이드」(2021)는 설계단계 20개, 구현단계 49개 항목(입력데이터 검증 및 표현, 보안기능, 시간 및 상태, 에러처리, 코드오류, 캡슐화, API 오용)으로 행정·공공기관 정보시스템 사업에 적용. 공공 발주면 이 기준의 진단 결과를 따로 준비하고, 민간은 대조용 참고.

| 항목 | 적을 것 | 예 |
| --- | --- | --- |
| 자산 | 잃거나 유출되면 피해가 나는 것 | 계정·세션, 개인정보, 결제 정보, 비밀값, 관리자 기능, 사용자 업로드 |
| 행위자 | 누가 무엇을 노리나 | 비로그인 외부인, 타인 데이터를 노리는 로그인 사용자, 탈취된 관리자 계정, 악성 의존성, LLM 입력에 지시를 심는 제3자 |
| 진입점 | 신뢰하지 않는 입력이 들어오는 곳 | 공개 API·폼, 웹훅, 파일 업로드, 서버가 가져오는 URL, LLM 프롬프트·도구 결과, 관리자 화면, CI·배포 |
| 신뢰 경계 | 검사가 일어나야 하는 경계 | 클라이언트↔서버, 서버↔외부 API, 서버↔DB, 앱↔LLM |

## 에이전트 금지 사항

다음은 사용자 승인과 `decisions.md` 기록 없이 하지 말 것. 테스트 통과만을 위한 비활성화는 요청하지도 말 것(키트 규칙).
- 보안 검사 끄기: CSRF 미들웨어, CSP, 인증 가드, TLS 인증서 검증(`rejectUnauthorized: false`, `verify=False`), 보안 린트 규칙, 취약점 스캔 단계, `--no-verify`.
- 인증 우회 플래그·테스트 백도어·기본 관리자 계정을 운영 빌드에 남기기(6.3.2 L1, 15.2.3 L2). 디버그 모드 운영 활성화(13.4.2 L2).
- 직접 만든 암호 알고리즘·해시·토큰 서명. 검증된 구현만 사용(11.2.1 L2), MD5 등 금지 해시는 어떤 암호 용도로도 금지(11.4.1 L1).
- `eval`·동적 코드 실행에 사용자 입력 넣기(1.3.2 L1), 프레임워크 기본 이스케이프를 sanitizer 없이 우회, 권한 검사 실패나 예외를 허용으로 처리(fail-open, 16.5.3 L2), 비밀값을 코드·클라이언트 번들·로그·URL에 넣기.

## 인증

| 항목 | 기준 | 근거 |
| --- | --- | --- |
| 최소 길이 | 비밀번호 단독 로그인 15자, 다른 요소와 함께 쓰는 비밀번호 10자 | NIST 15자·8자, ASVS 6.2.1 L1(8자, 15자 강력 권장), KISA 10자리 기준을 함께 충족하는 키트 값 |
| 최대 길이 | 64자 이상 허용, 잘라내거나 대소문자 변환 금지 | NIST 3.1.1.2, 6.2.8 L1, 6.2.9 L2 |
| 조합·변경 주기 | 문자 종류 조합 강제 금지, 주기적 변경 강제 금지(유출 증거가 있을 때만 변경 요구) | NIST 3.1.1.2, 6.2.5 L1, 6.2.10 L2 |
| 차단 목록 | 유출 비밀번호, 흔한 비밀번호(최소 상위 3,000개), 서비스명·아이디 파생어와 전체 문자열 대조 | NIST 3.1.1.2, 6.2.4 L1, 6.2.12 L2 |
| 입력 편의 | 붙여넣기, 비밀번호 관리자 자동 채움, 마스킹 해제 보기 허용 | NIST 3.1.1.2, 6.2.7 L1, ACCESSIBILITY 3.3.8 |
| 저장 | Argon2id m=19456(19 MiB), t=2, p=1 이상. 대안 scrypt N=2^17, r=8, p=1 / bcrypt cost 10 이상(입력 72바이트 한계) / FIPS 필요 시 PBKDF2-HMAC-SHA256 600,000회 | OWASP Password Storage, 11.4.2 L2, 고시 제7조① 일방향 암호화 |
| 실패 제한 | 계정 기준 연속 실패 100회 이하에서 차단·지연, IP만 기준으로 세지 말 것, 잠금이 타인 계정 잠그기에 악용되지 않게 설계 | NIST 3.2.2, OWASP Authentication, 6.1.1·6.3.1 L1 |
| 재설정·OTP | CSPRNG 생성, 1회 사용, 메일·SMS 코드 수명 최대 10분, 6자리 숫자 이상, 시도 횟수 제한 | 6.4.1 L1, 6.5.1·6.5.3·6.5.4·6.5.5·6.6.3 L2 |
| 금지 | 비밀번호 힌트·비밀 질문, 기본 계정, 현재 비밀번호 확인 없는 변경 | 6.4.2·6.3.2·6.2.3 L1 |

- 인증은 프레임워크·검증된 라이브러리·IdP 기능을 쓰고 직접 구현을 피할 것(키트 규칙). 외부 IdP 토큰은 서명 검증, 계정은 IdP id 네임스페이스로 묶음(6.8.1·6.8.2 L2). SMS OTP는 번호 검증 후에만, TOTP 같은 더 강한 수단과 함께 제공(6.6.1 L2).
- bcrypt를 쓰면 72바이트 초과 입력의 처리 방식을 정해 기록. 6.2.8이 잘라내기를 금지하므로 신규 프로젝트는 Argon2id 우선.

## 세션

- 세션 토큰은 서버에서 검증(7.2.1 L1), 참조 토큰은 CSPRNG 128비트 이상(7.2.3 L1). 로그인·재인증 때 새 토큰을 발급하고 이전 토큰 종료(7.2.4 L1). 로그아웃·만료 시 서버에서 무효화. JWT 같은 자체 포함 토큰은 폐기 목록이나 사용자별 발급 기준 시각이 필요(7.4.1 L1). 계정 비활성·삭제 시 모든 세션 종료(7.4.2 L1). 유휴·절대 만료를 정해 기록(7.1.1·7.3.1·7.3.2 L2). OWASP Session Management 예시는 유휴 고가치 2~5분·저위험 15~30분, 하루 업무용 절대 4~8시간.
- 쿠키: `__Host-` 접두사, `Secure`, `HttpOnly`, 목적에 맞는 `SameSite`(3.3.1 L1, 3.3.2~3.3.4 L2). 세션 토큰은 `Set-Cookie`로만 전달하고 `localStorage`에 두지 말 것(3.3.4, XSS 시 탈취 방지를 위한 키트 기본값).
- 토큰 서명 검증과 알고리즘 허용 목록, `none` 금지(9.1.1·9.1.2 L1). 토큰·API 키를 URL에 넣지 말 것(14.2.1 L1). 이메일·전화번호·MFA 변경 전 재인증(7.5.1 L2), 비밀번호 변경 후 다른 세션 종료 선택지(7.4.3 L2).

## 권한

- 서버에서 강제(8.3.1 L1). 클라이언트의 버튼 숨김·라우트 가드는 UX일 뿐 검사로 치지 않음. 기본 거부, 모든 요청에서 검사(OWASP Authorization).
- 객체 단위 검사: 조회·수정·삭제 쿼리 조건에 소유자·테넌트 조건 포함(8.2.2 L1, IDOR·BOLA). 추측하기 어려운 id도 검사를 대신하지 못함. 멀티테넌트는 테넌트 간 차단(8.4.1 L2).
- 필드 단위: 응답은 필요한 필드만(15.3.1 L1), 쓰기는 허용 필드 목록으로 mass assignment 차단(15.3.3 L2, 8.2.3 L2).
- 권한 변경은 즉시 반영(8.3.2 L3, 키트는 L1부터 적용). 정적 파일·클라우드 저장소 객체도 같은 검사(OWASP Authorization). `spec/PERMISSIONS.md`(`--with-spec`으로 배치한 경우, 없으면 키트의 `template/spec/PERMISSIONS.md`를 복사)가 기준. 매트릭스에 없는 리소스·동작은 구현 전에 추가하고, `-` 칸마다 거부 테스트와 다른 사용자 id로 바꾼 요청 테스트 작성.

## 입력과 출력

- 서버에서 입력 검증: 타입·길이·범위·허용 값 목록(2.2.1·2.2.2 L1). 클라이언트 검증은 사용성용. 다단계 흐름은 순서 건너뛰기 차단(2.3.1 L1).
- DB: 파라미터화 쿼리·ORM(1.2.4 L1). 테이블·컬럼·정렬 방향은 허용 목록 매핑, 이스케이프는 방어 수단으로 쓰지 말 것(OWASP SQL Injection). 문자열 결합 raw query API 금지. DB 계정은 최소 권한.
- OS 명령은 셸 문자열 대신 인자 배열(1.2.5 L1). XML 파서 외부 엔티티 비활성화(1.5.1 L1), 신뢰하지 않는 데이터의 역직렬화는 타입 허용 목록(1.5.2 L2). HTML 출력은 프레임워크 기본 이스케이프와 컨텍스트별 인코딩(1.2.1 L1). 텍스트는 `textContent`·`createTextNode`로 넣을 것(3.2.2 L1).
- 이스케이프 우회 API(`dangerouslySetInnerHTML`, `bypassSecurityTrustAs*`, `unsafeHTML`, `innerHTML`, `v-html`)는 DOMPurify 같은 검증된 sanitizer를 거친 값에만 사용(1.3.1 L1, OWASP XSS Prevention). 사용자 값이 들어가는 `href`·`src`는 `https:`·`http:` 등 허용 프로토콜만, `javascript:` 차단(1.2.2 L1). 사용자 SVG·마크다운은 sanitize(1.3.4·1.3.5 L2).
- SSRF: 서버가 사용자 지정 URL을 가져오면 프로토콜·도메인·포트 허용 목록(1.3.6 L2), 리다이렉트 따라가지 않기(15.3.2 L2), DNS 해석 후 사설·루프백·링크 로컬과 `169.254.169.254` 차단, 받은 응답을 그대로 돌려주지 않기(OWASP SSRF Prevention).

## 요청 위조와 교차 출처

- 상태 변경은 POST·PUT·PATCH·DELETE로만(3.5.3 L1). 쿠키 인증이면 CSRF 토큰(동기화 토큰, 서명된 double-submit)이나 CORS 안전 목록 밖의 커스텀 헤더로 출처 확인(3.5.1 L1). Fetch Metadata(`Sec-Fetch-Site`)로 막으면 `Origin` 검증 대체 경로가 필수, `SameSite`는 보조 수단(OWASP CSRF Prevention).
- CORS: `Access-Control-Allow-Origin`은 고정값 또는 허용 목록 대조, `*`는 민감 정보 없는 응답에만(3.4.2 L1). 요청 `Origin`을 그대로 반사하지 말 것. `postMessage`는 출처 확인(3.5.5 L2), WebSocket 핸드셰이크는 `Origin` 허용 목록 확인(4.4.2 L2), 외부 도메인 자동 리다이렉트는 허용 목록(3.7.2 L2).

## 비밀값

- 서버 환경 변수나 플랫폼 비밀 저장소에 보관, 소스·빌드 산출물에 넣지 말 것(13.3.1 L2). 키 이름은 `.env.example`, 값은 gitignore된 `.env`나 배포 플랫폼 설정에. 개발·운영 키 분리, 접근은 최소 권한(13.3.2 L2).
- 클라이언트 번들에 들어가는 변수(Next.js `NEXT_PUBLIC_`, Vite `VITE_`)는 빌드 시 코드에 박히므로 공개해도 되는 값만. 모바일 앱 바이너리 안의 키도 추출 가능하다고 보고 서버 경유로 호출(키트 규칙). 로그·오류 응답·분석 이벤트·URL에도 남기지 말 것(16.2.5 L2, 14.2.1 L1).
- 유출 의심 시 순서: 해당 키 폐기와 재발급 → 사용 기록 확인 → 코드·히스토리 정리(OWASP Secrets Management). 히스토리에서 지워도 유출로 간주하고 폐기를 생략하지 말 것. 개인정보가 얽히면 PRIVACY_LEGAL의 신고 절차로.
- `guard-secrets.sh`는 에이전트의 Edit·Write 안에 있는 형태가 뚜렷한 리터럴만 막고, 파싱 실패 시 통과(fail-open). 터미널 출력·로그·번들·사람의 커밋은 보지 못하므로 CI 시크릿 스캔을 따로 둘 것. GitHub secret scanning·push protection은 공개 저장소 무료, 비공개는 Secret Protection 필요. `HARNESS_SECRET_GUARD=off` 우회는 사용자 승인과 AGENTS §B 기록 후에만.

## 의존성과 공급망

- lockfile 커밋, CI 설치는 `npm ci`(lockfile 불일치 시 실패) 또는 `pnpm install --frozen-lockfile`(CI 기본 true). 새 의존성 추가는 AGENTS §4 ASK이며 아래 표를 채워 함께 보고.

| 확인 항목 | 방법 |
| --- | --- |
| 필요성·이름 | 표준 라이브러리·기존 의존성·짧은 코드로 대체 가능한지, 공식 저장소 링크와 대조해 오타·유사 이름 패키지 배제 |
| 유지 상태 | 최근 릴리스, 관리자 수, 미해결 보안 이슈. 공개 저장소면 OpenSSF Scorecard 점수(검사별 0~10) 참고 |
| 설치 스크립트 | `postinstall` 등 유무. pnpm v10 이상은 의존성 스크립트를 기본 실행하지 않으므로 `allowBuilds`에 필요한 것만 등록 |
| 취약점·서명·범위 | `npm audit`/`pnpm audit`, `npm audit signatures`로 레지스트리 서명·provenance 확인, 추가되는 전이 의존성 수와 라이선스 |

- 취약점 업데이트 기한을 문서화하고 기한을 넘긴 컴포넌트를 두지 않음(15.1.1·15.2.1 L1). 키트 기본값은 치명·높음 7일 이내, 나머지는 월 1회 정기 업데이트(사용자가 `decisions.md`에서 조정).
- GitHub 저장소면 Dependabot alerts 활성화. 새 버전 설치 지연은 pnpm `minimumReleaseAge`(분 단위, 현행 문서 기본 1440) 같은 설정으로. 외부 CDN 스크립트는 버전 고정과 SRI(3.6.1 L3). CI 워크플로는 토큰 권한 최소화와 액션 버전 고정(Scorecard Token-Permissions·Pinned-Dependencies 검사 항목). 패키지를 배포하는 프로젝트만 SLSA Build L1(provenance) 이상을 목표로 하고 `npm publish --provenance` 사용(GitHub Actions·GitLab의 클라우드 러너 필요). 앱만 배포하면 해당 없음.

## 전송과 보안 헤더

| 대상 | 값 | 근거 |
| --- | --- | --- |
| 전송 | 모든 외부 연결 TLS, TLS 1.2·1.3만, 공인 인증서. API 엔드포인트는 HTTP→HTTPS 자동 리다이렉트 대신 거부 | 12.1.1·12.2.1·12.2.2 L1, 4.1.2 L2 |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` 이상. `preload`는 되돌리기 어려워 사용자 결정 | 3.4.1 L1(1년, L2부터 하위 도메인), MDN |
| `Content-Security-Policy` | 최소 `object-src 'none'; base-uri 'none'` + nonce·hash 또는 허용 목록. 권장 `script-src 'nonce-{RANDOM}' 'strict-dynamic'; object-src 'none'; base-uri 'none'`, `frame-ancestors 'none'` 또는 `'self'`. `'unsafe-inline'` 피하고 `Content-Security-Policy-Report-Only`로 먼저 배포. 출력 인코딩을 대신하지 못하는 추가 방어층 | 3.4.3·3.4.6 L2, OWASP CSP |
| `X-Content-Type-Options` | `nosniff` | 3.4.4 L2 |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | 3.4.5 L2, OWASP HTTP Headers |
| 기타 | `Permissions-Policy`로 안 쓰는 기능 차단(예 `geolocation=(), camera=(), microphone=()`), `Cross-Origin-Opener-Policy: same-origin`, `X-Frame-Options: DENY`(구형 브라우저용), `X-XSS-Protection`은 `0` 또는 생략, `Server`·`X-Powered-By` 제거 | OWASP HTTP Headers, 3.4.8 L3 |
| 캐시·형식·노출 | 민감 응답 `Cache-Control: no-store`, 본문 있는 응답에 charset 포함 `Content-Type`, 운영에서 `.git`·디렉터리 목록 노출 금지 | 14.3.2 L2, 4.1.1·13.4.1 L1, 13.4.3 L2 |

## 파일 업로드

- 기능별 허용 확장자·최대 크기(압축 해제 후 크기 포함)를 정해 기록(5.1.1 L2), 처리 가능한 크기만 수락(5.2.1 L1). 확장자 허용 목록과 매직 바이트 검사, 이미지는 재인코딩(5.2.2 L1, L2부터 모든 파일). `Content-Type` 요청 헤더는 신뢰하지 않음(OWASP File Upload).
- 저장 이름은 서버가 생성하고 사용자 파일명을 경로에 쓰지 않음(5.3.2 L1). 웹 루트 밖이나 별도 버킷에 두고 서버 코드로 실행되지 않게(5.3.1 L1).
- 다운로드 응답은 검증한 파일명으로 `Content-Disposition` 지정(5.4.1·5.4.2 L2). 압축 파일은 해제 전 크기·개수 확인(5.2.3 L2)과 내부 경로 무시(5.3.3 L3). 업로드에도 인증·권한·CSRF 검사(OWASP File Upload). 신뢰하지 않는 출처 파일은 악성코드 검사(5.4.3 L2). 이미지 EXIF·메타데이터는 [시각 에셋](VISUAL_ASSETS.md).

## 남용 방지

- 레이트 리밋 대상: 로그인, 가입, 비밀번호 재설정, OTP 검증(6.6.3), 메일·SMS 발송(비용, 메일 재발송 한도는 [메일 발송](EMAIL_DELIVERY.md)), 검색·내보내기 등 무거운 기능(15.2.2 L2), LLM 호출. 사용자별·전역 한도를 함께 정할 것(2.1.3·2.4.1 L2).
- 계정 기준과 IP 기준을 병행하고, 잠금보다 점점 늘어나는 지연을 우선(OWASP Authentication). 프록시 뒤 클라이언트 IP는 신뢰한 중간 계층 헤더만 사용(4.1.3·15.3.4 L2).
- 계정 열거 방지: 로그인 실패, 재설정 요청, 가입에 같은 응답(예: "아이디 또는 비밀번호가 올바르지 않습니다", "가입된 이메일이면 재설정 안내를 보냈습니다"). 없는 계정도 해시를 계산해 응답 시간 차이 제거(OWASP Authentication, 6.3.8 L3). 문구는 [제품 문구](UI_COPY.md), CAPTCHA 대안은 [접근성](ACCESSIBILITY.md) 3.3.8.

## LLM 기능

사용자 경험·생성물 표시·품질 평가는 [AI 기능](AI_FEATURES.md)이 맡고, 여기서는 보안만 다룸.
- 사용자 입력, 웹 페이지, 파일, 검색·도구 결과는 지시가 아닌 데이터로 취급하고 프롬프트에서 구분 표시(LLM01 Prompt Injection). 시스템 프롬프트는 유출된다고 가정하고 비밀값·권한 규칙을 넣지 말 것(LLM07 System Prompt Leakage).
- 도구는 필요한 것만, 권한은 최소로, 호출은 요청한 사용자의 권한으로 실행. 삭제·결제·외부 발송 같은 고위험 동작은 사람 승인(LLM06 Excessive Agency).
- 모델 출력은 신뢰하지 않는 입력: 화면 렌더링 시 HTML·마크다운 인코딩과 sanitize, DB·셸에 넣을 때 파라미터화, 구조화 출력은 스키마 검증(LLM05 Improper Output Handling). 마크다운 외부 이미지 자동 로드는 허용 목록으로 제한(데이터 유출 경로 차단, 키트 규칙).
- RAG 검색 결과에도 요청자 권한 필터를 적용해 다른 사용자 데이터가 컨텍스트에 섞이지 않게(LLM02·LLM08, 키트 해석). 사용자별 요청·토큰 한도(LLM10 Unbounded Consumption). 간접 인젝션 문자열을 넣은 문서 fixture로 회귀 테스트(LLM01의 적대적 테스트).

## 보안 이벤트 기록

| 이벤트 | 근거 |
| --- | --- |
| 로그인 성공·실패(인증 방식 포함), 로그아웃, 전체 세션 종료, 권한 거부 | 16.3.1·16.3.2 L2 |
| 비밀번호·MFA·이메일 변경, 재설정 요청·완료, 관리자 동작·권한 변경 | OWASP Logging |
| 레이트 리밋·잠금 발동, 입력 검증 실패, CSRF·토큰 검증 실패 등 통제 우회 시도 | 16.3.3 L2, OWASP Logging |
| 예상치 못한 오류, 백엔드 TLS 실패 같은 보안 통제 실패 | 16.3.4 L2 |
| 업로드 거부, LLM 고위험 도구 실행과 승인 결과 | 키트 규칙 |

- 항목마다 when·where·who·what(16.2.1 L2), 시각은 UTC 또는 오프셋 포함(16.2.2 L2), 결과, 요청 id. 로그 인젝션 방지를 위해 CR·LF·구분자 인코딩(16.4.1 L2).
- 남기지 말 것: 비밀번호, 세션 id(추적이 필요하면 해시), 액세스 토큰, 암호화 키, 결제 정보(OWASP Logging, 16.2.5 L2). 개인정보 처리 기준은 PRIVACY_LEGAL. 사용자에게는 일반 오류 메시지만, 스택 트레이스·쿼리·키 노출 금지(16.5.1 L2). 로그 구조·보존 기간·전송·알림은 OPERATIONS.

## 검증

| 검사 | 방법 | 통과 기준 |
| --- | --- | --- |
| 비밀값 | CI 시크릿 스캔(히스토리 포함), `grep`으로 번들 산출물의 키 접두사 검색 | 탐지 0건, 공개 변수에 비밀 없음 |
| 의존성 | `npm audit`/`pnpm audit`, Dependabot alerts, `npm audit signatures` | 기한 넘긴 치명·높음 0건 |
| 정적 분석 | SAST 도구(공개 GitHub 저장소는 code scanning 무료) | 신규 high 0건 또는 사유 기록 |
| 헤더 | `curl -sI <운영 URL>`로 전송·헤더 표 확인, `/.git/HEAD` 요청 | 표의 헤더 존재, `.git` 404 |
| 권한 | PERMISSIONS `-` 칸 거부 테스트, 다른 사용자 id로 바꾼 요청 | 전부 403·404 |
| 인증·세션 | 짧은 비밀번호·흔한 비밀번호 거부, 붙여넣기 동작, 실패 응답 동일성, 로그아웃 뒤 이전 쿠키 재사용 | 거부·동일·401 |
| CSRF·CORS | 다른 출처에서 상태 변경 요청, 임의 `Origin` 헤더 | 거부, 허용 목록 밖 출처에 ACAO 없음 |
| 업로드·SSRF | 확장자만 바꾼 실행 파일, 압축 폭탄, `localhost`·`169.254.169.254`·리다이렉트 URL | 전부 거부 |
| LLM | 간접 인젝션 fixture, 출력에 `<script>`·외부 이미지 마크다운 | 지시 미실행, 인코딩되어 표시 |

결과 인계에는 실행한 검사와 도구 버전, 대상 환경, 미실행 범위를 기록. 에이전트가 대신할 수 없는 것: 침투 테스트와 외부 보안 감사, 운영 클라우드 IAM·네트워크 설정 확인, 공공 감리용 인증 진단 도구 결과, 법적 적합성과 유출 신고 판단. 자동 스캔만 했다면 수동 점검 미실행으로 남길 것.

## 근거와 한계

확인일 2026-10-01.

- [OWASP ASVS 5.0.0](https://github.com/OWASP/ASVS/releases/tag/v5.0.0_release) (2025-05-30 릴리스, `v5.0.0_release` 태그 원문): 레벨 정의(L1 약 20%, L2까지 약 70%), 장 V1~V17, 본문에 인용한 요구사항 번호와 레벨.
- [OWASP Top 10:2025](https://top10.owasp.org/2025/): A01 Broken Access Control, A02 Security Misconfiguration, A03 Software Supply Chain Failures, A04 Cryptographic Failures, A05 Injection, A06 Insecure Design, A07 Authentication Failures, A08 Software or Data Integrity Failures, A09 Security Logging and Alerting Failures, A10 Mishandling of Exceptional Conditions.
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/): Password Storage, Session Management, Authentication, Authorization, Cross-Site Request Forgery Prevention, Cross Site Scripting Prevention, SQL Injection Prevention, Server Side Request Forgery Prevention, File Upload, Secrets Management, HTTP Headers, Content Security Policy, Logging.
- [NIST SP 800-63B-4](https://pages.nist.gov/800-63-4/sp800-63b.html) (Final, 2025-07-31, [CSRC](https://csrc.nist.gov/pubs/sp/800/63/b/4/final)): 3.1.1.2 비밀번호, 3.2.2 실패 제한.
- [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/): LLM01·LLM05·LLM06의 대응 원칙은 각 항목 페이지에서 확인.
- [SLSA v1.2 Build track](https://slsa.dev/spec/v1.2/build-track-basics) (Approved), [npm provenance](https://docs.npmjs.com/generating-provenance-statements), [npm ci](https://docs.npmjs.com/cli/v11/commands/npm-ci), [pnpm 공급망 보안](https://pnpm.io/supply-chain-security), [pnpm install](https://pnpm.io/cli/install), [OpenSSF Scorecard](https://scorecard.dev/). GitHub Docs: [About secret scanning](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning), [GitHub security features](https://docs.github.com/en/code-security/getting-started/github-security-features), [About Dependabot alerts](https://docs.github.com/en/code-security/dependabot/dependabot-alerts/about-dependabot-alerts).
- [MDN, Strict-Transport-Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Strict-Transport-Security), [W3C CSP Level 3](https://www.w3.org/TR/CSP3/) (Working Draft, 16 September 2026), [Next.js 환경 변수](https://nextjs.org/docs/app/guides/environment-variables), [Vite env](https://vite.dev/guide/env-and-mode). 국가법령정보센터, [개인정보의 안전성 확보조치 기준](https://www.law.go.kr/행정규칙/개인정보의안전성확보조치기준). [KISA 소프트웨어 개발 보안 가이드](https://www.kisa.or.kr/2060204/form?postSeq=5) (등록 2021-11-29), [소프트웨어 보안약점 진단가이드](https://www.kisa.or.kr/2060204/form?postSeq=9) (등록 2021-11-30).

오용 주의와 미확인 사항:
- OWASP Top 10:2025의 공식 발표일은 페이지에서 확인하지 못함(미확인). GitHub OWASP/Top10 저장소에서 제목의 RC 표기가 2025-12-24 커밋으로 제거된 것까지 확인.
- ASVS 레벨 선택(L1 전부 + 해당 장 L2), 비밀번호 10자 하한, 업데이트 기한 7일·월 1회, `localStorage` 금지, 모바일 키 서버 경유는 키트 규칙이며 원문 문장에서 온 수치가 없음. ASVS master 브랜치(Bleeding Edge)는 번호가 바뀔 수 있어 5.0.0 태그만 인용.
- KISA 소프트웨어 개발보안 가이드 표 3-12(『패스워드 선택 및 이용 안내서』 인용)의 비밀번호 규칙(두 종류 이상 8자리 또는 10자리 이상)은 NIST의 조합 규칙 금지와 충돌. 키트 길이 하한은 두 기준을 함께 만족하도록 고른 값.
- OWASP 세션 만료 시간과 Password Storage 파라미터는 예시·최소 권장값이며 서버 성능과 위험에 맞춰 조정 대상. Dependabot alerts 무료 범위, pnpm `minimumReleaseAge` 기본값과 `allowBuilds` 설정명(현행 문서 기준이며 이전 버전의 이름은 미확인), GitHub 유료 기능 이름은 문서 개정에 따라 바뀔 수 있음. LLM 항목은 원칙 목록이며 프롬프트 인젝션을 완전히 막는 방법은 원문도 제시하지 않음. LLM02·LLM07·LLM08·LLM10은 이름만 확인했고 대응 문장은 키트 해석.
