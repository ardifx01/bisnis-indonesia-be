import Articles from "../models/ArticleModel.js";
import Users from "../models/UserModel.js";
import db from "../config/Database.js";

const generateDummyArticles = async () => {
  try {
    // Option 1: Gunakan sync tanpa alter untuk menghindari konflik enum
    // await Articles.sync({ force: false });

    // Option 2: Atau gunakan try-catch untuk handle enum yang sudah ada
    try {
      await Articles.sync({ alter: true });
    } catch (syncError) {
      if (syncError.message.includes("already exists")) {
        console.log("Tables already synced, continuing...");
        // Jika enum sudah ada, coba sync tanpa alter
        await Articles.sync();
      } else {
        throw syncError;
      }
    }

    // Clean existing articles
    const existingCount = await Articles.count();
    if (existingCount > 0) {
      await Articles.destroy({ where: {}, truncate: true });
    }

    // Get existing users
    const existingUsers = await Users.findAll({
      attributes: ["id"],
      limit: 20,
    });

    if (existingUsers.length === 0) {
      console.log("No users found in database!");
      return;
    }

    // HTML content templates
    const htmlContents = [
      `<h1>Panduan Lengkap JavaScript ES6+</h1>
<p>JavaScript telah berkembang pesat dalam beberapa tahun terakhir. Dalam artikel ini, kita akan membahas fitur-fitur terbaru yang membuat JavaScript semakin powerful.</p>

<h2>Arrow Functions</h2>
<p>Arrow function adalah salah satu fitur paling populer di ES6:</p>
<pre><code>const greet = (name) => {
  return \`Hello, \${name}!\`;
};</code></pre>

<blockquote>
<p>"Arrow functions membuat kode JavaScript lebih concise dan readable." - JavaScript Developer</p>
</blockquote>

<h3>Keuntungan Arrow Functions:</h3>
<ul>
<li>Syntax yang lebih singkat</li>
<li>Lexical <strong>this</strong> binding</li>
<li>Implicit return untuk single expression</li>
</ul>

<p>Untuk informasi lebih lanjut, kunjungi <a href="https://developer.mozilla.org">MDN Web Docs</a>.</p>`,

      `<h1>Tutorial React Hooks untuk Pemula</h1>
<p>React Hooks mengubah cara kita menulis komponen React. Mari pelajari hooks yang paling sering digunakan.</p>

<h2>useState Hook</h2>
<p>Hook pertama yang harus dipelajari adalah <code>useState</code>:</p>
<pre><code>import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    &lt;div&gt;
      &lt;p&gt;Count: {count}&lt;/p&gt;
      &lt;button onClick={() =&gt; setCount(count + 1)}&gt;
        Increment
      &lt;/button&gt;
    &lt;/div&gt;
  );
}</code></pre>

<div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0;">
<h4>💡 Tips:</h4>
<p>Selalu gunakan functional updates ketika state baru bergantung pada state sebelumnya.</p>
</div>

<h3>Best Practices:</h3>
<ol>
<li>Gunakan multiple state variables untuk data yang tidak related</li>
<li>Hindari complex objects dalam single state</li>
<li>Pertimbangkan useReducer untuk state management yang kompleks</li>
</ol>`,

      `<h1>Optimasi Performance Website dengan Lazy Loading</h1>
<p>Performance website adalah faktor kunci dalam user experience dan SEO. Salah satu teknik yang efektif adalah <em>lazy loading</em>.</p>

<h2>Apa itu Lazy Loading?</h2>
<p>Lazy loading adalah teknik yang menunda loading resource sampai benar-benar dibutuhkan oleh user.</p>

<h3>Implementasi untuk Images:</h3>
<pre><code>&lt;img 
  src="placeholder.jpg" 
  data-src="actual-image.jpg" 
  class="lazy-load"
  alt="Description"
&gt;

&lt;script&gt;
const images = document.querySelectorAll('.lazy-load');
const imageObserver = new IntersectionObserver((entries) =&gt; {
  entries.forEach(entry =&gt; {
    if (entry.isIntersecting) {
      const img = entry.target;
      img.src = img.dataset.src;
      imageObserver.unobserve(img);
    }
  });
});

images.forEach(img =&gt; imageObserver.observe(img));
&lt;/script&gt;</code></pre>

<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<thead>
<tr style="background-color: #f5f5f5;">
<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Teknik</th>
<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Performance Gain</th>
<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Kompleksitas</th>
</tr>
</thead>
<tbody>
<tr>
<td style="border: 1px solid #ddd; padding: 12px;">Image Lazy Loading</td>
<td style="border: 1px solid #ddd; padding: 12px;">20-50%</td>
<td style="border: 1px solid #ddd; padding: 12px;">Rendah</td>
</tr>
<tr style="background-color: #f9f9f9;">
<td style="border: 1px solid #ddd; padding: 12px;">Component Lazy Loading</td>
<td style="border: 1px solid #ddd; padding: 12px;">30-60%</td>
<td style="border: 1px solid #ddd; padding: 12px;">Sedang</td>
</tr>
</tbody>
</table>`,

      `<h1>Database Design Patterns untuk Aplikasi Modern</h1>
<p>Dalam pengembangan aplikasi modern, database design pattern yang tepat sangat mempengaruhi performa dan maintainability aplikasi.</p>

<h2>Repository Pattern</h2>
<p>Repository pattern memisahkan logika data access dari business logic:</p>

<pre><code>class UserRepository {
  async findById(id) {
    return await db.query('SELECT * FROM users WHERE id = $1', [id]);
  }
  
  async create(userData) {
    const { name, email } = userData;
    return await db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [name, email]
    );
  }
}</code></pre>

<div style="background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 6px; padding: 16px; margin: 16px 0;">
<h4>⚠️ Perhatian:</h4>
<p>Jangan over-engineer dengan terlalu banyak abstraction layers jika aplikasi masih sederhana.</p>
</div>

<h3>Keuntungan Repository Pattern:</h3>
<ul>
<li><strong>Separation of Concerns:</strong> Business logic terpisah dari data access</li>
<li><strong>Testability:</strong> Mudah untuk mock data layer dalam testing</li>
<li><strong>Flexibility:</strong> Mudah berganti database atau ORM</li>
<li><strong>Maintainability:</strong> Kode lebih terorganisir dan mudah dipelihara</li>
</ul>

<p>Pelajari lebih lanjut tentang <a href="#" style="color: #0066cc; text-decoration: none;">design patterns</a> dalam pengembangan software.</p>`,

      `<h1>Microservices Architecture: Pros and Cons</h1>
<p>Microservices telah menjadi arsitektur populer untuk aplikasi enterprise. Namun, apakah selalu merupakan pilihan yang tepat?</p>

<h2>Apa itu Microservices?</h2>
<p>Microservices adalah architectural pattern dimana aplikasi dibangun sebagai kumpulan service-service kecil yang independen.</p>

<h3>Keuntungan Microservices:</h3>
<ol>
<li><strong>Scalability:</strong> Setiap service bisa di-scale independen</li>
<li><strong>Technology Diversity:</strong> Bebas pilih tech stack per service</li>
<li><strong>Team Independence:</strong> Tim bisa develop dan deploy secara terpisah</li>
<li><strong>Fault Isolation:</strong> Error di satu service tidak mempengaruhi yang lain</li>
</ol>

<blockquote style="border-left: 4px solid #e74c3c; padding-left: 20px; margin: 20px 0; font-style: italic; color: #555;">
"Microservices are not a silver bullet. They come with their own set of complexities." - Martin Fowler
</blockquote>

<h3>Tantangan Microservices:</h3>
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">
<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">
<h4>🔧 Technical Challenges</h4>
<ul>
<li>Network latency</li>
<li>Data consistency</li>
<li>Service discovery</li>
<li>Distributed tracing</li>
</ul>
</div>
<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">
<h4>👥 Organizational Challenges</h4>
<ul>
<li>Team coordination</li>
<li>Deployment complexity</li>
<li>Monitoring & debugging</li>
<li>Documentation overhead</li>
</ul>
</div>
</div>

<h2>Kapan Menggunakan Microservices?</h2>
<p>Pertimbangkan microservices ketika:</p>
<ul>
<li>Tim development sudah mature</li>
<li>Aplikasi sudah kompleks dan sulit di-maintain</li>
<li>Butuh scalability yang berbeda per komponen</li>
<li>Organisasi sudah siap dengan DevOps practices</li>
</ul>`,
    ];

    // Article titles and related data
    const articlesData = [
      {
        title: "Panduan Lengkap JavaScript ES6+",
        excerpt:
          "Pelajari fitur-fitur terbaru JavaScript yang membuat development lebih efisien dan modern.",
        keywords: [
          "javascript",
          "es6",
          "arrow functions",
          "programming",
          "web development",
        ],
        metaTitle: "JavaScript ES6+ Guide - Modern Web Development",
        metaDescription:
          "Complete guide to modern JavaScript ES6+ features including arrow functions, destructuring, and async/await for better web development.",
        thumbnail:
          "https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=400&fit=crop",
        thumbnailAlt: "JavaScript code on computer screen",
      },
      {
        title: "Tutorial React Hooks untuk Pemula",
        excerpt:
          "Panduan lengkap menggunakan React Hooks untuk membuat komponen yang lebih clean dan efisien.",
        keywords: ["react", "hooks", "javascript", "frontend", "tutorial"],
        metaTitle: "React Hooks Tutorial - Complete Beginner Guide",
        metaDescription:
          "Learn React Hooks from scratch with practical examples. Master useState, useEffect, and custom hooks for modern React development.",
        thumbnail:
          "https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=400&fit=crop",
        thumbnailAlt: "React logo and code editor",
      },
      {
        title: "Optimasi Performance Website dengan Lazy Loading",
        excerpt:
          "Tingkatkan performa website hingga 50% dengan teknik lazy loading yang tepat dan implementasi modern.",
        keywords: [
          "performance",
          "lazy loading",
          "optimization",
          "web",
          "speed",
        ],
        metaTitle: "Website Performance Optimization with Lazy Loading",
        metaDescription:
          "Boost your website performance up to 50% with modern lazy loading techniques. Complete guide with code examples and best practices.",
        thumbnail:
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop",
        thumbnailAlt: "Website performance metrics dashboard",
      },
      {
        title: "Database Design Patterns untuk Aplikasi Modern",
        excerpt:
          "Pelajari design patterns terbaik untuk database yang scalable dan maintainable dalam aplikasi modern.",
        keywords: [
          "database",
          "design patterns",
          "sql",
          "backend",
          "architecture",
        ],
        metaTitle: "Modern Database Design Patterns Guide",
        metaDescription:
          "Master database design patterns for scalable applications. Learn Repository pattern, Active Record, and more with practical examples.",
        thumbnail:
          "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=400&fit=crop",
        thumbnailAlt: "Database schema diagram",
      },
      {
        title: "Microservices Architecture: Pros and Cons",
        excerpt:
          "Analisis mendalam tentang microservices architecture, kapan menggunakannya dan tantangan yang harus dihadapi.",
        keywords: [
          "microservices",
          "architecture",
          "scalability",
          "devops",
          "backend",
        ],
        metaTitle: "Microservices Architecture Complete Analysis",
        metaDescription:
          "Comprehensive analysis of microservices architecture. Learn the benefits, challenges, and when to adopt microservices for your projects.",
        thumbnail:
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=400&fit=crop",
        thumbnailAlt: "Microservices architecture diagram",
      },
    ];

    // Status options with weights (higher weight = more likely to be selected)
    const statusOptions = [
      { status: "published", weight: 70 },
      { status: "draft", weight: 15 },
      { status: "archived", weight: 10 },
      { status: "scheduled", weight: 5 },
    ];

    // Helper function to get random weighted status
    const getRandomStatus = () => {
      const totalWeight = statusOptions.reduce(
        (sum, option) => sum + option.weight,
        0
      );
      const random = Math.random() * totalWeight;
      let currentWeight = 0;

      for (const option of statusOptions) {
        currentWeight += option.weight;
        if (random <= currentWeight) {
          return option.status;
        }
      }
      return "draft";
    };

    // Helper function to generate random date within range
    const getRandomDate = (start, end) => {
      return new Date(
        start.getTime() + Math.random() * (end.getTime() - start.getTime())
      );
    };

    // Generate articles
    const numberOfArticles = Math.floor(Math.random() * 11) + 20; // 20-30 articles
    const currentDate = new Date();
    const oneYearAgo = new Date(
      currentDate.getTime() - 365 * 24 * 60 * 60 * 1000
    );
    const oneMonthFromNow = new Date(
      currentDate.getTime() + 30 * 24 * 60 * 60 * 1000
    );

    const dummyArticles = Array.from({ length: numberOfArticles }, (_, i) => {
      const randomUser =
        existingUsers[Math.floor(Math.random() * existingUsers.length)];
      const baseData = articlesData[i % articlesData.length];
      const status = getRandomStatus();

      // Generate unique title and slug
      const titleSuffix =
        Math.floor(i / articlesData.length) > 0
          ? ` Vol ${Math.floor(i / articlesData.length) + 1}`
          : "";
      const fullTitle = `${baseData.title}${titleSuffix}`;
      const slug =
        fullTitle
          .toLowerCase()
          .replace(/[^\w\s-]/g, "")
          .replace(/\s+/g, "-")
          .substring(0, 100) + `-${i + 1}`;

      // Generate random metrics
      const viewsCount = Math.floor(Math.random() * 10000);
      const likesCount = Math.floor(Math.random() * (viewsCount / 10));
      const commentsCount = Math.floor(Math.random() * (viewsCount / 50));

      // Generate dates based on status
      let publishedAt = null;
      let scheduledAt = null;

      if (status === "published") {
        publishedAt = getRandomDate(oneYearAgo, currentDate);
      } else if (status === "scheduled") {
        scheduledAt = getRandomDate(currentDate, oneMonthFromNow);
      } else if (status === "archived") {
        publishedAt = getRandomDate(
          oneYearAgo,
          new Date(currentDate.getTime() - 90 * 24 * 60 * 60 * 1000)
        );
      }

      return {
        title: fullTitle,
        slug: slug,
        excerpt: baseData.excerpt,
        content: htmlContents[i % htmlContents.length],
        thumbnail: baseData.thumbnail,
        thumbnailAlt: baseData.thumbnailAlt,
        metaTitle: baseData.metaTitle,
        metaDescription: baseData.metaDescription,
        keywords: baseData.keywords,
        status: status,
        publishedAt: publishedAt,
        scheduledAt: scheduledAt,
        viewsCount: status === "published" ? viewsCount : 0,
        likesCount: status === "published" ? likesCount : 0,
        commentsCount: status === "published" ? commentsCount : 0,
        featured: Math.random() < 0.15, // 15% chance to be featured
        allowComments: Math.random() < 0.9, // 90% allow comments
        userId: randomUser.id,
        // readingTime will be calculated automatically by the model hook
        // excerpt will be auto-generated if not provided by the model hook
      };
    });

    // Create articles with better error handling
    const createdArticles = [];
    for (const articleData of dummyArticles) {
      try {
        const article = await Articles.create(articleData);
        createdArticles.push(article);
      } catch (error) {
        console.log(`Failed to create article: ${articleData.title}`);
        console.log(`Error: ${error.message}`);

        // Try with minimal required fields only
        try {
          const minimalData = {
            title: articleData.title,
            slug: articleData.slug,
            content: articleData.content,
            userId: articleData.userId,
          };

          const article = await Articles.create(minimalData);
          createdArticles.push(article);
          console.log(`✓ Created with minimal data: ${articleData.title}`);
        } catch (secondError) {
          console.log(
            `✗ Completely failed: ${articleData.title} - ${secondError.message}`
          );
        }
      }
    }

    console.log(
      `\n🎉 Successfully created ${createdArticles.length} articles out of ${numberOfArticles} attempted`
    );

    // Show summary by status
    const statusCounts = await Articles.findAll({
      attributes: ["status", [db.fn("COUNT", db.col("id")), "count"]],
      group: ["status"],
      raw: true,
    });

    console.log("\n📊 Articles by status:");
    statusCounts.forEach((item) => {
      console.log(`  ${item.status}: ${item.count} articles`);
    });
  } catch (error) {
    console.error("❌ Error creating articles:", error.message);
  }
};

generateDummyArticles();

export default generateDummyArticles;
