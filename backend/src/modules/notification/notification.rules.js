import {
  NOTIFICATION_ACTION_TYPES,
  NOTIFICATION_CATEGORIES,
  NOTIFICATION_RELATED_MODELS,
  NOTIFICATION_SEVERITIES,
  NOTIFICATION_TYPES,
} from "./notification.constants.js";
import { buildNotificationDedupeKey, isSameDayUTC } from "./notification.utils.js";

export const buildWeatherAlertPayloads = ({
  ownerId,
  farmId,
  weather,
}) => {
  const payloads = [];
  if (!weather) return payloads;

  const rainMm = Number(weather.rainMm ?? 0);
  const maxTemp = Number(weather.maxTemp ?? 0);
  const windSpeed = Number(weather.windSpeed ?? 0);
  const forecastDate = weather.date || new Date();

  if (rainMm >= 10) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.WEATHER,
      category: NOTIFICATION_CATEGORIES.RAIN,
      sourceModule: "weather",
      title: "Heavy rain expected tomorrow",
      message:
        "Rain is expected in the next 24 hours. Avoid irrigation and protect sensitive crops.",
      severity: NOTIFICATION_SEVERITIES.HIGH,
      priorityScore: 90,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_WEATHER,
      actionLabel: "View weather",
      metadata: { rainMm, forecastDate },
      dedupeKey: buildNotificationDedupeKey(
        "weather",
        "rain",
        farmId,
        isSameDayUTC(forecastDate)
      ),
    });
  }

  if (maxTemp >= 38) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.WEATHER,
      category: NOTIFICATION_CATEGORIES.HEAT,
      sourceModule: "weather",
      title: "Heat wave warning",
      message:
        "Very high temperatures are expected. Monitor soil moisture and avoid plant stress.",
      severity: NOTIFICATION_SEVERITIES.HIGH,
      priorityScore: 88,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_WEATHER,
      actionLabel: "View weather",
      metadata: { maxTemp, forecastDate },
      dedupeKey: buildNotificationDedupeKey(
        "weather",
        "heat",
        farmId,
        isSameDayUTC(forecastDate)
      ),
    });
  }

  if (windSpeed >= 35) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.WEATHER,
      category: NOTIFICATION_CATEGORIES.WIND,
      sourceModule: "weather",
      title: "Strong wind alert",
      message:
        "Strong wind conditions are expected. Secure fragile plants and exposed equipment.",
      severity: NOTIFICATION_SEVERITIES.MEDIUM,
      priorityScore: 70,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_WEATHER,
      actionLabel: "View weather",
      metadata: { windSpeed, forecastDate },
      dedupeKey: buildNotificationDedupeKey(
        "weather",
        "wind",
        farmId,
        isSameDayUTC(forecastDate)
      ),
    });
  }

  return payloads;
};

export const buildScanAlertPayloads = ({ ownerId, farmId, scan }) => {
  const payloads = [];
  if (!scan) return payloads;

  const diseaseName = String(
    scan.diseaseName || scan.predictedClass || "Unknown"
  ).trim();

  const confidence = Number(scan.confidence ?? 0);
  const scanId = scan._id || scan.id;

  const isHealthy =
    scan.isHealthy ?? diseaseName.toLowerCase().includes("healthy");

  if (!isHealthy) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SCAN,
      category: NOTIFICATION_CATEGORIES.DISEASE_DETECTED,
      sourceModule: "scan",
      title: "Disease detected in last scan",
      message: `${diseaseName} was detected. Open scan details for treatment recommendations.`,
      severity:
        confidence >= 80
          ? NOTIFICATION_SEVERITIES.HIGH
          : NOTIFICATION_SEVERITIES.MEDIUM,
      priorityScore: confidence >= 80 ? 92 : 75,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_SCAN,
      actionLabel: "Open scan",
      relatedModel: NOTIFICATION_RELATED_MODELS.SCAN,
      relatedId: scanId || null,
      metadata: {
        diseaseName,
        confidence,
      },
      dedupeKey: buildNotificationDedupeKey(
        "scan",
        "disease",
        scanId || diseaseName
      ),
    });
  }

  if (confidence > 0 && confidence < 60) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SCAN,
      category: NOTIFICATION_CATEGORIES.LOW_CONFIDENCE_SCAN,
      sourceModule: "scan",
      title: "Low-confidence scan result",
      message:
        "The last scan confidence is low. Please rescan under better lighting for a more reliable result.",
      severity: NOTIFICATION_SEVERITIES.MEDIUM,
      priorityScore: 68,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_SCAN,
      actionLabel: "Rescan",
      relatedModel: NOTIFICATION_RELATED_MODELS.SCAN,
      relatedId: scanId || null,
      metadata: {
        diseaseName,
        confidence,
      },
      dedupeKey: buildNotificationDedupeKey(
        "scan",
        "low_confidence",
        scanId || diseaseName
      ),
    });
  }

  return payloads;
};

