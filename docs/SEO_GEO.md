# 검색·생성형 검색 노출 (SEO·GEO)

로그인 없이 열리는 공개 페이지(랜딩, 소개, 가격, 문서, 글, 상품)가 있는 웹 프로젝트에 적용. 로그인 뒤 도구만 있고 공개 페이지가 없으면 제외하되, 스테이징·관리자 경로의 비노출 처리는 아래 표를 따를 것.
공유 미리보기(OG)·공유 이미지·Core Web Vitals 수치는 [시각 에셋](VISUAL_ASSETS.md), 화면 문구는 [화면 문구](UI_COPY.md), 제목 계층·`lang`은 [접근성](ACCESSIBILITY.md), 보안 헤더·WAF·비밀값은 [보안](SECURITY.md), 분석 도구 동의·쿠키는 [개인정보·법적 고지](PRIVACY_LEGAL.md), 로그 보존은 [운영](OPERATIONS.md)이 맡음.
Google은 AI Overviews·AI Mode 노출에 추가 요구사항이나 특별 최적화가 없고 "GEO/AEO"도 SEO의 일부라고 밝힘(Google AI features, AI optimization guide). 그래서 이 문서는 크롤링·색인 기본기를 먼저 두고 생성형 검색 고유 항목은 그 위에 얹음.

## 크롤링과 색인

| 대상 | 처리 | 근거 |
| --- | --- | --- |
| 스테이징·프리뷰 배포 | 인증(플랫폼 보호나 HTTP 인증)으로 막고 `X-Robots-Tag: noindex` 병행 | robots.txt는 접근 권한 수단이 아님(RFC 9309), 차단된 URL도 설명 없이 색인될 수 있음(Google) |
| 관리자·계정·결제 화면 | 인증 + `noindex`. robots.txt에 경로를 나열하면 경로가 공개되므로 넣지 않음(키트 규칙) | Google robots.txt intro, 네이버 robots.txt 가이드 |
| 사이트 내 검색 결과, 필터·정렬 조합 URL | `noindex` 또는 robots.txt 크롤 제외 | 매개변수가 많은 저가치 URL은 크롤 낭비(Bing 21항) |
| 없는 URL·삭제한 글 | 404 응답. 오류 화면을 200으로 주는 soft 404 금지 | Google JS SEO, 네이버 색인 효율성 |
| 점검·일시 장애 | 503 | 네이버 색인 효율성 |
| 영구 이동 / 2일 미만 이동 | 301 / 302 | Bing 7항 |

- `noindex`를 건 페이지는 robots.txt로 막지 말 것. 막으면 크롤러가 태그를 읽지 못해 색인에 남음(Google, OpenAI 퍼블리셔 FAQ). JS로 나중에 `noindex`를 넣거나 빼지 말고 서버 응답에서 결정(Google은 `noindex`를 보면 렌더링을 건너뛸 수 있음).
- robots.txt: 호스트·프로토콜·포트마다 루트 `/robots.txt`, UTF-8 `text/plain`, 500 KiB 이하, 2xx 응답. 5xx를 주면 Google은 크롤을 멈추고 네이버는 '모두 비허용'으로 해석하며, HTML을 돌려주면 네이버는 규칙 없음으로 볼 수 있음. SPA 폴백 라우팅이 `/robots.txt`·`/sitemap.xml`을 `index.html`로 덮지 않는지 확인. Google은 최대 24시간 캐시하므로 변경 효과는 지연될 수 있음.
- 렌더링에 필요한 JS·CSS·파비콘 경로는 차단하지 말 것(Google 모바일 우선 색인, 네이버 JS 가이드). 크롤러는 IP로 차단하지 말고 robots.txt로 제어(네이버: IP 대역은 예고 없이 바뀜).
- 사이트맵: XML, UTF-8, 절대 URL, 200을 주는 canonical URL만 포함. 파일당 50,000 URL·10MB 미만(Google 50MB, 네이버 제출 한도 10MB 중 엄격한 쪽), 넘으면 사이트맵 인덱스. `lastmod`는 실제 의미 있는 수정일만, `priority`·`changefreq`는 Google이 무시하므로 값에 의미를 두지 말 것. robots.txt에 `Sitemap: https://...` 행 추가.
- 글·뉴스형 사이트는 본문 전체를 담은 RSS 2.0도 생성해 네이버에 제출(item 1개 이상, 10MB 미만, 모든 URL이 소유 확인한 도메인).
- 렌더링: 제목·설명·canonical·본문 핵심 문단·내부 링크는 서버 응답 HTML(SSR 또는 정적 생성)에 포함. 근거는 Google("모든 봇이 JS를 실행하지는 않음"), 네이버(SPA라도 주요 영역은 SSR 권장), Bing(핵심 콘텐츠를 클라이언트 렌더링 뒤에 숨기지 말 것). AI 크롤러의 JS 실행 여부는 공식 문서에서 확인하지 못했으므로(미확인) 서버 HTML을 기준으로 둠.
- 링크는 `<a href="...">`. `onClick`만 있는 링크와 `#`·`#!` 라우팅 금지, History API 경로 사용(Google, 네이버: fragment는 제거하고 수집).
- 모바일 우선 색인: 반응형 기본. 모바일과 데스크톱의 본문·title·description·robots meta·구조화 데이터를 같게 두고, 사용자 조작 뒤에야 불러오는 본문을 두지 말 것.

