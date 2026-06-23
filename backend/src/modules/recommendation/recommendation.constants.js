export const RECOMMENDATION_TYPES = {
  IRRIGATION: "irrigation",
  FERTILIZATION: "fertilization",
  DISEASE: "disease",
};

export const RECOMMENDATION_PRIORITIES = {
  HIGH: "high",
  MEDIUM: "medium",
  LOW: "low",
};

export const RECOMMENDATION_STATUSES = {
  PENDING: "pending",
  DONE: "done",
  DISMISSED: "dismissed",
  EXPIRED: "expired",
};

export const SOIL_RULES = {
  sandy: {
    dryThreshold: 35,
    optimalMin: 35,
    optimalMax: 55,
    highThreshold: 65,
    irrigationHint: "Use light irrigation more frequently",
  },
  loamy: {
    dryThreshold: 30,
    optimalMin: 30,
    optimalMax: 60,
    highThreshold: 70,
    irrigationHint: "Use normal irrigation schedule",
  },
  clay: {
    dryThreshold: 25,
    optimalMin: 25,
    optimalMax: 50,
    highThreshold: 60,
    irrigationHint: "Avoid over-irrigation and water less frequently",
  },
};

export const WEATHER_RULES = {
  hotThreshold: 32,
  veryHotThreshold: 36,
  highHumidityThreshold: 80,
  highWindThreshold: 15,
};