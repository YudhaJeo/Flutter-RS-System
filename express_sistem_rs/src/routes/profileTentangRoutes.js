import express from 'express';
import * as ProfileController from '../controllers/profileTentangController.js';

const router = express.Router();

router.get('/', ProfileController.getAllprofile);
router.get('/:id', ProfileController.getprofileById);

export default router;
