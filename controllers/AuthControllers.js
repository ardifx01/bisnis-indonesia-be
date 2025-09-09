import User from "../models/UserModel.js";
import argon2 from "argon2";
import jwt from "jsonwebtoken";
import axios from "axios";
import passport from "passport";
import Roles from "../models/RolesModel.js";
import Memberships from "../models/MembershipModel.js";
import { Op } from "sequelize";

export const Register = async (req, res) => {
  const { name, email, password, confPassword } = req.body;

  if (password.length > 8) {
    return res.status(400).json({
      message: "Password must not be more than 8 characters",
    });
  }

  if (password !== confPassword)
    return res
      .status(400)
      .json({ message: "Password and Confirm Password do not match" });

  const hashPassword = await argon2.hash(password);

  try {
    // Get default role and membership
    const defaultRole = await Roles.findOne({ where: { slug: "member" } }); // Adjust slug as needed
    const defaultMembership = await Memberships.findOne({
      where: { slug: "free" },
    }); // Adjust slug as needed

    if (!defaultRole || !defaultMembership) {
      return res.status(500).json({
        message: "Default role or membership not found",
      });
    }

    console.log(defaultMembership);

    await User.create({
      name: name,
      email: email,
      password: hashPassword,
      role_id: defaultRole.id,
      membership_id: defaultMembership.id,
      membership_expires_at: new Date(
        Date.now() + defaultMembership.duration_days * 24 * 60 * 60 * 1000
      ), // Set expiry based on membership duration
    });

    res.status(201).json({ message: "Register Successfully" });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const Login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
      });
    }

    const user = await User.findOne({
      where: {
        email: email,
      },
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

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // Check if user is active
    if (!user.is_active) {
      return res.status(403).json({
        message: "Account is deactivated. Please contact administrator.",
      });
    }

    // Verify password
    const match = await argon2.verify(user.password, password);
    if (!match) {
      return res.status(400).json({
        message: "Wrong Password",
      });
    }

    // Update last login
    await user.update({
      last_login_at: new Date(),
    });

    // Prepare user data for token and response
    const userData = {
      id: user.id,
      name: user.name,
      email: user.email,
      bio: user.bio,
      picture: user.picture,
      pictureUrl: user.pictureUrl,
      is_active: user.is_active,
      email_verified: !!user.email_verified_at,
      role: {
        id: user.role?.id,
        name: user.role?.name,
        slug: user.role?.slug,
        permissions: user.role?.permissions,
      },
      membership: {
        id: user.membership?.id,
        name: user.membership?.name,
        slug: user.membership?.slug,
        price: user.membership?.price,
        duration_days: user.membership?.duration_days,
        features: user.membership?.features,
        limits: user.membership?.limits,
        expires_at: user.membership_expires_at,
        is_expired: user.membership_expires_at
          ? new Date(user.membership_expires_at) < new Date()
          : false,
      },
    };

    const tokenPayload = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      membership: {
        id: user.membership?.id,
        name: user.membership?.name,
        slug: user.membership?.slug,
        expires_at: user.membership_expires_at,
        is_expired: user.membership_expires_at
          ? new Date(user.membership_expires_at) < new Date()
          : false,
      },
      pictureUrl: user.pictureUrl,
    };

    const accessToken = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
      expiresIn: "1d",
    });

    res.status(200).json({
      message: "Login successful",
      user: userData,
      accessToken,
    });
  } catch (error) {
    console.error("Error in Login:", error);
    res.status(500).json({
      message: "Internal server error",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

export const LoginFacebook = async (req, res) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken) {
      return res.status(400).json({ message: "Access token is required" });
    }

    const response = await axios.get(
      `https://graph.facebook.com/me?access_token=${accessToken}&fields=id,name,email,picture`
    );
    const userProfile = response.data;

    if (!userProfile) {
      return res.status(401).json({ message: "Invalid Facebook access token" });
    }

    // Find user by email OR by provider_id for Facebook
    let user = await User.findOne({
      where: {
        [Op.or]: [
          { email: userProfile.email },
          {
            provider: "facebook",
            provider_id: userProfile.id,
          },
        ],
      },
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

    if (!user) {
      return res
        .status(401)
        .json({ message: "Facebook account is not registered yet" });
    }

    // Update provider info if user exists but doesn't have Facebook provider data
    if (user.provider !== "facebook" || user.provider_id !== userProfile.id) {
      await user.update({
        provider: "facebook",
        provider_id: userProfile.id,
        picture: userProfile.picture?.data?.url || user.picture,
        pictureUrl: userProfile.picture?.data?.url || user.pictureUrl,
        last_login_at: new Date(),
      });
    } else {
      // Update last login and picture if changed
      await user.update({
        picture: userProfile.picture?.data?.url || user.picture,
        pictureUrl: userProfile.picture?.data?.url || user.pictureUrl,
        last_login_at: new Date(),
      });
    }

    const tokenPayload = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      membership: {
        id: user.membership?.id,
        name: user.membership?.name,
        slug: user.membership?.slug,
        expires_at: user.membership_expires_at,
        is_expired: user.membership_expires_at
          ? new Date(user.membership_expires_at) < new Date()
          : false,
      },
      pictureUrl: user.pictureUrl,
    };

    const token = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    return res.json({
      message: "Login successful",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        bio: user.bio,
        picture: user.picture,
        pictureUrl: user.pictureUrl,
        is_active: user.is_active,
        email_verified: !!user.email_verified_at,
        provider: user.provider,
        role: {
          id: user.role?.id,
          name: user.role?.name,
          slug: user.role?.slug,
          permissions: user.role?.permissions,
        },
        membership: {
          id: user.membership?.id,
          name: user.membership?.name,
          slug: user.membership?.slug,
          price: user.membership?.price,
          duration_days: user.membership?.duration_days,
          features: user.membership?.features,
          limits: user.membership?.limits,
          expires_at: user.membership_expires_at,
          is_expired: user.membership_expires_at
            ? new Date(user.membership_expires_at) < new Date()
            : false,
        },
      },
      accessToken: token,
    });
  } catch (error) {
    console.error("Error during Facebook login:", error);
    return res.status(500).json({ message: "Server error during login" });
  }
};

