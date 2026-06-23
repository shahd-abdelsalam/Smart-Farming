import bcrypt from "bcrypt";
import crypto from "crypto";
import User from "../../models/user.model.js";
import PasswordReset from "../../models/password-reset.model.js";
import EmailVerification from "../../models/email-verification.model.js";
import generateToken from "../../utils/generate-token.js";
import generateCode from "../../utils/generate-code.js";
import ApiError from "../../utils/api-error.js";
import { env } from "../../config/env.js";

export const registerUserService = async ({ fullName, email, phoneNumber, password, language }) => {
  const normalizedEmail = email.toLowerCase();

  const existing = await User.findOne({ email: normalizedEmail });
  if (existing) {
    throw new ApiError(400, "Email already exists");
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await User.create({
    fullName,
    email: normalizedEmail,
    phoneNumber,
    passwordHash,
    role: "user",
    language: language === "ar" ? "ar" : "en",
    emailVerified: false,
  });

  const verifyToken = crypto.randomBytes(32).toString("hex");
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

  await EmailVerification.create({
    userId: user._id,
    token: verifyToken,
    expiresAt,
    used: false,
  });

  return {
    user,
    nextStep: "confirm_email",
    debugVerifyToken: env.NODE_ENV === "production" ? undefined : verifyToken,
  };
};

export const verifyEmailService = async (token) => {
  const record = await EmailVerification.findOne({ token, used: false });

  if (!record) {
    throw new ApiError(400, "Invalid token");
  }

  if (record.expiresAt.getTime() < Date.now()) {
    throw new ApiError(400, "Token expired");
  }

  const user = await User.findById(record.userId);
  if (!user) {
    throw new ApiError(400, "Invalid request");
  }

  user.emailVerified = true;
  await user.save();

  record.used = true;
  await record.save();

  return true;
};

export const resendVerificationService = async (email) => {
  const normalizedEmail = email.toLowerCase();

  const user = await User.findOne({ email: normalizedEmail });
  if (!user) {
    return {
      message: "If the email exists, a new verification token was created",
    };
  }

  if (user.emailVerified) {
    return {
      alreadyVerified: true,
      message: "Email already verified",
    };
  }

  await EmailVerification.deleteMany({
    userId: user._id,
    used: false,
  });

  const verifyToken = crypto.randomBytes(32).toString("hex");
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

  await EmailVerification.create({
    userId: user._id,
    token: verifyToken,
    expiresAt,
    used: false,
  });

  return {
    message: "Verification token recreated",
    debugVerifyToken: env.NODE_ENV === "production" ? undefined : verifyToken,
  };
};

export const loginUserService = async ({ email, password }) => {
  const normalizedEmail = email.toLowerCase().trim();

  const user = await User.findOne({ email: normalizedEmail }).select("+passwordHash");

  if (!user) {
    throw new ApiError(400, "Wrong email or password");
  }

  if (!user.passwordHash) {
    throw new ApiError(500, "Password hash is missing for this account");
  }

  const ok = await bcrypt.compare(password, user.passwordHash);

  if (!ok) {
    throw new ApiError(400, "Wrong email or password");
  }

  if (!user.emailVerified) {
    throw new ApiError(403, "Email not verified");
  }

  user.lastLoginAt = new Date();
  await user.save();

  const token = generateToken(user);

  return {
    token,
    user,
  };
};

export const forgotPasswordService = async (email) => {
  const normalizedEmail = email.toLowerCase();

  const user = await User.findOne({ email: normalizedEmail });

  if (!user) {
    return {
      message: "Code sent",
    };
  }

  await PasswordReset.deleteMany({
    email: normalizedEmail,
    used: false,
  });

  const code = generateCode();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

  await PasswordReset.create({
    email: normalizedEmail,
    code,
    expiresAt,
    used: false,
  });

  return {
    message: "Code sent",
    debugCode: env.NODE_ENV === "production" ? undefined : code,
  };
};

export const verifyResetCodeService = async ({ email, code }) => {
  const normalizedEmail = email.toLowerCase();

  const record = await PasswordReset.findOne({
    email: normalizedEmail,
    code: code.toString(),
    used: false,
  }).sort({ createdAt: -1 });

  if (!record) {
    throw new ApiError(400, "Invalid code");
  }

  if (record.expiresAt.getTime() < Date.now()) {
    throw new ApiError(400, "Code expired");
  }

  return true;
};

export const resetPasswordService = async ({ email, code, newPassword }) => {
  const normalizedEmail = email.toLowerCase();

  const record = await PasswordReset.findOne({
    email: normalizedEmail,
    code: code.toString(),
    used: false,
  }).sort({ createdAt: -1 });

  if (!record) {
    throw new ApiError(400, "Invalid code");
  }

  if (record.expiresAt.getTime() < Date.now()) {
    throw new ApiError(400, "Code expired");
  }

  const user = await User.findOne({ email: normalizedEmail });
  if (!user) {
    throw new ApiError(400, "Invalid request");
  }

  user.passwordHash = await bcrypt.hash(newPassword, 10);
  await user.save();

  record.used = true;
  await record.save();

  return true;
};

export const logoutUserService = async () => {
  return true;
};