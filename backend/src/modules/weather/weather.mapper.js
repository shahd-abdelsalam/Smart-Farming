function getWeatherAdvice(current, alerts = []) {
  const condition = current?.condition?.toLowerCase() || "";

  if (alerts.length > 0) {
    return "Check weather alerts before irrigation or field work";
  }

  if (condition.includes("rain")) {
    return "Rain is expected, avoid irrigation today if possible";
  }

  if (current?.tempC >= 35) {
    return "High temperature today, monitor soil moisture closely";
  }

  return "Weather conditions look stable today";
}

function mapDailyForecast(forecastDays = []) {
  return forecastDays.map((day) => ({
    date: day.date,
    maxTempC: day.day?.maxtemp_c,
    minTempC: day.day?.mintemp_c,
    avgTempC: day.day?.avgtemp_c,
    avgHumidity: day.day?.avghumidity,
    chanceOfRain: day.day?.daily_chance_of_rain,
    condition: day.day?.condition?.text,
    conditionIcon: day.day?.condition?.icon,
    uv: day.day?.uv,
    sunrise: day.astro?.sunrise,
    sunset: day.astro?.sunset,
  }));
}

function mapHourlyForecast(hours = []) {
  return hours.map((hour) => ({
    time: hour.time,
    tempC: hour.temp_c,
    feelsLikeC: hour.feelslike_c,
    humidity: hour.humidity,
    windKph: hour.wind_kph,
    chanceOfRain: hour.chance_of_rain,
    condition: hour.condition?.text,
    conditionIcon: hour.condition?.icon,
    isDay: hour.is_day,
  }));
}

function mapAlerts(alerts = []) {
  return alerts.map((alert) => ({
    headline: alert.headline,
    severity: alert.severity,
    urgency: alert.urgency,
    event: alert.event,
    areas: alert.areas,
    effective: alert.effective,
    expires: alert.expires,
    desc: alert.desc,
  }));
}

export function mapWeatherSummary(raw) {
  const location = raw.location || {};
  const current = raw.current || {};
  const forecastDays = raw.forecast?.forecastday || [];
  const today = forecastDays[0] || {};
  const mappedAlerts = mapAlerts(raw.alerts?.alert || []);

  return {
    location: {
      name: location.name,
      region: location.region,
      country: location.country,
      lat: location.lat,
      lon: location.lon,
      localtime: location.localtime,
      tzId: location.tz_id,
    },
    current: {
      tempC: current.temp_c,
      tempF: current.temp_f,
      feelsLikeC: current.feelslike_c,
      humidity: current.humidity,
      windKph: current.wind_kph,
      uv: current.uv,
      visibilityKm: current.vis_km,
      pressureMb: current.pressure_mb,
      condition: current.condition?.text,
      conditionIcon: current.condition?.icon,
      isDay: current.is_day,
      lastUpdated: current.last_updated,
    },
    astronomy: {
      sunrise: today.astro?.sunrise,
      sunset: today.astro?.sunset,
      moonrise: today.astro?.moonrise,
      moonset: today.astro?.moonset,
      moonPhase: today.astro?.moon_phase,
      moonIllumination: today.astro?.moon_illumination,
    },
    highlights: {
      windKph: current.wind_kph,
      humidity: current.humidity,
      uv: current.uv,
      visibilityKm: current.vis_km,
    },
    advice: getWeatherAdvice(
      {
        condition: current.condition?.text,
        tempC: current.temp_c,
      },
      mappedAlerts
    ),
    todayHourly: mapHourlyForecast(today.hour || []),
    dailyForecast: mapDailyForecast(forecastDays),
    alerts: mappedAlerts,
  };
}

export function mapLocationSearchResults(raw = []) {
  return raw.map((item) => ({
    id: item.id || null,
    name: item.name,
    region: item.region,
    country: item.country,
    lat: item.lat,
    lon: item.lon,
    url: item.url,
  }));
}

/**
 * Recommendation System mappers
 * دول مخصصين للـ recommendation module
 */

export function mapCurrentWeather(raw) {
  return {
    temperature: raw?.current?.temp_c ?? null,
    condition: raw?.current?.condition?.text ?? null,
    humidity: raw?.current?.humidity ?? null,
    windSpeed: raw?.current?.wind_kph ?? null,
  };
}

export function mapForecastWeather(raw) {
  return Array.isArray(raw?.forecast?.forecastday)
    ? raw.forecast.forecastday.map((day) => ({
        date: day.date,
        willRain:
          (day?.day?.daily_chance_of_rain
            ? Number(day.day.daily_chance_of_rain)
            : 0) >= 50,
        condition: day?.day?.condition?.text ?? null,
      }))
    : [];
}