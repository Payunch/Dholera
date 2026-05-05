const { sequelize } = require('./models');

async function sync() {
  try {
    await sequelize.sync({ alter: true });
    console.log("Database altered successfully");
  } catch(e) {
    console.error(e);
  }
}

sync();
