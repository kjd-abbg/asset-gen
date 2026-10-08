# 핸드오프 — 다음 세션이 이어받는 지점

최종 갱신: 2026-10-08 · 상태: 첫 버전 완성·커밋(`8d2b806`). 맥 앱 배포 중, 실사용 확인 대기

> 이 파일의 목적은 하나다: **세션을 끊고 새로 시작했을 때, 이 파일만 읽고 다음 한
> 걸음을 알 수 있는가.** 안 되면 이 파일이 부실한 것이지 모델 문제가 아니다.
> 작업이 끝날 때 한 번이 아니라 **스텝을 끝낼 때마다** 갱신한다.

---

## ⚡ 지금 위치

사내 에셋 생성기. 대상 하나를 18개 스타일로 그려 보고(스타일 탐색), 고른 스타일로 같은 톤의 세트를 만든다(세트 만들기). 글자 없는 그림만.
각자 맥에서 본인 ChatGPT 구독(앱에 넣은 Codex CLI의 image_gen, 공식 문서상 GPT Image 2)으로 생성한다. 서버 공유 없음, 127.0.0.1 전용.
`../logo-gen`(2026-10-07)에서 떼어 낸 독립 프로젝트. 이후 작업 지시는 이 폴더에서 받는다.

배포 형태는 Electron 맥 앱이다. `make app` → `dist/asset-gen-<버전>-arm64.dmg`, 전달용 사본은 `~/Desktop/에셋 생성기/`(dmg + 사용자가 고친 `설치 안내.txt`).
dmg 안에도 `읽어주세요.txt`(원본 `build-resources/읽어주세요.txt`)가 들어간다.

```
make check     # 2026-10-08 통과 (harness·format·lint·typecheck·design-md·design-literals·test 4·prose)
make app       # 2026-10-08 성공, 앱 실행·로그인 인식·asar 변조 거부 확인
```

구조: `docs/STACK.md`. 디자인: `DESIGN.md`(코발트 `#2453d6`, 라이트 전용), `spec/DESIGN-BRIEF.md`. 로고: `docs/BRAND.md`. 결정과 이유: `decisions.md`.

---

## 다음 한 걸음

1. 결정자 실사용 확인 대기: 설치한 앱으로 실제 생성 2~3장(앱 안 로그인 버튼, 결과 폴더 열기, thread_id 폴더 회수 실검증, Dock·Finder 한글 표시 이름).
2. 결정자 피드백이 오면 그 작업. 화면을 고치면 `make check` 후 `make app`, 전달 폴더 dmg 교체. 재배포 때는 `package.json` 버전을 올리는 것을 제안해 둠(아직 0.1.0).
3. 여유가 되면 고친 화면으로 독립 렌더 리뷰 2차(`docs/DESIGN_REVIEW.md`).

---

## 결정자가 정한 것 (다시 묻지 않는다)

- 디자인: 성격(정돈·절제·최신), 강조색 코발트, 다크 모드 없음(2026-10-07).
- 배포: Electron 맥 앱, 자동 업데이트·업데이트 알림 없음, 새 dmg 재배포(2026-10-08). 회사 Apple Developer 인증서 없음 → ad-hoc 서명.
- 첫 실행 경고("악성 코드가 없음을 확인할 수 없습니다")는 "완료" → 시스템 설정 "그래도 열기" 또는 `xattr -dr com.apple.quarantine "/Applications/Asset Gen.app"`. 결정자는 번거로워함. 대안(사내 NAS·USB 복사, curl 한 줄 설치, 인증서 공증)은 안내만 했고 보류.
- 로고: "견본 부채"(A2) 코발트.
- 기존 생성 결과는 지워도 됨. 단 `public/styles/` 치아 캐릭터 썸네일 18장은 유지.

---

## 하지 말아야 할 것

- `src/styles/tokens.css`를 직접 고치지 않는다. `DESIGN.md` 수정 후 `make design-tokens`. 화면 CSS에 색·px·% 값을 직접 쓰지 않는다(기준선 0건). 사양 밖 값은 `src/styles/tokens-extra.css`.
- 앱 productName·CFBundleName을 한글로 바꾸지 않는다(시작 즉시 SIGTRAP). 표시 이름만 CFBundleDisplayName.
- Next `outputFileTracingExcludes`에 `dist/**`·`output/**` 같은 패턴을 쓰지 않는다(next 내부까지 빠짐). output은 `tool/build-app.sh`가 지운다.
- electron-builder는 `build/app`을 projectDir로 쓴다. dmg에 넣을 파일은 `build/app` 안으로 복사해야 한다.
- 실제 생성은 구독 사용량을 쓴다. 테스트·리뷰 캡처는 `ASSET_GEN_FAKE=1`. 리뷰 캡처는 폭마다 새 `ASSET_GEN_OUTPUT` 사본을 쓴다.
- `rm -rf`는 에이전트 권한에서 막혀 있다. 직접 지우지 말고 새 경로를 쓴다.
- 로고·아이콘 파일을 손으로 고치지 않는다. `node tool/gen-icons.mjs`.

---

## 확인하지 않은 것

| 항목 | 이유 |
| --- | --- |
| 앱에서의 실제 이미지 생성, thread_id 회수 | 구독 사용, 결정자 확인 대기 |
| 다른 맥에서 첫 실행 경고 처리, 인텔 맥 | 다른 기기 필요(arm64 전용 빌드) |
| 앱 창 E2E(Electron 창 조작) | 미구성, 앱 서버 스모크로 대신 |
| 상표 유사성(KIPRIS) | 사내 도구, 외부 배포 시 사람 확인 |
| 브리프 1절 주 사용자·기기 비율 | "가정:" 상태, 결정자 확인 대기 |
