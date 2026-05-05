const express = require('express');
const router = express.Router();
const { Analytics } = require('../models');
const { verifyToken } = require('./auth');

// GET analytics data (Admin)
router.get('/', verifyToken, async (req, res) => {
  try {
    const data = await Analytics.findAll({ order: [['date', 'ASC']] });
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
