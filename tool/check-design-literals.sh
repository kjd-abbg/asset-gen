#!/bin/sh
# [sensor:design-literals] 화면 코드가 토큰 대신 쓴 색·크기 리터럴을 래칫으로 잡는다.
#
# 왜 센서인가: 에이전트는 화면을 만들 때 토큰 대신 `#3b82f6`, `13px`, `bg-blue-500`,
# `mt-[1.3rem]`을 그 자리에서 지어낸다. 화면이 늘수록 비슷한 회색·간격이 수십 개가
# 되고 다크 모드·브랜드 변경 때 전부 손으로 찾아야 한다. docs/DESIGN_TOKENS.md의
# "토큰 변수만 참조" 규칙이 리뷰마다 반복되지 않게 센서로 올렸다(AGENTS.md §3).
#
# 잡는 것 (주석은 제거한 뒤 검사):
#   hex      색이 들어갈 자리의 16진 색: CSS 값, 따옴표로 감싼 색 문자열, Tailwind `[#fff]`
#   color-fn rgb·rgba·hsl·hsla·hwb·lab·lch·oklab·oklch·color-mix
#   named    색 속성 값의 이름 색(red, tomato, white 등. transparent·currentColor 제외)
#   px       0·0.5·1px을 뺀 px (음수 포함). @media·@container 조건, min-/max-width 조건 제외
#   unit     CSS 값과 Tailwind 임의값의 rem·em·pt, 임의값의 %·vh·vw
#   jsx      JSX/객체 스타일의 단위 없는 숫자(padding: 13 → React는 px로 처리)
#   palette  Tailwind 기본 팔레트 클래스(bg-blue-500 등)
# 잡지 않는 것: 토큰 원본(DESIGN_TOKEN_FILES, 경로에 DESIGN_EXCLUDE 조각이 든 파일),
#   테스트·스토리 파일, 줄 끝에 `design-literal-ok`와 이유를 단 예외.
#   위계·정렬·리듬은 판정하지 않는다. 0건을 시각 품질 통과로 보고하지 말 것.
#
# 래칫: 기준선은 파일마다 "리터럴 값 → 개수"를 기록한다. 어느 값이든 기준선보다 늘거나
#   새 값이 생기면 실패하고, 실패 출력은 새로 생긴 값과 그 줄을 보여 준다. 줄면 기준선이
#   따라 내려간다. 기준선 파일이 없으면 통과가 아니라 오류(exit 2)다. 지우는 것으로
#   센서를 무력화하지 못하게 했다. 처음 한 번만 `--init`으로 만든다.
#
# 설정 (환경 변수, Makefile 타깃에서 지정):
#   DESIGN_SRC         검사할 디렉터리, 공백 구분 (기본: src)
#   DESIGN_TOKEN_FILES 토큰 원본 파일 경로, 공백 구분 (예: src/app/globals.css)
#   DESIGN_EXCLUDE     경로에 이 조각이 들어가면 제외, 공백 구분 (기본: tokens generated)
#   DESIGN_EXT         확장자 (기본: css scss sass less tsx jsx ts js vue svelte html astro)
#   DESIGN_PALETTE     0이면 Tailwind 기본 팔레트 검사를 끈다 (기본: 1)
#   DESIGN_BASELINE    기준선 파일 (기본: tool/design-literals-baseline.json)
#
# 사용: sh tool/check-design-literals.sh          검사
#       sh tool/check-design-literals.sh --init   기준선 생성(처음 한 번, 또는 의도한 일괄 변경 뒤)
# 출력 규약: agent-harness-kit/docs/SENSOR_CONTRACT.md
# 종료 코드: 0 통과 / 1 늘어남 / 2 센서 자체 오류(설정·기준선 문제)

set -eu
ROOT=$(cd "${DESIGN_ROOT:-$(dirname "$0")/..}" && pwd)
. "$(cd "$(dirname "$0")" && pwd)/sensor-lib.sh"
cd "$ROOT"

sensor_begin design-literals
command -v python3 >/dev/null 2>&1 || sensor_broken "python3이 필요하다" "python3을 설치하거나 SENSORS에서 design-literals를 뺀다"