## canonical과 URL

- 색인 대상 페이지마다 `<head>`에 절대 URL의 `rel="canonical"` 1개, 자기 자신 또는 대표 URL을 가리킴(Google은 선택이라 하지만 키트 기본값으로 채택). `og:url`·사이트맵·hreflang의 URL과 일치시킬 것.
- 중복 통합 신호의 강도는 리디렉트 > canonical > 사이트맵 순(Google). 대표 호스트 하나를 정해 `http`→`https`, `www` 유무 변형을 301 한 번으로 보냄. 사이트 메인은 canonical보다 HTTP 리디렉트 권장(네이버).
- canonical 목적으로 robots.txt나 `noindex`를 쓰지 말 것(Google).
- URL은 소문자, 내용을 설명하는 경로(`/guide/creator`), 매개변수 최소(네이버). 세션·추적 매개변수를 내부 링크에 넣지 말고, 주소를 바꾸면 301로 이어 줄 것(Bing 20항).

## 페이지 메타

| 요소 | 규칙 | 근거 |
| --- | --- | --- |
| `<title>` | 페이지마다 고유, 주제를 설명하는 문구, 사이트명은 앞이나 뒤에 구분자(`-`, `:`, `|`)와 한 번. 같은 단어 2회 이상 반복, 홍보 문구 나열, 노출 목적의 잦은 변경 금지. 글자 수 상한은 공식 수치 없음 | Google title link, 네이버 콘텐츠 마크업 |
| `meta name="description"` | 페이지마다 고유, 1~2문장, 본문 복사·제목과 동일·키워드 나열 금지. 길이 제한 없음, 실제 표시 문구는 엔진이 고름 | Google snippet, 네이버 |
| `meta name="robots"` | 색인 대상은 생략(기본 index,follow). 비노출 대상만 위 표대로 | 네이버 선호 URL·로봇 메타 |
| `meta name="keywords"` | 넣지 않음 | Google SEO Starter Guide: 사용하지 않음 |
| OG 태그·공유 이미지 | VISUAL_ASSETS 표를 따름. 네이버는 `og:image`를 검색 썸네일로 쓸 수 있어 150×150 초과, 5,000 byte 이상, 가로세로비 3:1 이하, 페이지 고유 이미지 | 네이버 콘텐츠 마크업 |
| hreflang (다국어일 때만) | 각 언어판이 자신과 다른 모든 언어판을 상호 나열, ISO 639-1 언어(+선택 ISO 3166-1 alpha-2 지역), 절대 URL, 폴백은 `x-default` | Google localized versions |

- 프레임워크 기본 제목("React App", "Vite + React" 등)과 빈 description이 운영 빌드에 남지 않게 할 것(키트 규칙). 제목·설명 문안은 UI_COPY 편집 기준 적용.
- 제목 계층은 ACCESSIBILITY를 따름. Google은 제목 순서가 순위에 영향이 없다고 하지만 Bing은 논리적 H1~H6 구조를 권장함.

## 구조화 데이터

- 형식은 JSON-LD(`<script type="application/ld+json">`). Google 권장 형식이고 네이버도 JSON-LD·Microdata를 권장.
- 화면에 보이는 내용만, 보이는 값과 같게 마크업. 숨긴 내용 마크업 금지, 사용하는 기능의 필수 속성은 모두 채울 것. 올바른 마크업도 리치 결과 표시를 보장하지 않고, 위반하면 수동 조치로 리치 결과 자격을 잃음(Google 일반 가이드라인).
- 생성형 AI 검색에는 구조화 데이터가 필수가 아니고 전용 schema도 없음(Google AI optimization guide). 리치 결과 자격과 엔티티 명확화 용도로만 사용.

