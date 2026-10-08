import { defineConfig } from "@playwright/test";

// 테스트는 가짜 생성 모드로만 돌린다. 구독 사용량을 쓰지 않는다.
export default defineConfig({
  testDir: "tests",
  timeout: 60000,
  use: { baseURL: "http://127.0.0.1:1231" },
  webServer: {
    command:
      "NEXT_DIST_DIR=.next-test ASSET_GEN_FAKE=1 ASSET_GEN_OUTPUT=test-results/output next dev --hostname 127.0.0.1 --port 1231",
    url: "http://127.0.0.1:1231",
    reuseExistingServer: false,
    timeout: 120000,
  },
});
