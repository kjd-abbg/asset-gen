# 디자인 참고자료

웹 UI·UX·레이아웃 설계에 쓰는 논문·표준·조사·실무 저작의 목록. 새 프로젝트에서 같은 자료를 다시 찾지 않도록 확인 결과와 한계까지 적어 둠.
규칙은 [시각 설계](VISUAL_DESIGN.md)·[UX 기준](UX_DESIGN.md)·[디자인 토큰](DESIGN_TOKENS.md)·[접근성](ACCESSIBILITY.md)·[디자인 리뷰](DESIGN_REVIEW.md)에 있고, 이 문서는 그 규칙의 출처를 찾거나 새 규칙을 만들 때 읽음. 위 문서들이 이미 각 절 끝에 적은 출처(ISO 9241, Nielsen 휴리스틱, GOV.UK, KRDS, Material, Apple HIG, WCAG, DTCG, Dyson 줄 길이, Tractinsky 2000, Tuch "Is beautiful really usable?" 등)는 여기서 반복하지 않음.

## 읽는 법

| 확인 | 뜻 | 인용 규칙 |
| --- | --- | --- |
| 원문 | 본문이나 PDF에서 해당 주장과 수치를 직접 읽음 | 수치 인용 가능 |
| 초록 | 초록·서지 DB(Crossref, PubMed, Semantic Scholar, KCI)만 확인 | 방향만 인용, 수치는 "초록 기준" 표시 |
| 2차 | 다른 문헌·요약을 거쳐 확인 | 판정 기준으로 쓰지 말 것 |
| 서지 | 출판 정보만 확인 | 존재 근거로만 |

검증 이력: 2026-10-07에 별도 에이전트가 수치 34건을 원문과 다시 대조함. 정확 21, 과장·맥락 누락 8, 부정확 4, 확인 불가 5. "원문" 표시 행에서도 해석 오류가 나왔으므로 새 수치를 규칙에 쓰기 전에 원문 문장을 다시 확인할 것. 오류는 본문과 이 표에서 고쳤음.

성격 표시: 실증(동료심사 연구), 조사(업체·기관의 비심사 연구), 실무(전문가 경험·의견), 지침(조직 가이드라인). 확인일은 모두 2026-10-07. 원문 다수가 출판사 차단(403)으로 초록까지만 확인됨.

