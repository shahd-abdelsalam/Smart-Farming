import mongoose from "mongoose";
import { env } from "./env.js";

const connectDB = async () => {
  try {
    await mongoose.connect(env.MONGO_URI);
    console.log("MongoDB Connected");
  } catch (err) {
    console.log("Mongo Error:", err.message);
    process.exit(1);
  }
};

export default connectDB;