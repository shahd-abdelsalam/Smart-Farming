import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import {
  getMyProfileService,
  updateMyProfileService,
  updateMyLanguageService,
  updateMyNotificationsService,
  updateMyPasswordService,
  updateMyProfileImageService,
} from "./profile.service.js";
import {
  validateUpdateProfile,
  validateUpdateLanguage,
  validateUpdateNotifications,
  validateUpdatePassword,
} from "./profile.validation.js";

const formatUser = (user) => ({
  id: user._id,
  fullName: user.fullName,
  email: user.email,
  phoneNumber: user.phoneNumber,
  role: user.role,
  language: user.language,
  emailVerified: user.emailVerified,
  profileImage: user.profileImage,
  notificationsEnabled: user.notificationsEnabled,
  lastLoginAt: user.lastLoginAt,
  createdAt: user.createdAt,
  updatedAt: user.updatedAt,
});

export const getMyProfile = asyncHandler(async (req, res) => {
  const user = await getMyProfileService(req.userId);

  return res.status(200).json(
    new ApiResponse(true, "Profile fetched", {
      user: formatUser(user),
    })
  );
});

export const updateMyProfile = asyncHandler(async (req, res) => {
  const errors = validateUpdateProfile(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const user = await updateMyProfileService(req.userId, req.body);

  return res.status(200).json(
    new ApiResponse(true, "Profile updated", {
      user: formatUser(user),
    })
  );
});

export const updateMyLanguage = asyncHandler(async (req, res) => {
  const errors = validateUpdateLanguage(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const user = await updateMyLanguageService(req.userId, req.body.language);

  return res.status(200).json(
    new ApiResponse(true, "Language updated", {
      user: formatUser(user),
    })
  );
});

export const updateMyNotifications = asyncHandler(async (req, res) => {
  const errors = validateUpdateNotifications(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const user = await updateMyNotificationsService(
    req.userId,
    req.body.notificationsEnabled
  );

  return res.status(200).json(
    new ApiResponse(true, "Notifications updated", {
      user: formatUser(user),
    })
  );
});

export const updateMyPassword = asyncHandler(async (req, res) => {
  const errors = validateUpdatePassword(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  await updateMyPasswordService(req.userId, req.body);

  return res.status(200).json(
    new ApiResponse(true, "Password updated")
  );
});

export const updateMyProfileImage = asyncHandler(async (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      message: "Image file is required",
    });
  }

  const filePath = `/uploads/profile-images/${req.file.filename}`;
  const user = await updateMyProfileImageService(req.userId, filePath);

  return res.status(200).json(
    new ApiResponse(true, "Profile image updated", {
      user: formatUser(user),
    })
  );
});