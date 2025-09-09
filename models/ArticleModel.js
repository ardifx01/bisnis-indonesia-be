import { Sequelize } from "sequelize";
import db from "../config/Database.js";
import Users from "./UserModel.js";

const { DataTypes } = Sequelize;

const Articles = db.define(
  "articles",
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
    slug: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
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
    excerpt: {
      type: DataTypes.TEXT,
      allowNull: true,
      validate: {
        len: [0, 500], // Max 500 characters for excerpt
      },
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
    thumbnail: {
      type: DataTypes.TEXT,
      allowNull: true,
      validate: {
        isUrl: {
          msg: "Thumbnail must be a valid URL",
        },
      },
    },
    thumbnailAlt: {
      type: DataTypes.STRING(255),
      allowNull: true,
      field: "thumbnail_alt",
    },
    metaTitle: {
      type: DataTypes.STRING(60),
      allowNull: true,
      field: "meta_title",
      validate: {
        len: [0, 60], // SEO recommended length
      },
    },
    metaDescription: {
      type: DataTypes.STRING(160),
      allowNull: true,
      field: "meta_description",
      validate: {
        len: [0, 160], // SEO recommended length
      },
    },
    keywords: {
      type: DataTypes.TEXT,
      allowNull: true,
      get() {
        const rawValue = this.getDataValue("keywords");
        return rawValue ? rawValue.split(",").map((tag) => tag.trim()) : [];
      },
      set(val) {
        if (Array.isArray(val)) {
          this.setDataValue("keywords", val.join(","));
        } else if (typeof val === "string") {
          this.setDataValue("keywords", val);
        }
      },
    },
    status: {
      type: DataTypes.ENUM("draft", "published", "archived", "scheduled"),
      defaultValue: "draft",
      allowNull: false,
    },
    publishedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    scheduledAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    viewsCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
      validate: {
        min: 0,
      },
    },
    likesCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
    },
    commentsCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      allowNull: false,
      validate: {
        min: 0,
      },
    },
    readingTime: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: "Estimated reading time in minutes",
    },
    featured: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
    },
    allowComments: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false,
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
  },
  {
    freezeTableName: true,
    timestamps: true,
    indexes: [
      {
        fields: ["userId"],
      },
      {
        fields: ["title"],
      },
      {
        fields: ["status"],
      },
      {
        fields: ["publishedAt"],
      },
      {
        fields: ["createdAt"],
      },
      {
        fields: ["viewsCount"],
      },
      {
        fields: ["featured"],
      },
      {
        unique: true,
        fields: ["slug"],
      },
    ],
    // Add hooks for auto-calculating fields
    hooks: {
      beforeCreate: (article) => {
        // Auto-generate excerpt if not provided
        if (!article.excerpt && article.content) {
          const plainText = article.content.replace(/<[^>]*>/g, "");
          article.excerpt = plainText.substring(0, 200) + "...";
        }

        // Auto-calculate reading time
        if (article.content) {
          const wordsPerMinute = 200;
          const wordCount = article.content.split(/\s+/).length;
          article.readingTime = Math.ceil(wordCount / wordsPerMinute);
        }

        // Set publishedAt if status is published
        if (article.status === "published" && !article.publishedAt) {
          article.publishedAt = new Date();
        }
      },
      beforeUpdate: (article) => {
        // Auto-generate excerpt if not provided
        if (!article.excerpt && article.content) {
          const plainText = article.content.replace(/<[^>]*>/g, "");
          article.excerpt = plainText.substring(0, 200) + "...";
        }

        // Auto-calculate reading time
        if (article.content) {
          const wordsPerMinute = 200;
          const wordCount = article.content.split(/\s+/).length;
          article.readingTime = Math.ceil(wordCount / wordsPerMinute);
        }

        // Set publishedAt when changing status to published
        if (article.status === "published" && !article.publishedAt) {
          article.publishedAt = new Date();
        }
      },
    },
    scopes: {
      published: {
        where: {
          status: "published",
          publishedAt: {
            [Sequelize.Op.lte]: new Date(),
          },
        },
      },
      featured: {
        where: {
          featured: true,
        },
      },
      draft: {
        where: {
          status: "draft",
        },
      },
      withAuthor: {
        include: [
          {
            model: Users,
            as: "user",
            attributes: ["id", "name", "email", "pictureUrl"],
          },
        ],
      },
    },
  }
);

Users.hasMany(Articles, {
  foreignKey: "userId",
  as: "articles",
  onDelete: "CASCADE",
  onUpdate: "CASCADE",
});

Articles.belongsTo(Users, {
  foreignKey: "userId",
  as: "user",
  onDelete: "CASCADE",
  onUpdate: "CASCADE",
});

export default Articles;
