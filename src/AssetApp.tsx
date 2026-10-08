"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { limits } from "./prompt";
import type { AssetRecord } from "./server/store";
import { Alert, Download, Layers, Refresh, X } from "./icons";
import StyleSelect from "./StyleSelect";
import { groups, styles, type AssetStyle } from "./styles";

type Status = {
  installed: boolean;
  loggedIn: boolean;
  fake: boolean;
  maxParallel: number;
  outputDir?: string;
  desktop?: boolean;
};
type Mode = "explore" | "set";
type Ref = { runId: string; file: string };
type Job = {
  key: string;
  id: string;
  runId: string;
  mode: Mode;
  styleId: string;
  subject: string;
  palette: string;
  extra: string;
  reference: Ref | null;
  state: "queued" | "running" | "done" | "error" | "canceled";
  record?: AssetRecord;
  error?: string;
  startedAt?: number;
};
type Tab = Mode | "history";

const maxSetSubjects = 12;
const newId = () => crypto.randomUUID();
const styleOf = (id: string) => styles.find((s) => s.id === id) as AssetStyle;
const imageUrl = (r: { runId: string; file: string }) =>
  `/api/image/${r.runId}/${r.file}`;
function downloadName(r: AssetRecord) {
  const base = `${r.subject}-${r.styleLabel}`
    .replace(/[^\w가-힣 .-]/g, "")
    .trim()
    .slice(0, 100);
  return `${base || "asset"}.png`;
}

