import swaggerJSDoc from "swagger-jsdoc";

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Smart Farming API",
      version: "1.0.0",
    },
    servers: [
      {
        url: "http://localhost:3000",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
    tags: [
  { name: "Auth" },
  { name: "Profile" },
  { name: "Farm" },
  { name: "Dashboard" },
  { name: "Scan" },
  { name: "Weather" },
  { name: "Sensor" },
  { name: "Recommendations" },
  { name: "Notifications" },
]
  },
  apis: ["./src/modules/**/*.js"],
};

const swaggerSpec = swaggerJSDoc(options);

export default swaggerSpec;