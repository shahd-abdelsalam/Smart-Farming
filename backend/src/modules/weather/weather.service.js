import axios from "axios";
import weatherCache from "./weather.cache.js";
import { env } from "../../config/env.js";
import ApiError from "../../utils/api-error.js";

import { buildWeatherAlertPayloads } from "../notification/notification.rules.js";
import { createNotificationsBulkService } from "../notification/notification.service.js";

const weatherClient = axios.create({
  baseURL: env.WEATHER_API_BASE_URL,
  timeout: 10000,
});

export async function fetchForecastByCoords(lat, lon, days = 10) {
  try {
    const cacheKey = `forecast:${lat}:${lon}:${days}`;
    const cached = weatherCache.get(cacheKey);

    if (cached) return cached;

    const response = await weatherClient.get("/forecast.json", {
      params: {
        key: env.WEATHER_API_KEY,
        q: `${lat},${lon}`,
        days,
        alerts: "yes",
        aqi: "no",
      },
    });

    weatherCache.set(cacheKey, response.data);
    return response.data;
  } catch (error) {
    if (error.response?.data?.error?.message) {
      throw new ApiError(
        error.response.status || 502,
        error.response.data.error.message
      );
    }

    if (error.code === "ECONNABORTED") {
      throw new ApiError(504, "Weather provider timeout");
    }

    throw new ApiError(502, "Failed to fetch weather data");
  }
}

export async function generateWeatherNotificationsForFarm(farm, rawWeather) {
  if (!farm?._id || !farm?.ownerId || !rawWeather?.forecast?.forecastday) {
    return [];
  }

  const tomorrow =
    rawWeather.forecast.forecastday[1] ||
    rawWeather.forecast.forecastday[0];

// console.log("WEATHER ALERT CHECK:", {
//   rainMm: tomorrow.day.totalprecip_mm,
//   maxTemp: tomorrow.day.maxtemp_c,
//   windSpeed: tomorrow.day.maxwind_kph,
//   date: tomorrow.date,
// });

  if (!tomorrow?.day) return [];

  const weatherAlerts = buildWeatherAlertPayloads({
    ownerId: farm.ownerId,
    farmId: farm._id,
    weather: {
      rainMm: tomorrow.day.totalprecip_mm ?? 0,
      maxTemp: tomorrow.day.maxtemp_c ?? 0,
      windSpeed: tomorrow.day.maxwind_kph ?? 0,
      date: tomorrow.date,
    },
  });

  return createNotificationsBulkService(weatherAlerts);
}