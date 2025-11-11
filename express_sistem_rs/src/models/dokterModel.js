import db from '../core/config/knex.js';

const MINIO_URL =
  process.env.NODE_ENV === 'development'
    ? process.env.MINIO_DEVICE_URL 
    : process.env.MINIO_BASE_URL;

export async function getAllDokter() {
  const rows = await db('dokter')
    .leftJoin('jadwal_dokter', 'dokter.IDDOKTER', 'jadwal_dokter.IDDOKTER')
    .leftJoin('poli', 'dokter.IDPOLI', 'poli.IDPOLI')
    .leftJoin('master_tenaga_medis', 'dokter.IDTENAGAMEDIS', 'master_tenaga_medis.IDTENAGAMEDIS')
    .select(
      'dokter.IDDOKTER',
      'dokter.IDTENAGAMEDIS',
      'dokter.IDPOLI',
      'master_tenaga_medis.NAMALENGKAP',
      'master_tenaga_medis.JENISTENAGAMEDIS',
      'master_tenaga_medis.FOTOPROFIL',
      'poli.NAMAPOLI',
      'jadwal_dokter.HARI',
      'jadwal_dokter.JAM_MULAI',
      'jadwal_dokter.JAM_SELESAI'
    );

  const result = {};
  rows.forEach((row) => {
    if (!result[row.IDDOKTER]) {
      const fotoUrl = row.FOTOPROFIL
        ? `${MINIO_URL}${row.FOTOPROFIL.startsWith('/') ? '' : '/'}${row.FOTOPROFIL}`
        : null;

      result[row.IDDOKTER] = {
        IDDOKTER: row.IDDOKTER,
        IDTENAGAMEDIS: row.IDTENAGAMEDIS,
        NAMALENGKAP: row.NAMALENGKAP,
        JENISTENAGAMEDIS: row.JENISTENAGAMEDIS,
        IDPOLI: row.IDPOLI,
        NAMAPOLI: row.NAMAPOLI,
        FOTOPROFIL: fotoUrl,
        JADWALPRAKTEK: [],
      };
    }

    if (row.HARI && row.JAM_MULAI && row.JAM_SELESAI) {
      result[row.IDDOKTER].JADWALPRAKTEK.push(
        `${row.HARI} ${row.JAM_MULAI.slice(0, 5)} - ${row.JAM_SELESAI.slice(0, 5)}`
      );
    }
  });

  const finalData = Object.values(result).map((d) => ({
    ...d,
    JADWALPRAKTEK: d.JADWALPRAKTEK.join(', '),
  }));

  return finalData;
}

export const getDokterById = async (id) => {

  const dokter = await db('dokter')
    .leftJoin('master_tenaga_medis', 'dokter.IDTENAGAMEDIS', 'master_tenaga_medis.IDTENAGAMEDIS')
    .where('dokter.IDDOKTER', id)
    .first();

  if (!dokter) {
    return null;
  }

  const jadwal = await db('jadwal_dokter').where('IDDOKTER', id);
  const fotoUrl = dokter.FOTOPROFIL
    ? `${MINIO_URL}${dokter.FOTOPROFIL.startsWith('/') ? '' : '/'}${dokter.FOTOPROFIL}`
    : null;

  return {
    ...dokter,
    FOTOPROFIL: fotoUrl,
    JADWAL: jadwal,
  };
};
