import express from "express";
import {
  getUsers,
  getUserById,
  updateUserById,
  handleUserImage,
  deleteUserById,
} from "../controllers/UsersControllers.js";
import { jwtAuth } from "../middleware/AuthUser.js";

const router = express.Router();

router.post("/users", jwtAuth, getUsers);
router.get("/users/:id", jwtAuth, getUserById);
router.put("/users/:id", jwtAuth, updateUserById);
router.post("/users/:id/image", jwtAuth, handleUserImage);
router.delete("/users/:id", jwtAuth, deleteUserById);

export default router;
