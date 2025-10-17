import express from 'express';
import * as PoliController from '../controllers/poliController.js';

const router = express.Router();

router.get('/', PoliController.getAllPoli);

export default router;