export const RegisterFacebook = async (req, res) => {
  try {
    const { accessToken } = req.body;

    if (!accessToken)
      return res.status(400).json({ message: "Access token is required" });

    const response = await axios.get(
      `https://graph.facebook.com/me?access_token=${accessToken}&fields=id,name,email,picture`
    );

    const userProfile = response.data;

    if (!userProfile) {
      return res.status(401).json({ message: "Invalid Facebook access token" });
    }

    // Check if user already exists by email OR Facebook provider_id
    let user = await User.findOne({
      where: {
        [Op.or]: [
          { email: userProfile.email },
          {
            provider: "facebook",
            provider_id: userProfile.id,
          },
        ],
      },
    });

    if (user) {
      // If user exists, update provider info and return existing user
      if (user.provider !== "facebook" || user.provider_id !== userProfile.id) {
        await user.update({
          provider: "facebook",
          provider_id: userProfile.id,
          picture: userProfile.picture?.data?.url || user.picture,
          pictureUrl: userProfile.picture?.data?.url || user.pictureUrl,
          last_login_at: new Date(),
        });
      }

      // Reload user with associations
      user = await User.findByPk(user.id, {
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

      const tokenPayload = {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        membership: {
          id: user.membership?.id,
          name: user.membership?.name,
          slug: user.membership?.slug,
          expires_at: user.membership_expires_at,
          is_expired: user.membership_expires_at
            ? new Date(user.membership_expires_at) < new Date()
            : false,
        },
        pictureUrl: user.pictureUrl,
      };

      const token = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
        expiresIn: "7d",
      });

      return res.status(200).json({
        message: "Login successful (existing user)",
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          bio: user.bio,
          picture: user.picture,
          pictureUrl: user.pictureUrl,
          is_active: user.is_active,
          email_verified: !!user.email_verified_at,
          provider: user.provider,
          role: {
            id: user.role?.id,
            name: user.role?.name,
            slug: user.role?.slug,
            permissions: user.role?.permissions,
          },
          membership: {
            id: user.membership?.id,
            name: user.membership?.name,
            slug: user.membership?.slug,
            price: user.membership?.price,
            duration_days: user.membership?.duration_days,
            features: user.membership?.features,
            limits: user.membership?.limits,
            expires_at: user.membership_expires_at,
            is_expired: user.membership_expires_at
              ? new Date(user.membership_expires_at) < new Date()
              : false,
          },
        },
        accessToken: token,
      });
    }

    // Create new user if doesn't exist
    const defaultRole = await Roles.findOne({ where: { slug: "member" } });
    const defaultMembership = await Memberships.findOne({
      where: { slug: "free" },
    });

    if (!defaultRole || !defaultMembership) {
      return res.status(500).json({
        message: "Default role or membership not found",
      });
    }

    user = await User.create({
      name: userProfile.name,
      email: userProfile.email || null,
      picture: userProfile.picture?.data?.url || null,
      pictureUrl: userProfile.picture?.data?.url || null,
      provider: "facebook",
      provider_id: userProfile.id,
      role_id: defaultRole.id,
      membership_id: defaultMembership.id,
      membership_expires_at: new Date(
        Date.now() + defaultMembership.duration_days * 24 * 60 * 60 * 1000
      ),
      email_verified_at: new Date(), // Facebook emails are considered verified
      last_login_at: new Date(),
    });

    // Reload user with associations
    user = await User.findByPk(user.id, {
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

    const tokenPayload = {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      membership: {
        id: user.membership?.id,
        name: user.membership?.name,
        slug: user.membership?.slug,
        expires_at: user.membership_expires_at,
        is_expired: user.membership_expires_at
          ? new Date(user.membership_expires_at) < new Date()
          : false,
      },
      pictureUrl: user.pictureUrl,
    };

    const token = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    return res.status(201).json({
      message: "Register Successfully",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        bio: user.bio,
        picture: user.picture,
        pictureUrl: user.pictureUrl,
        is_active: user.is_active,
        email_verified: !!user.email_verified_at,
        provider: user.provider,
        role: {
          id: user.role?.id,
          name: user.role?.name,
          slug: user.role?.slug,
          permissions: user.role?.permissions,
        },
        membership: {
          id: user.membership?.id,
          name: user.membership?.name,
          slug: user.membership?.slug,
          price: user.membership?.price,
          duration_days: user.membership?.duration_days,
          features: user.membership?.features,
          limits: user.membership?.limits,
          expires_at: user.membership_expires_at,
          is_expired: user.membership_expires_at
            ? new Date(user.membership_expires_at) < new Date()
            : false,
        },
      },
      accessToken: token,
    });
  } catch (error) {
    console.error("Error during Facebook register:", error.message);
    return res.status(500).json({ message: "Server error during register" });
  }
};

