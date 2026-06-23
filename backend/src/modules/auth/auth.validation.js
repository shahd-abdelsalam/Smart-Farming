export const validateRegister = (body) => {
  const errors = [];
  const { fullName, email, phoneNumber, password, confirmPassword } = body;

  if (!fullName?.trim()) errors.push("Full name is required");
  if (!email?.trim()) errors.push("Email is required");
  if (!phoneNumber?.trim()) errors.push("Phone number is required");
  if (!password) errors.push("Password is required");
  if (!confirmPassword) errors.push("Confirm password is required");

  if (password && password.length < 8) {
    errors.push("Password must be at least 8 characters");
  }

  if (password && confirmPassword && password !== confirmPassword) {
    errors.push("Passwords do not match");
  }

  return errors;
};

export const validateLogin = (body) => {
  const errors = [];
  const { email, password } = body;

  if (!email?.trim()) errors.push("Email is required");
  if (!password) errors.push("Password is required");

  return errors;
};

export const validateForgotPassword = (body) => {
  const errors = [];
  const { email } = body;

  if (!email?.trim()) errors.push("Email is required");

  return errors;
};

export const validateVerifyResetCode = (body) => {
  const errors = [];
  const { email, code } = body;

  if (!email?.trim()) errors.push("Email is required");
  if (!code?.toString().trim()) errors.push("Code is required");

  return errors;
};

export const validateResetPassword = (body) => {
  const errors = [];
  const { email, code, newPassword, confirmPassword } = body;

  if (!email?.trim()) errors.push("Email is required");
  if (!code?.toString().trim()) errors.push("Code is required");
  if (!newPassword) errors.push("New password is required");
  if (!confirmPassword) errors.push("Confirm password is required");

  if (newPassword && newPassword.length < 8) {
    errors.push("New password must be at least 8 characters");
  }

  if (newPassword && confirmPassword && newPassword !== confirmPassword) {
    errors.push("Passwords do not match");
  }

  return errors;
};

export const validateResendVerification = (body) => {
  const errors = [];
  const { email } = body;

  if (!email?.trim()) errors.push("Email is required");

  return errors;
};

