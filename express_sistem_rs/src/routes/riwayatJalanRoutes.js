import express from 'express';
import * as RiwayatJalanController from '../controllers/riwayatJalanController.js';

const router = express.Router();

router.get('/', (req, res) => { res.json({ message: 'Route riwayat jalan aktif' });});
router.get('/:id', RiwayatJalanController.getById);

export default router;