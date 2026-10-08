#!/usr/bin/env python3
"""Codex Stop / Gemini AfterAgent: dirty 마커 없이 make check를 직접 실행한다."""
import json
import os
from pathlib import Path
import signal
import subprocess
import sys


def main():
    if os.environ.get("HARNESS_GATE") == "off":
        print(json.dumps({"systemMessage": "턴 게이트 꺼짐: 미검증. Git 게이트는 유지된다."}))
        return 0
    try:
        event = json.load(sys.stdin)
        if not isinstance(event, dict) or event.get("hook_event_name") not in ("Stop", "AfterAgent"):
            raise ValueError("Stop / AfterAgent 입력 필요")
        active = event.get("stop_hook_active", False)
        if not isinstance(active, bool):
            raise ValueError("stop_hook_active는 boolean이어야 한다")
    except (ValueError, TypeError) as error:
        print(f"[gate:turn] 미검증: 훅 입력 오류: {error}", file=sys.stderr)
        return 2
    root = Path(__file__).resolve().parent.parent
    env = os.environ.copy()
    for key in ("MAKEFLAGS", "MFLAGS", "GNUMAKEFLAGS", "MAKEOVERRIDES"):
        env.pop(key, None)
    try:
        # stdout은 훅 JSON 전용. 센서 출력은 stderr로 전달한다.
        with subprocess.Popen(["make", "check"], cwd=root, env=env,
                              stdout=sys.stderr, stderr=sys.stderr,
                              start_new_session=True) as process:
            try:
                code = process.wait(timeout=540)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                code = 2
                print("[gate:turn] 540초 초과: 미검증", file=sys.stderr)
    except OSError as error:
        print(f"[gate:turn] 실행 불가: {error}", file=sys.stderr)
        code = 2
    if code == 0:
        print("{}")
        return 0
    reason = "make check 실패 또는 미실행. 실패를 고치고 결과를 보고한다. 완료라고 말하지 않는다."
    if active:
        # 실패를 통과로 바꾸지 않고 재시도 루프만 끝낸다. Git은 계속 차단한다.
        print(json.dumps({"systemMessage": "미검증 상태로 종료: " + reason}, ensure_ascii=False))
        return 0
    print(reason, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
