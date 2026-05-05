const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PdfDocument = sequelize.define('PdfDocument', {
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  category: {
    type: DataTypes.STRING,
    allowNull: true
  },
  file_path: {
    type: DataTypes.STRING,
    allowNull: false
  },
  is_protected: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
});

module.exports = PdfDocument;
