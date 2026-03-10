import Loan, { ILoan } from '../models/Loan';
import User from '../models/User';
import mongoose from 'mongoose';

interface TrustScoreComponents {
  baseScore: number;
  loansRepaid: number;
  defaults: number;
  lateDays: number;
  finalScore: number;
}

/**
 * Calculates trust score for a user based on their lending history.
 * Formula:
 *   score = 50 + (5 × loans_repaid) − (10 × defaults) − (1 × late_days)
 *   Clamped to [0, 100]
 */
export const calculateTrustScore = async (
  userId: mongoose.Types.ObjectId | string
): Promise<TrustScoreComponents> => {
  const id = typeof userId === 'string' ? new mongoose.Types.ObjectId(userId) : userId;

  const loans = await Loan.find({ lenderId: id }).lean();

  const loansRepaid = loans.filter((l: ILoan) => l.status === 'repaid').length;
  const defaults = loans.filter((l: ILoan) => l.status === 'defaulted').length;
  const lateDays = loans.reduce((sum: number, l: ILoan) => sum + (l.lateDays || 0), 0);

  const baseScore = 50;
  const rawScore = baseScore + 5 * loansRepaid - 10 * defaults - lateDays;
  const finalScore = Math.min(100, Math.max(0, rawScore));

  return { baseScore, loansRepaid, defaults, lateDays, finalScore };
};

/**
 * Recalculates and persists the trust score for a user.
 */
export const syncTrustScore = async (
  userId: mongoose.Types.ObjectId | string
): Promise<number> => {
  const { finalScore } = await calculateTrustScore(userId);
  await User.findByIdAndUpdate(userId, { trustScore: finalScore });
  return finalScore;
};
