// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\models\notifikasiModel.js
import db from '../core/config/knex.js';

export const getAll = (nik = null) => {
  const query = db('notifikasi_user')
    .join('pasien', 'notifikasi_user.NIK', 'pasien.NIK')
    .leftJoin('poli', 'notifikasi_user.IDPOLI', 'poli.IDPOLI')
    .leftJoin('dokter', 'notifikasi_user.IDDOKTER', 'dokter.IDDOKTER')
    .leftJoin(
      'master_tenaga_medis',
      'dokter.IDTENAGAMEDIS',
      'master_tenaga_medis.IDTENAGAMEDIS'
    )
    .select(
      'notifikasi_user.*',
      'pasien.NAMALENGKAP as NAMAPASIEN',
      'poli.NAMAPOLI',
      'master_tenaga_medis.NAMALENGKAP as NAMADOKTER'
    );

  if (nik) {
    query.where('notifikasi_user.NIK', nik);
  }

  return query;
};

export const updateStatusById = async (id) => {
  return db('notifikasi_user')
    .where({ IDNOTIFIKASI: id })
    .update({ STATUS: true, UPDATED_AT: db.fn.now() });
};

export const startTransaction = () => {
  return db.transaction();
};
