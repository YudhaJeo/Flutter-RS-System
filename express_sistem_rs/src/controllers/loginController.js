import { findUserByInput } from '../models/loginModel.js';
import bcrypt from 'bcrypt';

export const loginUser = async (req, res) => {
  try {
    const { norekammedis, password } = req.body;

    if (!norekammedis || !password) {
      return res.status(400).json({
        success: false,
        message: 'No Rekam Medis / NIK dan Password wajib diisi.',
      });
    }

    const user = await findUserByInput(norekammedis);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'No Rekam Medis / NIK tidak ditemukan.',
      });
    }

    if (!user.PASSWORD) {
      return res.status(403).json({
        success: false,
        message: 'Akun ini belum terdaftar di aplikasi mobile. Silakan daftar terlebih dahulu.',
      });
    }

    const passwordMatch = await bcrypt.compare(password.trim(), user.PASSWORD);
    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message: 'Password salah. Silakan coba lagi.',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Login berhasil.',
      pasien: {
        IDPASIEN: user.IDPASIEN,
        NOREKAMMEDIS: user.NOREKAMMEDIS,
        NIK: user.NIK,
        NAMALENGKAP: user.NAMALENGKAP,
      },
    });
  } catch (err) {
    console.error('❌ Login error:', err);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};