| 페이지 | 유형 (schema.org) | 주요 속성 |
| --- | --- | --- |
| 홈 | `Organization`, `WebSite` | `name`, `url`, `logo`, `sameAs`(공식 채널). `WebSite`의 `name`은 Google 사이트 이름 후보 |
| 글·문서 | `Article` | `headline`, `author`, `datePublished`, `dateModified`, `image` |
| 상품 상세 | `Product` + `Offer` | `name`, `image`, `offers.price`, `priceCurrency`(`KRW`), `availability` |
| 계층이 있는 페이지 | `BreadcrumbList` | 화면의 이동 경로와 같은 순서 |
| 쓰지 않음 | `FAQPage`, `HowTo` | Google에서 HowTo는 2023-09 제거, FAQ는 2026-05-07부터 미표시(2026-06 문서 삭제). 다른 유형도 Search Central 변경 기록에서 폐기 여부 확인 |

## 콘텐츠

- 사람 우선(Google helpful content): 방문자가 직접 왔을 때도 유용한지 기준으로 작성. 작성자·게시일·수정일을 화면에 표시하고, 자동화·AI 작성 사용이 방문자에게 드러나게 할 것(Who·How·Why).
- 남의 글 요약이나 누구나 쓸 수 있는 일반론 대신 직접 경험·자체 데이터·제품 고유 정보 위주(Google: non-commodity content).
- 스팸 정책 위반 금지, 생성형 AI 답변에도 동일 적용(2026-05 명시): 검색어 변형마다 페이지 대량 생성(지역명×서비스명 등, scaled content abuse), 봇과 사람에게 다른 내용(cloaking), 숨긴 텍스트, 키워드 반복(keyword stuffing), 도어웨이. 생성형 AI로 페이지를 만들면 사실 검토 뒤 공개하고, 가치 없이 다수 생성하지 말 것(Google 생성형 AI 콘텐츠 안내). AI 생성 이미지 표시는 VISUAL_ASSETS.
- 한 URL에 한 주제, 핵심 답과 정보는 위쪽에(Bing 17·18항). 소제목·첫 문단 배치는 UX_DESIGN의 F-pattern 대응 규칙과 같음.
- 사실·정의를 문장으로 명시하고 외부 문맥 없이 그 페이지만으로 확인 가능하게(Bing 15항). 사람·조직·제품 이름은 페이지 전체에서 같은 표기(Bing 16항).
- 이미지·영상만으로 정보를 전달하지 말고 같은 내용을 텍스트로도 둘 것(Bing 12항, Google AI features: 텍스트 중심).
- 사실이 바뀌면 본문·`dateModified`·사이트맵 `lastmod`를 함께 갱신. 분량 목표는 두지 않음(Google: 선호하는 단어 수 없음).

## 검색엔진 등록

| 엔진 | 등록·소유 확인 | 수집 로봇 | 제출 | 비고 |
| --- | --- | --- | --- | --- |
| Google | Search Console (사람 로그인) | `Googlebot` | Sitemaps 보고서 또는 robots.txt `Sitemap:` | 설정 > Search 생성형 AI 항목은 기본 '포함' |
| 네이버 | 서치어드바이저 웹마스터도구. 호스트 단위 등록, meta 태그 또는 HTML 파일로 확인. JS·meta refresh로 리디렉트되는 메인이나 frame 안 태그는 확인 불가 | `Yeti` (역 DNS가 `.naver.com`) | 요청 > 사이트맵 제출, RSS 제출 | 방문 후 최대 1주 내 반영, `site:도메인`으로 확인 |
| 다음 | Daum 웹마스터도구 PIN 코드 발급(이용 동의 24개월 후 초기화) | robots.txt 토큰 `DAUM` (고객센터) | 미확인 | 인증키를 robots.txt에 넣는 방식은 2차 출처로만 확인(미확인) |
| Bing | Bing Webmaster Tools | `Bingbot` | 사이트맵, IndexNow | 같은 색인이 Copilot·grounding API에도 쓰임 |

