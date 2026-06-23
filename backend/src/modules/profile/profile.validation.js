export const validateUpdateProfile = (body) => {
  const errors = [];
  const { fullName, email, phoneNumber } = body;

  if (
    fullName === undefined &&
    email === undefined &&
    phoneNumber === undefined
  ) {
    errors.push("At least one field is required");
  }

  if (fullName !== undefined) {
    if (typeof fullName !== "string" || !fullName.trim()) {
      errors.push("Full name must be a non-empty string");
    } else if (fullName.trim().length < 2 || fullName.trim().length > 100) {
      errors.push("Full name must be between 2 and 100 characters");
    }
  }

  if (email !== undefined) {
    if (typeof email !== "string" || !email.trim()) {
      errors.push("Email must be a non-empty string");
    } else {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email.trim().toLowerCase())) {
        errors.push("Email is invalid");
      }
    }
  }

  if (phoneNumber !== undefined) {
    if (typeof phoneNumber !== "string" || !phoneNumber.trim()) {
      errors.push("Phone number must be a non-empty string");
    } else {
      const egyptPhoneRegex = /^01[0125][0-9]{8}$/;
      if (!egyptPhoneRegex.test(phoneNumber.trim())) {
        errors.push("Phone number is invalid");
      }
    }
  }

  return errors;
};

export const validateUpdateLanguage = (body) => {
  const errors = [];
  const { language } = body;

  if (language !== "en" && language !== "ar") {
    errors.push("Language must be en or ar");
  }

  return errors;
};

export const validateUpdateNotifications = (body) => {
  const errors = [];
  const { notificationsEnabled } = body;

  if (typeof notificationsEnabled !== "boolean") {
    errors.push("notificationsEnabled must be boolean");
  }

  return errors;
};

export const validateUpdatePassword = (body) => {
  const errors = [];
  const { currentPassword, newPassword, confirmPassword } = body;

  if (typeof currentPassword !== "string" || !currentPassword.trim()) {
    errors.push("Current password is required");
  }

  if (typeof newPassword !== "string" || newPassword.length < 6) {
    errors.push("New password must be at least 6 characters");
  }

  if (typeof confirmPassword !== "string" || !confirmPassword.trim()) {
    errors.push("Confirm password is required");
  }

  if (
    typeof currentPassword === "string" &&
    typeof newPassword === "string" &&
    currentPassword === newPassword
  ) {
    errors.push("New password must be different from current password");
  }

  if (
    typeof newPassword === "string" &&
    typeof confirmPassword === "string" &&
    newPassword !== confirmPassword
  ) {
    errors.push("Confirm password does not match new password");
  }

  return errors;
};