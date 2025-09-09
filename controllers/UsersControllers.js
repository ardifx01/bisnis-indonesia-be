import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";
import { Op } from "sequelize";
import Roles from "../models/RolesModel.js";
import Memberships from "../models/MembershipModel.js";
import Users from "../models/UserModel.js";

export const getUsers = async (req, res) => {
  try {
    const {
      search = "",
      page = 1,
      perPage = 10,
      sortBy = "name",
      sortOrder = "ASC",
    } = req.body;

    const pageNumber = parseInt(page);
    const limitNumber = parseInt(perPage);
    const offset = (pageNumber - 1) * limitNumber;

    const allowedSortColumns = [
      "id",
      "name",
      "email",
      "is_active",
      "email_verified_at",
      "last_login_at",
      "createdAt",
      "updatedAt",
    ];
    const validSortBy =
      sortBy && allowedSortColumns.includes(sortBy) ? sortBy : "name";

    const validSortOrder = ["ASC", "DESC"].includes(sortOrder?.toUpperCase())
      ? sortOrder.toUpperCase()
      : "ASC";

    let whereCondition = {};
    let includeCondition = [];

    if (search) {
      const normalizedSearch = search.trim();

      whereCondition = {
        [Op.or]: [
          { name: { [Op.like]: `%${normalizedSearch}%` } },
          { email: { [Op.like]: `%${normalizedSearch}%` } },
          { bio: { [Op.like]: `%${normalizedSearch}%` } },
        ],
      };

      includeCondition = [
        {
          model: Roles,
          as: "role",
          where: {
            [Op.or]: [
              { name: { [Op.like]: `%${normalizedSearch}%` } },
              { slug: { [Op.like]: `%${normalizedSearch}%` } },
            ],
          },
          required: false,
        },
        {
          model: Memberships,
          as: "membership",
          where: {
            [Op.or]: [
              { name: { [Op.like]: `%${normalizedSearch}%` } },
              { slug: { [Op.like]: `%${normalizedSearch}%` } },
            ],
          },
          required: false,
        },
      ];
    } else {
      includeCondition = [
        {
          model: Roles,
          as: "role",
          attributes: ["id", "name", "slug"],
        },
        {
          model: Memberships,
          as: "membership",
          attributes: ["id", "name", "slug", "price", "duration_days"],
        },
      ];
    }

    const { count, rows } = await Users.findAndCountAll({
      attributes: [
        "id",
        "name",
        "email",
        "bio",
        "picture",
        "pictureUrl",
        "is_active",
        "email_verified_at",
        "membership_expires_at",
        "last_login_at",
        "createdAt",
        "updatedAt",
      ],
      where: whereCondition,
      include: includeCondition,
      limit: limitNumber,
      offset: offset,
      order: [[validSortBy, validSortOrder]],
      distinct: true,
    });

    const transformedRows = rows.map((user) => ({
      id: user.id,
      name: user.name,
      email: user.email,
      bio: user.bio,
      picture: user.picture,
      pictureUrl: user.pictureUrl,
      is_active: user.is_active,
      email_verified: !!user.email_verified_at,
      email_verified_at: user.email_verified_at,
      last_login_at: user.last_login_at,
      role: {
        id: user.role?.id,
        name: user.role?.name,
        slug: user.role?.slug,
      },
      membership: {
        id: user.membership?.id,
        name: user.membership?.name,
        slug: user.membership?.slug,
        price: user.membership?.price,
        duration_days: user.membership?.duration_days,
        expires_at: user.membership_expires_at,
        is_expired: user.membership_expires_at
          ? new Date(user.membership_expires_at) < new Date()
          : false,
      },
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    }));

    const totalPages = Math.ceil(count / limitNumber);

    res.status(200).json({
      data: transformedRows,
      pagination: {
        currentPage: pageNumber,
        perPage: limitNumber,
        totalItems: count,
        totalPages: totalPages,
      },
      message: "success",
    });
  } catch (error) {
    console.error("Error in getUsers:", error);
    res.status(500).json({
      message: error.message,
      error: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
};

export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await Users.findOne({
      where: { id },
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

    // Transform response
    const transformedUser = {
      id: user.id,
      name: user.name,
      email: user.email,
      bio: user.bio,
      picture: user.picture,
      pictureUrl: user.pictureUrl,
      is_active: user.is_active,
      email_verified: !!user.email_verified_at,
      email_verified_at: user.email_verified_at,
      last_login_at: user.last_login_at,
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
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };

    res.status(200).json({
      data: transformedUser,
      message: "success",
    });
  } catch (error) {
    console.error("Error in getUserById:", error);
    res.status(500).json({
      message: error.message,
      error: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
};

export const updateUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      email,
      bio,
      role_id,
      membership_id,
      membership_expires_at,
      is_active,
    } = req.body;

    const user = await Users.findByPk(id);
    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    // Validate role_id - now required field
    if (role_id) {
      const role = await Roles.findByPk(role_id);
      if (!role) {
        return res.status(400).json({
          message: "Invalid role_id",
        });
      }
    }

    // Validate membership_id - now required field
    if (membership_id) {
      const membership = await Memberships.findByPk(membership_id);
      if (!membership) {
        return res.status(400).json({
          message: "Invalid membership_id",
        });
      }
    }

    // Check email uniqueness if email is being changed
    if (email && email !== user.email) {
      const existingUser = await Users.findOne({
        where: {
          email,
          id: { [Op.ne]: id },
        },
      });
      if (existingUser) {
        return res.status(400).json({
          message: "Email already exists",
        });
      }
    }

    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (email !== undefined) updateData.email = email;
    if (bio !== undefined) updateData.bio = bio;
    if (role_id !== undefined) updateData.role_id = role_id;
    if (membership_id !== undefined) updateData.membership_id = membership_id;
    if (membership_expires_at !== undefined)
      updateData.membership_expires_at = membership_expires_at;
    if (is_active !== undefined) updateData.is_active = is_active;

    await user.update(updateData);

    // Get updated user with relations
    const updatedUser = await Users.findOne({
      where: { id },
      include: [
        {
          model: Roles,
          as: "role",
          attributes: ["id", "name", "slug"],
        },
        {
          model: Memberships,
          as: "membership",
          attributes: ["id", "name", "slug", "price", "duration_days"],
        },
      ],
    });

    // Transform response to match model structure
    const transformedUser = {
      id: updatedUser.id,
      name: updatedUser.name,
      email: updatedUser.email,
      bio: updatedUser.bio,
      picture: updatedUser.picture,
      pictureUrl: updatedUser.pictureUrl,
      is_active: updatedUser.is_active,
      email_verified: !!updatedUser.email_verified_at,
      email_verified_at: updatedUser.email_verified_at,
      last_login_at: updatedUser.last_login_at,
      role: updatedUser.role,
      membership: {
        ...updatedUser.membership?.dataValues,
        expires_at: updatedUser.membership_expires_at,
        is_expired: updatedUser.membership_expires_at
          ? new Date(updatedUser.membership_expires_at) < new Date()
          : false,
      },
      createdAt: updatedUser.createdAt,
      updatedAt: updatedUser.updatedAt,
    };

    res.status(200).json({
      data: transformedUser,
      message: "User updated successfully",
    });
  } catch (error) {
    console.error("Error in updateUserById:", error);
    res.status(500).json({
      message: error.message,
      error: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
};

export const handleUserImage = async (req, res) => {
  if (!req.files || !req.files.picture) {
    return res.status(400).json({ msg: "No File Uploaded" });
  }

  const file = req.files.picture;
  const fileSize = file.data.length;
  const ext = path.extname(file.name).toLowerCase();
  const allowedTypes = [".png", ".jpg", ".jpeg"];

  if (!allowedTypes.includes(ext)) {
    return res.status(422).json({
      message: "Invalid image type. Only .png, .jpg, and .jpeg are allowed",
    });
  }

  if (fileSize > 5000000) {
    return res.status(422).json({ message: "Image must be less than 5 MB" });
  }

  const fileName = file.md5 + ext;

  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const filePath = path.join(__dirname, "../public/profile", fileName);

  const url = `${req.protocol}://${req.get("host")}/profile/${fileName}`;

  file.mv(filePath, async (err) => {
    if (err) return res.status(500).json({ message: err.message });

    try {
      // Fixed: Use Users instead of User for consistency
      const user = await Users.findOne({
        where: { id: req.params.id },
      });

      if (!user) return res.status(404).json({ message: "User not found" });

      if (user.pictureUrl) {
        const oldImagePath = path.join(
          __dirname,
          "../public/profile",
          path.basename(user.pictureUrl)
        );
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }

      await user.update({
        picture: fileName,
        pictureUrl: url,
      });

      res.status(200).json({
        message: "Image updated successfully",
        pictureUrl: url,
      });
    } catch (error) {
      console.error(error.message);
      res.status(500).json({ message: "Internal server error" });
    }
  });
};

export const deleteUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const currentUser = req.user;

    if (!id) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const userToDelete = await Users.findOne({
      where: { id },
      include: [
        {
          model: Roles,
          as: "role",
          attributes: ["id", "name", "slug"],
        },
      ],
    });

    if (!userToDelete) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Check if trying to delete own account
    if (currentUser.id === id) {
      return res.status(400).json({
        success: false,
        message: "Cannot delete your own account",
      });
    }

    // Get current user role for permission check
    const currentUserWithRole = await Users.findOne({
      where: { id: currentUser.id },
      include: [
        {
          model: Roles,
          as: "role",
          attributes: ["id", "name", "slug"],
        },
      ],
    });

    // Only super admin can delete users
    if (
      !currentUserWithRole.role ||
      currentUserWithRole.role.slug !== "super_admin"
    ) {
      return res.status(403).json({
        success: false,
        message: "Forbidden: Only super admin can delete users",
      });
    }

    // Prevent deleting another super admin (optional business rule)
    if (userToDelete.role && userToDelete.role.slug === "super_admin") {
      return res.status(403).json({
        success: false,
        message: "Cannot delete another super admin account",
      });
    }

    // Store user data before deletion
    const deletedUserData = {
      id: userToDelete.id,
      name: userToDelete.name,
      email: userToDelete.email,
      role: userToDelete.role,
      createdAt: userToDelete.createdAt,
    };

    // Delete user's profile picture if exists
    if (userToDelete.picture) {
      const __filename = fileURLToPath(import.meta.url);
      const __dirname = path.dirname(__filename);
      const imagePath = path.join(
        __dirname,
        "../public/profile",
        userToDelete.picture
      );

      if (fs.existsSync(imagePath)) {
        try {
          fs.unlinkSync(imagePath);
        } catch (error) {
          console.error("Error deleting user image:", error);
        }
      }
    }

    // Delete the user
    await userToDelete.destroy();

    return res.status(200).json({
      success: true,
      message: "User deleted successfully",
      data: {
        deleted_user: deletedUserData,
      },
    });
  } catch (error) {
    console.error("Error in deleteUserById:", error);

    if (error.name === "SequelizeValidationError") {
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors: error.errors.map((err) => err.message),
      });
    }

    if (error.name === "SequelizeForeignKeyConstraintError") {
      return res.status(400).json({
        success: false,
        message:
          "Cannot delete user. User has related data that must be removed first",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error:
        process.env.NODE_ENV === "development"
          ? error.message
          : "Something went wrong",
    });
  }
};
