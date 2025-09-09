export const membershipType = (req, res, next) => {
  // Check if user exists
  if (!req.user) {
    return res.status(401).json({ message: "User not authenticated" });
  }

  const membershipType = req.user.membership.slug;

  // 3. Membership System
  // • Paket A → akses max 5 artikel & 5 video (free)
  // • Paket B → akses max 10 artikel & 10 video (premium)
  // • Paket C → akses unlimited (semua konten) (enterprise)

  switch (membershipType) {
    case "free":
      req.limit = 5;
      req.membershipLevel = "free";
      console.log("DISINI");
      break;

    case "premium":
      req.limit = 10;
      req.membershipLevel = "premium";
      break;

    case "enterprise":
      req.limit = null; // unlimited
      req.membershipLevel = "enterprise";
      break;

    // Handle empty or null membership (default to free)
    case "":
    case null:
    case undefined:
      req.limit = 5;
      req.membershipLevel = "free";
      break;

    default:
      // Unknown membership type, default to free
      req.limit = 5;
      req.membershipLevel = "free";
      console.warn(
        `Unknown membership type: ${membershipType}, defaulting to free`
      );
      break;
  }

  next();
};
