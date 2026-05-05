const sequelize = require('../config/database');
const Lead = require('./Lead');
const Update = require('./Update');
const Analytics = require('./Analytics');
const VisitorSession = require('./VisitorSession');
const PdfDocument = require('./PdfDocument');
const PdfView = require('./PdfView');
const AuditLog = require('./AuditLog');
const WhatsAppLog = require('./WhatsAppLog');
const Setting = require('./Setting');

// Define Relationships
Lead.hasMany(PdfView, { foreignKey: 'lead_id' });
PdfView.belongsTo(Lead, { foreignKey: 'lead_id' });

Lead.hasMany(WhatsAppLog, { foreignKey: 'lead_id' });
WhatsAppLog.belongsTo(Lead, { foreignKey: 'lead_id' });

PdfDocument.hasMany(PdfView, { foreignKey: 'pdf_id' });
PdfView.belongsTo(PdfDocument, { foreignKey: 'pdf_id' });

module.exports = {
  sequelize,
  Lead,
  Update,
  Analytics,
  VisitorSession,
  PdfDocument,
  PdfView,
  AuditLog,
  WhatsAppLog,
  Setting
};
