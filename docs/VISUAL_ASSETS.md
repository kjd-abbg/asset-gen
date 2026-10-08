# 시각 에셋: 아이콘·공유 이미지·일러스트·사진

신규 웹·앱 프로젝트에서 UI 아이콘, 소셜 공유 미리보기 이미지, 일러스트, 사진을 고르거나 만들 때 적용. UI가 없으면 적용 대상에서 제외.
로고·파비콘·앱 아이콘·Manifest 아이콘은 [로고 기준](LOGO_DESIGN.md)이 맡으며 여기서는 다루지 않음. 대체 텍스트·대비 수치는 [접근성 기준](ACCESSIBILITY.md), 렌더 실행은 [UI 검증](UI_VALIDATION.md), 아이콘·일러스트의 색과 크기 단계는 [디자인 토큰 기준](DESIGN_TOKENS.md)을 따를 것.
사용자가 브랜드 자료나 지정 에셋을 주면 그 자료가 우선이며, 이 문서는 선택·검증 기준으로만 사용.

## UI 아이콘: 세트 선택과 라이선스

- 한 프로젝트에 아이콘 세트는 하나(키트 규칙). 세트마다 그리드·선 두께·모서리·끝 처리가 달라 섞으면 같은 화면에서 무게가 어긋남. 세트에 없는 아이콘은 같은 세트의 그리드 규칙으로 직접 그리고 출처를 "자체 제작"으로 기록. 같은 세트 안에서도 outline과 fill 스타일을 임의로 섞지 말 것. fill은 선택 상태처럼 의미가 있을 때만 사용 (SF Symbols HIG: 선택 표시와 탭 바에 fill 변형).
- 같은 의미는 제품 전체에서 같은 아이콘, 같은 아이콘은 같은 의미로 사용. 아이콘 의미가 화면마다 다르면 사용자가 기능을 기대할 수 없음 (NN/g Icon Usability).
- 채택 전 공식 저장소의 LICENSE를 열어 확인하고 세트 이름, 버전, 라이선스, 저작권자를 에셋 목록에 기록. 아래 표는 2026-10-01 확인값이며 버전이 바뀌면 다시 확인할 것.

| 세트 | 라이선스 (저작권자) | 비고 |
| --- | --- | --- |
| Lucide | ISC, Feather 유래 아이콘은 MIT (Cole Bemis) | LICENSE 파일에 MIT 적용 아이콘 목록이 따로 있음 |
| Heroicons | MIT (Tailwind Labs, Inc.) | |
| Tabler Icons | MIT (Paweł Kuna) | |
| Material Symbols / Material Icons | Apache License 2.0 (Google) | 출처 표기는 권장, 필수 아님(README) |
| SF Symbols | Apple 약관 | 앱 아이콘·로고·상표 용도의 사용 금지를 HIG가 명시. Apple 제품을 그린 심볼은 수정 불가. 웹 사용 가능 여부는 약관 원문 미확인이므로 웹 프로젝트에서는 쓰지 않음 |

## UI 아이콘: 그리드·크기·선

| 출처 | 그리드·크기 | 선·형태 |
| --- | --- | --- |
| Material Design 2 system icons | 24×24dp, 내용은 20×20dp live area, 둘레 2dp 패딩. 데스크톱 밀집 배치는 20dp(live area 16dp) | 선 두께 2dp 일정, 각진 끝 처리, 가는 선 금지 |
| Material Symbols | optical size 20~48dp(기본 24), weight 100~700(기본 400), grade -50~200, fill 0~1 | 축 값은 화면 전체에서 같은 값으로 고정(키트 규칙) |
| Lucide | 24×24px 캔버스, 가장자리와 1px 이상 간격 | 선 2px, 둥근 끝·둥근 이음, 요소 사이 2px 이상, 8px 이상 도형은 반경 2px |
| IBM Carbon | 기본 16px, UI에서 20·24·32px도 사용. 16·20px은 14·16px 본문과 짝 | 단색. 텍스트 옆 아이콘은 세로 가운데 정렬(baseline 정렬 금지), 텍스트 색과 같은 색 |
| SF Symbols | 9개 weight가 시스템 폰트 weight와 대응, small·medium·large scale은 cap height 기준 | 인접 텍스트와 같은 weight를 골라 굵기를 맞춤 |

