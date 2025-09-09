import { Op } from "sequelize";
import Articles from "../models/ArticleModel.js";
import User from "../models/UserModel.js";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

export const getArticle = async (req, res) => {
  try {
    const {
      search = "",
      page = 1,
      perPage = 10,
      sortBy = "createdAt",
      sortOrder = "DESC",
      status = null,
      author = null,
      featured = null,
    } = req.body;

    const pageNumber = parseInt(page);
    const limitNumber = parseInt(perPage);
    const offset = (pageNumber - 1) * limitNumber;

    const membershipLimit = req.limit;
    const membershipLevel = req.membershipLevel;

    // Updated allowed sort columns sesuai model
    const allowedSortColumns = [
      "id",
      "title",
      "slug",
      "content",
      "excerpt",
      "status",
      "userId",
      "thumbnail",
      "keywords",
      "readingTime",
      "viewsCount",
      "likesCount",
      "commentsCount",
      "featured",
      "publishedAt",
      "scheduledAt",
      "createdAt",
      "updatedAt",
    ];

    const validSortBy =
      sortBy && allowedSortColumns.includes(sortBy) ? sortBy : "createdAt";

    const validSortOrder = ["ASC", "DESC"].includes(sortOrder?.toUpperCase())
      ? sortOrder.toUpperCase()
      : "DESC";

    // Base condition untuk membership
    const baseWhereCondition = {};

    // Default filter untuk artikel yang published (jika user bukan admin)
    if (req.user && req.user.role !== "admin") {
      baseWhereCondition.status = "published";
    }

    let baseData;
    let totalMembershipItems;

    if (membershipLimit === null) {
      // Unlimited membership - get all data
      const { count, rows } = await Articles.findAndCountAll({
        attributes: [
          "id",
          "title",
          "slug",
          "content",
          "excerpt",
          "status",
          "userId",
          "thumbnail",
          "thumbnailAlt",
          "metaTitle",
          "metaDescription",
          "keywords",
          "readingTime",
          "viewsCount",
          "likesCount",
          "commentsCount",
          "featured",
          "allowComments",
          "publishedAt",
          "scheduledAt",
          "createdAt",
          "updatedAt",
        ],
        include: [
          {
            model: User,
            as: "user",
            attributes: ["id", "name", "email", "picture", "pictureUrl", "bio"],
          },
        ],
        where: baseWhereCondition,
        order: [[validSortBy, validSortOrder]],
        distinct: true,
      });

      baseData = rows;
      totalMembershipItems = count;
    } else {
      // Limited membership - get only allowed amount
      const { count, rows } = await Articles.findAndCountAll({
        attributes: [
          "id",
          "title",
          "slug",
          "content",
          "excerpt",
          "status",
          "userId",
          "thumbnail",
          "thumbnailAlt",
          "metaTitle",
          "metaDescription",
          "keywords",
          "readingTime",
          "viewsCount",
          "likesCount",
          "commentsCount",
          "featured",
          "allowComments",
          "publishedAt",
          "scheduledAt",
          "createdAt",
          "updatedAt",
        ],
        include: [
          {
            model: User,
            as: "user",
            attributes: ["id", "name", "email", "picture", "pictureUrl", "bio"],
          },
        ],
        where: baseWhereCondition,
        limit: membershipLimit,
        order: [[validSortBy, validSortOrder]],
        distinct: true,
      });

      baseData = rows;
      totalMembershipItems = Math.min(count, membershipLimit);
    }

    let filteredData = [...baseData];

    // Apply search filter
    if (search) {
      const normalizedSearch = search.trim().toLowerCase();
      filteredData = filteredData.filter((article) => {
        // Helper function untuk safely convert ke string dan lowercase
        const safeStringCheck = (value) => {
          if (value === null || value === undefined) return "";
          if (typeof value === "string") return value.toLowerCase();
          if (Array.isArray(value)) return value.join(" ").toLowerCase();
          return String(value).toLowerCase();
        };

        return (
          safeStringCheck(article?.title).includes(normalizedSearch) ||
          safeStringCheck(article?.content).includes(normalizedSearch) ||
          safeStringCheck(article?.excerpt).includes(normalizedSearch) ||
          safeStringCheck(article?.slug).includes(normalizedSearch) ||
          safeStringCheck(article?.keywords).includes(normalizedSearch) ||
          safeStringCheck(article?.user?.name).includes(normalizedSearch) ||
          safeStringCheck(article?.user?.email).includes(normalizedSearch)
        );
      });
    }

    // Apply status filter
    if (status) {
      filteredData = filteredData.filter(
        (article) => article.status === status
      );
    }

    // Apply author filter
    if (author) {
      filteredData = filteredData.filter(
        (article) => article.userId === author
      );
    }

    // Apply featured filter
    if (featured !== null) {
      const isFeatured = featured === true || featured === "true";
      filteredData = filteredData.filter(
        (article) => article.featured === isFeatured
      );
    }

    const totalFilteredItems = filteredData.length;
    const totalFilteredPages = Math.ceil(totalFilteredItems / limitNumber);

    // Handle case where page exceeds available pages
    if (pageNumber > totalFilteredPages && totalFilteredPages > 0) {
      return res.status(200).json({
        data: [],
        pagination: {
          currentPage: pageNumber,
          perPage: limitNumber,
          totalItems: totalFilteredItems,
          totalPages: totalFilteredPages,
          membershipLimit: membershipLimit,
          membershipLevel: membershipLevel,
          message: "Page exceeds available data",
        },
        filters: {
          search,
          status,
          author,
          featured,
          sortBy: validSortBy,
          sortOrder: validSortOrder,
        },
        message: "success",
      });
    }

    // Get paginated results
    const startIndex = (pageNumber - 1) * limitNumber;
    const endIndex = startIndex + limitNumber;
    const paginatedData = filteredData.slice(startIndex, endIndex);

    // STEP 4: Handle membership limit exceeded case
    if (membershipLimit !== null && startIndex >= membershipLimit) {
      return res.status(200).json({
        data: [],
        pagination: {
          currentPage: pageNumber,
          perPage: limitNumber,
          totalItems: 0,
          totalPages: 0,
          membershipLimit: membershipLimit,
          membershipLevel: membershipLevel,
          message: "Exceeded membership limit",
        },
        filters: {
          search,
          status,
          author,
          featured,
          sortBy: validSortBy,
          sortOrder: validSortOrder,
        },
        message: "success",
      });
    }

    res.status(200).json({
      data: paginatedData,
      pagination: {
        currentPage: pageNumber,
        perPage: limitNumber,
        totalItems: totalFilteredItems,
        totalPages: totalFilteredPages,
        membershipLimit: membershipLimit,
        membershipLevel: membershipLevel,
        baseDataCount: totalMembershipItems,
      },
      filters: {
        search,
        status,
        author,
        featured,
        sortBy: validSortBy,
        sortOrder: validSortOrder,
      },
      message: "success",
    });
  } catch (error) {
    console.error("Error in getArticle:", error);
    res.status(500).json({
      message: error.message,
      error: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
};

export const getArticleById = async (req, res) => {
  try {
    const data = await Articles.findOne({
      where: {
        id: req.params.id,
      },
    });

    if (!data) return res.status(404).json({ message: "Data not found!" });

    let response = await Articles.findOne({
      attributes: [
        "id",
        "title",
        "slug",
        "content",
        "excerpt",
        "status",
        "userId",
        "thumbnail",
        "thumbnailAlt",
        "metaTitle",
        "metaDescription",
        "keywords",
        "readingTime",
        "viewsCount",
        "likesCount",
        "commentsCount",
        "featured",
        "allowComments",
        "publishedAt",
        "scheduledAt",
        "createdAt",
        "updatedAt",
      ],
      where: {
        id: data.id,
      },
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email", "picture", "pictureUrl", "bio"],
        },
      ],
    });

    // Increment view count
    await Articles.increment("viewsCount", {
      by: 1,
      where: { id: data.id },
    });

    res.status(200).json(response);
  } catch (error) {
    console.error("Error in getArticleById:", error);
    res.status(500).json({ message: error.message });
  }
};

export const createArticle = async (req, res) => {
  try {
    const {
      title,
      content,
      excerpt,
      status = "draft",
      thumbnail,
      thumbnailAlt,
      metaTitle,
      metaDescription,
      keywords,
      featured = false,
      allowComments = true,
      publishedAt,
      scheduledAt,
    } = req.body;

    const userId = req.user.id; // Dari middleware auth

    // Generate slug dari title
    const slug = title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "");

    const newArticle = await Articles.create({
      title,
      slug,
      content,
      excerpt,
      status,
      userId,
      thumbnail,
      thumbnailAlt,
      metaTitle,
      metaDescription,
      keywords,
      featured,
      allowComments,
      publishedAt: status === "published" ? publishedAt || new Date() : null,
      scheduledAt: status === "scheduled" ? scheduledAt : null,
      viewsCount: 0,
      likesCount: 0,
      commentsCount: 0,
    });

    res.status(201).json({
      data: newArticle,
      message: "Article created successfully",
    });
  } catch (error) {
    console.error("Error in createArticle:", error);
    res.status(500).json({
      message: error.message,
    });
  }
};

