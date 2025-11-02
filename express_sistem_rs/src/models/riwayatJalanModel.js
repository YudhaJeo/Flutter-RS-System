import db from '../core/config/knex.js';

export async function getById(id) {
  const data = await db('riwayat_rawat_jalan as rj')
    .join('rawat_jalan as rjln', 'rj.IDRAWATJALAN', 'rjln.IDRAWATJALAN')
    .join('pendaftaran as pd', 'rjln.IDPENDAFTARAN', 'pd.IDPENDAFTARAN')
    .leftJoin('pasien as ps', 'pd.NIK', 'ps.NIK')
    .leftJoin('poli as p', 'pd.IDPOLI', 'p.IDPOLI')
    .join('dokter', 'rj.IDDOKTER', 'dokter.IDDOKTER')
    .join('master_tenaga_medis', 'dokter.IDTENAGAMEDIS', 'master_tenaga_medis.IDTENAGAMEDIS')
    .select(
      'rj.*',
      'ps.NAMALENGKAP',
      'ps.NIK',
      'p.NAMAPOLI',
      'pd.KELUHAN',
      'pd.TANGGALKUNJUNGAN as TANGGALRAWAT',   
      'master_tenaga_medis.NAMALENGKAP as NAMADOKTER',            
    )
    .where('rj.IDRIWAYATJALAN', id)
    .first();

  return data;
}