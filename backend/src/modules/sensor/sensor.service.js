import SoilMoistureReading from "../../models/soil-moisture-reading.model.js";
import SoilStatus from "../../models/soil-status.model.js";
import Farm from "../../models/farm.model.js";

import { buildSensorAlertPayloads } from "../notification/notification.rules.js";
import { createNotificationsBulkService } from "../notification/notification.service.js";

const getSoilStatus = (moisturePercent) => {
  if (moisturePercent < 30) {
    return {
      status: "dry",
      recommendation: "Soil moisture is low. Irrigation is recommended.",
    };
  }

  if (moisturePercent <= 70) {
    return {
      status: "optimal",
      recommendation: "Soil moisture is within the optimal range.",
    };
  }

  return {
    status: "wet",
    recommendation: "Soil moisture is high. No irrigation is needed now.",
  };
};

export const saveSoilMoistureReadingService = async (device, body) => {
  const recordedAt = body.recordedAt ? new Date(body.recordedAt) : new Date();

  const reading = await SoilMoistureReading.create({
    farmId: device.farmId,
    deviceId: device.deviceId,
    moisturePercent: body.moisturePercent,
    rawValue: body.rawValue ?? null,
    batteryVoltage: body.batteryVoltage ?? null,
    temperature: body.temperature ?? null,
    source: body.source || "device",
    recordedAt,
  });

  const soilState = getSoilStatus(body.moisturePercent);

  await SoilStatus.findOneAndUpdate(
    { farmId: device.farmId },
    {
      farmId: device.farmId,
      latestMoisturePercent: body.moisturePercent,
      latestRawValue: body.rawValue ?? null,
      latestDeviceId: device.deviceId,
      latestRecordedAt: recordedAt,
      status: soilState.status,
      recommendation: soilState.recommendation,
    },
    {
      new: true,
      upsert: true,
    }
  );

  device.lastSeenAt = new Date();
  await device.save();

  // ==============================
  // Sensor Notification Integration
  // ==============================
  const farm = await Farm.findById(device.farmId).select("ownerId").lean();

  if (farm?.ownerId) {
    const sensorAlerts = buildSensorAlertPayloads({
      ownerId: farm.ownerId,
      farmId: device.farmId,
      sensorReading: {
        _id: reading._id,
        moisturePercent: reading.moisturePercent,
        recordedAt: reading.recordedAt,
      },
    });

    await createNotificationsBulkService(sensorAlerts);
  }

  return reading;
};

export const getLatestSoilStatusService = async (farmId) => {
  return SoilStatus.findOne({ farmId });
};

export const getSoilMoistureHistoryService = async (farmId, limit = 20) => {
  return SoilMoistureReading.find({ farmId })
    .sort({ recordedAt: -1 })
    .limit(limit);
};