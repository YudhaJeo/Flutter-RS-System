import db from '../core/config/knex.js';

const MINIO_URL =
  process.env.NODE_ENV === 'development'
    ? 'http://10.0.2.2:9000' 
    : process.env.MINIO_BASE_URL || 'http://localhost:9000';

    
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
  