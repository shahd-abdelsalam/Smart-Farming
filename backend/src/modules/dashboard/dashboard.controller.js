import asyncHandler from "../../utils/async-handler.js";
import ApiResponse from "../../utils/api-response.js";
import ApiError from "../../utils/api-error.js";
import { getHomeDashboardService } from "./dashboard.service.js";

export const getHomeDashboard = asyncHandler(async (req, res) => {
  const ownerId =
    req.user?._id ||
    req.user?.id ||
    req.userId ||
    req.authUser?._id ||
    req.authUser?.id;

  if (!ownerId) {
    throw new ApiError(false, "Unauthorized: user id not found");
  }

  const dashboard = await getHomeDashboardService(ownerId);

  return res
    .status(200)
    .json(
      new ApiResponse(
        true,
        "Home dashboard fetched successfully",
        dashboard
      )
    );
});