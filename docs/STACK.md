# 기술 스택과 구조

AGENTS.md §10에서 옮김. 구조가 바뀌면 이 문서를 고친다.

Next.js 15 App Router · React 19 · TS strict · CSS. 화면 `src/AssetApp.tsx`, 스타일 18종 `src/styles.ts`, 지시 `src/prompt.ts`,
Codex 실행·회수 `src/server/codex.ts`, 저장 `src/server/store.ts`, 로컬 전용 `src/server/guard.ts`. 테스트 Playwright(가짜 생성, 1231).
디자인 `DESIGN.md`→`src/styles/tokens.css`(생성물)·`tokens-extra.css`, 브리프 `spec/DESIGN-BRIEF.md`. 앱 `electron/main.cjs`·`tool/build-app.sh`.

## 데스크톱 앱 (make app)

- `tool/build-app.sh`: Next 단독 실행 서버(`.next-app/standalone`)를 `build/app/server`에 모으고, `electron/main.cjs`와 함께 electron-builder로 `dist/`에 .app·.dmg·.zip을 만든다.
- 앱 코드는 `app.asar` 하나로 묶고 fuse로 asar 무결성 검사·asar 전용 로드를 켠다. 노드 실행 모드·NODE_OPTIONS·디버거 인자는 끈다.
- Codex 실행 파일은 `Contents/Resources/codex`(asar 밖). 음성 리소스는 뺀다.
- 결과 저장 위치는 `~/Library/Application Support/에셋 생성기/output`. 메뉴 "파일 > 결과 폴더 열기".
- 번들·실행 파일 이름은 영문 `Asset Gen`, 표시 이름만 `CFBundleDisplayName`으로 한글(한글 번들 이름은 시작 즉시 충돌).
- 아이콘·로고는 `node tool/gen-icons.mjs`로 다시 만든다. 규칙은 `docs/BRAND.md`.
- 서명은 ad-hoc(`identity: "-"`, 강화 런타임 끔). 회사 Developer ID가 생기면 identity·hardenedRuntime·notarize를 켠다.
