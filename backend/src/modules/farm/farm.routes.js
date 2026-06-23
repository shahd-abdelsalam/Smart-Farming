import { Router } from "express";
import authMiddleware from "../../middlewares/auth.middleware.js";
import { setupFarmInfo, saveFarmInfo, getFarmInfo } from "./farm.controller.js";

const router = Router();

router.use(authMiddleware);

/**
 * @swagger
 * /api/farm:
 *   post:
 *     tags: [Farm]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: "El-Nile Farm"
 *               farmSize:
 *                 type: number
 *                 example: 5
 *               cropTypes:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["Tomato"]
 *               soilType:
 *                 type: string
 *                 example: "Sandy"
 *               irrigationType:
 *                 type: string
 *                 example: "Drip"
 *               plantingDate:
 *                 type: string
 *                 example: "2026-06-01"
 *               locationText:
 *                 type: string
 *                 example: "Egypt, Mansoura"
 *               geo:
 *                 type: object
 *                 properties:
 *                   lat:
 *                     type: number
 *                     example: 31.0409
 *                   lng:
 *                     type: number
 *                     example: 31.3785
 *     responses:
 *       201:
 *         description: Farm info created
 */
router.post("/", setupFarmInfo);

/**
 * @swagger
 * /api/farm:
 *   patch:
 *     tags: [Farm]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: "El-Nile Farm"
 *               farmSize:
 *                 type: number
 *                 example: 5
 *               cropTypes:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["Tomato"]
 *               soilType:
 *                 type: string
 *                 example: "Sandy"
 *               irrigationType:
 *                 type: string
 *                 example: "Drip"
 *               plantingDate:
 *                 type: string
 *                 example: "2026-06-01"
 *               locationText:
 *                 type: string
 *                 example: "Egypt, Mansoura"
 *               geo:
 *                 type: object
 *                 properties:
 *                   lat:
 *                     type: number
 *                     example: 31.0409
 *                   lng:
 *                     type: number
 *                     example: 31.3785
 *     responses:
 *       200:
 *         description: Farm info saved
 */
router.patch("/", saveFarmInfo);

/**
 * @swagger
 * /api/farm:
 *   get:
 *     tags: [Farm]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Farm fetched
 */
router.get("/", getFarmInfo);

export default router;