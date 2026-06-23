import {
  DEFAULT_NOTIFICATION_LIMIT,
  MAX_NOTIFICATION_LIMIT,
  NOTIFICATION_SEVERITIES,
  NOTIFICATION_STATUSES,
  NOTIFICATION_TYPES,
} from "./notification.constants.js";
import { clampNumber, toBoolean } from "./notification.utils.js";

export const validateNotificationListQuery = (query) => {
  const page = clampNumber(query.page, 1, 100000, 1);
  const limit = clampNumber(
    query.limit,
    1,
    MAX_NOTIFICATION_LIMIT,
    DEFAULT_NOTIFICATION_LIMIT
  );

  const type = query.type;
  const severity = query.severity;
  const status = query.status;
  const isRead = toBoolean(query.isRead);

  if (type && !Object.values(NOTIFICATION_TYPES).includes(type)) {
    throw new Error("Invalid notification type");
  }

  if (
    severity &&
    !Object.values(NOTIFICATION_SEVERITIES).includes(severity)
  ) {
    throw new Error("Invalid notification severity");
  }

  if (status && !Object.values(NOTIFICATION_STATUSES).includes(status)) {
    throw new Error("Invalid notification status");
  }

  return {
    page,
    limit,
    type,
    severity,
    status,
    isRead,
  };
};