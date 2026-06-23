export const validateFarmInfo = (body) => {
  const errors = [];
  const {
    name,
    farmSize,
    cropTypes,
    soilType,
    irrigationType,
    plantingDate,
    locationText,  
    geo,
  } = body;

  if (
    name !== undefined &&
    name !== null &&
    typeof name !== "string"
  ) {
    errors.push("Name must be a string");
  }

  if (typeof farmSize !== "string" || !farmSize.trim()) {
    errors.push("Farm size is required");
  }

  if (typeof cropTypes !== "string" || !cropTypes.trim()) {
    errors.push("Crop types is required");
  }

  if (typeof soilType !== "string" || !soilType.trim()) {
    errors.push("Soil type is required");
  }

  if (typeof irrigationType !== "string" || !irrigationType.trim()) {
    errors.push("Irrigation type is required");
  }

  if (!plantingDate) {
    errors.push("Planting date is required");
  } else {
    const parsedDate = new Date(plantingDate);
    if (Number.isNaN(parsedDate.getTime())) {
      errors.push("Planting date must be a valid date");
    }
  }

  if (
    locationText !== undefined &&
    locationText !== null &&
    typeof locationText !== "string"
  ) {
    errors.push("locationText must be a string");
  }

  if (geo !== undefined && geo !== null) {
    if (typeof geo !== "object" || Array.isArray(geo)) {
      errors.push("geo must be an object");
    } else {
      if (
        geo.lat !== undefined &&
        geo.lat !== null &&
        typeof geo.lat !== "number"
      ) {
        errors.push("geo.lat must be a number");
      }

      if (
        geo.lng !== undefined &&
        geo.lng !== null &&
        typeof geo.lng !== "number"
      ) {
        errors.push("geo.lng must be a number");
      }
    }
  }

  return errors;
};

export const validateFarmSetup = (body) => {
  const errors = [];
  const { email } = body;

  if (typeof email !== "string" || !email.trim()) {
    errors.push("Email is required");
  }

  return [...errors, ...validateFarmInfo(body)];
};