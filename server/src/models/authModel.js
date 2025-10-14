import db from '../core/config/knex.js';

export const findUser = async (norekammedis, tanggallahir) => {
  try {
    const pasien = await db('pasien')
      .where({ NOREKAMMEDIS: norekammedis, TANGGALLAHIR: tanggallahir })
      .first();
    return pasien;
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};
