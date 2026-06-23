import mongoose from "mongoose";

const recommendationScheduleSchema = new mongoose.Schema(
  {
    day: {
      type: String,
      required: true,
      trim: true,
    },
    action: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { _id: false }
);

const recommendationDetailsSchema = new mongoose.Schema(
  {
    schedule: {
      type: [recommendationScheduleSchema],
      default: [],
    },
    notes: {
      type: [String],
      default: [],
    },
  },
  { _id: false }
);

const recommendationMetaSchema = new mongoose.Schema(
  {
    soilMoisture: { type: Number, default: null },
    soilType: { type: String, default: null },
    irrigationType: { type: String, default: null },
    growthStage: { type: String, default: null },
    weatherCondition: { type: String, default: null },
    temperature: { type: Number, default: null },
    humidity: { type: Number, default: null },
    scanId: { type: mongoose.Schema.Types.ObjectId, ref: "Scan", default: null },
    scanDisease: { type: String, default: null },
    scanConfidence: { type: Number, default: null },
  },
  { _id: false }
);

const recommendationSchema = new mongoose.Schema(
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

    type: {
      type: String,
      enum: ["irrigation", "fertilization", "disease"],
      required: true,
      index: true,
    },

    title: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      required: true,
      trim: true,
    },

    reason: {
      type: String,
      required: true,
      trim: true,
    },

    action: {
      type: String,
      required: true,
      trim: true,
    },

    priority: {
      type: String,
      enum: ["high", "medium", "low"],
      default: "low",
      index: true,
    },

    status: {
      type: String,
      enum: ["pending", "done", "dismissed", "expired"],
      default: "pending",
      index: true,
    },

    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },

    source: {
      type: [String],
      default: [],
    },

    meta: {
      type: recommendationMetaSchema,
      default: () => ({}),
    },

    details: {
      type: recommendationDetailsSchema,
      default: () => ({ schedule: [], notes: [] }),
    },

    validUntil: {
      type: Date,
      required: true,
      index: true,
    },

    lastTriggeredAt: {
      type: Date,
      default: Date.now,
    },

    resolvedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

recommendationSchema.index({ ownerId: 1, status: 1, isActive: 1 });
recommendationSchema.index({ farmId: 1, type: 1, status: 1 });

const Recommendation = mongoose.model("Recommendation", recommendationSchema);

export default Recommendation;