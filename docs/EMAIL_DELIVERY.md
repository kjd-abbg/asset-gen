# 메일 발송: 서비스 메일·뉴스레터

가입 인증, 비밀번호 재설정, 결제·보안 알림 같은 서비스 메일과 뉴스레터·프로모션을 보내는 기능을 만들 때 적용. 메일을 보내지 않는 제품은 적용 제외.
광고성 정보의 동의·(광고) 표시·야간 전송·2년 확인과 발송 서비스의 위탁·국외 이전은 [개인정보·법적 고지](PRIVACY_LEGAL.md), 토큰 수명·1회 사용·계정 열거 방지·레이트 리밋·비밀값은 [보안](SECURITY.md), 감시·알림·비용 상한은 [운영](OPERATIONS.md), 문구는 [화면 문구](UI_COPY.md), 대체 텍스트와 대비는 [접근성](ACCESSIBILITY.md)·[시각 에셋](VISUAL_ASSETS.md)이 맡음. 아래 수치는 2026-10-01에 확인한 수신 업체 정책이며 업체가 예고 없이 바꿀 수 있음.

## 메일 종류 구분

| 종류 | 예 | 구독 취소 | 발송 경로 |
| --- | --- | --- | --- |
| 트랜잭션 | 가입 인증, 비밀번호 재설정, 영수증, 보안 알림 | 원클릭 요건 제외(Google FAQ) | 트랜잭션 전용 주소·서브도메인 |
| 관계·알림 | 댓글·활동 알림, 정기 요약, 서비스 공지 | 알림 설정에서 끄기, 구독형이면 원클릭 적용(키트 규칙) | 트랜잭션과 같은 경로 가능, From 주소는 분리 |
| 광고성 | 뉴스레터, 프로모션, 쿠폰·적립금 안내 | 원클릭 + 본문 링크 필수(Google, Yahoo) | 광고 전용 주소·서브도메인 |

- 법적 성격(광고성 정보 해당 여부)의 판정은 PRIVACY_LEGAL로 넘김. Google FAQ도 구분은 업종·법령에 따라 다르고 메일 성격은 수신자가 판단한다고 명시. 한 메일에 종류를 섞지 말 것. 예로 영수증에 프로모션을 넣지 않음(Google 발신자 가이드라인).

## 발송 기반

- 키트 기본값은 발송 서비스(이메일 API 또는 SMTP 릴레이) 사용. 근거 사실: Compute Engine은 외부 25번 포트 연결을 막고 서드파티 메일 서비스를 안내함(Google Cloud 문서), Gmail·네이버는 발송 IP의 정·역방향 DNS를 요구함, 공유 IP 평판은 같은 IP의 모든 발신자에게 영향(Google), SES는 주요 메일 업체와 피드백 루프를 대신 설정함(AWS). 자체 MTA 운영은 사용자 결정으로 `decisions.md`에 기록.
- 발송 서비스는 PRIVACY_LEGAL 개인정보 목록 표의 수탁자 열에 올리고, API 키는 서버 환경 변수로만 다룸(SECURITY 비밀값).
- 발송 서비스 가입, 도메인 인증, DNS 레코드 추가·변경은 사용자 승인 대상(AGENTS §4 ASK). 에이전트는 레코드 초안과 확인 명령까지 준비.

| 용도 | 예 | 규칙 |
| --- | --- | --- |
| 트랜잭션 From | `account@mail.example.com` | 같은 종류는 같은 From 주소(Google). From 헤더에 주소 1개 |
| 광고 From | `news@news.example.com` | 트랜잭션과 다른 주소, 전용 IP를 쓰면 다른 IP·풀(Google, Yahoo, SES 전용 IP 풀) |
| Return-Path(MAIL FROM) | `bounce.mail.example.com` | 발송 서비스가 안내하는 전용 서브도메인. 메일을 보내는 From·받는 주소와 겹치지 않게(SES) |
| 업무 수신 메일 | `example.com`의 MX | 발송 서비스와 별개. 회신이 필요하면 `Reply-To`로 받을 주소 지정 |

