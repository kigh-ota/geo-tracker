import { assertEquals, assertExists } from "@std/assert";
import type { paths } from "../../../types/api.ts";
import { handleRequest } from "./routes.ts";

// ヘルスチェック用の型
type HealthResponse = paths["/health"]["get"]["responses"]["200"]["content"]["application/json"];
// 位置情報バッチ用の型
type LocationBatchRequest = paths["/locations/batch"]["post"]["requestBody"]["content"]["application/json"];
type LocationBatchResponse = paths["/locations/batch"]["post"]["responses"]["201"]["content"]["application/json"];

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

Deno.test("POST /locations/batch - 位置情報バッチ送信が正常に動作する", async () => {
  const requestBody: LocationBatchRequest = {
    device_id: "550e8400-e29b-41d4-a716-446655440000",
    device_info: {
      model: "iPhone14,2",
      os_version: "iOS 17.0"
    },
    locations: [
      {
        latitude: 35.6812,
        longitude: 139.7671,
        accuracy: 5.0,
        timestamp: "2024-01-15T10:30:00Z",
        altitude: 45.2,
        speed: 1.5,
        heading: 180.0,
        battery_level: 0.85,
        activity_type: "walking"
      }
    ]
  };

  const request = new Request("http://127.0.0.1:54321/functions/v1/api/locations/batch", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-API-Key": "test-api-key"
    },
    body: JSON.stringify(requestBody)
  });

  // handleRequest関数を呼び出してレスポンスを取得
  const response = await handleRequest(request);

  // ステータスコードの確認
  assertEquals(response.status, 201);

  // レスポンスヘッダーの確認
  assertEquals(response.headers.get("Content-Type"), "application/json");

  // レスポンスボディの確認
  const body = await response.json() as LocationBatchResponse;
  assertEquals(typeof body.message, "string");
  assertEquals(body.received_count, 1);
});