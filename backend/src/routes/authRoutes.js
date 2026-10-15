import express from 'express';
import {
  customerRequestOtp,
  customerVerifyOtp,
  driverLogin,
  driverVerifyOtp,
  driverUploadDocuments,
  socialSignIn
} from '../controllers/authController.js';

const router = express.Router();

// Customer Auth
router.post('/customer/request-otp', customerRequestOtp);
router.post('/customer/verify-otp', customerVerifyOtp);

// Driver Auth
router.post('/driver/login', driverLogin);
router.post('/driver/verify-otp', driverVerifyOtp);
router.post('/driver/upload-documents', driverUploadDocuments);

// Social Sign In (Google & Apple)
router.post('/social', socialSignIn);

export default router;
