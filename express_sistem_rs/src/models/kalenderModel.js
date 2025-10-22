import db from '../core/config/knex.js';

export const getAll = () => {
  return db('kalender as k')
    .leftJoin('master_tenaga_medis as m', 'k.IDDOKTER', 'm.IDTENAGAMEDIS')
    .select(
      'k.ID',
      'k.IDDOKTER',
      'k.TANGGAL',
      'k.STATUS',
      'k.KETERANGAN',
      'k.CREATED_AT',
      'k.UPDATED_AT',
      'm.NAMALENGKAP as NAMADOKTER'
    )
    .orderBy('k.TANGGAL', 'asc');
};

export const getById = (id) => {
  return db('kalender as k')
    .leftJoin('master_tenaga_medis as m', 'k.IDDOKTER', 'm.IDTENAGAMEDIS')
    .select(
      'k.ID',
      'k.IDDOKTER',
      'k.TANGGAL',
      'k.STATUS',
      'k.KETERANGAN',
      'k.CREATED_AT',
      'k.UPDATED_AT',
      'm.NAMALENGKAP as NAMADOKTER'
    )
    .where('k.ID', id)
    .first();
};
