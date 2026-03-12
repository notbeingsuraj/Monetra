import { Request, Response, NextFunction } from 'express';
import User from '../models/User';

export const requirePhoneVerification = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userReq = req as any;
    if (!userReq.user || !userReq.user.id) {
      res.status(401).json({ success: false, message: 'Not authorized' });
      return;
    }

    const user = await User.findById(userReq.user.id);
    if (!user) {
      res.status(401).json({ success: false, message: 'User no longer exists' });
      return;
    }

    if (!user.isPhoneVerified) {
      res.status(403).json({
        success: false,
        message: 'Phone number must be verified to perform financial operations',
      });
      return;
    }

    next();
  } catch (error) {
    next(error);
  }
};
