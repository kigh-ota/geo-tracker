import request from 'supertest';
import { createApp } from '../src/app';

describe('POST /v1/locations/batch - Validation', () => {
  const app = createApp();

  it('should return 400 for missing required fields', async () => {
    const invalidPayload = {
      device_id: "550e8400-e29b-41d4-a716-446655440000"
      // missing locations array
    };

    const response = await request(app)
      .post('/v1/locations/batch')
      .send(invalidPayload)
      .expect(400);

    expect(response.body).toEqual({
      error: 'INVALID_REQUEST',
      message: expect.stringContaining('locations'),
      details: expect.any(Object)
    });
  });

  it('should return 400 for invalid latitude values', async () => {
    const invalidPayload = {
      device_id: "550e8400-e29b-41d4-a716-446655440000",
      locations: [
        {
          latitude: 91.0, // invalid: > 90
          longitude: 139.7671,
          timestamp: "2024-01-15T10:30:00Z"
        }
      ]
    };

    const response = await request(app)
      .post('/v1/locations/batch')
      .send(invalidPayload)
      .expect(400);

    expect(response.body).toEqual({
      error: 'INVALID_REQUEST',
      message: 'Invalid latitude value',
      details: expect.any(Object)
    });
  });

  it('should return 400 for invalid longitude values', async () => {
    const invalidPayload = {
      device_id: "550e8400-e29b-41d4-a716-446655440000",
      locations: [
        {
          latitude: 35.6812,
          longitude: 181.0, // invalid: > 180
          timestamp: "2024-01-15T10:30:00Z"
        }
      ]
    };

    const response = await request(app)
      .post('/v1/locations/batch')
      .send(invalidPayload)
      .expect(400);

    expect(response.body).toEqual({
      error: 'INVALID_REQUEST',
      message: 'Invalid longitude value',
      details: expect.any(Object)
    });
  });

  it('should return 400 for empty locations array', async () => {
    const invalidPayload = {
      device_id: "550e8400-e29b-41d4-a716-446655440000",
      locations: [] // empty array
    };

    const response = await request(app)
      .post('/v1/locations/batch')
      .send(invalidPayload)
      .expect(400);

    expect(response.body).toEqual({
      error: 'INVALID_REQUEST',
      message: 'At least one location is required',
      details: expect.any(Object)
    });
  });

  it('should return 400 for invalid JSON', async () => {
    const response = await request(app)
      .post('/v1/locations/batch')
      .set('Content-Type', 'application/json')
      .send('invalid json')
      .expect(400);

    expect(response.body).toEqual({
      error: 'INVALID_REQUEST',
      message: expect.stringContaining('JSON'),
      details: expect.any(Object)
    });
  });
});