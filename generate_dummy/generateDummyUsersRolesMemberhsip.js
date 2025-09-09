import argon2 from "argon2";
import db from "../config/Database.js";
import Roles from "../models/RolesModel.js";
import Memberships from "../models/MembershipModel.js";
import Users from "../models/UserModel.js";

const generateEverything = async () => {
  try {
    // Disable foreign key checks temporarily (PostgreSQL way)
    await db.query("SET session_replication_role = 'replica'");

    // Drop tables if exists (termasuk enum types)
    await db.query("DROP TABLE IF EXISTS users CASCADE");
    await db.query("DROP TABLE IF EXISTS roles CASCADE");
    await db.query("DROP TABLE IF EXISTS memberships CASCADE");
    await db.query("DROP TYPE IF EXISTS enum_users_provider CASCADE");

    // Re-enable foreign key checks
    await db.query("SET session_replication_role = 'origin'");

    // 2. Create tables
    await Roles.sync({ force: true });
    await Memberships.sync({ force: true });
    await Users.sync({ force: true });

    // 3. Create roles
    // const roles = await Roles.bulkCreate([
    //   {
    //     id: "550e8400-e29b-41d4-a716-446655440001",
    //     name: "Super Admin",
    //     slug: "super_admin",
    //     description: "Full system access",
    //     permissions: ["*"],
    //   },
    //   {
    //     id: "550e8400-e29b-41d4-a716-446655440002",
    //     name: "Admin",
    //     slug: "admin",
    //     description: "Administrative access",
    //     permissions: [
    //       "users.read",
    //       "users.create",
    //       "users.update",
    //       "users.delete",
    //     ],
    //   },
    //   {
    //     id: "550e8400-e29b-41d4-a716-446655440003",
    //     name: "Member",
    //     slug: "member",
    //     description: "Regular user access",
    //     permissions: ["profile.read", "profile.update"],
    //   },
    // ]);

    // 4. Create memberships
    // const memberships = await Memberships.bulkCreate([
    //   {
    //     id: "660e8400-e29b-41d4-a716-446655440001",
    //     name: "Free",
    //     slug: "free",
    //     description: "Basic membership",
    //     price: 0.0,
    //     duration_days: 365,
    //     features: ["Basic Support", "Limited Storage"],
    //   },
    //   {
    //     id: "660e8400-e29b-41d4-a716-446655440002",
    //     name: "Premium",
    //     slug: "premium",
    //     description: "Advanced features",
    //     price: 29.99,
    //     duration_days: 30,
    //     features: ["Priority Support", "Advanced Analytics"],
    //   },
    //   {
    //     id: "660e8400-e29b-41d4-a716-446655440003",
    //     name: "Enterprise",
    //     slug: "enterprise",
    //     description: "Unlimited access",
    //     price: 99.99,
    //     duration_days: 30,
    //     features: ["24/7 Support", "Custom Solutions"],
    //   },
    // ]);

    // 5. Hash password
    const hashedPassword = await argon2.hash("password");

    // 6. Calculate expiry dates
    const calculateExpiry = (days) => {
      return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
    };

    // 7. Create users with provider info
    const users = await Users.bulkCreate([
      {
        name: "Super Admin",
        email: "superadmin@example.com",
        password: hashedPassword,
        bio: "System Super Administrator",
        role_id: "550e8400-e29b-41d4-a716-446655440001", // super_admin
        membership_id: "660e8400-e29b-41d4-a716-446655440003", // enterprise
        membership_expires_at: calculateExpiry(365),
        pictureUrl: "https://i.pravatar.cc/150?img=1",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Admin User",
        email: "admin@example.com",
        password: hashedPassword,
        bio: "System Administrator",
        role_id: "550e8400-e29b-41d4-a716-446655440002", // admin
        membership_id: "660e8400-e29b-41d4-a716-446655440002", // premium
        membership_expires_at: calculateExpiry(90),
        pictureUrl: "https://i.pravatar.cc/150?img=2",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "John Doe",
        email: "john.doe@example.com",
        password: hashedPassword,
        bio: "Regular member user",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440001", // free
        membership_expires_at: calculateExpiry(365),
        pictureUrl: "https://i.pravatar.cc/150?img=3",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Jane Smith ",
        email: "jane.smith@gmail.com",
        password: hashedPassword,
        bio: "Premium member user ",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440002", // premium
        membership_expires_at: calculateExpiry(30),
        pictureUrl: "https://i.pravatar.cc/150?img=4",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Bob Johnson",
        email: "bob.johnson@example.com",
        password: hashedPassword,
        bio: "Content creator and writer",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440002", // premium
        membership_expires_at: calculateExpiry(30),
        pictureUrl: "https://i.pravatar.cc/150?img=5",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Alice Brown",
        email: "alice.brown@example.com",
        password: hashedPassword,
        bio: "Video content specialist",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440003", // enterprise
        membership_expires_at: calculateExpiry(30),
        pictureUrl: "https://i.pravatar.cc/150?img=6",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Charlie Wilson",
        email: "charlie.wilson@gmail.com",
        password: hashedPassword,
        bio: "Tech enthusiast and blogger (Google Login)",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440001", // free
        membership_expires_at: calculateExpiry(365),
        pictureUrl: "https://i.pravatar.cc/150?img=7",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Diana Davis",
        email: "diana.davis@example.com",
        password: hashedPassword,
        bio: "Marketing specialist",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440002", // premium
        membership_expires_at: calculateExpiry(30),
        pictureUrl: "https://i.pravatar.cc/150?img=8",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Edward Miller",
        email: "edward.miller@example.com",
        password: hashedPassword,
        bio: "Software developer",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440001", // free
        membership_expires_at: calculateExpiry(365),
        pictureUrl: "https://i.pravatar.cc/150?img=9",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
      {
        name: "Fiona Garcia",
        email: "fiona.garcia@example.com",
        password: hashedPassword,
        bio: "UI/UX Designer",
        role_id: "550e8400-e29b-41d4-a716-446655440003", // member
        membership_id: "660e8400-e29b-41d4-a716-446655440002", // premium
        membership_expires_at: calculateExpiry(30),
        pictureUrl: "https://i.pravatar.cc/150?img=10",
        is_active: true,
        email_verified_at: new Date(),
        provider: "local",
        provider_id: null,
      },
    ]);

    // 8. Display results
    console.log("\n LOGIN CREDENTIALS (Local):");
    console.log("   superadmin@example.com | password");
    console.log("   admin@example.com | password");
    console.log("   john.doe@example.com | password");

    console.log("\n All done! Database is ready to use!");
  } catch (error) {
    console.error(" Error:", error);
    throw error;
  } finally {
    await db.close();
    process.exit(0);
  }
};

generateEverything().catch(console.error);
