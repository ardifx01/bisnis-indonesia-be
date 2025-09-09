import db from "../config/Database.js";
import Videos from "../models/VideoModel.js";
import Users from "../models/UserModel.js";

const generateDummyVideos = async () => {
  try {
    console.log("🎬 Starting video generation...");

    // Sync database
    await db.sync({ force: false });

    // Clean existing videos
    const deletedCount = await Videos.destroy({
      where: {},
      force: true,
      truncate: true,
    });

    console.log(`🗑️  Deleted ${deletedCount} old videos`);

    // Get existing users
    const existingUsers = await Users.findAll({
      attributes: ["id", "name"],
      limit: 50,
      order: [["createdAt", "DESC"]],
    });

    if (existingUsers.length === 0) {
      console.error("❌ No users found! Create users first.");
      return;
    }

    console.log(`👥 Found ${existingUsers.length} users`);

    // Video data by category
    const videoData = {
      "web-development": [
        "HTML5 Semantic Elements Complete Guide",
        "CSS Grid Layout Mastery Course",
        "JavaScript ES2024 New Features",
        "React 18 Server Components Tutorial",
        "Vue 3 Composition API Deep Dive",
        "Angular 17 Standalone Components",
        "TypeScript Advanced Types Workshop",
        "Next.js 14 App Router Complete Guide",
        "Svelte 5 Runes System Tutorial",
        "Web Performance Optimization Masterclass",
        "Responsive Design with CSS Flexbox",
        "Progressive Web Apps Development",
        "GraphQL API with Apollo Server",
        "Webpack 5 Module Federation",
        "Tailwind CSS Advanced Techniques",
      ],
      programming: [
        "Python Clean Code Principles",
        "Java Spring Boot Microservices",
        "C++ Modern Features 2024",
        "Go Concurrent Programming Guide",
        "Rust Memory Safety Fundamentals",
        "Node.js Event Loop Explained",
        "Algorithm Design Patterns",
        "Data Structures Visualization",
        "Code Review Best Practices",
        "Software Architecture Patterns",
        "Design Patterns Implementation",
        "Test Driven Development TDD",
        "Clean Architecture Principles",
        "SOLID Programming Principles",
        "Functional Programming Concepts",
      ],
      "data-science": [
        "Machine Learning with Python",
        "Deep Learning Neural Networks",
        "Data Visualization with D3.js",
        "Statistical Analysis in R",
        "SQL for Data Analytics",
        "Pandas Data Manipulation",
        "Scikit-learn Model Selection",
        "TensorFlow 2.0 Complete Course",
        "Data Pipeline Architecture",
        "Big Data with Apache Spark",
        "Natural Language Processing NLP",
        "Computer Vision OpenCV",
        "Time Series Analysis",
        "A/B Testing for Data Science",
        "MLOps Production Deployment",
      ],
      "mobile-development": [
        "React Native Cross-Platform Apps",
        "Flutter Widget Development",
        "Swift iOS App Development",
        "Kotlin Android Programming",
        "Mobile UI/UX Design Principles",
        "App Store Optimization Guide",
        "Firebase Integration Tutorial",
        "Push Notifications Implementation",
        "Mobile App Testing Strategies",
        "Progressive Web Apps PWA",
        "Xamarin Cross-Platform Development",
        "Ionic Hybrid App Development",
        "Mobile App Security Best Practices",
        "React Native Navigation",
        "Flutter State Management",
      ],
      lifestyle: [
        "Morning Productivity Routine",
        "Minimalist Living Guide",
        "Work-Life Balance Tips",
        "Meditation for Beginners",
        "Healthy Cooking Recipes",
        "Home Organization Hacks",
        "Budget Planning Strategies",
        "Time Management Techniques",
        "Digital Detox Challenge",
        "Personal Development Journey",
        "Sustainable Living Practices",
        "Stress Management Techniques",
        "Self-Care Routine Ideas",
        "Goal Setting and Achievement",
        "Habit Building Strategies",
      ],
      beauty: [
        "Korean Skincare K-Beauty Routine",
        "Makeup Tutorial for Beginners",
        "Natural Beauty DIY Recipes",
        "Anti-Aging Skincare Science",
        "Hair Care and Styling Tips",
        "Acne Treatment Solutions",
        "Ingredient Analysis Guide",
        "Professional Makeup Techniques",
        "Skincare for Different Skin Types",
        "Beauty Product Reviews 2024",
        "Eyeshadow Blending Techniques",
        "Contouring and Highlighting",
        "Lip Care and Lipstick Tips",
        "Nail Art Designs Tutorial",
        "Men's Grooming Essentials",
      ],
      health: [
        "Nutrition Facts and Myths",
        "Mental Health Awareness",
        "Stress Management Techniques",
        "Sleep Quality Improvement",
        "Immune System Boosting",
        "Heart Health Exercise Guide",
        "Diabetes Management Tips",
        "Healthy Aging Strategies",
        "Women's Health Topics",
        "Men's Health Essentials",
        "Hydration and Water Intake",
        "Vitamins and Supplements Guide",
        "Posture Correction Exercises",
        "Eye Health and Screen Time",
        "Digestive Health Tips",
      ],
      fitness: [
        "Full Body Workout Routine",
        "Yoga for Flexibility",
        "HIIT Training Methods",
        "Strength Training Basics",
        "Running Marathon Preparation",
        "Home Gym Setup Guide",
        "Nutrition for Athletes",
        "Injury Prevention Exercises",
        "Bodyweight Training Program",
        "Recovery and Rest Importance",
        "CrossFit Training Basics",
        "Pilates Core Strengthening",
        "Swimming Technique Guide",
        "Cycling Training Programs",
        "Weight Loss Exercise Plans",
      ],
      education: [
        "Study Techniques That Work",
        "Online Learning Best Practices",
        "STEM Education Innovation",
        "Language Learning Methods",
        "Critical Thinking Skills",
        "Research Methodology Guide",
        "Academic Writing Tips",
        "Test Taking Strategies",
        "Educational Technology Tools",
        "Lifelong Learning Mindset",
        "Memory Improvement Techniques",
        "Note Taking Strategies",
        "Presentation Skills Development",
        "Public Speaking Confidence",
        "Speed Reading Techniques",
      ],
      tutorial: [
        "Adobe Photoshop Complete Guide",
        "Microsoft Excel Advanced Formulas",
        "WordPress Website Creation",
        "Video Editing with Premiere Pro",
        "Digital Marketing Fundamentals",
        "Social Media Management",
        "SEO Optimization Techniques",
        "Email Marketing Strategies",
        "Content Creation Tips",
        "Blogging for Beginners",
        "Podcast Creation Guide",
        "YouTube Channel Growth",
        "Graphic Design Principles",
        "Photography Basics",
        "3D Modeling with Blender",
      ],
    };

    // Sample URLs (YouTube embeds)
    const sampleUrls = [
      "https://www.youtube.com/embed/9xwazD5SyVg",
      "https://www.youtube.com/embed/dQw4w9WgXcQ",
      "https://www.youtube.com/embed/L_jWHffIx5E",
      "https://www.youtube.com/embed/jNQXAC9IVRw",
      "https://www.youtube.com/embed/fJ9rUzIMcZQ",
      "https://www.youtube.com/embed/kJQP7kiw5Fk",
      "https://www.youtube.com/embed/hFmPveauxd0",
      "https://www.youtube.com/embed/ZXsQAXx_ao0",
      "https://www.youtube.com/embed/Ke90Tje7VS0",
      "https://www.youtube.com/embed/6stlCkUDG_s",
      "https://www.youtube.com/embed/ScMzIvxBSi4",
      "https://www.youtube.com/embed/2Vv-BfVoq4g",
      "https://www.youtube.com/embed/QH2-TGUlwu4",
      "https://www.youtube.com/embed/nfWlot6h_JM",
      "https://www.youtube.com/embed/BBAyRBTfsOU",
    ];

    // Thumbnail URLs
    const sampleThumbnails = [
      "https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg",
      "https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
      "https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg",
      "https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg",
      "https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg",
      "https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg",
      "https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg",
      "https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg",
    ];

    // Quality distribution (weighted)
    const qualityOptions = ["720p", "1080p", "480p", "1440p", "360p"];
    const qualityWeights = [40, 35, 15, 8, 2];

    // Languages with weights
    const languageOptions = ["id", "en", "ja", "ko"];
    const languageWeights = [60, 35, 3, 2];

    // Tags by category
    const categoryTags = {
      "web-development": [
        "javascript",
        "html",
        "css",
        "react",
        "nodejs",
        "frontend",
        "backend",
        "fullstack",
      ],
      programming: [
        "python",
        "java",
        "algorithms",
        "coding",
        "software",
        "development",
        "clean-code",
      ],
      "data-science": [
        "machine-learning",
        "ai",
        "python",
        "statistics",
        "analytics",
        "visualization",
      ],
      "mobile-development": [
        "react-native",
        "flutter",
        "ios",
        "android",
        "mobile-app",
        "cross-platform",
      ],
      lifestyle: [
        "productivity",
        "wellness",
        "minimalism",
        "self-improvement",
        "life-tips",
      ],
      beauty: [
        "skincare",
        "makeup",
        "beauty-tips",
        "cosmetics",
        "self-care",
        "grooming",
      ],
      health: [
        "nutrition",
        "mental-health",
        "wellness",
        "medical",
        "healthy-living",
      ],
      fitness: [
        "workout",
        "exercise",
        "gym",
        "training",
        "health",
        "bodybuilding",
        "cardio",
      ],
      education: [
        "learning",
        "study-tips",
        "academic",
        "knowledge",
        "skills",
        "teaching",
      ],
      tutorial: [
        "howto",
        "guide",
        "tips",
        "tutorial",
        "learn",
        "beginner",
        "advanced",
      ],
    };

    // Helper functions
    const getRandomWeighted = (options, weights) => {
      const totalWeight = weights.reduce((sum, weight) => sum + weight, 0);
      let random = Math.random() * totalWeight;

      for (let i = 0; i < options.length; i++) {
        random -= weights[i];
        if (random <= 0) {
          return options[i];
        }
      }
      return options[0];
    };

    const generateViews = () => {
      const rand = Math.random();
      if (rand < 0.05) return Math.floor(Math.random() * 1000000) + 500000; // Viral videos (5%)
      if (rand < 0.15) return Math.floor(Math.random() * 500000) + 50000; // Very popular (10%)
      if (rand < 0.35) return Math.floor(Math.random() * 50000) + 5000; // Popular (20%)
      if (rand < 0.65) return Math.floor(Math.random() * 5000) + 500; // Medium (30%)
      return Math.floor(Math.random() * 500) + 10; // Low views (35%)
    };

    const generateEngagementFromViews = (views) => {
      const baseEngagementRate = 0.02 + Math.random() * 0.08; // 2-10% base engagement
      const likes = Math.floor(
        views * baseEngagementRate * (0.7 + Math.random() * 0.6)
      );
      const dislikes = Math.floor(likes * (0.03 + Math.random() * 0.12)); // 3-15% of likes
      const comments = Math.floor(likes * (0.08 + Math.random() * 0.25)); // 8-33% of likes
      const shares = Math.floor(likes * (0.01 + Math.random() * 0.06)); // 1-7% of likes

      return { likes, dislikes, comments, shares };
    };

    const generateDescription = (title, category) => {
      const templates = [
        `Dalam video ini, kita akan membahas ${title.toLowerCase()}. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!`,

        `${title} - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.`,

        `Tutorial ${title.toLowerCase()} step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!`,

        `Pelajari ${title.toLowerCase()} dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!`,

        `${title} explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.`,
      ];

      return templates[Math.floor(Math.random() * templates.length)];
    };

    const generateDuration = () => {
      const rand = Math.random();
      if (rand < 0.25) return Math.floor(Math.random() * 240) + 60; // Short: 1-5 min
      if (rand < 0.65) return Math.floor(Math.random() * 600) + 300; // Medium: 5-15 min
      if (rand < 0.9) return Math.floor(Math.random() * 1200) + 900; // Long: 15-35 min
      return Math.floor(Math.random() * 2400) + 1800; // Very long: 30-70 min
    };

    // Generate videos
    const numberOfVideos = Math.floor(Math.random() * 81) + 120; // 120-200 videos
    const dummyVideos = [];
    const usedTitles = new Set();

    console.log(`📊 Generating ${numberOfVideos} videos...`);

    for (let i = 0; i < numberOfVideos; i++) {
      const randomUser =
        existingUsers[Math.floor(Math.random() * existingUsers.length)];

      // Select category
      const categories = Object.keys(videoData);
      const category =
        categories[Math.floor(Math.random() * categories.length)];

      // Select title
      const titles = videoData[category];
      let title;
      let attempts = 0;
      do {
        const baseTitle = titles[Math.floor(Math.random() * titles.length)];
        const shouldAddPart = Math.random() < 0.3;
        const variation = shouldAddPart
          ? ` - Part ${Math.floor(Math.random() * 5) + 1}`
          : "";
        title = baseTitle + variation;
        attempts++;

        if (attempts > 50) {
          title += ` #${Math.floor(Math.random() * 1000)}`;
          break;
        }
      } while (usedTitles.has(title));

      usedTitles.add(title);

      // Generate metrics
      const views = generateViews();
      const { likes, dislikes, comments, shares } =
        generateEngagementFromViews(views);
      const duration = generateDuration();

      // Generate dates (videos created in last 365 days)
      const createdDate = new Date(
        Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000
      );
      const publishedDate = new Date(
        createdDate.getTime() + Math.random() * 7 * 24 * 60 * 60 * 1000
      );

      // Generate tags
      const availableTags = categoryTags[category] || categoryTags["tutorial"];
      const numTags = Math.floor(Math.random() * 5) + 2; // 2-6 tags
      const selectedTags = [];
      const shuffledTags = [...availableTags].sort(() => 0.5 - Math.random());

      for (let j = 0; j < Math.min(numTags, shuffledTags.length); j++) {
        selectedTags.push(shuffledTags[j]);
      }

      // Generate analytics data
      const retentionMultiplier = 0.25 + Math.random() * 0.55; // 25-80% retention
      const averageWatchTime = Math.round(duration * retentionMultiplier);
      const retentionRate =
        Math.round((averageWatchTime / duration) * 100 * 100) / 100;
      const clickThroughRate = Math.round((1 + Math.random() * 9) * 100) / 100; // 1-10% CTR

      dummyVideos.push({
        title,
        description: generateDescription(title, category),
        url: sampleUrls[Math.floor(Math.random() * sampleUrls.length)],
        thumbnail:
          sampleThumbnails[Math.floor(Math.random() * sampleThumbnails.length)],
        duration,
        category,
        tags: selectedTags,
        language: getRandomWeighted(languageOptions, languageWeights),
        quality: getRandomWeighted(qualityOptions, qualityWeights),
        views,
        likes,
        dislikes,
        comments,
        shares,
        isPublic: Math.random() < 0.92, // 92% public
        isActive: Math.random() < 0.97, // 97% active
        isFeatured: Math.random() < 0.08, // 8% featured
        isPremium: Math.random() < 0.18, // 18% premium
        monetizationEnabled: Math.random() < 0.65, // 65% monetized
        ageRestriction: (() => {
          const rand = Math.random();
          if (rand < 0.88) return "all";
          if (rand < 0.96) return "13+";
          if (rand < 0.99) return "16+";
          return "18+";
        })(),
        publishedAt: publishedDate,
        scheduledAt:
          Math.random() < 0.05
            ? new Date(Date.now() + Math.random() * 30 * 24 * 60 * 60 * 1000)
            : null,
        lastViewedAt:
          views > 0
            ? new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000)
            : null,
        averageWatchTime,
        retentionRate,
        clickThroughRate,
        fileSize: Math.floor(duration * (40 + Math.random() * 120) * 1024), // 40-160KB per second
        encoding: (() => {
          const rand = Math.random();
          if (rand < 0.75) return "H.264";
          if (rand < 0.9) return "H.265";
          return "VP9";
        })(),
        userId: randomUser.id,
        metadata: {
          uploadedFrom: (() => {
            const rand = Math.random();
            if (rand < 0.6) return "web";
            if (rand < 0.85) return "mobile";
            return "desktop";
          })(),
          processingTime: Math.floor(Math.random() * 180) + 20, // 20-200 seconds
          originalFileName: `${title
            .toLowerCase()
            .replace(/[^a-z0-9\s]/g, "")
            .replace(/\s+/g, "_")
            .substring(0, 50)}.mp4`,
          compressionRatio:
            Math.round((0.55 + Math.random() * 0.35) * 100) / 100, // 0.55-0.9
          bitrate: Math.floor(Math.random() * 3000) + 1000, // 1000-4000 kbps
        },
        createdAt: createdDate,
        updatedAt: new Date(
          publishedDate.getTime() + Math.random() * 5 * 24 * 60 * 60 * 1000
        ),
      });
    }

    // Insert videos in batches for better performance
    const batchSize = 25;
    const createdVideos = [];

    console.log("💾 Inserting videos to database...");

    for (let i = 0; i < dummyVideos.length; i += batchSize) {
      const batch = dummyVideos.slice(i, i + batchSize);

      try {
        const batchResult = await Videos.bulkCreate(batch, {
          validate: true,
          returning: true,
          hooks: false,
        });

        createdVideos.push(...batchResult);
      } catch (error) {
        console.error(`❌ Error in batch insertion:`, error.message);
        throw error;
      }
    }

    // Show final results
    console.log(`✅ Successfully created ${createdVideos.length} videos`);

    // Basic statistics
    const totalViews = createdVideos.reduce(
      (sum, video) => sum + video.views,
      0
    );
    const totalLikes = createdVideos.reduce(
      (sum, video) => sum + video.likes,
      0
    );

    console.log(`📺 Total views: ${totalViews.toLocaleString()}`);
    console.log(`👍 Total likes: ${totalLikes.toLocaleString()}`);
  } catch (error) {
    console.error("❌ ERROR:", error.message);

    // Specific error handling
    if (error.name === "SequelizeForeignKeyConstraintError") {
      console.error("💡 Solution: Run the user generator first");
    } else if (error.name === "SequelizeValidationError") {
      console.error("💡 Data validation failed");
    } else if (error.name === "SequelizeConnectionError") {
      console.error("💡 Check database connection");
    }

    throw error;
  } finally {
    try {
      await db.close();
    } catch (closeError) {
      console.error("Error closing database:", closeError.message);
    }
  }
};

// Handle graceful shutdown
process.on("SIGINT", async () => {
  console.log("\n⚠️  Process interrupted");
  try {
    await db.close();
  } catch (error) {
    console.error("❌ Error closing database:", error.message);
  }
  process.exit(1);
});

process.on("unhandledRejection", async (reason, promise) => {
  console.error("💀 Unhandled Promise Rejection:", reason);
  await db.close();
  process.exit(1);
});

// Run the generator
console.log("🚀 Starting Video Generator...");
generateDummyVideos().catch(async (error) => {
  console.error("💀 FATAL ERROR:", error.message);
  try {
    await db.close();
  } catch (closeError) {
    console.error("Error closing database:", closeError.message);
  }
  process.exit(1);
});

export default generateDummyVideos;
