import express from 'express';
import * as rekamMedisController from '../controllers/rekamMedisController.js';

const router = express.Router();

router.get('/', rekamMedisController.getRiwayatKunjungan);
router.get('/detail/:nik', rekamMedisController.getDetailRiwayat);

export default router;