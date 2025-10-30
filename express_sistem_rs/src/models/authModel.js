import db from '../core/config/knex.js';

export const findUser = async (input, tanggallahir) => {
  try {
    const pasien = await db('pasien')
      .where(function () {
        this.where('NOREKAMMEDIS', input).orWhere('NIK', input);
      })
      .andWhere('TANGGALLAHIR', tanggallahir)
      .first();

    return pasien;
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};
