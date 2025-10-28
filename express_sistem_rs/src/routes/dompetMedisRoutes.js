// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\routes\depositRoutes.js
import express from 'express';
import * as dompetMedisController from '../controllers/dompetMedisController.js';

const router = express.Router();

router.get('/user/:nik', dompetMedisController.getDepositByNik);
router.get('/invoice/:idInvoice', dompetMedisController.getPenggunaanByInvoice);

export default router;