// D:\MARSTECH\NextJS-ExpressJS-Final-System\sistem_rs_be\src\models\beritaModel.js
import db from '../core/config/knex.js';

export const getAll = () => db('berita').select();

export const getById = (id) => {
  return db('berita').where('IDBERITA', id).first();
};