export default function AssetApp() {
  const [status, setStatus] = useState<Status | null>(null);
  const [tab, setTab] = useState<Tab>("explore");
  const [subject, setSubject] = useState("");
  const [palette, setPalette] = useState("");
  const [extra, setExtra] = useState("");
  const [picked, setPicked] = useState<Set<string>>(
    () => new Set(styles.map((s) => s.id)),
  );
  const [kitStyle, setKitStyle] = useState(styles[0].id);
  const [kitSubjects, setKitSubjects] = useState("");
  const [kitPalette, setKitPalette] = useState("");
  const [kitExtra, setKitExtra] = useState("");
  const [reference, setReference] = useState<AssetRecord | null>(null);
  const [jobs, setJobs] = useState<Job[]>([]);
  const [history, setHistory] = useState<AssetRecord[] | null>(null);
  const [message, setMessage] = useState("");
  const [stylesOpen, setStylesOpen] = useState(true);
  const [, tick] = useState(0);
  const controllers = useRef(new Map<string, AbortController>());

  const loadStatus = useCallback(() => {
    setStatus(null);
    fetch("/api/status")
      .then((r) => r.json())
      .then(setStatus)
      .catch(() =>
        setStatus({
          installed: false,
          loggedIn: false,
          fake: false,
          maxParallel: 1,
        }),
      );
  }, []);
  useEffect(loadStatus, [loadStatus]);

  const [loggingIn, setLoggingIn] = useState(false);
  async function login() {
    setLoggingIn(true);
    const res = await fetch("/api/login", { method: "POST" }).catch(() => null);
    if (!res?.ok) {
      setLoggingIn(false);
      setMessage("로그인을 시작하지 못했습니다. 앱을 다시 실행해 주세요.");
      return;
    }
    // 브라우저에서 로그인을 마칠 때까지 3초마다 확인한다(최대 10분)
    for (let i = 0; i < 200; i++) {
      await new Promise((r) => setTimeout(r, 3000));
      const next = await fetch("/api/status")
        .then((r) => r.json() as Promise<Status>)
        .catch(() => null);
      if (next?.loggedIn) {
        setStatus(next);
        break;
      }
    }
    setLoggingIn(false);
  }

  const loadHistory = useCallback(() => {
    fetch("/api/runs")
      .then((r) => r.json())
      .then((d) => setHistory(d.assets ?? []))
      .catch(() => setHistory([]));
  }, []);
  useEffect(() => {
    if (tab === "history") loadHistory();
  }, [tab, loadHistory]);

  const ready = Boolean(status?.installed && status.loggedIn);
  const busy = jobs.some((j) => j.state === "queued" || j.state === "running");

  useEffect(() => {
    if (!jobs.some((j) => j.state === "running")) return;
    const t = setInterval(() => tick((n) => n + 1), 1000);
    return () => clearInterval(t);
  }, [jobs]);

  const patch = useCallback((key: string, next: Partial<Job>) => {
    setJobs((list) => list.map((j) => (j.key === key ? { ...j, ...next } : j)));
  }, []);

  const run = useCallback(
    async (job: Job) => {
      const controller = new AbortController();
      controllers.current.set(job.key, controller);
      try {
        const res = await fetch("/api/generate", {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            runId: job.runId,
            id: job.id,
            mode: job.mode,
            styleId: job.styleId,
            subject: job.subject,
            palette: job.palette,
            extra: job.extra,
            reference: job.reference,
          }),
          signal: controller.signal,
        });
        const data = await res.json().catch(() => ({}));
        if (res.status === 429) {
          // 서버 동시 생성 한도에 걸린 것은 실패가 아니다. 잠시 뒤 다시 줄을 선다.
          await new Promise((r) => setTimeout(r, 3000));
          if (!controller.signal.aborted)
            patch(job.key, { state: "queued", startedAt: undefined });
          return;
        }
        if (res.ok) patch(job.key, { state: "done", record: data });
        else
          patch(job.key, {
            state: "error",
            error: data.error ?? `생성 실패 (${res.status})`,
          });
      } catch {
        patch(job.key, {
          state: controller.signal.aborted ? "canceled" : "error",
          error: controller.signal.aborted
            ? "취소했습니다."
            : "서버에 연결하지 못했습니다.",
        });
      } finally {
        controllers.current.delete(job.key);
      }
    },
    [patch],
  );

  // 대기 중인 작업을 동시 생성 한도만큼 꺼내 실행한다.
  useEffect(() => {
    const limit = status?.maxParallel ?? 1;
    const running = jobs.filter((j) => j.state === "running").length;
    const next = jobs
      .filter((j) => j.state === "queued")
      .slice(0, Math.max(0, limit - running));
    if (!next.length) return;
    setJobs((list) =>
      list.map((j) =>
        next.some((n) => n.key === j.key)
          ? { ...j, state: "running", startedAt: Date.now() }
          : j,
      ),
    );
    next.forEach((j) => void run(j));
  }, [jobs, status, run]);

  function enqueue(items: Omit<Job, "key" | "id" | "state">[]) {
    setJobs(
      items.map((i) => ({ ...i, key: newId(), id: newId(), state: "queued" })),
    );
    setMessage("");
  }

  function startExplore() {
    const s = subject.trim();
    if (!s) return setMessage("무엇을 그릴지 입력해 주세요.");
    if (!picked.size) return setMessage("스타일을 하나 이상 골라 주세요.");
    const runId = newId();
    setStylesOpen(false);
    enqueue(
      styles
        .filter((st) => picked.has(st.id))
        .map((st) => ({
          runId,
          mode: "explore" as const,
          styleId: st.id,
          subject: s,
          palette: palette.trim(),
          extra: extra.trim(),
          reference: null,
        })),
    );
  }

  function startSet() {
    const list = kitSubjects
      .split("\n")
      .map((l) => l.trim())
      .filter(Boolean);
    if (!list.length)
      return setMessage("그릴 대상을 한 줄에 하나씩 입력해 주세요.");
    if (list.length > maxSetSubjects)
      return setMessage(`한 번에 ${maxSetSubjects}개까지 만들 수 있습니다.`);
    if (list.some((l) => l.length > limits.subject))
      return setMessage("대상 설명이 너무 깁니다.");
    const runId = newId();
    const ref = reference
      ? { runId: reference.runId, file: reference.file }
      : null;
    enqueue(
      list.map((s) => ({
        runId,
        mode: "set" as const,
        styleId: kitStyle,
        subject: s,
        palette: kitPalette.trim(),
        extra: kitExtra.trim(),
        reference: ref,
      })),
    );
  }

  function retry(job: Job) {
    patch(job.key, {
      id: newId(),
      state: "queued",
      record: undefined,
      error: undefined,
    });
  }

  function cancelAll() {
    setJobs((list) =>
      list.map((j) =>
        j.state === "queued"
          ? { ...j, state: "canceled", error: "취소했습니다." }
          : j,
      ),
    );
    controllers.current.forEach((c) => c.abort());
  }

  function useForSet(r: AssetRecord) {
    setKitStyle(r.styleId);
    setReference(r);
    if (!kitPalette && r.palette) setKitPalette(r.palette);
    setTab("set");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  const doneCount = jobs.filter((j) => j.state === "done").length;
  const historyRuns = useMemo(() => {
    const map = new Map<string, AssetRecord[]>();
    for (const r of history ?? [])
      map.set(r.runId, [...(map.get(r.runId) ?? []), r]);
    return [...map.values()];
  }, [history]);

  const visibleJobs = jobs.length > 0 && jobs[0].mode === tab ? jobs : [];
  const failedCount = visibleJobs.filter(
    (j) => j.state === "error" || j.state === "canceled",
  ).length;
  const kitCount = kitSubjects.split("\n").filter((l) => l.trim()).length;
  const kitStyleInfo = styleOf(kitStyle);
  const stylePickerOpen = stylesOpen || visibleJobs.length === 0;

  return (
    <>
      <header className="app-header">
        <div className="app-header-inner">
          <span className="brand">
            <img className="brand-mark" src="/brand/mark.svg" alt="" />
            에셋 생성기
          </span>
          <nav className="tabs" aria-label="화면">
            {(
              [
                ["explore", "스타일 탐색"],
                ["set", "세트 만들기"],
                ["history", "기록"],
              ] as const
            ).map(([id, label]) => (
              <button
                key={id}
                className="tab"
                aria-current={tab === id ? "page" : undefined}
                onClick={() => {
                  setTab(id);
                  setMessage("");
                }}
              >
                {label}
              </button>
            ))}
          </nav>
          <StatusPill status={status} />
        </div>
      </header>

      <main className="page">
        <StatusBanner
          status={status}
          loggingIn={loggingIn}
          onLogin={login}
          onRefresh={loadStatus}
        />

        {tab === "explore" && (
          <>
            <section className="intro">
              <h1>대상 하나를 여러 스타일로 그려 봅니다</h1>
              <p>
                마음에 드는 스타일을 찾으면 같은 톤으로 에셋 세트를 이어서 만들
                수 있습니다. 글자 없는 그림만 만듭니다.
              </p>
            </section>

            <section className="composer" aria-label="생성 조건">
              <label className="field field-main">
                <span className="field-label">
                  무엇을 그릴까요? <span className="req">필수</span>
                </span>
                <textarea
                  rows={2}
                  value={subject}
                  maxLength={limits.subject}
                  onChange={(e) => setSubject(e.target.value)}
                  placeholder="예: 리본이 달린 선물상자"
                />
              </label>
              <div className="field-row">
                <label className="field">
                  <span className="field-label">
                    색상 방향 <span className="opt">선택</span>
                  </span>
                  <input
                    value={palette}
                    maxLength={limits.palette}
                    onChange={(e) => setPalette(e.target.value)}
                    placeholder="예: 민트와 진한 초록, 크림색 포인트"
                  />
                </label>
                <label className="field">
                  <span className="field-label">
                    추가 요청 <span className="opt">선택</span>
                  </span>
                  <input
                    value={extra}
                    maxLength={limits.extra}
                    onChange={(e) => setExtra(e.target.value)}
                    placeholder="예: 귀엽고 둥근 느낌, 정면 시점"
                  />
                </label>
              </div>
            </section>

            {stylePickerOpen ? (
              <section className="styles" aria-labelledby="style-heading">
                <div className="section-head">
                  <h2 id="style-heading">
                    스타일 <span className="count">{picked.size}/18</span>
                  </h2>
                  <div className="section-actions">
                    <button
                      type="button"
                      className="btn btn-link"
                      onClick={() =>
                        setPicked(new Set(styles.map((s) => s.id)))
                      }
                    >
                      전체 선택
                    </button>
                    <button
                      type="button"
                      className="btn btn-link"
                      onClick={() => setPicked(new Set())}
                    >
                      해제
                    </button>
                  </div>
                </div>
                <div className="group-chips" aria-label="묶음으로 고르기">
                  {groups.map((g) => {
                    const inGroup = styles.filter((s) => s.group === g);
                    const all = inGroup.every((s) => picked.has(s.id));
                    return (
                      <button
                        key={g}
                        type="button"
                        className="chip"
                        aria-pressed={all}
                        onClick={() =>
                          setPicked((p) => {
                            const n = new Set(p);
                            inGroup.forEach((s) =>
                              all ? n.delete(s.id) : n.add(s.id),
                            );
                            return n;
                          })
                        }
                      >
                        {g}{" "}
                        <span className="chip-count">
                          {inGroup.filter((s) => picked.has(s.id)).length}/
                          {inGroup.length}
                        </span>
                      </button>
                    );
                  })}
                </div>
                <div className="style-grid">
                  {groups
                    .flatMap((g) => styles.filter((s) => s.group === g))
                    .map((s) => {
                      const on = picked.has(s.id);
                      return (
                        <button
                          key={s.id}
                          type="button"
                          className="style-tile"
                          aria-pressed={on}
                          onClick={() =>
                            setPicked((p) => {
                              const n = new Set(p);
                              if (n.has(s.id)) n.delete(s.id);
                              else n.add(s.id);
                              return n;
                            })
                          }
                        >
                          <img src={`/styles/${s.id}.jpg`} alt="" />
                          <span className="style-name">
                            <span className="check" aria-hidden="true">
                              {on ? "✓" : ""}
                            </span>
                            {s.label}
                          </span>
                        </button>
                      );
                    })}
                </div>
                <p className="hint">
                  예시 그림은 같은 치아 캐릭터를 스타일만 바꿔 그린 결과입니다.
                </p>
              </section>
            ) : (
              <div className="style-summary">
                <span>
                  스타일 {picked.size}개:{" "}
                  {styles
                    .filter((st) => picked.has(st.id))
                    .map((st) => st.label)
                    .join(", ")}
                </span>
                <button
                  type="button"
                  className="btn btn-link"
                  onClick={() => setStylesOpen(true)}
                >
                  스타일 다시 고르기
                </button>
              </div>
            )}
            <ActionBar
              ready={ready}
              busy={busy}
              label={`${picked.size}개 스타일로 생성`}
              emptyText="스타일을 하나 이상 골라 주세요."
              otherBusy={busy && jobs[0]?.mode !== "explore"}
              count={picked.size}
              parallel={status?.maxParallel ?? 1}
              onStart={startExplore}
              onCancel={cancelAll}
            />
          </>
        )}

        {tab === "set" && (
          <>
            <section className="intro">
              <h1>고른 스타일로 에셋 세트를 만듭니다</h1>
              <p>
                참고 이미지가 있으면 그 그림의 재질·색감·조명을 맞춰 새 대상을
                그립니다.
              </p>
            </section>

            <section className="composer composer-set" aria-label="세트 조건">
              <div className="set-style">
                <div className="field">
                  <span className="field-label" id="kit-style-label">
                    스타일
                  </span>
                  <StyleSelect
                    labelId="kit-style-label"
                    value={kitStyle}
                    onChange={(id) => {
                      setKitStyle(id);
                      if (reference && reference.styleId !== id)
                        setReference(null);
                    }}
                  />
                </div>
                <div className="ref">
                  <span className="field-label">톤 맞춤 참고 이미지</span>
                  {reference ? (
                    <div className="ref-box">
                      <img src={imageUrl(reference)} alt="" />
                      <div>
                        <strong>{reference.subject}</strong>
                        <span>{reference.styleLabel}</span>
                        <button
                          type="button"
                          className="btn btn-link btn-sm"
                          onClick={() => setReference(null)}
                        >
                          참고 이미지 빼기
                        </button>
                      </div>
                    </div>
                  ) : (
                    <div className="ref-box ref-empty">
                      <img src={`/styles/${kitStyleInfo.id}.jpg`} alt="" />
                      <p>
                        없음. 탐색 결과나 기록에서 &lsquo;이 스타일로
                        세트&rsquo;를 누르면 그 이미지에 톤을 맞춥니다.
                      </p>
                    </div>
                  )}
                </div>
              </div>
              <label className="field">
                <span className="field-label">
                  그릴 대상 <span className="req">필수</span>
                  <span className="opt">
                    한 줄에 하나, 최대 {maxSetSubjects}개
                  </span>
                </span>
                <textarea
                  rows={5}
                  value={kitSubjects}
                  onChange={(e) => setKitSubjects(e.target.value)}
                  placeholder={"예: 선물상자\n신용카드\n알림 벨\n코인"}
                />
              </label>
              <div className="field-row">
                <label className="field">
                  <span className="field-label">
                    색상 방향 <span className="opt">선택</span>
                  </span>
                  <input
                    value={kitPalette}
                    maxLength={limits.palette}
                    onChange={(e) => setKitPalette(e.target.value)}
                  />
                </label>
                <label className="field">
                  <span className="field-label">
                    추가 요청 <span className="opt">선택</span>
                  </span>
                  <input
                    value={kitExtra}
                    maxLength={limits.extra}
                    onChange={(e) => setKitExtra(e.target.value)}
                  />
                </label>
              </div>
            </section>
            <ActionBar
              ready={ready}
              busy={busy}
              label="세트 생성"
              emptyText="그릴 대상을 한 줄에 하나씩 입력해 주세요."
              otherBusy={busy && jobs[0]?.mode !== "set"}
              count={kitCount}
              parallel={status?.maxParallel ?? 1}
              onStart={startSet}
              onCancel={cancelAll}
            />
          </>
        )}

        {message && (
          <p className="message" role="alert">
            {message}
          </p>
        )}

        {visibleJobs.length > 0 && (
          <section className="results" aria-labelledby="result-heading">
            <div className="section-head">
              <h2 id="result-heading">결과</h2>
              <p className="progress-text" role="status">
                {doneCount}/{visibleJobs.length} 완료
                {failedCount > 0 && ` · 실패 ${failedCount}`}
              </p>
            </div>
            <progress
              className="progress"
              max={visibleJobs.length}
              value={doneCount}
              aria-label="생성 진행"
            />
            <div className="card-grid">
              {visibleJobs.map((j) => (
                <JobCard
                  key={j.key}
                  job={j}
                  queuePos={
                    visibleJobs
                      .filter((q) => q.state === "queued")
                      .findIndex((q) => q.key === j.key) + 1
                  }
                  onRetry={() => retry(j)}
                  onCancel={() => controllers.current.get(j.key)?.abort()}
                  onUseForSet={useForSet}
                />
              ))}
            </div>
          </section>
        )}

        {tab === "history" && (
          <section className="history">
            <section className="intro">
              <h1>기록</h1>
              <p>
                이 컴퓨터에서 만든 에셋입니다.
                {status?.outputDir && ` 파일 위치: ${status.outputDir}`}
              </p>
            </section>
            {history === null ? (
              <p className="hint">기록을 불러오는 중입니다.</p>
            ) : historyRuns.length === 0 ? (
              <div className="empty">
                <h2>아직 만든 에셋이 없습니다</h2>
                <p>스타일 탐색에서 대상을 입력하고 생성해 보세요.</p>
                <button
                  className="btn btn-primary"
                  onClick={() => setTab("explore")}
                >
                  스타일 탐색으로 가기
                </button>
              </div>
            ) : (
              historyRuns.map((list) => (
                <div key={list[0].runId} className="run">
                  <div className="run-head">
                    <span className="badge badge-queued">
                      {list[0].mode === "explore" ? "스타일 탐색" : "세트"}
                    </span>
                    <h2>
                      {list[0].mode === "explore"
                        ? list[0].subject
                        : `${list[0].styleLabel} 세트`}
                    </h2>
                    <span className="run-meta">
                      {new Date(list[0].createdAt).toLocaleString("ko-KR")} ·{" "}
                      {list.length}개
                    </span>
                  </div>
                  <div className="card-grid">
                    {list.map((r) => (
                      <AssetCard
                        key={r.id}
                        record={r}
                        onUseForSet={useForSet}
                      />
                    ))}
                  </div>
                </div>
              ))
            )}
          </section>
        )}
      </main>
    </>
  );
}

