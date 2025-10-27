// D:\MARSTECH\NextJS-ExpressJS-Final-System\sistem_rs_be\src\models\beritaModel.js
import db from '../core/config/knex.js';

const MINIO_URL =
  process.env.NODE_ENV === 'development'
    ? 'http://10.0.2.2:9000' 
    : process.env.MINIO_BASE_URL || 'http://localhost:9000';

export const getAll = async () => {
  const rows = await db('berita').select();

  const data = rows.map((row) => ({
    ...row,
    PRATINJAU: row.PRATINJAU
      ? `${MINIO_URL}${row.PRATINJAU.startsWith('/') ? '' : '/'}${row.PRATINJAU}`
      : null,
  }));

  return data;
};

export const getById = async (id) => {
  const row = await db('berita').where('IDBERITA', id).first();

  if (!row) return null;

  return {
    ...row,
    PRATINJAU: row.PRATINJAU
      ? `${MINIO_URL}${row.PRATINJAU.startsWith('/') ? '' : '/'}${row.PRATINJAU}`
      : null,
  };
};
