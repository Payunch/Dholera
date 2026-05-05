const express = require('express');
const router = express.Router();
const { Lead, VisitorSession, PdfView, PdfDocument } = require('../models');
const { Op } = require('sequelize');
const ExcelJS = require('exceljs');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const { verifyToken } = require('./auth');
const { 
  sendOtpOnWhatsapp, 
  normalizePhone, 
  buildManualWhatsAppMessage, 
  logWhatsAppActivity 
} = require('../services/whatsapp');
const { logAuditEvent } = require('../services/auditLogger');
const { maybeNotifyHighInterestLead, isHighInterestLead } = require('../services/leadNotifications');
const { cleanText, cleanEmail, cleanPathFragment, parsePositiveInt } = require('../utils/sanitize');

const OTP_TTL_MS = 5 * 60 * 1000;
const OTP_SEND_WINDOW_MS = Number.parseInt(process.env.OTP_SEND_WINDOW_MS || `${15 * 60 * 1000}`, 10);
const OTP_SEND_MAX = Number.parseInt(process.env.OTP_SEND_MAX || '5', 10);
const OTP_VERIFY_WINDOW_MS = Number.parseInt(process.env.OTP_VERIFY_WINDOW_MS || `${15 * 60 * 1000}`, 10);
const OTP_VERIFY_MAX = Number.parseInt(process.env.OTP_VERIFY_MAX || '15', 10);

const otpSendLimiter = rateLimit({
  windowMs: OTP_SEND_WINDOW_MS,
  max: OTP_SEND_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many OTP requests. Please wait and try again.' }
});

const otpVerifyLimiter = rateLimit({
  windowMs: OTP_VERIFY_WINDOW_MS,
  max: OTP_VERIFY_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many verification attempts. Please wait and try again.' }
});

const hashOtp = (otp) => crypto.createHash('sha256').update(String(otp)).digest('hex');
const isValidPhone = (phone) => /^[6-9]\d{9}$/.test(phone);
const ALLOWED_LEAD_STATUSES = new Set(['New', 'Contacted', 'Converted', 'Follow-up', 'Not Interested', 'Closed']);

const extractToken = (authHeader = '') => {
  if (!authHeader) return '';
  if (authHeader.toLowerCase().startsWith('bearer ')) return authHeader.slice(7).trim();
  return authHeader.trim();
};

const safeJsonParse = (value, fallback = []) => {
  try {
    const parsed = JSON.parse(value || '[]');
    return Array.isArray(parsed) ? parsed : fallback;
  } catch (err) {
    return fallback;
  }
};

const getLeadContext = async (lead) => {
  const plainLead = lead?.get ? lead.get({ plain: true }) : { ...lead };
  const sessions = plainLead.browserFingerprint
    ? await VisitorSession.findAll({
        where: { browserFingerprint: plainLead.browserFingerprint },
        order: [['createdAt', 'DESC']]
      })
    : [];

  const pdfViews = plainLead.id
    ? await PdfView.findAll({
        where: { lead_id: plainLead.id },
        include: [PdfDocument],
        order: [['createdAt', 'DESC']]
      })
    : [];

  const sessionPages = sessions.flatMap((session) => safeJsonParse(session.visitedPages, []));
  const leadPages = safeJsonParse(plainLead.visited_pages, []);
  const pages = [...new Set([...leadPages, ...sessionPages])];

  return {
    plainLead,
    sessions,
    pdfViews,
    pages,
    total_sessions: sessions.length,
    totalTimeSpent: (plainLead.timeSpent || 0) + sessions.reduce((acc, session) => acc + (session.timeSpent || 0), 0),
    pdf_view_count: pdfViews.length
  };
};

const maybeNotifyLeadIfHighInterest = async (lead, context = {}) => {
  const leadData = lead?.get ? lead.get({ plain: true }) : { ...lead };
  const notificationContext = {
    pages: context.pages || safeJsonParse(leadData.visited_pages, []),
    sessions: context.sessions || [],
    views: context.pdfViews || context.views || []
  };
  const mergedLeadData = {
    ...leadData,
    timeSpent: context.totalTimeSpent ?? leadData.timeSpent,
    pdf_view_count: notificationContext.views.length
  };

  if (!isHighInterestLead(mergedLeadData)) {
    return { notified: false, reason: 'not_high_interest' };
  }

  if (leadData.high_interest_whatsapp_notified_at && leadData.high_interest_email_notified_at) {
    return { notified: false, reason: 'already_notified' };
  }

  const result = await maybeNotifyHighInterestLead(mergedLeadData, notificationContext);
  const updates = {};
  if (result.whatsapp?.sent && !leadData.high_interest_whatsapp_notified_at) {
    updates.high_interest_whatsapp_notified_at = new Date();
  }
  if (result.email?.sent && !leadData.high_interest_email_notified_at) {
    updates.high_interest_email_notified_at = new Date();
  }
  if (Object.keys(updates).length && lead?.update) {
    await lead.update(updates);
  }

  return result;
};

