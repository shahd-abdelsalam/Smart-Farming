import mongoose from "mongoose";

const sensorDeviceSchema = new mongoose.Schema(
  {
    deviceId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    deviceToken: {
      type: String,
      required: true,
      trim: true,
    },
    farmId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farm",
      required: true,
      index: true,
    },
    sensorType: {
      type: String,
      enum: ["soil_moisture"],
      default: "soil_moisture",
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastSeenAt: {
      type: Date,
      default: null,
    },
    notes: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

const SensorDevice = mongoose.model("SensorDevice", sensorDeviceSchema);

export default SensorDevice;