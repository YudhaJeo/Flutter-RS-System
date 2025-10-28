// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\controllers\dompetMedisController.js
import * as DompetMedis from '../models/dompetMedisModel.js';

export async function getDepositByNik(req, res) {
  try {
    const { nik } = req.params;
    const data = await DompetMedis.getDepositByNik(nik);

    res.status(200).json({
      success: true,
      message: data.length ? 'Data deposit ditemukan' : 'Tidak ada data deposit',
      data,
    });
  } catch (err) {
    console.error('❌ [DepositController] Get Deposit By User Error:', err);
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data deposit pengguna',
      error: err.message,
    });
  }
}

export async function getPenggunaanByInvoice(req, res) {
  try {
    const { idInvoice } = req.params;
    const data = await DompetMedis.getPenggunaanByInvoice(idInvoice);

    res.status(200).json({
      success: true,
      message: data.length ? 'Data penggunaan deposit ditemukan' : 'Tidak ada data penggunaan',
      data,
    });
  } catch (err) {
    console.error('❌ [DepositController] Get Penggunaan By Invoice Error:', err);
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data penggunaan deposit',
      error: err.message,
    });
  }
}
