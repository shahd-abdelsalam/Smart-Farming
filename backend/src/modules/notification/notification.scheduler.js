import cron from "node-cron";
import { buildSystemAlertPayloads } from "./notification.rules.js";
import { createNotificationsBulkService } from "./notification.service.js";

import Farm from "../../models/farm.model.js";
import Scan from "../../models/scan.model.js";
import SensorReading from "../../models/soil-moisture-reading.model.js";

const HOURS_24 = 24 * 60 * 60 * 1000;
const DAYS_3 = 3 * HOURS_24;

const checkFarmProfileIncomplete = (farm) => {
  if (!farm) return true;

  return !farm.name || !farm.soilType || !farm.locationText;
};

const runSystemNotificationChecks = async () => {
  const farms = await Farm.find({}).select("_id ownerId name soilType locationText").lean();

  for (const farm of farms) {
    const lastScan = await Scan.findOne({ farmId: farm._id })
      .sort({ createdAt: -1 })
      .select("_id createdAt")
      .lean();

    const lastSensorReading = await SensorReading.findOne({ farmId: farm._id })
      .sort({ createdAt: -1 })
      .select("_id createdAt recordedAt")
      .lean();

    const lastScanDate = lastScan?.createdAt ? new Date(lastScan.createdAt) : null;
    const lastSensorDate = lastSensorReading?.recordedAt
      ? new Date(lastSensorReading.recordedAt)
      : lastSensorReading?.createdAt
      ? new Date(lastSensorReading.createdAt)
      : null;

    const hasRecentScan =
      !!lastScanDate && Date.now() - lastScanDate.getTime() <= DAYS_3;

    const hasRecentSensorReading =
      !!lastSensorDate && Date.now() - lastSensorDate.getTime() <= HOURS_24;

    const payloads = buildSystemAlertPayloads({
      ownerId: farm.ownerId,
      farmId: farm._id,
      hasRecentScan,
      hasRecentSensorReading,
      isFarmProfileIncomplete: checkFarmProfileIncomplete(farm),
    });

    await createNotificationsBulkService(payloads);
  }
};

const startNotificationScheduler = () => {
  // كل يوم 9 صباحًا
  cron.schedule("0 9 * * *", async () => {
    try {
      await runSystemNotificationChecks();
      console.log("Notification scheduler: system checks completed.");
    } catch (error) {
      console.error("Notification scheduler error:", error.message);
    }
  });

  console.log("Notification scheduler started.");
};

export default startNotificationScheduler;