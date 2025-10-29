// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\routes\notifikasiRoutes.js
import express from 'express';
import * as NotifikasiController from '../controllers/notifikasiController.js';

const router = express.Router();

router.get('/', NotifikasiController.getAllNotifikasi);

export default router;