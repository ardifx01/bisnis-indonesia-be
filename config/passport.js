import dotenv from "dotenv";
dotenv.config();
import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import Users from "../models/UserModel.js";
import Memberships from "../models/MembershipModel.js";

// Serialize user - hanya simpan UUID user yang sebenarnya
passport.serializeUser((user, done) => {
  console.log("Serializing user:", user.id);
  done(null, user.id); // Ini adalah UUID dari database
});

// Deserialize user - cari berdasarkan UUID
passport.deserializeUser(async (id, done) => {
  try {
    console.log("Deserializing user with ID:", id);

    // Pastikan id adalah UUID yang valid
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!uuidRegex.test(id)) {
      console.error("Invalid UUID format:", id);
      return done(null, false);
    }

    const user = await Users.findOne({
      where: { id: id }, // Cari berdasarkan UUID
      include: [
        {
          model: Roles,
          as: "role",
          attributes: ["id", "name", "slug", "permissions"],
        },
        {
          model: Memberships,
          as: "membership",
          attributes: [
            "id",
            "name",
            "slug",
            "price",
            "duration_days",
            "features",
            "limits",
          ],
        },
      ],
    });

    if (user) {
      console.log("User found:", user.id);
      done(null, user);
    } else {
      console.log("User not found with UUID:", id);
      done(null, false);
    }
  } catch (error) {
    console.error("Error in deserializeUser:", error);
    done(error, null);
  }
});

// Google OAuth Strategy
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "/api/auth/google/callback",
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const googleUser = {
          id: profile.id.toString(),
          email: profile.emails?.[0]?.value,
          name: profile.displayName,
          displayName: profile.displayName,
          photo: profile.photos?.[0]?.value,
          picture: profile.photos?.[0]?.value,
        };

        return done(null, googleUser);
      } catch (error) {
        console.error("Error in Google strategy:", error);
        return done(error, null);
      }
    }
  )
);

export default passport;
