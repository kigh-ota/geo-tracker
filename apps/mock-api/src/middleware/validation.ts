import express from 'express';

export function validateLocationBatch(req: express.Request, res: express.Response, next: express.NextFunction) {
  const body = req.body;
  
  // Check if locations array exists and is not empty
  if (!body.locations || !Array.isArray(body.locations)) {
    return res.status(400).json({
      error: 'INVALID_REQUEST',
      message: 'locations field is required and must be an array',
      details: { field: 'locations', type: 'array' }
    });
  }
  
  if (body.locations.length === 0) {
    return res.status(400).json({
      error: 'INVALID_REQUEST',
      message: 'At least one location is required',
      details: { field: 'locations', minItems: 1 }
    });
  }
  
  // Check required device_id
  if (!body.device_id) {
    return res.status(400).json({
      error: 'INVALID_REQUEST',
      message: 'device_id field is required',
      details: { field: 'device_id', type: 'string' }
    });
  }
  
  // Validate each location
  for (let i = 0; i < body.locations.length; i++) {
    const location = body.locations[i];
    
    // Check required fields
    if (typeof location.latitude !== 'number') {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'latitude is required and must be a number',
        details: { field: `locations[${i}].latitude`, type: 'number' }
      });
    }
    
    if (typeof location.longitude !== 'number') {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'longitude is required and must be a number',
        details: { field: `locations[${i}].longitude`, type: 'number' }
      });
    }
    
    if (!location.timestamp) {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'timestamp is required',
        details: { field: `locations[${i}].timestamp`, type: 'string' }
      });
    }
    
    // Validate latitude range (-90 to 90)
    if (location.latitude < -90 || location.latitude > 90) {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Invalid latitude value',
        details: { field: `locations[${i}].latitude`, min: -90, max: 90, actual: location.latitude }
      });
    }
    
    // Validate longitude range (-180 to 180)
    if (location.longitude < -180 || location.longitude > 180) {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Invalid longitude value',
        details: { field: `locations[${i}].longitude`, min: -180, max: 180, actual: location.longitude }
      });
    }
  }
  
  next();
}