import Farm from "../../models/farm.model.js";
import Scan from "../../models/scan.model.js";
import SoilMoistureReading from "../../models/soil-moisture-reading.model.js";
import Recommendation from "../../models/recommendation.model.js";
import Notification from "../../models/notification.model.js";
import { fetchForecastByCoords } from "../weather/weather.service.js";

import {
  getSoilStatus,
  getCropOverview,
  getWeatherOverview,
  getMinutesAgo,
  getLastUpdateText,
  getGrowthData,
  buildActivities,
} from "./dashboard.utils.js";

export async function getHomeDashboardService(ownerId) {
  const farm = await Farm.findOne({ ownerId });

  if (!farm) {
    return {
      farm: null,

      overview: {
        crop: {
          label: "No farm data",
          severity: "unknown",
        },
        soil: {
          label: "Unknown",
          severity: "unknown",
        },
        weather: {
          label: "Unavailable",
          severity: "unknown",
        },
      },

      growth: getGrowthData(null),

      quickStats: {
        soilMoisture: null,
        soilStatus: "Unknown",
        lastUpdateMinutes: null,
        lastUpdateText: "No updates yet",
      },

      activities: [],
    };
  }

  const [
    lastScan,
    lastSensorReading,
    latestRecommendation,
    latestNotification,
  ] = await Promise.all([
    Scan.findOne({ ownerId }).sort({ createdAt: -1 }),

    SoilMoistureReading.findOne({ farmId: farm._id }).sort({
      recordedAt: -1,
      createdAt: -1,
    }),

    Recommendation.findOne({ ownerId }).sort({ createdAt: -1 }),

    Notification.findOne({ ownerId }).sort({ createdAt: -1 }),
  ]);

  let weatherRaw = null;

  if (farm.geo?.lat && farm.geo?.lng) {
    try {
      weatherRaw = await fetchForecastByCoords(farm.geo.lat, farm.geo.lng, 10);
    } catch (error) {
      weatherRaw = null;
    }
  }

  const soilMoisture = lastSensorReading?.moisturePercent ?? null;
  const soil = getSoilStatus(soilMoisture);

  const lastUpdateDate =
    lastSensorReading?.recordedAt ||
    lastSensorReading?.createdAt ||
    lastScan?.createdAt ||
    latestRecommendation?.createdAt ||
    latestNotification?.createdAt ||
    null;

  const lastUpdateMinutes = getMinutesAgo(lastUpdateDate);

  return {
    farm: {
      id: farm._id,
      name: farm.name || "My Farm",
      location: farm.locationText || "",
      cropTypes: farm.cropTypes || "",
      soilType: farm.soilType || "",
      irrigationType: farm.irrigationType || "",
      growthStage: farm.growthStage || "Vegetative",
    },

    overview: {
      crop: getCropOverview(lastScan),
      soil,
      weather: getWeatherOverview(weatherRaw),
    },

    growth: getGrowthData(farm),

    quickStats: {
      soilMoisture,
      soilStatus: soil.label,
      lastUpdateMinutes,
      lastUpdateText: getLastUpdateText(lastUpdateMinutes),
    },

    activities: buildActivities({
      latestRecommendation,
      latestNotification,
      lastScan,
    }),
  };
}