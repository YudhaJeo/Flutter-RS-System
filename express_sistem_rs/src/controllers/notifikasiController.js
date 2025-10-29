// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\controllers\notifikasiController.js
import * as NotifikasiModel from '../models/notifikasiModel.js';

export async function getAllNotifikasi(req, res) {
  try {
    const data = await NotifikasiModel.getAll();
    res.json({ data });
  } catch (err) {
    console.error('GetAll Error:', err.message);
    res.status(500).json({ error: err.message });
  }
}

export async function updateStatusNotifikasi(req, res) {
  try {
    const { id } = req.params;
    await NotifikasiModel.updateStatusById(id);
    res.json({ message: 'Status notifikasi berhasil diperbarui menjadi dibaca.' });
  } catch (err) {
    console.error('UpdateStatus Error:', err.message);
    res.status(500).json({ error: err.message });
  }
}
