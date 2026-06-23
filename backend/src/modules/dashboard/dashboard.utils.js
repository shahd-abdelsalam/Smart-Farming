function normalizeNumber(value, fallback = null) {
  if (value === undefined || value === null || Number.isNaN(Number(value))) {
    return fallback;
  }

  return Number(value);
}

export function getSoilStatus(moisturePercent) {
  const value = normalizeNumber(moisturePercent);

  if (value === null) {
    return {
      label: "Unknown",
      severity: "unknown",
    };
  }

  if (value < 30) {
    return {
      label: "Dry",
      severity: "warning",
    };
  }

  if (value <= 70) {
    return {
      label: "Normal",
      severity: "good",
    };
  }

  return {
    label: "Wet",
    severity: "info",
  };
}

export function getCropOverview(lastScan) {
  if (!lastScan) {
    return {
      label: "No scan yet",
      severity: "unknown",
      diseaseName: null,
      confidence: null,
      scanId: null,
    };
  }

  if (lastScan.isHealthy) {
    return {
      label: "Healthy",
      severity: "good",
      diseaseName: lastScan.diseaseName || "Healthy",
      confidence: lastScan.confidence ?? null,
      scanId: lastScan._id,
    };
  }

  return {
    label: "Needs Attention",
    severity: "warning",
    diseaseName: lastScan.diseaseName || "Unknown disease",
    confidence: lastScan.confidence ?? null,
    scanId: lastScan._id,
  };
}

export function getWeatherOverview(weatherRaw) {
  const today = weatherRaw?.forecast?.forecastday?.[0]?.day;

  if (!today) {
    return {
      label: "Unavailable",
      severity: "unknown",
      condition: null,
      rainChance: null,
      maxTemp: null,
      minTemp: null,
    };
  }

  const rainChance = normalizeNumber(today.daily_chance_of_rain, 0);
  const maxTemp = normalizeNumber(today.maxtemp_c);
  const minTemp = normalizeNumber(today.mintemp_c);
  const condition = today.condition?.text || "Unknown";

  if (rainChance >= 50) {
    return {
      label: "Rain expected",
      severity: "info",
      condition,
      rainChance,
      maxTemp,
      minTemp,
    };
  }

  return {
    label: "No rain",
    severity: "good",
    condition,
    rainChance,
    maxTemp,
    minTemp,
  };
}

export function getMinutesAgo(date) {
  if (!date) return null;

  const time = new Date(date).getTime();

  if (Number.isNaN(time)) return null;

  const diffMs = Date.now() - time;
  const minutes = Math.floor(diffMs / 60000);

  return minutes < 0 ? 0 : minutes;
}

export function getLastUpdateText(minutes) {
  if (minutes === null || minutes === undefined) return "No updates yet";

  if (minutes < 1) return "Just now";
  if (minutes === 1) return "1 min ago";
  if (minutes < 60) return `${minutes} min ago`;

  const hours = Math.floor(minutes / 60);

  if (hours === 1) return "1 hour ago";
  if (hours < 24) return `${hours} hours ago`;

  const days = Math.floor(hours / 24);

  if (days === 1) return "1 day ago";
  return `${days} days ago`;
}

export function getGrowthData(farm) {
  const stage = farm?.growthStage || "Vegetative";

  return {
    percent: 3,
    label: "+3% Growth",
    stage,
    chart: [
      { label: "AUG", value: 1 },
      { label: "SEP", value: 1.4 },
      { label: "OCT", value: 3 },
      { label: "NOV", value: 3.1 },
      { label: "DEC", value: 5 },
    ],
  };
}

export function buildActivities({
  latestRecommendation,
  latestNotification,
  lastScan,
}) {
  const activities = [];

  if (latestRecommendation) {
    activities.push({
      type: "recommendation",
      title: "New recommendation generated",
      message:
        latestRecommendation.title ||
        latestRecommendation.message ||
        "A new recommendation was generated for your farm.",
      createdAt: latestRecommendation.createdAt,
      refId: latestRecommendation._id,
    });
  }

  if (latestNotification) {
    activities.push({
      type: "alert",
      title: "New alert",
      message:
        latestNotification.title ||
        latestNotification.message ||
        "A new farm alert was created.",
      createdAt: latestNotification.createdAt,
      refId: latestNotification._id,
    });
  }

  if (lastScan) {
    activities.push({
      type: "scan",
      title: "Latest scan result",
      message: lastScan.isHealthy
        ? "Latest scan result: plant appears healthy."
        : `Latest scan result: ${lastScan.diseaseName || "disease"} detected.`,
      createdAt: lastScan.createdAt,
      refId: lastScan._id,
    });
  }

  return activities
    .filter((item) => item.createdAt)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, 3);
}