import * as KritikSaranModel from '../models/kritikSaranModel.js';

export const getAllKritikSaran = async (req, res) => {
  try {
    const { nik } = req.query;
    const data = await KritikSaranModel.getAll(nik);
    res.status(200).json({ success: true, data });
  } catch (err) {
    console.error('Get All Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
};

export const getKritikSaranById = async (req, res) => {
  try {
    const { id } = req.params;
    const data = await KritikSaranModel.getById(id);
    if (!data) {
      return res.status(404).json({ success: false, message: 'Data tidak ditemukan' });
    }
    res.status(200).json({ success: true, data });
  } catch (err) {
    console.error('Get By ID Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
};

export const createKritikSaran = async (req, res) => {
  try {
    const { NIK, JENIS, PESAN, CREATED_AT } = req.body;

    if (!JENIS || !PESAN) {
      return res.status(400).json({
        success: false,
        message: 'JENIS dan PESAN wajib diisi',
      });
    }

    const now = CREATED_AT ? new Date(CREATED_AT) : new Date();

    const newData = await KritikSaranModel.create({
      NIK,
      JENIS,
      PESAN,
      CREATED_AT: now, 
    });

    res.status(201).json({
      success: true,
      message: 'Data berhasil ditambahkan',
      data: newData,
    });
  } catch (err) {
    console.error('Create Error:', err);
    res.status(500).json({ success: false, message: err.message });
  }
};