export const updateArticle = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      title,
      content,
      excerpt,
      status,
      thumbnail,
      thumbnailAlt,
      metaTitle,
      metaDescription,
      keywords,
      featured,
      allowComments,
      publishedAt,
      scheduledAt,
    } = req.body;

    const article = await Articles.findByPk(id);

    if (!article) {
      return res.status(404).json({
        message: "Article not found",
      });
    }

    // Check authorization - hanya member yang tidak bisa update
    if (req.user && req.user.role.slug === "member") {
      return res.status(403).json({
        message: "Members are not authorized to update articles",
      });
    }

    const updateData = {};

    if (title) {
      updateData.title = title;
      // Generate ulang slug jika title berubah
      updateData.slug = title
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/(^-|-$)/g, "");
    }

    if (content !== undefined) updateData.content = content;
    if (excerpt !== undefined) updateData.excerpt = excerpt;
    if (status) {
      updateData.status = status;
      // Set publishedAt jika status berubah ke published
      if (status === "published" && !article.publishedAt) {
        updateData.publishedAt = publishedAt || new Date();
      }
      // Set scheduledAt jika status berubah ke scheduled
      if (status === "scheduled") {
        updateData.scheduledAt = scheduledAt;
      }
    }
    if (thumbnail !== undefined) updateData.thumbnail = thumbnail;
    if (thumbnailAlt !== undefined) updateData.thumbnailAlt = thumbnailAlt;
    if (metaTitle !== undefined) updateData.metaTitle = metaTitle;
    if (metaDescription !== undefined)
      updateData.metaDescription = metaDescription;
    if (keywords !== undefined) updateData.keywords = keywords;
    if (featured !== undefined) updateData.featured = featured;
    if (allowComments !== undefined) updateData.allowComments = allowComments;
    if (publishedAt !== undefined) updateData.publishedAt = publishedAt;
    if (scheduledAt !== undefined) updateData.scheduledAt = scheduledAt;

    await article.update(updateData);

    // Return updated article dengan include
    const updatedArticle = await Articles.findByPk(id, {
      attributes: [
        "id",
        "title",
        "slug",
        "content",
        "excerpt",
        "status",
        "userId",
        "thumbnail",
        "thumbnailAlt",
        "metaTitle",
        "metaDescription",
        "keywords",
        "readingTime",
        "viewsCount",
        "likesCount",
        "commentsCount",
        "featured",
        "allowComments",
        "publishedAt",
        "scheduledAt",
        "createdAt",
        "updatedAt",
      ],
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email", "picture", "pictureUrl", "bio"],
        },
      ],
    });

    res.status(200).json({
      data: updatedArticle,
      message: "Article updated successfully",
    });
  } catch (error) {
    console.error("Error in updateArticle:", error);
    res.status(500).json({
      message: error.message,
    });
  }
};

