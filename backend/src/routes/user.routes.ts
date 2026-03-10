import { Router } from 'express';
import { getTrustScore, syncUserTrustScore, updateProfile } from '../controllers/user.controller';
import { protect } from '../middleware/auth.middleware';

const router = Router();

router.use(protect);

router.get('/me/score', getTrustScore);
router.post('/me/score/sync', syncUserTrustScore);
router.patch('/me', updateProfile);

export default router;
