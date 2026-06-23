import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import Farm from "../../models/farm.model.js";
import {
  fetchForecastByCoords,
  generateWeatherNotificationsForFarm,
} from "./weather.service.js";
import { mapWeatherSummary } from "./weather.mapper.js";

export const getMyFarmWeatherController = asyncHandler(async (req, res) => {
  const farm = await Farm.findOne({ ownerId: req.userId });

  if (!farm) {
    return res.status(404).json({
      success: false,
      message: "Farm not found",
    });
  }

  if (!farm.geo || farm.geo.lat == null || farm.geo.lng == null) {
    return res.status(400).json({
      success: false,
      message: "Farm location is missing",
    });
  }

  const raw = await fetchForecastByCoords(farm.geo.lat, farm.geo.lng, 10);

  // Generate weather alerts from forecast data
  await generateWeatherNotificationsForFarm(farm, raw);

  const mapped = mapWeatherSummary(raw);

  return res.status(200).json(
    new ApiResponse(true, "Farm weather fetched successfully", {
      weather: mapped,
    })
  );
});