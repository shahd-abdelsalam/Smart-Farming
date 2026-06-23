export const weatherSummaryValidator = (data) => {
  const errors = [];

  if (!data.lat) {
    errors.push("lat is required");
  } else if (isNaN(Number(data.lat))) {
    errors.push("lat must be a valid number");
  }

  if (!data.lon) {
    errors.push("lon is required");
  } else if (isNaN(Number(data.lon))) {
    errors.push("lon must be a valid number");
  }

  if (data.days !== undefined) {
    const days = Number(data.days);

    if (isNaN(days) || !Number.isInteger(days)) {
      errors.push("days must be an integer");
    } else if (days < 1 || days > 14) {
      errors.push("days must be between 1 and 14");
    }
  }

  return errors;
};

export const weatherAlertsValidator = (data) => {
  const errors = [];

  if (!data.lat) {
    errors.push("lat is required");
  } else if (isNaN(Number(data.lat))) {
    errors.push("lat must be a valid number");
  }

  if (!data.lon) {
    errors.push("lon is required");
  } else if (isNaN(Number(data.lon))) {
    errors.push("lon must be a valid number");
  }

  return errors;
};

export const weatherSearchValidator = (data) => {
  const errors = [];

  if (!data.q) {
    errors.push("q is required");
  } else if (String(data.q).trim().length < 2) {
    errors.push("q must be at least 2 characters");
  }

  return errors;
};