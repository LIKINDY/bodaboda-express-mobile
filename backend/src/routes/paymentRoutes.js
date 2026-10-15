import express from 'express';
import {
  initiatePayment,
  paymentCallback,
  getWalletBalance,
  topupWallet
} from '../controllers/paymentController.js';

const router = express.Router();

router.post('/initiate', initiatePayment);
router.post('/callback', paymentCallback);
router.get('/wallet/balance', getWalletBalance);
router.post('/wallet/topup', topupWallet);

export default router;
