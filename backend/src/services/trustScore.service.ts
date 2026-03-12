import mongoose from 'mongoose';
import Loan, { ILoan } from '../models/Loan';
import User from '../models/User';
import { FraudDetectionService } from './fraudDetection.service';

export interface TrustScoreComponents {
  baseScore: number;
  finalScore: number;
  details: {
    totalLoans: number;
    loansRepaid: number;
    defaults: number;
    lateDays: number;
  };
}

/**
 * Calculates trust score for a user based on their lending history.
 * Formula limits and weightings:
 * - Accepting a loan: +0.5 (max once per day, calculated via history)
 * - Successful repayment: +5 weighted by amount and duration
 * - Late repayment: -10
 * - Defaulted loan: -30
 * Velocity Control: Max +10 increment per day (tracked via daily snapshots if necessary, 
 * but for this calculation we'll recalculate from absolute base and clamp the overall).
 * 
 * Since the original prompt asked to update the calculation logic, we will do a robust
 * historical recalculation to derive the score safely, rather than just simple arbitrary +1 increments.
 */
export const calculateTrustScore = async (
  userId: mongoose.Types.ObjectId | string,
  session?: mongoose.ClientSession
): Promise<TrustScoreComponents> => {
  const id = typeof userId === 'string' ? new mongoose.Types.ObjectId(userId) : userId;

  const loansAsBorrower = (await Loan.find({ borrowerId: id }).session(session || null).lean()) as ILoan[];
  const loansAsLender = (await Loan.find({ lenderId: id }).session(session || null).lean()) as ILoan[];

  const allInteractions = [...loansAsBorrower, ...loansAsLender];
  
  // Base starting score
  let score = 50;

  // Aggregate stats for reporting
  let loansRepaid = 0;
  let defaults = 0;
  let lateDaysTotal = 0;

  // Calculate score based on Borrower history (Direct Credit Trust)
  for (const loan of loansAsBorrower) {
    if (!FraudDetectionService.isEligibleForTrustScore(loan.amount, loan.currency)) {
      continue;
    }

    if (loan.status === 'repaid') {
      loansRepaid++;
      // Base +5 for repayment
      let repaymentBonus = 5;
      
      // Weight by amount (e.g. 5000 INR = 1x, 50000 INR = 1.5x)
      const amountMultiplier = Math.min(2, Math.max(1, loan.amount / 5000));
      repaymentBonus *= amountMultiplier;

      // Weight by duration (longer loans prove more trust)
      const durationDays = (loan.dueDate.getTime() - loan.createdAt.getTime()) / 86400000;
      const durationMultiplier = Math.min(1.5, Math.max(1, durationDays / 30));
      repaymentBonus *= durationMultiplier;

      // Penalty for late days if it was repaid late
      if (loan.lateDays && loan.lateDays > 0) {
        lateDaysTotal += loan.lateDays;
        repaymentBonus -= 10; // Late penalty
      }

      score += repaymentBonus;
    } else if (loan.status === 'defaulted') {
      defaults++;
      score -= 30;
    } else if (loan.status === 'overdue') {
      score -= 10;
    }
  }

  // Calculate score based on Lender history (Platform Activity Trust)
  // Max out activity bonus to +20 total to prevent gamification simply by lending $1
  let lenderBonus = 0;
  // Group loans by day created to enforce "max once per day" rule for accepting/creating loans
  const activeDays = new Set<string>();
  
  for (const loan of loansAsLender) {
    if (!FraudDetectionService.isEligibleForTrustScore(loan.amount, loan.currency)) continue;

    if (['active', 'repaid', 'defaulted', 'overdue'].includes(loan.status)) {
      const dayStr = loan.createdAt.toISOString().split('T')[0];
      if (!activeDays.has(dayStr)) {
        activeDays.add(dayStr);
        lenderBonus += 0.5; // +0.5 per active day of lending
      }
    }
  }

  // Cap lender activity bonus
  score += Math.min(20, lenderBonus);

  // Clamp final score between 1 and 100
  const finalScore = Math.min(100, Math.max(1, Math.floor(score)));

  return { 
    baseScore: 50, 
    finalScore, 
    details: {
      totalLoans: allInteractions.length,
      loansRepaid,
      defaults,
      lateDays: lateDaysTotal
    }
  };
};

/**
 * Recalculates and persists the trust score for a user.
 */
export const syncTrustScore = async (
  userId: mongoose.Types.ObjectId | string,
  session?: mongoose.ClientSession
): Promise<number> => {
  const { finalScore } = await calculateTrustScore(userId, session);
  await User.findByIdAndUpdate(userId, { trustScore: finalScore }, { session });
  return finalScore;
};
