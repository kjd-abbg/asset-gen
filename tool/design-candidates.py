# -*- coding: utf-8 -*-
"""강조색 후보 비교: 같은 DESIGN.md에 색만 바꾼 후보를 만들고 대비를 계산하고 견본 화면을 렌더한다.

사용: python3 tool/design-candidates.py <후보.json> [--src DESIGN.md] [--out artifacts/design/system-candidates]

후보.json — 후보 이름 → DESIGN.md `colors:`에서 바꿀 토큰과 값. 예:
  {"a-green": {"primary": "#1f7a63", "on-primary": "#ffffff", "primary-on-light": "#1f7a63"},
   "b-lime":  {"primary": "#7cc242", "on-primary": "#000000", "primary-on-light": "#3d7410"}}
없는 토큰 이름은 오타로 보고 실패한다(조용히 무시하면 비교가 틀린다).

산출: <out>/<후보>/DESIGN.md, <out>/<후보>/preview.html, <out>/index.html(나란히 보기).
대비: 두 토큰이 모두 있는 짝만 계산한다. 기준 미달이 하나라도 있으면 exit 1.
견본 화면은 색 비교용이다. 레이아웃 시안이 아니라는 표시가 화면 맨 위에 들어간다(docs/DESIGN_SYSTEM.md).
"""
import html
import json
import os
import re
import sys

# (전경, 배경, 기준) — WCAG 2.2: 글자 4.5:1, 컨트롤·포커스 표시 3:1
PAIRS = [
    ("on-primary", "primary", 4.5), ("on-primary", "primary-hover", 4.5), ("on-primary", "primary-pressed", 4.5),
    ("primary-on-light", "canvas", 4.5), ("primary-on-dark", "surface-dark", 4.5),
    ("ink", "canvas", 4.5), ("body", "canvas", 4.5), ("mute", "canvas", 4.5), ("on-dark", "surface-dark", 4.5),
    ("on-dark-mute", "surface-dark", 4.5), ("error", "canvas", 4.5), ("link", "canvas", 4.5),
    ("focus", "canvas", 3.0), ("focus", "surface-dark", 3.0), ("hairline-control", "canvas", 3.0),
]


def lum(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)


def ratio(a, b):
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


COLOR_LINE = re.compile(r'^(\s+)([A-Za-z0-9_-]+):\s*["\']?(#[0-9a-fA-F]{3,8})["\']?\s*$')


def front_matter(text):
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        sys.exit("DESIGN.md 맨 앞에 --- 로 감싼 YAML 머리말이 없다")
    return m


def colors_block(lines):
    """`colors:` 아래 들여쓴 `이름: "#hex"` 줄의 (줄 번호, 이름, 값)."""
    out, inside = [], False
    for i, line in enumerate(lines):
        if re.match(r"^colors:\s*$", line):
            inside = True
            continue
        if inside:
            if line and not line[0].isspace():
                break
            m = COLOR_LINE.match(line)
            if m:
                out.append((i, m.group(2), m.group(3)))
    return out


def build(src_text, overrides):
    m = front_matter(src_text)
    lines = m.group(1).split("\n")
    found = {name: (i, val) for i, name, val in colors_block(lines)}
    missing = [k for k in overrides if k not in found]
    if missing:
        raise KeyError(", ".join(missing))
    for k, v in overrides.items():
        i, _ = found[k]
        indent = re.match(r"^(\s+)", lines[i]).group(1)
        lines[i] = f'{indent}{k}: "{v}"'
    colors = {name: val for _, name, val in colors_block(lines)}
    return "---\n" + "\n".join(lines) + "\n---\n" + src_text[m.end():], colors


def radius(src_text):
    m = re.search(r"^rounded:\s*\n((?:\s+.*\n)+)", src_text, re.M)
    if m:
        v = re.search(r"^\s+sm:\s*([0-9.]+(?:px|rem))", m.group(1), re.M)
        if v:
            return v.group(1)
    return "4px"


