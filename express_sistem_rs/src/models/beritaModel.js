// D:\MARSTECH\NextJS-ExpressJS-Final-System\sistem_rs_be\src\models\beritaModel.js
import db from '../core/config/knex.js';


const MINIO_URL =
  process.env.NODE_ENV === 'development'
    ? process.env.MINIO_DEVICE_URL 
    : process.env.MINIO_BASE_URL;

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
