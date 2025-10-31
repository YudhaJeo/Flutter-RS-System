import db from '../core/config/knex.js';

export async function getRiwayatInapById(id) {
  return await db('riwayat_rawat_inap')
    .join('rawat_inap', 'riwayat_rawat_inap.IDRAWATINAP', 'rawat_inap.IDRAWATINAP')
    .join('rawat_jalan', 'rawat_inap.IDRAWATJALAN', 'rawat_jalan.IDRAWATJALAN')
    .join('pendaftaran', 'rawat_jalan.IDPENDAFTARAN', 'pendaftaran.IDPENDAFTARAN')
    .join('pasien', 'pendaftaran.NIK', 'pasien.NIK')
    .join('bed', 'rawat_inap.IDBED', 'bed.IDBED')
    .select(
      'riwayat_rawat_inap.*',
      'pasien.NAMALENGKAP',
      'bed.NOMORBED',
      'riwayat_rawat_inap.TOTALKAMAR'
    )
    .where('riwayat_rawat_inap.IDRIWAYATINAP', id)
    .first();
}


export async function getRiwayatObatByIdRiwayat(id) {
  return await db('riwayat_obat_inap')
    .join('obat', 'riwayat_obat_inap.IDOBAT', 'obat.IDOBAT')
    .select('obat.NAMAOBAT', 'obat.JENISOBAT', 'riwayat_obat_inap.JUMLAH', 'riwayat_obat_inap.HARGA', 'riwayat_obat_inap.TOTAL')
    .where('riwayat_obat_inap.IDRIWAYATINAP', id);
}

export async function getRiwayatAlkesByIdRiwayat(id) {
  return await db('riwayat_alkes_inap')
    .join('alkes', 'riwayat_alkes_inap.IDALKES', 'alkes.IDALKES')
    .select('alkes.NAMAALKES', 'alkes.JENISALKES', 'riwayat_alkes_inap.JUMLAH', 'riwayat_alkes_inap.HARGA', 'riwayat_alkes_inap.TOTAL')
    .where('riwayat_alkes_inap.IDRIWAYATINAP', id);
}

export async function getRiwayatTindakanByIdRiwayat(id) {
  return await db('riwayat_tindakan_inap')
    .join('tindakan_medis', 'riwayat_tindakan_inap.IDTINDAKAN', 'tindakan_medis.IDTINDAKAN')
    .select('tindakan_medis.NAMATINDAKAN', 'tindakan_medis.KATEGORI', 'riwayat_tindakan_inap.JUMLAH', 'riwayat_tindakan_inap.HARGA', 'riwayat_tindakan_inap.TOTAL')
    .where('riwayat_tindakan_inap.IDRIWAYATINAP', id);
}
