// 에셋 생성기 데스크톱 앱 본체.
// 앱 안의 Next 단독 실행 서버(server/)를 보조 프로세스로 띄우고 창에 연다.
// 생성은 앱에 넣은 Codex 실행 파일과 각자의 ChatGPT 로그인으로 한다.
const {
  app,
  BrowserWindow,
  Menu,
  dialog,
  shell,
  utilityProcess,
} = require("electron");
const fs = require("node:fs");
const net = require("node:net");
const path = require("node:path");

const APP_NAME = "에셋 생성기";
app.setName(APP_NAME);

if (!app.requestSingleInstanceLock()) app.quit();

let server = null;
let win = null;
let baseUrl = "";
let quitting = false;

function freePort() {
  const fixed = Number(process.env.ASSET_GEN_PORT);
  if (fixed) return Promise.resolve(fixed);
  return new Promise((resolve, reject) => {
    const s = net.createServer();
    s.on("error", reject);
    s.listen(0, "127.0.0.1", () => {
      const { port } = s.address();
      s.close(() => resolve(port));
    });
  });
}

async function waitForServer(url, timeoutMs) {
  const until = Date.now() + timeoutMs;
  while (Date.now() < until) {
    try {
      const res = await fetch(url);
      if (res.ok) return true;
    } catch {
      /* 아직 준비 중 */
    }
    await new Promise((r) => setTimeout(r, 200));
  }
  return false;
}

function codexDir() {
  // 패키징된 앱: Contents/Resources/codex, 개발 실행: node_modules의 Codex
  if (app.isPackaged) return path.join(process.resourcesPath, "codex");
  const arch = process.arch === "arm64" ? "arm64" : "x64";
  const triple =
    arch === "arm64" ? "aarch64-apple-darwin" : "x86_64-apple-darwin";
  return path.join(
    __dirname,
    "..",
    "node_modules",
    "@openai",
    `codex-darwin-${arch}`,
    "vendor",
    triple,
  );
}

function outputDir() {
  const dir = path.join(app.getPath("userData"), "output");
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

async function startServer() {
  const port = await freePort();
  baseUrl = `http://127.0.0.1:${port}`;
  const codex = codexDir();
  const serverDir = app.isPackaged
    ? path.join(__dirname, "server")
    : path.join(__dirname, "..", "build", "app", "server");
  // 사용자 셸의 다른 값은 넘기지 않는다. Codex 로그인 위치(HOME·CODEX_HOME)만 전달.
  const env = {
    HOME: process.env.HOME,
    TMPDIR: process.env.TMPDIR,
    PATH: [
      path.join(codex, "codex-path"),
      "/usr/bin",
      "/bin",
      "/usr/sbin",
      "/sbin",
    ].join(":"),
    NODE_ENV: "production",
    PORT: String(port),
    HOSTNAME: "127.0.0.1",
    ASSET_GEN_DESKTOP: "1",
    ASSET_GEN_OUTPUT: outputDir(),
    ASSET_GEN_CODEX_BIN: path.join(codex, "bin", "codex"),
  };
  for (const key of ["CODEX_HOME", "ASSET_GEN_FAKE", "ASSET_GEN_FAKE_DELAY"])
    if (process.env[key]) env[key] = process.env[key];

  server = utilityProcess.fork(path.join(serverDir, "server.js"), [], {
    env,
    stdio: "pipe",
    serviceName: "asset-gen-server",
  });
  const log = [];
  const keep = (d) => {
    log.push(String(d));
    if (log.length > 50) log.shift();
  };
  server.stdout?.on("data", keep);
  server.stderr?.on("data", keep);
  server.on("exit", (code) => {
    server = null;
    if (quitting) return;
    dialog.showErrorBox(
      APP_NAME,
      `서버가 멈췄습니다(코드 ${code}). 앱을 다시 실행해 주세요.\n\n${log.join("").slice(-1500)}`,
    );
    app.quit();
  });
  return waitForServer(`${baseUrl}/api/runs`, 30000);
}

const loadingPage = `data:text/html;charset=utf-8,${encodeURIComponent(
  `<!doctype html><meta charset="utf-8"><title>${APP_NAME}</title>
  <body style="margin:0;display:grid;place-items:center;height:100vh;background:#fafafa;
  font:15px -apple-system,system-ui,sans-serif;color:#4d4d4d">에셋 생성기를 준비하고 있습니다</body>`,
)}`;

function createWindow() {
  win = new BrowserWindow({
    width: 1320,
    height: 900,
    minWidth: 760,
    minHeight: 600,
    title: APP_NAME,
    backgroundColor: "#fafafa",
    show: false,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
    },
  });
  win.once("ready-to-show", () => win.show());
  win.on("closed", () => (win = null));
  // 앱 안의 페이지만 창에서 열고, 바깥 주소는 기본 브라우저로 보낸다.
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (baseUrl && url.startsWith(baseUrl + "/api/image/"))
      return {
        action: "allow",
        overrideBrowserWindowOptions: { width: 900, height: 900, title: APP_NAME },
      };
    shell.openExternal(url);
    return { action: "deny" };
  });
  win.webContents.on("will-navigate", (event, url) => {
    if (!baseUrl || !url.startsWith(baseUrl)) {
      event.preventDefault();
      if (/^https?:/.test(url)) shell.openExternal(url);
    }
  });
  win.loadURL(loadingPage);
}

function buildMenu() {
  const template = [
    {
      label: APP_NAME,
      submenu: [
        { role: "about", label: `${APP_NAME} 정보` },
        { type: "separator" },
        { role: "hide", label: `${APP_NAME} 가리기` },
        { role: "hideOthers", label: "기타 가리기" },
        { type: "separator" },
        { role: "quit", label: `${APP_NAME} 종료` },
      ],
    },
    {
      label: "파일",
      submenu: [
        {
          label: "결과 폴더 열기",
          accelerator: "CmdOrCtrl+Shift+O",
          click: () => shell.openPath(outputDir()),
        },
        { type: "separator" },
        { role: "close", label: "창 닫기" },
      ],
    },
    {
      label: "편집",
      submenu: [
        { role: "undo", label: "실행 취소" },
        { role: "redo", label: "다시 실행" },
        { type: "separator" },
        { role: "cut", label: "잘라내기" },
        { role: "copy", label: "복사" },
        { role: "paste", label: "붙여넣기" },
        { role: "selectAll", label: "전체 선택" },
      ],
    },
    {
      label: "보기",
      submenu: [
        { role: "reload", label: "새로고침" },
        { type: "separator" },
        { role: "resetZoom", label: "실제 크기" },
        { role: "zoomIn", label: "확대" },
        { role: "zoomOut", label: "축소" },
        { type: "separator" },
        { role: "togglefullscreen", label: "전체 화면" },
      ],
    },
    { role: "windowMenu", label: "윈도우" },
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

app.on("second-instance", () => {
  if (win) {
    if (win.isMinimized()) win.restore();
    win.focus();
  }
});

app.whenReady().then(async () => {
  buildMenu();
  createWindow();
  const ok = await startServer().catch(() => false);
  if (!ok) {
    dialog.showErrorBox(APP_NAME, "앱을 준비하지 못했습니다. 다시 실행해 주세요.");
    app.quit();
    return;
  }
  win?.loadURL(baseUrl);
});

app.on("activate", () => {
  if (!win && baseUrl) {
    createWindow();
    win.loadURL(baseUrl);
  }
});

app.on("window-all-closed", () => app.quit());

app.on("before-quit", () => {
  quitting = true;
  server?.kill();
});
