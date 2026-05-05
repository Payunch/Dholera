const express = require('express');
const router = express.Router();
const { Update } = require('../models');
const { verifyToken } = require('./auth');
const { Op } = require('sequelize');
const { cleanText } = require('../utils/sanitize');
const upload = require('../middleware/upload');

// GET all updates (Public, only published)
router.get('/', async (req, res) => {
  const { all } = req.query;
  const search = cleanText(req.query?.search, 120).replace(/[%_]/g, '');
  const where = {};

  if (search) {
    where[Op.or] = [
      { title: { [Op.like]: `%${search}%` } },
      { content: { [Op.like]: `%${search}%` } },
      { category: { [Op.like]: `%${search}%` } }
    ];
  }

  if (all === 'true') {
    return verifyToken(req, res, async () => {
      try {
        const updates = await Update.findAll({ where, order: [['createdAt', 'DESC']] });
        res.json(updates);
      } catch (err) {
        res.status(500).json({ error: err.message });
      }
    });
  }

  try {
    where.published = true;
    const updates = await Update.findAll({ where, order: [['createdAt', 'DESC']] });
    res.json(updates);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET single update
router.get('/:id', async (req, res) => {
  try {
    const update = await Update.findByPk(req.params.id);
    if (!update) return res.status(404).json({ error: 'Update not found' });
    res.json(update);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST a new update (Admin)
router.post('/', verifyToken, upload.single('image'), async (req, res) => {
  try {
    console.log('POST /api/updates - body:', req.body);
    console.log('POST /api/updates - file:', req.file);

    const { title, content, category, published } = req.body;
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    const updateData = {
      title: cleanText(title, 255),
      content: cleanText(content, 50000),
      category: cleanText(category, 100) || 'General',
      published: published === 'true' || published === true || published === '1'
    };

    if (req.file) {
      updateData.imageUrl = `/uploads/images/${req.file.filename}`;
    }

    const update = await Update.create(updateData);
    console.log('Update created successfully:', update.id);
    res.status(201).json(update);
  } catch (err) {
    console.error('Error creating update:', err);
    res.status(400).json({ error: err.message || 'Failed to create update' });
  }
});

// PUT update an update (Admin)
router.put('/:id', verifyToken, upload.single('image'), async (req, res) => {
  try {
    console.log(`PUT /api/updates/${req.params.id} - body:`, req.body);
    console.log(`PUT /api/updates/${req.params.id} - file:`, req.file);

    const update = await Update.findByPk(req.params.id);
    if (!update) return res.status(404).json({ error: 'Update not found' });

    const { title, content, category, published } = req.body;
    const updateData = {};
    
    if (title !== undefined) updateData.title = cleanText(title, 255);
    if (content !== undefined) updateData.content = cleanText(content, 50000);
    if (category !== undefined) updateData.category = cleanText(category, 100);
    
    if (published !== undefined) {
      updateData.published = published === 'true' || published === true || published === '1';
    }

    if (req.file) {
      updateData.imageUrl = `/uploads/images/${req.file.filename}`;
    }

    await update.update(updateData);
    console.log('Update updated successfully:', update.id);
    res.json(update);
  } catch (err) {
    console.error('Error updating update:', err);
    res.status(400).json({ error: err.message || 'Failed to update update' });
  }
});

// DELETE an update (Admin)
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const update = await Update.findByPk(req.params.id);
    if (!update) return res.status(404).json({ error: 'Update not found' });
    await update.destroy();
    res.json({ message: 'Update deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
