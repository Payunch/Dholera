const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Analytics = sequelize.define('Analytics', {
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
    unique: true
  },
  pageVisits: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  uniqueVisitors: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  avgSessionDuration: {
    type: DataTypes.FLOAT, // in seconds
    defaultValue: 0
  }
});

module.exports = Analytics;
