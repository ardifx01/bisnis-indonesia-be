import express from "express";
import {
  getArticle,
  getArticleById,
  handleDirectUpload,
  deleteArticle,
  getFileInfo,
  deleteFile,
  updateArticle,
} from "../controllers/ArticleControllers.js";
import { jwtAuth } from "../middleware/AuthUser.js";
import { membershipType } from "../middleware/ContentMidleware.js";

const router = express.Router();

router.post("/article", jwtAuth, membershipType, getArticle);
router.get("/article/:id", jwtAuth, getArticleById);
router.delete("/article/:id", jwtAuth, deleteArticle);
router.put("/article/:id", jwtAuth, updateArticle);
// content editor
router.post("/upload-direct", jwtAuth, handleDirectUpload);
router.get("/files/:filename", jwtAuth, getFileInfo);
router.delete("/files/:filename", jwtAuth, deleteFile);

export default router;
