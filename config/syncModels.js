// Import models dalam urutan yang benar
import Roles from "../models/RolesModel.js";
import Memberships from "../models/MembershipModel.js";
import Users from "../models/UserModel.js";
import Articles from "../models/ArticleModel.js";
import Videos from "../models/VideoModel.js";

// Function untuk sync models dengan urutan yang benar
export const syncModels = async () => {
  try {
    // await Roles.sync({ alter: false });
    // console.log("✅ Roles table synced");

    // await Memberships.sync({ alter: false });
    // console.log("✅ Memberships table synced");

    // await Users.sync({ alter: false });
    // console.log("✅ Users table synced");

    // await Articles.sync({ alter: false });
    // console.log("✅ Articles table synced");

    // await Videos.sync({ alter: false });
    // console.log("✅ Videos table synced");

    return true;
  } catch (error) {
    console.error("❌ Model sync failed:", error.message);
    throw error;
  }
};
