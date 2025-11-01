import bcrypt from 'bcrypt';
import { findUserByInput, updatePasswordById } from '../models/registerModel.js';

export const registerUser = async (req, res) => {
  try {
    const { norekammedis, password } = req.body;

    // 🔹 Validasi input
    if (!norekammedis || !password) {
      return res.status(400).json({
        success: false,
        message: 'No Rekam Medis / NIK dan Password wajib diisi.',
      });
    }

    // 🔹 Cek apakah pasien terdaftar
    const pasien = await findUserByInput(norekammedis);
    if (!pasien) {
      return res.status(404).json({
        success: false,
        message: 'Pasien dengan No Rekam Medis / NIK tersebut tidak ditemukan.',
      });
    }

    if (pasien.PASSWORD) {
      return res.status(400).json({
        success: false,
        message: 'Akun ini sudah terdaftar di aplikasi mobile.',
      });
    }

    const hashedPassword = await bcrypt.hash(password.trim(), 10);

    await updatePasswordById(pasien.IDPASIEN, hashedPassword);

    return res.status(200).json({
      success: true,
      message: 'Registrasi berhasil. Akun Anda telah terhubung ke aplikasi mobile.',
    });
  } catch (err) {
    console.error('❌ Register error:', err);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server.',
    });
  }
};
