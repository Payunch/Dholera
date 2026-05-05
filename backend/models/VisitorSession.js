const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const VisitorSession = sequelize.define('VisitorSession', {
  sessionId: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  timeSpent: {
    type: DataTypes.INTEGER, // in seconds
    defaultValue: 0
  },
  visitedPages: {
    type: DataTypes.TEXT, // Storing as JSON string array
    defaultValue: '[]'
  },
  source: {
    type: DataTypes.STRING,
    allowNull: true
  },
  deviceType: {
    type: DataTypes.STRING,
    allowNull: true
  },
  browserFingerprint: {
    type: DataTypes.STRING,
    allowNull: true
  },
  ip: {
    type: DataTypes.STRING,
    allowNull: true
  }
});

module.exports = VisitorSession;
