import { Router } from "express";
import authMiddleware from "../../middlewares/auth.middleware.js";
import upload from "../../middlewares/upload.middleware.js";
import {
  getMyProfile,
  updateMyProfile,
  updateMyLanguage,
  updateMyNotifications,
  updateMyPassword,
  updateMyProfileImage,
} from "./profile.controller.js";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * /api/profile:
 *   get:
 *     tags: [Profile]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/", getMyProfile);

/**
 * @swagger
 * /api/profile:
 *   patch:
 *     tags: [Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fullName:
 *                 type: string
 *               phoneNumber:
 *                 type: string
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/", updateMyProfile);

/**
 * @swagger
 * /api/profile/language:
 *   patch:
 *     tags: [Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               language:
 *                 type: string
 *                 example: en
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/language", updateMyLanguage);

/**
 * @swagger
 * /api/profile/notifications:
 *   patch:
 *     tags: [Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/notifications", updateMyNotifications);

/**
 * @swagger
 * /api/profile/password:
 *   patch:
 *     tags: [Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               currentPassword:
 *                 type: string
 *               newPassword:
 *                 type: string
 *               confirmPassword:
 *                 type: string
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/password", updateMyPassword);

/**
 * @swagger
 * /api/profile/image:
 *   patch:
 *     tags: [Profile]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               image:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/image", upload.single("image"), updateMyProfileImage);

export default router;