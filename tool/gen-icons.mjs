// 로고 원본(SVG)과 파생 아이콘을 만든다. 사용: node tool/gen-icons.mjs
// 방향: "견본 부채"(2026-10-08 결정자 선택). 상세·사용 규칙은 docs/BRAND.md.
import { chromium } from "@playwright/test";
import { execFileSync } from "node:child_process";
import { mkdirSync, rmSync, writeFileSync } from "node:fs";

const COBALT = "#2453d6";

// 512 좌표계 심볼. 한 색으로만 그리고 카드 사이 틈은 마스크로 오려 낸다(투명).
// 그래서 흰 바탕·검은 바탕·브랜드색 면 어디에 놓아도 같은 형태다.
function card({ id, fg, x, y, w, h, rx, sw, gap, angle, kind, cutBy = [] }) {
  const rot = angle ? ` transform="rotate(${angle} 256 440)"` : "";
  const shape = (extra) =>
    `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}"${rot} ${extra}/>`;
  const cuts = cutBy
    .map(
      (c) =>
        `<rect x="${c.x}" y="${c.y}" width="${c.w}" height="${c.h}" rx="${c.rx}"${c.angle ? ` transform="rotate(${c.angle} 256 440)"` : ""} fill="#000" stroke="#000" stroke-width="${c.sw + gap * 2}"/>`,
    )
    .join("");
  let body = "";
  if (kind === "solid") body = shape(`fill="${fg}"`);
  if (kind === "outline") body = shape(`fill="none" stroke="${fg}" stroke-width="${sw}"`);
  if (kind === "stripes") {
    const lines = Array.from(
      { length: 14 },
      (_, i) =>
        `<rect x="${-24 + i * 46}" y="-40" width="24" height="640" transform="rotate(30 256 241)" fill="${fg}"/>`,
    ).join("");
    body = `<clipPath id="${id}-c"><rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${rx}"${rot}/></clipPath>
      <g clip-path="url(#${id}-c)">${lines}</g>${shape(`fill="none" stroke="${fg}" stroke-width="${sw}"`)}`;
  }
  if (!cuts) return body;
  return `<mask id="${id}-m" maskUnits="userSpaceOnUse" x="-100" y="-100" width="712" height="712"><rect x="-100" y="-100" width="712" height="712" fill="#fff"/>${cuts}</mask><g mask="url(#${id}-m)">${body}</g>`;
}
function fan(fg, id, small) {
  const base = small
    ? { x: 170, y: 96, w: 172, h: 300, rx: 48, sw: 44, gap: 16 }
    : { x: 176, y: 92, w: 160, h: 300, rx: 40, sw: 30, gap: 11 };
  const tilt = small ? 26 : 24;
  const front = { ...base, y: base.y - (small ? 32 : 22), h: base.h + (small ? 32 : 22), sw: 0 };
  const right = { ...base, angle: tilt };
  const left = { ...base, angle: -tilt };
  return [
    card({ id: `${id}-l`, fg, ...left, kind: "outline", cutBy: [right, front] }),
    card({ id: `${id}-r`, fg, ...right, kind: small ? "outline" : "stripes", cutBy: [front] }),
    card({ id: `${id}-f`, fg, ...front, kind: "solid" }),
  ].join("");
}
const symbol = (fg, id = "s") => fan(fg, id, false);
// 32px 이하용: 줄무늬를 빼고 선을 굵게(기본형 단순 축소 금지).
const symbolSmall = (fg, id = "ss") => fan(fg, id, true);
const svg = (viewBox, body) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}"><title>에셋 생성기</title>${body}</svg>\n`;
// 심볼 viewBox는 렌더 후 실제 그려진 범위(getBBox)로 자른다. 아래 measure() 참고.
let SYMBOL_BOX = "0 0 512 512";
const tile = (inner) =>
  `<rect x="100" y="100" width="824" height="824" rx="185" fill="${COBALT}"/><g transform="translate(212 212) scale(1.17)">${inner}</g>`;

