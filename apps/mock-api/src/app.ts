import express from 'express';
import { operations } from './types/api';

export function createApp(): express.Application {
  const app = express();
  
  app.use(express.json());
  
  // Health check endpoint
  app.get('/v1/health', (req, res) => {
    const response: operations['getHealth']['responses']['200']['content']['application/json'] = {
      status: 'healthy',
      timestamp: new Date().toISOString()
    };
    
    res.status(200).json(response);
  });
  
  return app;
}