import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import {
  registerUserService,
  verifyEmailService,
  resendVerificationService,
  loginUserService,
  forgotPasswordService,
  verifyResetCodeService,
  resetPasswordService,
} from "./auth.service.js";
import {
  validateRegister,
  validateLogin,
  validateForgotPassword,
  validateVerifyResetCode,
  validateResetPassword,
  validateResendVerification,
} from "./auth.validation.js";

export const register = asyncHandler(async (req, res) => {
  const errors = validateRegister(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const result = await registerUserService(req.body);

  res.status(201).json(
    new ApiResponse(true, "Registered", {
      user: {
        id: result.user._id,
        fullName: result.user.fullName,
        email: result.user.email,
        phoneNumber: result.user.phoneNumber,
        role: result.user.role,
        language: result.user.language,
        emailVerified: result.user.emailVerified,
      },
      nextStep: result.nextStep,
      debugVerifyToken: result.debugVerifyToken,
    })
  );
});

export const verifyEmail = asyncHandler(async (req, res) => {
  const token = req.query.token?.toString();

  if (!token) {
    return res.status(400).json({
      success: false,
      message: "Token is required",
    });
  }

  await verifyEmailService(token);

  res.status(200).json(new ApiResponse(true, "Email verified"));
});

export const resendVerification = asyncHandler(async (req, res) => {
  const errors = validateResendVerification(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const result = await resendVerificationService(req.body.email);

  res.status(200).json(
    new ApiResponse(true, result.message, {
      debugVerifyToken: result.debugVerifyToken,
    })
  );
});

export const login = asyncHandler(async (req, res) => {
  const errors = validateLogin(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const result = await loginUserService(req.body);

  res.status(200).json(
    new ApiResponse(true, "Logged in", {
      token: result.token,
      user: {
        id: result.user._id,
        fullName: result.user.fullName,
        email: result.user.email,
        phoneNumber: result.user.phoneNumber,
        role: result.user.role,
        language: result.user.language,
        emailVerified: result.user.emailVerified,
      },
    })
  );
});

export const forgotPassword = asyncHandler(async (req, res) => {
  const errors = validateForgotPassword(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const result = await forgotPasswordService(req.body.email);

  res.status(200).json(
    new ApiResponse(true, result.message, {
      debugCode: result.debugCode,
    })
  );
});

export const verifyResetCode = asyncHandler(async (req, res) => {
  const errors = validateVerifyResetCode(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  await verifyResetCodeService(req.body);

  res.status(200).json(new ApiResponse(true, "Code verified"));
});

export const resetPassword = asyncHandler(async (req, res) => {
  const errors = validateResetPassword(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  await resetPasswordService(req.body);

  res.status(200).json(new ApiResponse(true, "Password updated"));
});

import { logoutUserService } from "./auth.service.js";

export const logout = asyncHandler(async (req, res) => {
  await logoutUserService();

  return res.status(200).json(
    new ApiResponse(true, "Logged out")
  );
});