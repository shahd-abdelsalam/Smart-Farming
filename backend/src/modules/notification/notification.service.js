import mongoose from "mongoose";
import Notification from "../../models/notification.model.js";
import {
  NOTIFICATION_STATUSES,
} from "./notification.constants.js";
import { notificationResponseMapper } from "./notification.utils.js";

export const createNotificationService = async (payload) => {
  const notification = await Notification.create(payload);
  return notification;
};

export const findActiveNotificationByDedupeKeyService = async ({
  ownerId,
  dedupeKey,
}) => {
  if (!ownerId || !dedupeKey) return null;

  return Notification.findOne({
    ownerId,
    dedupeKey,
    status: NOTIFICATION_STATUSES.ACTIVE,
  });
};

export const createOrIgnoreDuplicateNotificationService = async (payload) => {
  if (!payload?.dedupeKey) {
    return createNotificationService(payload);
  }

  const existing = await findActiveNotificationByDedupeKeyService({
    ownerId: payload.ownerId,
    dedupeKey: payload.dedupeKey,
  });

  if (existing) {
    return existing;
  }

  return createNotificationService(payload);
};

export const createNotificationsBulkService = async (payloads = []) => {
  if (!Array.isArray(payloads) || payloads.length === 0) return [];

  const results = [];

  for (const payload of payloads) {
    const created = await createOrIgnoreDuplicateNotificationService(payload);
    results.push(created);
  }

  return results;
};

export const getNotificationsForUserService = async ({
  ownerId,
  page = 1,
  limit = 10,
  type,
  severity,
  status,
  isRead,
}) => {
  const skip = (page - 1) * limit;

  const filter = {
    ownerId,
  };

  if (type) filter.type = type;
  if (severity) filter.severity = severity;
  if (status) filter.status = status;
  if (typeof isRead === "boolean") filter.isRead = isRead;

  const [items, totalItems, unreadCount] = await Promise.all([
    Notification.find(filter)
      .sort({ isRead: 1, priorityScore: -1, createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean(),
    Notification.countDocuments(filter),
    Notification.countDocuments({
      ownerId,
      isRead: false,
      status: NOTIFICATION_STATUSES.ACTIVE,
    }),
  ]);

  return {
    items: items.map(notificationResponseMapper),
    pagination: {
      page,
      limit,
      totalItems,
      totalPages: Math.ceil(totalItems / limit) || 1,
    },
    unreadCount,
  };
};

export const getUnreadNotificationsCountService = async (ownerId) => {
  const unreadCount = await Notification.countDocuments({
    ownerId,
    isRead: false,
    status: NOTIFICATION_STATUSES.ACTIVE,
  });

  return unreadCount;
};

export const markNotificationAsReadService = async ({
  notificationId,
  ownerId,
}) => {
  if (!mongoose.Types.ObjectId.isValid(notificationId)) {
    throw new Error("Invalid notification id");
  }

  const notification = await Notification.findOneAndUpdate(
    {
      _id: notificationId,
      ownerId,
    },
    {
      $set: {
        isRead: true,
        readAt: new Date(),
      },
    },
    { new: true }
  );

  if (!notification) {
    throw new Error("Notification not found");
  }

  return notificationResponseMapper(notification);
};

export const markAllNotificationsAsReadService = async (ownerId) => {
  await Notification.updateMany(
    {
      ownerId,
      isRead: false,
    },
    {
      $set: {
        isRead: true,
        readAt: new Date(),
      },
    }
  );

  return true;
};

export const deleteNotificationByIdService = async ({
  notificationId,
  ownerId,
}) => {
  if (!mongoose.Types.ObjectId.isValid(notificationId)) {
    throw new Error("Invalid notification id");
  }

  const deleted = await Notification.findOneAndDelete({
    _id: notificationId,
    ownerId,
  });

  if (!deleted) {
    throw new Error("Notification not found");
  }

  return true;
};

export const resolveNotificationByIdService = async ({
  notificationId,
  ownerId,
}) => {
  if (!mongoose.Types.ObjectId.isValid(notificationId)) {
    throw new Error("Invalid notification id");
  }

  const updated = await Notification.findOneAndUpdate(
    {
      _id: notificationId,
      ownerId,
    },
    {
      $set: {
        status: NOTIFICATION_STATUSES.RESOLVED,
        resolvedAt: new Date(),
      },
    },
    { new: true }
  );

  if (!updated) {
    throw new Error("Notification not found");
  }

  return notificationResponseMapper(updated);
};