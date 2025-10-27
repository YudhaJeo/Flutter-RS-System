// src/controllers/beritaController.js
import * as BeritaModel from "../models/beritaModel.js";

export const getAllBerita = async (req, res) => {
  try {
    const berita = await BeritaModel.getAll();
    res.json({ data: berita });
  } catch (err) {
    console.error("getAllBerita Error:", err);
    res.status(500).json({ error: err.message });
  }
};