import Recommendation from "../../models/recommendation.model.js";
import Farm from "../../models/farm.model.js";
import SoilMoistureReading from "../../models/soil-moisture-reading.model.js";
import Scan from "../../models/scan.model.js";

import {
  buildDiseaseRecommendation,
  buildFertilizationRecommendation,
  buildIrrigationRecommendation,
} from "./recommendation.builders.js";

import {
  buildWeatherFlags,
  calculateGrowthStage,
} from "./recommendation.utils.js";

import { fetchForecastByCoords } from "../weather/weather.service.js";
import {
  mapCurrentWeather,
  mapForecastWeather,
} from "../weather/weather.mapper.js";

async function getLatestSensorReading(farmId) {
  return SoilMoistureReading.findOne({ farmId }).sort({ createdAt: -1 });
}

async function getLatestScan(farmId) {
  return Scan.findOne({ farmId }).sort({ createdAt: -1 });
}

async function getWeatherForFarm(farm) {
  const lat = farm?.geo?.lat;
  const lng = farm?.geo?.lng;

  if (lat === undefined || lng === undefined || lat === null || lng === null) {
    return {
      current: {},
      forecast: [],
    };
  }

  const weatherData = await fetchForecastByCoords(lat, lng, 3);

  return {
    current: mapCurrentWeather(weatherData),
    forecast: mapForecastWeather(weatherData),
  };
}

async function upsertRecommendation(recommendationData) {
  const existing = await Recommendation.findOne({
    farmId: recommendationData.farmId,
    type: recommendationData.type,
    status: "pending",
    isActive: true,
  });

  if (!existing) {
    return Recommendation.create(recommendationData);
  }

  existing.title = recommendationData.title;
  existing.description = recommendationData.description;
  existing.reason = recommendationData.reason;
  existing.action = recommendationData.action;
  existing.priority = recommendationData.priority;
  existing.status = "pending";
  existing.isActive = true;
  existing.source = recommendationData.source;
  existing.meta = recommendationData.meta;
  existing.details = recommendationData.details;
  existing.validUntil = recommendationData.validUntil;
  existing.lastTriggeredAt = new Date();
  existing.resolvedAt = null;

  await existing.save();
  return existing;
}

async function expireObsoleteRecommendations(farmId, activeTypes = []) {
  await Recommendation.updateMany(
    {
      farmId,
      status: "pending",
      isActive: true,
      type: { $nin: activeTypes },
    },
    {
      $set: {
        status: "expired",
        isActive: false,
        resolvedAt: new Date(),
      },
    }
  );
}

export async function generateRecommendationsForFarm(
  farmId,
  triggerType = "manual"
) {
  const farm = await Farm.findById(farmId).lean();

  if (!farm) {
    throw new Error("Farm not found for recommendation generation");
  }

  const latestSensor = await getLatestSensorReading(farmId);
  const latestScan = await getLatestScan(farmId);
  const weatherPayload = await getWeatherForFarm(farm);

  const growthStage = calculateGrowthStage(
    farm.plantingDate,
    farm.cropTypes || "Tomato"
  );

  const weatherFlags = buildWeatherFlags(
    weatherPayload.current,
    weatherPayload.forecast
  );

  const commonInput = {
    ownerId: farm.ownerId,
    farmId: farm._id,
    moisture: latestSensor?.moisturePercent ?? null,
    soilType: farm.soilType || "loamy",
    irrigationType: farm.irrigationType || null,
    growthStage,
    weather: weatherPayload.current,
    weatherFlags,
    latestScan,
    triggerType,
  };

  const candidates = [
    buildIrrigationRecommendation(commonInput),
    buildFertilizationRecommendation(commonInput),
    buildDiseaseRecommendation(commonInput),
  ].filter(Boolean);

  const savedRecommendations = [];
  const activeTypes = [];

  for (const recommendation of candidates) {
    const saved = await upsertRecommendation(recommendation);
    savedRecommendations.push(saved);
    activeTypes.push(recommendation.type);
  }

  await expireObsoleteRecommendations(farmId, activeTypes);

  return {
    farmId,
    triggerType,
    growthStage,
    generatedCount: savedRecommendations.length,
    recommendations: savedRecommendations,
  };
}

export async function getRecommendationsService({
  ownerId,
  type,
  status,
  priority,
  farmId,
}) {
  const query = { ownerId };

  if (type) query.type = type;
  if (status) query.status = status;
  if (priority) query.priority = priority;
  if (farmId) query.farmId = farmId;

  return Recommendation.find(query).sort({ createdAt: -1 });
}

export async function getRecommendationByIdService(recommendationId, ownerId) {
  return Recommendation.findOne({
    _id: recommendationId,
    ownerId,
  });
}

export async function updateRecommendationStatusService(
  recommendationId,
  ownerId,
  status
) {
  const recommendation = await Recommendation.findOne({
    _id: recommendationId,
    ownerId,
  });

  if (!recommendation) {
    throw new Error("Recommendation not found");
  }

  recommendation.status = status;
  recommendation.isActive = status === "pending";
  recommendation.resolvedAt = status === "pending" ? null : new Date();

  await recommendation.save();
  return recommendation;
}