#!/bin/sh
# [sensor:prose] 기계가 셀 수 있는 글쓰기 버릇을 잡는다.
#
# 왜 센서인가: "AI 같은 말투를 고쳐라"는 지적이 프로젝트마다 반복됐다.
# 같은 지적이 반복되면 취향이 아니라 구조다(AGENTS.md §3). 대화로 매번
# 고치면 그 대화에서만 유효하고, 규칙으로 적으면 읽히지 않는다.
#
# 잡는 것은 **밀도**뿐이다. 각 표현 자체는 정상이고, 3줄마다 볼드가 나오면
# 강조가 강조로 안 읽히는 것이 문제다.
#
# ⚠ 한 줄에 여러 항목을 이어붙이는 것(직렬화)은 **잡지 않는다.** 하네스 문서는
#   매 세션 컨텍스트에 들어가므로 압축이 옳다. 줄을 늘리면 토큰만 늘어난다.
#   사용자에게 보이는 화면 카피는 정반대이지만, 그건 이 센서의 대상이 아니라
#   스택 어댑터(stack-template)의 콘텐츠 규칙이 다룬다.
#
# ⚠ 래칫이고, 기준은 **파일별 밀도**다(본문 100줄당). 기존 문서를 전부 고치라고
#   요구하지 않는다. 기존 파일이 나빠질 때만 실패한다. 문서를 새로 늘리는 것도,
#   장황한 글을 덜어내는 것도 통과한다. 좋아지면 그 파일의 기준만 따라 내려간다.
#
# ⚠ 이 센서는 취향을 판정하지 못한다. 좋은 글을 나쁘다고 할 수 있다. 그래서
#   기준선 대비 증가만 보고, 절대 개수로는 아무것도 막지 않는다.
#
# 대상 제외: 외부에서 가져온 문서(HARNESS_ENGINEERING.md), 의존성, 빌드 산출물,
#   git이 무시하는 문서(.gitignore 등). git을 쓸 수 없으면 무시 규칙 없이 전부 본다.
# 끄는 법: Makefile의 SENSORS에서 prose를 빼고 이 파일과 타깃을 지운다.

set -eu
# 검사 대상 루트. 기본은 스크립트의 상위(배치된 프로젝트).
# 키트 저장소가 자기 문서를 검사할 때는 PROSE_ROOT로 덮어쓴다.
ROOT=$(cd "${PROSE_ROOT:-$(dirname "$0")/..}" && pwd)
. "$(cd "$(dirname "$0")" && pwd)/sensor-lib.sh"
cd "$ROOT"

BASELINE="${PROSE_BASELINE:-tool/prose-baseline.json}"
EXCLUDE="${PROSE_EXCLUDE:-HARNESS_ENGINEERING.md}"

sensor_begin prose
command -v python3 >/dev/null 2>&1 || sensor_broken "python3이 필요하다" "python3을 설치하거나 SENSORS에서 prose를 뺀다"

python3 - "$BASELINE" "$EXCLUDE" <<'PY'
import json, os, re, sys, pathlib, subprocess

baseline_path, exclude = sys.argv[1], set(sys.argv[2].split())
SKIP_DIRS = {".git", "node_modules", "vendor", "dist", "build", ".next",
             ".harness", ".dart_tool", "__pycache__", ".venv"}

# 셀 수 있는 버릇만. 각각은 정상 표현이고, 문제는 밀도다.
TELLS = [
    ("bold",    lambda t: len(re.findall(r"\*\*[^*\n]+\*\*", t)),
     "볼드가 잦으면 강조가 강조로 읽히지 않는다",
     "정말 놓치면 안 되는 곳만 남기고 지운다"),
    ("emdash",  lambda t: t.count("—"),
     "em-dash로 문장을 잇는 버릇",
     "쉼표·괄호로 바꾸거나 문장을 끊는다"),
    ("aphorism", lambda t: len(re.findall(r"[^.\n]{5,30}(?:이다|아니다|된다|한다|맞다)\.", t)),
     "짧은 단정문으로 문단을 맺는 버릇",
     "설명으로 끝낸다. 문단마다 교훈을 달지 않는다"),
    ("contrast", lambda t: len(re.findall(r"(?:가|이) 아니라|만이 아니다", t)),
     "'A가 아니라 B' 대조 반복",
     "그냥 B라고 쓴다"),
    # ── 직렬화: 줄을 나눌 수 있는데 한 줄에 밀어넣는 버릇 ──
]

def body_of(text):
    out = []
    fence = False
    for line in text.split("\n"):
        if line.lstrip().startswith("```"):
            fence = not fence; continue
        if fence: continue
        st = line.strip()
        if not st or st.startswith(("|", "#", ">", "<!--")): continue
        out.append(line)
    return "\n".join(out), len(out)

