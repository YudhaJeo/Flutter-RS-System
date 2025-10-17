import db from '../core/config/knex.js';

export const getAll = () => {
    return db('poli').select('*');
};

export const getById = (id) => {
    return db('poli').where('IDPOLI', id).first();
};
