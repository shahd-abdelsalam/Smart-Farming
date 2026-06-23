import Farm from "../../models/farm.model.js";
import ApiResponse from "../../utils/api-response.js";
import {
  generateRecommendationsForFarm,
  getRecommendationByIdService,
  getRecommendationsService,
  updateRecommendationStatusService,
} from "./recommendation.service.js";
import {
  validateGenerateRecommendations,
  validateRecommendationStatusUpdate,
} from "./recommendation.validator.js";

export async function generateRecommendationsController(req, res, next) {
  try {
    const errors = validateGenerateRecommendations(req.body);

    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors,
      });
    }

    const farm = await Farm.findOne({
      _id: req.body.farmId,
      ownerId: req.userId,
    });

    if (!farm) {
      return res.status(404).json({
        success: false,
        message: "Farm not found",
      });
    }

    const result = await generateRecommendationsForFarm(
      req.body.farmId,
      "manual"
    );

    return res.status(200).json(
      new ApiResponse(true, "Recommendations generated successfully", result)
    );
  } catch (error) {
    next(error);
  }
}

export async function getRecommendationsController(req, res, next) {
  try {
    const recommendations = await getRecommendationsService({
      ownerId: req.userId,
      type: req.query.type,
      status: req.query.status,
      priority: req.query.priority,
      farmId: req.query.farmId,
    });

    return res.status(200).json(
      new ApiResponse(true, "Recommendations fetched successfully", {
        recommendations,
      })
    );
  } catch (error) {
    next(error);
  }
}

export async function getRecommendationByIdController(req, res, next) {
  try {
    const recommendation = await getRecommendationByIdService(
      req.params.id,
      req.userId
    );

    if (!recommendation) {
      return res.status(404).json({
        success: false,
        message: "Recommendation not found",
      });
    }

    return res.status(200).json(
      new ApiResponse(true, "Recommendation fetched successfully", {
        recommendation,
      })
    );
  } catch (error) {
    next(error);
  }
}

export async function updateRecommendationStatusController(req, res, next) {
  try {
    const errors = validateRecommendationStatusUpdate(req.body);

    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors,
      });
    }

    const recommendation = await updateRecommendationStatusService(
      req.params.id,
      req.userId,
      req.body.status
    );

    return res.status(200).json(
      new ApiResponse(true, "Recommendation status updated successfully", {
        recommendation,
      })
    );
  } catch (error) {
    next(error);
  }
}