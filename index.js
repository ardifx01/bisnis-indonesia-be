import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import session from "express-session";
import "./config/passport.js";
import passport from "passport";
import UserRoute from "./routes/UserRoute.js";
import ArticleRoute from "./routes/ArticleRoute.js";
import VideoRoute from "./routes/VideoRoute.js";
import AuthRoute from "./routes/AuthRoute.js";
import FileUpload from "express-fileupload";
import db from "./config/Database.js";
// import { syncModels } from "./config/syncModels.js";

const app = express();

// Database connection and sync
(async () => {
  try {
    console.log("Attempting database connection...");
    await db.authenticate();
    console.log("PostgreSQL connection established successfully!");

    // Manual sync models
    // await syncModels();

    // Test query untuk memastikan connection benar-benar jalan
    const result = await db.query("SELECT version();");
    console.log("PostgreSQL version:", result[0][0].version);
  } catch (error) {
    console.error(
      "❌ Unable to connect to PostgreSQL database:",
      error.message
    );
    console.error("Full error:", error);
    process.exit(1); // Exit jika tidak bisa connect ke database
  }
})();

// Session configuration
app.use(
  session({
    secret: process.env.SESS_SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: {
      secure: "auto",
      maxAge: 24 * 60 * 60 * 1000, // 24 hours
    },
  })
);

// Passport middleware
app.use(passport.initialize());
app.use(passport.session());

// CORS configuration
app.use(
  cors({
    credentials: true,
    origin: process.env.CLIENT_URL || "http://localhost:3000",
  })
);

// Body parser middleware
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// File upload middleware
app.use(
  FileUpload({
    createParentPath: true,
    limits: {
      fileSize: 5 * 1024 * 1024, // 5MB max file size
    },
  })
);

// Static files
app.use(express.static("public"));

// Health check endpoint

// Routes
app.use("/api", UserRoute);
app.use("/api", ArticleRoute);
app.use("/api", VideoRoute);
app.use("/api", AuthRoute);

// Error handling middleware
app.use((error, req, res, next) => {
  console.error("💥 Server Error:", error);
  res.status(500).json({
    message: "Internal Server Error",
    error:
      process.env.NODE_ENV === "development"
        ? error.message
        : "Something went wrong",
  });
});

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    message: "Route not found",
    path: req.originalUrl,
  });
});

const PORT = process.env.APP_PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || "development"}`);
});
