import db from '../core/config/knex.js';

export const findUserByInput = async (input) => {
  try {
    const pasien = await db('pasien')
      .where(function () {
        this.where('NOREKAMMEDIS', input).orWhere('NIK', input);
      })
      .first();
    return pasien;
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};

export const updatePasswordById = async (idPasien, hashedPassword) => {
  try {
    await db('pasien')
      .where({ IDPASIEN: idPasien })
      .update({ PASSWORD: hashedPassword });
    return true;
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};
