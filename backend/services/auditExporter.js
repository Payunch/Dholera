const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const cron = require('node-cron');
const { Op } = require('sequelize');
const { AuditLog } = require('../models');

const DEFAULT_EXPORT_DIR = process.env.AUDIT_EXPORT_DIR || path.join(__dirname, '..', 'audit_exports');
const EXPORT_AFTER_DAYS = Number.parseInt(process.env.AUDIT_EXPORT_AFTER_DAYS || '30', 10);
const EXPORT_RETENTION_DAYS = Number.parseInt(process.env.AUDIT_EXPORT_RETENTION_DAYS || '365', 10);

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

async function exportOldLogs() {
  try {
    ensureDir(DEFAULT_EXPORT_DIR);
    const cutoff = new Date(Date.now() - EXPORT_AFTER_DAYS * 24 * 60 * 60 * 1000);
    const logs = await AuditLog.findAll({ where: { createdAt: { [Op.lt]: cutoff } }, order: [['createdAt', 'ASC']] });
    if (!logs || logs.length === 0) return;

    const fileName = `audit-export-${new Date().toISOString().slice(0,10)}.json.gz`;
    const filePath = path.join(DEFAULT_EXPORT_DIR, fileName);

    const json = JSON.stringify(logs.map(l => ({
      id: l.id,
      eventType: l.eventType,
      actorType: l.actorType,
      actorId: l.actorId,
      success: l.success,
      ip: l.ip,
      userAgent: l.userAgent,
      details: l.details,
      createdAt: l.createdAt
    })), null, 2);

    const gz = zlib.createGzip();
    const out = fs.createWriteStream(filePath);
    gz.pipe(out);
    gz.end(json);

    out.on('finish', async () => {
      // Remove exported rows from DB older than retention window
      const removeCutoff = new Date(Date.now() - EXPORT_RETENTION_DAYS * 24 * 60 * 60 * 1000);
      try {
        await AuditLog.destroy({ where: { createdAt: { [Op.lt]: removeCutoff } } });
      } catch (err) {
        console.error('Failed to prune old audit logs:', err);
      }
    });
  } catch (err) {
    console.error('Audit export failed:', err);
  }
}

function startAuditExporter() {
  // Run daily at 03:00 server time
  cron.schedule('0 3 * * *', () => {
    console.log('Running scheduled audit export');
    exportOldLogs();
  });
  // Also attempt a run at startup (non-blocking)
  setTimeout(() => exportOldLogs(), 2000);
}

module.exports = { startAuditExporter, exportOldLogs };
