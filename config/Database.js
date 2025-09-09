import { Sequelize } from "sequelize";
import dotenv from "dotenv";
dotenv.config();

// Explicit values untuk debugging
// const dbHost = process.env.DB_HOST;
// const dbUsername = process.env.DB_USERNAME;
// const dbPassword = process.env.DB_PASSWORD;
// const dbDatabase = process.env.DB_DATABASE;
// const dbPort = parseInt(process.env.DB_PORT);

// development
const dbHost = process.env.DB_HOST || "127.0.0.1";
const dbUsername = process.env.DB_USERNAME || "postgres";
const dbPassword = process.env.DB_PASSWORD || "password";
const dbDatabase = process.env.DB_DATABASE || "db_bisnis_indonesia";
const dbPort = parseInt(process.env.DB_PORT) || 5432;

// Method 1: Connection string untuk debugging
const connectionString = `postgresql://${dbUsername}:${dbPassword}@${dbHost}:${dbPort}/${dbDatabase}`;

const db = new Sequelize(connectionString, {
  dialect: "postgres",
  logging: console.log, // Show all SQL queries
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
});

export default db;
