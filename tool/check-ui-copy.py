#!/usr/bin/env python3
"""스택 어댑터가 추출한 고정 UI 문구 검사. 문맥 검토를 대신하지 않는다."""
import json
import re
import sys
from pathlib import Path

RULES = {
    "explanatory-dash": re.compile(r"—"),
    "hype": re.compile(r"혁신적인|압도적인|파격적인|완벽한 경험|최적의 솔루션|새로운 기준을"),
    "abstract-copy": re.compile(r"가능성을 (?:열|펼)|마음에 닿|작업 조각|문장 사이의 중요한 신호|한 문장을 끝까지"),
    "personification": re.compile(r"이 화면이 (?:스스로|알아서) 알아"),
    "empty-contrast": re.compile(r"단순(?:한|히).{0,40}(?:넘어|아니라)"),
}


def main():
    try:
        if len(sys.argv) != 2:
            raise ValueError()
        records = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
        if not isinstance(records, list) or not records:
            raise ValueError()
        for row in records:
            if not isinstance(row, dict) or any(not isinstance(row.get(k), str) or not row[k].strip() for k in ("source", "text")):
                raise ValueError()
    except (OSError, ValueError, UnicodeError):
        print("[sensor:ui-copy] ERROR: 비어 있지 않은 source/text 문자열 배열 JSON 파일이 필요합니다", file=sys.stderr)
        return 2
    failed = False
    for row in records:
        for name, pattern in RULES.items():
            if re.search(r"[가-힣]", row["text"]) and pattern.search(row["text"]):
                print(f"[sensor:ui-copy] FAIL {json.dumps(row['source'], ensure_ascii=False)}: {name}", file=sys.stderr)
                failed = True
    if failed:
        return 1
    print(f"[sensor:ui-copy] PASS ({len(records)}개 문구, 문맥 수동 검토 필요)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
