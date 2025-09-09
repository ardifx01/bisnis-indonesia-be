import { Sequelize } from "sequelize";
import db from "../config/Database.js";
import Users from "./UserModel.js";

const { DataTypes } = Sequelize;

const Videos = db.define(
  "videos",
  {
    id: {
      primaryKey: true,
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [3, 255],
      },
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
      validate: {
        len: [0, 2000],
      },
    },
    url: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
        isUrl: true,
      },
    },
    thumbnail: {
      type: DataTypes.TEXT,
      allowNull: true,
      validate: {
        isUrl: true,
      },
    },
    duration: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: "Duration in seconds",
      validate: {
        min: 1,
        max: 43200, // 12 hours max
      },
    },
    category: {
      type: DataTypes.ENUM(
        "web-development",
        "programming",
        "data-science",
        "mobile-development",
        "devops",
        "design",
        "ai-ml",
        "cybersecurity",
        "blockchain",
        "tutorial",
        "lifestyle",
        "beauty",
        "health",
        "fitness",
        "cooking",
        "travel",
        "photography",
        "music",
        "education",
        "business",
        "entertainment",
        "gaming",
        "sports",
        "news",
        "science",
        "technology",
        "other"
      ),
      allowNull: false,
      defaultValue: "other",
    },
    tags: {
      type: DataTypes.JSON,
      allowNull: true,
      defaultValue: [],
      validate: {
        isValidTags(value) {
          if (value && !Array.isArray(value)) {
            throw new Error("Tags must be an array");
          }
          if (value && value.length > 20) {
            throw new Error("Maximum 20 tags allowed");
          }
        },
      },
    },
    language: {
      type: DataTypes.STRING(10),
      allowNull: false,
      defaultValue: "id",
      validate: {
        isIn: [["id", "en", "es", "fr", "de", "ja", "ko", "zh", "ar", "hi"]],
      },
    },
    quality: {
      type: DataTypes.ENUM(
        "144p",
        "240p",
        "360p",
        "480p",
        "720p",
        "1080p",
        "1440p",
        "2160p"
      ),
      allowNull: false,
      defaultValue: "720p",
    },
    views: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: 0,
      },
    },
    likes: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: 0,
      },
    },
    dislikes: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: 0,
      },
    },
    comments: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: 0,
      },
    },
    shares: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      validate: {
        min: 0,
      },
    },
    isPublic: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
    isFeatured: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    isPremium: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    monetizationEnabled: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    ageRestriction: {
      type: DataTypes.ENUM("all", "13+", "16+", "18+"),
      allowNull: false,
      defaultValue: "all",
    },
    publishedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    scheduledAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    lastViewedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    averageWatchTime: {
      type: DataTypes.FLOAT,
      allowNull: true,
      comment: "Average watch time in seconds",
      validate: {
        min: 0,
      },
    },
    retentionRate: {
      type: DataTypes.FLOAT,
      allowNull: true,
      comment: "Retention rate percentage (0-100)",
      validate: {
        min: 0,
        max: 100,
      },
    },
    clickThroughRate: {
      type: DataTypes.FLOAT,
      allowNull: true,
      comment: "CTR percentage (0-100)",
      validate: {
        min: 0,
        max: 100,
      },
    },
    engagementScore: {
      type: DataTypes.FLOAT,
      allowNull: true,
      comment: "Overall engagement score (0-10)",
      validate: {
        min: 0,
        max: 10,
      },
    },
    fileSize: {
      type: DataTypes.BIGINT,
      allowNull: true,
      comment: "File size in bytes",
      validate: {
        min: 1,
      },
    },
    encoding: {
      type: DataTypes.STRING(50),
      allowNull: true,
      defaultValue: "H.264",
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: Users,
        key: "id",
      },
      validate: {
        notEmpty: true,
      },
    },
    metadata: {
      type: DataTypes.JSON,
      allowNull: true,
      defaultValue: {},
      comment: "Additional metadata for video processing info, etc.",
    },
  },
  {
    freezeTableName: true,
    timestamps: true,
    paranoid: true, // Soft delete
    indexes: [
      {
        fields: ["userId"],
      },
      {
        fields: ["title"],
      },
      {
        fields: ["category"],
      },
      {
        fields: ["language"],
      },
      {
        fields: ["views"],
      },
      {
        fields: ["likes"],
      },
      {
        fields: ["publishedAt"],
      },
      {
        fields: ["createdAt"],
      },
      {
        fields: ["isPublic", "isActive"],
      },
      {
        fields: ["isFeatured"],
      },
      // Removed the problematic GIN index that requires pg_trgm extension
    ],
    hooks: {
      beforeSave: async (video, options) => {
        // Auto-calculate engagement score
        if (video.views > 0) {
          const likeRatio = video.likes / (video.likes + video.dislikes || 1);
          const commentRatio = video.comments / video.views;
          const shareRatio = video.shares / video.views;

          video.engagementScore = Math.min(
            10,
            (likeRatio * 3 + commentRatio * 100 + shareRatio * 50) * 2
          );
        }

        // Set publishedAt if going public for first time
        if (video.isPublic && !video.publishedAt) {
          video.publishedAt = new Date();
        }

        // Update lastViewedAt when views increase
        if (video.changed("views") && video.views > 0) {
          video.lastViewedAt = new Date();
        }
      },
    },
  }
);

// Instance methods
Videos.prototype.incrementViews = async function (count = 1) {
  this.views += count;
  this.lastViewedAt = new Date();
  return this.save();
};

Videos.prototype.addLike = async function () {
  this.likes += 1;
  return this.save();
};

Videos.prototype.addDislike = async function () {
  this.dislikes += 1;
  return this.save();
};

Videos.prototype.incrementComments = async function (count = 1) {
  this.comments += count;
  return this.save();
};

Videos.prototype.incrementShares = async function (count = 1) {
  this.shares += count;
  return this.save();
};

Videos.prototype.getDurationFormatted = function () {
  if (!this.duration) return "Unknown";

  const hours = Math.floor(this.duration / 3600);
  const minutes = Math.floor((this.duration % 3600) / 60);
  const seconds = this.duration % 60;

  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, "0")}:${seconds
      .toString()
      .padStart(2, "0")}`;
  }
  return `${minutes}:${seconds.toString().padStart(2, "0")}`;
};

Videos.prototype.getEngagementRate = function () {
  if (this.views === 0) return 0;
  return (
    ((this.likes + this.comments + this.shares) / this.views) *
    100
  ).toFixed(2);
};

Videos.prototype.getLikeRatio = function () {
  const total = this.likes + this.dislikes;
  if (total === 0) return 0;
  return ((this.likes / total) * 100).toFixed(1);
};

// Definisi asosiasi
Users.hasMany(Videos, {
  foreignKey: "userId",
  as: "videos",
  onDelete: "CASCADE",
  onUpdate: "CASCADE",
});

Videos.belongsTo(Users, {
  foreignKey: "userId",
  as: "user",
  onDelete: "CASCADE",
  onUpdate: "CASCADE",
});

export default Videos;
