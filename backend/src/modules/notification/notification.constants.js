export const NOTIFICATION_TYPES = Object.freeze({
  WEATHER: "weather",
  SCAN: "scan",
  SENSOR: "sensor",
  RECOMMENDATION: "recommendation",
  SYSTEM: "system",
});

export const NOTIFICATION_CATEGORIES = Object.freeze({
  RAIN: "rain",
  HEAT: "heat",
  WIND: "wind",
  FROST: "frost",

  DISEASE_DETECTED: "disease_detected",
  LOW_CONFIDENCE_SCAN: "low_confidence_scan",
  HEALTHY_SCAN: "healthy_scan",
  RESCAN_NEEDED: "rescan_needed",

  MOISTURE_LOW: "moisture_low",
  MOISTURE_HIGH: "moisture_high",
  SENSOR_OFFLINE: "sensor_offline",
  SENSOR_ABNORMAL: "sensor_abnormal",

  IRRIGATION_REMINDER: "irrigation_reminder",
  FERTILIZATION_REMINDER: "fertilization_reminder",
  TREATMENT_ACTION: "treatment_action",

  NO_RECENT_SCAN: "no_recent_scan",
  HEALTH_CHECK_NEEDED: "health_check_needed",
  FARM_PROFILE_INCOMPLETE: "farm_profile_incomplete",
  WEATHER_UNAVAILABLE: "weather_unavailable",
  DEVICE_DISCONNECTED: "device_disconnected",
});

export const NOTIFICATION_SEVERITIES = Object.freeze({
  LOW: "low",
  MEDIUM: "medium",
  HIGH: "high",
});

export const NOTIFICATION_STATUSES = Object.freeze({
  ACTIVE: "active",
  RESOLVED: "resolved",
  ARCHIVED: "archived",
});

export const NOTIFICATION_ACTION_TYPES = Object.freeze({
  NONE: "none",
  OPEN_WEATHER: "open_weather",
  OPEN_SCAN: "open_scan",
  OPEN_RECOMMENDATIONS: "open_recommendations",
  OPEN_SENSOR: "open_sensor",
  OPEN_PROFILE: "open_profile",
});

export const NOTIFICATION_RELATED_MODELS = Object.freeze({
  SCAN: "Scan",
  SENSOR_READING: "SensorReading",
  RECOMMENDATION: "Recommendation",
  FARM: "Farm",
});

export const DEFAULT_NOTIFICATION_LIMIT = 10;
export const MAX_NOTIFICATION_LIMIT = 50;