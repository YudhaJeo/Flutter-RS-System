// D:\Mobile App\flutter_sistem_rs\server\src\models\profileModel.js
import db from '../core/config/knex.js';

export const getProfileById = async (id) => {
  try {
    return await db('pasien').where({ IDPASIEN: id }).first();
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};

export const updateProfile = async (id, data) => {
  try {
    const toUpdate = {};
    if (data.alamat !== undefined) toUpdate.ALAMAT = data.alamat;
    if (data.nohp !== undefined) toUpdate.NOHP = data.nohp;
    if (data.usia !== undefined) toUpdate.USIA = data.usia;
    if (data.idasuransi !== undefined) toUpdate.IDASURANSI = data.idasuransi;
    if (data.noasuransi !== undefined) toUpdate.NOASURANSI = data.noasuransi;
    await db('pasien').where({ IDPASIEN: id }).update(toUpdate);
    return await db('pasien').where({ IDPASIEN: id }).first();
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};

export const getAllAsuransi = async () => {
  try {
    return await db('asuransi').select('IDASURANSI', 'NAMAASURANSI');
  } catch (err) {
    throw new Error('Database Asuransi error: ' + err.message);
  }
};
