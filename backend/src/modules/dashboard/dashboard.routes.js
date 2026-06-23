import { Router } from "express";
import { getHomeDashboard } from "./dashboard.controller.js";
import authMiddleware from "../../middlewares/auth.middleware.js";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * /api/dashboard:
 *   get:
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard fetched successfully
 *       401:
 *         description: Unauthorized
 */
router.get("/", getHomeDashboard);
export default router;