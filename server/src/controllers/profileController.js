// D:\Mobile App\flutter_sistem_rs\server\src\controllers\profileController.js
import { getProfileById, updateProfile as updateProfileModel } from '../models/profileModel.js';

export const getProfile = async (req, res) => {
  try {
    // ambil id dari query parameter
    const id = req.query.id || req.body.id;
    if (!id) return res.status(400).json({ success: false, message: 'ID pasien wajib ada' });

    const data = await getProfileById(id);
    if (!data) return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

export const updateProfile = async (req, res) => {
  try {
    const id = req.body.id;
    if (!id) return res.status(400).json({ success: false, message: 'ID pasien wajib ada' });
    const { alamat, nohp, usia, idasuransi, noasuransi } = req.body;
    const updated = await updateProfileModel(id, { alamat, nohp, usia, idasuransi, noasuransi });
    res.json({ success: true, data: updated });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
