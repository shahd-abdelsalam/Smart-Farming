import SensorDevice from "../models/sensor-device.model.js";

const sensorAuthMiddleware = async (req, res, next) => {
  try {
    const deviceId = req.headers["x-device-id"];
    const deviceToken = req.headers["x-device-token"];

    if (!deviceId || !deviceToken) {
      return res.status(401).json({
        success: false,
        message: "Missing device credentials",
      });
    }

    const device = await SensorDevice.findOne({
      deviceId: deviceId.toString(),
      isActive: true,
    });

    if (!device) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized device",
      });
    }

    if (device.deviceToken !== deviceToken.toString()) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized device",
      });
    }

    req.sensorDevice = device;
    next();
  } catch (err) {
    next(err);
  }
};

export default sensorAuthMiddleware;