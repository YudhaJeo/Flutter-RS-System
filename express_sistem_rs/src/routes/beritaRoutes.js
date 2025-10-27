// D:\MARSTECH\NextJS-ExpressJS-Final-System\sistem_rs_be\src\routes\beritaRoutes.js
import express from "express";
import * as BeritaController from "../controllers/beritaController.js";

const router = express.Router();

router.get("/", BeritaController.getAllBerita);

export default router;