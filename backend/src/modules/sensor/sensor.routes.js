import { Router } from "express";
import sensorAuthMiddleware from "../../middlewares/sensor-auth.middleware.js";
import authMiddleware from "../../middlewares/auth.middleware.js";
import {
  receiveSoilMoistureReading,
  getMyLatestSoilStatus,
  getMySoilHistory,
} from "./sensor.controller.js";

const router = Router();
/**
 * @swagger
 * /api/sensor/soil-moisture/readings:
 *   post:
 *     tags: [Sensor]
 *     parameters:
 *       - in: header
 *         name: x-device-id
 *         required: true
 *         schema:
 *           type: string
 *           example: ESP32_01
 *       - in: header
 *         name: x-device-token
 *         required: true
 *         schema:
 *           type: string
 *           example: soil_sensor_01_token_X7m29QaL88
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               moisturePercent:
 *                 type: number
 *                 example: 55
 *               rawValue:
 *                 type: number
 *                 example: 1800
 *               batteryVoltage:
 *                 type: number
 *                 example: 3.7
 *               temperature:
 *                 type: number
 *                 example: 28
 *               recordedAt:
 *                 type: string
 *                 example: "2026-06-19T01:00:00.000Z"
 *     responses:
 *       201:
 *         description: Success
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Soil moisture reading saved"
 *       401:
 *         description: Unauthorized
 */
router.post(
  "/soil-moisture/readings",
  sensorAuthMiddleware,
  receiveSoilMoistureReading
);

/**
 * @swagger
 * /api/sensor/soil-moisture/latest:
 *   get:
 *     tags: [Sensor]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/soil-moisture/latest", authMiddleware, getMyLatestSoilStatus);

/**
 * @swagger
 * /api/sensor/soil-moisture/history:
 *   get:
 *     tags: [Sensor]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/soil-moisture/history", authMiddleware, getMySoilHistory);

export default router;