- 서브도메인을 나눠도 Gmail 대량 발신자 판정은 상위 도메인 합산이라 기준을 피하지 못함(Google FAQ). 분리의 목적은 평판 격리임(Yahoo: IP 또는 DKIM 도메인별 분리, Postmark: 브로드캐스트를 별도 인프라로).
- `@gmail.com`·`@naver.com`을 From으로 쓰는 외부 발송 금지. 네이버는 naver.com DMARC를 `p=quarantine`으로 강화했고 Gmail도 사칭 From에 quarantine 집행을 예고함.

## 도메인 인증

| 레코드 | 위치 | 값 예 | 기준 |
| --- | --- | --- | --- |
| SPF | MAIL FROM 도메인 TXT | `v=spf1 include:<발송 서비스 값> ~all` | 이름당 SPF 레코드 1개(복수면 permerror), DNS 조회 유발 항목 10개 이하(RFC 7208 4.6.4). `~all`로 시작해 DMARC 보고서로 발송원을 모두 확인한 뒤 `-all` 검토(키트 규칙) |
| DKIM | `<selector>._domainkey.mail.example.com` | 발송 서비스가 주는 TXT 또는 CNAME | RSA 1024비트 미만 금지, 2048비트 권장, `rsa-sha1` 금지(RFC 8301) |
| DMARC | `_dmarc.example.com` TXT | `v=DMARC1; p=none; rua=mailto:dmarc@example.com` | 서브도메인은 상위 정책을 따름, 다르게 하려면 `sp=` 또는 서브도메인 레코드(RFC 9989) |
| PTR | 발송 IP 역방향 | 업체 공유 IP면 업체 관리 | 전용 IP·자체 서버면 PTR 호스트의 A/AAAA가 같은 IP로(FCrDNS, Google·네이버) |

- 정렬(alignment): DMARC 통과에는 SPF 또는 DKIM 중 하나가 pass이고 그 도메인이 From 도메인과 정렬돼야 함. 기본 `adkim=r`·`aspf=r`(relaxed)은 조직 도메인이 같으면 정렬로 봄. 발송 서비스의 기본 MAIL FROM(업체 도메인)을 쓰면 SPF는 pass여도 정렬되지 않으므로 DKIM 정렬을 필수로, 커스텀 MAIL FROM으로 SPF 정렬까지 맞출 것(SES DMARC 문서, Google은 둘 다 정렬을 권장하며 향후 요건화 가능성 언급).

| DMARC 단계 | 값 | 다음 단계로 가는 조건 |
| --- | --- | --- |
| 1 감시 | `p=none; rua=...` | SPF·DKIM과 보고서 수신함을 먼저 갖춤(RFC 9989 5.1.1~5.1.4). 보고서 최소 4주(키트 기본값) |
| 2 격리 | `p=quarantine` | 정당한 발송원이 모두 정렬 pass, 미정렬 정당 흐름은 강화 전에 고쳐야 함(RFC 9989 5.1.6) |
| 3 거부 | `p=reject` | 격리 단계 보고서에서 정당 메일 실패 0, 메일링 리스트·포워딩 영향 검토(RFC 9989 5.1.7·7.4) |

- 강화 결정은 사용자. `pct`는 RFC 9989에서 historic이므로 새 레코드에 넣지 말고 시험은 `t=y`를 사용. 보고서는 기계 파싱을 전제로 한 XML이라 수신함과 처리 도구를 함께 정할 것(RFC 9989 5.1.5).
- MTA-STS(RFC 8461)·TLS-RPT(RFC 8460)는 그 도메인이 메일을 받을 때의 수신 보호라 발송 전용이면 선택. BIMI는 IETF 표준이 아닌 개인 제출 Internet-Draft이며 Gmail은 `p=quarantine` 이상과 VMC·CMC 인증서를 요구하므로 기본 범위 밖. ARC(RFC 8617, Experimental)는 포워더·메일링 리스트가 붙이는 헤더라 발송 앱의 구현 대상에서 제외.

## 대량 발송 요건

