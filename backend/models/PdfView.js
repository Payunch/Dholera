const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PdfView = sequelize.define('PdfView', {
  viewed_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  time_spent: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
});

module.exports = PdfView;
