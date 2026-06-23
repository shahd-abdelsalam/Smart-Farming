import mongoose from "mongoose";

const soilMoistureReadingSchema = new mongoose.Schema(
  {
    farmId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farm",
      required: true,
      index: true,
    },
    deviceId: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    moisturePercent: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    rawValue: {
      type: Number,
      default: null,
    },
    batteryVoltage: {
      type: Number,
      default: null,
    },
    temperature: {
      type: Number,
      default: null,
    },
    recordedAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    source: {
  type: String,
  enum: ["postman", "device", "simulator"],
  default: "device",
},
  },
  { timestamps: true }
);

soilMoistureReadingSchema.index({ farmId: 1, recordedAt: -1 });
soilMoistureReadingSchema.index({ deviceId: 1, recordedAt: -1 });

const SoilMoistureReading = mongoose.model(
  "SoilMoistureReading",
  soilMoistureReadingSchema
);

export default SoilMoistureReading;