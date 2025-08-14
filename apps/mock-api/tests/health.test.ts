import request from 'supertest';
import { createApp } from '../src/app';

describe('GET /v1/health', () => {
  const app = createApp();

  it('should return 200 status with healthy response', async () => {
    const response = await request(app)
      .get('/v1/health')
      .expect(200);

    expect(response.body).toEqual({
      status: 'healthy',
      timestamp: expect.any(String)
    });
    
    expect(new Date(response.body.timestamp).toISOString()).toBe(response.body.timestamp);
  });

  it('should return response without requiring authentication', async () => {
    await request(app)
      .get('/v1/health')
      .expect(200);
  });
});