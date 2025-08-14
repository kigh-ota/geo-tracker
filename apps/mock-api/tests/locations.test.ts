import request from 'supertest';
import { createApp } from '../src/app';
import { components } from '../src/types/api';

describe('POST /v1/locations/batch', () => {
  const app = createApp();

  const validLocationBatch: components['schemas']['LocationBatch'] = {
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

  it('should accept valid location batch and return 201', async () => {
    const response = await request(app)
      .post('/v1/locations/batch')
      .send(validLocationBatch)
      .expect(201);

    expect(response.body).toEqual({
      message: "Successfully recorded 1 locations",
      received_count: 1
    });
  });

  it('should accept multiple locations in batch', async () => {
    const multipleBatch = {
      ...validLocationBatch,
      locations: [
        ...validLocationBatch.locations,
        {
          latitude: 35.6813,
          longitude: 139.7672,
          accuracy: 10.0,
          timestamp: "2024-01-15T10:31:00Z"
        }
      ]
    };

    const response = await request(app)
      .post('/v1/locations/batch')
      .send(multipleBatch)
      .expect(201);

    expect(response.body).toEqual({
      message: "Successfully recorded 2 locations",
      received_count: 2
    });
  });

  it('should log received location data to console', async () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    
    await request(app)
      .post('/v1/locations/batch')
      .send(validLocationBatch)
      .expect(201);

    expect(consoleSpy).toHaveBeenCalledWith(
      expect.stringContaining('Device ID: 550e8400-e29b-41d4-a716-446655440000')
    );
    expect(consoleSpy).toHaveBeenCalledWith(
      expect.stringContaining('Locations received: 1')
    );
    
    consoleSpy.mockRestore();
  });
});