export const deleteArticle = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate article ID
    if (!id || typeof id !== "string") {
      return res.status(400).json({
        message: "Invalid article ID provided",
      });
    }

    // Check if user is authenticated
    if (!req.user) {
      return res.status(401).json({
        message: "Authentication required",
      });
    }

    // Find the article
    const article = await Articles.findByPk(id);

    if (!article) {
      return res.status(404).json({
        message: "Article not found",
      });
    }
    console.log(req.user);

    const userRole = req.user.role.slug.toLowerCase();

    // Block members from deleting articles
    if (userRole === "member") {
      return res.status(403).json({
        message: "Members are not authorized to delete articles",
      });
    }

    // Authorization logic for allowed roles
    let isAuthorized = false;

    switch (userRole) {
      case "super_admin":
      case "admin":
        // Super Admin and Admin can delete any article
        isAuthorized = true;
        break;

      default:
        // For any other role (non-member), check if they own the article
        isAuthorized = article.userId === req.user.id;
        break;
    }

    // Final authorization check
    if (!isAuthorized) {
      return res.status(403).json({
        message: `Not authorized to delete this article. Your role: ${
          req.user.role || "unknown"
        }`,
      });
    }

    await article.destroy();

    res.status(200).json({
      message: "Article deleted successfully",
      deletedBy: {
        userId: req.user.id,
        role: req.user.role,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error("Error in deleteArticle:", error);

    // Specific error handling
    if (error.name === "SequelizeValidationError") {
      return res.status(400).json({
        message: "Validation error occurred",
        details: error.errors.map((err) => err.message),
      });
    }

    if (error.name === "SequelizeForeignKeyConstraintError") {
      return res.status(400).json({
        message: "Cannot delete article due to existing references",
      });
    }

    res.status(500).json({
      message: "An error occurred while deleting the article",
      error:
        process.env.NODE_ENV === "development"
          ? error.message
          : "Internal server error",
    });
  }
};

export const handleDirectUpload = async (req, res) => {
  if (!req.files || !req.files.file) {
    return res.status(400).json({ msg: "No File Uploaded" });
  }

  const file = req.files.file;
  const fileSize = file.data.length;
  const ext = path.extname(file.name).toLowerCase();
  const allowedTypes = [".png", ".jpg", ".jpeg", ".gif", ".webp"];

  if (!allowedTypes.includes(ext)) {
    return res.status(422).json({
      message:
        "Invalid image type. Only .png, .jpg, .jpeg, .gif, and .webp are allowed",
    });
  }

  // Validate file size (maximum 10MB)
  if (fileSize > 10000000) {
    return res.status(422).json({ message: "Image must be less than 10 MB" });
  }

  const fileName = file.md5 + ext;

  // Construct the path using import.meta.url instead of __dirname
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const filePath = path.join(__dirname, "../public/content", fileName);

  // Ensure directory exists
  const uploadDir = path.join(__dirname, "../public/content");
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }

  const url = `${req.protocol}://${req.get("host")}/content/${fileName}`;

  // Move file to the public/content directory
  file.mv(filePath, async (err) => {
    if (err) return res.status(500).json({ message: err.message });

    res.status(200).json({
      message: "Image uploaded successfully",
      location: `content/${fileName}`,
      url: url,
      filename: fileName,
    });
  });
};

