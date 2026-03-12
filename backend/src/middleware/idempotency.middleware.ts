import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth.middleware';
import IdempotencyCache from '../models/IdempotencyCache';

export const idempotency = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  const idempotencyKey = req.headers['idempotency-key'] as string;

  if (!idempotencyKey) {
    // If client doesn't provide a key, just process normally (or we can enforce it)
    // For a strict fintech app, we should enforce it on specific routes.
    res.status(400).json({ success: false, message: 'Idempotency-Key header is required for this operation' });
    return;
  }

  const userId = req.user!._id;

  try {
    // Check if we already processed this exact key for this user
    const existingCache = await IdempotencyCache.findOne({ key: idempotencyKey, userId });
    
    if (existingCache) {
      res.status(existingCache.responseStatus).json(JSON.parse(existingCache.responseBody));
      return;
    }

    // Capture the original response via res.json override
    const originalJson = res.json.bind(res);
    
    res.json = (body: any): Response => {
      // Save it asynchronously so we don't block the response.
      // We only save successful responses (2xx) or specific controlled errors.
      if (res.statusCode >= 200 && res.statusCode < 300) {
        IdempotencyCache.create({
          key: idempotencyKey,
          userId,
          requestPath: req.originalUrl,
          responseBody: JSON.stringify(body),
          responseStatus: res.statusCode
        }).catch(err => {
          console.error('Failed to save idempotency cache:', err);
        });
      }
      
      return originalJson(body);
    };

    next();
  } catch (err) {
    next(err);
  }
};
