import express from 'express';
import * as DokterController from '../controllers/dokterController.js';

const router = express.Router();

router.get('/', DokterController.getAllDokter);
router.get('/poli/:idPoli', DokterController.getDokterByPoli);
router.get('/:id', DokterController.getDokterById);

export default router;