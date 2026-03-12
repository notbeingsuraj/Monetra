import mongoose from 'mongoose';
import Loan from '../models/Loan';
import User from '../models/User';

export class FraudDetectionService {
  /**
   * Checks if creating a loan or request violates velocity rules.
   * Throws an error if suspicious behavior is flagged.
   */
  static async checkLoanVelocity(lenderId: string, borrowerIdentifier: { id?: string | null, contact?: string }): Promise<void> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let matchQuery: any;

    if (borrowerIdentifier.id) {
      const bId = borrowerIdentifier.id;
      matchQuery = {
        $or: [
          { lenderId, borrowerId: bId },
          { lenderId: bId, borrowerId: lenderId }
        ],
        createdAt: { $gte: today }
      };
    } else if (borrowerIdentifier.contact) {
      matchQuery = {
        lenderId,
        borrowerContact: borrowerIdentifier.contact,
        createdAt: { $gte: today }
      };
    } else {
      return;
    }

    const loanCount = await Loan.countDocuments(matchQuery);

    if (loanCount >= 5) {
      const idsToFlag = [lenderId];
      if (borrowerIdentifier.id) idsToFlag.push(borrowerIdentifier.id);

      await User.updateMany(
        { _id: { $in: idsToFlag } },
        { $set: { isFlagged: true } }
      );
      
      console.warn(`[FraudDetection] Flagged user(s) for excessive loan velocity. Check lender: ${lenderId}`);
      throw new Error('Security policy triggered: Excessive loan requests detected between these parties today.');
    }
  }

  /**
   * Evaluates if the amount meets the minimum threshold to impact trust scores.
   */
  static isEligibleForTrustScore(amount: number, currency = 'INR'): boolean {
    const MINIMUM_THRESHOLDS: Record<string, number> = {
      'INR': 500,
      'USD': 10
    };
    const threshold = MINIMUM_THRESHOLDS[currency] || 0;
    return amount >= threshold;
  }
}
