export const validateSoilMoistureReading = (body) => {
  const errors = [];
  const { moisturePercent, rawValue, batteryVoltage, temperature, recordedAt } = body;

  if (moisturePercent === undefined || moisturePercent === null) {
    errors.push("moisturePercent is required");
  }

  if (
    moisturePercent !== undefined &&
    (typeof moisturePercent !== "number" || moisturePercent < 0 || moisturePercent > 100)
  ) {
    errors.push("moisturePercent must be a number between 0 and 100");
  }

  if (
  body.source !== undefined &&
  !["postman", "device", "simulator"].includes(body.source)
  ) {
  errors.push("source must be postman, device, or simulator");
  }

  if (rawValue !== undefined && rawValue !== null && typeof rawValue !== "number") {
    errors.push("rawValue must be a number");
  }

  if (
    batteryVoltage !== undefined &&
    batteryVoltage !== null &&
    typeof batteryVoltage !== "number"
  ) {
    errors.push("batteryVoltage must be a number");
  }

  if (
    temperature !== undefined &&
    temperature !== null &&
    typeof temperature !== "number"
  ) {
    errors.push("temperature must be a number");
  }

  if (recordedAt && Number.isNaN(Date.parse(recordedAt))) {
    errors.push("recordedAt must be a valid date");
  }

  return errors;
};