function StatusPill({ status }: { status: Status | null }) {
  const [label, tone] = !status
    ? ["연결 확인 중", "queued"]
    : status.fake
      ? ["테스트 모드", "warning"]
      : status.installed && status.loggedIn
        ? ["ChatGPT 로그인됨", "done"]
        : ["로그인 필요", "failed"];
  return (
    <span className={`status-pill status-${tone}`}>
      <span className="dot" aria-hidden="true" />
      {label}
    </span>
  );
}

function StatusBanner({
  status,
  loggingIn,
  onLogin,
  onRefresh,
}: {
  status: Status | null;
  loggingIn: boolean;
  onLogin: () => void;
  onRefresh: () => void;
}) {
  if (!status) return null;
  if (status.fake)
    return (
      <div className="banner" role="status">
        <span>
          테스트 모드입니다. 실제 이미지를 만들지 않고 단색 그림으로 흐름만
          확인합니다.
        </span>
      </div>
    );
  if (!status.installed)
    return (
      <div className="banner" role="status">
        <span>
          {status.desktop
            ? "앱에 들어 있는 Codex를 실행하지 못했습니다. 앱을 다시 설치해 주세요."
            : "Codex CLI를 찾지 못했습니다. 시작하기.command로 다시 실행해 주세요."}
        </span>
        <button className="btn btn-secondary btn-sm" onClick={onRefresh}>
          다시 확인
        </button>
      </div>
    );
  if (!status.loggedIn)
    return (
      <div className="banner" role="status">
        <span>
          {loggingIn
            ? "브라우저에서 본인 ChatGPT 계정으로 로그인해 주세요. 끝나면 자동으로 이어집니다."
            : "이미지를 만들려면 본인 ChatGPT 계정으로 한 번 로그인해야 합니다."}
        </span>
        <button
          className="btn btn-primary btn-sm"
          onClick={onLogin}
          disabled={loggingIn}
        >
          {loggingIn ? "로그인 기다리는 중" : "ChatGPT로 로그인"}
        </button>
      </div>
    );
  return null;
}

