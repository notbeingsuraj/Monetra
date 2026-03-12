import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { UserService } from '../services/user.service';

export const getTrustScore = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const scoreData = await UserService.getTrustScore(req.user!._id.toString());
    res.status(200).json({ success: true, data: scoreData });
  } catch (err) {
    next(err);
  }
};

export const syncUserTrustScore = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const finalScore = await UserService.syncTrustScore(req.user!._id.toString());
    res.status(200).json({ success: true, trustScore: finalScore });
  } catch (err) {
    next(err);
  }
};

export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { name, profilePicture } = req.body;
    const user = await UserService.updateProfile(req.user!._id.toString(), { name, profilePicture });
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};
