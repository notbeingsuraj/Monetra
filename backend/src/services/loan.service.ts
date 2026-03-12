import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';
import Loan from '../models/Loan';
import Repayment from '../models/Repayment';
import User from '../models/User';
import Invite from '../models/Invite';
import { syncTrustScore } from './trustScore.service';
import { FraudDetectionService } from './fraudDetection.service';

export class LoanService {
  static async getLoans(userId: string, query: Record<string, unknown>, skip: number, limit: number) {
    const q: Record<string, unknown> = { lenderId: userId, ...query };
    const [loans, total] = await Promise.all([
      Loan.find(q).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Loan.countDocuments(q),
    ]);
    return { loans, total };
  }

  static async getLoanDetails(userId: string, loanId: string) {
    const loan = await Loan.findOne({ _id: loanId, lenderId: userId });
    if (!loan) throw new Error('Loan not found');
    const repayments = await Repayment.find({ loanId: loan._id }).sort({ paidAt: -1 });
    return { loan, repayments };
  }

  static async createLoan(lenderId: string, data: any) {
    if (data.borrowerContact) {
      await FraudDetectionService.checkLoanVelocity(lenderId, { contact: data.borrowerContact });
    }
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const [loan] = await Loan.create([{
        lenderId,
        ...data,
        currency: data.currency || 'INR',
      }], { session });
      
      await session.commitTransaction();
      return loan;
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  static async markRepaid(userId: string, loanId: string, note?: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const loan = await Loan.findOne({ _id: loanId, lenderId: userId }).session(session);
      if (!loan) throw new Error('Loan not found');
      if (loan.status === 'repaid') throw new Error('Loan already marked as repaid');

      const now = new Date();
      const isLate = now > loan.dueDate;
      loan.status = 'repaid';
      loan.repaidAt = now;
      loan.lateDays = isLate ? Math.floor((now.getTime() - loan.dueDate.getTime()) / 86400000) : 0;
      
      await loan.save({ session });
      
      await Repayment.create([{
        loanId: loan._id,
        lenderId: userId,
        amountPaid: loan.amount,
        note,
        paidAt: now,
      }], { session });

      const newScore = await syncTrustScore(userId, session);
      await session.commitTransaction();
      return { loan, newScore };
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  static async markDefaulted(userId: string, loanId: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const loan = await Loan.findOne({ _id: loanId, lenderId: userId }).session(session);
      if (!loan) throw new Error('Loan not found');

      loan.status = 'defaulted';
      await loan.save({ session });

      const newScore = await syncTrustScore(userId, session);
      await session.commitTransaction();
      return { loan, newScore };
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  static async deleteLoan(userId: string, loanId: string) {
    const loan = await Loan.findOneAndDelete({ _id: loanId, lenderId: userId });
    if (!loan) throw new Error('Loan not found');
  }

  static async getSummary(userId: string) {
    const [pending, repaid, overdue, defaulted, totalLent] = await Promise.all([
      Loan.countDocuments({ lenderId: userId, status: 'pending' }),
      Loan.countDocuments({ lenderId: userId, status: 'repaid' }),
      Loan.countDocuments({ lenderId: userId, status: 'overdue' }),
      Loan.countDocuments({ lenderId: userId, status: 'defaulted' }),
      Loan.aggregate([
        { $match: { lenderId: new mongoose.Types.ObjectId(userId) } },
        { $group: { _id: null, total: { $sum: '$amount' } } },
      ]),
    ]);

    return {
      pending,
      repaid,
      overdue,
      defaulted,
      totalLent: totalLent[0]?.total || 0,
    };
  }

  static async createRequest(lenderId: string, data: any) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const borrower = await User.findOne({ phone: data.borrowerContact }).session(session);
      
      let borrowerId = borrower?._id || null;
      let borrowerName = borrower?.name || data.borrowerContact;

      if (borrowerId?.toString() === lenderId) {
        throw new Error('You cannot send a loan request to yourself');
      }

      if (borrowerId) {
        const existing = await Loan.findOne({ lenderId, borrowerId, status: 'pending' }).session(session);
        if (existing) throw new Error('You already have a pending request with this user');
      }

      await FraudDetectionService.checkLoanVelocity(lenderId, {
        id: borrowerId?.toString(),
        contact: data.borrowerContact
      });

      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7);

      const [loan] = await Loan.create([{
        lenderId,
        borrowerName,
        borrowerContact: data.borrowerContact,
        ...(borrowerId ? { borrowerId } : {}),
        amount: data.amount,
        interest: data.interest || 0,
        currency: data.currency || 'INR',
        dueDate: new Date(data.dueDate),
        note: data.note,
        status: 'pending',
        expiresAt,
      }], { session });

      if (!borrower) {
        const inviteToken = uuidv4();
        await Invite.create([{
          token: inviteToken,
          phone: data.borrowerContact,
          lenderId,
          loanId: loan._id,
          expiresAt,
        }], { session });
        await session.commitTransaction();
        return { loan, inviteToken };
      }

      await session.commitTransaction();
      return { loan };
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  static async getIncomingRequests(borrowerId: string) {
    return Loan.find({ borrowerId, status: 'pending' }).sort({ createdAt: -1 });
  }

  static async getOutgoingRequests(lenderId: string) {
    return Loan.find({ lenderId, status: 'pending' }).sort({ createdAt: -1 });
  }

  static async acceptRequest(borrowerId: string, loanId: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const loan = await Loan.findOne({ _id: loanId, borrowerId, status: 'pending' }).session(session);
      if (!loan) throw new Error('Pending loan request not found');

      if (loan.expiresAt && new Date() > loan.expiresAt) {
        loan.status = 'expired';
        await loan.save({ session });
        throw new Error('This loan request has expired');
      }

      loan.status = 'active';
      await loan.save({ session });

      const user = await User.findById(borrowerId).session(session);
      if (user) {
        await syncTrustScore(borrowerId, session);
      }

      await session.commitTransaction();
      return loan;
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  static async rejectRequest(borrowerId: string, loanId: string) {
    const loan = await Loan.findOne({ _id: loanId, borrowerId, status: 'pending' });
    if (!loan) throw new Error('Pending loan request not found');

    loan.status = 'rejected';
    await loan.save();
    return loan;
  }

  static async cancelRequest(lenderId: string, loanId: string) {
    const loan = await Loan.findOne({ _id: loanId, lenderId, status: 'pending' });
    if (!loan) throw new Error('Pending loan request not found');

    loan.status = 'cancelled';
    await loan.save();
    return loan;
  }
}
