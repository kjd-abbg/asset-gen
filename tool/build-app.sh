#!/bin/bash
# 맥 데스크톱 앱(.app·.dmg) 빌드. 결과는 dist/.
# 1) Next 단독 실행 서버를 만들고 2) build/app에 앱 본체를 모은 뒤 3) electron-builder로 묶는다.
set -euo pipefail
cd "$(dirname "$0")/.."

ARCH="$(uname -m)"
[ "$ARCH" = "arm64" ] || ARCH="x64"
CODEX_TRIPLE=$([ "$ARCH" = "arm64" ] && echo aarch64-apple-darwin || echo x86_64-apple-darwin)
CODEX_VENDOR="node_modules/@openai/codex-darwin-$ARCH/vendor/$CODEX_TRIPLE"
[ -x "$CODEX_VENDOR/bin/codex" ] || { echo "✗ Codex 실행 파일이 없다: $CODEX_VENDOR (npm ci 먼저)"; exit 1; }

rm -rf build/app dist .next-app
NEXT_OUTPUT_STANDALONE=1 NEXT_DIST_DIR=.next-app npx next build

mkdir -p build/app/server
cp -R .next-app/standalone/. build/app/server/
# 파일 추적이 저장소의 생성 결과(output/)까지 따라온다. 개인 결과물이 앱에 들어가지 않게 지운다.
rm -rf build/app/server/output
cp -R .next-app/static build/app/server/.next-app/static
cp -R public build/app/server/public
# asar 안에서는 작업 폴더를 바꿀 수 없다. 서버는 __dirname 기준 경로를 쓰므로 chdir만 뺀다.
grep -q 'process.chdir(__dirname)' build/app/server/server.js
sed -i '' 's/process\.chdir(__dirname)/void 0 \/* asar: chdir 제거 *\//' build/app/server/server.js

cp electron/main.cjs build/app/main.cjs
# dmg 창에 함께 보일 설치 안내(electron-builder는 앱 폴더 밖 파일을 dmg에 넣지 않는다)
mkdir -p build/app/dmg && cp build-resources/읽어주세요.txt build/app/dmg/
node -e '
const p = require("./package.json");
require("fs").writeFileSync("build/app/package.json", JSON.stringify({
  name: "asset-gen", productName: "Asset Gen", version: p.version,
  description: "대상 하나를 여러 스타일로 그려 보고 같은 톤의 에셋 세트를 만든다",
  main: "main.cjs", author: "ABBG", private: true, dependencies: {}
}, null, 2));'
# 앱에 개인 결과물이 들어가면 안 된다
if [ -e build/app/server/output ]; then echo "✗ 서버 묶음에 output/이 들어갔다"; exit 1; fi

# FAST=1이면 설치 파일(dmg·zip) 없이 앱 폴더만 만든다.
CODEX_VENDOR="$CODEX_VENDOR" npx electron-builder --mac --"$ARCH" ${FAST:+--dir} \
  --projectDir build/app --config "$PWD/electron-builder.config.cjs"
