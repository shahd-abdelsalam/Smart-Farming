import Farm from "../../models/farm.model.js";
import User from "../../models/user.model.js";
import ApiError from "../../utils/api-error.js";

export const upsertFarmInfoService = async (userId, body) => {
  const {
    name,
    farmSize,
    cropTypes,
    soilType,
    irrigationType,
    plantingDate,
    locationText,
    geo,
  } = body;

  const farm = await Farm.findOneAndUpdate(
    { ownerId: userId },
    {
      ownerId: userId,
      name: name ?? "",
      farmSize,
      cropTypes,
      soilType,
      irrigationType,
      plantingDate,
      locationText: locationText ?? "",
      geo: {
        lat: geo?.lat ?? null,
        lng: geo?.lng ?? null,
      },
    },
    {
      new: true,
      upsert: true,
      runValidators: true,
    }
  );

  return farm;
};

export const getFarmInfoService = async (userId) => {
  const farm = await Farm.findOne({ ownerId: userId });
  return farm;
};

export const setupFarmInfoService = async (body) => {
  const {
    email,
    name,
    farmSize,
    cropTypes,
    soilType,
    irrigationType,
    plantingDate,
    locationText,
    geo,
  } = body;

  const normalizedEmail = email.toLowerCase().trim();

  const user = await User.findOne({ email: normalizedEmail });

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  if (!user.emailVerified) {
    throw new ApiError(403, "Email is not verified");
  }

  const existingFarm = await Farm.findOne({ ownerId: user._id });

  if (existingFarm) {
    throw new ApiError(400, "Farm info already exists");
  }

  const farm = await Farm.create({
    ownerId: user._id,
    name: name ?? "",
    farmSize,
    cropTypes,
    soilType,
    irrigationType,
    plantingDate,
    locationText: locationText ?? "",
    geo: {
      lat: geo?.lat ?? null,
      lng: geo?.lng ?? null,
    },
  });

  return farm;
};