// D:\Mobile App\flutter_sistem_rs\server\src\routes\profileRoutes.js
import express from 'express';
import { getProfile, updateProfile } from '../controllers/profileController.js';

const router = express.Router();

router.get('/', getProfile);
router.put('/', updateProfile);

export default router;
