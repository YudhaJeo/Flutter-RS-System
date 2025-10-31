import * as RiwayatRawatInap from '../models/riwayatInapModel.js';

export async function getRiwayatInapById(req, res) {
  const { id } = req.params;

  if (isNaN(parseInt(id))) {
    return res.status(400).json({ message: 'ID tidak valid' });
  }

  try {
    const dataUtama = await RiwayatRawatInap.getRiwayatInapById(id);
    if (!dataUtama) {
      return res.status(404).json({ message: 'Riwayat rawat inap tidak ditemukan' });
    }

    const daftarObat = await RiwayatRawatInap.getRiwayatObatByIdRiwayat(id);
    const daftarAlkes = await RiwayatRawatInap.getRiwayatAlkesByIdRiwayat(id);
    const daftarTindakan = await RiwayatRawatInap.getRiwayatTindakanByIdRiwayat(id);

    const responseData = {
      ...dataUtama,
      obat: daftarObat,
      alkes: daftarAlkes,
      tindakan: daftarTindakan,
    };

    return res.status(200).json({ data: responseData });
  } catch (err) {
    console.error(`[GET] /riwayat_inap/${id} gagal:`, err);
    return res.status(500).json({ message: 'Gagal mengambil detail riwayat rawat inap' });
  }
}