import { Sequelize } from "sequelize";
import db from "../config/Database.js";
import Roles from "./RolesModel.js";
import Memberships from "./MembershipModel.js";

const { DataTypes } = Sequelize;

const Users = db.define(
  "users",
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
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [3, 100],
      },
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: true,
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING(255),
      allowNull: true,
      validate: {
        notEmpty: true,
      },
    },
    picture: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    pictureUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
      validate: {
        isUrl: true,
      },
    },
    bio: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    role_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: Roles,
        key: "id",
      },
    },
    membership_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: Memberships,
        key: "id",
      },
    },
    membership_expires_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      allowNull: false,
    },
    last_login_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    email_verified_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    provider: {
      type: DataTypes.ENUM("local", "google", "facebook"),
      allowNull: false,
      defaultValue: "local",
      comment: "Authentication provider (local, google, facebook)",
    },
    provider_id: {
      type: DataTypes.STRING(255),
      allowNull: true,
      comment: "External provider ID (Google ID, Facebook ID, etc.)",
    },
  },
  {
    freezeTableName: true,
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ["email"],
      },
      {
        fields: ["role_id"],
      },
      {
        fields: ["membership_id"],
      },
      {
        fields: ["is_active"],
      },
      {
        fields: ["email_verified_at"],
      },
      {
        fields: ["last_login_at"],
      },
      {
        fields: ["provider"],
      },
      {
        fields: ["provider_id"],
      },
      {
        unique: true,
        fields: ["provider", "provider_id"],
        name: "unique_provider_id",
        where: {
          provider_id: {
            [Sequelize.Op.ne]: null,
          },
        },
      },
    ],
  }
);

// Definisi asosiasi
Users.belongsTo(Roles, {
  foreignKey: "role_id",
  as: "role",
  onDelete: "RESTRICT",
  onUpdate: "CASCADE",
});

Users.belongsTo(Memberships, {
  foreignKey: "membership_id",
  as: "membership",
  onDelete: "RESTRICT",
  onUpdate: "CASCADE",
});

Roles.hasMany(Users, {
  foreignKey: "role_id",
  as: "users",
});

Memberships.hasMany(Users, {
  foreignKey: "membership_id",
  as: "users",
});

export default Users;