- IndexNow: 루트에 `{key}.txt`(키 8~128자, 영숫자와 `-`)를 두고 글 게시·수정·삭제 때 URL을 GET 또는 POST JSON(요청당 최대 10,000개)으로 전송, 200·202면 성공. 제출 URL은 참여 엔진에 공유되며 참여 목록에 Bing·네이버·Yandex·Seznam·Yep 등이 있고 Google은 없음(indexnow.org searchengines.json). 정적 사이트처럼 배포 훅이 없으면 사이트맵만으로 충분.

## 생성형 검색(GEO)

- 노출 조건은 색인과 스니펫 허용(Google: 색인되고 스니펫과 함께 표시 가능한 페이지). Google에서 `nosnippet`·`max-snippet`·`data-nosnippet`(`span`·`div`·`section`에만)은 AI Overviews·AI Mode의 입력도 제한함. Bing은 `NOARCHIVE`면 Copilot 답변에 쓰지 않고 `NOCACHE`면 URL·제목·스니펫만 씀. 네이버 `nosourceinfo`는 AI 자동 생성 출처설명을 끔. 노출을 원하는 페이지에는 이 지시자를 쓰지 말 것.
- 인용되기 쉬운 구조(Bing 15~18항, Aggarwal et al. 2024): 질문이나 주제를 담은 소제목 바로 아래 1~3문장의 직접 답, 수치에는 단위·기준일·출처 링크, 비교는 HTML `<table>`, 인용은 출처와 함께. 수치·인용은 검증 가능한 출처가 있을 때만 넣고 만들어 내지 말 것(키트 규칙).
- Google 기준으로 하지 않아도 되는 일: llms.txt 같은 AI 전용 파일, 내용을 잘게 쪼개는 chunking, AI용 재작성, 비진정성 언급 확보(Google AI optimization guide).
- AI 크롤러 정책은 아래 표의 열 단위로 정해 프로젝트 `decisions.md`에 날짜와 함께 기록. 키트 기본값은 검색·답변 노출 허용, 학습 수집은 프로젝트 결정. 공식 문서로 확인한 토큰만 사용.

| 운영사 | 검색·답변 노출 | 사용자 요청 시 가져오기 | 모델 학습 수집 |
| --- | --- | --- | --- |
| Google | `Googlebot` (AI Overviews·AI Mode 포함, 제외는 Search Console 설정이나 snippet 지시자) | 해당 없음 | `Google-Extended`: Gemini 학습과 Gemini 앱·Vertex AI grounding 제어, Google 검색 포함·순위와 무관 |
| OpenAI | `OAI-SearchBot`: 막으면 ChatGPT 검색 답변에서 빠짐(링크·제목만 나올 수 있어 완전 제외는 `noindex`) | `ChatGPT-User`: robots.txt가 적용되지 않을 수 있음 | `GPTBot` |
| Anthropic | `Claude-SearchBot` | `Claude-User` (robots.txt 준수) | `ClaudeBot` |
| Perplexity | `PerplexityBot` (학습에 쓰지 않음) | `Perplexity-User`: 대체로 robots.txt 무시 | 공식 문서에 별도 학습 크롤러 없음 |
| Apple | `Applebot` (Spotlight·Siri·Safari) | 해당 없음 | `Applebot-Extended`: 크롤링하지 않고 Applebot 수집분의 학습 사용만 제어 |
| Common Crawl | 해당 없음 | 해당 없음 | `CCBot`: 공개 크롤 데이터셋. 공식 페이지는 AI 학습 용도를 명시하지 않음 |

검색·답변 노출은 허용하고 학습 수집만 막는 예. 전용 그룹이 있는 크롤러는 `*` 그룹을 읽지 않으므로(RFC 9309 §2.2.1) 공통 차단 경로가 있으면 각 그룹에 반복할 것.

```txt
User-agent: GPTBot
User-agent: ClaudeBot
User-agent: Google-Extended
User-agent: Applebot-Extended
User-agent: CCBot
Disallow: /

User-agent: *
Allow: /

Sitemap: https://example.com/sitemap.xml
```

- robots.txt는 요청일 뿐 강제 수단이 아니고, 사용자 요청형 가져오기는 무시할 수 있으며 UA 위장도 있음(Common Crawl). 실제 차단이 필요하면 SECURITY의 WAF·레이트 리밋으로 처리하고 이 표에는 의도만 기록.
- llms.txt: Jeremy Howard의 제안(2024-09-03, v2 2026-08-10)이며 표준화 기구 문서가 아님. Google 검색은 사용하지 않고 순위에 영향도 없음. OpenAI·Anthropic·Perplexity의 크롤러 문서에는 사용 언급이 없음(지원 여부 미확인). 키트 기본값은 만들지 않음. 개발자 문서·API처럼 에이전트가 읽을 이유가 있는 사이트만 `decisions.md`에 이유를 남기고 추가하며, 내용은 공개 페이지와 일치시킬 것.

