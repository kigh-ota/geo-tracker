// Geo Tracker API - Supabase Edge Function
// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { handleRequest } from "./routes.ts"

console.log("Geo Tracker API starting...")

Deno.serve(async (req: Request) => {
  // return await handleRequest(req)
    return new Response(
    JSON.stringify({
      headers: Object.fromEntries(req.headers),
    }, null, 2),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make HTTP requests:

  # Health check
  curl -i 'http://127.0.0.1:54321/functions/v1/api/health'

  # Location batch
  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/api/locations/batch' \
    --header 'Content-Type: application/json' \
    --data '{
      "device_id": "550e8400-e29b-41d4-a716-446655440000",
      "locations": [
        {
          "latitude": 35.6812,
          "longitude": 139.7671,
          "accuracy": 5.0,
          "timestamp": "2024-01-15T10:30:00Z"
        }
      ]
    }'

*/
