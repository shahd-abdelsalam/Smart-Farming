import fs from "fs";
import axios from "axios";
import FormData from "form-data";
import Scan from "../../models/scan.model.js";
import { env } from "../../config/env.js";
import { buildScanAlertPayloads } from "../notification/notification.rules.js";
import { createNotificationsBulkService } from "../notification/notification.service.js";

const diseaseDetailsMap = {
  "bacterial spot": {
    description:
      "A bacterial disease that causes dark spots on leaves and can reduce crop quality.",
    recommendedActions: [
      "Remove infected leaves immediately",
      "Avoid overhead watering",
      "Disinfect gardening tools",
      "Use copper-based bactericide if necessary",
    ],
  },

  "early blight": {
    description:
      "A fungal disease that causes concentric dark spots on older leaves.",
    recommendedActions: [
      "Prune infected leaves",
      "Improve air circulation",
      "Avoid wetting leaves during irrigation",
      "Apply fungicide regularly",
    ],
  },

  "late blight": {
    description:
      "A fast-spreading disease that affects leaves and stems in humid conditions.",
    recommendedActions: [
      "Remove infected parts quickly",
      "Reduce humidity around the plant",
      "Avoid overhead irrigation",
      "Apply appropriate fungicide",
    ],
  },

  "leaf mold": {
    description:
      "A fungal disease that appears as yellow spots on the upper leaf surface.",
    recommendedActions: [
      "Improve ventilation",
      "Reduce humidity levels",
      "Remove affected leaves",
      "Use fungicide if necessary",
    ],
  },

  "septoria leaf spot": {
    description:
      "A common fungal disease causing small circular spots on leaves.",
    recommendedActions: [
      "Remove infected leaves",
      "Avoid overhead watering",
      "Use mulch to prevent soil splash",
      "Apply fungicide treatment",
    ],
  },

  "spider mites two spotted spider mite": {
    description:
      "Tiny pests that feed on plant sap causing yellowing and leaf damage.",
    recommendedActions: [
      "Spray plants with water to reduce mites",
      "Use insecticidal soap",
      "Maintain proper plant humidity",
      "Apply miticide if infestation is severe",
    ],
  },

  "target spot": {
    description:
      "A fungal disease that causes circular lesions with concentric rings.",
    recommendedActions: [
      "Remove infected leaves",
      "Improve airflow around the plant",
      "Avoid excessive moisture",
      "Apply fungicide treatment",
    ],
  },

  "tomato yellow leaf curl virus": {
    description:
      "A viral disease that causes yellowing, curling, and stunted growth.",
    recommendedActions: [
      "Remove infected plants immediately",
      "Control whitefly population",
      "Use resistant tomato varieties",
      "Avoid planting near infected crops",
    ],
  },

  "tomato mosaic virus": {
    description:
      "A viral disease that causes mottled leaves and reduced plant growth.",
    recommendedActions: [
      "Remove infected plants",
      "Disinfect tools regularly",
      "Avoid tobacco contamination",
      "Use virus-free seeds",
    ],
  },

  "healthy": {
    description: "The plant appears healthy with no visible signs of disease.",
    recommendedActions: [
      "Continue regular monitoring",
      "Maintain proper irrigation",
      "Follow fertilization schedule",
    ],
  },
};

function getPredictedClassFromAI(aiResult) {
  return (
    aiResult.predicted_class ||
    aiResult.predictedClass ||
    aiResult.class_name ||
    aiResult.className ||
    aiResult.raw_class_name ||
    aiResult.prediction ||
    aiResult.result ||
    aiResult.label ||
    aiResult.top_predictions?.[0]?.raw_class_name ||
    aiResult.top_predictions?.[0]?.class_name ||
    aiResult.top_predictions?.[0]?.className ||
    aiResult.top_predictions?.[0]?.name ||
    aiResult.top_predictions?.[0]?.label ||
    "Unknown"
  );
}

function getConfidenceFromAI(aiResult) {
  const confidence =
    aiResult.confidence ??
    aiResult.score ??
    aiResult.probability ??
    aiResult.top_predictions?.[0]?.confidence ??
    aiResult.top_predictions?.[0]?.score ??
    0;

  return Number(confidence);
}

