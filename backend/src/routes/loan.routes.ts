import { Router } from 'express';
import {
  getLoans,
  getLoan,
  createLoan,
  markRepaid,
  markDefaulted,
  deleteLoan,
  getLoanSummary,
  createLoanRequest,
  getIncomingRequests,
  getOutgoingRequests,
  acceptLoanRequest,
  rejectLoanRequest,
  cancelLoanRequest
} from '../controllers/loan.controller';
import { protect } from '../middleware/auth.middleware';

const router = Router();

// All loan routes require authentication
router.use(protect);

router.get('/summary', getLoanSummary);
router.get('/', getLoans);
router.get('/:id', getLoan);
router.post('/', createLoan);
router.patch('/:id/repay', markRepaid);
router.patch('/:id/default', markDefaulted);
router.delete('/:id', deleteLoan);

router.get('/requests/incoming', getIncomingRequests);
router.get('/requests/outgoing', getOutgoingRequests);
router.post('/requests/:id/accept', acceptLoanRequest);
router.post('/requests/:id/reject', rejectLoanRequest);
router.post('/requests/:id/cancel', cancelLoanRequest);
router.post('/requests', createLoanRequest);

export default router;
