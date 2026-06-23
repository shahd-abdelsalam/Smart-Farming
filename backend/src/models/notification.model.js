import mongoose from "mongoose";
import {
  NOTIFICATION_ACTION_TYPES,
  NOTIFICATION_CATEGORIES,
  NOTIFICATION_SEVERITIES,
  NOTIFICATION_STATUSES,
  NOTIFICATION_TYPES,
} from "../modules/notification/notification.constants.js";

const notificationSchema = new mongoose.Schema(
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
      default: null,
      index: true,
    },

    type: {
      type: String,
      enum: Object.values(NOTIFICATION_TYPES),
      required: true,
      index: true,
    },

    category: {
      type: String,
      enum: Object.values(NOTIFICATION_CATEGORIES),
      required: true,
      index: true,
    },

    sourceModule: {
      type: String,
      required: true,
      trim: true,
    },

    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 120,
    },

    message: {
      type: String,
      required: true,
      trim: true,
      maxlength: 500,
    },

    severity: {
      type: String,
      enum: Object.values(NOTIFICATION_SEVERITIES),
      default: NOTIFICATION_SEVERITIES.MEDIUM,
      index: true,
    },

    priorityScore: {
      type: Number,
      default: 50,
    },

    status: {
      type: String,
      enum: Object.values(NOTIFICATION_STATUSES),
      default: NOTIFICATION_STATUSES.ACTIVE,
      index: true,
    },

    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },

    readAt: {
      type: Date,
      default: null,
    },

    actionType: {
      type: String,
      enum: Object.values(NOTIFICATION_ACTION_TYPES),
      default: NOTIFICATION_ACTION_TYPES.NONE,
    },

    actionLabel: {
      type: String,
      default: null,
      trim: true,
      maxlength: 80,
    },

    relatedModel: {
      type: String,
      default: null,
      trim: true,
    },

    relatedId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null,
    },

    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },

    dedupeKey: {
      type: String,
      default: null,
      index: true,
    },

    expiresAt: {
      type: Date,
      default: null,
      index: true,
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

notificationSchema.index({ ownerId: 1, createdAt: -1 });
notificationSchema.index({ ownerId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ ownerId: 1, status: 1, createdAt: -1 });
notificationSchema.index({ farmId: 1, type: 1, createdAt: -1 });
notificationSchema.index({ ownerId: 1, dedupeKey: 1 });

const Notification =
  mongoose.models.Notification ||
  mongoose.model("Notification", notificationSchema);

export default Notification;