FALLBACK = {"primary": "#2b5fd9", "on-primary": "#ffffff", "canvas": "#ffffff", "ink": "#111111",
            "body": "#222222", "mute": "#5c5c5c", "hairline": "#d4d4d4", "hairline-control": "#8a8a8a",
            "surface-soft": "#f5f5f5", "surface-dark": "#111111", "on-dark": "#ffffff", "on-dark-mute": "#cccccc",
            "error": "#c4161c", "error-surface": "#fdecec"}


def preview(name, colors, rad, checks):
    c = dict(FALLBACK, **colors)
    c.setdefault("primary-hover", c["primary"])
    c.setdefault("primary-on-light", c["primary"])
    c.setdefault("primary-on-dark", c["primary"])
    c.setdefault("focus", c["primary-on-light"])
    c.setdefault("link", c["primary-on-light"])
    var = "\n".join(f"  --c-{k}: {v};" for k, v in sorted(c.items()))
    rows = "".join(
        f"<tr><td>{fg} / {bg}</td><td>{r:.2f}:1</td><td>{need}:1</td><td>{'통과' if r >= need else '미달'}</td></tr>"
        for fg, bg, need, r in checks)
    n = html.escape(name)
    return f"""<!doctype html><html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1"><title>색 후보 {n}</title>
<style>
:root {{
{var}
}}
*{{box-sizing:border-box;margin:0}}
body{{font-family:system-ui,sans-serif;line-height:1.6;color:var(--c-body);background:var(--c-canvas);word-break:keep-all}}
.notice{{background:var(--c-surface-soft);border-bottom:1px solid var(--c-hairline);padding:12px 24px;font-weight:700;color:var(--c-ink)}}
.w{{max-width:1080px;margin:0 auto;padding:32px 24px;display:grid;gap:32px}}
h1,h2{{color:var(--c-ink);line-height:1.3}}h1{{font-size:32px}}h2{{font-size:20px}}
.nav{{display:flex;gap:24px;align-items:center;border-bottom:1px solid var(--c-hairline);height:56px;font-weight:700;color:var(--c-ink)}}
.nav span[aria-current]{{box-shadow:inset 0 -2px 0 var(--c-primary-on-light);padding:16px 0}}
.btns{{display:flex;gap:12px;flex-wrap:wrap;align-items:center}}
.b{{height:44px;padding:0 20px;border-radius:{rad};font:inherit;font-weight:700;border:2px solid transparent}}
.p{{background:var(--c-primary);color:var(--c-on-primary)}}.ph{{background:var(--c-primary-hover);color:var(--c-on-primary)}}
.s{{background:var(--c-canvas);color:var(--c-ink);border-color:var(--c-ink)}}
.f{{outline:2px solid var(--c-focus);outline-offset:2px}}
a{{color:var(--c-link);font-weight:700}}
.card{{position:relative;border:1px solid var(--c-hairline);border-radius:{rad};padding:24px}}
.card::before{{content:"";position:absolute;top:-1px;left:-1px;width:10px;height:10px;background:var(--c-primary)}}
label{{display:block;margin-bottom:4px}}
input{{width:100%;max-width:28rem;height:44px;padding:0 12px;font:inherit;border:2px solid var(--c-error);border-radius:{rad}}}
.err{{color:var(--c-error);font-weight:700;font-size:14px}}
.dark{{background:var(--c-surface-dark);color:var(--c-on-dark);padding:32px 24px;display:grid;gap:16px}}
.dark h2{{color:var(--c-on-dark)}}.dark .acc{{color:var(--c-primary-on-dark);font-weight:700}}.dark p{{color:var(--c-on-dark-mute)}}
table{{border-collapse:collapse;font-size:14px;font-variant-numeric:tabular-nums}}td{{padding:6px 16px 6px 0;border-bottom:1px solid var(--c-hairline)}}
</style></head><body>
<p class="notice">색 비교용 견본입니다. 레이아웃 시안이 아닙니다. 후보 {n}의 강조색이 버튼·링크·현재 위치·포커스·어두운 면에서 어떻게 보이는지만 비교합니다.</p>
<div class="w">
<div class="nav"><span>회사</span><span aria-current="page">제품</span><span>문의</span></div>
<h1>후보 {n}</h1>
<div class="btns"><button class="b p">주 행동</button><button class="b ph">주 행동(호버)</button><button class="b s">보조 행동</button><button class="b p f">포커스</button><a href="#">본문 링크</a></div>
<div class="card"><h2>카드 제목</h2><p>카드 모서리 표식과 본문 글자의 조합입니다.</p></div>
<div><label><b>입력 오류 상태</b></label><input aria-invalid="true"><p class="err">값을 입력해 주세요.</p></div>
<div class="dark"><p class="acc">어두운 면 위의 강조 글자</p><h2>어두운 면 제목</h2><p>어두운 면 보조 글자</p><div class="btns"><button class="b p">주 행동</button></div></div>
<table><tr><td>전경 / 배경</td><td>대비</td><td>기준</td><td>판정</td></tr>{rows}</table>
</div></body></html>
"""


