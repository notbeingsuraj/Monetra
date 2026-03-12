import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { LoanService } from '../services/loan.service';

export const getLoans = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { status, page = '1', limit = '20' } = req.query as Record<string, string>;
    const userId = req.user!._id.toString();
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // We don't want to pass status to the service directly from req.query since it relies on explicit handling
    const query = status ? { status } : {};

    const { loans, total } = await LoanService.getLoans(userId, query, skip, parseInt(limit));

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

export const getLoan = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await LoanService.getLoanDetails(req.user!._id.toString(), req.params.id as string);
    res.status(200).json({ success: true, data });
  } catch (err: any) {
    if (err.message === 'Loan not found') {
      res.status(404).json({ success: false, message: err.message });
      return;
    }
    next(err);
  }
};

export const createLoan = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { borrowerName, borrowerContact, amount, currency, dueDate, note } = req.body;
    if (!borrowerName || !amount || !dueDate) {
      res.status(400).json({ success: false, message: 'borrowerName, amount, and dueDate are required' });
      return;
    }

    const loan = await LoanService.createLoan(req.user!._id.toString(), {
      borrowerName, borrowerContact, amount, currency, dueDate, note
    });

    res.status(201).json({ success: true, data: loan });
  } catch (err) {
    next(err);
  }
};

export const markRepaid = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { loan, newScore } = await LoanService.markRepaid(req.user!._id.toString(), req.params.id as string, req.body.note);
    res.status(200).json({ success: true, data: loan, newTrustScore: newScore });
  } catch (err: any) {
    if (err.message === 'Loan not found') res.status(404).json({ success: false, message: err.message });
    else if (err.message === 'Loan already marked as repaid') res.status(400).json({ success: false, message: err.message });
    else next(err);
  }
};

export const markDefaulted = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { loan, newScore } = await LoanService.markDefaulted(req.user!._id.toString(), req.params.id as string);
    res.status(200).json({ success: true, data: loan, newTrustScore: newScore });
  } catch (err: any) {
    if (err.message === 'Loan not found') res.status(404).json({ success: false, message: err.message });
    else next(err);
  }
};

export const deleteLoan = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    await LoanService.deleteLoan(req.user!._id.toString(), req.params.id as string);
    res.status(200).json({ success: true, message: 'Loan deleted' });
  } catch (err: any) {
    if (err.message === 'Loan not found') res.status(404).json({ success: false, message: err.message });
    else next(err);
  }
};

export const getLoanSummary = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const summary = await LoanService.getSummary(req.user!._id.toString());
    res.status(200).json({ success: true, data: summary });
  } catch (err) {
    next(err);
  }
};

export const createLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { borrowerContact, amount, interest, currency, dueDate, note } = req.body;
    if (!borrowerContact || !amount || !dueDate) {
      res.status(400).json({ success: false, message: 'borrowerContact, amount, and dueDate are required' });
      return;
    }

    const data = await LoanService.createRequest(req.user!._id.toString(), {
      borrowerContact, amount, interest, currency, dueDate, note
    });

    if (data.inviteToken) {
      res.status(201).json({ 
        success: true, 
        message: 'User not found. Invite generated and pending loan created.',
        data: data.loan,
        inviteToken: data.inviteToken 
      });
      return;
    }

    res.status(201).json({ success: true, data: data.loan });
  } catch (err: any) {
    if (err.message === 'You cannot send a loan request to yourself' || err.message === 'You already have a pending request with this user') {
      res.status(400).json({ success: false, message: err.message });
    } else {
      next(err);
    }
  }
};

export const getIncomingRequests = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await LoanService.getIncomingRequests(req.user!._id.toString());
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
};

export const getOutgoingRequests = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await LoanService.getOutgoingRequests(req.user!._id.toString());
    res.status(200).json({ success: true, data });
  } catch (err) {
    next(err);
  }
};

export const acceptLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await LoanService.acceptRequest(req.user!._id.toString(), req.params.id as string);
    res.status(200).json({ success: true, data: loan });
  } catch (err: any) {
    if (err.message.includes('not found')) res.status(404).json({ success: false, message: err.message });
    else if (err.message.includes('expired')) res.status(400).json({ success: false, message: err.message });
    else next(err);
  }
};

export const rejectLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await LoanService.rejectRequest(req.user!._id.toString(), req.params.id as string);
    res.status(200).json({ success: true, data: loan });
  } catch (err: any) {
    if (err.message.includes('not found')) res.status(404).json({ success: false, message: err.message });
    else next(err);
  }
};

export const cancelLoanRequest = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const loan = await LoanService.cancelRequest(req.user!._id.toString(), req.params.id as string);
    res.status(200).json({ success: true, data: loan });
  } catch (err: any) {
    if (err.message.includes('not found')) res.status(404).json({ success: false, message: err.message });
    else next(err);
  }
};
