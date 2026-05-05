// Script: migrate-pdfs.js
// Purpose: Read PdfDocument rows from backend/database.sqlite and insert them into MySQL.

const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// Ensure models use MySQL connection.
process.env.DB_DIALECT = process.env.DB_DIALECT || 'mysql';

const models = require('../models');
const { PdfDocument, sequelize } = models;

const sqlitePath = path.join(__dirname, '..', 'database.sqlite');

const readSqliteRows = () => new Promise((resolve, reject) => {
  const db = new sqlite3.Database(sqlitePath, sqlite3.OPEN_READONLY, (err) => {
    if (err) {
      reject(err);
    }
  });

  db.all('SELECT id, title, category, file_path, is_protected FROM PdfDocuments', (err, rows) => {
    db.close();
    if (err) {
      reject(err);
      return;
    }
    resolve(rows || []);
  });
});

const normalizeFilePath = (value) => String(value || '').replace(/^\/+/, '');

const main = async () => {
  console.log('Opening SQLite DB at', sqlitePath);
  await sequelize.authenticate();
  await sequelize.sync();
  console.log('MySQL connected and schema verified.');

  const rows = await readSqliteRows();
  console.log(`Found ${rows.length} PDF rows in SQLite.`);

  let inserted = 0;
  let skipped = 0;

  for (const row of rows) {
    const filePath = normalizeFilePath(row.file_path || row.filePath || row.path);
    if (!filePath) {
      skipped += 1;
      console.warn(`Skipping SQLite row ${row.id}: missing file_path`);
      continue;
    }

    const existing = await PdfDocument.findOne({ where: { file_path: filePath } });
    if (existing) {
      skipped += 1;
      console.log(`Skipped existing: ${filePath}`);
      continue;
    }

    await PdfDocument.create({
      title: row.title || `Document ${row.id}`,
      category: row.category || null,
      file_path: filePath,
      is_protected: typeof row.is_protected !== 'undefined' ? !!row.is_protected : true
    });

    inserted += 1;
    console.log(`Inserted: ${filePath}`);
  }

  console.log(`Migration complete. Inserted ${inserted}, skipped ${skipped}.`);
};

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Migration failed:', err.message);
    process.exit(1);
  });
