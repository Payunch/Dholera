const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Lead = sequelize.define('Lead', {
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: true
  },
  source: {
    type: DataTypes.STRING,
    allowNull: true,
    defaultValue: 'Website'
  },
  timeSpent: {
    type: DataTypes.INTEGER, // in seconds
    allowNull: true,
    defaultValue: 0
  },
  status: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'New' // New, Contacted, Converted, Follow-up, Not Interested, Closed
  },
  visited_pages: {
    type: DataTypes.TEXT, // Storing as JSON string
    allowNull: true
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  last_contacted: {
    type: DataTypes.DATE,
    allowNull: true
  },
  verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  returning_visitor: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  visit_count: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  },
  lead_token: {
    type: DataTypes.STRING,
    allowNull: true,
    unique: true
  },
  browserFingerprint: {
    type: DataTypes.STRING,
    allowNull: true
  },
  otp: {
    type: DataTypes.STRING,
    allowNull: true
  },
  otp_expiry: {
    type: DataTypes.DATE,
    allowNull: true
  },
  high_interest_whatsapp_notified_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  high_interest_email_notified_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  whatsapp_sent_count: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  last_whatsapp_sent: {
    type: DataTypes.DATE,
    allowNull: true
  }
});

module.exports = Lead;
