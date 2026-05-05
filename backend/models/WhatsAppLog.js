const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const WhatsAppLog = sequelize.define('WhatsAppLog', {
  lead_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  message_sent: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: true
  },
  message_type: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'manual'
  },
  template_name: {
    type: DataTypes.STRING,
    allowNull: true
  },
  status: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: 'clicked'
  }
});

module.exports = WhatsAppLog;
