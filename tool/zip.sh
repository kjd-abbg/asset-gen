#!/bin/bash
# 동료에게 줄 압축 파일을 만든다. 설치 파일·빌드 결과·내 생성 결과·git 기록은 뺀다.
set -euo pipefail
cd "$(dirname "$0")/../.."
OUT="$PWD/asset-gen.zip"
rm -f "$OUT"
zip -qr "$OUT" asset-gen \
  -x 'asset-gen/node_modules/*' 'asset-gen/.next/*' 'asset-gen/.next-*/*' \
  'asset-gen/output/*' 'asset-gen/test-results/*' 'asset-gen/playwright-report/*' \
  'asset-gen/.runtime/*' 'asset-gen/.git/*' 'asset-gen/artifacts/*' \
  'asset-gen/.harness/state/*' 'asset-gen/.harness/logs/*' \
  'asset-gen/dist/*' 'asset-gen/build/*' '*.DS_Store'
echo "만들었습니다: $OUT ($(du -h "$OUT" | cut -f1))"