MODE=check
[ "${1:-}" = "--init" ] && MODE=init

SRC="${DESIGN_SRC:-src}"
found=0
for d in $SRC; do [ -d "$d" ] && found=1; done
[ "$found" -eq 1 ] || sensor_broken "검사할 디렉터리가 없다: $SRC" \
  "화면 코드 위치를 DESIGN_SRC로 지정한다 (예: DESIGN_SRC=\"app components\")"

python3 - "$MODE" "$SRC" "${DESIGN_EXCLUDE:-tokens generated}" "${DESIGN_TOKEN_FILES:-}" \
  "${DESIGN_EXT:-css scss sass less tsx jsx ts js vue svelte html astro}" \
  "${DESIGN_PALETTE:-1}" "${DESIGN_BASELINE:-tool/design-literals-baseline.json}" <<'PY'
import json, os, pathlib, re, subprocess, sys
from collections import Counter

mode, src_dirs, exclude, token_files, exts, palette_on, baseline_path = sys.argv[1:8]
src_dirs, exclude = src_dirs.split(), exclude.split()
token_files = {os.path.normpath(p) for p in token_files.split()}
exts = {"." + e for e in exts.split()}
palette_on = palette_on != "0"
SKIP_DIRS = {".git", "node_modules", "vendor", "dist", "build", ".next", ".harness",
             "coverage", "__pycache__", ".venv", "out"}
MARK = "design-literal-ok"
CSS_EXT = {".css", ".scss", ".sass", ".less"}

HEX = r"#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})(?![\w-])"
NAMED = ("red|blue|green|black|white|gray|grey|orange|purple|yellow|pink|brown|navy|teal|"
         "maroon|olive|lime|aqua|cyan|magenta|fuchsia|silver|gold|tomato|coral|salmon|crimson|"
         "indigo|violet|beige|ivory|khaki|lavender|plum|orchid|tan|turquoise|skyblue|"
         "steelblue|slategray|darkgray|lightgray|whitesmoke|gainsboro")
TW_COLORS = ("slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|"
             "cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose")
TW_PREFIX = ("bg|text|border|border-[trblxy]|ring|ring-offset|outline|fill|stroke|from|via|to|"
             "decoration|divide|shadow|accent|caret|placeholder")
RULES = [
    # (종류, 정규식, 대상: all|css|js)
    ("hex", re.compile(r"\[(" + HEX + r")\]"), "all"),                          # bg-[#fff]
    ("hex", re.compile(r"""["'`](""" + HEX + r""")["'`]"""), "all"),            # "#fff"
    ("hex", re.compile(r"(?:^|[\s:(,])(" + HEX + r")"), "css"),                 # CSS 값
    ("hex", re.compile(r"(?:[:(,]\s*|solid\s+|dashed\s+)(" + HEX + r")"), "js"), # CSS 문자열 조각
    ("color-fn", re.compile(r"\b((?:rgba?|hsla?|hwb|lab|lch|oklab|oklch|color-mix)\()"), "all"),
    ("named", re.compile(r"(?:color|background(?:-color)?|border(?:-[a-z]+)?-color|fill|stroke|outline-color)\s*:\s*['\"]?(" + NAMED + r")\b['\"]?\s*[;,}\n]", re.I), "all"),
    ("named", re.compile(r"\b(?:color|background(?:Color)?|borderColor|fill|stroke)\s*:\s*['\"](" + NAMED + r")['\"]", re.I), "js"),
    ("px", re.compile(r"(?<![\w.#-])(-?(?:\d+\.\d+|\.\d+|\d+)px)\b"), "all"),
    ("unit", re.compile(r"\[(-?(?:\d+\.\d+|\.\d+|\d+)(?:rem|em|pt|%|vh|vw|dvh|svh|lvh|ch))\]"), "all"),
    ("unit", re.compile(r"(?<![\w.#-])(-?(?:\d+\.\d+|\.\d+|\d+)(?:rem|em|pt))\b"), "css"),
    ("unit", re.compile(r"""["'`](-?(?:\d+\.\d+|\.\d+|\d+)(?:rem|em|pt))["'`]"""), "js"),
    ("unit", re.compile(r"\b[a-z-]+\s*:\s*(-?(?:\d+\.\d+|\.\d+|\d+)(?:rem|em|pt))\b"), "js"),  # CSS-in-JS 문자열
    ("jsx", re.compile(r"\b((?:padding|margin|gap|rowGap|columnGap|top|left|right|bottom|inset|width|height|minWidth|maxWidth|minHeight|maxHeight|fontSize|letterSpacing|borderRadius|borderWidth)(?:Top|Right|Bottom|Left|Block|Inline|X|Y)?\s*:\s*-?(?:\d+\.\d+|\d+))(?![\w.%'\"])"), "js"),
]
PALETTE = re.compile(r"(?<![\w-])((?:[a-z0-9-]+:)*(?:" + TW_PREFIX + r")-(?:" + TW_COLORS + r")-(?:50|[1-9]00|950))(?:/\d+)?\b")
ALLOWED_PX = {"0px", "1px", "0.5px", ".5px", "-0px", "-1px"}
ZERO_JSX = re.compile(r":\s*-?(?:0|1)$")