// 실제 그려진 범위 측정(획 포함). 큰 변형·작은 변형 중 넓은 쪽 + 여유 8.
{
  const b0 = await chromium.launch();
  const pg = await b0.newPage();
  await pg.setContent(`<svg viewBox="0 0 512 512" width="512" height="512">${symbol("#000", "m1")}${symbolSmall("#000", "m2")}</svg>`);
  const png = await pg.screenshot({ omitBackground: true, clip: { x: 0, y: 0, width: 512, height: 512 } });
  await b0.close();
  // 알파가 있는 픽셀의 경계를 PNG에서 직접 읽는다(마스크·회전 반영)
  const { inflateSync } = await import("node:zlib");
  let o = 8, idat = [], w = 0, h = 0;
  while (o < png.length) {
    const len = png.readUInt32BE(o), type = png.toString("ascii", o + 4, o + 8);
    if (type === "IHDR") { w = png.readUInt32BE(o + 8); h = png.readUInt32BE(o + 12); }
    if (type === "IDAT") idat.push(png.subarray(o + 8, o + 8 + len));
    o += 12 + len;
  }
  const raw = inflateSync(Buffer.concat(idat)), bpp = 4, stride = w * bpp + 1;
  const px = Buffer.alloc(w * h * bpp);
  for (let yy = 0; yy < h; yy++) {
    const f = raw[yy * stride], row = raw.subarray(yy * stride + 1, (yy + 1) * stride);
    const prev = yy ? px.subarray((yy - 1) * w * bpp, yy * w * bpp) : null, cur = px.subarray(yy * w * bpp, (yy + 1) * w * bpp);
    for (let i = 0; i < row.length; i++) {
      const a = i >= bpp ? cur[i - bpp] : 0, b = prev ? prev[i] : 0, c = prev && i >= bpp ? prev[i - bpp] : 0;
      const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
      cur[i] = (row[i] + [0, a, b, (a + b) >> 1, pa <= pb && pa <= pc ? a : pb <= pc ? b : c][f]) & 255;
    }
  }
  let x0 = w, y0 = h, x1 = 0, y1 = 0;
  for (let yy = 0; yy < h; yy++) for (let xx = 0; xx < w; xx++) if (px[(yy * w + xx) * 4 + 3] > 8) {
    x0 = Math.min(x0, xx); y0 = Math.min(y0, yy); x1 = Math.max(x1, xx); y1 = Math.max(y1, yy);
  }
  const side = Math.max(x1 - x0, y1 - y0) + 16, cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
  SYMBOL_BOX = `${Math.round(cx - side / 2)} ${Math.round(cy - side / 2)} ${side} ${side}`;
  console.log("심볼 범위", { x0, y0, x1, y1 }, "viewBox", SYMBOL_BOX);
}

const out = {
  "build-resources/logo-symbol.svg": svg(SYMBOL_BOX, symbol("#111111")),
  "build-resources/logo-symbol-small.svg": svg(SYMBOL_BOX, symbolSmall("#111111")),
  "build-resources/logo-symbol-cobalt.svg": svg(SYMBOL_BOX, symbol(COBALT)),
  "build-resources/icon.svg": svg("0 0 1024 1024", tile(symbol("#ffffff"))),
  "build-resources/icon-small.svg": svg("0 0 1024 1024", tile(symbolSmall("#ffffff"))),
  // 앱 상단 바 로고(소형 변형, 코발트)
  "public/brand/mark.svg": svg(SYMBOL_BOX, symbolSmall(COBALT)),
  // Next app router 파비콘(소형 변형)
  "src/app/icon.svg": svg("0 0 1024 1024", tile(symbolSmall("#ffffff"))),
};
for (const [p, s] of Object.entries(out)) writeFileSync(p, s);

// 1024 PNG 렌더 → iconset(작은 크기는 소형 변형) → icns
const b = await chromium.launch();
const page = await b.newPage({ viewport: { width: 1024, height: 1024 } });
async function png(file, path) {
  await page.setContent(
    `<style>html,body{margin:0;background:transparent}svg{width:1024px;height:1024px;display:block}</style>${out[file]}`,
  );
  await page.screenshot({ path, omitBackground: true });
}
await png("build-resources/icon.svg", "build-resources/icon-1024.png");
await png("build-resources/icon-small.svg", "build-resources/icon-small-1024.png");
await b.close();

const set = "build-resources/icon.iconset";
rmSync(set, { recursive: true, force: true });
mkdirSync(set);
for (const s of [16, 32, 128, 256, 512]) {
  for (const [scale, px] of [["", s], ["@2x", s * 2]]) {
    const src = px <= 32 ? "build-resources/icon-small-1024.png" : "build-resources/icon-1024.png";
    execFileSync("sips", ["-z", String(px), String(px), src, "--out", `${set}/icon_${s}x${s}${scale}.png`], { stdio: "ignore" });
  }
}
execFileSync("iconutil", ["-c", "icns", set, "-o", "build-resources/icon.icns"]);
console.log("아이콘 생성: build-resources/icon.icns, src/app/icon.svg, logo-symbol*.svg");
