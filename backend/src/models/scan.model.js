import mongoose from "mongoose";

const scanSchema = new mongoose.Schema(
  {
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    farmId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farm",
      required: true,
      index: true,
    },

    imageUrl: {
      type: String,
      required: true,
      trim: true,
    },

    source: {
      type: String,
      enum: ["camera", "gallery"],
      default: "camera",
    },

    predictedClass: {
      type: String,
      required: true,
      trim: true,
    },

    diseaseName: {
      type: String,
      required: true,
      trim: true,
    },

    confidence: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },

    description: {
      type: String,
      default: "",
      trim: true,
    },

    recommendedActions: {
      type: [String],
      default: [],
    },

    rawModelResponse: {
      type: mongoose.Schema.Types.Mixed,
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: function (doc, ret) {
        delete ret.__v;
        return ret;
      },
    },
  }
);

const Scan = mongoose.model("Scan", scanSchema);

export default Scan;