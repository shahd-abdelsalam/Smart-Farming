import {
  RECOMMENDATION_PRIORITIES,
  RECOMMENDATION_STATUSES,
  RECOMMENDATION_TYPES,
} from "./recommendation.constants.js";
import {
  getEndOfToday,
  getDaysFromNow,
  getSoilRules,
} from "./recommendation.utils.js";

export function buildIrrigationRecommendation(input) {
  const {
    ownerId,
    farmId,
    moisture,
    soilType,
    irrigationType,
    weather,
    weatherFlags,
    growthStage,
  } = input;

  if (moisture === null || moisture === undefined) return null;

  const rules = getSoilRules(soilType);

  let title = "";
  let description = "";
  let reason = "";
  let action = "";
  let priority = RECOMMENDATION_PRIORITIES.LOW;
  let notes = [];
  let schedule = [];

  if (weatherFlags.isRainExpectedSoon) {
    title = "Delay irrigation";
    description = "Rain is expected soon";
    reason = `Soil moisture is ${moisture}% and rain is expected soon`;
    action = "Recheck soil moisture after rain";
    priority = RECOMMENDATION_PRIORITIES.MEDIUM;
    notes = [
      "Avoid unnecessary irrigation before expected rain",
      "Check moisture again after rainfall",
    ];
    schedule = [
      { day: "Today", action: "Wait and monitor weather conditions" },
      { day: "Tomorrow", action: "Recheck soil moisture after rain" },
    ];
  } else if (moisture < rules.dryThreshold) {
    title = "Irrigation needed";
    description = "Soil moisture is low";
    reason = `Soil moisture is ${moisture}% which is low for ${soilType} soil`;
    action = "Add 20L water in the evening";
    priority = weatherFlags.isHot
      ? RECOMMENDATION_PRIORITIES.HIGH
      : RECOMMENDATION_PRIORITIES.MEDIUM;

    notes = [
      "Best irrigation time is evening",
      rules.irrigationHint,
      irrigationType
        ? `Recommended irrigation type: ${irrigationType}`
        : "Use the available irrigation method carefully",
    ];

    schedule = [
      { day: "Today", action: "Add 20L water in the evening" },
      { day: "Tomorrow", action: "Recheck soil moisture" },
    ];
  } else if (moisture <= rules.optimalMax) {
    title = "No irrigation needed";
    description = "Soil moisture is within the safe range";
    reason = `Soil moisture is ${moisture}% and is suitable for ${soilType} soil`;
    action = "Monitor again tomorrow";
    priority = RECOMMENDATION_PRIORITIES.LOW;
    notes = [
      "Current moisture is in the acceptable range",
      "Continue regular monitoring",
    ];
    schedule = [
      { day: "Today", action: "No irrigation needed" },
      { day: "Tomorrow", action: "Check moisture again" },
    ];
  } else {
    title = "Avoid irrigation";
    description = "Soil moisture is high";
    reason = `Soil moisture is ${moisture}% which is high for ${soilType} soil`;
    action = "Delay irrigation and monitor soil moisture later";
    priority = RECOMMENDATION_PRIORITIES.LOW;
    notes = [
      "Avoid over-irrigation",
      "High moisture may stress the crop",
    ];
    schedule = [
      { day: "Today", action: "Do not irrigate" },
      { day: "Tomorrow", action: "Check soil moisture again" },
    ];
  }

  return {
    ownerId,
    farmId,
    type: RECOMMENDATION_TYPES.IRRIGATION,
    title,
    description,
    reason,
    action,
    priority,
    status: RECOMMENDATION_STATUSES.PENDING,
    isActive: true,
    source: ["sensor", "weather", "farmInfo"],
    meta: {
      soilMoisture: moisture,
      soilType,
      irrigationType,
      growthStage,
      weatherCondition: weather?.condition ?? null,
      temperature: weather?.temperature ?? null,
      humidity: weather?.humidity ?? null,
      scanId: null,
      scanDisease: null,
      scanConfidence: null,
    },
    details: {
      schedule,
      notes,
    },
    validUntil: getEndOfToday(),
    lastTriggeredAt: new Date(),
  };
}