| 항목 | Gmail(개인 계정 수신) | Yahoo | 네이버 |
| --- | --- | --- | --- |
| 대상 | 24시간 5,000통 근접 이상, 상위 도메인 합산, 한 번 해당하면 영구 | 대량 발신자(수치 미확인) | 대량 발송(수치 비공개) |
| 인증 | 모든 발신자 SPF 또는 DKIM, 대량은 SPF·DKIM·DMARC(`p=none` 이상)·정렬 | 같음, DMARC pass | SPF 미통과 차단 가능, SPF·DKIM 권장, 대량은 DMARC 등록 |
| 구독 취소 | 마케팅·구독 메일 원클릭 + 본문 링크, 48시간 안 처리 | 원클릭, 2일 안 처리 | 수신 거부자 목록 제외 |
| 스팸률 | Postmaster Tools 0.3% 미만 필수, 0.1% 미만 유지 | 0.3% 미만(CFL) | 신고 누적 시 차단, 도메인 신뢰도 하락 |
| 인프라 | PTR(정·역방향), TLS, RFC 5322 | PTR, RFC 5321·5322 | PTR+FCrDNS, RBL 미등재, 동시 다수 연결 금지 |
| 집행 | 2025-11부터 일시·영구 거절 강화, 새 도메인은 가속 | 미확인 | 2024-07부터 점진 적용 |

- 1인 프로젝트도 첫 발송부터 대량 기준을 충족(키트 규칙). 기준 초과는 되돌릴 수 없고 새 도메인은 집행이 빠르기 때문.
- 원클릭 구독 취소(RFC 8058 3.1·4): 아래 두 헤더, HTTPS URI 1개 필수, URI에 수신자·리스트를 식별하는 위조하기 어려운 토큰, POST는 쿠키·로그인 없이 처리, 응답에 리다이렉트 금지, 두 헤더를 DKIM 서명 범위에 포함. 스팸 필터가 헤더 URI를 자동으로 가져가므로(RFC 8058 1장) GET은 확인 화면만 보여 주고 구독을 끊지 않음. 원클릭은 그 메일의 리스트에서만 빼고(Google FAQ), 전체 수신 거부는 설정 화면에서.

```
List-Unsubscribe: <https://example.com/unsub/opaque-token>, <mailto:unsub@example.com?subject=unsub>
List-Unsubscribe-Post: List-Unsubscribe=One-Click
```

## 발송 품질

- 큐: 요청 처리 중 동기 발송 대신 작업 큐에 넣고 바로 응답(키트 규칙). 가입된 주소에만 발송이 일어나 응답 시간이 달라지는 것도 막음(SECURITY 계정 열거 방지).
- 멱등성: 발송 전에 목적·대상 id·이벤트 id로 고유 키를 만든 발송 기록을 저장하고, 재시도는 같은 키로만. 발송 서비스가 멱등 키를 받으면 함께 전달(키트 규칙).
- 재시도: 4yz 일시 실패와 API 429·5xx는 지수 백오프와 횟수 상한, 5yz 영구 실패는 재시도하지 않음(RFC 5321 4.2.1). Gmail `4.7.28`은 10분 이상 멈췄다가 연결 1개부터 다시 늘림(Google). 하드 바운스 주소로 반복 발송 금지(SES).
- 수신 거부 목록(suppression list): 하드 바운스·스팸 신고는 전 종류 발송 중단, 구독 취소는 해당 리스트만. 발송 직전에 조회하고, 발송 서비스 목록과 앱 DB를 웹훅으로 동기화하며 웹훅은 서명을 검증(키트 규칙). Gmail은 신고 데이터를 SES에 주지 않으므로 Gmail 스팸률은 Postmaster Tools로 따로 봄(SES).
- 뉴스레터 구독은 주소 확인 메일로 확정(Google: 구독 전 수신자 주소 확인), 기본 체크된 구독 동의 금지(Google, 동의 화면은 PRIVACY_LEGAL·UX_DESIGN).
- 볼륨: 새 도메인·IP는 참여도가 높은 수신자에게 소량부터 점진 증가, 갑작스러운 2배 증가 금지(Google), 문제가 생기면 간격을 두고 나눠 발송(네이버). 재발송 한도는 같은 주소·같은 목적 60초 간격, 시간당 5회(키트 기본값, SECURITY 남용 방지의 메일 발송 항목).

| 지표 | 유지 | 조치 기준 | 출처 |
| --- | --- | --- | --- |
| 바운스율(하드) | 2% 미만 | 5% 검토, 10% 발송 정지 가능 | SES FAQ |
| 신고율 | 0.1% 미만 | 0.1% 검토, 0.5% 발송 정지 가능 | SES FAQ |
| Gmail 스팸률 | 0.1% 미만 | 0.3% 이상이면 완화 지원 대상 제외 | Google FAQ |

