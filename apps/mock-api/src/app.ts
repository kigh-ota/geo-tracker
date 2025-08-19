import express from 'express';
import { operations, components } from './types/api';
import { validateLocationBatch } from './middleware/validation';

export function createApp(): express.Application {
  const app = express();
  
  app.use(express.json());
  
  // Error handler for malformed JSON
  app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    if (err instanceof SyntaxError && 'body' in err) {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Invalid JSON format',
        details: { error: err.message }
      });
    }
    next(err);
  });
  
  // Health check endpoint
  app.get('/v1/health', (req, res) => {
    const response: operations['getHealth']['responses']['200']['content']['application/json'] = {
      status: 'healthy',
      timestamp: new Date().toISOString()
    };
    
    res.status(200).json(response);
  });
  
  // Location batch endpoint
  app.post('/v1/locations/batch', validateLocationBatch, (req, res) => {
    const locationBatch: components['schemas']['LocationBatch'] = req.body;
    const locationsCount = locationBatch.locations.length;
    
    // Log received data to console (as specified in requirements)
    console.log(`\n[${new Date().toISOString()}] POST /v1/locations/batch`);
    console.log(`Device ID: ${locationBatch.device_id}`);
    console.log(`Locations received: ${locationsCount}`);
    
    locationBatch.locations.forEach((location, index) => {
      console.log(`- Location ${index + 1}: lat=${location.latitude}, lng=${location.longitude}, accuracy=${location.accuracy}m, timestamp=${location.timestamp}`);
    });
    
    if (locationBatch.device_info) {
      console.log(`Device info: ${locationBatch.device_info.model} (${locationBatch.device_info.os_version})`);
    }
    
    const response: operations['postLocationsBatch']['responses']['200']['content']['application/json'] = {
      message: `Successfully recorded ${locationsCount} locations`,
      received_count: locationsCount
    };
    
    res.status(200).json(response);
  });
  
  return app;
}