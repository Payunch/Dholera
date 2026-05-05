const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const { PdfDocument, PdfView, Lead } = require('../models');

// GET list of PDFs
router.get('/list', async (req, res) => {
  try {
    const pdfs = await PdfDocument.findAll({
      attributes: ['id', 'title', 'category'] // don't expose file_path
    });
    res.json(pdfs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET secure PDF stream
router.get('/view/:id', async (req, res) => {
  try {
    // Accept either raw token or "Bearer <token>"
    let leadToken = req.headers['authorization'] || '';
    if (!leadToken) {
      return res.status(403).json({ error: 'Verification required to view this document.' });
    }
    if (leadToken.toLowerCase().startsWith('bearer ')) {
      leadToken = leadToken.slice(7).trim();
    }

    const lead = await Lead.findOne({ where: { lead_token: leadToken } });
    if (!lead || !lead.verified) {
      return res.status(403).json({ error: 'Invalid or unverified lead token.' });
    }

    const pdf = await PdfDocument.findByPk(req.params.id);
    if (!pdf) {
      return res.status(404).json({ error: 'PDF not found.' });
    }

    // Record view - handle potential column name mismatch by using association method if possible or being careful
    try {
      await PdfView.create({
        lead_id: lead.id,
        pdf_id: pdf.id
      });
    } catch (viewErr) {
      console.error('Error recording PDF view:', viewErr.message);
      // Continue even if view recording fails, so the user can see the PDF
    }

    // Update lead returning status
    const viewCount = await PdfView.count({ where: { lead_id: lead.id } });
    if (viewCount > 1 && !lead.returning_visitor) {
      await lead.update({ returning_visitor: true });
    }

    // Resolve the file path safely under backend/uploads
    const uploadsDir = path.resolve(__dirname, '..', 'uploads');
    const resolved = path.resolve(__dirname, '..', pdf.file_path || '');

    // Prevent directory traversal - ensure resolved path is under uploadsDir
    if (!resolved.startsWith(uploadsDir)) {
      console.error('Attempted access outside uploads dir:', resolved);
      return res.status(400).json({ error: 'Invalid document path.' });
    }

    if (!fs.existsSync(resolved)) {
      console.error('File not found at path:', resolved);
      return res.status(404).json({ error: 'Document file missing on server.' });
    }

    res.sendFile(resolved, {
      headers: {
        'Content-Type': 'application/pdf',
        'Cache-Control': 'no-store, no-cache, must-revalidate, private'
      }
    });

  } catch (err) {
    console.error('PDF View Error:', err);
    res.status(500).json({ error: 'Internal server error while loading document.' });
  }
});

module.exports = router;
