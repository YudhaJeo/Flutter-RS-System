import db from '../core/config/knex.js';

export const findUserByUsernameOrEmail = async (usernameOrEmail) => {
  try {
    const user = await db('users')
      .where('USERNAME', usernameOrEmail)
      .orWhere('EMAIL', usernameOrEmail)
      .first();
    return user;
  } catch (err) {
    throw new Error('Database error: ' + err.message);
  }
};
