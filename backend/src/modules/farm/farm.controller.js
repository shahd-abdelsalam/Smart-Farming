import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import {
  upsertFarmInfoService,
  getFarmInfoService,
  setupFarmInfoService,
} from "./farm.service.js";
import { validateFarmInfo, validateFarmSetup } from "./farm.validation.js";
import { generateRecommendationsForFarm } from "../recommendation/recommendation.service.js";

const formatFarm = (farm) => ({
  id: farm._id,
  name: farm.name || "",
  farmSize: farm.farmSize,
  cropTypes: farm.cropTypes,    
  soilType: farm.soilType,
  irrigationType: farm.irrigationType,
  plantingDate: farm.plantingDate || null,
  locationText: farm.locationText,
  geo: farm.geo,
  createdAt: farm.createdAt,
  updatedAt: farm.updatedAt,
});

export const setupFarmInfo = asyncHandler(async (req, res) => {
  const errors = validateFarmSetup(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const farm = await setupFarmInfoService(req.body);

  await generateRecommendationsForFarm(farm._id, "farm_setup");

  return res.status(201).json(
    new ApiResponse(true, "Farm info created", {
      farm: formatFarm(farm),
    })
  );
});

export const saveFarmInfo = asyncHandler(async (req, res) => {
  const errors = validateFarmInfo(req.body);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const farm = await upsertFarmInfoService(req.userId, req.body);

  await generateRecommendationsForFarm(farm._id, "farm_update");

  return res.status(200).json(
    new ApiResponse(true, "Farm info saved", {
      farm: formatFarm(farm),
    })
  );
});

export const getFarmInfo = asyncHandler(async (req, res) => {
  const farm = await getFarmInfoService(req.userId);

  if (!farm) {
    return res.status(404).json({
      success: false,
      message: "Farm not found",
    });
  }

  return res.status(200).json(
    new ApiResponse(true, "Farm fetched", {
      farm: formatFarm(farm),
    })
  );
});