- 크기는 세트의 기준 그리드(대개 24)와 그 정수 배 또는 세트가 정한 밀집 크기만 사용하고 실제 단계 값은 디자인 토큰에 둘 것. 20px 그리드 아이콘을 23px로 늘리는 식의 임의 배율은 선이 픽셀 경계에서 뭉개짐(키트 규칙). 아이콘 크기와 터치 대상 크기는 분리. 아이콘은 24px라도 버튼은 ACCESSIBILITY 포인터·터치 대상 표(웹 24×24 CSS px 최소, 앱 44pt/48dp 권장)를 패딩으로 맞출 것.

## UI 아이콘: 라벨 병행과 구현

- 기본은 보이는 텍스트 라벨과 아이콘 병행. 라벨은 hover 없이 항상 보이게 (NN/g: 보편적으로 인식되는 아이콘은 소수이고 대부분은 모호함).
- 떠올리는 데 5초 넘게 걸리는 개념은 아이콘으로 표현하지 말고 텍스트로 (NN/g 5초 규칙). GOV.UK는 대부분의 경우 아이콘 회피를 권고하고, 자주 반복 사용하는 업무 시스템에서만 유용하다고 봄.
- 아이콘만 쓰는 버튼은 닫기·검색·메뉴·더보기처럼 제품 안에서 반복되는 동작에 한정하고(키트 규칙), 접근 가능한 이름과 툴팁을 함께 제공.
- 형식은 인라인 SVG나 같은 출처의 SVG 스프라이트(`<symbol>` + `<use href="#id">`). 아이콘 폰트는 사용자가 글꼴을 덮어쓰면 사라질 수 있어 기본값에서 제외 (WCAG 기법 ARIA24). 이미 쓰는 프로젝트라면 ARIA24대로 `role="img"`로 표시. 인라인과 스프라이트 선택 기준은 출처가 없음(키트 규칙): 컴포넌트 프레임워크면 아이콘별 컴포넌트로 트리 셰이킹, 정적 페이지에서 같은 아이콘이 반복되면 스프라이트. 외부 도메인 스프라이트는 쓰지 말 것.
- 색은 `fill="currentColor"` 또는 `stroke="currentColor"`로 부모 `color`를 상속 (CSS Color 4 §6.4). SVG 안에 색값을 하드코딩하지 말고 다크 테마는 토큰의 `color` 변경으로 처리. `<img src="*.svg">`나 CSS 배경으로 넣은 SVG는 문서의 `color`를 상속하지 않으므로 색이 상태에 따라 바뀌는 아이콘에는 쓰지 말 것. `viewBox`는 세트 그리드 그대로(`0 0 24 24`) 두고 `width`/`height`는 사용처에서 지정. SVG 금지 요소와 좌표 정리는 LOGO_DESIGN의 SVG 작성 규칙을 따름.
- 텍스트와 함께 있는 장식 아이콘: SVG에 `aria-hidden="true"`, 이름은 텍스트가 담당 (ARIA24).
- 아이콘만 있는 버튼·링크: 이름은 `<button>`·`<a>`에 `aria-label`이나 시각적으로 숨긴 텍스트로 주고 내부 SVG는 `aria-hidden="true"`. 이름은 모양이 아닌 기능("X" 대신 "닫기") (APG Names and Descriptions; WAI Images Tutorial functional images).
- 컨트롤 밖에서 단독으로 정보를 주는 SVG(상태 표시 등): `role="img"`와 `aria-label` 또는 `aria-labelledby` (APG). 인접 텍스트가 같은 정보를 주면 장식으로 처리.
- 대비: 이해에 필요한 아이콘은 인접 색과 3:1 이상 (WCAG 1.4.11, 측정 방식은 ACCESSIBILITY). 장식 아이콘은 요구 없음. Carbon은 아이콘에 텍스트와 같은 4.5:1을 요구하므로 더 엄격한 선택지로 참고.