// GET all leads (Admin) - with filters and search
router.get('/', verifyToken, async (req, res) => {
  try {
    const status = cleanText(req.query?.status, 40);
    const source = cleanText(req.query?.source, 80);
    const search = cleanText(req.query?.search, 80).replace(/[%_]/g, '');
    const days = parsePositiveInt(req.query?.days, 0, 3650);
    const where = {};
    
    if (status && ALLOWED_LEAD_STATUSES.has(status)) where.status = status;
    if (source) where.source = source;
    if (days) {
      const date = new Date();
      date.setDate(date.getDate() - days);
      where.createdAt = { [Op.gte]: date };
    }
    if (search) {
      where[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { phone: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } }
      ];
    }

    const leads = await Lead.findAll({ 
      where, 
      include: [{
        model: PdfView,
        include: [PdfDocument]
      }],
      order: [['createdAt', 'DESC']] 
    });

    // Manually attach VisitorSession data for each lead based on fingerprint
    const leadsWithIntelligence = await Promise.all(leads.map(async (lead) => {
      const plainLead = lead.get({ plain: true });
      if (plainLead.browserFingerprint) {
        const sessions = await VisitorSession.findAll({
          where: { browserFingerprint: plainLead.browserFingerprint },
          order: [['createdAt', 'DESC']]
        });
        plainLead.sessions = sessions;
        plainLead.total_sessions = sessions.length;
        
        // Re-calculate total time spent including anonymous sessions
        // Lead.timeSpent is now intended to only store authenticated engagement time
        plainLead.totalTimeSpent = (plainLead.timeSpent || 0) + sessions.reduce((acc, s) => acc + (s.timeSpent || 0), 0);

        // Merge visited pages from Lead and all associated sessions for a complete journey pathway
        const sessionPages = sessions.flatMap((s) => safeJsonParse(s.visitedPages, []));
        const leadPages = safeJsonParse(plainLead.visited_pages, []);
        plainLead.visited_pages = JSON.stringify([...new Set([...leadPages, ...sessionPages])]);
      } else {
        plainLead.sessions = [];
        plainLead.total_sessions = 0;
        plainLead.totalTimeSpent = plainLead.timeSpent || 0;
      }
      return plainLead;
    }));

    res.json(leadsWithIntelligence);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET check if visitor is already verified by fingerprint
router.get('/check-visitor/:fingerprint', async (req, res) => {
  try {
    const fingerprint = cleanText(req.params?.fingerprint, 120);
    if (!/^fp_[a-z0-9]+$/i.test(fingerprint)) {
      return res.status(400).json({ error: 'Invalid fingerprint format.' });
    }

    const lead = await Lead.findOne({ 
      where: { browserFingerprint: fingerprint, verified: true },
      order: [['updatedAt', 'DESC']]
    });
    
    if (lead) {
      // Update visit count if it's a new session (determined by frontend)
      await lead.update({ 
        returning_visitor: true,
        visit_count: lead.visit_count + 1
      });
      return res.json({ verified: true, lead_token: lead.lead_token, lead: { name: lead.name, email: lead.email, phone: lead.phone } });
    }
    
    res.json({ verified: false });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST save lead directly (without OTP verification)
router.post('/save-direct', async (req, res) => {
  try {
    const name = cleanText(req.body?.name, 120);
    const email = cleanEmail(req.body?.email);
    const sessionId = cleanText(req.body?.sessionId, 100);
    const browserFingerprint = cleanText(req.body?.browserFingerprint, 120);
    const phone = cleanText(req.body?.phone, 20);

    const normalizedPhone = normalizePhone(phone);
    const localPhone = normalizedPhone.startsWith('91') && normalizedPhone.length === 12
      ? normalizedPhone.slice(2)
      : normalizedPhone;

    if (!name || !localPhone) {
      await logAuditEvent({
        eventType: 'lead.save.direct.failed',
        actorType: 'lead',
        actorId: localPhone || null,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'missing_name_or_phone' }
      });
      return res.status(400).json({ error: 'Name and phone are required.' });
    }

    if (!isValidPhone(localPhone)) {
      await logAuditEvent({
        eventType: 'lead.save.direct.failed',
        actorType: 'lead',
        actorId: localPhone,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'invalid_phone' }
      });
      return res.status(400).json({ error: 'Please enter a valid 10-digit Indian mobile number.' });
    }

    // Generate lead token
    const leadToken = crypto.randomBytes(16).toString('hex');
    let timeSpent = 0;
    let visitedPages = '[]';
    
    if (sessionId) {
      const session = await VisitorSession.findOne({ where: { sessionId } });
      if (session) {
        timeSpent = session.timeSpent;
        visitedPages = session.visitedPages;
      }
    }

    // Create or update lead
    let lead = await Lead.findOne({ where: { phone: localPhone } });

    if (lead) {
      // Update existing lead
      await lead.update({
        name: name || lead.name,
        email: email || lead.email,
        browserFingerprint: browserFingerprint || lead.browserFingerprint,
        lead_token: leadToken,
        verified: true,
        status: lead.status || 'New'
      });
    } else {
      // Create new lead
      lead = await Lead.create({
        name,
        phone: localPhone,
        email,
        source: 'Direct Save',
        browserFingerprint,
        lead_token: leadToken,
        verified: true,
        status: 'New'
      });
    }

    await logAuditEvent({
      eventType: 'lead.save.direct.success',
      actorType: 'lead',
      actorId: localPhone,
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { source: 'Direct Save', leadId: lead.id }
    });

    const leadContext = await getLeadContext(lead);
    await maybeNotifyLeadIfHighInterest(lead, leadContext);

    res.json({ 
      success: true, 
      lead_token: leadToken,
      lead: {
        id: lead.id,
        name: lead.name,
        phone: lead.phone,
        email: lead.email
      }
    });
  } catch (err) {
    console.error('Error in save-direct:', err);
    await logAuditEvent({
      eventType: 'lead.save.direct.failed',
      actorType: 'lead',
      success: false,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { reason: 'exception', message: err.message }
    });
    res.status(500).json({ error: err.message });
  }
});

// POST send OTP to mobile
router.post('/send-otp', otpSendLimiter, async (req, res) => {
  try {
    const name = cleanText(req.body?.name, 120);
    const email = cleanEmail(req.body?.email);
    const sessionId = cleanText(req.body?.sessionId, 100);
    const browserFingerprint = cleanText(req.body?.browserFingerprint, 120);
    const phone = cleanText(req.body?.phone, 20);

    const normalizedPhone = normalizePhone(phone);
    const localPhone = normalizedPhone.startsWith('91') && normalizedPhone.length === 12
      ? normalizedPhone.slice(2)
      : normalizedPhone;

    if (!name || !localPhone) {
      await logAuditEvent({
        eventType: 'lead.otp.send.failed',
        actorType: 'lead',
        actorId: localPhone || null,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'missing_name_or_phone' }
      });
      return res.status(400).json({ error: 'Name and phone are required.' });
    }

    if (!isValidPhone(localPhone)) {
      await logAuditEvent({
        eventType: 'lead.otp.send.failed',
        actorType: 'lead',
        actorId: localPhone,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'invalid_phone' }
      });
      return res.status(400).json({ error: 'Please enter a valid 10-digit Indian mobile number.' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + OTP_TTL_MS);
    const otpHash = hashOtp(otp);

    let lead = await Lead.findOne({ where: { phone: localPhone } });

    if (lead) {
      await lead.update({ 
        name: name || lead.name,
        email: email || lead.email,
        otp: otpHash,
        otp_expiry: expiry,
        browserFingerprint: browserFingerprint || lead.browserFingerprint
      });
    } else {
      lead = await Lead.create({
        name,
        phone: localPhone,
        email,
        source: 'OTP Verification',
        otp: otpHash,
        otp_expiry: expiry,
        browserFingerprint,
        verified: false
      });
    }

    const whatsappResult = await sendOtpOnWhatsapp({ phone: localPhone, otp });

    await logAuditEvent({
      eventType: 'lead.otp.send.success',
      actorType: 'lead',
      actorId: localPhone,
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: {
        provider: whatsappResult.provider,
        fallback: whatsappResult.provider === 'fallback'
      }
    });

    res.json({ success: true, message: 'OTP sent successfully' });
  } catch (err) {
    await logAuditEvent({
      eventType: 'lead.otp.send.failed',
      actorType: 'lead',
      success: false,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { reason: 'exception', message: err.message }
    });
    res.status(500).json({ error: err.message });
  }
});

// POST verify OTP
router.post('/verify-otp', otpVerifyLimiter, async (req, res) => {
  try {
    const otp = cleanText(req.body?.otp, 10);
    const sessionId = cleanText(req.body?.sessionId, 100);
    const phone = cleanText(req.body?.phone, 20);

    const normalizedPhone = normalizePhone(phone);
    const localPhone = normalizedPhone.startsWith('91') && normalizedPhone.length === 12
      ? normalizedPhone.slice(2)
      : normalizedPhone;

    if (!isValidPhone(localPhone) || !/^\d{6}$/.test(String(otp || ''))) {
      await logAuditEvent({
        eventType: 'lead.otp.verify.failed',
        actorType: 'lead',
        actorId: localPhone || null,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'invalid_format' }
      });
      return res.status(400).json({ error: 'Invalid phone or OTP format.' });
    }

    const lead = await Lead.findOne({ where: { phone: localPhone } });

    if (!lead) {
      await logAuditEvent({
        eventType: 'lead.otp.verify.failed',
        actorType: 'lead',
        actorId: localPhone,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'lead_not_found' }
      });
      return res.status(404).json({ error: 'Lead not found' });
    }
    if (!lead.otp || hashOtp(otp) !== lead.otp) {
      await logAuditEvent({
        eventType: 'lead.otp.verify.failed',
        actorType: 'lead',
        actorId: localPhone,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'invalid_otp' }
      });
      return res.status(400).json({ error: 'Invalid OTP' });
    }
    if (new Date() > lead.otp_expiry) {
      await logAuditEvent({
        eventType: 'lead.otp.verify.failed',
        actorType: 'lead',
        actorId: localPhone,
        success: false,
        ip: req.ip,
        userAgent: req.headers['user-agent'],
        details: { reason: 'otp_expired' }
      });
      return res.status(400).json({ error: 'OTP expired' });
    }

    // Success -> Verify Lead
    const leadToken = crypto.randomBytes(16).toString('hex');
    let session = null;
    
    if (sessionId) {
      session = await VisitorSession.findOne({ where: { sessionId } });
    }

    await lead.update({
      verified: true,
      lead_token: leadToken,
      otp: null, // Clear OTP
      otp_expiry: null,
      visit_count: lead.visit_count + 1,
      returning_visitor: lead.visit_count > 0
    });

    // Calculate full context for notification (without double counting by summing dynamically)
    const sessions = await VisitorSession.findAll({ where: { browserFingerprint: lead.browserFingerprint } });
    const sessionPages = sessions.flatMap((s) => safeJsonParse(s.visitedPages, []));
    const leadPages = safeJsonParse(lead.visited_pages, []);
    const mergedPages = [...new Set([...leadPages, ...sessionPages])];
    const totalTimeSpent = (lead.timeSpent || 0) + sessions.reduce((acc, s) => acc + (s.timeSpent || 0), 0);

    await maybeNotifyLeadIfHighInterest(lead, {
      sessions,
      pages: mergedPages,
      totalTimeSpent,
      pdfViews: await PdfView.findAll({ where: { lead_id: lead.id }, include: [PdfDocument], order: [['createdAt', 'DESC']] })
    });

    await logAuditEvent({
      eventType: 'lead.otp.verify.success',
      actorType: 'lead',
      actorId: localPhone,
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent']
    });

    res.json({ success: true, lead_token: leadToken, lead: { name: lead.name, email: lead.email, phone: lead.phone } });
  } catch (err) {
    await logAuditEvent({
      eventType: 'lead.otp.verify.failed',
      actorType: 'lead',
      success: false,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { reason: 'exception', message: err.message }
    });
    res.status(500).json({ error: err.message });
  }
});

