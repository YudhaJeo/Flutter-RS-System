import db from '../core/config/knex.js';

const MINIO_URL =
  process.env.NODE_ENV === 'development'
    ? process.env.MINIO_DEVICE_URL 
    : process.env.MINIO_BASE_URL;

    
export const getAll = async () => {
  const rows = await db('profile_mobile').select();

  const data = rows.map((row) => ({
    ...row,
    FOTOLOGO: row.FOTOLOGO
      ? `${MINIO_URL}${row.FOTOLOGO.startsWith('/') ? '' : '/'}${row.FOTOLOGO}`
      : null,
  }));

  return data;
};

export const getById = async (id) => {
    const row = await db('profile_mobile').where('IDPROFILE', id).first();
  
    if (!row) return null;
  
    return {
      ...row,
      FOTOLOGO: row.FOTOLOGO
        ? `${MINIO_URL}${row.FOTOLOGO.startsWith('/') ? '' : '/'}${row.FOTOLOGO}`
        : null,
    };
  };
  