## 1. 레이아웃·그리드·위계·스캐닝

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Müller-Brockmann (1981), Grid Systems in Graphic Design, Niggli, ISBN 978-3-7212-0145-1 | 서지·실무 | 그리드는 조직을 빠르고 믿을 만하게 하는 도구 | 인쇄·고정 판형 |
| Marcotte (2010-05-25), [Responsive Web Design](https://alistapart.com/article/responsive-web-design/), A List Apart | 원문·실무 | 유동 그리드·유연한 이미지·미디어 쿼리 | float 시대 기법 |
| Simmons (2018), Intrinsic Web Design, Big Web Show 녹취 (zeldman.com 2018-05-02) | 원문·실무 | fixed·fr·minmax·auto 혼합으로 미디어 쿼리 없이 4단계 신축 | 실증 없음 |
| Pickering & Bell, [Every Layout](https://every-layout.dev/) (3판), Axioms | 원문·실무 | 조합형 레이아웃 단위, 매직 넘버 제거, measure 60ch | 유료, 한글 ch 부정확 |
| Bell (2020-05-26), [CUBE CSS](https://cube.fyi/) | 원문·실무 | Composition→Utility→Block→Exception, 변형은 data 속성 | 방법론 |
| Tanzu/Pivotal (2016-12-14), Intro to the 8-Point Grid System | 원문·실무 | 8 배수는 확대 시 반 픽셀이 생기지 않음 | 사용성 근거 없음 |
| Pernice (2019-08-25), [Text Scanning Patterns: Eyetracking Evidence](https://www.nngroup.com/articles/text-scanning-patterns-eyetracking/), NN/g | 원문·조사 | F·spotted·layer-cake·commitment, 벽 같은 글은 거의 안 읽음 | 패턴 빈도 없음 |
| NN/g F-Shaped Pattern 현행판 (2026-08 재검토) | 원문·조사 | marking·bypassing 정의, F는 바람직하지 않은 패턴 | 수치 없음 |
| Fessenden (2018-04-15), [Scrolling and Attention](https://www.nngroup.com/articles/scrolling-and-attention/), NN/g | 원문·조사 | N=120, 첫 화면 57%, 첫 두 화면 74%, 첫 세 화면 81% (2010년 첫 화면 80%) | 데스크톱 1920×1080 |
| Schade (2015-02-01), [The Fold Manifesto](https://www.nngroup.com/articles/page-fold-manifesto/), NN/g | 원문·조사 | fold 100px 위가 아래보다 주목 102% 많음 | 84%는 두 지표 합친 추정 |
| Flaherty (2016-01-17), [The Illusion of Completeness](https://www.nngroup.com/articles/illusion-of-completeness/), NN/g | 원문·조사 | 전체 화면 히어로에서 8명 중 6명 스크롤 안 함, false floor 요인 | 사례 1건 |
| NN/g (2017-10-22), [Horizontal Attention Leans Left](https://www.nngroup.com/articles/horizontal-attention-leans-left/) | 원문·조사 | 왼쪽 절반 80%, RTL 반전 | 데스크톱 |
| Pernice (2018-04-22), [Banner Blindness Revisited](https://www.nngroup.com/articles/banner-blindness-old-and-new-findings/), NN/g | 원문·조사 | 튀는 것은 광고로 인식. 레일 응시 0.8%는 참가자 한 명 한 페이지 사례(132회 중 1회) | 모바일 표본 미기재 |
| Benway (1998), Banner Blindness, HFES 42, 463–467, doi:10.1177/154193129804200504 | 서지 | 존재 근거 | 94% vs 54% 수치는 2차라 인용 금지 |
| Itti, Koch & Niebur (1998), IEEE TPAMI 20(11), 1254–1259, doi:10.1109/34.730558 | 초록·실증 | 색·명도·방향 대비로 saliency 계산 | 자연 장면, 과업 무시 |
| Shen & Zhao (2014), Webpage Saliency, ECCV, doi:10.1007/978-3-319-10584-0_3 | 원문(포스터)·실증 | 위치 편향, 얼굴·텍스트 선호 | n=11, 자유 관찰 |
| Bylinskii et al. (2017), Learning Visual Importance, UIST '17, doi:10.1145/3126594.3126653 | 초록·실증 | 디자인 요소별 중요도 예측 모델 | 크라우드 주석 |
| Buscher, Cutrell & Morris (2009), CHI '09, doi:10.1145/1518701.1518705 | 초록·실증 | 시선 분포는 과업에 따라 다름 (n=20, 페이지 361) | 수치 미확인 |
| Gordon (2021-01-17), Visual Hierarchy in UX, NN/g | 원문·실무 | 크기 3단계, 큰 요소 2개, 블러 스퀸트 테스트 | 경험칙 |
| Harley (2020-08-02), Proximity Principle in Visual Design, NN/g | 원문·실무 | 내부 간격 < 외부 간격, 근접이 유사성보다 우선 | px 수치 없음 |
| Chaparro et al. (2004), Reading Online Text: Four White Space Layouts, Usability News 6(2) | 초록·조사 | 여백 있는 텍스트가 속도·이해 모두 우수, 행간은 선호에만 | 표본 미확인 |
| Bauerly & Liu (2006), IJHCS 64(8), 670–682, doi:10.1016/j.ijhcs.2006.01.002 | 서지 | 구성 요소와 미적 선호 | 추상 도형 |
| Ngo, Teo & Byrne (2003), Modelling interface aesthetics, Information Sciences 152, 25–46, doi:10.1016/S0020-0255(02)00404-8 | 초록·실증 | 균형·대칭·정렬 등 14개 미적 척도 | 공식 미확인 |

## 2. 첫인상·미학·복잡도·신뢰

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Lindgaard, Fernandes, Dudek & Brown (2006), Behaviour & IT 25(2), 115–126, doi:10.1080/01449290500330448 | 2차·실증 | 50ms·500ms 매력 평가가 페이지 평균에서 r≈.97 | 매력만 측정, 개인 일관성 아님 |
| Lindgaard et al. (2011), ACM TOCHI 18(1), doi:10.1145/1959022.1959023 | 초록·실증 | 신뢰·사용성 판단은 매력과 질적으로 다르게 처리 | 같은 자극 세트 |
| Tractinsky et al. (2006), IJHCS 64(11), 1071–1083, doi:10.1016/j.ijhcs.2006.06.009 | 초록·실증 | N=40, 500ms와 10s 평균 일치, 낮은 매력은 표현적 미학 부족과 연관 | 개인차 큼 |
| Tuch, Presslaber, Stöcklin, Opwis & Bargas-Avila (2012), IJHCS 70(11), 794–811, doi:10.1016/j.ijhcs.2012.06.003 | 원문·실증 | 복잡도 17ms부터 효과, 관례성 효과 시간에 따라 증가, 복잡하면 관례 이점 소실 | 회사 사이트, 스위스 학생 |
| Reinecke et al. (2013), CHI '13, 2049–2058, doi:10.1145/2470654.2481281 | 원문·실증 | 548명·450사이트, 색채감 R²=.78·복잡도 R²=.65 모델, 45세 초과 저복잡도 선호, 수상작도 4.21~6.57/9 | 500ms만, 자원자 |
| Reinecke & Gajos (2014), CHI '14, 11–20, doi:10.1145/2556288.2557052 | 원문·실증 | 39,975명·179개국, 복잡도 과잉 d=2.0 vs 부족 d=0.6, 국가·성별·학력 차 | 자기선택 표본 |
| Miniukovich & De Angeli (2015), CHI '15, 1163–1172, doi:10.1145/2702123.2702575 | 초록·실증 | 자동 미적 지표 8개, 웹 분산 설명 최대 49% | 소표본, 게이트 금지 |
| Miniukovich & De Angeli (2014), AVI '14, doi:10.1145/2598153.2598173 | 서지 | 복잡도 계산 지표 | 2015 논문 우선 |
| Michailidou, Harper & Bechhofer (2008), SIGDOC '08, doi:10.1145/1456536.1456581 | 2차·실증 | 복잡도는 블록·이미지·단어 수와 양의 관계 | 수치 미확인 |
| Moshagen & Thielsch (2010), Facets of visual aesthetics, IJHCS 68(10), 689–709, doi:10.1016/j.ijhcs.2010.05.006 | 원문·실증 | VisAWI 18문항 4요인(단순성·다양성·색·완성도), 단축형 VisAWI-S 4문항(2013) | 독일어권 |
| Lavie & Tractinsky (2004), IJHCS 60(3), 269–298, doi:10.1016/j.ijhcs.2003.09.002 | 초록·실증 | 고전적 미학(정돈) vs 표현적 미학(창의) | 이스라엘 학생 |
| Kurosu & Kashimura (1995), CHI '95 Companion, doi:10.1145/223355.223680 | 원문·실증 | ATM 화면 252명, 아름다움과 겉보기 사용성 r=.589 | 실제 사용성은 측정 안 함 |
| Fogg et al. (2003), DUX '03, doi:10.1145/997078.997097 및 Consumer WebWatch 보고서 (2002) | 보고서 원문·실증 | 2,684명, design look 언급 46.1%, 전문가는 7.6~16.4% | 언급 비율이지 판단 가중치 아님 |
| Fogg (2002), [Stanford Web Credibility Guidelines](https://credibility.stanford.edu/guidelines/index.html) | 원문·지침 | 실제 조직·연락처·최신성·오류 없음 등 10개 | 2002년 |
| Sillence et al. (2004), CHI '04, 663–670, doi:10.1145/985692.985776 | 원문·실증 | 빠른 거절 관련 발언의 94%가 디자인 요인, 선택은 콘텐츠 신뢰성 | n=15, 건강 분야 |
| Robins & Holmes (2008), IP&M 44(1), 386–399, doi:10.1016/j.ipm.2007.02.003 | 원문·실증 | 같은 콘텐츠 고미학 버전의 신용도 높음 (21쌍 중 7쌍 유의) | n=20 |
| Roth et al. (2010), Mental models for web objects, Interacting with Computers 22(2), 140–152, doi:10.1016/j.intcom.2009.10.004 | 초록·실증 | N=516, 쇼핑·뉴스·회사 사이트별 객체 기대 위치 존재 | 위치별 수치 미확인, 데스크톱 |
| Kaley & Nielsen (2019-05-26), 'About Us' Information on Corporate Websites, NN/g | 원문·조사 | 70명+·100사이트, 무엇을·어디서·연락처 요약, 스톡 사진 불신 | 미국 중심 |
| Wang (2024-03-15), Homepage Design: 5 Fundamental Principles, NN/g / Liu, White & Dumais (2010), SIGIR '10, doi:10.1145/1835449.1835513 | 원문/2차 | 홈은 elevator pitch. 10~20초 이탈 집중은 웹 페이지 일반 체류 연구(Liu)를 NN/g가 요약한 2차 | |

## 3. 색

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Palmer & Schloss (2010), PNAS 107(19), 8877–8882, doi:10.1073/pnas.0906172107 | 원문·실증 | 색 선호 분산 80%를 연상 대상의 호오로 설명 | 버클리 표본, 맥락 없는 색 |
| Ou & Luo (2006), Color Research & Application 31(3), 191–204, doi:10.1002/col.20208 | 2차·실증 | 두 색 조화는 색차·명도 합·명도 차·색상 효과 | 17명, 색 패치 |
| Valdez & Mehrabian (1994), J Exp Psych: General 123(4), 394–409, doi:10.1037/0096-3445.123.4.394 | 초록·실증 | 정서 효과는 명도·채도가 색상보다 강함 | 먼셀 칩, 학생 |
| Jonauskaite et al. (2020), Psychological Science 31(10), doi:10.1177/0956797620948810 | 초록·실증 | 30개국 4,598명, 보편 유사도 r=.88에 국가별 차이 추가 | |
| Elliot & Maier (2014), Annual Review of Psychology 65, 95–120, doi:10.1146/annurev-psych-010213-115035 | 초록·리뷰 | 색 심리 응용 권고는 시기상조 | |
| Singh (2006), Management Decision 44(6), 783–789, doi:10.1108/00251740610673332 | 초록·리뷰 | "62~90%" 수치의 출처 (신화 근거로만) | 원 실험 아님 |
| Piepenbrock et al. (2013), Ergonomics 56(7), 1116–1124, doi:10.1080/00140139.2013.790485 / (2014) 57(11), 1670–1677, doi:10.1080/00140139.2014.948496 | 초록·실증 | 밝은 바탕 어두운 글자가 연령 무관 우세 | 독일어 교정 과제 |
| Buchner, Mayr & Brandt (2009), Ergonomics 52(7), 882–886, doi:10.1080/00140130802641635 | 초록·실증 | 휘도를 맞추면 극성 이점 사라짐 | |
| Comeau (2021, 2026-04 갱신), Designing Beautiful Shadows in CSS, joshwcomeau.com | 원문·실무 | 광원 일관, 다층 그림자, 배경 색조 그림자 | 장식 영역 |
| Saarinen et al. (2024-03-28), How we redesigned the Linear UI, linear.app | 원문·실무 | 테마 변수 98→3개, LCH로 파생, 고대비 자동 생성 | 조직 사례 |

## 4. 화면 타이포그래피·가독성

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Rello, Pielot & Marcos (2016), Make It Big!, CHI '16, 3637–3648, doi:10.1145/2858036.2858204 | 초록·실증 | N=104, 18pt까지 크기가 클수록 가독성↑, 18·22·26pt에서 이해도↑, 행간은 양 끝만 해로움 | 영어, pt 단위 미확인 |
| Legge & Bigelow (2011), J Vision 11(5):8, doi:10.1167/11.5.8 | 원문·리뷰 | 유창 범위 x-height 0.2°~2°, 웹 텍스트 다수가 임계 크기 근처 | 시청 거리 의존 |
| Bernard et al. (2003), IJHCS 59(6), 823–835, doi:10.1016/S1071-5819(03)00121-6 | 2차·실증 | 역사적 근거만 | CRT 렌더링 |
| Wallace et al. (2022), ACM TOCHI 29(4), doi:10.1145/3502222 | 원문·실증 | N=352, 개인별 글꼴 속도차 35%, 단일 최적 글꼴 없음 | 원격, 영어 |
| Sheedy et al. (2005), Human Factors 47(4), 797–815, doi:10.1518/001872005775570998 | 초록·실증 | 작은 크기 판독성은 서체 영향 | 2005 LCD, 역치 과제 |
| Arditi & Cho (2005), Vision Research 45(23), 2926–2933, doi:10.1016/j.visres.2005.06.013 | 초록·실증 | 세리프 유무는 읽기 속도에 영향 없음 | 실험용 서체 |
| Beier & Larson (2013), Information Design Journal 20(1), 16–31, doi:10.1075/idj.20.1.02bei | 원문·실증 | 익숙함은 속도에, 낯선 형태는 선호에 영향 | 단기 노출 |
| Zorzi et al. (2012), PNAS 109(28), 11455–11459, doi:10.1073/pnas.1205566109 | 원문·실증 | 넓은 자간이 난독증 아동의 정확도·속도를 높임, 통제군 속도 이득 없음 (오류 감소 폭은 본문 미확인) | 아동, 인쇄 |
| Chung (2002), IOVS 43(4), 1270–1276, PMID 11923275 | 초록·실증 | 표준 자간 이상 넓혀도 속도 이득 없음 | n=6, RSVP |
| Perea et al. (2011), Acta Psychologica 137(3), 345–351, doi:10.1016/j.actpsy.2011.04.003 | 초록·실증 | 단어 인식은 약간 넓은 자간이 빠름 | 단어 단위 과제 |
| Korinth et al. (2020), Frontiers in Psychology 11:444, doi:10.3389/fpsyg.2020.00444 | 원문·실증 | 넓은 자간이 빠른 독자의 문장 읽기를 늦춤 | n=24, 독일어 |
| Zhu, Su & Dong (2021), Interacting with Computers 33(2), 177–187, doi:10.1093/iwc/iwab020 | 초록·실증 | 중국어 모바일, 큰 크기에서 넓은 행간이 편함 | 간체 |
| Ling & van Schaik (2006), IJHCS 64(5), 395–404, doi:10.1016/j.ijhcs.2005.08.015 | 원문·실증 | 긴 줄(85~100cpl)이 훑기 빠름, 짧은 줄 선호, 정독 55~70cpl 권고 | 800×600, 영어 |
| Bringhurst, The Elements of Typographic Style §2.1.2 | 2차·실무 | 45~75자는 세리프 본문 인쇄 관행, 66자 "widely regarded" | 실험 아님 |
| Butterick, [Practical Typography](https://practicaltypography.com/) | 원문·실무 | 줄 45~90자, 행간 120~145%, 웹 15~25px, tabular figures는 열 정렬용 | 라틴 문자 |
| Brown (2011-05-03), More Meaningful Typography, A List Apart | 원문·실무 | 모듈러 스케일 | |
| Gilyead & Mudford (2020-02-01), Designing with fluid type scales, utopia.fyi | 원문·실무 | 두 스케일 사이 clamp() 보간 (360px/18px/1.2 → 1240px/20px/1.25) | 확대 주의 없음 |
| Barvian (2023-11-07), Addressing Accessibility Concerns With Using Fluid Type, Smashing | 원문·실무 | max ≤ 2.5×min이면 1.4.4 통과 | 비공식 해석 |
| 신종현·박민용 (2003), 대한산업공학회지 29(3), 197–205 | 원문·실증 | 한글 웹 50cpl 최고(시험 최대값), 100% 줄간격 우세 | n=18, CRT |
| 정성원 (2016), 한국콘텐츠학회논문지 16(11), doi:10.5392/JKCA.2016.16.11.661 | 원문·실증 | 65세+ 24명, 13pt 최고, 나눔명조 판독성 우세, 자간·행간 영향 없음 | 짧은 지문 |
| 윤종찬·하진영 (2019), 디지털콘텐츠학회논문지 20(1), 33–40, doi:10.9728/dcs.2019.20.1.33 | 초록·실증 | 큰 크기·160% 행간이 두 연령대 모두 유리 | n=20 |
| 김민정 외 (2016), 한국HCI학회, doi:10.17210/hcik.2016.01.468 | 초록·실증 | 화면이 클수록 약간 큰 글자가 빠름 | n=33 |
| 김묘하·지용구 (2006), 한국HCI학회 | 원문·실증 | 작은 글자에 넓은 자간은 읽기 시간 증가 | 초소형 화면 |
| 정재우 (1997), 한성대 석사논문 | 초록·실증 | 행간 150% 미만 부적절 (국내 원류 중 하나) | CRT |
| 심영은 외 (2019), 한국HCI학회 / 옥지수 외 (2024), doi:10.9728/dcs.2024.25.1.239 | 2차/초록 | 한글 글꼴 가독성 결과가 서로 엇갈림 | 선택 근거로 쓰지 말 것 |
| W3C (2020), [klreq](https://www.w3.org/TR/klreq/) | 원문·지침 | 한글 자간 0, 문단별 음절·어절 줄바꿈 | 행간·줄 길이 수치 없음 |

## 5. 내비게이션·정보 구조·모바일·체감 성능

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Pirolli & Card (1999), Information Foraging, Psychological Review 106(4), 643–675, doi:10.1037/0033-295X.106.4.643 | 초록·이론 | 정보 냄새로 탐색 가치 추정 | UI 수치 없음 |
| Chi et al. (2001), CHI '01, 490–497, doi:10.1145/365024.365325 | 초록·실증 | 링크 주변 단서로 정보 냄새 계산 | |
| Budiu (2020-02-02), [Information Scent](https://www.nngroup.com/articles/information-scent/), NN/g | 원문·실무 | "더 보기" 같은 모호한 라벨 금지 | |
| Pernice & Budiu (2016-06-26), [Hamburger Menus and Hidden Navigation](https://www.nngroup.com/articles/hamburger-menus/), NN/g | 원문·조사 | N=179, 숨김 27% vs 노출 48%, 발견 20%↓, 데스크톱 39% 느림 | 6사이트, 2016 |
| Budiu (2015-11-15), Basic Patterns for Mobile Navigation, NN/g | 원문·실무 | 5개 이하 탭 바, 그 이상 콤보 | 하단 우위 실험 없음 |
| Nielsen & Li (2017-03-26), Mega Menus Work Well, NN/g | 원문·조사 | 0.5초 지연 열기, 0.1초 표시 | |
| Laubheimer (2024-06-07), Menu-Design Checklist, NN/g | 원문·실무 | 현재 위치 표시, 클릭으로 하위 메뉴, 캐스케이드 회피 | |
| Laubheimer (2018, 2026-09 재검토), Breadcrumbs: 11 Design Guidelines, NN/g | 원문·실무 | 계층 표시, 마지막 항목 링크 없음 | |
| Fessenden (2019-02-24), Web Page Footers 101, NN/g | 원문·실무 | 푸터 필수 링크, 2단계 이하 | |
| Larson & Czerwinski (1998), CHI '98, 25–32, doi:10.1145/274644.274649 | 초록·실증 | 깊이가 늘면 성능↓, 중간 폭·깊이가 최선 | 1998 |
| Kiger (1984), IJMMS 20, 201–213, doi:10.1016/S0020-7373(84)80018-8 | 서지 | 깊이·폭 상충 고전 | 단독 인용 금지 |
| Porter (2003-04-16), Testing the Three-Click Rule, UIE | 원문·조사 | 44명·620과업, 클릭 수와 성공·이탈 무관 | 비심사 |
| Rosenfeld, Morville & Arango (2015), Information Architecture 4th ed., O'Reilly | 서지·실무 | 조직·라벨·내비게이션·검색 체계 | |
| Spencer (2009), Card Sorting, Rosenfeld Media / NN/g Card Sorting (2024) | 서지/원문 | 오픈 소팅, 정성 15명+·정량 30~50명, 카드 30~50장 | |
| Laubheimer (2023, 2026-08 재검토), Tree Testing, NN/g | 원문·실무 | 성공률·시간·직접성 측정, 시나리오형 과업 | 기준치 없음 |
| Nielsen (2001-05-12), Search: Visible and Simple, NN/g | 원문·실무 | 링크 대신 입력창 | 2001 데스크톱 |
| Nielsen (2002), Top 10 Guidelines for Homepage Usability, NN/g | 원문·실무 | 태그라인, 최우선 과업 강조, 실제 콘텐츠 예시, 검색창 27자 폭 | 2002 |
| Nielsen (2013-01-19), Auto-Forwarding Carousels, NN/g / Budiu (2018), Carousels on Mobile | 원문·조사 | 자동 회전 정보 누락, 5프레임 이하 | 사례 기반 |
| Runyon (2013-07), Carousel Interaction Stats | 원문·조사 | 클릭 1.07% 중 89% 첫 슬라이드, 자동재생 뉴스 사이트 예외 | 개인 블로그 |
| Scott (2019, 2025-04 갱신), 10 UX Requirements for Homepage Carousels, Baymard | 원문·조사 | 이커머스 46%에 문제, 데스크톱 5~7초, 모바일 자동 금지 | 방법론 유료 |
| Flaherty (2017-11-26), Zigzag Image–Text Layouts, NN/g | 원문·조사 | 지그재그는 훑기 효율↓ | 정성 |
| Nielsen (2010-10-31), Photos as Web Content, NN/g | 원문·조사 | 과업 관련 사진은 보고 장식 스톡은 무시 | 2010 |
| Hoober (2013-02-18), How Do Users Really Hold Mobile Devices?, UXmatters | 원문·조사 | 관찰 1,333건 중 터치 중이던 780건에서 한 손 49%·받침 36%·양손 15% | 2013 화면 |
| Hoober (2017-03-06), Design for Fingers, Touch, and People Part 1, UXmatters | 원문·실무 | 중앙 7mm, 모서리 12mm | 방법 불투명 |
| Parhi, Karlson & Bederson (2006), MobileHCI '06, doi:10.1145/1152215.1152260 | 초록·실증 | 엄지 9.2mm(단일)·9.6mm(연속) | PDA급 |
| Bergstrom-Lehtovirta & Oulasvirta (2014), CHI '14, 1991–2000, doi:10.1145/2556288.2557354 | 초록·실증 | 엄지 기능 영역 모델 | 모델 연구 |
| Wroblewski (2011), Mobile First, A Book Apart | 서지·실무 | 좁은 화면부터 우선순위 | 철학 |
| web.dev, [Web Vitals](https://web.dev/articles/vitals) (2024-10-31), [Defining thresholds](https://web.dev/articles/defining-core-web-vitals-thresholds) (2025-05-07) | 원문·지침 | LCP 2.5s, INP 200ms, CLS 0.1 (p75), 임계값 절충 근거 | CLS는 내부 평가 |
| Google/DoubleClick (2016-09-08), The Need for Mobile Speed | 원문·조사 | "53%" 문구의 원 출처 | 광고 사업자 상관 자료 |
| Mejtoft et al. (2018), ECCE 2018, doi:10.1145/3232078.3232086 | 초록·실증 | 스켈레톤 체감 우세 경향, 유의하지 않음 | 소규모 |
| Harrison, Yeo & Hudson (2010), Faster Progress Bars, CHI '10, 1545–1548, doi:10.1145/1753326.1753556 | 원문·실증 | 역방향 리빙 막대 체감 11% 단축 | 11%는 n=16 실험 |
| Neusesser (2022-09-04), Infinite Scrolling, NN/g | 원문·실무 | 피드에만, 찾기·비교엔 더 보기·페이지네이션 | |
| Holst/Baymard (2016-03-01), Infinite Scrolling, Pagination Or "Load More", Smashing | 원문·조사 | 더 보기+지연 로딩 최선, pushState 복원 90% 오류 | 이커머스 |
| Laubheimer (2021-04-04), Sticky Headers, NN/g | 원문·실무 | 최소 높이, 불투명, 부분 고정 | |

## 6. 데이터 화면

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Cleveland & McGill (1984), JASA 79(387), 531–554, doi:10.1080/01621459.1984.10478080 | 2차·실증 | 위치 > 길이 > 각도 > 면적 > 부피·색 | 비율 추정 과제 |
| Heer & Bostock (2010), CHI '10, doi:10.1145/1753326.1753357 | 원문·실증 | 순위 재현, 높이 40px에서 오차↑, 80px 넘으면 이득 적음, 격자 8px 이상 | MTurk |
| Munzner (2014), Visualization Analysis and Design, CRC, ISBN 9781466508910 | 2차·실무 | 크기·범주 채널 효과 순위 | 종합 휴리스틱 |
| Tufte (1983/2001), The Visual Display of Quantitative Information | 서지·실무 | data-ink, chartjunk | 전문가 의견 |
| Inbar, Tractinsky & Meyer (2007), ECCE, doi:10.1145/1362550.1362587 | 초록·실증 | 87명이 덜 최소화한 차트 선호 | 선호만 측정 |
| Few (2013), Information Dashboard Design 2nd ed. / Bullet Graph Design Specification (2013-10-10) | 서지/원문·실무 | 한눈 모니터링, 불릿 그래프 구간 3~5·단일 색조 명도 | 사용자 실험 없음 |
| Laubheimer (2022-04-03), [Data Tables: Four Major User Tasks](https://www.nngroup.com/articles/data-tables/), NN/g | 원문·실무 | 4과업, 첫 열 식별자, 고정 헤더 | 수치 없음 |
| Laubheimer (2017-06-18), Dashboards: Preattentive, NN/g | 원문·실무 | 운영형·분석형, 길이·위치로 양 표현 | |
| IBM [Carbon Data table](https://carbondesignsystem.com/components/data-table/) | 원문·지침 | 행 24/32/40/48/64, 툴바 5개, 일괄 모드 | 숫자 정렬 규칙은 없음 |
| Material Design 2, Data tables | 원문·지침 | 숫자 오른쪽 정렬, 기본 52dp | 레거시 |
| Atlassian Design System, Dynamic table | 원문·지침 | 하단 페이지네이션, 복잡 편집은 모달 | Polaris·Fiori 수치는 미확인 |
| Butterick, Alternate figures / MDN font-variant-numeric | 원문 | tabular figures는 열 정렬용 | 글꼴의 tnum 필요 |
| Healey & Enns (2012), IEEE TVCG 18(7), 1170–1188, doi:10.1109/TVCG.2011.127 | 초록·리뷰 | 주의·시각 기억과 시각화 | 규칙 목록 아님 |
| Harrower & Brewer (2003), ColorBrewer, Cartographic Journal 40(1), 27–37, doi:10.1179/000870403235002042 | 서지·실무 | 순차·발산·범주 팔레트 | 지도용 |
| Borland & Taylor (2007), IEEE CG&A 27(2), 14–17, doi:10.1109/MCG.2007.323435 | 초록·실무 | rainbow 컬러맵 문제 | 반론 존재 |
| Matplotlib, Choosing Colormaps | 원문·지침 | viridis 계열 명도 단조, jet 부적합 | |
| Okabe & Ito (2002, 2008), [Color Universal Design](https://jfly.uni-koeln.de/color/) | 원문·지침 | 색각 이상 안전 8색 | hex 값 별도 확인 |
| Hearst (2009), Search User Interfaces, Cambridge UP, 8장 | 원문·실무 | 패싯 결과 수, 0건 회피, 적용 필터 개별 해제 | |

## 7. 실무 저작·조직 지침·AI 생성 화면

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Wathan & Schoger (2018), [Refactoring UI](https://www.refactoringui.com/) | 일부·실무 | 굵기·색으로 위계, 여백 넉넉히 시작, 회색에 색조, 버튼 위계 | Tailwind 미감과 결합 |
| Vercel, [Web Interface Guidelines](https://vercel.com/design/guidelines) | 원문·지침 | 포커스 링, 대상 크기, 로딩 지연, `transition: all` 금지, tabular-nums, 폼 | APCA 선호는 KWCAG와 충돌 |
| Freiberg (2023-07), [Invisible Details of Interaction Design](https://rauno.me/craft/interaction-design) | 원문·실무 | 끊을 수 있는 애니메이션, 자주 쓰는 UI는 즉시 | iOS 중심 |
| Kowalski, [emilkowal.ski/ui](https://emilkowal.ski/ui) (Great animations 등) | 원문·실무 | 300ms 미만, ease-out, scale 0.9+, transform-origin | 경험칙 |
| Allsopp (2000-04-07), A Dao of Web Design, A List Apart | 원문·실무 | 사용자 설정 존중, 상대 단위 | |
| Frost (2016), [Atomic Design](https://atomicdesign.bradfrost.com/) | 원문·실무 | 실제 콘텐츠로 페이지 단계 검증 | 분류 논쟁 주의 |
| Curtis, Naming Tokens in Design Systems (EightShapes) | 일부·실무 | 토큰 이름 계층, 로컬→전역 승격 | |
| Saarinen (2016), Building a Visual Language, Airbnb Design | 2차·실무 | Unified·Universal·Iconic·Conversational | 원문 404 |
| Google (2025), Expressive design: Google's UX research | 원문·조사 | 46개 연구·18,000명, 핵심 요소 발견 최대 4배, 관례 파괴 경고 | 비심사, 최대값 |
| 김자유 (2022-11-15), 토스의 라이팅 시스템, toss.tech | 원문·지침 | 다음 화면 예측 가능한 문구, 빈 문장 제거 | |
| 토스, 앱인토스 Consumer UX Guide | 원문·지침 | 진입·뒤로 가기 가로막기 금지, 모든 모달에 닫기, 해요체 | 앱인토스 맥락 |
| 행정안전부 [KRDS](https://www.krds.go.kr) | 일부·지침 | 공공 토큰·컴포넌트·패턴 (세부는 DESIGN_TOKENS·UX_DESIGN) | |
| Anthropic (2025-10-21), Prompting for frontend aesthetics, Claude Cookbook | 원문·지침 | 분포 수렴 진단, 기본 글꼴·보라 그라디언트·흩어진 모션 회피 | 의도적 과장, 본문 가독성과 충돌 항목 |
| Anthropic (2025-11-12), Improving frontend design through Skills / `frontend-design` SKILL.md (2026-10 열람) | 원문·지침 | 계획→독창성 검토→구현→자기비평, 과감함은 한 요소에, 번호·구분선은 정보일 때만 | 판본 변경 |
| Bakaus, [Impeccable](https://impeccable.style/) (Apache-2.0) | 원문·실무 | 범용 화면 징후 결정론적 검사 60여 개 | 개인 프로젝트 |
| prg.sh (2025-10-26), Why Your AI Keeps Building the Same Purple Gradient Website | 2차·의견 | Tailwind UI indigo 기본값 가설 | 인과 추정 |

## 8. 디자인 검수 방법·기계 검사

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Connor & Irizarry (2015), Discussing Design, O'Reilly | 2차·실무 | 목표→요소→효과→이유 4문항 | |
| Gibbons (2016-10-23), Design Critiques, NN/g | 원문·실무 | 범위·목표 합의, 질문형 지적 | 사람 회의용 |
| stylelint-declaration-strict-value (v1.12.1) / stylelint core `color-no-hex` 등 | 원문·도구 | 속성별 토큰 강제 | CSS 파일만 |
| eslint-plugin-tailwindcss (v4판) `no-arbitrary-value` | 원문·도구 | Tailwind 임의값 금지 | 동적 클래스 못 잡음 |
| Deque, [Automated Accessibility Coverage Report](https://www.deque.com/automated-accessibility-testing-coverage/) | 원문·조사 | 이슈 건수의 57.38%를 자동 검출 | 성공기준 커버율 아님 |
| Chrome for Developers, Lighthouse accessibility scoring | 원문·지침 | axe 가중 평균, 수동 감사 미반영 | 100점 ≠ 접근 가능 |
| Playwright, [Visual comparisons](https://playwright.dev/docs/test-snapshots) | 원문·도구 | pixelmatch, threshold 0.2, mask, 같은 환경 기준선 | 미적 판단 불가 |
| Storybook Visual tests / Percy | 원문/2차·도구 | 상태별 스토리 시각 테스트 | 유료 서비스 |
| Oulasvirta et al. (2018), AIM, UIST '18 Adjunct, doi:10.1145/3266037.3266087 | 원문·도구 | 17개 지표(색·지각 유창성·시각 안내·색각) | 임계값 없음 |
| Duan et al. (2024), UICrit, UIST '24, doi:10.1145/3654777.3676381 | 초록·실증 | 디자이너 크리틱 3,059건, few-shot으로 LLM 피드백 55%↑ | 모바일 UI |
| Wu et al. (2024), UIClip, UIST '24, doi:10.1145/3654777.3676408 | 2차·실증 | 쌍대 비교 75.12% vs 범용 VLM 52.9~60.3% | 2024 모델 |
| Si et al. (2025), Design2Code, NAACL 2025, arXiv:2403.03163 | 원문·실증 | 484 페이지, 블록 일치·위치·색 지표가 사람 선호 79.9% 예측 | 재현 과제 |
| Zhang et al. (2025), ArtifactsBench, arXiv:2507.04952 / Jung et al. (2025), UI-Bench, arXiv:2508.20410 | 초록·실증 | 렌더→스크린샷→체크리스트 MLLM 채점, 전문가 일치 90%+ | 벤치마크 |

## 9. 로고 실무·색 조합·생성 기능

브랜딧(브랜딩 생성 서비스) 저장소가 2026-09에 조사·기록한 자료 중 로고 결과물과 생성 기능 화면에 쓰는 것만. 서지는 2026-10-07 Crossref로 다시 대조.

| 출처 | 확인·성격 | 쓸 수 있는 것 | 한계 |
| --- | --- | --- | --- |
| Schloss & Palmer (2011, 온라인 2010), Aesthetic response to color combinations, Attention, Perception & Psychophysics 73(2), doi:10.3758/s13414-010-0027-0 | 서지·실증 | 조합 선호·조화·바탕 위 도형색 선호는 다른 판단 → 로고 색 후보를 실제 바탕 위에서 비교 | 색쌍 실험 |
| Amershi et al. (2019), Guidelines for Human-AI Interaction, CHI '19, doi:10.1145/3290605.3300233 | 서지·실증 | 사용자 선택과 AI 제안 구분, 통제 | AI_FEATURES에 상세 |
| Zamfirescu-Pereira et al. (2023), Why Johnny Can't Prompt, CHI '23, doi:10.1145/3544548.3581388 | 서지·실증 | 비전문가 프롬프트 작성 실패 → 자유 프롬프트를 주 입력으로 두지 않음 | |
| Subramonyam et al. (2024), Bridging the Gulf of Envisioning, CHI '24, doi:10.1145/3613904.3642754 | 서지·실증 | 원하는 결과를 말로 구상하기 어려움 | |
| Chernev, Böckenholt & Goodman (2015, 온라인 2014), Choice overload, J Consumer Psychology 25(2), doi:10.1016/j.jcps.2014.08.002 | 서지·메타분석 | 선택 과부하는 결정 난이도·선택지 복잡도·선호 불확실성·목표에 따라 달라짐 | 개수 기준 없음, "3개 이하"는 실무 값 |
| Johnson & Goldstein (2003), Do Defaults Save Lives?, Science 302, doi:10.1126/science.1091721 | 서지·실증 | 기본값 효과 → 미리 채우되 표시 | 장기 기증 맥락 |
| 브랜딧 로고 생성·감사 기록 (2026-09~10) | 실무 | 로고 브리프, 업종 클리셰, 생성 파이프라인, 사용처 배치, 검증 항목 (LOGO_DESIGN) | 제품 휴리스틱, 클리셰 표는 상용 갤러리 정리 |

## 10. 실제 제품 실패 사례

가이드 본문의 "(사례 Dn)"이 가리키는 항목. 출처는 브랜딩 생성 서비스(브랜딧, Next.js) 저장소의 2026-09~10 감사·결정 기록이며, 한 제품의 관찰이라 수치를 일반 기준으로 쓰지 말 것.

| ID | 날짜 | 관찰 | 반영한 규칙 |
| --- | --- | --- | --- |
| D1 | 2026-09-18 | 기준색이 조금만 달라져도 계산된 강조색이 거의 검정으로 급변 | 색 파생은 기준색을 훑으며 급변 여부 확인 |
| D2 | 2026-10-06 | 글자 대비를 맞추려 버튼 면만 어둡게 해 면과 배경이 1.07:1, 1px 테두리 때문에 검사는 통과 | 대비 교정 시 두 쌍 재측정 |
| D3 | 2026-09-29 | 전역 최소 터치 높이 규칙이 작성자 스타일 62곳을 덮음 | 전역 안전 CSS는 `:where()` |
| D4 | 2026-09-29 | 생성 작업 요청이 끊겼는데 상태를 모른 채 무기한 로딩 | 상태 미상 시한과 과금 여부 안내 |
| D5 | 2026-10-02 | 요금 제한 안내 방식 조사(Canva·Adobe Express·Figma·Notion 공식 문서) | 제한 원인별 안내 |
| D6 | 2026-09-23 | 레이아웃 슬롯 추가 뒤 HMR 상태에서만 정상으로 보이고 재시작 시 깨짐(Next 15.5 재현) | 구조 변경 뒤 서버 재시작·새 컨텍스트로 검증 |
| D7 | 2026-09-16~29 | 스켈레톤 동등성을 존재 여부·일부 좌표로 판정해 실제 화면과 다른 스켈레톤이 통과 | 경계 상자를 여러 폭에서 비교(한 제품은 2px 미만 사용) |
| D8 | 2026-09-29 | 새로고침 시 데이터가 없어 다른 화면의 스켈레톤 표시 | 직접 진입 시 스켈레톤 선택 검사 |
| D9 | 2026-09-18 | 글자를 키우자 배지가 제목 폭을 11px로 밀어냄, 카드 행동 기준선 어긋남 | 글자 크기 변경 뒤 배치 재확인 |
| D10 | 2026-10-06 | 모달용 그리드를 좁은 패널로 옮기자 표 칸이 5~80px로 눌림 | 패널 안 컴포넌트는 컨테이너 쿼리 |
| D11 | 2026-09 | reduced motion을 켜도 JS 애니메이션·자동 슬라이드가 계속 돎 | reduced motion은 JS·영상·카운터까지 |
| D12 | 2026-09-29 | 편집 화면 미리보기를 멈추려 matchMedia로 reduced motion을 흉내 내자 콘텐츠 분기·영상이 바뀌어 저장본에 섞임 | 비저장 스타일시트로 애니메이션 시간만 0 |
| D13 | 2026-10-06 | 변수 뒤 고정 조사로 "귀리 굽는 집를" 노출, 복구 가능한 삭제에 "되돌릴 수 없습니다" | 조사 헬퍼, 삭제 문구를 동작과 일치 |
| D14 | 2026-09-21 | 모달 배경 스크롤, 포커스 복귀 실패(body만 잠금, 역할만 붙인 div, 자식 자동 포커스 뒤 호출 요소 저장) | html·body 잠금, native dialog, 호출 요소 먼저 저장 |
| D15 | 2026-09-21 | WebKit에서만 Tab이 모달 밖으로 빠져나감 | 키보드·모달 검사를 WebKit에서도 |
| D16 | 2026-10-06~07 | 센서는 모두 통과했으나 헤더 로고 대비 2.89:1·글자 9.9px, 실제 생성물 결함 10건(센서가 자리표시자·합성 예제만 봄) | 검수는 최종 자산을 넣은 실제 순서로, 실제 결과물 감사 분리 |
| D17 | 2026-09 | 로고 생성: 브리프 없이 그리면 업종 클리셰로 수렴, 생성 모델 결과에 글자·그라디언트가 섞여 벡터화 실패 | 로고 브리프, 생성 파이프라인 |
| D18 | 2026-09-18 | 24화면 실측에서 삭제 경고 10px·환불 안내 12px, 14px 미만 고정 선언 667건 | 역할별 글자 크기 하한 |
| D19 | 2026-09~10 | 생성 기능에서 자유 프롬프트 입력 실패, 결과 자동 덮어쓰기, 보기만 하는 이동에도 확인창 | 생성 기능 화면 패턴 |

## 근거로 쓰지 않는 통념

| 통념 | 실제 근거 상태 |
| --- | --- |
| Z-pattern으로 시선이 움직인다 | 실증 근거 없음. 확인된 것은 왼쪽 편향과 과업 의존성 |
| F-pattern을 따라 배치하라 | F는 서식이 나쁠 때 나오는 실패 패턴 |
| 사람들은 스크롤하지 않는다 / fold는 무의미하다 | 둘 다 틀림. 스크롤은 하지만 첫 화면에 57%가 몰림 |
| 3클릭 규칙 | 클릭 수와 성공·이탈 무관 (Porter 2003) |
| 햄버거 메뉴는 어디서나 괜찮다 | 데스크톱에서 발견율·속도 저하 (NN/g 2016) |
| 3초 넘으면 53% 이탈 | 광고 사업자 상관 자료, 방법 비공개 |
| 50ms면 승부가 끝난다 / 겉모습만 중요하다 | 매력 평가 평균에 한정, 신뢰·선택은 다르게 결정 |
| 예쁘면 쓰기 쉽다 | 겉보기 사용성과만 상관 (Kurosu 1995) |
| 46%가 디자인으로 신뢰를 판단한다 | 댓글 언급 비율 (Fogg 2003) |
| 파랑 = 신뢰, 색이 판단의 62~90% | 미국 표본·리뷰 2차 수치, 응용은 시기상조 |
| 다크 모드가 눈에 좋다 | 장문 수행은 밝은 바탕이 우세, 원인은 휘도 |
| 단순할수록 무조건 좋다 | 역U자. 단 과잉 복잡이 훨씬 해로움 |
| 화면에선 산세리프가 더 읽기 쉽다 | 세리프 유무 효과 없음, 개인차가 더 큼 |
| 66자가 이상적이다 | 인쇄 관행 서술, 화면 단일 최적값 없음 |
| 16px는 연구로 정해진 값이다 | 브라우저 기본값 |
| 자간을 넓히면 읽기 쉽다 | 난독증 아동에 한정 |
| 여백이 이해도를 20% 높인다 (Lin 2004) | 인용된 논문은 여백 연구가 아님 |
| 배너 정보 94% vs 54% (Benway 1998) | 원문 미확인 2차 수치 |
| 캐러셀은 언제나 1%만 클릭된다 | 예외(자동재생 뉴스) 있음. "2번째 이후는 거의 안 보임"까지만 |
| 8pt 그리드가 사용성을 높인다 | 일관성 관례 |
| 스켈레톤은 항상 빠르게 느껴진다 | 경향뿐, 유의하지 않음 |
| axe 0건이면 접근성 통과 | 자동 검출은 이슈의 약 57% |
| 보색·유사색 배색이면 조화롭다 | 색상환 관계는 조화 점수가 아님 (Schloss & Palmer 2011) |
| 60-30-10은 색 면적의 법칙이다 | KRDS가 원칙으로 채택했으나(색상 페이지 원문) 근거는 밝히지 않음. 공공 서비스 외에는 출발점 |
| AI=파랑, 친환경=초록처럼 업종 색이 정답이다 | 연상은 맥락 의존, 업종 자동 연결은 차별화를 지움 |

## 새 자료를 더할 때

- 원문을 열어 확인 수준을 적고, 수치에는 표본·방법·환경을 함께 적을 것. 열지 못했으면 "초록" 또는 "2차"로 표시하고 판정 기준으로 쓰지 말 것.
- 업체 조사(NN/g, Baymard, Google, Deque)는 비심사임을 표시. 실무 저작은 경험칙으로 표시하고 접근성 기준과 충돌하면 접근성을 따름.
- 규칙으로 쓰려면 해당 가이드(VISUAL_DESIGN 등)에 넣고 이 표에는 출처만. 프로젝트 고유 레퍼런스(경쟁사 사이트, 무드보드)는 키트가 아니라 프로젝트의 `spec/DESIGN-BRIEF.md`에.
- 키트 기여 기준은 README "기여" 절. 자료 확인일이 1년을 넘은 행은 월간 리뷰 때 재확인 후보.

미확보로 남은 것: 가치 제안·CTA·사회적 증거의 정량 연구, Baymard 유료 보고서 수치, 레이아웃 이동 불쾌감의 독립 연구, 낙관적 UI 연구, Pretendard·Noto Sans KR 대상 한글 웹폰트 실측, Lindgaard 2006·Roth 2010·Michailidou 2008의 원문 수치, Okabe-Ito hex 값, Ngo 2003 척도 공식, Polaris·Fiori 표 수치.
