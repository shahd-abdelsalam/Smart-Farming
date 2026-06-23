import express from "express";
import authMiddleware from "../../middlewares/auth.middleware.js";
import scanUpload from "../../middlewares/scan-upload.middleware.js";
import {
  getScanOverviewController,
  createScanController,
  getMyScansController,
  getScanByIdController,
} from "./scan.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/scan:
 *   get:
 *     tags: [Scan]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/", authMiddleware, getMyScansController);

/**
 * @swagger
 * /api/scan:
 *   post:
 *     tags: [Scan]
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
 *               source:
 *                 type: string
 *                 enum: [camera, gallery]
 *                 example: gallery
 *     responses:
 *       201:
 *         description: Success
 */
router.post(
  "/",
  authMiddleware,
  scanUpload.single("image"),
  createScanController
);

/**
 * @swagger
 * /api/scan/overview:
 *   get:
 *     tags: [Scan]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/overview", authMiddleware, getScanOverviewController);

/**
 * @swagger
 * /api/scan/{id}:
 *   get:
 *     tags: [Scan]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/:id", authMiddleware, getScanByIdController);

export default router;