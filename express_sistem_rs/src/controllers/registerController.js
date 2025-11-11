import bcrypt from 'bcrypt';
import { findUserByInput, updatePasswordById } from '../models/registerModel.js';
import admin from 'firebase-admin';
import axios from 'axios';

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

const sendOTPViaSMS = async (phoneNumber, otp) => {
  try {
    let formattedPhone = phoneNumber;
    if (phoneNumber.startsWith('+62')) {
      formattedPhone = '0' + phoneNumber.substring(3);
    } else if (phoneNumber.startsWith('62')) {
      formattedPhone = '0' + phoneNumber.substring(2);
    }

    const message = `Kode verifikasi Mobile Rumah Sakit Anda: ${otp}. Berlaku 5 menit. Jangan bagikan kode ini kepada siapapun.`;

    const response = await axios.post(
      'https://api.fonnte.com/send',
      {
        target: formattedPhone,
        message: message,
        countryCode: '62'
      },
      {
        headers: {
          'Authorization': process.env.FONTEE_API_KEY
        }
      }
    );

    if (response.data.status) {
      return true;
    } else {
      throw new Error(response.data.reason || 'Gagal mengirim SMS');
    }
  } catch (error) {
    console.error('❌ Error sending SMS via Fontee:', error.response?.data || error.message);
    throw new Error('Gagal mengirim SMS');
  }
};

const sendOTPViaFirebase = async (phoneNumber, otp, otpId) => {
  try {
    const db = admin.firestore();
    
    await db.collection('otp_codes').doc(otpId).set({
      phoneNumber: phoneNumber,
      otp: otp,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 5 * 60 * 1000)
      ),
      verified: false,
      attempts: 0
    });
    
    if (process.env.FONTEE_ENABLED === 'true') {
      await sendOTPViaSMS(phoneNumber, otp);
    } else {
      console.log('⚠️ SMS Gateway disabled. OTP tidak dikirim via SMS.');
      console.log(`📱 OTP untuk testing: ${otp}`);
    }
    
    return true;
  } catch (error) {
    console.error('❌ Error in sendOTPViaFirebase:', error);
    throw new Error('Gagal mengirim OTP');
  }
};

export const requestOTP = async (req, res) => {
  try {
    const { norekammedis, password } = req.body;

    if (!norekammedis || !password) {
      return res.status(400).json({
        success: false,
        message: 'No Rekam Medis / NIK dan Password wajib diisi.',
      });
    }

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

    if (!pasien.NOHP) {
      return res.status(400).json({
        success: false,
        message: 'Nomor HP tidak terdaftar. Silakan hubungi admin RS.',
      });
    }

    const otp = generateOTP();
    const otpId = `otp_${pasien.IDPASIEN}_${Date.now()}`;

    await sendOTPViaFirebase(pasien.NOHP, otp, otpId);

    return res.status(200).json({
      success: true,
      message: 'Kode OTP telah dikirim ke nomor HP Anda.',
      data: {
        otpId: otpId,
        phoneNumber: pasien.NOHP,
        expiresIn: 300
      }
    });
  } catch (err) {
    console.error('❌ Request OTP error:', err);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server.',
    });
  }
};

export const verifyOTPAndRegister = async (req, res) => {
  try {
    const { otpId, otp, norekammedis, password } = req.body;

    if (!otpId || !otp || !norekammedis || !password) {
      return res.status(400).json({
        success: false,
        message: 'Data tidak lengkap.',
      });
    }

    const db = admin.firestore();
    const otpDoc = await db.collection('otp_codes').doc(otpId).get();

    if (!otpDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Kode OTP tidak ditemukan atau sudah kadaluarsa.',
      });
    }

    const otpData = otpDoc.data();

    if (otpData.verified) {
      return res.status(400).json({
        success: false,
        message: 'Kode OTP sudah digunakan.',
      });
    }

    const now = admin.firestore.Timestamp.now();
    if (now.toMillis() > otpData.expiresAt.toMillis()) {
      return res.status(400).json({
        success: false,
        message: 'Kode OTP sudah kadaluarsa. Silakan minta kode baru.',
      });
    }

    if (otpData.attempts >= 5) {
      return res.status(400).json({
        success: false,
        message: 'Terlalu banyak percobaan. Silakan minta kode OTP baru.',
      });
    }

    if (otpData.otp !== otp) {
      await db.collection('otp_codes').doc(otpId).update({
        attempts: admin.firestore.FieldValue.increment(1)
      });

      return res.status(400).json({
        success: false,
        message: `Kode OTP salah. Sisa percobaan: ${5 - (otpData.attempts + 1)}`,
      });
    }

    const pasien = await findUserByInput(norekammedis);
    if (!pasien) {
      return res.status(404).json({
        success: false,
        message: 'Data pasien tidak ditemukan.',
      });
    }

    const hashedPassword = await bcrypt.hash(password.trim(), 10);
    await updatePasswordById(pasien.IDPASIEN, hashedPassword);

    await db.collection('otp_codes').doc(otpId).update({
      verified: true,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return res.status(200).json({
      success: true,
      message: 'Verifikasi berhasil! Akun Anda telah terdaftar di aplikasi mobile.',
    });
  } catch (err) {
    console.error('❌ Verify OTP error:', err);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server.',
    });
  }
};

export const resendOTP = async (req, res) => {
  try {
    const { norekammedis } = req.body;

    if (!norekammedis) {
      return res.status(400).json({
        success: false,
        message: 'No Rekam Medis / NIK wajib diisi.',
      });
    }

    const pasien = await findUserByInput(norekammedis);
    if (!pasien) {
      return res.status(404).json({
        success: false,
        message: 'Data pasien tidak ditemukan.',
      });
    }

    if (!pasien.NOHP) {
      return res.status(400).json({
        success: false,
        message: 'Nomor HP tidak terdaftar.',
      });
    }

    const otp = generateOTP();
    const otpId = `otp_${pasien.IDPASIEN}_${Date.now()}`;

    await sendOTPViaFirebase(pasien.NOHP, otp, otpId);

    return res.status(200).json({
      success: true,
      message: 'Kode OTP baru telah dikirim.',
      data: {
        otpId: otpId,
        phoneNumber: pasien.NOHP,
        expiresIn: 300
      }
    });
  } catch (err) {
    console.error('❌ Resend OTP error:', err);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server.',
    });
  }
};

export const registerUser = async (req, res) => {
  try {
    const { norekammedis, password } = req.body;

    if (!norekammedis || !password) {
      return res.status(400).json({
        success: false,
        message: 'No Rekam Medis / NIK dan Password wajib diisi.',
      });
    }

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