function ActionBar(props: {
  ready: boolean;
  busy: boolean;
  label: string;
  count: number;
  parallel: number;
  emptyText: string;
  otherBusy: boolean;
  onStart: () => void;
  onCancel: () => void;
}) {
  const minutes = Math.max(
    1,
    Math.ceil((props.count * 50) / props.parallel / 60),
  );
  return (
    <div className="action-bar">
      <span className="estimate">
        {props.otherBusy
          ? "다른 탭의 생성이 진행 중입니다. 끝나거나 취소하면 시작할 수 있습니다."
          : props.count > 0
            ? `이미지 ${props.count}장 · 동시 ${props.parallel}장 · 약 ${minutes}분. 장수만큼 구독 사용량을 씁니다.`
            : props.emptyText}
      </span>
      {props.busy ? (
        <button className="btn btn-secondary btn-lg" onClick={props.onCancel}>
          남은 생성 모두 취소
        </button>
      ) : (
        <button
          className="btn btn-primary btn-lg"
          disabled={!props.ready || props.count === 0}
          onClick={props.onStart}
        >
          {props.label}
        </button>
      )}
    </div>
  );
}

function JobCard({
  job,
  queuePos,
  onRetry,
  onCancel,
  onUseForSet,
}: {
  job: Job;
  queuePos: number;
  onRetry: () => void;
  onCancel: () => void;
  onUseForSet: (r: AssetRecord) => void;
}) {
  if (job.state === "done" && job.record)
    return (
      <AssetCard
        record={job.record}
        onUseForSet={onUseForSet}
        onRetry={onRetry}
      />
    );
  const style = styleOf(job.styleId);
  const title = job.mode === "explore" ? style.label : job.subject;
  const failed = job.state === "error" || job.state === "canceled";
  const seconds = Math.round(
    (Date.now() - (job.startedAt ?? Date.now())) / 1000,
  );
  return (
    <article className={`card card-${job.state}`} data-state={job.state}>
      <div className="card-media placeholder">
        {(job.state === "queued" || job.state === "running") && (
          <span className="placeholder-stack">
            <img
              className="placeholder-thumb"
              src={`/styles/${style.id}.jpg`}
              alt=""
            />
            {job.state === "running" && (
              <span className="spinner" aria-hidden="true" />
            )}
          </span>
        )}
        {failed && <Alert className="placeholder-icon" />}
      </div>
      <div className="card-body">
        <div className="card-title">
          <h3>{title}</h3>
          <Badge state={job.state} />
        </div>
        <p className={`card-status ${failed ? "is-error" : ""}`}>
          {job.state === "running" && `${seconds}초 경과 · 보통 40~75초`}
          {job.state === "queued" && `${queuePos}번째로 기다리는 중`}
          {failed && job.error}
        </p>
        <div className="card-actions">
          {job.state === "running" && (
            <button
              className="btn btn-tertiary btn-sm btn-block"
              onClick={onCancel}
            >
              <X /> 이 생성 취소
            </button>
          )}
          {failed && (
            <button
              className="btn btn-secondary btn-sm btn-block"
              onClick={onRetry}
            >
              <Refresh /> 다시 시도
            </button>
          )}
        </div>
      </div>
    </article>
  );
}

