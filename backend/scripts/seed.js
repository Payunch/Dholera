const { sequelize, Lead, Update, Analytics, VisitorSession, PdfDocument, PdfView } = require('../models');

const seedData = async () => {
  await sequelize.sync({ force: true });
  console.log('Database synced & cleared.');

  // Real PDFs moved from frontend
  const pdfData = [
    // DP Maps
    { title: 'New DP Plan 2026', category: 'DP Maps', file_path: 'uploads/pdfs/New_DP.pdf' },
    { title: 'Dholera DP Map - Zone Hath', category: 'DP Maps', file_path: 'uploads/pdfs/d.p zone hath and resurwey number ok-Model.pdf' },
    { title: 'New Development Plan Layout', category: 'DP Maps', file_path: 'uploads/pdfs/DHOLERA New DP Plan-MAP.pdf' },
    
    // Naksha (TP Maps)
    { title: 'TP 1A1 Final Naksha', category: 'Naksha', file_path: 'uploads/pdfs/TP 1A1_.pdf' },
    { title: 'TP 1A2 Final Naksha', category: 'Naksha', file_path: 'uploads/pdfs/2___DHOLERA TP 1A2 FINAL.pdf' },
    { title: 'TP 2B1 Naksha', category: 'Naksha', file_path: 'uploads/pdfs/TP.2B1 (1).pdf' },
    { title: 'TP 2B-1 Layout', category: 'Naksha', file_path: 'uploads/pdfs/3____2b-1.pdf' },
    { title: 'TP 2B-2 Layout', category: 'Naksha', file_path: 'uploads/pdfs/4____2B-2.pdf' },
    { title: 'TP 2B3 Layout', category: 'Naksha', file_path: 'uploads/pdfs/5____2B3.pdf' },
    { title: 'TP 3B 2021', category: 'Naksha', file_path: 'uploads/pdfs/7_______3B_2021.pdf' },
    { title: 'TP 4B1 2024', category: 'Naksha', file_path: 'uploads/pdfs/TP 4B1 2024.pdf' },
    { title: 'TP 4B-1 After TR', category: 'Naksha', file_path: 'uploads/pdfs/12       TP 4B-1_Aftfter TR final-portrai.pdf' },
    { title: 'TP 4B-2 Layout', category: 'Naksha', file_path: 'uploads/pdfs/10_TP-4B_2.pdf' },
    { title: 'TP 5 O.P. F.P.', category: 'Naksha', file_path: 'uploads/pdfs/T.P. - 5 O.P. - F.P.  (1).pdf' },
    { title: 'TP 5A 2021', category: 'Naksha', file_path: 'uploads/pdfs/9_______5A_2021.pdf' },
    { title: 'TP 5A After TR', category: 'Naksha', file_path: 'uploads/pdfs/14       TP5A ater TR final-Model.pdf' },
    { title: 'TP 5B 2021', category: 'Naksha', file_path: 'uploads/pdfs/10_______5B_2021.pdf' },
    { title: 'TP 6A 2021', category: 'Naksha', file_path: 'uploads/pdfs/11________6A_2021.pdf' },
    
    // Official PDFs (Paramarsh/Authority)
    { title: 'TP 3A Authority Paramarsh', category: 'PDFs', file_path: 'uploads/pdfs/08        TP3A Authority Paramarsh before Avord sudhara (authority paramars-Layout1.pdf' },
    { title: 'TP 3C-1 CTP TR Paramarsh', category: 'PDFs', file_path: 'uploads/pdfs/10        TP 3C-1 CTP TR  Paramarsh-Layout1.pdf' },
    { title: 'Infrastructure Update April 2026', category: 'PDFs', file_path: 'uploads/pdfs/14-04-2026   150238.pdf' }
  ];

  await PdfDocument.bulkCreate(pdfData);
  console.log('Database seeded with PDFs only.');

  console.log('Database seeded successfully with real PDFs.');
};

seedData().catch(console.error);
