#!/bin/sh
# DESIGN.md → 토큰 CSS 생성. 사용: sh tool/gen-design-tokens.sh [출력 경로]
# `make design-tokens`와 design-md 센서(check-design-md.sh)가 같은 명령을 쓴다.
#
# 설정 (환경 변수):
#   DESIGN_MD_SRC        원본 (기본: DESIGN.md)
#   DESIGN_TOKENS_OUT    출력 (기본: src/styles/tokens.css, 첫 인자가 우선)
#   DESIGN_MD_BIN        실행 파일 (기본: node_modules/.bin/design.md)
#   DESIGN_TOKENS_FORMAT export 형식 (기본: css-tailwind. 그 밖: css-vars, dtcg)
#   DESIGN_RESET_PALETTE 1이면 css-tailwind 앞에 `@theme { --color-*: initial; }`를 넣어
#                        Tailwind 기본 팔레트를 끈다 (기본: 1)
set -eu
SRC="${DESIGN_MD_SRC:-DESIGN.md}"
OUT="${1:-${DESIGN_TOKENS_OUT:-src/styles/tokens.css}}"
BIN="${DESIGN_MD_BIN:-node_modules/.bin/design.md}"
FMT="${DESIGN_TOKENS_FORMAT:-css-tailwind}"

mkdir -p "$(dirname "$OUT")"
tmp="$OUT.tmp.$$"
{
  echo "/* 생성물 — 직접 고치지 말 것. 원본: $SRC, 생성: make design-tokens */"
  if [ "$FMT" = "css-tailwind" ] && [ "${DESIGN_RESET_PALETTE:-1}" = "1" ]; then
    echo "/* Tailwind 기본 팔레트를 끄고 $SRC 색만 남긴다. */"
    echo "@theme {"
    echo "  --color-*: initial;"
    echo "}"
  fi
  "$BIN" export --format "$FMT" "$SRC"
} > "$tmp" || { rm -f "$tmp"; exit 1; }
mv "$tmp" "$OUT"
