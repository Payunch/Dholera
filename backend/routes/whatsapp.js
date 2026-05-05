const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { verifyToken } = require('./auth');
const { WhatsAppLog, Lead } = require('../models');
const { sendTemplateMessage, logWhatsAppActivity } = require('../services/whatsapp');
const { logAuditEvent } = require('../services/auditLogger');

// Future API: Send single template message
router.post('/send', verifyToken, async (req, res) => {
  try {
    const { leadId, templateName, languageCode, parameters } = req.body;
    const lead = await Lead.findByPk(leadId);
    if (!lead) return res.status(404).json({ error: 'Lead not found' });

    // This would call the real WhatsApp Cloud API / Twilio
    const result = await sendTemplateMessage({
      phone: lead.phone,
      templateName,
      languageCode: languageCode || 'en',
      parameters: parameters || []
    });

    await logWhatsAppActivity({
      leadId,
      messageSent: result.sent,
      messageType: 'template',
      templateName
    });

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Future API: Send bulk messages
router.post('/bulk', verifyToken, async (req, res) => {
  // Logic for bulk sending via API
  res.status(501).json({ error: 'Bulk API not yet implemented. Use manual bulk for now.' });
});

// GET WhatsApp stats for analytics
router.get('/stats', verifyToken, async (req, res) => {
  try {
    const totalClicks = await WhatsAppLog.count({ where: { message_sent: true } });
    const leadsContacted = await Lead.count({ 
      where: { 
        whatsapp_sent_count: { [Op.gt]: 0 } 
      } 
    });
    const conversionsAfterWhatsApp = await Lead.count({
      where: {
        status: 'Converted',
        whatsapp_sent_count: { [Op.gt]: 0 }
      }
    });

    res.json({
      totalClicks,
      leadsContacted,
      conversionsAfterWhatsApp,
      responseRate: 'Manual tracking required' // As per requirement
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET WhatsApp logs for analytics
router.get('/logs', verifyToken, async (req, res) => {
  try {
    const logs = await WhatsAppLog.findAll({
      include: [{ model: Lead, attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      limit: 100
    });
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
