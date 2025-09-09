import jwt from "jsonwebtoken";

export const jwtAuth = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (token) {
      const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decodedToken;
      return next();
    }

    const { accessToken } = req.body || req.query;

    if (accessToken) {
      const response = await axios.get(
        `https://graph.facebook.com/me?access_token=${accessToken}&fields=id,name,email,picture`
      );
      const userProfile = response.data;

      if (userProfile) {
        const newToken = jwt.sign(
          {
            id: userProfile.id,
            name: userProfile.name,
            email: userProfile.email,
          },
          process.env.JWT_SECRET,
          { expiresIn: "7d" }
        );

        res.setHeader("Authorization", `Bearer ${newToken}`);

        req.user = userProfile;

        return next();
      } else {
        return res
          .status(401)
          .json({ message: "Unauthorized: Invalid Facebook access token" });
      }
    }

    return res.status(401).json({ message: "Unauthorized: No token provided" });
  } catch (error) {
    console.error("Error verifying token or Facebook accessToken:", error);
    res.status(401).json({ message: "Unauthorized: Invalid or expired token" });
  }
};