function formatDiseaseName(rawName) {
  if (!rawName) return "Unknown";

  return String(rawName)
    .replace("Tomato___", "")
    .replace("Tomato__", "")
    .replace("Tomato_", "")
    .replace(/_/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function normalizeDiseaseKey(name) {
  return String(name || "")
    .toLowerCase()
    .replace(/^tomato\s+/, "")
    .replace(/___/g, " ")
    .replace(/__/g, " ")
    .replace(/_/g, " ")
    .replace(/-/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function getDiseaseDetails(diseaseName) {
  const key = normalizeDiseaseKey(diseaseName);

  const normalizedMap = Object.fromEntries(
    Object.entries(diseaseDetailsMap).map(([mapKey, value]) => [
      normalizeDiseaseKey(mapKey),
      value,
    ])
  );

  return (
    normalizedMap[key] || {
      description: "No detailed description available for this condition.",
      recommendedActions: [
        "Monitor the plant carefully",
        "Scan again with better image quality",
        "Consult an agricultural expert",
      ],
    }
  );
}

function normalizePrediction(aiResult) {
  console.log("AI RESULT FROM MODEL:", aiResult);

  const rawName = getPredictedClassFromAI(aiResult);
  const cleanName = formatDiseaseName(rawName);

  return {
    predictedClass: rawName,
    diseaseName: cleanName,
    confidence: getConfidenceFromAI(aiResult),
    isHealthy:
      aiResult.is_healthy ??
      aiResult.isHealthy ??
      cleanName.toLowerCase().includes("healthy"),
  };
}

async function buildScanInsight(userId, farmId, diseaseName, isHealthy) {
  const query = farmId ? { ownerId: userId, farmId } : { ownerId: userId };

  const recentScans = await Scan.find(query).sort({ createdAt: -1 }).limit(5);

  if (recentScans.length === 0) {
    return isHealthy
      ? "This is the first healthy scan recorded for this farm."
      : "This is the first detected case of this condition for this farm.";
  }

  const repeatedCount = recentScans.filter(
    (scan) =>
      String(scan.diseaseName).toLowerCase() ===
      String(diseaseName).toLowerCase()
  ).length;

  if (isHealthy) {
    const healthyCount = recentScans.filter((scan) =>
      String(scan.diseaseName).toLowerCase().includes("healthy")
    ).length;

    if (healthyCount >= 2) {
      return "Healthy results have appeared repeatedly in recent scans for this farm.";
    }

    return "The current scan shows a healthy plant condition.";
  }

  if (repeatedCount >= 3) {
    return "This disease has appeared multiple times in recent scans for this farm.";
  }

  if (repeatedCount >= 1) {
    return "This condition has been detected before in recent scans for this farm.";
  }

  return "This is the first recent detection of this condition for this farm.";
}

export const analyzeImageWithAIService = async (filePath) => {
  try {
    const form = new FormData();
    form.append("file", fs.createReadStream(filePath));

    console.log("AI URL:", `${env.AI_SERVICE_BASE_URL}/predict`);
    console.log("File sent to AI:", filePath);

    const response = await axios.post(`${env.AI_SERVICE_BASE_URL}/predict`, form, {
      headers: form.getHeaders(),
      timeout: 15000,
    });

    console.log("FULL AI RESPONSE:", JSON.stringify(response.data, null, 2));

    return response.data;
  } catch (error) {
    console.log("AI ERROR:", error.message);

    if (error.code === "ECONNABORTED") {
      return {
        success: false,
        message: "AI service timeout",
      };
    }

    if (error.code === "ECONNREFUSED") {
      return {
        success: false,
        message: "AI service is not available",
      };
    }

    if (error.response?.data) {
      return {
        success: false,
        message:
          error.response.data.message ||
          error.response.data.error ||
          "AI service returned an error",
      };
    }

    return {
      success: false,
      message: "Failed to connect to AI service",
    };
  }
};

export const saveScanResult = async ({
  userId,
  farmId,
  imageUrl,
  source,
  aiResult,
}) => {
  const normalized = normalizePrediction(aiResult);
  const details = getDiseaseDetails(normalized.diseaseName);

  const scan = await Scan.create({
    ownerId: userId,
    farmId,
    imageUrl,
    source: source || "camera",
    predictedClass: normalized.predictedClass,
    diseaseName: normalized.diseaseName,
    confidence: normalized.confidence,
    description: details.description,
    recommendedActions: details.recommendedActions,
    rawModelResponse: aiResult,
  });

  const scanAlerts = buildScanAlertPayloads({
    ownerId: userId,
    farmId,
    scan: {
      _id: scan._id,
      diseaseName: scan.diseaseName,
      predictedClass: scan.predictedClass,
      confidence: scan.confidence,
      isHealthy: normalized.isHealthy,
    },
  });

  if (scanAlerts.length > 0) {
    await createNotificationsBulkService(scanAlerts);
  }

  return scan;
};

export const getMyScansService = async (userId) => {
  return await Scan.find({ ownerId: userId }).sort({ createdAt: -1 });
};

export const getScanByIdService = async (userId, scanId) => {
  return await Scan.findOne({ _id: scanId, ownerId: userId });
};

export const getScanOverviewService = async (userId) => {
  const scans = await Scan.find({ ownerId: userId }).sort({ createdAt: -1 });

  const totalTests = scans.length;

  const avgScore =
    totalTests > 0
      ? Math.round(
          scans.reduce((sum, scan) => sum + (scan.confidence || 0), 0) /
            totalTests
        )
      : 0;

  let performanceStatus = "Low";

  if (avgScore >= 80) {
    performanceStatus = "Satisfied";
  } else if (avgScore >= 50) {
    performanceStatus = "Average";
  }

  const recentTests = scans.slice(0, 5);

  return {
    totalTests,
    avgScore,
    performanceStatus,
    recentTests,
  };
};

export const getDynamicInsightService = async ({
  userId,
  farmId,
  diseaseName,
  isHealthy,
}) => {
  return await buildScanInsight(userId, farmId, diseaseName, isHealthy);
};