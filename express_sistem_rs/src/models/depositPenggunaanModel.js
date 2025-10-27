import db from '../core/config/knex.js';

export const getAll = () => {
  return db('deposit_penggunaan')
    .join('deposit', 'deposit_penggunaan.IDDEPOSIT', 'deposit.IDDEPOSIT')
    .join('invoice', 'deposit_penggunaan.IDINVOICE', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', 'pasien.NIK') 
    .select(
      'deposit_penggunaan.*',
      'deposit.NODEPOSIT',
      'invoice.NOINVOICE',
      'pasien.NIK',
      'pasien.NAMALENGKAP as NAMAPASIEN'
    );
};

export const getById = (id) => {
  return db('deposit_penggunaan')
    .join('deposit', 'deposit_penggunaan.IDDEPOSIT', 'deposit.IDDEPOSIT')
    .join('invoice', 'deposit_penggunaan.IDINVOICE', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', 'pasien.NIK')
    .select(
      'deposit_penggunaan.*',
      'deposit.NODEPOSIT',
      'invoice.NOINVOICE',
      'pasien.NIK',
      'pasien.NAMALENGKAP as NAMAPASIEN'
    )
    .where('deposit_penggunaan.IDPENGGUNAAN', id)
    .first();
};

export const getByInvoice = (noInvoice) => {
  return db('deposit_penggunaan')
    .join('deposit', 'deposit_penggunaan.IDDEPOSIT', 'deposit.IDDEPOSIT')
    .join('invoice', 'deposit_penggunaan.IDINVOICE', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', 'pasien.NIK')
    .select(
      'deposit_penggunaan.*',
      'deposit.NODEPOSIT',
      'invoice.NOINVOICE',
      'pasien.NIK',
      'pasien.NAMALENGKAP as NAMAPASIEN'
    )
    .where('invoice.NOINVOICE', noInvoice) // 🔹 ubah dari ID ke NOINVOICE
    .orderBy('deposit_penggunaan.TANGGALPEMAKAIAN', 'desc');
};
