import { Router } from "express";
import authRoutes from "../modules/auth/auth.routes.js";
import farmRoutes from "../modules/farm/farm.routes.js";
import profileRoutes from "../modules/profile/profile.routes.js";
import authMiddleware from "../middlewares/auth.middleware.js";
import isAdminMiddleware from "../middlewares/is-admin.middleware.js";
import asyncHandler from "../utils/async-handler.js";
import User from "../models/user.model.js";
import sensorRoutes from "../modules/sensor/sensor.routes.js";
import ApiResponse from "../utils/api-response.js";
import scanRoutes from "../modules/scan/scan.routes.js";
import weatherRoutes from "../modules/weather/weather.routes.js";
import recommendationRoutes from "../modules/recommendation/recommendation.routes.js";
import notificationRoutes from "../modules/notification/notification.routes.js";
import dashboardRoutes from "../modules/dashboard/dashboard.routes.js";

const router = Router();

router.use("/auth", authRoutes);
router.use("/farm", farmRoutes);
router.use("/profile", profileRoutes);
router.use("/sensor", sensorRoutes);
router.use("/weather", weatherRoutes);
router.use("/scan", scanRoutes);
router.use("/recommendations", recommendationRoutes);
router.use("/notifications", notificationRoutes);
router.use("/dashboard", dashboardRoutes);

router.get(
  "/me",
  authMiddleware,
  asyncHandler(async (req, res) => {
    const user = await User.findById(req.userId, { passwordHash: 0 });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    return res.status(200).json(
      new ApiResponse(true, "User fetched", {
        user: {
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
        },
      })
    );
  })
);

router.get(
  "/admin/users",
  authMiddleware,
  isAdminMiddleware,
  asyncHandler(async (req, res) => {
    const users = await User.find({}, { passwordHash: 0 });

    return res.status(200).json(
      new ApiResponse(true, "Users fetched", {
        users,
      })
    );
  })
);

export default router;