def candidates():
    # git이 무시하는 문서는 프로젝트 문서가 아니다. 비공개 메모·내려받은 원본·생성물이
    # 대부분이고, 검사하면 그 경로가 커밋되는 기준선에 남는다. 추적 중인 문서와
    # 아직 add하지 않은 새 문서(--others)는 검사한다. 무시 규칙은 git이 판단한다.
    # git 저장소가 아니거나 git이 없으면 예전처럼 모든 *.md를 본다.
    try:
        out = subprocess.run(
            ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
            capture_output=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return set(pathlib.Path(".").rglob("*.md"))
    return {pathlib.Path(os.fsdecode(x)) for x in out.split(b"\0") if x.endswith(b".md")}

files, total, all_lines = [], 0, 0
for p in sorted(candidates()):
    if any(part in SKIP_DIRS for part in p.parts): continue
    if str(p) in exclude or p.name in exclude: continue
    try: text = p.read_text(encoding="utf-8")
    except Exception: continue
    body, nlines = body_of(text)
    if nlines < 15: continue          # 짧은 파일은 밀도가 의미 없다
    counts = {k: fn(body) for k, fn, _, _ in TELLS}
    n = sum(counts.values()); total += n; all_lines += nlines
    files.append((n / nlines * 100, n, nlines, str(p), counts))

files.sort(reverse=True)

# 기준선은 **파일별 밀도**다. 전체 합계로 하면 두 가지가 어긋난다.
#   - 개수 총합: 문서를 새로 쓸 때마다 실패한다(분자가 는다)
#   - 전체 밀도: 장황하지만 깨끗한 글을 지우면 실패한다(분모가 준다)
# 둘 다 겪고 파일별로 왔다. 기존 파일이 나빠질 때만 잡힌다.
# (docs/EVIDENCE.md §G)
TOL = 3.0            # 파일별 밀도 허용 오차
per = {path: round(d, 1) for d, n, nl, path, c in files}

try:
    base = json.load(open(baseline_path)).get("files")
except Exception:
    base = None

def save(d):
    # 마지막 개행을 붙인다. 이 파일은 센서가 만드는 생성물이지만 저장소 안에 있어
    # 포맷 검사(Prettier 등)의 대상이 된다. 개행이 없으면 format-check가 이 파일을
    # 물고, `make check`가 prose를 돌린 다음 format-check에서 깨진다 - 한 번은
    # 통과하고 다음 번엔 실패하는 센서가 된다. (docs/EVIDENCE.md §H)
    with open(baseline_path, "w") as f:
        json.dump({"files": d,
                   "_설명": "파일별 글쓰기 버릇 밀도(본문 100줄당). 기존 파일이 이 값보다 나빠지면 실패한다.",
                   "_갱신": "문체를 의도적으로 바꿨으면 해당 파일의 값을 새 밀도로 고친다."},
                  f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")

if not base:
    save(per)
    print(f"[sensor:prose] PASS (baseline 신규 생성: {len(per)}개 파일 · 전체 {total}건/{all_lines}줄)")
    sys.exit(0)

worst_allowed = max(base.values()) if base else 100.0
bad = []
for path, d in sorted(per.items(), key=lambda x: -x[1]):
    if path in base:
        if d > base[path] + TOL:
            bad.append((path, d, base[path], "나빠졌다"))
    elif d > worst_allowed:
        bad.append((path, d, worst_allowed, "새 파일인데 기존 최악보다 나쁘다"))

if not bad:
    # 새 파일과 좋아진 파일을 반영하되, 기존 파일의 기준은 올리지 않는다.
    merged = dict(base)
    for path, d in per.items():
        if path not in merged or d < merged[path]:
            merged[path] = d
    for path in list(merged):
        if path not in per: del merged[path]
    if merged != base: save(merged)
    print(f"[sensor:prose] PASS ({len(per)}개 파일 · 전체 {total}건/{all_lines}줄 · 기존 파일 밀도 유지)")
    sys.exit(0)

print(f"[sensor:prose] FAIL ({len(bad)}개 파일의 문체가 나빠졌다)")
for i, (path, d, ref, why) in enumerate(bad[:5], 1):
    c = next(x[4] for x in files if x[3] == path)
    worst = max(c, key=c.get)
    fix = next(f for k, _, _, f in TELLS if k == worst)
    print(f"  {i}. {path} — 밀도 {d} (기준 {ref}) — {why}, 가장 잦은 것: {worst} {c[worst]}회 — FIX: {fix}")
if len(bad) > 5: print(f"  (총 {len(bad)}개 중 상위 5개)")
print(f"  의도한 변화면 {baseline_path}에서 해당 파일의 값을 고친다.")
sys.exit(1)
PY
