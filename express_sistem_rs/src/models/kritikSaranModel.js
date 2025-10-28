import db from '../core/config/knex.js';

export const getAll = async () => {
  return db('kritik_saran').select('*').orderBy('CREATED_AT', 'desc');
};

export const getById = async (id) => {
  return db('kritik_saran').where({ IDKRITIKSARAN: id }).first();
};

export const create = async (data) => {
  const [insertedId] = await db('kritik_saran').insert(data);
  return getById(insertedId);
};
