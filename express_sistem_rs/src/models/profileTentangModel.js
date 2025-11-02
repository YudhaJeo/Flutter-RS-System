import db from '../core/config/knex.js';

export const getAll = () => {
    return db('profile_mobile').select('*');
};

export const getById = (id) => {
    return db('profile_mobile').where('IDPROFILE', id).first();
};
