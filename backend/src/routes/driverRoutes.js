import express from 'express';
import {
  toggleDriverStatus,
  getDriverEarnings,
  getDemandHeatmap,
  updateDriverProfile
} from '../controllers/driverController.js';

const router = express.Router();

router.post('/status', toggleDriverStatus);
router.get('/earnings', getDriverEarnings);
router.get('/demand-heatmap', getDemandHeatmap);
router.put('/profile-documents', updateDriverProfile);

export default router;
