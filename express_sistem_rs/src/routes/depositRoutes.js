import express from 'express';
import * as DepositController from '../controllers/depositController.js';

const router = express.Router();

router.get('/', DepositController.getAllDeposit);
router.get('/user/:nik', DepositController.getDepositByUser);
router.get('/:id', DepositController.getDepositById);

export default router;