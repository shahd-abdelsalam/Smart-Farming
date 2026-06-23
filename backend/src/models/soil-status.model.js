import mongoose from "mongoose";

const soilStatusSchema = new mongoose.Schema(
  {
    farmId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farm",
      required: true,
      unique: true,
      index: true,
    },
    latestMoisturePercent: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    latestRawValue: {
      type: Number,
      default: null,
    },
    latestDeviceId: {
      type: String,
      required: true,
    },
    latestRecordedAt: {
      type: Date,
      required: true,
    },
    status: {
      type: String,
      enum: ["dry", "optimal", "wet"],
      required: true,
    },
    recommendation: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

const SoilStatus = mongoose.model("SoilStatus", soilStatusSchema);

export default SoilStatus;