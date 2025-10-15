// D:\Mobile App\flutter_sistem_rs\server\src\routes\profileRoutes.js
import express from 'express';
import { getProfile, updateProfile, getAsuransi } from '../controllers/profileController.js';

const router = express.Router();

router.get('/', getProfile);
router.put('/', updateProfile);
router.get('/asuransi', getAsuransi);

export default router;
