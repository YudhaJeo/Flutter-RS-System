import express from 'express';
import * as RiwayatJalanController from '../controllers/riwayatJalanController.js';

const router = express.Router();

router.get('/:id', RiwayatJalanController.getById);

export default router;