def strip_comments(text, is_css):
    # 문자열 안의 `//`(URL)까지 지우지 않도록 블록 주석은 전부, 줄 주석은 앞이 공백·줄 시작일 때만.
    text = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    if not is_css:
        text = re.sub(r"(^|[\s;{}(])//[^\n]*", r"\1", text)
        text = re.sub(r"<!--.*?-->", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    return text

MEDIA = re.compile(r"@(?:media|container|custom-media)[^{]*")
COND = re.compile(r"\(\s*(?:min|max)-(?:width|height|inline-size|block-size)\s*:[^)]*\)")
TW_VARIANT = re.compile(r"\b(?:min|max)-\[[^\]]*\]:")

def scan_line(line, kind):
    line = MEDIA.sub("", line)
    line = COND.sub("", line)
    line = TW_VARIANT.sub("", line)
    found, taken = [], []
    for name, rx, target in RULES:
        if target != "all" and target != kind: continue
        for m in rx.finditer(line):
            v = m.group(1)
            if name == "px" and v in ALLOWED_PX: continue
            if name == "jsx" and ZERO_JSX.search(v): continue
            a, b = m.span(1)
            if any(a < y and x < b for x, y in taken): continue  # 같은 값을 규칙 둘이 세지 않게
            taken.append((a, b))
            found.append((name, re.sub(r"\s+", " ", v)))
    if palette_on and kind == "js":
        for m in PALETTE.finditer(line):
            found.append(("palette", m.group(1)))
    return found

def candidates():
    try:
        out = subprocess.run(["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
                             capture_output=True, check=True).stdout
        files = [pathlib.Path(os.fsdecode(x)) for x in out.split(b"\0") if x]
    except (OSError, subprocess.CalledProcessError):
        files = [p for d in src_dirs for p in pathlib.Path(d).rglob("*") if p.is_file()]
    roots = [pathlib.Path(d) for d in src_dirs]
    for p in files:
        if p.suffix not in exts: continue
        if not any(p == r or r in p.parents for r in roots): continue
        if any(part in SKIP_DIRS for part in p.parts): continue
        s = str(p)
        if os.path.normpath(s) in token_files: continue
        if any(x in s for x in exclude): continue
        if re.search(r"\.(test|spec|stories)\.\w+$", s) or s.endswith(".d.ts"): continue
        if not p.exists(): continue
        yield p

current, where = {}, {}
for p in sorted(candidates()):
    try: raw = p.read_text(encoding="utf-8")
    except Exception: continue
    kind = "css" if p.suffix in CSS_EXT else "js"
    text = strip_comments(raw, kind == "css")
    raw_lines = raw.splitlines()
    c = Counter()
    for i, line in enumerate(text.splitlines(), 1):
        # 예외 표시는 주석에 다는 경우가 많아 주석을 지우기 전 원본 줄에서 확인한다.
        if i <= len(raw_lines) and MARK in raw_lines[i - 1]: continue
        for name, v in scan_line(line, kind):
            key = f"{name}:{v}"
            c[key] += 1
            where.setdefault((str(p), key), i)
    if c: current[str(p)] = dict(c)

def save(d):
    # 마지막 개행: 포맷 검사가 이 생성물을 물지 않게 한다 (docs/EVIDENCE.md §H)
    with open(baseline_path, "w") as f:
        json.dump({"version": 2, "files": d,
                   "_설명": "파일별 '종류:값' → 개수. 어느 값이든 늘거나 새 값이 생기면 실패한다.",
                   "_갱신": "의도한 예외는 줄 끝 design-literal-ok와 이유. 의도한 일괄 변경 뒤에만 --init으로 다시 만든다."},
                  f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")

total = sum(sum(v.values()) for v in current.values())
if mode == "init":
    save(current)
    print(f"[sensor:design-literals] PASS (기준선 생성: {len(current)}개 파일 · {total}건 → {baseline_path})")
    sys.exit(0)

try:
    data = json.load(open(baseline_path))
except FileNotFoundError:
    print(f"[sensor:design-literals] ERROR — 기준선 파일이 없다: {baseline_path}", file=sys.stderr)
    print("  FIX: 처음 도입이면 `sh tool/check-design-literals.sh --init`으로 만들고 커밋한다. 지워진 것이면 git에서 복구한다.", file=sys.stderr)
    sys.exit(2)
except Exception:
    print(f"[sensor:design-literals] ERROR — 기준선을 읽을 수 없다: {baseline_path}", file=sys.stderr)
    print("  FIX: git에서 복구하거나 --init으로 다시 만든다.", file=sys.stderr)
    sys.exit(2)
base = data.get("files") if isinstance(data, dict) else None
if data.get("version") != 2 or not isinstance(base, dict):
    print("[sensor:design-literals] ERROR — 기준선 형식이 이전 버전이다", file=sys.stderr)
    print("  FIX: 키트 0.9.15부터 값별 기준선을 쓴다. `sh tool/check-design-literals.sh --init`으로 다시 만들고 커밋한다.", file=sys.stderr)
    sys.exit(2)

bad = []
for path, c in sorted(current.items()):
    ref = base.get(path, {})
    for key, n in sorted(c.items()):
        if n > ref.get(key, 0):
            bad.append((path, key, n, ref.get(key, 0)))

if not bad:
    shrunk = {p: {k: n for k, n in c.items() if n <= base.get(p, {}).get(k, 0)} for p, c in current.items()}
    shrunk = {p: c for p, c in shrunk.items() if c}
    before = sum(sum(v.values()) for v in base.values())
    if shrunk != base: save(shrunk)
    note = f" · 기준선보다 {before - total}건 줄었다" if before > total else ""
    print(f"[sensor:design-literals] PASS ({len(current)}개 파일 · {total}건{note})")
    sys.exit(0)

FIX = {
    "hex": "색을 semantic 토큰 변수로 바꾼다", "color-fn": "색 함수를 토큰 참조로 바꾼다. 정의는 토큰 원본에서만",
    "named": "이름 색을 토큰으로 바꾼다", "px": "간격·크기를 space·size 토큰으로 바꾼다",
    "unit": "임의 rem·em 값을 스케일 토큰으로 바꾼다", "jsx": "인라인 숫자 스타일 대신 토큰 클래스·변수를 쓴다",
    "palette": "기본 팔레트 대신 프로젝트 토큰 색 클래스를 쓴다",
}
print(f"[sensor:design-literals] FAIL ({len(bad)}개 값이 늘었다)")
for i, (path, key, n, ref) in enumerate(bad[:5], 1):
    kind, val = key.split(":", 1)
    why = "새 값" if ref == 0 else f"기준 {ref}건 → {n}건"
    print(f"  {i}. {path}:{where[(path, key)]} — `{val}` ({kind}, {why}) — FIX: {FIX[kind]}. 의도한 예외면 줄 끝에 {MARK}와 이유")
if len(bad) > 5: print(f"  (총 {len(bad)}개 중 상위 5개)")
sys.exit(1)
PY
