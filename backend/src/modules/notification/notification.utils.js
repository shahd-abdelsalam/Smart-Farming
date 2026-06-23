export const buildNotificationDedupeKey = (...parts) => {
  return parts
    .filter(Boolean)
    .map((part) => String(part).trim().toLowerCase().replace(/\s+/g, "_"))
    .join("_");
};

export const getTimeAgo = (date) => {
  const now = new Date();
  const createdAt = new Date(date);
  const diffMs = now - createdAt;

  const sec = Math.floor(diffMs / 1000);
  if (sec < 60) return `${sec}s ago`;

  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m ago`;

  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h ago`;

  const day = Math.floor(hr / 24);
  if (day < 7) return `${day}d ago`;

  const week = Math.floor(day / 7);
  if (week < 5) return `${week}w ago`;

  const month = Math.floor(day / 30);
  if (month < 12) return `${month}mo ago`;

  const year = Math.floor(day / 365);
  return `${year}y ago`;
};

export const toBoolean = (value) => {
  if (value === true || value === "true") return true;
  if (value === false || value === "false") return false;
  return undefined;
};

export const clampNumber = (value, min, max, fallback) => {
  const num = Number(value);
  if (Number.isNaN(num)) return fallback;
  return Math.min(Math.max(num, min), max);
};

export const notificationResponseMapper = (notification) => ({
  id: notification._id,
  ownerId: notification.ownerId,
  farmId: notification.farmId,
  type: notification.type,
  category: notification.category,
  sourceModule: notification.sourceModule,
  title: notification.title,
  message: notification.message,
  severity: notification.severity,
  priorityScore: notification.priorityScore,
  status: notification.status,
  isRead: notification.isRead,
  readAt: notification.readAt,
  actionType: notification.actionType,
  actionLabel: notification.actionLabel,
  relatedModel: notification.relatedModel,
  relatedId: notification.relatedId,
  metadata: notification.metadata || {},
  dedupeKey: notification.dedupeKey,
  expiresAt: notification.expiresAt,
  resolvedAt: notification.resolvedAt,
  createdAt: notification.createdAt,
  updatedAt: notification.updatedAt,
  timeAgo: getTimeAgo(notification.createdAt),
});

export const isSameDayUTC = (date) => {
  const d = new Date(date);
  return d.toISOString().slice(0, 10);
};