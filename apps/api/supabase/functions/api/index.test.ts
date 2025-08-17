import { assertEquals, assertExists } from "@std/assert";
import type { paths } from "../../../types/api.ts";
import { handleRequest } from "./routes.ts";

// ヘルスチェック用の型
type HealthResponse = paths["/health"]["get"]["responses"]["200"]["content"]["application/json"];

Deno.test("GET /health - ヘルスチェックが正常に動作する", async () => {
  const request = new Request("http://127.0.0.1:54321/functions/v1/api/health", {
    method: "GET",
  });

  // handleRequest関数を呼び出してレスポンスを取得
  const response = await handleRequest(request);

  // ステータスコードの確認
  assertEquals(response.status, 200);

  // レスポンスヘッダーの確認
  assertEquals(response.headers.get("Content-Type"), "application/json");

  // レスポンスボディの確認
  const body = await response.json() as HealthResponse;
  assertEquals(body.status, "healthy");
  assertExists(body.timestamp);
  assertEquals(typeof body.timestamp, "string");

  // タイムスタンプがISO 8601形式であることを確認
  const timestamp = new Date(body.timestamp);
  assertEquals(isNaN(timestamp.getTime()), false);
});