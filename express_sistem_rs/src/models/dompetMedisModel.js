// D:\Mobile App\flutter_sistem_rs\express_sistem_rs\src\models\dompetMedisModel.js
import db from '../core/config/knex.js';

export const getDepositByNik = async (nik) => {
  return await db('deposit')
    .join('invoice', 'deposit.IDINVOICE', '=', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', '=', 'pasien.NIK')
    .leftJoin('bank_account', 'deposit.IDBANK', '=', 'bank_account.IDBANK')
    .select(
      'deposit.IDDEPOSIT',
      'deposit.NODEPOSIT',
      'deposit.TANGGALDEPOSIT',
      'deposit.NOMINAL as JUMLAH',
      'deposit.STATUS',
      'invoice.NOINVOICE',
      'pasien.NIK',
      'pasien.NAMALENGKAP as NAMAPASIEN',
      'bank_account.NAMA_BANK'
    )
    .where('pasien.NIK', nik)
    .orderBy('deposit.TANGGALDEPOSIT', 'desc');
};

export const getPenggunaanByInvoice = async (noInvoice) => {
  return await db('deposit_penggunaan')
    .join('deposit', 'deposit_penggunaan.IDDEPOSIT', '=', 'deposit.IDDEPOSIT')
    .join('invoice', 'deposit_penggunaan.IDINVOICE', '=', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', '=', 'pasien.NIK')
    .select(
      'deposit_penggunaan.IDPENGGUNAAN',
      'deposit_penggunaan.TANGGALPEMAKAIAN',
      'deposit_penggunaan.JUMLAH_PEMAKAIAN',
      'deposit.NODEPOSIT',
      'invoice.NOINVOICE',
      'pasien.NIK',
      'pasien.NAMALENGKAP as NAMAPASIEN'
    )
    
    .where('invoice.NOINVOICE', noInvoice)
    .orderBy('deposit_penggunaan.TANGGALPEMAKAIAN', 'desc');
};
