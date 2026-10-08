import type { NextConfig } from "next";
const config: NextConfig = {
  distDir: process.env.NEXT_DIST_DIR ?? ".next",
  poweredByHeader: false,
  devIndicators: false,
  // 데스크톱 앱 빌드(tool/build-app.sh)에서만 단독 실행 서버를 만든다.
  ...(process.env.NEXT_OUTPUT_STANDALONE === "1"
    ? {
        output: "standalone" as const,
        outputFileTracingRoot: process.cwd(),
        // 생성 결과(output/)는 tool/build-app.sh가 묶음에서 지운다. 추적 제외 패턴은
        // 경로 중간에도 맞아 next/dist/build/output 등을 함께 빼므로 쓰지 않는다.
      }
    : {}),
};
export default config;
