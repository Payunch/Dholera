const fs = require('fs');
const path = require('path');
const { sequelize, PdfDocument, Lead } = require('../models');

const main = async () => {
  await sequelize.authenticate();

  const pdf = await PdfDocument.findOne({ raw: true });
  const lead = await Lead.findOne({ where: { verified: true }, raw: true });

  if (!pdf) {
    console.log('No PDF records found');
    process.exit(1);
  }

  const resolvedPdfPath = path.resolve(__dirname, '..', pdf.file_path);
  console.log('First PDF:', pdf.title);
  console.log('Stored path:', pdf.file_path);
  console.log('Resolved path:', resolvedPdfPath);
  console.log('Exists on disk:', fs.existsSync(resolvedPdfPath));

  if (lead) {
    console.log('Verified lead token exists:', !!lead.lead_token);
    console.log('Lead id:', lead.id);
  } else {
    console.log('No verified lead found to test viewer token flow');
  }
};

main().then(() => process.exit(0)).catch((err) => {
  console.error(err);
  process.exit(1);
});