## 소셜 공유 미리보기: 메타 태그

| 태그 | 요구 | 규칙 (출처) |
| --- | --- | --- |
| `og:title` | 필수 (OGP) | 사이트명 없이 페이지 제목 (Meta). 카카오 스크랩 메시지는 최대 2줄 표시 |
| `og:type` | 필수 (OGP) | 일반 페이지 `website`, 글 `article`. Meta는 미지정 시 `website` |
| `og:image` | 필수 (OGP) | `https` 절대 URL, 로그인·쿠키 없이 접근 가능할 것 |
| `og:url` | 필수 (OGP) | canonical URL. 세션·추적·사용자 식별 파라미터 제거 (Meta). canonical 규칙은 [SEO_GEO](SEO_GEO.md) |
| `og:description` | OGP 선택, Meta·LinkedIn·카카오가 사용 | 2~4문장 이내 (Meta). 카카오는 최대 2줄 표시 |
| `og:image:alt` | `og:image`가 있으면 지정 (OGP) | 이미지가 전하는 정보. 작성 기준은 대체 텍스트 절 |
| `og:image:width`, `og:image:height` | 권장 (Meta) | 첫 공유 때 크롤러가 비동기 처리 없이 바로 렌더 |
| `og:site_name`, `og:locale` | 선택 | 카카오는 `og:site_name`을 버튼 영역에 표시하고 없으면 도메인 표시. 한국어 페이지는 `ko_KR` |
| `twitter:card` | X 필수 | `summary_large_image`. 나머지는 X가 OG 태그로 대체 처리 |
| `twitter:image:alt` | 선택 | 최대 420자 |

- 메타 태그는 서버 응답 HTML의 `<head>`에 둘 것. 크롤러가 JS를 실행한다는 보장이 없으므로 클라이언트 렌더링으로만 넣지 말 것(키트 규칙).
- 콘텐츠 페이지는 페이지마다 고유 이미지, 사이트 공통 이미지는 폴백으로만 사용. X 문서는 여러 페이지에 걸친 로고·작성자 사진 같은 일반 이미지 사용을 피하라고 함. 크롤러 접근: `robots.txt`에서 미리보기 크롤러(예: Twitterbot)를 막지 말고, 방화벽을 쓰면 카카오 스크랩 서버 IP를 허용 (카카오 개발자 문서).

## 소셜 공유 미리보기: 이미지 규격

| 플랫폼 | 크기 | 비율 | 용량·형식 |
| --- | --- | --- | --- |
| Meta(Facebook) | 1200×630 이상 권장, 큰 미리보기 최소 600×315, 허용 최소 200×200 | 1.91:1 | 8MB 이하 |
| X `summary_large_image` | 최소 300×157, 최대 4096×4096 | 2:1 | 5MB 미만, JPG·PNG·WEBP·GIF(첫 프레임). SVG 불가 |
| LinkedIn | 최소 1200×627 | 1.91:1 | 5MB, JPG·PNG·GIF |
| 카카오톡 스크랩 메시지 | 기본 템플릿 최소 200×200, 사용자 정의 템플릿 최소 400×400 | 공식 문서에 없음(미확인) | 5MB 이하 |

