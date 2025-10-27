import express from 'express';
import * as PenggunaanController from '../controllers/depositPenggunaanController.js';

const router = express.Router();

router.get('/', PenggunaanController.getAllPenggunaan);
router.get('/:id', PenggunaanController.getPenggunaanById);
router.get('/invoice/:idInvoice', PenggunaanController.getByInvoice);

export default router;