// 데스크톱 앱 패키징 설정 (tool/build-app.sh가 build/app을 채운 뒤 사용)
// projectDir을 build/app으로 두어 상위 저장소의 node_modules를 끌어오지 않게 한다.
const path = require("node:path");
const root = __dirname;
module.exports = {
  appId: "kr.co.abbg.asset-gen",
  // 실행 파일·번들 이름은 영문이어야 한다. 한글이면 Electron이 시작 즉시 충돌(2026-10-08 확인).
  // 사용자에게 보이는 이름은 extendInfo의 CFBundleDisplayName으로 한글 표시.
  productName: "Asset Gen",
  directories: {
    app: path.join(root, "build/app"),
    output: path.join(root, "dist"),
    buildResources: path.join(root, "build-resources"),
  },
  // 서버 묶음의 server/node_modules는 Next가 추적한 최소 의존성이다.
  // electron-builder는 하위 node_modules를 기본으로 빼므로 명시해서 넣는다.
  // dmg/는 설치 창에만 넣는 안내문이라 앱 코드 묶음에서 뺀다.
  files: ["**/*", "!dmg/**", "server/node_modules/**/*"],
  // 앱 코드는 app.asar 하나로 묶는다. 아래 fuse가 이 파일의 변조를 막는다.
  asar: true,
  // Codex 실행 파일은 asar 밖(Contents/Resources/codex)에 둔다. 실행 파일은 asar 안에서 실행할 수 없다.
  extraResources: [{ from: path.resolve(root, process.env.CODEX_VENDOR || ""), to: "codex", filter: ["**/*", "!codex-resources/voice/**"] }],
  mac: {
    category: "public.app-category.graphics-design",
    extendInfo: {
      // CFBundleName은 Electron이 Helper 앱 경로를 찾는 데 쓰므로 영문 그대로 둔다.
      CFBundleDisplayName: "에셋 생성기",
    },
    icon: path.join(root, "build-resources/icon.icns"),
    target: ["dmg", "zip"],
    // ad-hoc 서명: Apple Silicon은 서명 없는 실행 파일을 죽인다(fuse 변경으로 원래 서명이 깨짐).
    // 회사 Apple Developer 인증서가 생기면 identity에 인증서 이름을 넣고 notarize를 켠다.
    identity: "-",
    // 강화 런타임은 정식 서명·공증 때 켠다(ad-hoc에서는 라이브러리 검증으로 실행이 막힘).
    hardenedRuntime: false,
  },
  // dmg 창: 앱 → 응용 프로그램 끌어 넣기, 아래에 설치 안내(읽어주세요.txt)
  dmg: {
    title: "에셋 생성기",
    window: { width: 560, height: 420 },
    contents: [
      { x: 150, y: 170 },
      { x: 410, y: 170, type: "link", path: "/Applications" },
      { x: 280, y: 320, type: "file", path: path.join(root, "build/app/dmg/읽어주세요.txt") },
    ],
  },
  artifactName: "asset-gen-${version}-${arch}.${ext}",
  electronFuses: {
    runAsNode: false,
    enableCookieEncryption: true,
    enableNodeOptionsEnvironmentVariable: false,
    enableNodeCliInspectArguments: false,
    enableEmbeddedAsarIntegrityValidation: true,
    onlyLoadAppFromAsar: true,
  },
};
