import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import User from '../models/User';
import { calculateTrustScore, syncTrustScore } from '../services/trustScore.service';

// GET /api/users/me/score
export const getTrustScore = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!._id;
    const scoreData = await calculateTrustScore(userId);

    res.status(200).json({ success: true, data: scoreData });
  } catch (err) {
    next(err);
  }
};

// POST /api/users/me/score/sync
export const syncUserTrustScore = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!._id;
    const finalScore = await syncTrustScore(userId);

    res.status(200).json({ success: true, trustScore: finalScore });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/users/me
export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!._id;
    const { name, profilePicture } = req.body as { name?: string; profilePicture?: string };

    const allowedUpdates: Record<string, unknown> = {};
    if (name) allowedUpdates.name = name;
    if (profilePicture) allowedUpdates.profilePicture = profilePicture;

    const user = await User.findByIdAndUpdate(userId, allowedUpdates, {
      new: true,
      runValidators: true,
    });

    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};