export function buildFertilizationRecommendation(input) {
  const {
    ownerId,
    farmId,
    moisture,
    soilType,
    irrigationType,
    weather,
    weatherFlags,
    growthStage,
  } = input;

  if (moisture === null || moisture === undefined) return null;

  let title = "";
  let description = "";
  let reason = "";
  let action = "";
  let priority = RECOMMENDATION_PRIORITIES.LOW;
  let notes = [];
  let schedule = [];

  if (weatherFlags.isRainExpectedSoon) {
    title = "Delay fertilization";
    description = "Rain may reduce fertilizer effectiveness";
    reason = "Rain is expected soon, which may reduce fertilizer absorption and effectiveness";
    action = "Wait until weather stabilizes, then recheck soil moisture before fertilizing";
    priority = RECOMMENDATION_PRIORITIES.MEDIUM;
    notes = [
      "Avoid fertilization before expected rain",
      "Recheck soil moisture after weather stabilizes",
    ];
    schedule = [
      { day: "Today", action: "Do not fertilize now" },
      { day: "Next 2 days", action: "Monitor weather and soil moisture" },
    ];
  } else if (moisture < 30) {
    title = "Delay fertilization";
    description = "Soil moisture is too low";
    reason = "Low soil moisture may reduce nutrient absorption";
    action = "Irrigate first, then apply fertilizer after moisture improves";
    priority = RECOMMENDATION_PRIORITIES.MEDIUM;
    notes = [
      "Fertilization is more effective when soil moisture is suitable",
      "Low moisture reduces nutrient absorption",
    ];
    schedule = [
      { day: "Today", action: "Do not fertilize now" },
      { day: "Day 2", action: "Recheck soil moisture before fertilization" },
    ];
  } else if (moisture >= 40 && moisture <= 60) {
    title = "Fertilization recommended";
    description = "Apply fertilizer this week";
    reason = `Soil moisture is suitable for nutrient absorption and the crop is in ${growthStage} stage`;
    action = weatherFlags.isVeryHot
      ? "Apply balanced fertilizer in the evening or after irrigation"
      : "Apply balanced fertilizer in moderate amount";
    priority = RECOMMENDATION_PRIORITIES.MEDIUM;
    notes = [
      "Use fertilizer suitable for the current growth stage",
      "Avoid over-fertilization",
      irrigationType
        ? `Coordinate fertilization with ${irrigationType} irrigation if possible`
        : "Coordinate fertilization with irrigation timing",
    ];
    schedule = [
      { day: "Today", action: "Not required immediately" },
      { day: "Day 2", action: "Apply balanced fertilizer" },
      { day: "Day 5", action: "Recheck soil moisture before next fertilization" },
    ];
  } else if (moisture > 70) {
    title = "Fertilization not recommended now";
    description = "Soil moisture is too high";
    reason = "High soil moisture may cause nutrient loss";
    action = "Wait until soil moisture stabilizes before applying fertilizer";
    priority = RECOMMENDATION_PRIORITIES.LOW;
    notes = [
      "Avoid fertilization when soil moisture is too high",
      "High moisture may reduce fertilizer efficiency",
    ];
    schedule = [
      { day: "Today", action: "Do not fertilize" },
      { day: "Next 2 days", action: "Monitor soil moisture" },
    ];
  } else {
    title = "Monitor fertilization conditions";
    description = "Conditions are not optimal yet";
    reason = `Current soil moisture is ${moisture}% and should be monitored with the current ${growthStage} stage`;
    action = "Monitor soil moisture and weather before applying fertilizer";
    priority = RECOMMENDATION_PRIORITIES.LOW;
    notes = [
      "Reassess soil moisture before fertilization",
      "Growth stage affects fertilizer timing",
    ];
    schedule = [
      { day: "Today", action: "Monitor current conditions" },
      { day: "Day 2", action: "Review fertilization decision again" },
    ];
  }

  return {
    ownerId,
    farmId,
    type: RECOMMENDATION_TYPES.FERTILIZATION,
    title,
    description,
    reason,
    action,
    priority,
    status: RECOMMENDATION_STATUSES.PENDING,
    isActive: true,
    source: ["sensor", "weather", "farmInfo"],
    meta: {
      soilMoisture: moisture,
      soilType,
      irrigationType,
      growthStage,
      weatherCondition: weather?.condition ?? null,
      temperature: weather?.temperature ?? null,
      humidity: weather?.humidity ?? null,
      scanId: null,
      scanDisease: null,
      scanConfidence: null,
    },
    details: {
      schedule,
      notes,
    },
    validUntil: getDaysFromNow(3),
    lastTriggeredAt: new Date(),
  };
}

export function buildDiseaseRecommendation(input) {
  const {
    ownerId,
    farmId,
    weather,
    weatherFlags,
    latestScan,
  } = input;

  if (!latestScan?.diseaseName) return null;
  if (latestScan.diseaseName.toLowerCase() === "healthy") return null;

  const confidence = Number(latestScan.confidence ?? 0);

  const notes = [
    "Follow treatment guidance carefully",
    "Avoid delaying treatment for detected symptoms",
  ];

  if (weatherFlags.isHumidityHigh) {
    notes.push("High humidity may increase disease spread");
  }

  const scanActions = Array.isArray(latestScan.recommendedActions)
    ? latestScan.recommendedActions
    : [];

  const schedule = [];

  if (scanActions.length > 0) {
    scanActions.forEach((item, index) => {
      schedule.push({
        day: index === 0 ? "Today" : `Step ${index + 1}`,
        action: item,
      });
    });
  } else {
    schedule.push({ day: "Today", action: "Start treatment based on the detected disease" });
    schedule.push({ day: "Day 3", action: "Re-scan the plant" });
  }

  return {
    ownerId,
    farmId,
    type: RECOMMENDATION_TYPES.DISEASE,
    title: "Disease treatment required",
    description: `${latestScan.diseaseName} detected`,
    reason: `AI scan detected ${latestScan.diseaseName} with ${confidence}% confidence`,
    action: "View disease treatment details and follow the recommended care steps",
    priority:
      confidence >= 80
        ? RECOMMENDATION_PRIORITIES.HIGH
        : RECOMMENDATION_PRIORITIES.MEDIUM,
    status: RECOMMENDATION_STATUSES.PENDING,
    isActive: true,
    source: ["scan", "weather"],
    meta: {
      soilMoisture: null,
      soilType: null,
      irrigationType: null,
      growthStage: null,
      weatherCondition: weather?.condition ?? null,
      temperature: weather?.temperature ?? null,
      humidity: weather?.humidity ?? null,
      scanId: latestScan._id ?? null,
      scanDisease: latestScan.diseaseName ?? null,
      scanConfidence: confidence,
    },
    details: {
      schedule,
      notes,
    },
    validUntil: getDaysFromNow(3),
    lastTriggeredAt: new Date(),
  };
}