function Badge({ state }: { state: Job["state"] }) {
  const map = {
    queued: ["대기", "queued"],
    running: ["생성 중", "running"],
    done: ["완료", "done"],
    error: ["실패", "failed"],
    canceled: ["취소됨", "failed"],
  } as const;
  const [label, tone] = map[state];
  return <span className={`badge badge-${tone}`}>{label}</span>;
}

function AssetCard({
  record,
  onUseForSet,
  onRetry,
}: {
  record: AssetRecord;
  onUseForSet: (r: AssetRecord) => void;
  onRetry?: () => void;
}) {
  const title = record.mode === "explore" ? record.styleLabel : record.subject;
  const explore = record.mode === "explore";
  const download = (
    <a
      className={`btn btn-sm ${explore ? "btn-tertiary" : "btn-secondary btn-block"}`}
      href={`${imageUrl(record)}?download=${encodeURIComponent(downloadName(record))}`}
      aria-label={`${title} PNG 다운로드`}
    >
      <Download /> {explore ? "다운로드" : "PNG 다운로드"}
    </a>
  );
  const toSet = (
    <button
      className={`btn btn-sm ${explore ? "btn-secondary btn-block" : "btn-tertiary"}`}
      onClick={() => onUseForSet(record)}
      aria-label={`${record.styleLabel} 스타일로 세트 만들기`}
    >
      <Layers /> {explore ? "이 스타일로 세트" : "세트로"}
    </button>
  );
  return (
    <article className="card card-done" data-state="done">
      <a
        className="card-media"
        href={imageUrl(record)}
        target="_blank"
        rel="noreferrer"
        aria-label={`${record.subject} · ${record.styleLabel} 원본 크게 보기`}
      >
        <img
          src={imageUrl(record)}
          alt={`${record.subject} · ${record.styleLabel}`}
        />
      </a>
      <div className="card-body">
        <div className="card-title">
          <h3>{title}</h3>
          <span className="duration">
            {Math.round(record.durationMs / 1000)}초
          </span>
        </div>
        {record.note && <p className="note">{record.note}</p>}
        <div className="card-actions">
          {explore ? toSet : download}
          <div className="card-actions-row">
            {explore ? download : toSet}
            {onRetry && (
              <button
                className="btn btn-tertiary btn-sm"
                onClick={onRetry}
                aria-label={`${title} 다시 생성`}
              >
                <Refresh /> 다시 생성
              </button>
            )}
          </div>
        </div>
      </div>
    </article>
  );
}
