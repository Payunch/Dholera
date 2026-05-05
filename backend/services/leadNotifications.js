let nodemailer = null;
try {
  // Optional dependency: email alerts degrade gracefully when SMTP or the package is unavailable.
  nodemailer = require('nodemailer');
} catch (err) {
  nodemailer = null;
}
const { sendLeadAlertOnWhatsapp } = require('./whatsapp');

const ADMIN_EMAIL_TO = (process.env.ADMIN_EMAIL_TO || '').split(',').map((value) => value.trim()).filter(Boolean);
const SMTP_HOST = process.env.SMTP_HOST;
const SMTP_PORT = Number.parseInt(process.env.SMTP_PORT || '587', 10);
const SMTP_SECURE = String(process.env.SMTP_SECURE || '').toLowerCase() === 'true';
const SMTP_USER = process.env.SMTP_USER;
const SMTP_PASS = process.env.SMTP_PASS;
const SMTP_FROM = process.env.SMTP_FROM || SMTP_USER || 'alerts@dholera.local';
const WHATSAPP_ALERT_NUMBERS = (process.env.ADMIN_WHATSAPP_NUMBERS || '').split(',').map((value) => value.trim()).filter(Boolean);
const WHATSAPP_ALERT_TEMPLATE_NAME = process.env.WHATSAPP_LEAD_ALERT_TEMPLATE_NAME || 'lead_alert';
const WHATSAPP_ALERT_LANGUAGE = process.env.WHATSAPP_LEAD_ALERT_LANGUAGE || process.env.WHATSAPP_TEMPLATE_LANGUAGE || 'en';

const createMailer = () => {
  if (!SMTP_HOST || !SMTP_USER || !SMTP_PASS) return null;
  return nodemailer.createTransport({
    host: SMTP_HOST,
    port: SMTP_PORT,
    secure: SMTP_SECURE,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS
    }
  });
};

const mailer = createMailer();

const isHighInterestLead = (lead = {}) => {
  const visitCount = Number.parseInt(lead.visit_count || lead.visitCount || 0, 10);
  const timeSpent = Number.parseInt(lead.timeSpent || 0, 10);
  const returningVisitor = Boolean(lead.returning_visitor);
  const pdfViews = Number.parseInt(lead.pdf_view_count || lead.pdfViewCount || 0, 10);
  return visitCount >= 3 || timeSpent >= 300 || returningVisitor || pdfViews >= 3;
};

const buildLeadSummary = (lead = {}, context = {}) => {
  const createdAt = lead.createdAt ? new Date(lead.createdAt).toLocaleString() : 'Unknown';
  const status = lead.status || 'New';
  const pages = Array.isArray(context.pages) ? context.pages : [];
  const sessions = Array.isArray(context.sessions) ? context.sessions : [];
  const views = Array.isArray(context.views) ? context.views : [];

  return [
    `Name: ${lead.name || 'Unknown'}`,
    `Phone: ${lead.phone || 'Unknown'}`,
    `Email: ${lead.email || 'N/A'}`,
    `Status: ${status}`,
    `Created: ${createdAt}`,
    `Visits: ${lead.visit_count || 0}`,
    `Time Spent: ${Math.round((lead.timeSpent || 0) / 60)} min`,
    `Pages: ${pages.length ? pages.join(', ') : 'None'}`,
    `Sessions: ${sessions.length}`,
    `Document Views: ${views.length}`
  ].join('\n');
};

const sendAdminWhatsAppAlert = async (lead, context = {}) => {
  if (!WHATSAPP_ALERT_NUMBERS.length) {
    return { sent: false, reason: 'missing_admin_numbers' };
  }

  const payloadText = `High-interest lead identified:\n${buildLeadSummary(lead, context)}`;
  const results = [];

  for (const phone of WHATSAPP_ALERT_NUMBERS) {
    try {
      const response = await sendLeadAlertOnWhatsapp({ phone, lead });
      results.push({ phone, sent: response.sent, provider: response.provider, messageId: response.messageId });
    } catch (err) {
      results.push({ phone, sent: false, error: err.message });
    }
  }

  return { sent: results.some((item) => item.sent), results };
};

const sendAdminEmailAlert = async (lead, context = {}) => {
  if (!mailer || !ADMIN_EMAIL_TO.length) {
    return { sent: false, reason: 'missing_smtp_or_recipient' };
  }

  const subject = `High-interest lead: ${lead.name || lead.phone || 'new inquiry'}`;
  const text = buildLeadSummary(lead, context);
  const html = text.replace(/\n/g, '<br/>');

  await mailer.sendMail({
    from: SMTP_FROM,
    to: ADMIN_EMAIL_TO.join(', '),
    subject,
    text,
    html
  });

  return { sent: true };
};

const maybeNotifyHighInterestLead = async (lead, context = {}) => {
  if (!lead || !isHighInterestLead(lead)) {
    return { notified: false, reason: 'not_high_interest' };
  }

  const result = { notified: false, whatsapp: null, email: null };

  if (!lead.high_interest_whatsapp_notified_at) {
    try {
      result.whatsapp = await sendAdminWhatsAppAlert(lead, context);
      result.notified = result.whatsapp?.sent || result.notified;
    } catch (err) {
      result.whatsapp = { sent: false, error: err.message };
    }
  }

  if (!lead.high_interest_email_notified_at) {
    try {
      result.email = await sendAdminEmailAlert(lead, context);
      result.notified = result.email?.sent || result.notified;
    } catch (err) {
      result.email = { sent: false, error: err.message };
    }
  }

  return result;
};

module.exports = {
  isHighInterestLead,
  maybeNotifyHighInterestLead,
  sendAdminWhatsAppAlert,
  sendAdminEmailAlert,
  buildLeadSummary
};