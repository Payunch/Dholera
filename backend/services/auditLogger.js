const { AuditLog } = require('../models');

const logAuditEvent = async ({
  eventType,
  actorType = 'system',
  actorId = null,
  success = true,
  ip = null,
  userAgent = null,
  details = null
}) => {
  try {
    await AuditLog.create({
      eventType,
      actorType,
      actorId,
      success,
      ip,
      userAgent: userAgent ? String(userAgent).slice(0, 255) : null,
      details: details ? JSON.stringify(details).slice(0, 4000) : null
    });
  } catch (err) {
    console.error('Audit logging failed:', err.message);
  }
};

module.exports = {
  logAuditEvent
};
