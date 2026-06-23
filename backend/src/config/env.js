import dotenv from "dotenv";

dotenv.config();

export const env = {
  PORT: process.env.PORT || 3000,
  MONGO_URI: process.env.MONGO_URI,
  JWT_SECRET: process.env.JWT_SECRET,
  NODE_ENV: process.env.NODE_ENV || "development",
  WEATHER_API_KEY: process.env.WEATHER_API_KEY,
  WEATHER_API_BASE_URL: process.env.WEATHER_API_BASE_URL,
  AI_SERVICE_BASE_URL: process.env.AI_SERVICE_BASE_URL,
};