## 측정

- Google Search Console: 실적 보고서의 웹 검색 유형에 AI Overviews·AI Mode 집계 포함, 생성형 AI 실적 보고서(노출수, 2026-08-31 전체 사이트 제공), 페이지 색인·URL 검사·Sitemaps·robots.txt 보고서.
- 네이버 서치어드바이저: 콘텐츠 노출 및 클릭 리포트, `site:` 질의.
- ChatGPT 검색 유입은 referral URL의 `utm_source=chatgpt.com`으로 구분(OpenAI 퍼블리셔 FAQ). Perplexity·Claude 등 다른 AI 유입을 식별하는 공식 문서는 찾지 못해 referrer 도메인 집계는 참고값으로만 사용(미확인). 분석 도구 도입·동의는 PRIVACY_LEGAL, 지표 정의는 PRODUCT_PLANNING.
- 서버 로그로 크롤러 방문을 볼 때 UA만 믿지 말고 역 DNS(네이버)나 공개 IP 목록(Perplexity, Common Crawl)으로 확인. 로그 보존 기간은 OPERATIONS.

## 검증

| 항목 | 방법 | 통과 기준 |
| --- | --- | --- |
| robots.txt | `curl -sI`와 본문 확인, 필요하면 Google 오픈소스 robots.txt 파서 | 200, `text/plain`, 500 KiB 이하, HTML 아님, `decisions.md`의 크롤러 정책·`Sitemap:` 행과 일치 |
| 스테이징 비노출 | 프리뷰 URL `curl -sI` | 401·403 또는 `X-Robots-Tag: noindex` |
| 운영 noindex 누락 | 운영 빌드 HTML에서 `noindex` 검색 | 색인 대상 페이지 0건 |
| 서버 HTML | `curl -s URL` (JS 미실행) | `<title>`, description, canonical, 본문 핵심 문단, 내부 `<a href>` 존재 |
| 렌더 HTML | headless 렌더 DOM과 `curl` 결과 비교 (UI_VALIDATION) | 핵심 본문·링크 차이 없음, 모바일 폭에서도 동일 |
| 상태 코드 | 없는 URL, 삭제 URL, `http`·`www` 변형 요청 | 404, canonical로 301 한 번 |
| canonical·메타 | 색인 대상 전수 수집 스크립트 | canonical 절대 URL 1개이고 200, title·description 중복 0·빈 값 0·기본 템플릿 제목 0 |
| 사이트맵 | `xmllint --noout`, URL 수·용량, URL별 상태 | 유효 XML, 50,000개·10MB 미만, 전부 200·canonical·`noindex` 없음 |
| 구조화 데이터 | Rich Results Test, Schema Markup Validator, CI에서 JSON 파싱 | 오류 0, 값이 화면 텍스트와 일치, 폐기 유형 없음 |
| hreflang | 언어판 쌍 상호 링크 검사 | 누락 0 |
| 엔진 등록·제출 | Search Console·서치어드바이저·Bing의 사이트맵 처리 상태 | 사람 로그인이 필요하므로 에이전트는 "미실행(로그인 필요)"과 사유를 기록, 자동 검사 통과로 보고하지 말 것 |
| IndexNow | 키 파일 응답, 제출 응답 코드 | 200, 제출 200·202 |

## 근거와 한계

확인일 2026-10-01. 별도 표시가 없으면 원문 직접 확인.

