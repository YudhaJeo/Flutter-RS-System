import express from 'express';
import * as jadwalController from '../controllers/kalenderController.js';

const router = express.Router();

router.get('/', jadwalController.getAllJadwal);

export default router;
