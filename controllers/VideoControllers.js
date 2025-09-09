import Videos from "../models/VideoModel.js";
import User from "../models/UserModel.js";
import { Op } from "sequelize";

export const getVideo = async (req, res) => {
  try {
    const {
      search = "",
      page = 1,
      perPage = 10,
      sortBy = "createdAt",
      sortOrder = "DESC",
      category = "",
      language = "",
      quality = "",
      isPublic = null,
      isFeatured = null,
      isPremium = null,
    } = req.body;

    const pageNumber = parseInt(page);
    const limitNumber = parseInt(perPage);
    const offset = (pageNumber - 1) * limitNumber;

    const membershipLimit = req.limit;
    const membershipLevel = req.membershipLevel;
    const userRole = req.userRole || req.role;

    console.log(
      `Applying membership limit: ${
        membershipLimit || "unlimited"
      } for ${membershipLevel}, role: ${userRole}`
    );

    const allowedSortColumns = [
      "id",
      "title",
      "views",
      "likes",
      "createdAt",
      "updatedAt",
      "publishedAt",
      "duration",
      "retentionRate",
      "clickThroughRate",
    ];

    const validSortBy =
      sortBy && allowedSortColumns.includes(sortBy) ? sortBy : "createdAt";

    const validSortOrder = ["ASC", "DESC"].includes(sortOrder?.toUpperCase())
      ? sortOrder.toUpperCase()
      : "DESC";

    const baseWhereCondition = {};

    if (userRole === "member") {
      baseWhereCondition.isActive = true;
    }

    let baseData;
    let totalMembershipItems;

    if (membershipLimit === null) {
      // Unlimited membership - get all data
      const { count, rows } = await Videos.findAndCountAll({
        attributes: [
          "id",
          "title",
          "description",
          "url",
          "thumbnail",
          "duration",
          "category",
          "tags",
          "language",
          "quality",
          "views",
          "likes",
          "dislikes",
          "comments",
          "shares",
          "isPublic",
          "isActive",
          "isFeatured",
          "isPremium",
          "monetizationEnabled",
          "ageRestriction",
          "publishedAt",
          "averageWatchTime",
          "retentionRate",
          "clickThroughRate",
          "fileSize",
          "encoding",
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
      const { count, rows } = await Videos.findAndCountAll({
        attributes: [
          "id",
          "title",
          "description",
          "url",
          "thumbnail",
          "duration",
          "category",
          "tags",
          "language",
          "quality",
          "views",
          "likes",
          "dislikes",
          "comments",
          "shares",
          "isPublic",
          "isActive",
          "isFeatured",
          "isPremium",
          "monetizationEnabled",
          "ageRestriction",
          "publishedAt",
          "averageWatchTime",
          "retentionRate",
          "clickThroughRate",
          "fileSize",
          "encoding",
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
      filteredData = filteredData.filter((video) => {
        const tagsMatch =
          video.tags && Array.isArray(video.tags)
            ? video.tags.some((tag) =>
                tag.toLowerCase().includes(normalizedSearch)
              )
            : false;

        return (
          video.title?.toLowerCase().includes(normalizedSearch) ||
          video.description?.toLowerCase().includes(normalizedSearch) ||
          tagsMatch ||
          video.user?.name?.toLowerCase().includes(normalizedSearch) ||
          video.user?.email?.toLowerCase().includes(normalizedSearch)
        );
      });
    }

    // Apply other filters...
    if (category) {
      filteredData = filteredData.filter(
        (video) => video.category === category
      );
    }

    if (language) {
      filteredData = filteredData.filter(
        (video) => video.language === language
      );
    }

    if (quality) {
      filteredData = filteredData.filter((video) => video.quality === quality);
    }

    if (isPublic !== null && isPublic !== "") {
      const publicFilter = isPublic === "true" || isPublic === true;
      filteredData = filteredData.filter(
        (video) => video.isPublic === publicFilter
      );
    }

    if (isFeatured !== null && isFeatured !== "") {
      const featuredFilter = isFeatured === "true" || isFeatured === true;
      filteredData = filteredData.filter(
        (video) => video.isFeatured === featuredFilter
      );
    }

    if (isPremium !== null && isPremium !== "") {
      const premiumFilter = isPremium === "true" || isPremium === true;
      filteredData = filteredData.filter(
        (video) => video.isPremium === premiumFilter
      );
    }

    const totalFilteredItems = filteredData.length;
    const totalFilteredPages = Math.ceil(totalFilteredItems / limitNumber);

    // Handle pagination...
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
          userRole: userRole, // Tambahkan info role
          message: "Page exceeds available data",
        },
        filters: {
          search,
          category,
          language,
          quality,
          isPublic,
          isFeatured,
          isPremium,
          sortBy: validSortBy,
          sortOrder: validSortOrder,
        },
        message: "success",
      });
    }

    const startIndex = (pageNumber - 1) * limitNumber;
    const endIndex = startIndex + limitNumber;
    const paginatedData = filteredData.slice(startIndex, endIndex);

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
          userRole: userRole,
          message: "Exceeded membership limit",
        },
        filters: {
          search,
          category,
          language,
          quality,
          isPublic,
          isFeatured,
          isPremium,
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
        userRole: userRole,
        baseDataCount: totalMembershipItems,
      },
      filters: {
        search,
        category,
        language,
        quality,
        isPublic,
        isFeatured,
        isPremium,
        sortBy: validSortBy,
        sortOrder: validSortOrder,
      },
      message: "success",
    });
  } catch (error) {
    console.error("Error in getVideo:", error);
    res.status(500).json({
      message: error.message,
      error: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
};

export const getVideoById = async (req, res) => {
  try {
    const userRole = req.userRole || req.role || req.user?.role || "member";

    const whereCondition = {
      id: req.params.id,
    };

    if (userRole === "member") {
      whereCondition.isActive = true;
    }

    const video = await Videos.findOne({
      where: whereCondition,
      attributes: [
        "id",
        "title",
        "description",
        "url",
        "thumbnail",
        "duration",
        "category",
        "tags",
        "language",
        "quality",
        "views",
        "likes",
        "dislikes",
        "comments",
        "shares",
        "isPublic",
        "isActive",
        "isFeatured",
        "isPremium",
        "monetizationEnabled",
        "ageRestriction",
        "publishedAt",
        "scheduledAt",
        "lastViewedAt",
        "averageWatchTime",
        "retentionRate",
        "clickThroughRate",
        "fileSize",
        "encoding",
        "metadata",
        "createdAt",
        "updatedAt",
      ],
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
      ],
    });

    if (!video) {
      return res.status(404).json({
        message:
          userRole === "member"
            ? "Video not found or not available"
            : "Video not found",
      });
    }

    res.status(200).json({
      data: video,
      message: "success",
    });
  } catch (error) {
    console.error("Error in getVideoById:", error);
    res.status(500).json({ message: error.message });
  }
};

export const createVideo = async (req, res) => {
  try {
    // Check if user role is member
    if (req.role === "member") {
      return res.status(403).json({
        message: "Access denied. Members cannot create videos.",
      });
    }

    const {
      title,
      description,
      url,
      thumbnail,
      duration,
      category,
      tags = [],
      language = "id",
      quality = "720p",
      isPublic = true,
      isPremium = false,
      monetizationEnabled = false,
      ageRestriction = "all",
      scheduledAt,
      metadata = {},
    } = req.body;

    // Basic validation
    if (!title || !url) {
      return res.status(400).json({
        message: "Title and URL are required",
      });
    }

    // URL validation
    const urlPattern = /^https?:\/\/.+/;
    if (!urlPattern.test(url)) {
      return res.status(400).json({
        message: "Invalid URL format. Must start with http:// or https://",
      });
    }

    // Category validation
    const validCategories = [
      "web-development",
      "programming",
      "data-science",
      "mobile-development",
      "lifestyle",
      "beauty",
      "health",
      "fitness",
      "education",
      "tutorial",
    ];
    if (category && !validCategories.includes(category)) {
      return res.status(400).json({
        message: "Invalid category",
      });
    }

    // Language validation
    const validLanguages = ["id", "en", "ja", "ko"];
    if (language && !validLanguages.includes(language)) {
      return res.status(400).json({
        message: "Invalid language. Must be one of: id, en, ja, ko",
      });
    }

    // Quality validation
    const validQualities = ["360p", "480p", "720p", "1080p", "1440p", "4k"];
    if (quality && !validQualities.includes(quality)) {
      return res.status(400).json({
        message: "Invalid quality",
      });
    }

    // Age restriction validation
    const validAgeRestrictions = ["all", "13+", "16+", "18+"];
    if (ageRestriction && !validAgeRestrictions.includes(ageRestriction)) {
      return res.status(400).json({
        message: "Invalid age restriction",
      });
    }

    const newVideo = await Videos.create({
      title,
      description,
      url,
      thumbnail,
      duration: duration || 0,
      category: category || "tutorial",
      tags: Array.isArray(tags) ? tags : [],
      language,
      quality,
      views: 0,
      likes: 0,
      dislikes: 0,
      comments: 0,
      shares: 0,
      isPublic,
      isActive: true,
      isFeatured: false,
      isPremium,
      monetizationEnabled,
      ageRestriction,
      publishedAt: scheduledAt ? null : new Date(),
      scheduledAt: scheduledAt || null,
      lastViewedAt: null,
      averageWatchTime: 0,
      retentionRate: 0,
      clickThroughRate: 0,
      fileSize: 0,
      encoding: "H.264",
      metadata: {
        uploadedFrom: "web",
        processingTime: 0,
        originalFileName: "",
        compressionRatio: 0.7,
        bitrate: 2000,
        ...metadata,
      },
      userId: req.userId,
    });

    res.status(201).json({
      message: "Video created successfully",
      data: newVideo,
    });
  } catch (error) {
    if (error.name === "SequelizeValidationError") {
      const validationErrors = error.errors.map((err) => ({
        field: err.path,
        message: err.message,
      }));
      return res.status(400).json({
        message: "Validation error",
        errors: validationErrors,
      });
    }

    if (error.name === "SequelizeForeignKeyConstraintError") {
      return res.status(400).json({
        message: "Invalid user ID. User does not exist.",
      });
    }

    res.status(500).json({ message: error.message });
  }
};

export const updateVideo = async (req, res) => {
  const { id } = req.params;

  try {
    if (req.user && req.user.role.slug === "member") {
      return res.status(403).json({
        message: "Members are not authorized to update videos",
      });
    }

    const video = await Videos.findOne({
      where: { id: id },
    });

    if (!video) {
      return res.status(404).json({ message: "Video not found" });
    }

    const {
      title,
      description,
      url,
      thumbnail,
      duration,
      category,
      tags,
      language,
      quality,
      isPublic,
      isFeatured,
      isActive,
      isPremium,
      monetizationEnabled,
      ageRestriction,
      scheduledAt,
      metadata,
    } = req.body;

    // URL validation if provided
    if (url) {
      const urlPattern = /^https?:\/\/.+/;
      if (!urlPattern.test(url)) {
        return res.status(400).json({
          message: "Invalid URL format",
        });
      }
    }

    // Update only provided fields
    const updateData = {};
    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (url !== undefined) updateData.url = url;
    if (thumbnail !== undefined) updateData.thumbnail = thumbnail;
    if (duration !== undefined) updateData.duration = duration;
    if (category !== undefined) updateData.category = category;
    if (tags !== undefined) updateData.tags = Array.isArray(tags) ? tags : [];
    if (language !== undefined) updateData.language = language;
    if (quality !== undefined) updateData.quality = quality;
    if (isPublic !== undefined) updateData.isPublic = isPublic;
    if (isActive !== undefined) updateData.isActive = isActive;
    if (isFeatured !== undefined) updateData.isFeatured = isFeatured;
    if (isPremium !== undefined) updateData.isPremium = isPremium;
    if (monetizationEnabled !== undefined)
      updateData.monetizationEnabled = monetizationEnabled;
    if (ageRestriction !== undefined)
      updateData.ageRestriction = ageRestriction;
    if (scheduledAt !== undefined) updateData.scheduledAt = scheduledAt;
    if (metadata !== undefined) {
      updateData.metadata = { ...video.metadata, ...metadata };
    }

    await video.update(updateData);

    // Get updated video with user info
    const updatedVideo = await Videos.findOne({
      where: { id: id },
      attributes: [
        "id",
        "title",
        "description",
        "url",
        "thumbnail",
        "duration",
        "category",
        "tags",
        "language",
        "quality",
        "views",
        "likes",
        "dislikes",
        "comments",
        "shares",
        "isPublic",
        "isActive",
        "isFeatured",
        "isPremium",
        "monetizationEnabled",
        "ageRestriction",
        "publishedAt",
        "averageWatchTime",
        "retentionRate",
        "clickThroughRate",
        "createdAt",
        "updatedAt",
      ],
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
      ],
    });

    res.status(200).json({
      message: "Video updated successfully",
      data: updatedVideo,
    });
  } catch (error) {
    if (error.name === "SequelizeValidationError") {
      const validationErrors = error.errors.map((err) => ({
        field: err.path,
        message: err.message,
      }));
      return res.status(400).json({
        message: "Validation error",
        errors: validationErrors,
      });
    }

    res.status(500).json({ message: error.message });
  }
};

