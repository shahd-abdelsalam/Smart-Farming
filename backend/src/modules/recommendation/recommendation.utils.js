import { SOIL_RULES, WEATHER_RULES } from "./recommendation.constants.js";

export function getSoilRules(soilType = "loamy") {
  return SOIL_RULES[soilType] || SOIL_RULES.loamy;
}

export function buildWeatherFlags(weather = {}, forecast = []) {
  const currentTemperature = Number(weather?.temperature ?? 0);
  const currentHumidity = Number(weather?.humidity ?? 0);
  const windSpeed = Number(weather?.windSpeed ?? 0);

  return {
    isHot: currentTemperature >= WEATHER_RULES.hotThreshold,
    isVeryHot: currentTemperature >= WEATHER_RULES.veryHotThreshold,
    isHumidityHigh: currentHumidity >= WEATHER_RULES.highHumidityThreshold,
    isWindHigh: windSpeed >= WEATHER_RULES.highWindThreshold,
    isRainExpectedSoon: forecast.slice(0, 3).some((day) => day?.willRain === true),
  };
}

export function calculateGrowthStage(plantingDate, cropType = "Tomato") {
  if (!plantingDate) return "Unknown";

  const today = new Date();
  const plantedAt = new Date(plantingDate);

  const diffMs = today - plantedAt;
  const daysSincePlanting = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (cropType === "Tomato") {
    if (daysSincePlanting <= 20) return "Seedling";
    if (daysSincePlanting <= 50) return "Vegetative";
    if (daysSincePlanting <= 80) return "Flowering";
    return "Fruiting";
  }

  return "Unknown";
}

export function getEndOfToday() {
  const now = new Date();
  const end = new Date(now);
  end.setHours(23, 59, 59, 999);
  return end;
}

export function getDaysFromNow(days = 1) {
  const now = new Date();
  now.setDate(now.getDate() + days);
  return now;
}