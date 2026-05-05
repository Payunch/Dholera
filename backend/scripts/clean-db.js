const { sequelize, Lead, Update, PdfView, PdfDocument, VisitorSession, WhatsAppLog, AuditLog, Analytics } = require('../models');

const cleanDatabase = async () => {
  try {
    console.log('Starting database cleanup...');

    // Delete all dummy/test data
    await Lead.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all Leads');

    await Update.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all Updates');

    await PdfView.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all PDF Views');

    await VisitorSession.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all Visitor Sessions');

    await WhatsAppLog.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all WhatsApp Logs');

    await AuditLog.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all Audit Logs');

    await Analytics.destroy({ where: {}, truncate: true });
    console.log('✓ Cleared all Analytics');

    // Keep PDFs as they are reference data
    console.log('✓ Preserved all PDF Documents (reference data)');

    console.log('\n✅ Database cleanup completed successfully!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error during cleanup:', err);
    process.exit(1);
  }
};

cleanDatabase();
