import { findUserByUsernameOrEmail } from '../models/authModel.js';

export const loginUser = async (req, res) => {
  const { usernameOrEmail, password } = req.body;

  if (!usernameOrEmail || !password) {
    return res
      .status(400)
      .json({ success: false, message: 'Username/email dan password wajib diisi' });
  }

  try {
    const user = await findUserByUsernameOrEmail(usernameOrEmail);
    if (!user) {
      return res
        .status(401)
        .json({ success: false, message: 'Username atau email tidak ditemukan' });
    }

    if (user.PASSWORD !== password) {
      return res
        .status(401)
        .json({ success: false, message: 'Password salah' });
    }

    return res.json({
      success: true,
      message: 'Login berhasil',
      user: {
        id: user.IDUSER,
        username: user.USERNAME,
        email: user.EMAIL,
      },
    });
  } catch (err) {
    console.error(err);
    return res
      .status(500)
      .json({ success: false, message: 'Terjadi kesalahan server' });
  }
};
