const crypto = require('crypto');
const { Lead, WhatsAppLog, Setting } = require('../models');

// WhatsApp Cloud API Configuration
const WHATSAPP_API_VERSION = process.env.WHATSAPP_API_VERSION || 'v25.0';
const WHATSAPP_PHONE_NUMBER_ID = process.env.WHATSAPP_PHONE_NUMBER_ID;
const WHATSAPP_ACCESS_TOKEN = process.env.WHATSAPP_ACCESS_TOKEN;

// Template Names (Should be configured in Meta Dashboard)
const WHATSAPP_OTP_TEMPLATE_NAME = process.env.WHATSAPP_OTP_TEMPLATE_NAME || 'otp_verification';
const WHATSAPP_LEAD_ALERT_TEMPLATE_NAME = process.env.WHATSAPP_LEAD_ALERT_TEMPLATE_NAME || 'lead_alert';
const WHATSAPP_TEMPLATE_LANGUAGE = process.env.WHATSAPP_TEMPLATE_LANGUAGE || 'en_US';

const canSendRealWhatsapp = () => Boolean(WHATSAPP_PHONE_NUMBER_ID && WHATSAPP_ACCESS_TOKEN);

/**
 * Normalizes phone number to WhatsApp format (e.g., 91XXXXXXXXXX)
 */
const normalizePhone = (phone) => {
  if (!phone) return '';
  const digits = String(phone).replace(/\D/g, '');
  // Default to India (91) if 10 digits provided
  if (digits.length === 10) return `91${digits}`;
  return digits;
};

/**
 * Get business settings for WhatsApp messages
 */
const getBusinessSettings = async () => {
  const settings = await Setting.findAll({
    where: { category: 'business_details' }
  });

  const config = {
    site_owner_name: 'Naresh Gohel',
    phone: '7435808031',
    email: 'gohelnaresh7707@gmail.com',
    facebook: '',
    instagram: '',
    twitter: ''
  };

  settings.forEach(s => {
    if (config.hasOwnProperty(s.key)) {
      config[s.key] = s.value;
    }
  });

  return config;
};

/**
 * Build a manual WhatsApp message link (wa.me) for cases where API isn't used
 */
const buildManualWhatsAppMessage = async (lead) => {
  const config = await getBusinessSettings();
  const phone = normalizePhone(lead.phone);
  
  const greeting = lead.name ? `Hello ${lead.name}! 👋` : 'Hello! 👋';
  
  let interestMsg = 'We noticed your interest in our planning maps and projects.';
  if (lead.visited_pages) {
    try {
      const pages = JSON.parse(lead.visited_pages);
      if (pages && pages.length > 0) {
        const pageNames = pages.slice(0, 2).map(p => {
          return p.replace(/^\//, '').replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        }).join(' and ');
        interestMsg = `We noticed you were recently looking at ${pageNames} plans on our website.`;
      }
    } catch (e) {}
  }

  const message = `${greeting}

Thank you for your interest in Dholera Smart City.

Site Owner: ${config.site_owner_name}  
📞 ${config.phone}  
📧 ${config.email}  

${interestMsg}

Let us know if you would like:
✔ Site visit  
✔ Plot details  
✔ Investment guidance  

Regards,  
Dholera Team`;

  const encodedMessage = encodeURIComponent(message);
  return `https://wa.me/${phone}?text=${encodedMessage}`;
};

/**
 * Log WhatsApp activity to database
 */
const logWhatsAppActivity = async ({ leadId, messageSent, messageType = 'manual', templateName = null }) => {
  const log = await WhatsAppLog.create({
    lead_id: leadId,
    message_sent: messageSent,
    message_type: messageType,
    template_name: templateName,
    status: messageSent ? 'sent' : 'failed'
  });

  if (messageSent) {
    const lead = await Lead.findByPk(leadId);
    if (lead) {
      await lead.update({
        whatsapp_sent_count: (lead.whatsapp_sent_count || 0) + 1,
        last_whatsapp_sent: new Date(),
        status: lead.status === 'New' ? 'Contacted' : lead.status
      });
    }
  }

  return log;
};

/**
 * Sends a template message using WhatsApp Cloud API
 */
const sendTemplateMessage = async ({ phone, templateName, languageCode = WHATSAPP_TEMPLATE_LANGUAGE, parameters = [] }) => {
  const normalizedPhone = normalizePhone(phone);

  if (!canSendRealWhatsapp()) {
    console.warn(`WhatsApp API credentials missing. Falling back to log for ${normalizedPhone}.`);
    return { sent: false, provider: 'fallback', messageId: crypto.randomUUID() };
  }

  const url = `https://graph.facebook.com/${WHATSAPP_API_VERSION}/${WHATSAPP_PHONE_NUMBER_ID}/messages`;

  const payload = {
    messaging_product: 'whatsapp',
    to: normalizedPhone,
    type: 'template',
    template: {
      name: templateName,
      language: { code: languageCode },
      components: [
        {
          type: 'body',
          parameters: parameters.map((text) => ({ type: 'text', text: String(text) }))
        }
      ]
    }
  };

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${WHATSAPP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const data = await response.json();
    
    if (!response.ok) {
      console.error('WhatsApp API Error:', data);
      throw new Error(data?.error?.message || 'Failed to send WhatsApp message');
    }

    return {
      sent: true,
      provider: 'whatsapp-cloud-api',
      messageId: data?.messages?.[0]?.id || null
    };
  } catch (err) {
    console.error('WhatsApp Service Exception:', err.message);
    return { sent: false, error: err.message };
  }
};

/**
 * Specialized: Send OTP
 */
const sendOtpOnWhatsapp = async ({ phone, otp }) => {
  return sendTemplateMessage({
    phone,
    templateName: WHATSAPP_OTP_TEMPLATE_NAME,
    parameters: [otp]
  });
};

/**
 * Specialized: Send Lead Alert to Admin
 */
const sendLeadAlertOnWhatsapp = async ({ phone, lead }) => {
  const parameters = [
    lead?.name || 'New Lead',
    lead?.phone || 'N/A',
    new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })
  ];

  return sendTemplateMessage({
    phone,
    templateName: WHATSAPP_LEAD_ALERT_TEMPLATE_NAME,
    parameters
  });
};

module.exports = {
  sendOtpOnWhatsapp,
  sendLeadAlertOnWhatsapp,
  sendTemplateMessage,
  normalizePhone,
  getBusinessSettings,
  buildManualWhatsAppMessage,
  logWhatsAppActivity
};