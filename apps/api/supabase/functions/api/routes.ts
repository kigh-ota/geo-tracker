import { createClient } from "jsr:@supabase/supabase-js@2";

// Supabaseクライアントの初期化
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? 
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";

const supabase = createClient(supabaseUrl, supabaseKey);

export async function handleRequest(request: Request): Promise<Response> {
  const url = new URL(request.url);
  const path = url.pathname.replace("/functions/v1/api", "");
  
  if (path === "/health" && request.method === "GET") {
    return new Response(
      JSON.stringify({
        status: "healthy",
        timestamp: new Date().toISOString(),
      }),
      { 
        status: 200,
        headers: { "Content-Type": "application/json" } 
      },
    );
  }

  if (path === "/locations/batch" && request.method === "POST") {
    try {
      // APIキーの検証
      const apiKey = request.headers.get("X-API-Key");
      if (!apiKey) {
        return new Response(
          JSON.stringify({ error: "UNAUTHORIZED", message: "API key is required" }),
          { 
            status: 401,
            headers: { "Content-Type": "application/json" } 
          },
        );
      }

      // リクエストボディの解析
      const body = await request.json();
      const { device_id, device_info, locations } = body;

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

      // デバイス情報をupsert
      const { data: deviceData, error: deviceError } = await supabase
        .from("devices")
        .upsert(
          {
            device_id,
            model: device_info?.model,
            os_version: device_info?.os_version,
          },
          { onConflict: "device_id" }
        )
        .select()
        .single();

      if (deviceError) {
        console.error("Device upsert error:", deviceError);
        return new Response(
          JSON.stringify({ error: "DATABASE_ERROR", message: "Failed to save device info" }),
          { 
            status: 500,
            headers: { "Content-Type": "application/json" } 
          },
        );
      }

      // 位置情報データの挿入準備
      const locationInserts = locations.map((location: any) => ({
        device_uuid: deviceData.id,
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

      return new Response(
        JSON.stringify({
          message: `Successfully recorded ${locations.length} locations`,
          received_count: locations.length,
        }),
        { 
          status: 201,
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