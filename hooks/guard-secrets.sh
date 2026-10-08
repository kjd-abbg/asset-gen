#!/bin/sh
# PreToolUse(Edit|Write) — 코드에 비밀값 리터럴이 들어가는 것을 막는다.
#
# 왜 훅인가: AGENTS.md §4 DENY에 "코드에 API 키·시크릿·토큰 리터럴 삽입"이
# 적혀 있지만, 산문 금지는 지켜졌는지 확인할 방법이 없다. 그리고 이 실패는
# **되돌릴 수 없다** — 커밋되어 원격에 올라간 비밀값은 지워도 히스토리에 남고,
# 이미 유출된 것으로 취급해야 한다. 되돌릴 수 없는 행동은 사후 검출이 아니라
# 사전 차단이어야 한다(HARNESS_ENGINEERING.md §7).
#
# 이 훅은 `.claude/settings.json`의 deny 목록과 달리 **내용**을 본다.
# 접두사 매칭은 "무엇을 하는가"만 보고 "무엇을 쓰는가"는 못 본다.
#
# ⚠ fail-open: 파싱이 안 되면 막지 않는다. 이 훅은 안전망이지 벽이 아니다.
#    진짜 방어선은 시크릿 스캐너(CI)와 키 회전이다.
#
# 끄는 법: .claude/settings.json 의 hooks.PreToolUse에서 이 항목을 지운다.

[ "${HARNESS_SECRET_GUARD:-on}" = "off" ] && exit 0

command -v python3 >/dev/null 2>&1 || exit 0

input=$(cat 2>/dev/null || true)
[ -n "$input" ] || exit 0

# ⚠ `python3 - <<'PY'` 는 heredoc이 stdin을 차지하므로 파이프로 넣은 JSON이
#   python에게 닿지 않는다(조용히 아무것도 검사하지 않는 상태가 된다).
#   입력은 임시 파일로 넘기고 stdin은 스크립트에만 쓴다.
tmp=$(mktemp 2>/dev/null || echo "/tmp/harness-hook.$$")
printf '%s' "$input" > "$tmp"

python3 - "$tmp" <<'PY'
import sys, json, re

try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        d = json.load(fh)
except Exception:
    sys.exit(0)                      # 파싱 실패 = 막지 않는다

ti = d.get("tool_input") or {}
path = ti.get("file_path") or ""
# Write는 content, Edit는 new_string에 새 내용이 들어온다.
text = ti.get("content") or ti.get("new_string") or ""
if not text:
    sys.exit(0)

# .env.example 같은 자리표시자 파일은 검사하지 않는다.
if path.endswith((".example", ".sample", ".template", ".tmpl")):
    sys.exit(0)

# 자리표시자로 보이면 진짜 비밀값이 아니다.
PLACEHOLDER = re.compile(
    r"(?i)(your[_-]?|example|placeholder|xxx+|<[^>]+>|changeme|dummy|"
    r"process\.env|os\.environ|getenv|\$\{|\.\.\.)"
)

# 형태가 명확한 것만 잡는다. 넓게 잡으면 오탐으로 훅이 꺼진다.
PATTERNS = [
    (r"sk-[A-Za-z0-9]{32,}",                         "OpenAI 계열 API 키"),
    (r"sk-ant-[A-Za-z0-9_\-]{32,}",                  "Anthropic API 키"),
    (r"ghp_[A-Za-z0-9]{36}",                         "GitHub personal access token"),
    (r"github_pat_[A-Za-z0-9_]{60,}",                "GitHub fine-grained token"),
    (r"AKIA[0-9A-Z]{16}",                            "AWS access key ID"),
    (r"xox[baprs]-[A-Za-z0-9-]{10,}",                "Slack token"),
    (r"-----BEGIN (?:RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----", "개인키"),
    (r"eyJ[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}", "JWT"),
    (r"(?i)(?:api[_-]?key|secret|password|passwd|token)\s*[:=]\s*"
     r"[\"'][^\"'\s]{20,}[\"']",                     "하드코딩된 자격증명"),
]

hits = []
for pat, label in PATTERNS:
    for m in re.finditer(pat, text):
        frag = m.group(0)
        if PLACEHOLDER.search(frag):
            continue
        line = text[:m.start()].count("\n") + 1
        masked = frag[:6] + "…" + frag[-2:] if len(frag) > 12 else "…"
        hits.append((line, label, masked))
        break

if not hits:
    sys.exit(0)

loc = path or "(파일)"
detail = "\n".join(f"    {loc}:{ln} — {label} ({masked})"
                   for ln, label, masked in hits)

reason = (
    "비밀값 리터럴이 감지되어 쓰기를 막았다 (AGENTS.md §4 DENY).\n"
    f"{detail}\n\n"
    "저장소에 들어간 비밀값은 지워도 히스토리에 남는다 — 되돌릴 수 없다.\n"
    "FIX: 값을 환경 변수로 옮기고 코드에서는 이름만 참조한다. "
    "키 이름은 .env.example에 적고 실제 값은 .env(gitignore)에 둔다.\n"
    "오탐이면 HARNESS_SECRET_GUARD=off 로 한 번 우회할 수 있으나, "
    "그 경우 왜 오탐인지 AGENTS.md §B에 남긴다."
)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }
}, ensure_ascii=False))
sys.exit(2)
PY
rc=$?
rm -f "$tmp"
exit $rc
