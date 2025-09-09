import express from "express";
import {
  getVideo,
  getVideoById,
  createVideo,
  updateVideo,
  deleteVideo,
  getVideosByCategory,
  getTrendingVideos,
  incrementVideoView,
  likeVideo,
  getVideoAnalytics,
} from "../controllers/VideoControllers.js";
import { membershipType } from "../middleware/ContentMidleware.js";
import { jwtAuth } from "../middleware/AuthUser.js";

const router = express.Router();

// Public routes (tidak memerlukan authentication)
router.get("/videos/trending", getTrendingVideos);
router.get("/videos/category/:category", getVideosByCategory);
router.post("/videos/:id/view", incrementVideoView);

// Protected routes (memerlukan authentication)
router.post("/videos", jwtAuth, membershipType, getVideo);
router.get("/videos/:id", jwtAuth, getVideoById);
router.post("/videos", jwtAuth, createVideo);
router.put("/videos/:id", jwtAuth, updateVideo);
router.delete("/videos/:id", jwtAuth, deleteVideo);
router.post("/videos/:id/like", jwtAuth, likeVideo);
router.get("/videos/:id/analytics", jwtAuth, getVideoAnalytics);

export default router;