def main():
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        sys.exit(0 if args else 2)
    cand_path, src, out = args[0], "DESIGN.md", "artifacts/design/system-candidates"
    if "--src" in args:
        src = args[args.index("--src") + 1]
    if "--out" in args:
        out = args[args.index("--out") + 1]
    cands = json.load(open(cand_path, encoding="utf-8"))
    src_text = open(src, encoding="utf-8").read()
    rad = radius(src_text)
    ok, names = True, []
    for name, overrides in cands.items():
        if not re.match(r"^[A-Za-z0-9_-]+$", name):
            sys.exit(f"후보 이름은 영문·숫자·-·_만: {name}")
        try:
            text, colors = build(src_text, overrides)
        except KeyError as e:
            print(f"✗ {name}: {src}의 colors에 없는 토큰 — {e}")
            ok = False
            continue
        checks = [(fg, bg, need, ratio(colors[fg], colors[bg])) for fg, bg, need in PAIRS
                  if fg in colors and bg in colors]
        for fg, bg, need, r in checks:
            if r < need:
                ok = False
                print(f"✗ {name}: {fg} {colors[fg]} / {bg} {colors[bg]} = {r:.2f}:1 < {need}:1")
        if "primary-on-light" not in colors and "canvas" in colors and ratio(colors["primary"], colors["canvas"]) < 4.5:
            print(f"  {name}: primary가 canvas 위 {ratio(colors['primary'], colors['canvas']):.2f}:1 — "
                  "흰 바탕 글자·선·현재 위치 표시에 쓸 primary-on-light를 따로 정한다")
        d = os.path.join(out, name)
        os.makedirs(d, exist_ok=True)
        open(os.path.join(d, "DESIGN.md"), "w", encoding="utf-8").write(text)
        open(os.path.join(d, "preview.html"), "w", encoding="utf-8").write(preview(name, colors, rad, checks))
        names.append(name)
        print(f"✓ {name} → {d}/DESIGN.md, preview.html (대비 {len(checks)}쌍 계산)")
    frames = "".join(f'<figure><figcaption>{html.escape(n)}</figcaption><iframe src="{n}/preview.html"></iframe></figure>'
                     for n in names)
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, "index.html"), "w", encoding="utf-8").write(
        '<!doctype html><html lang="ko"><head><meta charset="utf-8"><title>색 후보 비교</title><style>'
        "body{margin:0;font-family:system-ui,sans-serif}p{padding:12px 16px;margin:0;font-weight:700}"
        "main{display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:8px;padding:8px}"
        "iframe{width:100%;height:1400px;border:1px solid #ccc}figcaption{font-weight:700;padding:4px 0}</style></head>"
        "<body><p>색 비교용 견본입니다. 레이아웃 시안이 아닙니다.</p><main>" + frames + "</main></body></html>\n")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
