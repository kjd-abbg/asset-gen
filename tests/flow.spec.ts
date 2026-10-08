import { expect, test } from "@playwright/test";

test("스타일 탐색 → 세트 만들기 → 기록", async ({ page }) => {
  await page.goto("/");
  await expect(page.locator(".status-pill")).toHaveText("테스트 모드");

  await page.getByLabel(/무엇을 그릴까요/).fill("리본이 달린 선물상자");
  await page.getByRole("button", { name: "해제", exact: true }).click();
  for (const name of ["클레이 3D", "픽셀 아트", "수채화"])
    await page.getByRole("button", { name, exact: true }).click();
  await expect(
    page.getByRole("button", { name: "픽셀 아트", exact: true }),
  ).toHaveAttribute("aria-pressed", "true");
  await page.getByRole("button", { name: "3개 스타일로 생성" }).click();

  await expect(
    page.getByRole("button", { name: "스타일 다시 고르기" }),
  ).toBeVisible();
  await expect(page.getByText("3/3 완료")).toBeVisible();
  await expect(page.locator('article[data-state="done"] img')).toHaveCount(3);
  const download = page.getByRole("link", { name: /PNG 다운로드/ }).first();
  const res = await page.request.get((await download.getAttribute("href"))!);
  expect(res.headers()["content-type"]).toBe("image/png");
  expect(res.headers()["content-disposition"]).toContain("attachment");

  await page
    .locator("article", { hasText: "픽셀 아트" })
    .getByRole("button", { name: /스타일로 세트/ })
    .click();
  await expect(page.locator(".select-value")).toHaveText("픽셀 아트");
  await expect(page.locator(".ref-box strong")).toHaveText(
    "리본이 달린 선물상자",
  );
  await page.getByLabel(/그릴 대상/).fill("코인\n알림 벨");
  await page.getByRole("button", { name: "세트 생성" }).click();
  await expect(page.getByText("2/2 완료")).toBeVisible();

  await page.getByRole("button", { name: "기록", exact: true }).click();
  await expect(
    page.getByRole("heading", { name: "픽셀 아트 세트" }),
  ).toBeVisible();
  await expect(
    page.getByRole("heading", { name: "리본이 달린 선물상자" }),
  ).toBeVisible();
});

test("스타일 드롭다운은 키보드와 마우스로 고를 수 있다", async ({ page }) => {
  await page.goto("/");
  await page.getByRole("button", { name: "세트 만들기", exact: true }).click();
  const trigger = page.locator(".select-trigger");
  // 라벨과 현재 값이 함께 이름으로 읽힌다
  await expect(
    page.getByRole("button", { name: "스타일 클레이 3D" }),
  ).toBeVisible();
  await trigger.focus();
  await page.keyboard.press("ArrowDown");
  const list = page.getByRole("listbox");
  await expect(list).toBeVisible();
  await expect(page.getByRole("option", { name: "클레이 3D" })).toHaveAttribute(
    "aria-selected",
    "true",
  );
  await page.keyboard.press("ArrowDown");
  await page.keyboard.press("Enter");
  await expect(list).toBeHidden();
  await expect(page.locator(".select-value")).toHaveText("글라스 3D");
  await expect(trigger).toBeFocused();

  await trigger.click();
  await page.getByRole("option", { name: "리노컷" }).click();
  await expect(page.locator(".select-value")).toHaveText("리노컷");

  await trigger.click();
  await page.keyboard.press("Escape");
  await expect(list).toBeHidden();
  await trigger.click();
  await page.getByRole("heading", { name: /에셋 세트를 만듭니다/ }).click();
  await expect(list).toBeHidden();
});

test("실패한 생성은 카드에 이유를 보여주고 다시 시도할 수 있다", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByLabel(/무엇을 그릴까요/).fill("FAIL-TEST");
  await page.getByRole("button", { name: "해제", exact: true }).click();
  await page.getByRole("button", { name: "모노라인", exact: true }).click();
  await page.getByRole("button", { name: "1개 스타일로 생성" }).click();
  await expect(page.getByText("테스트용 실패입니다.")).toBeVisible();
  await expect(page.getByText("실패", { exact: true })).toBeVisible();
  await expect(page.getByRole("button", { name: "다시 시도" })).toBeVisible();
});

test("다른 Origin과 잘못된 입력은 거부한다", async ({ request }) => {
  const body = {
    runId: "aaaaaaaa-1111",
    id: "bbbbbbbb-2222",
    mode: "explore",
    styleId: "clay",
    subject: "컵",
  };
  const foreign = await request.post("/api/generate", {
    data: body,
    headers: { origin: "http://evil.example" },
  });
  expect(foreign.status()).toBe(403);
  const badStyle = await request.post("/api/generate", {
    data: { ...body, styleId: "nope" },
  });
  expect(badStyle.status()).toBe(400);
  const traversal = await request.post("/api/generate", {
    data: { ...body, reference: { runId: "..", file: "../../etc/passwd" } },
  });
  expect(traversal.status()).toBe(400);
});
