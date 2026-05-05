const { Lead, PdfView, PdfDocument, WhatsAppLog, VisitorSession } = require('./models');

async function test() {
  try {
    const leads = await Lead.findAll({ 
      include: [{
        model: PdfView,
        include: [PdfDocument]
      }],
      order: [['createdAt', 'DESC']],
      limit: 1
    });
    console.log("Leads OK");
  } catch(e) {
    console.log("Leads Error:", e.message);
  }
  
  try {
    const logs = await WhatsAppLog.count();
    console.log("WhatsAppLog OK");
  } catch(e) {
    console.log("WhatsAppLog Error:", e.message);
  }

  try {
     const s = await VisitorSession.count();
     console.log("VisitorSession OK");
  } catch(e) {
     console.log("VisitorSession Error:", e.message);
  }
}

test();