다른 발송 서비스의 기준은 해당 업체 문서로 확인해 `decisions.md`에 기록. 지표 알림은 OPERATIONS 감시와 알림 절의 경로를 사용.

## 메일 내용

- 헤더: 유효한 `Message-ID`, `From`·`To`·`Subject`·`Date`는 한 번씩, 실제 답장·전달이 아니면 `Re:`·`Fwd:` 금지(Google).
- 발신자 이름은 서비스 이름으로 고정하고 제목·긴급 문구·수신자 이름·이모지를 넣지 말 것(Google 표시 이름 지침). 제목은 메일 목적을 그대로 쓰고 문구는 UI_COPY.
- 본문은 `multipart/alternative`로 `text/plain`을 먼저, `text/html`을 뒤에(RFC 2046 5.1.4). 일반 텍스트 파트에도 코드·전체 URL·만료 시각을 모두 넣을 것.
- 링크: 표시 텍스트가 목적지를 설명하고 자기 도메인을 사용, 단축 URL 금지, 클릭 추적을 쓰면 자기 서브도메인의 추적 도메인(키트 규칙). HTML·CSS로 숨긴 콘텐츠 금지(Google).
- HTML 접근성: `<html lang="ko">`(ACCESSIBILITY 3.1.1), `<title>`, 레이아웃 표에 `role="presentation"`(WAI-ARIA 1.2), 레이아웃 표 안에 `th`·`caption`·`summary` 금지(WCAG F46), 소스 순서와 읽는 순서 일치, 본문 대비 4.5:1(ACCESSIBILITY).
- 이미지 의존 금지: 코드·링크·금액·만료 시각은 텍스트로 두고 이미지를 꺼도 내용이 전달되게. 정보 이미지 `alt`, 장식 `alt=""`, 글자 이미지 금지(VISUAL_ASSETS).
- 다크모드: Gmail CSS 문서의 지원 미디어 기능에 `prefers-color-scheme`이 없어 클라이언트가 색을 임의로 바꿀 수 있다고 가정. 로고는 투명 배경 대신 자체 배경이나 테두리, 색만으로 정보 전달 금지, 밝은·어두운 배경 모두에서 대비 확인, CSS는 인라인 우선(키트 규칙). Gmail은 `<head>`의 `<style>`과 class·id·요소 선택자를 지원.
- 추적: Google은 열람률을 추적하지 않고 외부 열람률의 정확성도 검증할 수 없다고 밝힘. 트랜잭션 메일은 열람 픽셀·링크 재작성을 끄고(토큰 링크 보호, 키트 규칙), 광고 메일의 추적은 PRIVACY_LEGAL 쿠키·분석 도구 절로 판단.

## 트랜잭션 메일 패턴

| 메일 | 담을 것 | 근거 |
| --- | --- | --- |
| 가입 인증 | 목적, 링크 또는 코드, 서버 설정과 같은 유효 시간("30분 후 만료"), 요청하지 않았다면 무시해도 된다는 안내 | 키트 규칙, 수명은 SECURITY |
| 비밀번호 재설정 | 위 항목, 1회용 안내. URL은 설정된 기본 URL로 만들고 `Host` 헤더 사용 금지, 재설정 화면 `Referrer-Policy: no-referrer` | OWASP Forgot Password, SECURITY 재설정·OTP |
| 계정 변경 알림 | 변경 항목·시각, 본인이 아니면 할 일과 연결 화면. 이메일 변경은 이전 주소에도 발송(키트 규칙) | ASVS 6.3.7(L3, 계정이 있으면 키트 기본값) |
| 결제·영수증 | 거래 조건·사업자 표시 | PRIVACY_LEGAL 전자상거래 절 |

- 메일 링크의 GET은 확인 화면만 열고 토큰 소비는 화면의 버튼(POST)에서 처리. 링크 검사기가 본문 링크를 미리 여는 경우를 막기 위한 키트 해석(RFC 8058 1장의 헤더 URI 자동 접근 사례를 본문 링크에 적용).
- 비밀번호, 전체 개인정보, 다른 사용자 데이터를 메일 본문에 넣지 말 것. 토큰이 든 URL과 본문을 앱 로그에 남기지 않음(SECURITY 보안 이벤트 기록). 존재하지 않는 주소의 재설정·가입 요청에도 화면 응답은 같게(SECURITY 남용 방지, 문구는 UI_COPY).

