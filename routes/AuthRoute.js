import express from "express";
import {
  Login,
  Register,
  LoginFacebook,
  RegisterFacebook,
  LoginGoogle,
  LoginGoogleCallback,
} from "../controllers/AuthControllers.js";

const router = express.Router();

router.post("/login", Login);
router.post("/register", Register);
router.post("/auth/facebook/login", LoginFacebook);
router.post("/auth/facebook/register", RegisterFacebook);
router.get("/auth/google", LoginGoogle);
router.get("/auth/google/callback", LoginGoogleCallback);

export default router;