export const LoginGoogle = (req, res, next) => {
  passport.authenticate("google", { scope: ["profile", "email"] })(
    req,
    res,
    next
  );
};

export const LoginGoogleCallback = async (req, res, next) => {
  passport.authenticate("google", async (err, googleUser, info) => {
    if (err) {
      console.error("Passport Google authentication error:", err);
      return res
        .status(500)
        .json({ message: "Internal server error", error: err.message });
    }

    if (!googleUser) {
      return res.status(401).json({ message: "Authentication failed" });
    }

    try {
      console.log("Processing Google user:", {
        id: googleUser.id,
        email: googleUser.email,
        name: googleUser.name,
      });

      // Find user by email OR by Google provider_id (SAMA SEPERTI FACEBOOK)
      let user = await User.findOne({
        where: {
          [Op.or]: [
            { email: googleUser.email },
            {
              provider: "google",
              provider_id: googleUser.id.toString(),
            },
          ],
        },
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

      if (!user) {
        // Create new user if doesn't exist (SAMA SEPERTI FACEBOOK)
        const defaultRole = await Roles.findOne({
          where: { slug: "member" },
        });

        const defaultMembership = await Memberships.findOne({
          where: { slug: "free" },
        });

        if (!defaultRole || !defaultMembership) {
          return res.status(500).json({
            message: "Default role or membership not found",
          });
        }

        user = await User.create({
          name: googleUser.displayName || googleUser.name,
          email: googleUser.email,
          picture: googleUser.photo || googleUser.picture,
          pictureUrl: googleUser.photo || googleUser.picture,
          provider: "google",
          provider_id: googleUser.id.toString(), // Google ID di provider_id
          role_id: defaultRole.id,
          membership_id: defaultMembership.id,
          membership_expires_at: new Date(
            Date.now() + defaultMembership.duration_days * 24 * 60 * 60 * 1000
          ),
          email_verified_at: new Date(),
          last_login_at: new Date(),
        });

        user = await User.findOne({
          where: { id: user.id },
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

        console.log("New Google user created:", {
          id: user.id, // UUID
          email: user.email,
          provider_id: user.provider_id, // Google ID
        });
      } else {
        // Update existing user (SAMA SEPERTI FACEBOOK)
        const updateData = {
          last_login_at: new Date(),
        };

        // Update provider info if needed
        if (
          user.provider !== "google" ||
          user.provider_id !== googleUser.id.toString()
        ) {
          updateData.provider = "google";
          updateData.provider_id = googleUser.id.toString();
        }

        // Update picture if available
        if (googleUser.photo || googleUser.picture) {
          updateData.picture = googleUser.photo || googleUser.picture;
          updateData.pictureUrl = googleUser.photo || googleUser.picture;
        }

        await user.update(updateData);

        // Reload user data (SAMA SEPERTI FACEBOOK)
        await user.reload({
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

        console.log("Existing Google user updated:", {
          id: user.id, // UUID
          email: user.email,
          provider_id: user.provider_id, // Google ID
        });
      }

      // Validasi user berhasil dimuat
      if (!user) {
        return res.status(500).json({
          message: "Failed to load user data after authentication",
        });
      }

      // Create JWT token payload (SAMA SEPERTI FACEBOOK)
      const tokenPayload = {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        membership: {
          id: user.membership?.id,
          name: user.membership?.name,
          slug: user.membership?.slug,
          expires_at: user.membership_expires_at,
          is_expired: user.membership_expires_at
            ? new Date(user.membership_expires_at) < new Date()
            : false,
        },
        pictureUrl: user.pictureUrl,
        provider: user.provider,
      };

      const token = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
        expiresIn: "7d",
      });

      // Prepare user data for frontend (SAMA SEPERTI FACEBOOK)
      const userData = {
        id: user.id, // UUID dari database
        name: user.name,
        email: user.email,
        bio: user.bio,
        picture: user.picture,
        pictureUrl: user.pictureUrl,
        is_active: user.is_active,
        email_verified: !!user.email_verified_at,
        provider: user.provider,
        provider_id: user.provider_id, // Google ID
        role: {
          id: user.role?.id,
          name: user.role?.name,
          slug: user.role?.slug,
          permissions: user.role?.permissions,
        },
        membership: {
          id: user.membership?.id,
          name: user.membership?.name,
          slug: user.membership?.slug,
          price: user.membership?.price,
          duration_days: user.membership?.duration_days,
          features: user.membership?.features,
          limits: user.membership?.limits,
          expires_at: user.membership_expires_at,
          is_expired: user.membership_expires_at
            ? new Date(user.membership_expires_at) < new Date()
            : false,
        },
      };

      console.log("Google authentication successful for user UUID:", user.id);

      // Redirect to frontend with token (SAMA SEPERTI FACEBOOK RESPONSE STRUCTURE)
      res.redirect(
        `${
          process.env.CLIENT_URL || "http://localhost:3000"
        }/login?token=${encodeURIComponent(token)}&user=${encodeURIComponent(
          JSON.stringify(userData)
        )}`
      );
    } catch (error) {
      console.error("Error during Google authentication:", error);
      return res.status(500).json({
        message: "Server error during authentication",
        error: error.message,
        stack: process.env.NODE_ENV === "development" ? error.stack : undefined,
      });
    }
  })(req, res, next);
};
