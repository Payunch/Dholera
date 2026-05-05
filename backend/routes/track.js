const express = require('express');
const router = express.Router();
const { VisitorSession } = require('../models');

// POST /api/track
router.post('/', async (req, res) => {
  try {
    const { sessionId, page, timeSpent, source, deviceType, browserFingerprint } = req.body;
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    
    if (!sessionId) return res.status(400).json({ error: 'sessionId required' });

    let [session, created] = await VisitorSession.findOrCreate({
      where: { sessionId },
      defaults: {
        timeSpent: 0,
        visitedPages: JSON.stringify([]),
        source,
        deviceType,
        browserFingerprint,
        ip
      }
    });

    // If session was already there, but fingerprint was missing, update it
    if (!created && browserFingerprint && !session.browserFingerprint) {
      session.browserFingerprint = browserFingerprint;
    }

    let pages = JSON.parse(session.visitedPages || '[]');
    if (page && !pages.includes(page)) {
      pages.push(page);
    }

    session.timeSpent = (session.timeSpent || 0) + (timeSpent || 5);
    session.visitedPages = JSON.stringify(pages);
    await session.save();

    res.json(session);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
