const express = require('express');
const router = express.Router();
const { Setting } = require('../models');
const { verifyToken } = require('./auth');
const { logAuditEvent } = require('../services/auditLogger');
const { cleanText } = require('../utils/sanitize');

// GET all business settings
router.get('/', verifyToken, async (req, res) => {
  try {
    const settings = await Setting.findAll({
      where: { category: 'business_details' }
    });
    
    // Convert array to object for easier frontend use
    const config = {};
    settings.forEach(s => {
      config[s.key] = s.value;
    });
    
    res.json(config);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST update settings
router.post('/', verifyToken, async (req, res) => {
  try {
    const updates = req.body; // { key: value, ... }
    
    for (const [key, value] of Object.entries(updates)) {
      const cleanValue = cleanText(String(value), 500);
      
      const [setting, created] = await Setting.findOrCreate({
        where: { key },
        defaults: { value: cleanValue, category: 'business_details' }
      });
      
      if (!created) {
        await setting.update({ value: cleanValue });
      }
    }

    await logAuditEvent({
      eventType: 'settings.updated',
      actorType: 'admin',
      actorId: req.user?.role || 'admin',
      success: true,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      details: { keys: Object.keys(updates) }
    });

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
