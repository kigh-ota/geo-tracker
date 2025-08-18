import { createClient } from "jsr:@supabase/supabase-js@2";
import type { paths, components } from "./types/api.ts";

// 型エイリアス
type LocationBatchRequest = paths["/locations/batch"]["post"]["requestBody"]["content"]["application/json"];
type LocationBatchResponse = paths["/locations/batch"]["post"]["responses"]["200"]["content"]["application/json"];
type HealthResponse = paths["/health"]["get"]["responses"]["200"]["content"]["application/json"];
type ErrorResponse = paths["/locations/batch"]["post"]["responses"]["400"]["content"]["application/json"];
type Location = components["schemas"]["Location"];
type DeviceInfo = components["schemas"]["DeviceInfo"];
type LocationBatch = components["schemas"]["LocationBatch"];

// Supabaseクライアントの初期化
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? 
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";

const supabase = createClient(supabaseUrl, supabaseKey);

export async function handleRequest(request: Request): Promise<Response> {
  const url = new URL(request.url);
  let path = url.pathname;
  if (path.startsWith("/api")) {
    path = path.replace("/api", "");
  }
  
  // ルートパス "/" を "/health" などに正規化
  if (path === "") {
    path = "/";
  }

  if (path === "/health" && request.method === "GET") {
    try {
      // データベース疎通確認 (SELECT 1)
      const { error } = await supabase.rpc('health_check');
      
      // エラーがある場合は代替手段でDB疎通確認
      if (error) {
        // 簡単なクエリでDB接続確認
        const { error: dbError } = await supabase
          .from('locations')
          .select('id')
          .limit(1);
        
        if (dbError) {
          console.error('Database health check failed:', dbError);
          return new Response(
            JSON.stringify({
              status: "unhealthy",
              timestamp: new Date().toISOString(),
            }),
            { 
              status: 503,
              headers: { "Content-Type": "application/json" } 
            },
          );
        }
      }

      const response: HealthResponse = {
        status: "healthy",
        timestamp: new Date().toISOString(),
      };
      
      return new Response(
        JSON.stringify(response),
        { 
          status: 200,
          headers: { "Content-Type": "application/json" } 
        },
      );
    } catch (error) {
      console.error('Health check error:', error);
      return new Response(
        JSON.stringify({
          status: "unhealthy",
          timestamp: new Date().toISOString(),
        }),
        { 
          status: 503,
          headers: { "Content-Type": "application/json" } 
        },
      );
    }
  }

  if (path === "/locations/batch" && request.method === "POST") {
    try {

      // リクエストボディの解析
      const body: LocationBatchRequest = await request.json();
      const { device_id, locations } = body;

      // 基本的なバリデーション
      if (!device_id || !locations || !Array.isArray(locations) || locations.length === 0) {
        return new Response(
          JSON.stringify({ error: "INVALID_REQUEST", message: "device_id and locations are required" }),
          { 
            status: 400,
            headers: { "Content-Type": "application/json" } 
          },
        );
      }

      // 位置情報データの挿入準備
      const locationInserts = locations.map((location: Location) => ({
        device_id,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        timestamp: location.timestamp,
        altitude: location.altitude,
        speed: location.speed,
        heading: location.heading,
        battery_level: location.battery_level,
        activity_type: location.activity_type,
      }));

      // 位置情報の保存
      const { error: locationsError } = await supabase
        .from("locations")
        .insert(locationInserts);

      if (locationsError) {
        console.error("Locations insert error:", locationsError);
        return new Response(
          JSON.stringify({ error: "DATABASE_ERROR", message: "Failed to save location data" }),
          { 
            status: 500,
            headers: { "Content-Type": "application/json" } 
          },
        );
      }

      const response: LocationBatchResponse = {
        message: `Successfully recorded ${locations.length} locations`,
        received_count: locations.length,
      };

      return new Response(
        JSON.stringify(response),
        { 
          status: 200,
          headers: { "Content-Type": "application/json" } 
        },
      );

    } catch (error) {
      console.error("Request processing error:", error);
      return new Response(
        JSON.stringify({ error: "INVALID_REQUEST", message: "Invalid JSON body" }),
        { 
          status: 400,
          headers: { "Content-Type": "application/json" } 
        },
      );
    }
  }
  
  return new Response(
    JSON.stringify({ error: "Not Found", message: "Endpoint not found" }),
    { 
      status: 404,
      headers: { "Content-Type": "application/json" } 
    },
  );
}