- Google Search Central (developers.google.com/search/docs): AI features and your website(2025-12-10 갱신), Optimizing your website for generative AI features(ai-optimization-guide, 2026-07-10), Search Essentials·technical requirements·spam policies(2026-08-28), SEO Starter Guide, title link, snippet(2026-04-20), consolidate duplicate URLs, robots.txt intro·how Google interprets robots.txt, block indexing(noindex), build sitemap, JavaScript SEO basics, mobile-first indexing, localized versions(hreflang), structured data intro·general guidelines(2026-07-10)·search gallery, robots meta tag(2026-03-24), creating helpful content, using gen AI content, Google common crawlers(Google-Extended, 2026-07-14), Search documentation updates(https://developers.google.com/search/updates: FAQ 폐기 2026-05-08 공지·2026-06-15 문서 삭제, llms.txt 설명 2026-06-15). Search Console 도움말 16908024(Search 생성형 AI 설정), 16984139(생성형 AI 실적 보고서), 6062598(robots.txt 보고서).
- IETF RFC 9309, Robots Exclusion Protocol (Koster, Illyes, Zeller, Sassman, 2022-09), https://www.rfc-editor.org/rfc/rfc9309.html (§2.2.1: 일치하는 그룹이 없을 때만 `*` 그룹 적용).
- 네이버 서치어드바이저 웹마스터 가이드, https://searchadvisor.naver.com/guide/ (seo-basic-intro, seo-basic-robots, seo-basic-firewall, markup-content, markup-structure, request-feed, seo-advanced-javascript, seo-advanced-indexing, seo-advanced-url, structured-data-intro). 네이버 AI 브리핑에 대한 사이트 운영자용 공식 가이드는 찾지 못함(미확인). 네이버 연관 채널 마크업 형식은 원문을 읽지 않음.
- Daum 웹마스터도구 https://webmaster.daum.net, Daum 고객센터 웹문서 검색 도움말(PIN 코드 발급 38321, robots.txt 제외 28966). Daum 수집 로봇의 전체 UA 문자열과 사이트맵 제출 기능은 미확인.
- Bing Webmaster Guidelines, https://www.bing.com/webmasters/help/webmaster-guidelines-30fba23a (JS 렌더 페이지라 6~21항만 확인, 1~5항 미확인). IndexNow documentation과 searchengines.json, https://www.indexnow.org/.
- OpenAI, Overview of OpenAI Crawlers, https://developers.openai.com/api/docs/bots, Publishers and Developers FAQ, https://help.openai.com/en/articles/12627856. Anthropic, Does Anthropic crawl data from the web(2026-04-07 갱신), https://support.claude.com/en/articles/8896518. Perplexity Crawlers, https://docs.perplexity.ai/guides/bots. Apple, About Applebot(2026-09-04), https://support.apple.com/en-us/119829. Common Crawl CCBot, https://commoncrawl.org/ccbot.
- Aggarwal, P., Murahari, V., Rajpurohit, T., Kalyan, A., Narasimhan, K., Deshpande, A. (2024). GEO: Generative Engine Optimization. KDD '24, doi:10.1145/3637528.3671900, arXiv:2311.09735. 출처 인용·인용문·통계 추가가 GEO-bench(1만 질의)에서 위치 가중 단어 수 기준 30~40%, Perplexity.ai에서 인용문 추가 22% 개선, 키워드 스터핑은 10% 악화.
- Liu, N. F., Zhang, T., Liang, P. (2023). Evaluating Verifiability in Generative Search Engines. Findings of EMNLP 2023, arXiv:2304.09848. 생성 문장의 51.5%만 인용으로 완전히 뒷받침됨.
- llms.txt 제안, https://llmstxt.org/ (Jeremy Howard). 이 페이지의 "Lighthouse가 llms.txt를 점검" 주장은 Chrome 측 문서로 확인하지 않음(미확인). schema.org Organization 등, https://schema.org/ (V30.1).
- GEO 연구의 한계: GPT-3.5와 Google 상위 5개 결과로 만든 모사 엔진 중심이고, 저자 스스로 검색 순위 영향은 측정하지 않았으며 엔진이 바뀌면 효과도 바뀔 수 있다고 밝힘. 효과는 원래 순위가 낮은 출처에서 크고 1위 출처에는 음수였음. 그래서 수치를 목표치로 쓰지 말고 구조 원칙의 참고 근거로만 사용. Liu et al.의 결과처럼 인용된다고 내용이 정확히 전달되는 것도 보장되지 않음.
- 쓰지 않은 것: 키워드 밀도, title·description 글자 수 공식(Google·네이버 모두 상한 없음), 최소 단어 수, E-E-A-T를 직접 순위 요인으로 보는 해석(Google: 직접 요인 아님), AI 전용 chunking. 공식 문서가 부정했거나 1차 근거가 없음. Google은 내부 순위 시스템에 접근하는 서드파티 도구가 없다고 밝히므로 외부 SEO 점수는 판정 기준으로 쓰지 말 것. 크롤러 토큰과 엔진 정책은 자주 바뀌므로 배포 전 각 원문을 다시 확인할 것.
