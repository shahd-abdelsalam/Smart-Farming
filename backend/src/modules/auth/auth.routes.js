import { Router } from "express";
import {
  register,
  verifyEmail,
  resendVerification,
  login,
  forgotPassword,
  verifyResetCode,
  resetPassword,
} from "./auth.controller.js";

const router = Router();

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [fullName, email, phoneNumber, password, confirmPassword, language]
 *             properties:
 *               fullName:
 *                 type: string
 *                 example: "Shahd Abdelsalam"
 *               email:
 *                 type: string
 *                 example: "shahdtest123@gmail.com"
 *               phoneNumber:
 *                 type: string
 *                 example: "01012345678"
 *               password:
 *                 type: string
 *                 example: "12345678"
 *               confirmPassword:
 *                 type: string
 *                 example: "12345678"
 *               language:
 *                 type: string
 *                 example: "en"
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "User registered successfully"
 *               data:
 *                 user:
 *                   id: "65f123456789abcdef123456"
 *                   fullName: "Shahd Abdelsalam"
 *                   email: "shahdtest123@gmail.com"
 *                   phoneNumber: "01012345678"
 *                   language: "en"
 *       400:
 *         description: Bad Request
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "Email already exists"
 */
router.post("/register", register);

/**
 * @swagger
 * /api/auth/verify-email:
 *   get:
 *     tags: [Auth]
 *     parameters:
 *       - in: query
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         example: "verification_token_here"
 *     responses:
 *       200:
 *         description: Email verified successfully
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Email verified successfully"
 *       400:
 *         description: Invalid token
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "Invalid or expired token"
 */
router.get("/verify-email", verifyEmail);

/**
 * @swagger
 * /api/auth/resend-verification:
 *   post:
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email]
 *             properties:
 *               email:
 *                 type: string
 *                 example: "shahdtest123@gmail.com"
 *     responses:
 *       200:
 *         description: Verification email sent
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Verification email sent"
 *       400:
 *         description: Bad Request
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "Invalid request"
 */
router.post("/resend-verification", resendVerification);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:
 *                 type: string
 *                 example: "shahdtest123@gmail.com"
 *               password:
 *                 type: string
 *                 example: "12345678"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Login successful"
 *               data:
 *                 token: "jwt_token_here"
 *                 user:
 *                   id: "65f123456789abcdef123456"
 *                   fullName: "Shahd Abdelsalam"
 *                   email: "shahdtest123@gmail.com"
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "Invalid email or password"
 */
router.post("/login", login);

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email]
 *             properties:
 *               email:
 *                 type: string
 *                 example: "shahdtest123@gmail.com"
 *     responses:
 *       200:
 *         description: Reset code sent
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Reset code sent successfully"
 *       404:
 *         description: User not found
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "User not found"
 */
router.post("/forgot-password", forgotPassword);

/**
 * @swagger
 * /api/auth/verify-reset-code:
 *   post:
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, code]
 *             properties:
 *               email:
 *                 type: string
 *                 example: "shahdtest123@gmail.com"
 *               code:
 *                 type: string
 *                 example: "12345"
 *     responses:
 *       200:
 *         description: Reset code verified
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Reset code verified"
 *       400:
 *         description: Invalid code
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "Invalid or expired code"
 */
router.post("/verify-reset-code", verifyResetCode);

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, code, newPassword, confirmPassword]
 *             properties:
 *               email:
 *                 type: string
 *                 example: "shahdtest123@gmail.com"
 *               code:
 *                 type: string
 *                 example: "12345"
 *               newPassword:
 *                 type: string
 *                 example: "12345678"
 *               confirmPassword:
 *                 type: string
 *                 example: "12345678"
 *     responses:
 *       200:
 *         description: Password reset successfully
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: "Password reset successfully"
 *       400:
 *         description: Bad Request
 *         content:
 *           application/json:
 *             example:
 *               success: false
 *               message: "Invalid request"
 */
router.post("/reset-password", resetPassword);

export default router;