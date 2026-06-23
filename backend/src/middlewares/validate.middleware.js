const validateMiddleware = (validator, source = "body") => {
  return (req, res, next) => {
    const data = req[source];
    const errors = validator(data);

    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors,
      });
    }

    next();
  };
};

export default validateMiddleware;