## 개발·테스트

- 개발·staging에서 실제 사용자 주소로 발송 금지. 로컬 캐치올 SMTP(예: Mailpit)나 발송 서비스 샌드박스를 쓰고, 운영 외 환경의 발송 함수에 수신자 허용 목록 가드를 둘 것(키트 규칙). 운영 데이터 복사 금지는 OPERATIONS 환경과 설정 절.
- 테스트 수신자는 `example.com`(null MX `0 .`) 또는 SES 메일박스 시뮬레이터(`success@`·`bounce@`·`complaint@simulator.amazonses.com`, 바운스·신고 지표에 미반영). 운영과 개발의 발송 키 분리(SECURITY).
- 자기 도메인으로 모의 피싱이나 시험 캠페인 발송 금지(Google: 도메인 평판 하락·차단 목록 등재 위험).
- 템플릿 렌더 테스트: 템플릿마다 필수 변수 누락·빈 값·긴 이름·HTML 특수문자 이스케이프(SECURITY 출력 인코딩), `text/plain` 파트 존재, 링크가 운영 도메인 절대 URL, 만료 시각 문구가 설정값과 일치하는지 확인.

## 검증

| 확인 | 방법 | 통과 기준 |
| --- | --- | --- |
| SPF | `dig +short TXT bounce.mail.example.com` | `v=spf1` 레코드 1개, 발송 서비스 값 포함 |
| DKIM | `dig +short TXT <selector>._domainkey.mail.example.com` (CNAME이면 대상까지) | `p=` 공개 키 존재 |
| DMARC | `dig +short TXT _dmarc.example.com` | `v=DMARC1`, 현재 단계의 `p=`, `rua=` |
| PTR | `dig +short -x <발송 IP>` 뒤 결과 호스트를 `dig +short A` | 원래 IP로 돌아옴(전용 IP·자체 서버만) |
| 인증 결과 | Gmail·네이버 테스트 계정으로 받아 원본의 `Authentication-Results`(RFC 8601) 확인 | `spf=pass`, `dkim=pass header.d=<From과 정렬된 도메인>`, `dmarc=pass` |
| 원클릭 | `curl -si -X POST -d 'List-Unsubscribe=One-Click' '<URI>'`(쿠키 없이) | 2xx, `Location` 없음, 수신 거부 목록 반영. GET은 구독 유지 |
| 내용 | 템플릿 테스트, 이미지 끈 상태와 다크모드 클라이언트에서 열기 | 텍스트만으로 과업 가능, 대비 유지 |
| 개발 가드 | 개발 환경에서 허용 목록 밖 주소로 발송 시도 | 차단과 로그 |
| 바운스 | 시뮬레이터 `bounce@`로 발송 | 수신 거부 목록 추가, 재발송 없음 |

- 사람 로그인이 필요한 확인: Postmaster Tools(도메인 DNS 인증 후 스팸률·준수 상태 대시보드), Yahoo CFL 등록, DMARC 집계 보고서 검토, 발송 서비스 대시보드. 실행하지 못했으면 "미실행: 사유"로 보고하고 결과를 추정하지 말 것.

## 근거와 한계

확인일 2026-10-01. 별도 표시가 없으면 원문 직접 확인.

