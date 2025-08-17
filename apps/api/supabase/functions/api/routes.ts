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
  
  return new Response(
    JSON.stringify({ error: "Not Found", message: "Endpoint not found" }),
    { 
      status: 404,
      headers: { "Content-Type": "application/json" } 
    },
  );
}