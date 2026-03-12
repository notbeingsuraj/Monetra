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
import { validate } from '../middleware/validate.middleware';
import { idempotency } from '../middleware/idempotency.middleware';
import { requirePhoneVerification } from '../middleware/verification.middleware';
import { createLoanSchema, repayLoanSchema } from '../schemas/validation';

const router = Router();

// All loan routes require authentication
router.use(protect);

router.get('/summary', getLoanSummary);
router.get('/', getLoans);
router.get('/:id', getLoan);
router.post('/', requirePhoneVerification, validate(createLoanSchema), idempotency, createLoan);
router.patch('/:id/repay', requirePhoneVerification, validate(repayLoanSchema), idempotency, markRepaid);
router.patch('/:id/default', markDefaulted);
router.delete('/:id', deleteLoan);

router.get('/requests/incoming', getIncomingRequests);
router.get('/requests/outgoing', getOutgoingRequests);
router.post('/requests/:id/accept', requirePhoneVerification, idempotency, acceptLoanRequest);
router.post('/requests/:id/reject', rejectLoanRequest);
router.post('/requests/:id/cancel', cancelLoanRequest);
router.post('/requests', requirePhoneVerification, validate(createLoanSchema), idempotency, createLoanRequest);

export default router;
