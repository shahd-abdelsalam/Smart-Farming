import express from "express";
import cors from "cors";
import morgan from "morgan";
import path from "path";
import routes from "./routes/index.js";
import errorMiddleware from "./middlewares/error.middleware.js";
import startNotificationScheduler from "./modules/notification/notification.scheduler.js";
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./docs/swagger.js";

const app = express();

app.use(cors());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use("/uploads", express.static(path.resolve("uploads")));

app.get("/", (req, res) => {
  res.send("Backend is running");
});

app.use("/api", routes);

app.use(errorMiddleware);

startNotificationScheduler();

export default app;