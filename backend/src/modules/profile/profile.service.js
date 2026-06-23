import bcrypt from "bcrypt";
import User from "../../models/user.model.js";
import ApiError from "../../utils/api-error.js";

export const getMyProfileService = async (userId) => {
  const user = await User.findById(userId, { passwordHash: 0 });

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return user;
};

export const updateMyProfileService = async (userId, body) => {
  const { fullName, email, phoneNumber } = body;

  const user = await User.findById(userId);

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  if (fullName !== undefined) {
    user.fullName = fullName.trim();
  }

  if (phoneNumber !== undefined) {
    user.phoneNumber = phoneNumber.trim();
  }

  if (email !== undefined) {
    const normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail !== user.email) {
      const existingUser = await User.findOne({
        email: normalizedEmail,
        _id: { $ne: userId },
      });

      if (existingUser) {
        throw new ApiError(400, "Email already exists");
      }

      user.email = normalizedEmail;
      user.emailVerified = false;
    }
  }

  await user.save();

  const updatedUser = await User.findById(userId, { passwordHash: 0 });
  return updatedUser;
};

export const updateMyLanguageService = async (userId, language) => {
  const user = await User.findByIdAndUpdate(
    userId,
    { language },
    { new: true, runValidators: true, projection: { passwordHash: 0 } }
  );

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return user;
};

export const updateMyNotificationsService = async (userId, notificationsEnabled) => {
  const user = await User.findByIdAndUpdate(
    userId,
    { notificationsEnabled },
    { new: true, runValidators: true, projection: { passwordHash: 0 } }
  );

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return user;
};

export const updateMyPasswordService = async (userId, body) => {
  const { currentPassword, newPassword } = body;

  const user = await User.findById(userId).select("+passwordHash");

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  if (!user.passwordHash) {
    throw new ApiError(500, "Password hash is missing");
  }

  const isMatch = await bcrypt.compare(currentPassword, user.passwordHash);

  if (!isMatch) {
    throw new ApiError(400, "Current password is incorrect");
  }

  user.passwordHash = await bcrypt.hash(newPassword, 10);
  await user.save();

  return true;
};

export const updateMyProfileImageService = async (userId, filePath) => {
  const user = await User.findByIdAndUpdate(
    userId,
    { profileImage: filePath },
    { new: true, runValidators: true, projection: { passwordHash: 0 } }
  );

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return user;
};