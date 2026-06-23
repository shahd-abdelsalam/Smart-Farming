import fs from "fs";
import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import { validateCreateScan, validateScanId } from "./scan.validation.js";
import {
  analyzeImageWithAIService,
  saveScanResult,
  getMyScansService,
  getScanByIdService,
  getScanOverviewService,
  getDynamicInsightService,
} from "./scan.service.js";
import Farm from "../../models/farm.model.js";
import { generateRecommendationsForFarm } from "../recommendation/recommendation.service.js";

async function buildScanResultResponse(scan) {
  const isHealthy = String(scan.diseaseName || "")
    .toLowerCase()
    .includes("healthy");

  const insight = await getDynamicInsightService({
    userId: scan.ownerId,
    farmId: scan.farmId,
    diseaseName: scan.diseaseName,
    isHealthy,
  });

  return {
    id: scan._id,
    image: scan.imageUrl,
    disease: {
      name: scan.diseaseName,
      confidence: scan.confidence,
      isHealthy,
    },
    details: {
      description: scan.description,
      actions: scan.recommendedActions,
      insight,
    },
    createdAt: scan.createdAt,
  };
}

function buildScanCardResponse(scan) {
  return {
    id: scan._id,
    image: scan.imageUrl,
    title: "Tomato plant",
    subtitle: scan.diseaseName,
    confidence: scan.confidence,
    isHealthy: String(scan.diseaseName || "").toLowerCase().includes("healthy"),
    createdAt: scan.createdAt,
  };
}

export const getScanOverviewController = asyncHandler(async (req, res) => {
  const overview = await getScanOverviewService(req.userId);

  return res.status(200).json(
    new ApiResponse(true, "Scan overview fetched successfully", {
      totalTests: overview.totalTests,
      avgScore: overview.avgScore,
      performanceStatus: overview.performanceStatus,
      recentTests: overview.recentTests.map(buildScanCardResponse),
    })
  );
});

export const createScanController = asyncHandler(async (req, res) => {
  const errors = validateCreateScan(req.body, req.file);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const farm = await Farm.findOne({ ownerId: req.userId });

  if (!farm) {
    if (req.file?.path && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    return res.status(404).json({
      success: false,
      message: "Farm not found",
    });
  }

  const imageUrl = `/uploads/scans/${req.file.filename}`;

  try {
    const aiResponse = await analyzeImageWithAIService(req.file.path);

    if (!aiResponse.success) {
      if (fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
      }

      return res.status(500).json({
        success: false,
        message: aiResponse.message || "Failed to analyze image. Please try again.",
      });
    }

    const scan = await saveScanResult({
      userId: req.userId,
      farmId: farm._id,
      imageUrl,
      source: req.body.source,
      aiResult: aiResponse,
    });

    await generateRecommendationsForFarm(farm._id, "scan_update");

    return res.status(201).json(
      new ApiResponse(true, "Scan analyzed successfully", {
        scan: await buildScanResultResponse(scan),
      })
    );
  } catch (error) {
    if (req.file?.path && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    throw error;
  }
});

export const getMyScansController = asyncHandler(async (req, res) => {
  const scans = await getMyScansService(req.userId);

  return res.status(200).json(
    new ApiResponse(true, "Scans fetched successfully", {
      scans: scans.map(buildScanCardResponse),
    })
  );
});

export const getScanByIdController = asyncHandler(async (req, res) => {
  const errors = validateScanId(req.params);

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation error",
      errors,
    });
  }

  const scan = await getScanByIdService(req.userId, req.params.id);

  if (!scan) {
    return res.status(404).json({
      success: false,
      message: "Scan not found",
    });
  }

  return res.status(200).json(
    new ApiResponse(true, "Scan fetched successfully", {
      scan: await buildScanResultResponse(scan),
    })
  );
});