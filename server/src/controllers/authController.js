import { findUser } from '../models/authModel.js';

export const loginUser = async (req, res) => {
  const { norekammedis, tanggallahir } = req.body;

  if (!norekammedis || !tanggallahir) {
    return res.status(400)
      .json({ success: false, message: 'No rekam medis dan tanggal lahir wajib diisi' });
  }

  try {
    const pasien = await findUser(norekammedis, tanggallahir);
    if (!pasien) {
      return res
        .status(401)
        .json({ success: false, message: 'No Rekam Medis atau Tanggal Lahir tidak cocok!' });
    }
    return res.json({
      success: true,
      message: 'Login berhasil',
      pasien: {
        IDPASIEN: pasien.IDPASIEN,
        NOREKAMMEDIS: pasien.NOREKAMMEDIS,
        NAMALENGKAP: pasien.NAMALENGKAP,
        NIK: pasien.NIK,
      },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};
