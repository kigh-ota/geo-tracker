import { createApp } from './app';

const app = createApp();
const port = process.env.PORT || 8000;

app.listen(port, () => {
  console.log(`Mock API server is running on port ${port}`);
  console.log(`Health check: http://localhost:${port}/v1/health`);
});