export const deleteVideo = async (req, res) => {
  const { id } = req.params;

  try {
    if (req.user && req.user.role.slug === "member") {
      return res.status(403).json({
        message: "Members are not authorized to update videos",
      });
    }

    const video = await Videos.findOne({
      where: { id: id },
    });

    if (!video) {
      return res.status(404).json({ message: "Video not found" });
    }

    await video.destroy();

    res.status(200).json({
      message: "Video deleted successfully",
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Additional controller methods for the enhanced features

export const getVideosByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const { page = 1, perPage = 12 } = req.query;

    const pageNumber = parseInt(page);
    const limitNumber = parseInt(perPage);
    const offset = (pageNumber - 1) * limitNumber;

    const { count, rows } = await Videos.findAndCountAll({
      where: {
        category: category,
        isActive: true,
        isPublic: true,
      },
      attributes: [
        "id",
        "title",
        "thumbnail",
        "duration",
        "views",
        "likes",
        "publishedAt",
        "category",
        "isPremium",
        "ageRestriction",
      ],
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name"],
        },
      ],
      limit: limitNumber,
      offset: offset,
      order: [["publishedAt", "DESC"]],
    });

    const totalPages = Math.ceil(count / limitNumber);

    res.status(200).json({
      data: rows,
      pagination: {
        currentPage: pageNumber,
        perPage: limitNumber,
        totalItems: count,
        totalPages: totalPages,
      },
      message: "success",
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getTrendingVideos = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    // Get trending videos based on views and recent activity
    const videos = await Videos.findAll({
      where: {
        isActive: true,
        isPublic: true,
        publishedAt: {
          [Op.gte]: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Last 30 days
        },
      },
      attributes: [
        "id",
        "title",
        "thumbnail",
        "duration",
        "views",
        "likes",
        "publishedAt",
        "category",
        "retentionRate",
      ],
      include: [
        {
          model: User,
          as: "user",
          attributes: ["id", "name"],
        },
      ],
      order: [
        ["views", "DESC"],
        ["likes", "DESC"],
        ["retentionRate", "DESC"],
      ],
      limit: parseInt(limit),
    });

    res.status(200).json({
      data: videos,
      message: "success",
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const incrementVideoView = async (req, res) => {
  try {
    const { id } = req.params;

    const video = await Videos.findOne({
      where: { id: id, isActive: true },
    });

    if (!video) {
      return res.status(404).json({ message: "Video not found" });
    }

    await video.increment("views", { by: 1 });
    await video.update({ lastViewedAt: new Date() });

    res.status(200).json({
      message: "View count updated",
      views: video.views + 1,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const likeVideo = async (req, res) => {
  try {
    const { id } = req.params;

    const video = await Videos.findOne({
      where: { id: id, isActive: true },
    });

    if (!video) {
      return res.status(404).json({ message: "Video not found" });
    }

    await video.increment("likes", { by: 1 });

    res.status(200).json({
      message: "Video liked",
      likes: video.likes + 1,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getVideoAnalytics = async (req, res) => {
  try {
    // Check if user role is member
    if (req.role === "member") {
      return res.status(403).json({
        message: "Access denied. Members cannot access video analytics.",
      });
    }

    const { id } = req.params;

    const video = await Videos.findOne({
      where: { id: id },
      attributes: [
        "id",
        "title",
        "views",
        "likes",
        "dislikes",
        "comments",
        "shares",
        "averageWatchTime",
        "retentionRate",
        "clickThroughRate",
        "duration",
        "publishedAt",
        "fileSize",
        "encoding",
        "userId",
      ],
    });

    if (!video) {
      return res.status(404).json({ message: "Video not found" });
    }

    // Check ownership (admin can view any analytics, others only their own)
    if (video.userId !== req.userId && req.role !== "admin") {
      return res.status(403).json({
        message:
          "Access denied. You can only view analytics for your own videos.",
      });
    }

    res.status(200).json({
      data: video,
      message: "success",
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