export const getFileInfo = async (req, res) => {
  try {
    const { filename } = req.params;

    // Use consistent path resolution
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);
    const filePath = path.join(__dirname, "../public/content", filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        error: "File not found",
        message: "The requested file does not exist",
      });
    }

    const stats = fs.statSync(filePath);
    const ext = path.extname(filename).toLowerCase();

    res.json({
      filename,
      size: stats.size,
      extension: ext,
      created: stats.birthtime,
      modified: stats.mtime,
      url: `/content/${filename}`,
    });
  } catch (error) {
    console.error("Get file info error:", error);
    res.status(500).json({
      error: "Internal server error",
      message: "Failed to retrieve file information",
    });
  }
};

export const deleteFile = async (req, res) => {
  try {
    const { filename } = req.params;

    // Use consistent path resolution with import.meta.url
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);
    const filePath = path.join(__dirname, "../public/content", filename);

    console.log("Attempting to delete file:", filePath);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        error: "File not found",
        message: "The file to delete does not exist",
        path: filePath,
      });
    }

    fs.unlinkSync(filePath);

    console.log("File deleted successfully:", filename);

    res.json({
      success: true,
      message: "File deleted successfully",
      filename,
    });
  } catch (error) {
    console.error("Delete file error:", error);
    res.status(500).json({
      error: "Internal server error",
      message: "Failed to delete file",
      details: error.message,
    });
  }
};
