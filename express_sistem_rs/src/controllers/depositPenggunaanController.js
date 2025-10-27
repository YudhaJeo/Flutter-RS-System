import * as PenggunaanModel from '../models/depositPenggunaanModel.js';

export async function getAllPenggunaan(req, res) {
  try {
    const data = await PenggunaanModel.getAll();
    res.status(200).json({ success: true, data });
  } catch (err) {
    console.error('Get All Penggunaan Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
}

export async function getPenggunaanById(req, res) {
  try {
    const { id } = req.params;
    const penggunaan = await PenggunaanModel.getById(id);

    if (!penggunaan) {
      return res.status(404).json({ success: false, message: 'Data penggunaan tidak ditemukan' });
    }

    res.status(200).json({ success: true, data: penggunaan });
  } catch (err) {
    console.error('Get Penggunaan By ID Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
}

export async function getByInvoice(req, res) {
  try {
    const { idInvoice } = req.params;
    const data = await PenggunaanModel.getByInvoice(idInvoice);
    res.status(200).json({ success: true, data });
  } catch (err) {
    console.error('Get Penggunaan By Invoice Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
}