- 키트 기본값: 1200×630 JPEG 또는 PNG, 5MB 미만(위 표에서 가장 엄격한 상한). WebP·SVG는 지원이 표마다 달라 공유 이미지에 쓰지 않음.
- 안전 영역(키트 규칙): 플랫폼마다 비율이 달라 가장자리가 잘림. 서비스 이름과 핵심 그림은 중앙 630×630 정사각 안에 두고, 가장자리 60px 안에는 의미 있는 요소를 두지 말 것. 카카오 썸네일 비율이 미확인이라 정사각 중앙을 보수적 기준으로 잡음. 이미지 속 글자는 서비스 이름과 짧은 제목 정도로 최소화하고 같은 내용을 `og:title`에 둘 것. 작은 썸네일에서 읽히지 않는 부제·설명 문단은 넣지 않음.
- 갱신: Meta는 이미지를 URL 기준으로 캐시해 URL이 바뀌기 전에는 갱신하지 않음. 이미지를 바꿀 때 파일명이나 쿼리에 버전을 넣어 URL을 바꿀 것. X는 카드 내용을 7일간 캐시(2024-12 보관본).
- 검증 도구: [Meta Sharing Debugger](https://developers.facebook.com/tools/debug/)는 다시 스크랩해 내용을 갱신, 카카오 [도구] > [카카오톡 URL 메타정보 관리]는 OG 조회·공유 미리보기·캐시 초기화, [LinkedIn Post Inspector](https://www.linkedin.com/post-inspector/). 카카오 도구는 카카오 계정 로그인이 필요하므로 에이전트가 직접 못 쓰면 사람에게 확인을 넘기고 미실행으로 기록.

## 이미지 형식과 성능

| 용도 | 형식 (web.dev) |
| --- | --- |
| 아이콘·단순 도형·일러스트 선화 | SVG |
| 사진, 복잡한 이미지 | AVIF 또는 lossy WebP, 폴백 JPEG |
| 세밀한 디테일·투명이 필요한 래스터(UI 스크린샷 등) | PNG 또는 lossless WebP |
| 움직이는 이미지 | GIF 대신 `<video>` |
| 공유 미리보기 | JPEG 또는 PNG (위 규격 표) |

- 먼저 이미지가 꼭 필요한지, CSS나 텍스트로 대신할 수 있는지 판단 (web.dev 형식 선택 순서, GOV.UK: 실제 사용자 필요가 있을 때만 이미지).
- AVIF는 Chrome 2020, Firefox 2021, Safari 2022부터 지원 (web.dev 2023). `<picture>`에 `<source type="image/avif">`, `<source type="image/webp">`, 마지막 `<img>` JPEG 순으로 폴백 제공(키트 기본값).
- 모든 `<img>`에 `width`·`height` 속성 지정. 브라우저가 이 값으로 비율을 잡아 레이아웃 이동을 막음 (web.dev CLS). `srcset` 후보는 같은 비율로 만들고, 비율이 다른 아트 디렉션은 `<source>`에 `width`·`height` 지정. `srcset`에 너비 서술자(`480w`)를 쓰면 `sizes` 필수. `sizes="auto"`는 `loading="lazy"`일 때만 허용 (HTML Standard img 요소).
- 첫 화면 밖 이미지만 `loading="lazy"`. LCP 후보와 첫 화면 이미지에는 lazy 금지, LCP 이미지에는 `fetchpriority="high"` (web.dev).
- 기준값: LCP 2.5초 이하, CLS 0.1 이하, 모바일·데스크톱 각각 75번째 백분위 (web.dev Core Web Vitals). 측정은 운영 빌드로 하고 개발 모드 수치를 보고하지 말 것(UI 검증). 원본 해상도는 표시 최대 너비의 2배 정도까지만 두고 그 이상은 잘라 낼 것(키트 규칙). 프레임워크 이미지 컴포넌트나 이미지 CDN은 스택 관례를 따르되 위 속성이 출력 HTML에 남는지 확인.

## 일러스트·사진

- 스타일 일관성(키트 규칙): 일러스트는 한 스타일(선 두께, 채색 방식, 인물 표현 수준)로 통일하고 색은 디자인 토큰 팔레트에서만 사용. 아이콘 세트와 선 두께·모서리 성격을 맞출 것. 장식 목적의 이미지와 범용 스톡 사진은 피할 것 (GOV.UK Images).
- 대체 텍스트는 WAI 결정 트리 순서로 판단: 글자가 든 이미지인지 → 링크·버튼의 기능을 이미지가 담당하는지 → 페이지 의미에 기여하는지 → 순수 장식인지. 장식이거나 인접 텍스트와 중복이면 `alt=""`, 차트·복잡한 그림은 정보를 본문이나 표로 따로 제공. 세부는 ACCESSIBILITY 텍스트 대체 절.
- 글자가 든 이미지 금지(WCAG 1.4.5, 로고는 예외). 배너·프로모션 문구는 HTML 텍스트를 이미지 위에 겹치고 대비는 가장 불리한 지점에서 측정.
- 라이선스·출처 기록: 파일마다 출처 URL, 작성자, 라이선스, 내려받은 날짜를 에셋 목록에 기록. 출처를 기록할 수 없는 이미지는 쓰지 않음. 무료 라이선스도 피사체 권리까지 주지 않음. 예로 Unsplash 약관 §5는 이미지 속 상표·로고·브랜드, 식별 가능한 사람, 미술·저작물을 라이선스에서 제외하고 용도에 따라 별도 허락이 필요할 수 있다고 명시.
- 초상권: 대법원은 얼굴 등 특정인을 식별할 수 있는 신체적 특징이 함부로 촬영·공표·영리적으로 이용되지 않을 권리를 헌법 제10조에 근거한 권리로 봄 (대법원 2021. 4. 29. 선고 2020다227455). 식별 가능한 실제 인물 사진은 촬영·사용 동의 기록이 있는 것만 쓰고, 유명인 성명·초상의 상업적 이용(퍼블리시티권) 문제는 법무 확인으로 넘길 것.
- AI 생성 이미지: 저작권 보호 한계와 창작 기여 기록은 LOGO_DESIGN 법적 확인 절을 따름. 실존 인물(유명인 포함), 실존 브랜드·상표·캐릭터를 닮게 만드는 생성은 금지(키트 규칙). 생성 도구·모델·프롬프트·날짜와 사람이 고친 부분을 기록. 생성물 표시 의무(인공지능 기본법 제31조)와 화면 구현 예는 [AI 기능](AI_FEATURES.md) 고지·표시 절, 적용 여부는 법무 확인.
- 플레이스홀더 제거(키트 규칙): 출시 빌드에 임시 이미지 서비스 URL, 회색 더미, "sample"·워터마크가 남은 시안, 저해상도 임시 파일을 남기지 말 것. 임시 파일은 이름에 `placeholder`를 넣어 검색으로 찾을 수 있게 둠.
- 메타데이터: 사진은 게시 전 EXIF의 위치·기기·촬영 시각 정보를 제거 (Welsh Government 2025). 사용자 업로드 이미지를 다시 공개하는 기능이면 서버에서 제거하도록 설계하고, 업로드 사진을 [개인정보·법적 고지](PRIVACY_LEGAL.md)의 개인정보 목록 표에 올릴 것. 색 프로파일(ICC)은 남겨 색이 바뀌지 않게 할 것. 예: `exiftool -all= -tagsfromfile @ -icc_profile -overwrite_original photo.jpg`, 확인은 `exiftool -gps:all -a photo.jpg` 출력이 비어 있는지.

## 산출물

경로는 스택 관례에 맞추고 특정 프레임워크 경로를 공통값으로 쓰지 말 것.
- 에셋 목록 1개(브랜드 문서의 한 절 또는 별도 파일): 파일 경로, 종류(아이콘·공유 이미지·일러스트·사진), 출처 URL 또는 "자체 제작", 작성자, 라이선스, 확인일, 인물·상표 포함 여부와 동의 기록 위치, AI 생성 여부·도구. 아이콘 세트 기록: 세트 이름, 버전, 라이선스, 크기 단계와 사용 스타일(outline/fill 규칙).
- 서드파티 고지 파일: MIT·ISC는 저작권 고지와 허가 문구를 사본에 포함하라고, Apache 2.0은 라이선스 사본 제공을 요구하므로 세트별 고지 문구를 배포물에 포함.
- 공유 이미지: 기본 폴백 1장과 페이지별 생성 방식, 검증 도구 결과 캡처와 실행 일자.

## 검증

| 항목 | 방법 | 통과 기준 |
| --- | --- | --- |
| 아이콘 세트 | 의존성 목록과 저장소의 SVG 출처 검색 | 세트 1개, 에셋 목록에 라이선스 기록 |
| 아이콘 이름 | axe-core와 스크린리더로 아이콘 버튼 탐색 | 모든 아이콘 버튼에 기능 이름, 장식 SVG는 `aria-hidden` |
| 아이콘 대비·크기 | 라이트·다크 테마에서 계산된 색 측정, 버튼 bounding box | 의미 아이콘 3:1 이상, 대상 크기는 ACCESSIBILITY 표 |
| OG 태그 | 배포 URL의 서버 응답 HTML `<head>` 확인(JS 미실행) | 필수 4개, `og:image:alt`, `twitter:card`, 절대 URL |
| 공유 이미지 | 파일 치수·용량, 안전 영역 겹친 렌더 | 1200×630, 5MB 미만, 핵심 요소가 중앙 정사각 안 |
| 미리보기 | Sharing Debugger, 카카오 URL 메타정보 관리, Post Inspector | 의도한 제목·이미지 표시. 미실행 도구는 사유와 함께 기록 |
| 이미지 속성 | 렌더된 DOM에서 `img` 전수 검사 | `width`·`height` 존재, `w` 서술자에 `sizes`, LCP 이미지에 lazy 없음 |
| 성능 | 운영 빌드에서 Lighthouse 또는 web-vitals 측정 | LCP 2.5초·CLS 0.1 이하. 실험실 값과 필드 값을 구분 기록 |
| 대체 텍스트 | 이미지 목록과 결정 트리 판단 대조 | 판단과 `alt` 값 일치 |
| 플레이스홀더 | 빌드 산출물에서 `placeholder`, 임시 이미지 도메인 검색 | 0건 |
| 메타데이터 | `exiftool -gps:all` | 공개 사진에 위치 정보 없음 |
| 에셋 목록 | 에셋 디렉터리 파일과 목록 대조 | 누락 0 |

- 공유 이미지·아이콘 렌더 확인은 headless로 하고 실행 원칙은 UI 검증을 따름. 육안 판단(스타일 일관성, 썸네일 가독성)을 자동 검사 통과로 보고하지 말 것.

## 근거와 한계

확인일 2026-10-01. 별도 표시가 없으면 원문 직접 확인.

- Material Design 2, System icons, https://material.io/design/iconography/system-icons.html (현재 페이지는 JS 렌더라 본문 미확인, Internet Archive 2019-01 보관본으로 확인). Material Design 3(m3.material.io)의 현재 아이콘 수치는 미확인. Material Symbols guide, https://developers.google.com/fonts/docs/material_symbols (2024-09-26 갱신). google/material-design-icons README·LICENSE, https://github.com/google/material-design-icons.
- Apple HIG SF Symbols, https://developer.apple.com/design/human-interface-guidelines/sf-symbols (변경 이력 2025-07-28). SF Symbols 라이선스 약관 원문은 미확인.
- IBM Carbon, Icons usage, https://carbondesignsystem.com/elements/icons/usage/. Lucide icon design guide, https://lucide.dev/contribute/icon-design-guide. GOV.UK Design System, Images, https://design-system.service.gov.uk/styles/images/. 라이선스 원문: https://github.com/lucide-icons/lucide/blob/main/LICENSE, https://github.com/tailwindlabs/heroicons/blob/master/LICENSE, https://github.com/tabler/tabler-icons/blob/main/LICENSE.
- Harley, A. (2014-07-27). Icon Usability. Nielsen Norman Group, https://www.nngroup.com/articles/icon-usability/.
- W3C WCAG 2.2 Technique ARIA24, https://www.w3.org/WAI/WCAG22/Techniques/aria/ARIA24. W3C APG, Providing Accessible Names and Descriptions, https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/. WAI Images Tutorial, decision tree(2024-05-13 갱신)·functional images, https://www.w3.org/WAI/tutorials/images/. WCAG 2.2 Understanding 1.4.5, https://www.w3.org/WAI/WCAG22/Understanding/images-of-text.html. CSS Color Module Level 4 §6.4, https://www.w3.org/TR/css-color-4/ (Candidate Recommendation Draft 2026-09-30).
- The Open Graph protocol, https://ogp.me/. Meta for Developers, Webmasters와 Images, https://developers.facebook.com/docs/sharing/webmasters/. LinkedIn Help, Make your website shareable on LinkedIn, https://www.linkedin.com/help/linkedin/answer/a521928.
- X Cards: Summary Card with Large Image와 Getting started, developer.x.com (2025-01·2024-12 Internet Archive 보관본으로 확인). 현재 docs.x.com에서 카드 문서를 찾지 못해 현행 수치는 미확인.
- 카카오 개발자 문서: 메시지 템플릿 이해하기(스크랩, 컴포넌트 제약 사항), 메시지 템플릿 FAQ(OG 캐시), 도구 이해하기(카카오톡 URL 메타정보 관리), 카카오톡 공유 이해하기(방화벽), https://developers.kakao.com/docs/ko/message-template/common 외. 카카오톡 채팅창에 링크를 직접 붙여 넣은 미리보기에도 같은 규격과 초기화 도구가 적용되는지는 문서가 대상으로 명시하지 않아 미확인.
- web.dev: Choose the right image format(2024-08-13), Learn Images AVIF(2023-02-01), Web Vitals(2024-10-31), Optimize CLS(2025-02-07), Browser-level image lazy loading(2024-08-13), Fetch Priority(2023-11-14), https://web.dev/. HTML Standard img 요소의 `srcset`·`sizes`, https://html.spec.whatwg.org/multipage/embedded-content.html.
- Unsplash License와 Terms §5, https://unsplash.com/license, https://unsplash.com/terms. 대법원 2021. 4. 29. 선고 2020다227455 판결(대법원 2006. 10. 13. 선고 2004다16280 판결 참조), https://scourt.go.kr/sjudge/1620265689791_104809.pdf. 퍼블리시티권 관련 부정경쟁방지법 조문은 본문 미확인이라 규칙 근거에서 뺌.
- Welsh Government (Hwb), Guidance to support schools with learner image security (2025-06-11), https://hwb.gov.wales/keeping-safe-online/data-privacy-and-consent/guidance-to-support-schools-with-learner-image-security. 학교 대상 지침이라 일반 서비스로 넓힌 것은 키트 해석. 한국 개인정보보호위원회의 EXIF 관련 안내는 찾지 못함(미확인).
- 인공지능 기본법의 생성물 표시 의무(2026-01-22 시행)는 AI_FEATURES에서 국가법령정보센터 원문으로 확인.
- 키트 규칙으로 표시한 항목(한 세트 원칙, 아이콘만 쓰는 버튼의 범위, 스프라이트 선택, 공유 이미지 안전 영역, 원본 해상도 상한, 플레이스홀더, AI 모사 금지)은 출처가 정한 수치가 아니며 프로젝트에서 다르게 정하면 `decisions.md`에 이유를 남길 것. 플랫폼 규격은 예고 없이 바뀌므로 배포 전 각 도구로 실제 미리보기를 확인하고, 라이선스 표는 법적 판정이 아닌 확인 기록으로만 사용.
