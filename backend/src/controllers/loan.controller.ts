import { Request, Response, NextFunction } from 'express';
import Loan from '../models/Loan';
import Repayment from '../models/Repayment';
import { AuthRequest } from '../middleware/auth.middleware';
import { syncTrustScore } from '../services/trustScore.service';
import mongoose from 'mongoose';

// GET /api/loans
export const getLoans = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { status, page = '1', limit = '20' } = req.query as Record<string, string>;
    const userId = req.user!._id;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query: Record<string, unknown> = { lenderId: userId };
    if (status) query.status = status;

    const [loans, total] = await Promise.all([
      Loan.find(query).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
      Loan.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      data: loans,
      pagination: {
        total,
        page: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
      },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/loans/:id
export const getLoan = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOne({ _id: req.params.id, lenderId: req.user!._id });
    if (!loan) {
      res.status(404).json({ success: false, message: 'Loan not found' });
      return;
    }
    const repayments = await Repayment.find({ loanId: loan._id }).sort({ paidAt: -1 });
    res.status(200).json({ success: true, data: { loan, repayments } });
  } catch (err) {
    next(err);
  }
};

// POST /api/loans
export const createLoan = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { borrowerName, borrowerContact, amount, currency, dueDate, note } = req.body as {
      borrowerName: string;
      borrowerContact?: string;
      amount: number;
      currency?: string;
      dueDate: string;
      note?: string;
    };

    if (!borrowerName || !amount || !dueDate) {
      res.status(400).json({ success: false, message: 'borrowerName, amount, and dueDate are required' });
      return;
    }

    const loan = await Loan.create({
      lenderId: req.user!._id,
      borrowerName,
      borrowerContact,
      amount,
      currency: currency || 'INR',
      dueDate: new Date(dueDate),
      note,
    });

    res.status(201).json({ success: true, data: loan });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/loans/:id/repay
export const markRepaid = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOne({ _id: req.params.id, lenderId: req.user!._id });
    if (!loan) {
      res.status(404).json({ success: false, message: 'Loan not found' });
      return;
    }

    if (loan.status === 'repaid') {
      res.status(400).json({ success: false, message: 'Loan already marked as repaid' });
      return;
    }

    const now = new Date();
    const isLate = now > loan.dueDate;
    const lateDays = isLate ? Math.floor((now.getTime() - loan.dueDate.getTime()) / 86400000) : 0;

    loan.status = 'repaid';
    loan.repaidAt = now;
    loan.lateDays = lateDays;
    await loan.save();

    // Record repayment
    const { note } = req.body as { note?: string };
    await Repayment.create({
      loanId: loan._id,
      lenderId: req.user!._id,
      amountPaid: loan.amount,
      note,
      paidAt: now,
    });

    // Recalculate trust score
    const newScore = await syncTrustScore(req.user!._id);

    res.status(200).json({ success: true, data: loan, newTrustScore: newScore });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/loans/:id/default
export const markDefaulted = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOne({ _id: req.params.id, lenderId: req.user!._id });
    if (!loan) {
      res.status(404).json({ success: false, message: 'Loan not found' });
      return;
    }

    loan.status = 'defaulted';
    await loan.save();

    const newScore = await syncTrustScore(req.user!._id);

    res.status(200).json({ success: true, data: loan, newTrustScore: newScore });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/loans/:id
export const deleteLoan = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOneAndDelete({ _id: req.params.id, lenderId: req.user!._id });
    if (!loan) {
      res.status(404).json({ success: false, message: 'Loan not found' });
      return;
    }
    res.status(200).json({ success: true, message: 'Loan deleted' });
  } catch (err) {
    next(err);
  }
};

// GET /api/loans/summary
export const getLoanSummary = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!._id;

    const [pending, repaid, overdue, defaulted, totalLent] = await Promise.all([
      Loan.countDocuments({ lenderId: userId, status: 'pending' }),
      Loan.countDocuments({ lenderId: userId, status: 'repaid' }),
      Loan.countDocuments({ lenderId: userId, status: 'overdue' }),
      Loan.countDocuments({ lenderId: userId, status: 'defaulted' }),
      Loan.aggregate([
        { $match: { lenderId: new mongoose.Types.ObjectId(userId.toString()) } },
        { $group: { _id: null, total: { $sum: '$amount' } } },
      ]),
    ]);

    res.status(200).json({
      success: true,
      data: {
        pending,
        repaid,
        overdue,
        defaulted,
        totalLent: totalLent[0]?.total || 0,
      },
    });
  } catch (err) {
    next(err);
  }
};
