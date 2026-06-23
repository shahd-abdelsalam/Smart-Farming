const isAdminMiddleware = (req, res, next) => {
  if (req.role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "Admin only",
    });
  }

  next();
};

export default isAdminMiddleware;