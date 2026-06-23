import { Router } from "express";
import authMiddleware from "../../middlewares/auth.middleware.js";
import {
  generateRecommendationsController,
  getRecommendationByIdController,
  getRecommendationsController,
  updateRecommendationStatusController,
} from "./recommendation.controller.js";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * /api/recommendations:
 *   get:
 *     tags: [Recommendations]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get("/", getRecommendationsController);

/**
 * @swagger
 * /api/recommendations/{id}:
 *   get:
 *     tags: [Recommendations]
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
router.get("/:id", getRecommendationByIdController);

/**
 * @swagger
 * /api/recommendations/generate:
 *   post:
 *     tags: [Recommendations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               farmId:
 *                 type: string
 *                 example: "65f123456789abcdef123456"
 *     responses:
 *       200:
 *         description: Success
 */
router.post("/generate", generateRecommendationsController);

/**
 * @swagger
 * /api/recommendations/{id}/status:
 *   patch:
 *     tags: [Recommendations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 example: "resolved"
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/:id/status", updateRecommendationStatusController);

export default router;