// POST verify lead from PDF lock (LEGACY - keeping for compatibility but redirecting to OTP flow or updating)
router.post('/verify', async (req, res) => {
  // We can keep this for direct verification if needed, or point it to OTP
  // For now, let's keep it but mark it as "Auto-verify" for convenience or remove it.
  // The user asked for OTP, so we should prioritize that.
  res.status(400).json({ error: 'Please use /send-otp and /verify-otp flow.' });
});

// POST track returning verified user
router.post('/track-returning', async (req, res) => {
  try {
    const leadToken = extractToken(req.headers['authorization']);
    if (!leadToken) return res.status(403).json({ error: 'Missing token' });

    const page = cleanPathFragment(req.body?.page, 120);
    const timeSpent = parsePositiveInt(req.body?.timeSpent, 5, 60);
    
    const lead = await Lead.findOne({ where: { lead_token: leadToken } });
    if (!lead) return res.status(404).json({ error: 'Lead not found' });

    let pages = JSON.parse(lead.visited_pages || '[]');
    if (page && !pages.includes(page)) {
      pages.push(page);
    }

    // Accumulate time spent
    const newTime = (lead.timeSpent || 0) + (timeSpent || 5);
    
    await lead.update({
      timeSpent: newTime,
      visited_pages: JSON.stringify(pages),
      last_contacted: new Date()
    });

    const leadContext = await getLeadContext(lead);
    await maybeNotifyLeadIfHighInterest(lead, leadContext);

    res.json({ success: true, lead: { name: lead.name, email: lead.email, phone: lead.phone } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET verify lead token (Public/Lead)
router.get('/verify-token', async (req, res) => {
  try {
    const leadToken = extractToken(req.headers['authorization']);
    if (!leadToken) return res.status(401).json({ error: 'No token provided' });

    const lead = await Lead.findOne({ where: { lead_token: leadToken, verified: true } });
    if (!lead) {
      return res.status(404).json({ error: 'Lead session invalid or expired' });
    }

    res.json({ 
      valid: true, 
      lead: { 
        name: lead.name, 
        email: lead.email, 
        phone: lead.phone 
      } 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET export leads to Excel (Admin)
router.get('/export', verifyToken, async (req, res) => {
  try {
    const leads = await Lead.findAll({
      include: [{
        model: PdfView,
        include: [PdfDocument]
      }],
      order: [['createdAt', 'DESC']]
    });

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Leads');
    const sessionsSheet = workbook.addWorksheet('Visitor Sessions');
    const viewsSheet = workbook.addWorksheet('Document Views');

    worksheet.columns = [
      { header: 'Name', key: 'name', width: 20 },
      { header: 'Phone', key: 'phone', width: 15 },
      { header: 'Email', key: 'email', width: 25 },
      { header: 'Status', key: 'status', width: 15 },
      { header: 'Time Spent (s)', key: 'time_spent', width: 15 },
      { header: 'Source', key: 'source', width: 15 },
      { header: 'Visits', key: 'visit_count', width: 10 },
      { header: 'Total Sessions', key: 'total_sessions', width: 14 },
      { header: 'Document Views', key: 'document_views', width: 14 },
      { header: 'Pages Visited', key: 'pages_visited', width: 40 },
      { header: 'Created Date', key: 'createdAt', width: 20 },
      { header: 'Last Contacted', key: 'last_contacted', width: 20 }
    ];

    sessionsSheet.columns = [
      { header: 'Lead Name', key: 'lead_name', width: 20 },
      { header: 'Phone', key: 'phone', width: 15 },
      { header: 'Fingerprint', key: 'browserFingerprint', width: 24 },
      { header: 'Session ID', key: 'sessionId', width: 24 },
      { header: 'Time Spent (s)', key: 'timeSpent', width: 15 },
      { header: 'Visited Pages', key: 'visitedPages', width: 50 },
      { header: 'Created Date', key: 'createdAt', width: 20 }
    ];

    viewsSheet.columns = [
      { header: 'Lead Name', key: 'lead_name', width: 20 },
      { header: 'Phone', key: 'phone', width: 15 },
      { header: 'Document', key: 'document', width: 30 },
      { header: 'Category', key: 'category', width: 18 },
      { header: 'Viewed At', key: 'viewedAt', width: 20 },
      { header: 'Time Spent (s)', key: 'timeSpent', width: 15 }
    ];

    for (const lead of leads) {
      const context = await getLeadContext(lead);
      worksheet.addRow({
        name: lead.name,
        phone: lead.phone,
        email: lead.email,
        status: lead.status,
        time_spent: lead.timeSpent,
        source: lead.source,
        visit_count: lead.visit_count,
        total_sessions: context.total_sessions,
        document_views: context.pdf_view_count,
        pages_visited: context.pages.join(', '),
        createdAt: new Date(lead.createdAt).toLocaleString(),
        last_contacted: lead.last_contacted ? new Date(lead.last_contacted).toLocaleString() : ''
      });

      context.sessions.forEach((session) => {
        sessionsSheet.addRow({
          lead_name: lead.name,
          phone: lead.phone,
          browserFingerprint: lead.browserFingerprint,
          sessionId: session.sessionId,
          timeSpent: session.timeSpent,
          visitedPages: session.visitedPages,
          createdAt: new Date(session.createdAt).toLocaleString()
        });
      });

      context.pdfViews.forEach((view) => {
        viewsSheet.addRow({
          lead_name: lead.name,
          phone: lead.phone,
          document: view.PdfDocument?.title || 'Document',
          category: view.PdfDocument?.category || '',
          viewedAt: new Date(view.createdAt).toLocaleString(),
          timeSpent: view.time_spent || 0
        });
      });
    }
    
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=' + 'leads_export.xlsx');
    
    await workbook.xlsx.write(res);
    res.end();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST a new lead (Public)
router.post('/', async (req, res) => {
  try {
    const name = cleanText(req.body?.name, 120);
    const email = cleanEmail(req.body?.email);
    const source = cleanText(req.body?.source, 80);
    const sessionId = cleanText(req.body?.sessionId, 100);
    const phone = cleanText(req.body?.phone, 20);

    const normalizedPhone = normalizePhone(phone);
    const localPhone = normalizedPhone.startsWith('91') && normalizedPhone.length === 12
      ? normalizedPhone.slice(2)
      : normalizedPhone;

    if (!name || !isValidPhone(localPhone)) {
      return res.status(400).json({ error: 'Valid name and phone are required.' });
    }

    let timeSpent = 0;
    let visitedPages = '[]';
    
    if (sessionId) {
      const session = await VisitorSession.findOne({ where: { sessionId } });
      if (session) {
        timeSpent = session.timeSpent;
        visitedPages = session.visitedPages;
      }
    }
    
    const lead = await Lead.create({
      name,
      phone: localPhone,
      email,
      source: source || 'Website',
      timeSpent,
      visited_pages: visitedPages
    });

    await maybeNotifyLeadIfHighInterest(lead, { pages: safeJsonParse(visitedPages, []), totalTimeSpent: timeSpent });
    
    res.status(201).json(lead);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT update lead status (Admin)
router.put('/:id/status', verifyToken, async (req, res) => {
  try {
    const status = cleanText(req.body?.status, 40);
    if (!ALLOWED_LEAD_STATUSES.has(status)) {
      return res.status(400).json({ error: 'Invalid lead status' });
    }

    const lead = await Lead.findByPk(req.params.id);
    if (!lead) return res.status(404).json({ error: 'Lead not found' });
    
    await lead.update({ status, last_contacted: new Date() });

    await maybeNotifyLeadIfHighInterest(lead);

    await logAuditEvent({
      eventType: 'lead.status.updated',
      actorType: 'admin',
      actorId: req.user?.role || 'admin',
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { leadId: lead.id, status }
    });

    res.json(lead);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// PUT update lead notes (Admin)
router.put('/:id/notes', verifyToken, async (req, res) => {
  try {
    const notes = cleanText(req.body?.notes, 2000);
    const lead = await Lead.findByPk(req.params.id);
    if (!lead) return res.status(404).json({ error: 'Lead not found' });
    
    await lead.update({ notes });

    await logAuditEvent({
      eventType: 'lead.notes.updated',
      actorType: 'admin',
      actorId: req.user?.role || 'admin',
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { leadId: lead.id }
    });

    res.json(lead);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE a lead (Admin)
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const lead = await Lead.findByPk(req.params.id);
    if (!lead) return res.status(404).json({ error: 'Lead not found' });
    await lead.destroy();

    await logAuditEvent({
      eventType: 'lead.deleted',
      actorType: 'admin',
      actorId: req.user?.role || 'admin',
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { leadId: req.params.id }
    });

    res.json({ message: 'Lead deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET WhatsApp URL for a lead (Admin)
router.get('/:id/whatsapp-url', verifyToken, async (req, res) => {
  try {
    const lead = await Lead.findByPk(req.params.id);
    if (!lead) return res.status(404).json({ error: 'Lead not found' });
    
    const url = await buildManualWhatsAppMessage(lead);
    res.json({ url });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST log WhatsApp activity (Admin)
router.post('/:id/whatsapp-log', verifyToken, async (req, res) => {
  try {
    const leadId = req.params.id;
    const messageSent = req.body?.message_sent !== false;
    
    const log = await logWhatsAppActivity({ 
      leadId, 
      messageSent, 
      messageType: 'manual' 
    });

    await logAuditEvent({
      eventType: 'lead.whatsapp.manual_click',
      actorType: 'admin',
      actorId: req.user?.role || 'admin',
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { leadId, logId: log.id }
    });

    res.json({ success: true, log });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
