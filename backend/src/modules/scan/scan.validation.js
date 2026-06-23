import mongoose from "mongoose";

export const validateCreateScan = (body, file) => {
  const errors = [];

  if (!file) {
    errors.push("Image file is required");
  }

  if (body.source && !["camera", "gallery"].includes(body.source)) {
    errors.push("source must be either camera or gallery");
  }

  return errors;
};

export const validateScanId = (params) => {
  const errors = [];

  if (!params.id) {
    errors.push("Scan id is required");
  } else if (!mongoose.Types.ObjectId.isValid(params.id)) {
    errors.push("Invalid scan id");
  }

  return errors;
};