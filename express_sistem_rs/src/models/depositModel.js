import db from '../core/config/knex.js';

export const getAll = () => {
  return db('deposit')
    .join('invoice', 'deposit.IDINVOICE', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', 'pasien.NIK')
    .leftJoin('bank_account', 'deposit.IDBANK', 'bank_account.IDBANK')
    .select(
      'deposit.*',
      'invoice.NOINVOICE',
      'pasien.NAMALENGKAP as NAMAPASIEN',
      'pasien.NIK',
      'bank_account.NAMA_BANK'
    );
};

export const getById = (id) => {
  return db('deposit')
    .join('invoice', 'deposit.IDINVOICE', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', 'pasien.NIK')
    .leftJoin('bank_account', 'deposit.IDBANK', 'bank_account.IDBANK')
    .select(
      'deposit.*',
      'invoice.NOINVOICE',
      'pasien.NAMALENGKAP as NAMAPASIEN',
      'pasien.NIK',
      'bank_account.NAMA_BANK'
    )
    .where('deposit.IDDEPOSIT', id)
    .first();
};

export const getByNik = (nik) => {
  return db('deposit')
    .join('invoice', 'deposit.IDINVOICE', 'invoice.IDINVOICE')
    .join('pasien', 'invoice.NIK', 'pasien.NIK')
    .leftJoin('bank_account', 'deposit.IDBANK', 'bank_account.IDBANK')
    .select(
      'deposit.*',
      'invoice.NOINVOICE',
      'pasien.NAMALENGKAP as NAMAPASIEN',
      'pasien.NIK',
      'bank_account.NAMA_BANK'
    )
    .where('pasien.NIK', nik)
    .orderBy('deposit.TANGGALDEPOSIT', 'desc');
};