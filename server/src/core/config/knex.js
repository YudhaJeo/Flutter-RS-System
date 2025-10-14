// D:\Mobile App\flutter_sistem_rs\server\src\core\config\knex.js
import knex from 'knex';
import config from '../../../knexfile.js';

const db = knex(config.development);

export default db;