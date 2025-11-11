// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\routes\registerRoutes.js
import express from 'express';
import { 
  requestOTP,
  verifyOTPAndRegister,
  resendOTP
} from '../controllers/registerController.js';

const router = express.Router();

router.post('/request-otp', requestOTP);
router.post('/verify-otp', verifyOTPAndRegister);
router.post('/resend-otp', resendOTP);

export default router;