- Google, [Email sender guidelines](https://support.google.com/mail/answer/81126) (모든 발신자·5,000통 요건, 원클릭 헤더 예, 표시 이름, IP 분리, 4.7.28, 0.10%·0.30%), [Email sender guidelines FAQ](https://support.google.com/mail/answer/14229414) (대량 발신자 정의·영구 지위, 2025-11 집행 강화, 48시간, 트랜잭션 제외, 정렬 권고), [Feedback Loop](https://support.google.com/mail/answer/6254652), [Set up BIMI](https://knowledge.workspace.google.com/admin/security/set-up-bimi), [Gmail CSS support](https://developers.google.com/workspace/gmail/design/css) (2026-09-15 갱신), [Compute Engine, Sending email from an instance](https://docs.cloud.google.com/compute/docs/tutorials/sending-mail) (2026-09-28 갱신).
- Yahoo, [Sender Best Practices](https://senders.yahooinc.com/best-practices/) (모든·대량 발신자 요건, 2일, 유형별 IP·DKIM 분리, CFL; 갱신일 표시 없음).
- 네이버 메일 공지 대량메일발송정책 분류: [스팸 의심 메일 차단 강화](https://notice.naver.com/notices/mail/15568) (2024-04-17 등록, 2025-11-06 수정), [수신 서버 IP 직접 지정 해제](https://notice.naver.com/notices/mail/34510) (2026-09-30, MX 조회 방식, 기존 서버 2026-11-30 종료), [PTR 등록](https://notice.naver.com/notices/mail/715) (2019-11-27). 고객센터 [대량 메일 조치 방법](https://help.naver.com/service/30029/contents/21288), [발송 IP 및 서버 관리 가이드](https://help.naver.com/service/30029/contents/21286).
- IETF: RFC 7208(SPF), RFC 6376(DKIM), RFC 8301(DKIM 키·알고리즘), RFC 9989(DMARC, 2026-05, RFC 7489·9091 대체), RFC 9990(집계 보고서), RFC 9991(실패 보고서), RFC 7489(이전 DMARC, 정렬 기본값 대조용), RFC 2369, RFC 8058, RFC 8461, RFC 8460, RFC 8617, RFC 8601, RFC 5321, RFC 2046. 원문은 https://www.rfc-editor.org/rfc/rfcNNNN. BIMI는 [draft-brand-indicators-for-message-identification-14](https://datatracker.ietf.org/doc/draft-brand-indicators-for-message-identification/) (2026-05-01, individual).
- AWS SES 개발자 안내서: [Deliverability](https://docs.aws.amazon.com/ses/latest/dg/send-email-concepts-deliverability.html), [Account-level suppression list](https://docs.aws.amazon.com/ses/latest/dg/sending-email-suppression-list.html), [Enforcement FAQ](https://docs.aws.amazon.com/ses/latest/dg/faqs-enforcement.html), [Custom MAIL FROM](https://docs.aws.amazon.com/ses/latest/dg/mail-from.html), [DMARC](https://docs.aws.amazon.com/ses/latest/dg/send-email-authentication-dmarc.html), [Dedicated IPs](https://docs.aws.amazon.com/ses/latest/dg/dedicated-ip.html), [Mailbox simulator](https://docs.aws.amazon.com/ses/latest/dg/send-an-email-from-console.html). Postmark, [Message Streams](https://postmarkapp.com/support/article/1207-how-to-create-and-send-through-message-streams). 업체 선택을 권하는 인용이 아님.
- W3C [WAI-ARIA 1.2](https://www.w3.org/TR/wai-aria-1.2/#presentation) (Recommendation, 2023-06-06), [WCAG Technique F46](https://www.w3.org/WAI/WCAG22/Techniques/failures/F46). OWASP [Forgot Password Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html), ASVS 5.0.0 6.3.7.

오용 주의와 미확인 사항:
- 다음·카카오 메일의 발신자 정책 공식 문서는 찾지 못함(미확인). Yahoo 대량 발신자 수치와 집행 시점, 네이버 대량 기준 수치와 스팸 신고 횟수도 미확인이라 본문 수치로 쓰지 않음.
- Google 요건은 개인 Gmail 계정 수신에만 적용되고 Workspace 수신에는 적용되지 않음. SES 바운스·신고 기준은 SES 계정 정책이라 다른 발송 서비스에 옮기지 말 것.
- 메일 클라이언트별 다크모드 색 변환과 Gmail 메시지 잘림 크기는 공식 문서로 확인하지 못함(미확인). 다크모드 규칙은 지원 미디어 기능 목록에서 추론한 키트 해석.
- 키트 규칙·기본값(출처가 정한 값이 아님): 발송 서비스 기본 사용, 관계 메일 원클릭, `~all` 시작, DMARC 감시 4주, 첫 발송부터 대량 기준 충족, 큐·멱등 키·웹훅 서명 검증, 재발송 60초·시간당 5회, 추적 도메인, 트랜잭션 추적 끄기, GET 확인 화면, 개발 허용 목록 가드.
