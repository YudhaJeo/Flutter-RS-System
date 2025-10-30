import * as Model from '../models/rekamMedisModel.js';

export async function getRiwayatKunjungan(req, res) {
  try {
    const nik = req.params.nik || req.query.nik || req.headers['x-nik'];

    if (!nik) {
      return res.status(400).json({ error: 'NIK wajib dikirim (params, query, atau header)' });
    }

    const data = await Model.getRiwayatByPasien(nik);
    res.json({ data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}

export async function getDetailRiwayat(req, res) {
  try {
    const nik = req.params.nik || req.query.nik || req.headers['x-nik'];

    if (!nik) {
      return res.status(400).json({ error: 'NIK wajib dikirim (params, query, atau header)' });
    }

    const data = await Model.getRiwayatByPasien(nik);
    res.json({ data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}