export const validateGenerateRecommendations = (body) => {
  const errors = [];
  const { farmId } = body;

  if (typeof farmId !== "string" || !farmId.trim()) {
    errors.push("Farm id is required");
  }

  return errors;
};

export const validateRecommendationStatusUpdate = (body) => {
  const errors = [];
  const { status } = body;

  const allowedStatuses = ["pending", "done", "dismissed", "expired"];

  if (typeof status !== "string" || !allowedStatuses.includes(status)) {
    errors.push("Status must be one of: pending, done, dismissed, expired");
  }

  return errors;
};