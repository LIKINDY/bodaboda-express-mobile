import express from 'express';
import {
  estimateRideFare,
  getRideDetails,
  cancelRide,
  getRideHistory
} from '../controllers/rideController.js';

const router = express.Router();

router.post('/estimate', estimateRideFare);
router.get('/history', getRideHistory);
router.get('/:rideId', getRideDetails);
router.post('/:rideId/cancel', cancelRide);

export default router;
