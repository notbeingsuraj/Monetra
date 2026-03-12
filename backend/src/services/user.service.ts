import User from '../models/User';
import { calculateTrustScore, syncTrustScore } from './trustScore.service';

export class UserService {
  static async getTrustScore(userId: string) {
    return calculateTrustScore(userId);
  }

  static async syncTrustScore(userId: string) {
    return syncTrustScore(userId);
  }

  static async updateProfile(userId: string, data: { name?: string; profilePicture?: string }) {
    const allowedUpdates: Record<string, unknown> = {};
    if (data.name) allowedUpdates.name = data.name;
    if (data.profilePicture) allowedUpdates.profilePicture = data.profilePicture;

    return User.findByIdAndUpdate(userId, allowedUpdates, {
      new: true,
      runValidators: true,
    });
  }
}
