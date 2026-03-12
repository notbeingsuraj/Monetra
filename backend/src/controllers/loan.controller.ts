import { Request, Response, NextFunction } from 'express';
import Loan from '../models/Loan';
import Repayment from '../models/Repayment';
import User from '../models/User';
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

// POST /api/loans/requests
export const createLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { borrowerContact, amount, interest, currency, dueDate, note } = req.body as {
      borrowerContact: string;
      amount: number;
      interest?: number;
      currency?: string;
      dueDate: string;
      note?: string;
    };

    if (!borrowerContact || !amount || !dueDate) {
      res.status(400).json({ success: false, message: 'borrowerContact, amount, and dueDate are required' });
      return;
    }

    const lenderId = req.user!._id;

    // Resolve borrower identity
    const borrower = await User.findOne({ phone: borrowerContact });
    if (!borrower) {
      res.status(404).json({ success: false, message: 'User with this phone number not found. Ensure they have signed up for Monetra.' });
      return;
    }

    if (borrower._id.toString() === lenderId.toString()) {
      res.status(400).json({ success: false, message: 'You cannot send a loan request to yourself' });
      return;
    }

    // Check for duplicate pending requests (prevents spamming requests)
    const existingPending = await Loan.findOne({
      lenderId,
      borrowerId: borrower._id,
      status: 'pending'
    });
    
    if (existingPending) {
      res.status(400).json({ success: false, message: 'You already have a pending request with this user' });
      return;
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days from now

    const loan = await Loan.create({
      lenderId,
      borrowerName: borrower.name,
      borrowerContact,
      borrowerId: borrower._id,
      amount,
      interest: interest || 0,
      currency: currency || 'INR',
      dueDate: new Date(dueDate),
      note,
      status: 'pending',
      expiresAt,
    });

    // TODO: Send push notification to borrower here

    res.status(201).json({ success: true, data: loan });
  } catch (err) {
    next(err);
  }
};

// GET /api/loans/requests/incoming
export const getIncomingRequests = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loans = await Loan.find({ 
      borrowerId: req.user!._id, 
      status: 'pending' 
    }).sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: loans });
  } catch (err) {
    next(err);
  }
};

// GET /api/loans/requests/outgoing
export const getOutgoingRequests = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loans = await Loan.find({ 
      lenderId: req.user!._id, 
      status: 'pending' 
    }).sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: loans });
  } catch (err) {
    next(err);
  }
};

// POST /api/loans/requests/:id/accept
export const acceptLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOne({ 
      _id: req.params.id, 
      borrowerId: req.user!._id,
      status: 'pending'
    });

    if (!loan) {
      res.status(404).json({ success: false, message: 'Pending loan request not found' });
      return;
    }

    if (loan.expiresAt && new Date() > loan.expiresAt) {
      loan.status = 'expired';
      await loan.save();
      res.status(400).json({ success: false, message: 'This loan request has expired' });
      return;
    }

    loan.status = 'active';
    await loan.save();

    // Trust score impact for accepting loan
    const user = await User.findById(req.user!._id);
    if (user) {
      user.trustScore = Math.min(100, (user.trustScore || 50) + 1);
      await user.save();
    }

    // TODO: Send push notification to lender here

    res.status(200).json({ success: true, data: loan });
  } catch (err) {
    next(err);
  }
};

// POST /api/loans/requests/:id/reject
export const rejectLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOne({ 
      _id: req.params.id, 
      borrowerId: req.user!._id,
      status: 'pending'
    });

    if (!loan) {
      res.status(404).json({ success: false, message: 'Pending loan request not found' });
      return;
    }

    loan.status = 'rejected';
    await loan.save();
    
    // TODO: Send push notification to lender

    res.status(200).json({ success: true, data: loan });
  } catch (err) {
    next(err);
  }
};

// POST /api/loans/requests/:id/cancel
export const cancelLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await Loan.findOne({ 
      _id: req.params.id, 
      lenderId: req.user!._id,
      status: 'pending'
    });

    if (!loan) {
      res.status(404).json({ success: false, message: 'Pending loan request not found' });
      return;
    }

    loan.status = 'cancelled';
    await loan.save();

    res.status(200).json({ success: true, data: loan });
  } catch (err) {
    next(err);
  }
};
