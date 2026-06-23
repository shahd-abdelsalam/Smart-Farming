import express from "express";
import authMiddleware from "../../middlewares/auth.middleware.js";
import { getMyFarmWeatherController } from "./weather.controller.js";

const router = express.Router();

/**
 * @swagger
 * /api/weather/farm:
 *   get:
 *     tags: [Weather]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 *       400:
 *         description: Farm location is missing
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Farm not found
 */
router.get("/farm", authMiddleware, getMyFarmWeatherController);

export default router;