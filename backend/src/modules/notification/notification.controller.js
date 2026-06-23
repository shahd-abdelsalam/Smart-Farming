import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import { validateNotificationListQuery } from "./notification.validation.js";
import {
  getNotificationsForUserService,
  getUnreadNotificationsCountService,
  markNotificationAsReadService,
  markAllNotificationsAsReadService,
  deleteNotificationByIdService,
  resolveNotificationByIdService,
} from "./notification.service.js";

export const getNotificationsController = asyncHandler(async (req, res) => {
  const ownerId = req.userId;
  const query = validateNotificationListQuery(req.query);

  const data = await getNotificationsForUserService({
    ownerId,
    ...query,
  });

  return res.status(200).json(
    new ApiResponse(true, data, "Notifications fetched successfully")
  );
});

export const getUnreadNotificationsCountController = asyncHandler(
  async (req, res) => {
    const ownerId = req.userId;
    const unreadCount = await getUnreadNotificationsCountService(ownerId);

    return res.status(200).json(
      new ApiResponse(
        true,
        { unreadCount },
        "Unread notification count fetched successfully"
      )
    );
  }
);

export const markNotificationAsReadController = asyncHandler(
  async (req, res) => {
    const ownerId = req.userId;
    const notificationId = req.params.id;

    const data = await markNotificationAsReadService({
      notificationId,
      ownerId,
    });

    return res.status(200).json(
      new ApiResponse(true, data, "Notification marked as read successfully")
    );
  }
);

export const markAllNotificationsAsReadController = asyncHandler(
  async (req, res) => {
    const ownerId = req.userId;

    await markAllNotificationsAsReadService(ownerId);

    return res.status(200).json(
      new ApiResponse(true, null, "All notifications marked as read successfully")
    );
  }
);

export const deleteNotificationController = asyncHandler(async (req, res) => {
  const ownerId = req.userId;
  const notificationId = req.params.id;

  await deleteNotificationByIdService({
    notificationId,
    ownerId,
  });

  return res.status(200).json(
    new ApiResponse(true, null, "Notification deleted successfully")
  );
});

export const resolveNotificationController = asyncHandler(async (req, res) => {
  const ownerId = req.userId;
  const notificationId = req.params.id;

  const data = await resolveNotificationByIdService({
    notificationId,
    ownerId,
  });

  return res.status(200).json(
    new ApiResponse(true, data, "Notification resolved successfully")
  );
});