export const buildSensorAlertPayloads = ({
  ownerId,
  farmId,
  sensorReading,
}) => {
  const payloads = [];
  if (!sensorReading) return payloads;

  const moisturePercent = Number(sensorReading.moisturePercent ?? 0);
  const readingId = sensorReading._id || sensorReading.id;
  const readingDate = sensorReading.recordedAt || new Date();

  if (moisturePercent < 20) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SENSOR,
      category: NOTIFICATION_CATEGORIES.MOISTURE_LOW,
      sourceModule: "sensor",
      title: "Low soil moisture detected",
      message:
        "Soil moisture is low. Irrigation may be needed soon.",
      severity: NOTIFICATION_SEVERITIES.HIGH,
      priorityScore: 86,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_SENSOR,
      actionLabel: "View sensor",
      relatedModel: NOTIFICATION_RELATED_MODELS.SENSOR_READING,
      relatedId: readingId || null,
      metadata: { moisturePercent, readingDate },
      dedupeKey: buildNotificationDedupeKey(
        "sensor",
        "moisture_low",
        farmId,
        isSameDayUTC(readingDate)
      ),
    });
  }

  if (moisturePercent > 60) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SENSOR,
      category: NOTIFICATION_CATEGORIES.MOISTURE_HIGH,
      sourceModule: "sensor",
      title: "High soil moisture detected",
      message:
        "Soil moisture is high. Avoid irrigation to reduce root stress and overwatering risk.",
      severity: NOTIFICATION_SEVERITIES.MEDIUM,
      priorityScore: 72,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_SENSOR,
      actionLabel: "View sensor",
      relatedModel: NOTIFICATION_RELATED_MODELS.SENSOR_READING,
      relatedId: readingId || null,
      metadata: { moisturePercent, readingDate },
      dedupeKey: buildNotificationDedupeKey(
        "sensor",
        "moisture_high",
        farmId,
        isSameDayUTC(readingDate)
      ),
    });
  }

  return payloads;
};

export const buildSystemAlertPayloads = ({
  ownerId,
  farmId,
  hasRecentScan,
  hasRecentSensorReading,
  isFarmProfileIncomplete,
}) => {
  const payloads = [];

  if (!hasRecentScan) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SYSTEM,
      category: NOTIFICATION_CATEGORIES.HEALTH_CHECK_NEEDED,
      sourceModule: "system",
      title: "Crop health check needed",
      message:
        "No recent scan was detected. Please scan new leaves to confirm crop condition.",
      severity: NOTIFICATION_SEVERITIES.MEDIUM,
      priorityScore: 65,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_SCAN,
      actionLabel: "Open scan",
      metadata: {},
      dedupeKey: buildNotificationDedupeKey(
        "system",
        "health_check_needed",
        farmId,
        isSameDayUTC(new Date())
      ),
    });
  }

  if (!hasRecentSensorReading) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SYSTEM,
      category: NOTIFICATION_CATEGORIES.DEVICE_DISCONNECTED,
      sourceModule: "system",
      title: "Sensor data missing",
      message:
        "No recent sensor reading was received. Check device connectivity and power.",
      severity: NOTIFICATION_SEVERITIES.HIGH,
      priorityScore: 84,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_SENSOR,
      actionLabel: "View sensor",
      metadata: {},
      dedupeKey: buildNotificationDedupeKey(
        "system",
        "sensor_data_missing",
        farmId,
        isSameDayUTC(new Date())
      ),
    });
  }

  if (isFarmProfileIncomplete) {
    payloads.push({
      ownerId,
      farmId,
      type: NOTIFICATION_TYPES.SYSTEM,
      category: NOTIFICATION_CATEGORIES.FARM_PROFILE_INCOMPLETE,
      sourceModule: "system",
      title: "Farm profile incomplete",
      message:
        "Complete your farm information to improve recommendations and alerts.",
      severity: NOTIFICATION_SEVERITIES.LOW,
      priorityScore: 40,
      actionType: NOTIFICATION_ACTION_TYPES.OPEN_PROFILE,
      actionLabel: "Complete profile",
      metadata: {},
      dedupeKey: buildNotificationDedupeKey(
        "system",
        "farm_profile_incomplete",
        farmId
      ),
    });
  }

  return payloads;
};