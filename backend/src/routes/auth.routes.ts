import { Router } from 'express';
import { register, login, getMe, refreshAuth, logout, sendOtp, verifyOtp } from '../controllers/auth.controller';
import { protect } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import { registerSchema, loginSchema, refreshSchema, verifyOtpSchema } from '../schemas/validation';

const router = Router();

router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);
router.post('/refresh', validate(refreshSchema), refreshAuth);
router.post('/logout', logout);
router.post('/send-otp', protect, sendOtp);
router.post('/verify-otp', protect, validate(verifyOtpSchema), verifyOtp);
router.get('/me', protect, getMe);

export default router;
