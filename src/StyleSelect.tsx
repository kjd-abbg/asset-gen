"use client";

import { useEffect, useId, useRef, useState } from "react";
import { Check, ChevronDown } from "./icons";
import { groups, styles } from "./styles";

// 시스템 기본 목록 대신 썸네일이 있는 스타일 목록. WAI-ARIA 리스트박스 패턴.
// 버튼: Enter·Space·↓·↑로 열기. 목록: ↑↓ 이동, Home/End, Enter·Space 선택, Esc 닫기.
const ordered = groups.flatMap((g) => styles.filter((s) => s.group === g));

export default function StyleSelect({
  value,
  onChange,
  labelId,
}: {
  value: string;
  onChange: (id: string) => void;
  labelId: string;
}) {
  const uid = useId();
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(() =>
    Math.max(
      0,
      ordered.findIndex((s) => s.id === value),
    ),
  );
  const root = useRef<HTMLDivElement>(null);
  const button = useRef<HTMLButtonElement>(null);
  const list = useRef<HTMLDivElement>(null);
  const current = ordered.find((s) => s.id === value) ?? ordered[0];
  const optionId = (i: number) => `${uid}-opt-${i}`;

  function openList() {
    setActive(
      Math.max(
        0,
        ordered.findIndex((s) => s.id === value),
      ),
    );
    setOpen(true);
  }
  function close(focusButton = true) {
    setOpen(false);
    if (focusButton) button.current?.focus();
  }
  function pick(i: number) {
    onChange(ordered[i].id);
    close();
  }

  useEffect(() => {
    if (!open) return;
    list.current?.focus();
    const onDown = (e: MouseEvent) => {
      if (!root.current?.contains(e.target as Node)) close(false);
    };
    document.addEventListener("mousedown", onDown);
    return () => document.removeEventListener("mousedown", onDown);
  }, [open]);

  useEffect(() => {
    if (open)
      document
        .getElementById(optionId(active))
        ?.scrollIntoView({ block: "nearest" });
  }, [open, active]);

  function onListKey(e: React.KeyboardEvent) {
    const last = ordered.length - 1;
    const keys: Record<string, () => void> = {
      ArrowDown: () => setActive((a) => Math.min(last, a + 1)),
      ArrowUp: () => setActive((a) => Math.max(0, a - 1)),
      Home: () => setActive(0),
      End: () => setActive(last),
      Enter: () => pick(active),
      " ": () => pick(active),
      Escape: () => close(),
      Tab: () => close(false),
    };
    const run = keys[e.key];
    if (!run) return;
    if (e.key !== "Tab") e.preventDefault();
    run();
  }

  return (
    <div className="select" ref={root}>
      <button
        ref={button}
        type="button"
        className="select-trigger"
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-labelledby={`${labelId} ${uid}-value`}
        onClick={() => (open ? close() : openList())}
        onKeyDown={(e) => {
          if (["ArrowDown", "ArrowUp"].includes(e.key)) {
            e.preventDefault();
            openList();
          }
        }}
      >
        <img src={`/styles/${current.id}.jpg`} alt="" />
        <span id={`${uid}-value`} className="select-value">
          {current.label}
        </span>
        <span className="select-group">{current.group}</span>
        <ChevronDown className="select-chevron" />
      </button>
      {open && (
        <div
          ref={list}
          className="select-list"
          role="listbox"
          tabIndex={-1}
          aria-labelledby={labelId}
          aria-activedescendant={optionId(active)}
          onKeyDown={onListKey}
        >
          {groups.map((g) => (
            <div key={g} role="group" aria-label={g}>
              <div className="select-group-head" aria-hidden="true">
                {g}
              </div>
              {ordered.map((s, i) =>
                s.group !== g ? null : (
                  <div
                    key={s.id}
                    id={optionId(i)}
                    role="option"
                    aria-selected={s.id === value}
                    className="select-option"
                    data-active={i === active}
                    onMouseMove={() => setActive(i)}
                    onClick={() => pick(i)}
                  >
                    <img src={`/styles/${s.id}.jpg`} alt="" />
                    <span>{s.label}</span>
                    {s.id === value && <Check className="select-check" />}
                  </div>
                ),
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
