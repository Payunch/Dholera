const { Sequelize } = require('sequelize');
const path = require('path');

const dialect = process.env.DB_DIALECT || 'mysql';

let sequelize;

if (dialect === 'mysql') {
  const sslDisabled = process.env.DB_SSL === 'false' || process.env.DB_SSL === '0';

  sequelize = new Sequelize(
    process.env.DB_NAME || 'dholera',
    process.env.DB_USER || 'root',
    process.env.DB_PASS || '',
    {
      host: process.env.DB_HOST || '127.0.0.1',
      dialect: 'mysql',
      logging: false,
      dialectOptions: {
        // Disable SSL for local dev MySQL (required when MySQL requires SSL but
        // does not have a proper cert configured)
        ssl: sslDisabled ? false : undefined,
        connectTimeout: 10000
      },
      pool: {
        max: 5,
        min: 0,
        acquire: 30000,
        idle: 10000
      }
    }
  );

  console.log(
    `[DB] MySQL → ${process.env.DB_HOST || '127.0.0.1'}:3306 / ${process.env.DB_NAME || 'dholera'} (SSL: ${!sslDisabled})`
  );
} else {
  sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: path.join(__dirname, '../database.sqlite'),
    logging: false
  });
  console.log('[DB] SQLite → database.sqlite');
}

/**
 * Authenticate the connection and log a clear error if it fails.
 * Called from index.js before .sync().
 */
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log('[DB] Connection established successfully.');
    return true;
  } catch (err) {
    console.error('[DB] ❌ Unable to connect to the database:');
    console.error('   ', err.message);
    console.error('[DB] Check DB_HOST, DB_USER, DB_PASS, DB_NAME in backend/.env');
    return false;
  }
}

module.exports = sequelize;
module.exports.testConnection = testConnection;
