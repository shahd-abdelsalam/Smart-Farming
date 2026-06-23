import asyncHandler from "../../utils/async-handler.js";
import { validateSoilMoistureReading } from "./sensor.validation.js";
import {
  saveSoilMoistureReadingService,
  getLatestSoilStatusService,
  getSoilMoistureHistoryService,
} from "./sensor.service.js";
import Farm from "../../models/farm.model.js";
import { generateRecommendationsForFarm } from "../recommendation/recommendation.service.js";

export const receiveSoilMoistureReading = asyncHandler(async (req, res) => {
  const errors = validateSoilMoistureReading(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const reading = await saveSoilMoistureReadingService(req.sensorDevice, req.body);

  if (reading?.farmId) {
    await generateRecommendationsForFarm(reading.farmId, "sensor_update");
  }

  res.status(201).json({
    success: true,
    message: "Soil moisture reading received successfully",
    data: {
      readingId: reading._id,
      deviceId: reading.deviceId,
      farmId: reading.farmId,
      moisturePercent: reading.moisturePercent,
      receivedAt: reading.createdAt,
    },
  });
});

export const getMyLatestSoilStatus = asyncHandler(async (req, res) => {
  const farm = await Farm.findOne({ ownerId: req.userId });

  if (!farm) {
    return res.status(404).json({
      success: false,
      message: "Farm not found",
    });
  }

  const status = await getLatestSoilStatusService(farm._id);

  if (!status) {
    return res.status(404).json({
      success: false,
      message: "No soil status found yet",
    });
  }

  res.status(200).json({
    success: true,
    message: "Latest soil status fetched successfully",
    data: status,
  });
});

export const getMySoilHistory = asyncHandler(async (req, res) => {
  const farm = await Farm.findOne({ ownerId: req.userId });

  if (!farm) {
    return res.status(404).json({
      success: false,
      message: "Farm not found",
    });
  }

  const limit = Number(req.query.limit) || 20;
  const history = await getSoilMoistureHistoryService(farm._id, limit);

  res.status(200).json({
    success: true,
    message: "Soil moisture history fetched successfully",
    data: history,
  });
});