--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2025-08-24 14:27:42

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 863 (class 1247 OID 38527)
-- Name: enum_articles_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_articles_status AS ENUM (
    'draft',
    'published',
    'archived',
    'scheduled'
);


ALTER TYPE public.enum_articles_status OWNER TO postgres;

--
-- TOC entry 857 (class 1247 OID 38336)
-- Name: enum_users_provider; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_provider AS ENUM (
    'local',
    'google',
    'facebook'
);


ALTER TYPE public.enum_users_provider OWNER TO postgres;

--
-- TOC entry 875 (class 1247 OID 38836)
-- Name: enum_videos_ageRestriction; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."enum_videos_ageRestriction" AS ENUM (
    'all',
    '13+',
    '16+',
    '18+'
);


ALTER TYPE public."enum_videos_ageRestriction" OWNER TO postgres;

--
-- TOC entry 869 (class 1247 OID 38763)
-- Name: enum_videos_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_videos_category AS ENUM (
    'web-development',
    'programming',
    'data-science',
    'mobile-development',
    'devops',
    'design',
    'ai-ml',
    'cybersecurity',
    'blockchain',
    'tutorial',
    'lifestyle',
    'beauty',
    'health',
    'fitness',
    'cooking',
    'travel',
    'photography',
    'music',
    'education',
    'business',
    'entertainment',
    'gaming',
    'sports',
    'news',
    'science',
    'technology',
    'other'
);


ALTER TYPE public.enum_videos_category OWNER TO postgres;

--
-- TOC entry 872 (class 1247 OID 38818)
-- Name: enum_videos_quality; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_videos_quality AS ENUM (
    '144p',
    '240p',
    '360p',
    '480p',
    '720p',
    '1080p',
    '1440p',
    '2160p'
);


ALTER TYPE public.enum_videos_quality OWNER TO postgres;

--
-- TOC entry 222 (class 1255 OID 37312)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 38668)
-- Name: articles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.articles (
    id uuid NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    excerpt text,
    content text NOT NULL,
    thumbnail text,
    thumbnail_alt character varying(255),
    meta_title character varying(60),
    meta_description character varying(160),
    keywords text,
    status public.enum_articles_status DEFAULT 'draft'::public.enum_articles_status NOT NULL,
    "publishedAt" timestamp with time zone,
    "scheduledAt" timestamp with time zone,
    "viewsCount" integer DEFAULT 0 NOT NULL,
    "likesCount" integer DEFAULT 0 NOT NULL,
    "commentsCount" integer DEFAULT 0 NOT NULL,
    "readingTime" integer,
    featured boolean DEFAULT false NOT NULL,
    "allowComments" boolean DEFAULT true NOT NULL,
    "userId" uuid NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.articles OWNER TO postgres;

--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN articles."readingTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles."readingTime" IS 'Estimated reading time in minutes';


--
-- TOC entry 218 (class 1259 OID 38312)
-- Name: memberships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.memberships (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    price numeric(10,2) DEFAULT 0 NOT NULL,
    duration_days integer DEFAULT 30 NOT NULL,
    features jsonb DEFAULT '[]'::jsonb,
    limits jsonb DEFAULT '{"max_projects": null, "max_api_calls": null, "max_storage_gb": null}'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.memberships OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 38297)
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid NOT NULL,
    name character varying(50) NOT NULL,
    slug character varying(50) NOT NULL,
    description text,
    permissions jsonb DEFAULT '[]'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 38343)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255),
    picture character varying(255),
    "pictureUrl" text,
    bio text,
    role_id uuid NOT NULL,
    membership_id uuid NOT NULL,
    membership_expires_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    email_verified_at timestamp with time zone,
    provider public.enum_users_provider DEFAULT 'local'::public.enum_users_provider NOT NULL,
    provider_id character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN users.provider; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.provider IS 'Authentication provider (local, google, facebook)';


--
-- TOC entry 4941 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN users.provider_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.provider_id IS 'External provider ID (Google ID, Facebook ID, etc.)';


--
-- TOC entry 221 (class 1259 OID 38884)
-- Name: videos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.videos (
    id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    url text NOT NULL,
    thumbnail text,
    duration integer,
    category public.enum_videos_category DEFAULT 'other'::public.enum_videos_category NOT NULL,
    tags json DEFAULT '[]'::json,
    language character varying(10) DEFAULT 'id'::character varying NOT NULL,
    quality public.enum_videos_quality DEFAULT '720p'::public.enum_videos_quality NOT NULL,
    views integer DEFAULT 0 NOT NULL,
    likes integer DEFAULT 0 NOT NULL,
    dislikes integer DEFAULT 0 NOT NULL,
    comments integer DEFAULT 0 NOT NULL,
    shares integer DEFAULT 0 NOT NULL,
    "isPublic" boolean DEFAULT true NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "isFeatured" boolean DEFAULT false NOT NULL,
    "isPremium" boolean DEFAULT false NOT NULL,
    "monetizationEnabled" boolean DEFAULT false NOT NULL,
    "ageRestriction" public."enum_videos_ageRestriction" DEFAULT 'all'::public."enum_videos_ageRestriction" NOT NULL,
    "publishedAt" timestamp with time zone,
    "scheduledAt" timestamp with time zone,
    "lastViewedAt" timestamp with time zone,
    "averageWatchTime" double precision,
    "retentionRate" double precision,
    "clickThroughRate" double precision,
    "engagementScore" double precision,
    "fileSize" bigint,
    encoding character varying(50) DEFAULT 'H.264'::character varying,
    "userId" uuid NOT NULL,
    metadata json DEFAULT '{}'::json,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "deletedAt" timestamp with time zone
);


ALTER TABLE public.videos OWNER TO postgres;

--
-- TOC entry 4942 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos.duration; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos.duration IS 'Duration in seconds';


--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos."averageWatchTime"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos."averageWatchTime" IS 'Average watch time in seconds';


--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos."retentionRate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos."retentionRate" IS 'Retention rate percentage (0-100)';


--
-- TOC entry 4945 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos."clickThroughRate"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos."clickThroughRate" IS 'CTR percentage (0-100)';


--
-- TOC entry 4946 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos."engagementScore"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos."engagementScore" IS 'Overall engagement score (0-10)';


--
-- TOC entry 4947 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos."fileSize"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos."fileSize" IS 'File size in bytes';


--
-- TOC entry 4948 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN videos.metadata; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.videos.metadata IS 'Additional metadata for video processing info, etc.';


--
-- TOC entry 4932 (class 0 OID 38668)
-- Dependencies: 220
-- Data for Name: articles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.articles (id, slug, title, excerpt, content, thumbnail, thumbnail_alt, meta_title, meta_description, keywords, status, "publishedAt", "scheduledAt", "viewsCount", "likesCount", "commentsCount", "readingTime", featured, "allowComments", "userId", "createdAt", "updatedAt") FROM stdin;
cebb33f6-c4c4-455b-af7c-38498172c846	database-design-patterns-untuk-aplikasi-modern-vol-5	Database Design Patterns untuk Aplikasi Modern Vol 5	Pelajari design patterns terbaik untuk database yang scalable dan maintainable dalam aplikasi modern.	<h1>Database Design Patterns untuk Aplikasi Modern</h1>\n<p>Dalam pengembangan aplikasi modern, database design pattern yang tepat sangat mempengaruhi performa dan maintainability aplikasi.</p>\n<h2>Repository Pattern</h2>\n<p>Repository pattern memisahkan logika data access dari business logic:</p>\n<pre><code>class UserRepository {\n  async findById(id) {\n    return await db.query('SELECT * FROM users WHERE id = $1', [id]);\n  }\n  \n  async create(userData) {\n    const { name, email } = userData;\n    return await db.query(\n      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',\n      [name, email]\n    );\n  }\n}</code></pre>\n<div style="background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 6px; padding: 16px; margin: 16px 0;">\n<h4>⚠️ Perhatian:</h4>\n<p>Jangan over-engineer dengan terlalu banyak abstraction layers jika aplikasi masih sederhana.</p>\n</div>\n<h3>Keuntungan Repository Pattern:</h3>\n<ul>\n<li><strong>Separation of Concerns:</strong> Business logic terpisah dari data access</li>\n<li><strong>Testability:</strong> Mudah untuk mock data layer dalam testing</li>\n<li><strong>Flexibility:</strong> Mudah berganti database atau ORM</li>\n<li><strong>Maintainability:</strong> Kode lebih terorganisir dan mudah dipelihara</li>\n</ul>\n<p>Pelajari lebih lanjut tentang <a style="color: #0066cc; text-decoration: none;" href="#">design patterns</a> dalam pengembangan software.</p>	https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=400&fit=crop	Database schema diagram	Modern Database Design Patterns Guide	Master database design patterns for scalable applications. Learn Repository pattern, Active Record, and more with practical examples.	database,design patterns,sql,backend,architecture	published	2025-01-31 10:54:17.759+07	\N	7036	450	46	1	f	t	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	2025-08-23 13:42:43.089+07	2025-08-24 13:29:13.771+07
6fa144ac-632a-4c88-a7a2-ea474a8e464e	panduan-lengkap-javascript-es6-1	Panduan Lengkap JavaScript ES6+	Pelajari fitur-fitur terbaru JavaScript yang membuat development lebih efisien dan modern.	<h1>Panduan Lengkap JavaScript ES6+</h1>\n<p>JavaScript telah berkembang pesat dalam beberapa tahun terakhir. Dalam artikel ini, kita akan membahas fitur-fitur terbaru yang membuat JavaScript semakin powerful.</p>\n\n<h2>Arrow Functions</h2>\n<p>Arrow function adalah salah satu fitur paling populer di ES6:</p>\n<pre><code>const greet = (name) => {\n  return `Hello, ${name}!`;\n};</code></pre>\n\n<blockquote>\n<p>"Arrow functions membuat kode JavaScript lebih concise dan readable." - JavaScript Developer</p>\n</blockquote>\n\n<h3>Keuntungan Arrow Functions:</h3>\n<ul>\n<li>Syntax yang lebih singkat</li>\n<li>Lexical <strong>this</strong> binding</li>\n<li>Implicit return untuk single expression</li>\n</ul>\n\n<p>Untuk informasi lebih lanjut, kunjungi <a href="https://developer.mozilla.org">MDN Web Docs</a>.</p>	https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=400&fit=crop	JavaScript code on computer screen	JavaScript ES6+ Guide - Modern Web Development	Complete guide to modern JavaScript ES6+ features including arrow functions, destructuring, and async/await for better web development.	javascript,es6,arrow functions,programming,web development	published	2025-04-28 06:37:18.284+07	\N	555	3	10	1	f	t	3092405f-8950-49c9-b1ed-d85a34e9ea23	2025-08-23 13:42:42.96+07	2025-08-23 13:42:42.96+07
1d2a3954-3dd9-48a6-a922-7bfc415e7f9b	tutorial-react-hooks-untuk-pemula-2	Tutorial React Hooks untuk Pemula	Panduan lengkap menggunakan React Hooks untuk membuat komponen yang lebih clean dan efisien.	<h1>Tutorial React Hooks untuk Pemula</h1>\n<p>React Hooks mengubah cara kita menulis komponen React. Mari pelajari hooks yang paling sering digunakan.</p>\n\n<h2>useState Hook</h2>\n<p>Hook pertama yang harus dipelajari adalah <code>useState</code>:</p>\n<pre><code>import React, { useState } from 'react';\n\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  \n  return (\n    &lt;div&gt;\n      &lt;p&gt;Count: {count}&lt;/p&gt;\n      &lt;button onClick={() =&gt; setCount(count + 1)}&gt;\n        Increment\n      &lt;/button&gt;\n    &lt;/div&gt;\n  );\n}</code></pre>\n\n<div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0;">\n<h4>💡 Tips:</h4>\n<p>Selalu gunakan functional updates ketika state baru bergantung pada state sebelumnya.</p>\n</div>\n\n<h3>Best Practices:</h3>\n<ol>\n<li>Gunakan multiple state variables untuk data yang tidak related</li>\n<li>Hindari complex objects dalam single state</li>\n<li>Pertimbangkan useReducer untuk state management yang kompleks</li>\n</ol>	https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=400&fit=crop	React logo and code editor	React Hooks Tutorial - Complete Beginner Guide	Learn React Hooks from scratch with practical examples. Master useState, useEffect, and custom hooks for modern React development.	react,hooks,javascript,frontend,tutorial	draft	\N	\N	0	0	0	1	f	t	6262077e-05e4-4b8d-86c1-84b29fcfe254	2025-08-23 13:42:42.992+07	2025-08-23 13:42:42.992+07
6209466a-176f-45b4-83b7-39abb8c52d1f	optimasi-performance-website-dengan-lazy-loading-3	Optimasi Performance Website dengan Lazy Loading	Tingkatkan performa website hingga 50% dengan teknik lazy loading yang tepat dan implementasi modern.	<h1>Optimasi Performance Website dengan Lazy Loading</h1>\n<p>Performance website adalah faktor kunci dalam user experience dan SEO. Salah satu teknik yang efektif adalah <em>lazy loading</em>.</p>\n\n<h2>Apa itu Lazy Loading?</h2>\n<p>Lazy loading adalah teknik yang menunda loading resource sampai benar-benar dibutuhkan oleh user.</p>\n\n<h3>Implementasi untuk Images:</h3>\n<pre><code>&lt;img \n  src="placeholder.jpg" \n  data-src="actual-image.jpg" \n  class="lazy-load"\n  alt="Description"\n&gt;\n\n&lt;script&gt;\nconst images = document.querySelectorAll('.lazy-load');\nconst imageObserver = new IntersectionObserver((entries) =&gt; {\n  entries.forEach(entry =&gt; {\n    if (entry.isIntersecting) {\n      const img = entry.target;\n      img.src = img.dataset.src;\n      imageObserver.unobserve(img);\n    }\n  });\n});\n\nimages.forEach(img =&gt; imageObserver.observe(img));\n&lt;/script&gt;</code></pre>\n\n<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">\n<thead>\n<tr style="background-color: #f5f5f5;">\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Teknik</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Performance Gain</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Kompleksitas</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style="border: 1px solid #ddd; padding: 12px;">Image Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">20-50%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Rendah</td>\n</tr>\n<tr style="background-color: #f9f9f9;">\n<td style="border: 1px solid #ddd; padding: 12px;">Component Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">30-60%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Sedang</td>\n</tr>\n</tbody>\n</table>	https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop	Website performance metrics dashboard	Website Performance Optimization with Lazy Loading	Boost your website performance up to 50% with modern lazy loading techniques. Complete guide with code examples and best practices.	performance,lazy loading,optimization,web,speed	published	2025-04-15 22:12:35.976+07	\N	7357	650	22	1	f	t	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	2025-08-23 13:42:42.998+07	2025-08-23 13:42:42.998+07
c6e8054f-d538-4c43-a0ef-23a095674533	database-design-patterns-untuk-aplikasi-modern-4	Database Design Patterns untuk Aplikasi Modern	Pelajari design patterns terbaik untuk database yang scalable dan maintainable dalam aplikasi modern.	<h1>Database Design Patterns untuk Aplikasi Modern</h1>\n<p>Dalam pengembangan aplikasi modern, database design pattern yang tepat sangat mempengaruhi performa dan maintainability aplikasi.</p>\n\n<h2>Repository Pattern</h2>\n<p>Repository pattern memisahkan logika data access dari business logic:</p>\n\n<pre><code>class UserRepository {\n  async findById(id) {\n    return await db.query('SELECT * FROM users WHERE id = $1', [id]);\n  }\n  \n  async create(userData) {\n    const { name, email } = userData;\n    return await db.query(\n      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',\n      [name, email]\n    );\n  }\n}</code></pre>\n\n<div style="background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 6px; padding: 16px; margin: 16px 0;">\n<h4>⚠️ Perhatian:</h4>\n<p>Jangan over-engineer dengan terlalu banyak abstraction layers jika aplikasi masih sederhana.</p>\n</div>\n\n<h3>Keuntungan Repository Pattern:</h3>\n<ul>\n<li><strong>Separation of Concerns:</strong> Business logic terpisah dari data access</li>\n<li><strong>Testability:</strong> Mudah untuk mock data layer dalam testing</li>\n<li><strong>Flexibility:</strong> Mudah berganti database atau ORM</li>\n<li><strong>Maintainability:</strong> Kode lebih terorganisir dan mudah dipelihara</li>\n</ul>\n\n<p>Pelajari lebih lanjut tentang <a href="#" style="color: #0066cc; text-decoration: none;">design patterns</a> dalam pengembangan software.</p>	https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=400&fit=crop	Database schema diagram	Modern Database Design Patterns Guide	Master database design patterns for scalable applications. Learn Repository pattern, Active Record, and more with practical examples.	database,design patterns,sql,backend,architecture	draft	\N	\N	0	0	0	1	f	t	03a0977b-3ae5-491f-bd77-3cec98f336a7	2025-08-23 13:42:43.004+07	2025-08-23 13:42:43.004+07
916ed353-11c6-4a6e-ade4-0a8925e0c202	microservices-architecture-pros-and-cons-5	Microservices Architecture: Pros and Cons	Analisis mendalam tentang microservices architecture, kapan menggunakannya dan tantangan yang harus dihadapi.	<h1>Microservices Architecture: Pros and Cons</h1>\n<p>Microservices telah menjadi arsitektur populer untuk aplikasi enterprise. Namun, apakah selalu merupakan pilihan yang tepat?</p>\n\n<h2>Apa itu Microservices?</h2>\n<p>Microservices adalah architectural pattern dimana aplikasi dibangun sebagai kumpulan service-service kecil yang independen.</p>\n\n<h3>Keuntungan Microservices:</h3>\n<ol>\n<li><strong>Scalability:</strong> Setiap service bisa di-scale independen</li>\n<li><strong>Technology Diversity:</strong> Bebas pilih tech stack per service</li>\n<li><strong>Team Independence:</strong> Tim bisa develop dan deploy secara terpisah</li>\n<li><strong>Fault Isolation:</strong> Error di satu service tidak mempengaruhi yang lain</li>\n</ol>\n\n<blockquote style="border-left: 4px solid #e74c3c; padding-left: 20px; margin: 20px 0; font-style: italic; color: #555;">\n"Microservices are not a silver bullet. They come with their own set of complexities." - Martin Fowler\n</blockquote>\n\n<h3>Tantangan Microservices:</h3>\n<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>🔧 Technical Challenges</h4>\n<ul>\n<li>Network latency</li>\n<li>Data consistency</li>\n<li>Service discovery</li>\n<li>Distributed tracing</li>\n</ul>\n</div>\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>👥 Organizational Challenges</h4>\n<ul>\n<li>Team coordination</li>\n<li>Deployment complexity</li>\n<li>Monitoring & debugging</li>\n<li>Documentation overhead</li>\n</ul>\n</div>\n</div>\n\n<h2>Kapan Menggunakan Microservices?</h2>\n<p>Pertimbangkan microservices ketika:</p>\n<ul>\n<li>Tim development sudah mature</li>\n<li>Aplikasi sudah kompleks dan sulit di-maintain</li>\n<li>Butuh scalability yang berbeda per komponen</li>\n<li>Organisasi sudah siap dengan DevOps practices</li>\n</ul>	https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=400&fit=crop	Microservices architecture diagram	Microservices Architecture Complete Analysis	Comprehensive analysis of microservices architecture. Learn the benefits, challenges, and when to adopt microservices for your projects.	microservices,architecture,scalability,devops,backend	archived	2025-04-02 18:48:17.38+07	\N	0	0	0	1	f	t	6262077e-05e4-4b8d-86c1-84b29fcfe254	2025-08-23 13:42:43.01+07	2025-08-23 13:42:43.01+07
7c4e8975-63d3-4f6e-910c-235df43a3f93	panduan-lengkap-javascript-es6-vol-2-6	Panduan Lengkap JavaScript ES6+ Vol 2	Pelajari fitur-fitur terbaru JavaScript yang membuat development lebih efisien dan modern.	<h1>Panduan Lengkap JavaScript ES6+</h1>\n<p>JavaScript telah berkembang pesat dalam beberapa tahun terakhir. Dalam artikel ini, kita akan membahas fitur-fitur terbaru yang membuat JavaScript semakin powerful.</p>\n\n<h2>Arrow Functions</h2>\n<p>Arrow function adalah salah satu fitur paling populer di ES6:</p>\n<pre><code>const greet = (name) => {\n  return `Hello, ${name}!`;\n};</code></pre>\n\n<blockquote>\n<p>"Arrow functions membuat kode JavaScript lebih concise dan readable." - JavaScript Developer</p>\n</blockquote>\n\n<h3>Keuntungan Arrow Functions:</h3>\n<ul>\n<li>Syntax yang lebih singkat</li>\n<li>Lexical <strong>this</strong> binding</li>\n<li>Implicit return untuk single expression</li>\n</ul>\n\n<p>Untuk informasi lebih lanjut, kunjungi <a href="https://developer.mozilla.org">MDN Web Docs</a>.</p>	https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=400&fit=crop	JavaScript code on computer screen	JavaScript ES6+ Guide - Modern Web Development	Complete guide to modern JavaScript ES6+ features including arrow functions, destructuring, and async/await for better web development.	javascript,es6,arrow functions,programming,web development	draft	\N	\N	0	0	0	1	f	t	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	2025-08-23 13:42:43.014+07	2025-08-23 13:42:43.014+07
be2272dd-7363-416f-965b-015094850fca	tutorial-react-hooks-untuk-pemula-vol-2-7	Tutorial React Hooks untuk Pemula Vol 2	Panduan lengkap menggunakan React Hooks untuk membuat komponen yang lebih clean dan efisien.	<h1>Tutorial React Hooks untuk Pemula</h1>\n<p>React Hooks mengubah cara kita menulis komponen React. Mari pelajari hooks yang paling sering digunakan.</p>\n\n<h2>useState Hook</h2>\n<p>Hook pertama yang harus dipelajari adalah <code>useState</code>:</p>\n<pre><code>import React, { useState } from 'react';\n\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  \n  return (\n    &lt;div&gt;\n      &lt;p&gt;Count: {count}&lt;/p&gt;\n      &lt;button onClick={() =&gt; setCount(count + 1)}&gt;\n        Increment\n      &lt;/button&gt;\n    &lt;/div&gt;\n  );\n}</code></pre>\n\n<div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0;">\n<h4>💡 Tips:</h4>\n<p>Selalu gunakan functional updates ketika state baru bergantung pada state sebelumnya.</p>\n</div>\n\n<h3>Best Practices:</h3>\n<ol>\n<li>Gunakan multiple state variables untuk data yang tidak related</li>\n<li>Hindari complex objects dalam single state</li>\n<li>Pertimbangkan useReducer untuk state management yang kompleks</li>\n</ol>	https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=400&fit=crop	React logo and code editor	React Hooks Tutorial - Complete Beginner Guide	Learn React Hooks from scratch with practical examples. Master useState, useEffect, and custom hooks for modern React development.	react,hooks,javascript,frontend,tutorial	published	2025-07-28 22:49:36.58+07	\N	1981	80	12	1	f	t	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	2025-08-23 13:42:43.019+07	2025-08-23 13:42:43.019+07
227ddf42-a0ca-4006-a766-6b63d4699b86	optimasi-performance-website-dengan-lazy-loading-vol-2-8	Optimasi Performance Website dengan Lazy Loading Vol 2	Tingkatkan performa website hingga 50% dengan teknik lazy loading yang tepat dan implementasi modern.	<h1>Optimasi Performance Website dengan Lazy Loading</h1>\n<p>Performance website adalah faktor kunci dalam user experience dan SEO. Salah satu teknik yang efektif adalah <em>lazy loading</em>.</p>\n\n<h2>Apa itu Lazy Loading?</h2>\n<p>Lazy loading adalah teknik yang menunda loading resource sampai benar-benar dibutuhkan oleh user.</p>\n\n<h3>Implementasi untuk Images:</h3>\n<pre><code>&lt;img \n  src="placeholder.jpg" \n  data-src="actual-image.jpg" \n  class="lazy-load"\n  alt="Description"\n&gt;\n\n&lt;script&gt;\nconst images = document.querySelectorAll('.lazy-load');\nconst imageObserver = new IntersectionObserver((entries) =&gt; {\n  entries.forEach(entry =&gt; {\n    if (entry.isIntersecting) {\n      const img = entry.target;\n      img.src = img.dataset.src;\n      imageObserver.unobserve(img);\n    }\n  });\n});\n\nimages.forEach(img =&gt; imageObserver.observe(img));\n&lt;/script&gt;</code></pre>\n\n<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">\n<thead>\n<tr style="background-color: #f5f5f5;">\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Teknik</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Performance Gain</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Kompleksitas</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style="border: 1px solid #ddd; padding: 12px;">Image Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">20-50%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Rendah</td>\n</tr>\n<tr style="background-color: #f9f9f9;">\n<td style="border: 1px solid #ddd; padding: 12px;">Component Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">30-60%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Sedang</td>\n</tr>\n</tbody>\n</table>	https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop	Website performance metrics dashboard	Website Performance Optimization with Lazy Loading	Boost your website performance up to 50% with modern lazy loading techniques. Complete guide with code examples and best practices.	performance,lazy loading,optimization,web,speed	published	2025-03-18 05:39:21.063+07	\N	5247	504	5	1	f	t	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	2025-08-23 13:42:43.023+07	2025-08-23 13:42:43.023+07
e6e04569-e65b-4aec-a34f-b1a842eba6d0	microservices-architecture-pros-and-cons-vol-2-10	Microservices Architecture: Pros and Cons Vol 2	Analisis mendalam tentang microservices architecture, kapan menggunakannya dan tantangan yang harus dihadapi.	<h1>Microservices Architecture: Pros and Cons</h1>\n<p>Microservices telah menjadi arsitektur populer untuk aplikasi enterprise. Namun, apakah selalu merupakan pilihan yang tepat?</p>\n\n<h2>Apa itu Microservices?</h2>\n<p>Microservices adalah architectural pattern dimana aplikasi dibangun sebagai kumpulan service-service kecil yang independen.</p>\n\n<h3>Keuntungan Microservices:</h3>\n<ol>\n<li><strong>Scalability:</strong> Setiap service bisa di-scale independen</li>\n<li><strong>Technology Diversity:</strong> Bebas pilih tech stack per service</li>\n<li><strong>Team Independence:</strong> Tim bisa develop dan deploy secara terpisah</li>\n<li><strong>Fault Isolation:</strong> Error di satu service tidak mempengaruhi yang lain</li>\n</ol>\n\n<blockquote style="border-left: 4px solid #e74c3c; padding-left: 20px; margin: 20px 0; font-style: italic; color: #555;">\n"Microservices are not a silver bullet. They come with their own set of complexities." - Martin Fowler\n</blockquote>\n\n<h3>Tantangan Microservices:</h3>\n<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>🔧 Technical Challenges</h4>\n<ul>\n<li>Network latency</li>\n<li>Data consistency</li>\n<li>Service discovery</li>\n<li>Distributed tracing</li>\n</ul>\n</div>\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>👥 Organizational Challenges</h4>\n<ul>\n<li>Team coordination</li>\n<li>Deployment complexity</li>\n<li>Monitoring & debugging</li>\n<li>Documentation overhead</li>\n</ul>\n</div>\n</div>\n\n<h2>Kapan Menggunakan Microservices?</h2>\n<p>Pertimbangkan microservices ketika:</p>\n<ul>\n<li>Tim development sudah mature</li>\n<li>Aplikasi sudah kompleks dan sulit di-maintain</li>\n<li>Butuh scalability yang berbeda per komponen</li>\n<li>Organisasi sudah siap dengan DevOps practices</li>\n</ul>	https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=400&fit=crop	Microservices architecture diagram	Microservices Architecture Complete Analysis	Comprehensive analysis of microservices architecture. Learn the benefits, challenges, and when to adopt microservices for your projects.	microservices,architecture,scalability,devops,backend	published	2024-09-06 11:25:20.114+07	\N	2424	184	45	1	t	t	6262077e-05e4-4b8d-86c1-84b29fcfe254	2025-08-23 13:42:43.032+07	2025-08-23 13:42:43.032+07
b36b4614-c020-485e-89b5-f5de4a80ab65	panduan-lengkap-javascript-es6-vol-3-11	Panduan Lengkap JavaScript ES6+ Vol 3	Pelajari fitur-fitur terbaru JavaScript yang membuat development lebih efisien dan modern.	<h1>Panduan Lengkap JavaScript ES6+</h1>\n<p>JavaScript telah berkembang pesat dalam beberapa tahun terakhir. Dalam artikel ini, kita akan membahas fitur-fitur terbaru yang membuat JavaScript semakin powerful.</p>\n\n<h2>Arrow Functions</h2>\n<p>Arrow function adalah salah satu fitur paling populer di ES6:</p>\n<pre><code>const greet = (name) => {\n  return `Hello, ${name}!`;\n};</code></pre>\n\n<blockquote>\n<p>"Arrow functions membuat kode JavaScript lebih concise dan readable." - JavaScript Developer</p>\n</blockquote>\n\n<h3>Keuntungan Arrow Functions:</h3>\n<ul>\n<li>Syntax yang lebih singkat</li>\n<li>Lexical <strong>this</strong> binding</li>\n<li>Implicit return untuk single expression</li>\n</ul>\n\n<p>Untuk informasi lebih lanjut, kunjungi <a href="https://developer.mozilla.org">MDN Web Docs</a>.</p>	https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=400&fit=crop	JavaScript code on computer screen	JavaScript ES6+ Guide - Modern Web Development	Complete guide to modern JavaScript ES6+ features including arrow functions, destructuring, and async/await for better web development.	javascript,es6,arrow functions,programming,web development	published	2025-03-03 02:23:29.072+07	\N	6345	189	97	1	f	t	6262077e-05e4-4b8d-86c1-84b29fcfe254	2025-08-23 13:42:43.036+07	2025-08-23 13:42:43.036+07
3fd11d82-cabf-49f5-bc30-0abea0675eee	tutorial-react-hooks-untuk-pemula-vol-3-12	Tutorial React Hooks untuk Pemula Vol 3	Panduan lengkap menggunakan React Hooks untuk membuat komponen yang lebih clean dan efisien.	<h1>Tutorial React Hooks untuk Pemula</h1>\n<p>React Hooks mengubah cara kita menulis komponen React. Mari pelajari hooks yang paling sering digunakan.</p>\n\n<h2>useState Hook</h2>\n<p>Hook pertama yang harus dipelajari adalah <code>useState</code>:</p>\n<pre><code>import React, { useState } from 'react';\n\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  \n  return (\n    &lt;div&gt;\n      &lt;p&gt;Count: {count}&lt;/p&gt;\n      &lt;button onClick={() =&gt; setCount(count + 1)}&gt;\n        Increment\n      &lt;/button&gt;\n    &lt;/div&gt;\n  );\n}</code></pre>\n\n<div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0;">\n<h4>💡 Tips:</h4>\n<p>Selalu gunakan functional updates ketika state baru bergantung pada state sebelumnya.</p>\n</div>\n\n<h3>Best Practices:</h3>\n<ol>\n<li>Gunakan multiple state variables untuk data yang tidak related</li>\n<li>Hindari complex objects dalam single state</li>\n<li>Pertimbangkan useReducer untuk state management yang kompleks</li>\n</ol>	https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=400&fit=crop	React logo and code editor	React Hooks Tutorial - Complete Beginner Guide	Learn React Hooks from scratch with practical examples. Master useState, useEffect, and custom hooks for modern React development.	react,hooks,javascript,frontend,tutorial	draft	\N	\N	0	0	0	1	f	t	2b7729a3-0631-413d-a7e3-75679bfda256	2025-08-23 13:42:43.039+07	2025-08-23 13:42:43.039+07
d751e2bc-8ca7-4e33-95d2-8353ae612fd1	optimasi-performance-website-dengan-lazy-loading-vol-3-13	Optimasi Performance Website dengan Lazy Loading Vol 3	Tingkatkan performa website hingga 50% dengan teknik lazy loading yang tepat dan implementasi modern.	<h1>Optimasi Performance Website dengan Lazy Loading</h1>\n<p>Performance website adalah faktor kunci dalam user experience dan SEO. Salah satu teknik yang efektif adalah <em>lazy loading</em>.</p>\n\n<h2>Apa itu Lazy Loading?</h2>\n<p>Lazy loading adalah teknik yang menunda loading resource sampai benar-benar dibutuhkan oleh user.</p>\n\n<h3>Implementasi untuk Images:</h3>\n<pre><code>&lt;img \n  src="placeholder.jpg" \n  data-src="actual-image.jpg" \n  class="lazy-load"\n  alt="Description"\n&gt;\n\n&lt;script&gt;\nconst images = document.querySelectorAll('.lazy-load');\nconst imageObserver = new IntersectionObserver((entries) =&gt; {\n  entries.forEach(entry =&gt; {\n    if (entry.isIntersecting) {\n      const img = entry.target;\n      img.src = img.dataset.src;\n      imageObserver.unobserve(img);\n    }\n  });\n});\n\nimages.forEach(img =&gt; imageObserver.observe(img));\n&lt;/script&gt;</code></pre>\n\n<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">\n<thead>\n<tr style="background-color: #f5f5f5;">\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Teknik</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Performance Gain</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Kompleksitas</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style="border: 1px solid #ddd; padding: 12px;">Image Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">20-50%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Rendah</td>\n</tr>\n<tr style="background-color: #f9f9f9;">\n<td style="border: 1px solid #ddd; padding: 12px;">Component Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">30-60%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Sedang</td>\n</tr>\n</tbody>\n</table>	https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop	Website performance metrics dashboard	Website Performance Optimization with Lazy Loading	Boost your website performance up to 50% with modern lazy loading techniques. Complete guide with code examples and best practices.	performance,lazy loading,optimization,web,speed	published	2025-01-08 20:04:30.611+07	\N	5466	493	29	1	t	t	03a0977b-3ae5-491f-bd77-3cec98f336a7	2025-08-23 13:42:43.043+07	2025-08-23 13:42:43.043+07
f969b335-df27-4df4-a0cd-9116ae0d34a6	database-design-patterns-untuk-aplikasi-modern-vol-3-14	Database Design Patterns untuk Aplikasi Modern Vol 3	Pelajari design patterns terbaik untuk database yang scalable dan maintainable dalam aplikasi modern.	<h1>Database Design Patterns untuk Aplikasi Modern</h1>\n<p>Dalam pengembangan aplikasi modern, database design pattern yang tepat sangat mempengaruhi performa dan maintainability aplikasi.</p>\n\n<h2>Repository Pattern</h2>\n<p>Repository pattern memisahkan logika data access dari business logic:</p>\n\n<pre><code>class UserRepository {\n  async findById(id) {\n    return await db.query('SELECT * FROM users WHERE id = $1', [id]);\n  }\n  \n  async create(userData) {\n    const { name, email } = userData;\n    return await db.query(\n      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',\n      [name, email]\n    );\n  }\n}</code></pre>\n\n<div style="background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 6px; padding: 16px; margin: 16px 0;">\n<h4>⚠️ Perhatian:</h4>\n<p>Jangan over-engineer dengan terlalu banyak abstraction layers jika aplikasi masih sederhana.</p>\n</div>\n\n<h3>Keuntungan Repository Pattern:</h3>\n<ul>\n<li><strong>Separation of Concerns:</strong> Business logic terpisah dari data access</li>\n<li><strong>Testability:</strong> Mudah untuk mock data layer dalam testing</li>\n<li><strong>Flexibility:</strong> Mudah berganti database atau ORM</li>\n<li><strong>Maintainability:</strong> Kode lebih terorganisir dan mudah dipelihara</li>\n</ul>\n\n<p>Pelajari lebih lanjut tentang <a href="#" style="color: #0066cc; text-decoration: none;">design patterns</a> dalam pengembangan software.</p>	https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=400&fit=crop	Database schema diagram	Modern Database Design Patterns Guide	Master database design patterns for scalable applications. Learn Repository pattern, Active Record, and more with practical examples.	database,design patterns,sql,backend,architecture	published	2025-03-15 03:25:28.959+07	\N	8223	50	148	1	f	f	aad7e27c-5693-44ce-8998-57d874074af7	2025-08-23 13:42:43.047+07	2025-08-23 13:42:43.047+07
8fa56b9f-352d-46a1-8d64-d6dc6a8bbe5a	microservices-architecture-pros-and-cons-vol-3-15	Microservices Architecture: Pros and Cons Vol 3	Analisis mendalam tentang microservices architecture, kapan menggunakannya dan tantangan yang harus dihadapi.	<h1>Microservices Architecture: Pros and Cons</h1>\n<p>Microservices telah menjadi arsitektur populer untuk aplikasi enterprise. Namun, apakah selalu merupakan pilihan yang tepat?</p>\n\n<h2>Apa itu Microservices?</h2>\n<p>Microservices adalah architectural pattern dimana aplikasi dibangun sebagai kumpulan service-service kecil yang independen.</p>\n\n<h3>Keuntungan Microservices:</h3>\n<ol>\n<li><strong>Scalability:</strong> Setiap service bisa di-scale independen</li>\n<li><strong>Technology Diversity:</strong> Bebas pilih tech stack per service</li>\n<li><strong>Team Independence:</strong> Tim bisa develop dan deploy secara terpisah</li>\n<li><strong>Fault Isolation:</strong> Error di satu service tidak mempengaruhi yang lain</li>\n</ol>\n\n<blockquote style="border-left: 4px solid #e74c3c; padding-left: 20px; margin: 20px 0; font-style: italic; color: #555;">\n"Microservices are not a silver bullet. They come with their own set of complexities." - Martin Fowler\n</blockquote>\n\n<h3>Tantangan Microservices:</h3>\n<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>🔧 Technical Challenges</h4>\n<ul>\n<li>Network latency</li>\n<li>Data consistency</li>\n<li>Service discovery</li>\n<li>Distributed tracing</li>\n</ul>\n</div>\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>👥 Organizational Challenges</h4>\n<ul>\n<li>Team coordination</li>\n<li>Deployment complexity</li>\n<li>Monitoring & debugging</li>\n<li>Documentation overhead</li>\n</ul>\n</div>\n</div>\n\n<h2>Kapan Menggunakan Microservices?</h2>\n<p>Pertimbangkan microservices ketika:</p>\n<ul>\n<li>Tim development sudah mature</li>\n<li>Aplikasi sudah kompleks dan sulit di-maintain</li>\n<li>Butuh scalability yang berbeda per komponen</li>\n<li>Organisasi sudah siap dengan DevOps practices</li>\n</ul>	https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=400&fit=crop	Microservices architecture diagram	Microservices Architecture Complete Analysis	Comprehensive analysis of microservices architecture. Learn the benefits, challenges, and when to adopt microservices for your projects.	microservices,architecture,scalability,devops,backend	published	2025-01-05 19:38:46.84+07	\N	284	17	2	1	f	t	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	2025-08-23 13:42:43.051+07	2025-08-23 13:42:43.051+07
f0c4893a-0c6c-43ec-b746-b223e5d062b4	panduan-lengkap-javascript-es6-vol-4-16	Panduan Lengkap JavaScript ES6+ Vol 4	Pelajari fitur-fitur terbaru JavaScript yang membuat development lebih efisien dan modern.	<h1>Panduan Lengkap JavaScript ES6+</h1>\n<p>JavaScript telah berkembang pesat dalam beberapa tahun terakhir. Dalam artikel ini, kita akan membahas fitur-fitur terbaru yang membuat JavaScript semakin powerful.</p>\n\n<h2>Arrow Functions</h2>\n<p>Arrow function adalah salah satu fitur paling populer di ES6:</p>\n<pre><code>const greet = (name) => {\n  return `Hello, ${name}!`;\n};</code></pre>\n\n<blockquote>\n<p>"Arrow functions membuat kode JavaScript lebih concise dan readable." - JavaScript Developer</p>\n</blockquote>\n\n<h3>Keuntungan Arrow Functions:</h3>\n<ul>\n<li>Syntax yang lebih singkat</li>\n<li>Lexical <strong>this</strong> binding</li>\n<li>Implicit return untuk single expression</li>\n</ul>\n\n<p>Untuk informasi lebih lanjut, kunjungi <a href="https://developer.mozilla.org">MDN Web Docs</a>.</p>	https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=400&fit=crop	JavaScript code on computer screen	JavaScript ES6+ Guide - Modern Web Development	Complete guide to modern JavaScript ES6+ features including arrow functions, destructuring, and async/await for better web development.	javascript,es6,arrow functions,programming,web development	draft	\N	\N	0	0	0	1	f	t	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	2025-08-23 13:42:43.055+07	2025-08-23 13:42:43.055+07
f0ee1391-5e1e-49d1-aad0-715a7e7a1df5	tutorial-react-hooks-untuk-pemula-vol-4-17	Tutorial React Hooks untuk Pemula Vol 4	Panduan lengkap menggunakan React Hooks untuk membuat komponen yang lebih clean dan efisien.	<h1>Tutorial React Hooks untuk Pemula</h1>\n<p>React Hooks mengubah cara kita menulis komponen React. Mari pelajari hooks yang paling sering digunakan.</p>\n\n<h2>useState Hook</h2>\n<p>Hook pertama yang harus dipelajari adalah <code>useState</code>:</p>\n<pre><code>import React, { useState } from 'react';\n\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  \n  return (\n    &lt;div&gt;\n      &lt;p&gt;Count: {count}&lt;/p&gt;\n      &lt;button onClick={() =&gt; setCount(count + 1)}&gt;\n        Increment\n      &lt;/button&gt;\n    &lt;/div&gt;\n  );\n}</code></pre>\n\n<div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0;">\n<h4>💡 Tips:</h4>\n<p>Selalu gunakan functional updates ketika state baru bergantung pada state sebelumnya.</p>\n</div>\n\n<h3>Best Practices:</h3>\n<ol>\n<li>Gunakan multiple state variables untuk data yang tidak related</li>\n<li>Hindari complex objects dalam single state</li>\n<li>Pertimbangkan useReducer untuk state management yang kompleks</li>\n</ol>	https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=400&fit=crop	React logo and code editor	React Hooks Tutorial - Complete Beginner Guide	Learn React Hooks from scratch with practical examples. Master useState, useEffect, and custom hooks for modern React development.	react,hooks,javascript,frontend,tutorial	published	2025-01-27 05:19:55.671+07	\N	115	9	1	1	f	t	2b7729a3-0631-413d-a7e3-75679bfda256	2025-08-23 13:42:43.06+07	2025-08-23 13:42:43.06+07
e828f897-8255-4815-80ae-72b846d03d57	optimasi-performance-website-dengan-lazy-loading-vol-4-18	Optimasi Performance Website dengan Lazy Loading Vol 4	Tingkatkan performa website hingga 50% dengan teknik lazy loading yang tepat dan implementasi modern.	<h1>Optimasi Performance Website dengan Lazy Loading</h1>\n<p>Performance website adalah faktor kunci dalam user experience dan SEO. Salah satu teknik yang efektif adalah <em>lazy loading</em>.</p>\n\n<h2>Apa itu Lazy Loading?</h2>\n<p>Lazy loading adalah teknik yang menunda loading resource sampai benar-benar dibutuhkan oleh user.</p>\n\n<h3>Implementasi untuk Images:</h3>\n<pre><code>&lt;img \n  src="placeholder.jpg" \n  data-src="actual-image.jpg" \n  class="lazy-load"\n  alt="Description"\n&gt;\n\n&lt;script&gt;\nconst images = document.querySelectorAll('.lazy-load');\nconst imageObserver = new IntersectionObserver((entries) =&gt; {\n  entries.forEach(entry =&gt; {\n    if (entry.isIntersecting) {\n      const img = entry.target;\n      img.src = img.dataset.src;\n      imageObserver.unobserve(img);\n    }\n  });\n});\n\nimages.forEach(img =&gt; imageObserver.observe(img));\n&lt;/script&gt;</code></pre>\n\n<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">\n<thead>\n<tr style="background-color: #f5f5f5;">\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Teknik</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Performance Gain</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Kompleksitas</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style="border: 1px solid #ddd; padding: 12px;">Image Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">20-50%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Rendah</td>\n</tr>\n<tr style="background-color: #f9f9f9;">\n<td style="border: 1px solid #ddd; padding: 12px;">Component Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">30-60%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Sedang</td>\n</tr>\n</tbody>\n</table>	https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop	Website performance metrics dashboard	Website Performance Optimization with Lazy Loading	Boost your website performance up to 50% with modern lazy loading techniques. Complete guide with code examples and best practices.	performance,lazy loading,optimization,web,speed	published	2024-11-07 16:37:13.074+07	\N	9529	308	53	1	f	t	aad7e27c-5693-44ce-8998-57d874074af7	2025-08-23 13:42:43.064+07	2025-08-23 13:42:43.064+07
ad52acbd-b7ec-44f5-9d8b-d331c0f7d89e	database-design-patterns-untuk-aplikasi-modern-vol-4-19	Database Design Patterns untuk Aplikasi Modern Vol 4	Pelajari design patterns terbaik untuk database yang scalable dan maintainable dalam aplikasi modern.	<h1>Database Design Patterns untuk Aplikasi Modern</h1>\n<p>Dalam pengembangan aplikasi modern, database design pattern yang tepat sangat mempengaruhi performa dan maintainability aplikasi.</p>\n\n<h2>Repository Pattern</h2>\n<p>Repository pattern memisahkan logika data access dari business logic:</p>\n\n<pre><code>class UserRepository {\n  async findById(id) {\n    return await db.query('SELECT * FROM users WHERE id = $1', [id]);\n  }\n  \n  async create(userData) {\n    const { name, email } = userData;\n    return await db.query(\n      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',\n      [name, email]\n    );\n  }\n}</code></pre>\n\n<div style="background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 6px; padding: 16px; margin: 16px 0;">\n<h4>⚠️ Perhatian:</h4>\n<p>Jangan over-engineer dengan terlalu banyak abstraction layers jika aplikasi masih sederhana.</p>\n</div>\n\n<h3>Keuntungan Repository Pattern:</h3>\n<ul>\n<li><strong>Separation of Concerns:</strong> Business logic terpisah dari data access</li>\n<li><strong>Testability:</strong> Mudah untuk mock data layer dalam testing</li>\n<li><strong>Flexibility:</strong> Mudah berganti database atau ORM</li>\n<li><strong>Maintainability:</strong> Kode lebih terorganisir dan mudah dipelihara</li>\n</ul>\n\n<p>Pelajari lebih lanjut tentang <a href="#" style="color: #0066cc; text-decoration: none;">design patterns</a> dalam pengembangan software.</p>	https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=400&fit=crop	Database schema diagram	Modern Database Design Patterns Guide	Master database design patterns for scalable applications. Learn Repository pattern, Active Record, and more with practical examples.	database,design patterns,sql,backend,architecture	published	2025-04-05 10:37:36.561+07	\N	1366	93	9	1	f	t	6262077e-05e4-4b8d-86c1-84b29fcfe254	2025-08-23 13:42:43.068+07	2025-08-23 13:42:43.068+07
ac736932-6663-451b-b5f8-fb794855d4f7	microservices-architecture-pros-and-cons-vol-4-20	Microservices Architecture: Pros and Cons Vol 4	Analisis mendalam tentang microservices architecture, kapan menggunakannya dan tantangan yang harus dihadapi.	<h1>Microservices Architecture: Pros and Cons</h1>\n<p>Microservices telah menjadi arsitektur populer untuk aplikasi enterprise. Namun, apakah selalu merupakan pilihan yang tepat?</p>\n\n<h2>Apa itu Microservices?</h2>\n<p>Microservices adalah architectural pattern dimana aplikasi dibangun sebagai kumpulan service-service kecil yang independen.</p>\n\n<h3>Keuntungan Microservices:</h3>\n<ol>\n<li><strong>Scalability:</strong> Setiap service bisa di-scale independen</li>\n<li><strong>Technology Diversity:</strong> Bebas pilih tech stack per service</li>\n<li><strong>Team Independence:</strong> Tim bisa develop dan deploy secara terpisah</li>\n<li><strong>Fault Isolation:</strong> Error di satu service tidak mempengaruhi yang lain</li>\n</ol>\n\n<blockquote style="border-left: 4px solid #e74c3c; padding-left: 20px; margin: 20px 0; font-style: italic; color: #555;">\n"Microservices are not a silver bullet. They come with their own set of complexities." - Martin Fowler\n</blockquote>\n\n<h3>Tantangan Microservices:</h3>\n<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>🔧 Technical Challenges</h4>\n<ul>\n<li>Network latency</li>\n<li>Data consistency</li>\n<li>Service discovery</li>\n<li>Distributed tracing</li>\n</ul>\n</div>\n<div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px;">\n<h4>👥 Organizational Challenges</h4>\n<ul>\n<li>Team coordination</li>\n<li>Deployment complexity</li>\n<li>Monitoring & debugging</li>\n<li>Documentation overhead</li>\n</ul>\n</div>\n</div>\n\n<h2>Kapan Menggunakan Microservices?</h2>\n<p>Pertimbangkan microservices ketika:</p>\n<ul>\n<li>Tim development sudah mature</li>\n<li>Aplikasi sudah kompleks dan sulit di-maintain</li>\n<li>Butuh scalability yang berbeda per komponen</li>\n<li>Organisasi sudah siap dengan DevOps practices</li>\n</ul>	https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=400&fit=crop	Microservices architecture diagram	Microservices Architecture Complete Analysis	Comprehensive analysis of microservices architecture. Learn the benefits, challenges, and when to adopt microservices for your projects.	microservices,architecture,scalability,devops,backend	published	2025-07-16 04:22:37.022+07	\N	4971	376	39	1	f	t	2b7729a3-0631-413d-a7e3-75679bfda256	2025-08-23 13:42:43.072+07	2025-08-23 13:42:43.072+07
9f963b29-8d43-471f-8079-5db79b6547d4	optimasi-performance-website-dengan-lazy-loading-vol-5-23	Optimasi Performance Website dengan Lazy Loading Vol 5	Tingkatkan performa website hingga 50% dengan teknik lazy loading yang tepat dan implementasi modern.	<h1>Optimasi Performance Website dengan Lazy Loading</h1>\n<p>Performance website adalah faktor kunci dalam user experience dan SEO. Salah satu teknik yang efektif adalah <em>lazy loading</em>.</p>\n\n<h2>Apa itu Lazy Loading?</h2>\n<p>Lazy loading adalah teknik yang menunda loading resource sampai benar-benar dibutuhkan oleh user.</p>\n\n<h3>Implementasi untuk Images:</h3>\n<pre><code>&lt;img \n  src="placeholder.jpg" \n  data-src="actual-image.jpg" \n  class="lazy-load"\n  alt="Description"\n&gt;\n\n&lt;script&gt;\nconst images = document.querySelectorAll('.lazy-load');\nconst imageObserver = new IntersectionObserver((entries) =&gt; {\n  entries.forEach(entry =&gt; {\n    if (entry.isIntersecting) {\n      const img = entry.target;\n      img.src = img.dataset.src;\n      imageObserver.unobserve(img);\n    }\n  });\n});\n\nimages.forEach(img =&gt; imageObserver.observe(img));\n&lt;/script&gt;</code></pre>\n\n<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">\n<thead>\n<tr style="background-color: #f5f5f5;">\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Teknik</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Performance Gain</th>\n<th style="border: 1px solid #ddd; padding: 12px; text-align: left;">Kompleksitas</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style="border: 1px solid #ddd; padding: 12px;">Image Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">20-50%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Rendah</td>\n</tr>\n<tr style="background-color: #f9f9f9;">\n<td style="border: 1px solid #ddd; padding: 12px;">Component Lazy Loading</td>\n<td style="border: 1px solid #ddd; padding: 12px;">30-60%</td>\n<td style="border: 1px solid #ddd; padding: 12px;">Sedang</td>\n</tr>\n</tbody>\n</table>	https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=400&fit=crop	Website performance metrics dashboard	Website Performance Optimization with Lazy Loading	Boost your website performance up to 50% with modern lazy loading techniques. Complete guide with code examples and best practices.	performance,lazy loading,optimization,web,speed	published	2025-03-26 11:09:38.537+07	\N	148	11	1	1	f	t	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	2025-08-23 13:42:43.085+07	2025-08-23 13:42:43.085+07
0e63a8b1-ccdd-4167-9f84-143bf981c770	panduan-lengkap-javascript-es6-vol-5-21	Panduan Lengkap JavaScript ES6+ Vol 5	Pelajari fitur-fitur terbaru JavaScript yang membuat development lebih efisien dan modern.	<h1>Panduan Lengkap JavaScript ES6+</h1>\n<p>JavaScript telah berkembang pesat dalam beberapa tahun terakhir. Dalam artikel ini, kita akan membahas fitur-fitur terbaru yang membuat JavaScript semakin powerful.</p>\n\n<h2>Arrow Functions</h2>\n<p>Arrow function adalah salah satu fitur paling populer di ES6:</p>\n<pre><code>const greet = (name) => {\n  return `Hello, ${name}!`;\n};</code></pre>\n\n<blockquote>\n<p>"Arrow functions membuat kode JavaScript lebih concise dan readable." - JavaScript Developer</p>\n</blockquote>\n\n<h3>Keuntungan Arrow Functions:</h3>\n<ul>\n<li>Syntax yang lebih singkat</li>\n<li>Lexical <strong>this</strong> binding</li>\n<li>Implicit return untuk single expression</li>\n</ul>\n\n<p>Untuk informasi lebih lanjut, kunjungi <a href="https://developer.mozilla.org">MDN Web Docs</a>.</p>	https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=800&h=400&fit=crop	JavaScript code on computer screen	JavaScript ES6+ Guide - Modern Web Development	Complete guide to modern JavaScript ES6+ features including arrow functions, destructuring, and async/await for better web development.	javascript,es6,arrow functions,programming,web development	published	2025-07-19 17:32:13.662+07	\N	414	25	4	1	f	t	03a0977b-3ae5-491f-bd77-3cec98f336a7	2025-08-23 13:42:43.077+07	2025-08-23 14:19:07.237+07
f1b45462-d402-4b64-a4a3-8fc2d53a607b	tutorial-react-hooks-untuk-pemula-vol-5-22	Tutorial React Hooks untuk Pemula Vol 5	Panduan lengkap menggunakan React Hooks untuk membuat komponen yang lebih clean dan efisien.	<h1>Tutorial React Hooks untuk Pemula</h1>\n<p>React Hooks mengubah cara kita menulis komponen React. Mari pelajari hooks yang paling sering digunakan.</p>\n\n<h2>useState Hook</h2>\n<p>Hook pertama yang harus dipelajari adalah <code>useState</code>:</p>\n<pre><code>import React, { useState } from 'react';\n\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  \n  return (\n    &lt;div&gt;\n      &lt;p&gt;Count: {count}&lt;/p&gt;\n      &lt;button onClick={() =&gt; setCount(count + 1)}&gt;\n        Increment\n      &lt;/button&gt;\n    &lt;/div&gt;\n  );\n}</code></pre>\n\n<div style="background-color: #f0f8ff; padding: 15px; border-left: 4px solid #0066cc; margin: 20px 0;">\n<h4>💡 Tips:</h4>\n<p>Selalu gunakan functional updates ketika state baru bergantung pada state sebelumnya.</p>\n</div>\n\n<h3>Best Practices:</h3>\n<ol>\n<li>Gunakan multiple state variables untuk data yang tidak related</li>\n<li>Hindari complex objects dalam single state</li>\n<li>Pertimbangkan useReducer untuk state management yang kompleks</li>\n</ol>	https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=800&h=400&fit=crop	React logo and code editor	React Hooks Tutorial - Complete Beginner Guide	Learn React Hooks from scratch with practical examples. Master useState, useEffect, and custom hooks for modern React development.	react,hooks,javascript,frontend,tutorial	published	2025-06-14 14:14:54.028+07	\N	9769	282	2	1	f	t	2b7729a3-0631-413d-a7e3-75679bfda256	2025-08-23 13:42:43.081+07	2025-08-23 14:24:34.101+07
\.


--
-- TOC entry 4930 (class 0 OID 38312)
-- Dependencies: 218
-- Data for Name: memberships; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.memberships (id, name, slug, description, price, duration_days, features, limits, is_active, is_featured, priority, "createdAt", "updatedAt") FROM stdin;
660e8400-e29b-41d4-a716-446655440001	Free	free	Basic membership	0.00	365	["Basic Support", "Limited Storage"]	{"max_projects": null, "max_api_calls": null, "max_storage_gb": null}	t	f	1	2025-08-22 16:38:54.523+07	2025-08-22 16:38:54.523+07
660e8400-e29b-41d4-a716-446655440002	Premium	premium	Advanced features	29.99	30	["Priority Support", "Advanced Analytics"]	{"max_projects": null, "max_api_calls": null, "max_storage_gb": null}	t	f	1	2025-08-22 16:38:54.523+07	2025-08-22 16:38:54.523+07
660e8400-e29b-41d4-a716-446655440003	Enterprise	enterprise	Unlimited access	99.99	30	["24/7 Support", "Custom Solutions"]	{"max_projects": null, "max_api_calls": null, "max_storage_gb": null}	t	f	1	2025-08-22 16:38:54.523+07	2025-08-22 16:38:54.523+07
\.


--
-- TOC entry 4929 (class 0 OID 38297)
-- Dependencies: 217
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, slug, description, permissions, is_active, "createdAt", "updatedAt") FROM stdin;
550e8400-e29b-41d4-a716-446655440001	Super Admin	super_admin	Full system access	["*"]	t	2025-08-22 16:38:54.511+07	2025-08-22 16:38:54.511+07
550e8400-e29b-41d4-a716-446655440002	Admin	admin	Administrative access	["users.read", "users.create", "users.update", "users.delete"]	t	2025-08-22 16:38:54.511+07	2025-08-22 16:38:54.511+07
550e8400-e29b-41d4-a716-446655440003	Member	member	Regular user access	["profile.read", "profile.update"]	t	2025-08-22 16:38:54.511+07	2025-08-22 16:38:54.511+07
\.


--
-- TOC entry 4931 (class 0 OID 38343)
-- Dependencies: 219
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, picture, "pictureUrl", bio, role_id, membership_id, membership_expires_at, is_active, last_login_at, email_verified_at, provider, provider_id, "createdAt", "updatedAt") FROM stdin;
3092405f-8950-49c9-b1ed-d85a34e9ea23	Jane Smith 	jane.smith@gmail.com	\N	\N	https://i.pravatar.cc/150?img=4	Premium member user 	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440002	2025-09-21 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
6262077e-05e4-4b8d-86c1-84b29fcfe254	Bob Johnson	bob.johnson@example.com	\N	\N	https://i.pravatar.cc/150?img=5	Content creator and writer	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440002	2025-09-21 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
2b7729a3-0631-413d-a7e3-75679bfda256	Alice Brown	alice.brown@example.com	$argon2id$v=19$m=4096,t=3,p=1$Tgf+DPucNZe5LKFpzMjmYA$WLIUkPgzeAgcDURYDpt/Nnwe8vuZjP2cNv3LCAWzv8M	\N	https://i.pravatar.cc/150?img=6	Video content specialist	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440003	2025-09-21 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
108970e7-816a-4d0c-892c-657e0772729c	Charlie Wilson	charlie.wilson@gmail.com	\N	\N	https://i.pravatar.cc/150?img=7	Tech enthusiast and blogger (Google Login)	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440001	2026-08-22 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
7f10f633-1ed6-453a-91a8-4db228c0a68e	Diana Davis	diana.davis@example.com	$argon2id$v=19$m=4096,t=3,p=1$Tgf+DPucNZe5LKFpzMjmYA$WLIUkPgzeAgcDURYDpt/Nnwe8vuZjP2cNv3LCAWzv8M	\N	https://i.pravatar.cc/150?img=8	Marketing specialist	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440002	2025-09-21 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
3e0594aa-e52d-47a5-b5af-3ebb86f04060	Edward Miller	edward.miller@example.com	$argon2id$v=19$m=4096,t=3,p=1$Tgf+DPucNZe5LKFpzMjmYA$WLIUkPgzeAgcDURYDpt/Nnwe8vuZjP2cNv3LCAWzv8M	\N	https://i.pravatar.cc/150?img=9	Software developer	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440001	2026-08-22 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
e06af6c1-f50b-415e-bc0e-cde2656ad5ee	Fiona Garcia	fiona.garcia@example.com	\N	\N	https://i.pravatar.cc/150?img=10	UI/UX Designer	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440002	2025-09-21 16:38:54.54+07	t	\N	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-22 16:38:54.54+07
03a0977b-3ae5-491f-bd77-3cec98f336a7	John Doe	john.doe@example.com	$argon2id$v=19$m=4096,t=3,p=1$Tgf+DPucNZe5LKFpzMjmYA$WLIUkPgzeAgcDURYDpt/Nnwe8vuZjP2cNv3LCAWzv8M	\N	https://i.pravatar.cc/150?img=3	Regular member user	550e8400-e29b-41d4-a716-446655440003	660e8400-e29b-41d4-a716-446655440001	2026-08-22 16:38:54.54+07	t	2025-08-24 11:01:11.304+07	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-24 11:01:11.304+07
78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	Admin User	admin@example.com	$argon2id$v=19$m=4096,t=3,p=1$Tgf+DPucNZe5LKFpzMjmYA$WLIUkPgzeAgcDURYDpt/Nnwe8vuZjP2cNv3LCAWzv8M	\N	https://i.pravatar.cc/150?img=2	System Administrator	550e8400-e29b-41d4-a716-446655440002	660e8400-e29b-41d4-a716-446655440002	2025-11-20 16:38:54.54+07	t	2025-08-24 11:34:09.162+07	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-24 11:34:09.164+07
aad7e27c-5693-44ce-8998-57d874074af7	Super Admin	superadmin@example.com	$argon2id$v=19$m=4096,t=3,p=1$Tgf+DPucNZe5LKFpzMjmYA$WLIUkPgzeAgcDURYDpt/Nnwe8vuZjP2cNv3LCAWzv8M	\N	https://i.pravatar.cc/150?img=1	System Super Administrator	550e8400-e29b-41d4-a716-446655440001	660e8400-e29b-41d4-a716-446655440003	2026-08-22 16:38:54.54+07	t	2025-08-24 11:57:34.169+07	2025-08-22 16:38:54.54+07	local	\N	2025-08-22 16:38:54.54+07	2025-08-24 11:57:34.171+07
\.


--
-- TOC entry 4933 (class 0 OID 38884)
-- Dependencies: 221
-- Data for Name: videos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.videos (id, title, description, url, thumbnail, duration, category, tags, language, quality, views, likes, dislikes, comments, shares, "isPublic", "isActive", "isFeatured", "isPremium", "monetizationEnabled", "ageRestriction", "publishedAt", "scheduledAt", "lastViewedAt", "averageWatchTime", "retentionRate", "clickThroughRate", "engagementScore", "fileSize", encoding, "userId", metadata, "createdAt", "updatedAt", "deletedAt") FROM stdin;
170386bc-1f30-4b27-b2a2-b2921a83e913	Progressive Web Apps Development	Pelajari progressive web apps development dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	292	web-development	["javascript","html","css","fullstack"]	en	1440p	745556	55708	6198	6118	886	t	t	t	f	t	all	2025-06-17 07:54:07.966+07	2025-09-06 06:45:32.566+07	2025-08-05 18:16:48.156+07	227	77.74	3.35	\N	30642352	H.265	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":33,"originalFileName":"progressive_web_apps_development.mp4","compressionRatio":0.63,"bitrate":2322}	2025-06-12 03:59:56.065+07	2025-06-21 02:40:18.351+07	\N
bcbe2148-fa0c-4c87-aefb-59975d3ba4e9	Mobile UI/UX Design Principles	Dalam video ini, kita akan membahas mobile ui/ux design principles. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	2487	mobile-development	["react-native","flutter","ios","android","mobile-app"]	en	1080p	392119	27591	1048	4848	1085	t	t	f	f	t	all	2025-03-27 02:14:37.489+07	\N	2025-08-13 07:19:01.164+07	825	33.17	5.29	\N	148366037	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":49,"originalFileName":"mobile_uiux_design_principles.mp4","compressionRatio":0.86,"bitrate":2172}	2025-03-20 16:47:19.092+07	2025-03-29 14:08:43.075+07	\N
0c915ab9-6a3e-48a1-93f0-f1b7f29d7fd1	Habit Building Strategies	Tutorial habit building strategies step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	467	lifestyle	["productivity","wellness","minimalism","self-improvement","life-tips"]	id	480p	115	5	0	0	0	f	t	f	t	t	all	2025-05-08 17:11:11.99+07	\N	2025-08-05 22:02:07.357+07	179	38.33	2.05	\N	63406101	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":115,"originalFileName":"habit_building_strategies.mp4","compressionRatio":0.55,"bitrate":3530}	2025-05-06 22:32:55.15+07	2025-05-11 13:53:21.321+07	\N
30d73ab0-bbff-4f3e-81b1-3ea089545f17	Speed Reading Techniques - Part 4	Dalam video ini, kita akan membahas speed reading techniques - part 4. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	578	education	["teaching","skills","knowledge","academic"]	id	720p	14401	1602	206	137	106	t	t	f	t	f	all	2025-07-30 19:38:19.342+07	\N	2025-08-04 14:15:34.141+07	314	54.33	7.72	\N	45432088	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":73,"originalFileName":"speed_reading_techniques_part_4.mp4","compressionRatio":0.65,"bitrate":2103}	2025-07-26 15:49:14.571+07	2025-08-03 09:00:53.748+07	\N
d429c9e6-2c87-49b2-b260-b731f254164f	Tailwind CSS Advanced Techniques	Tutorial tailwind css advanced techniques step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/ScMzIvxBSi4	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	852	web-development	["javascript","frontend"]	en	480p	2784	195	14	28	11	t	f	f	f	f	13+	2025-03-21 10:00:35.925+07	\N	2025-08-22 09:36:16.679+07	402	47.18	4.2	\N	111330025	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":167,"originalFileName":"tailwind_css_advanced_techniques.mp4","compressionRatio":0.59,"bitrate":3201}	2025-03-17 04:22:11.761+07	2025-03-22 16:09:16.568+07	\N
50a2648f-d677-4544-8d66-1b310296685c	Video Editing with Premiere Pro	Pelajari video editing with premiere pro dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	1602	tutorial	["learn","beginner","tutorial","tips","advanced"]	en	720p	1885	62	3	19	3	t	t	f	f	f	all	2025-02-12 13:58:53.22+07	\N	2025-08-07 06:30:56.831+07	1208	75.41	1.13	\N	114156139	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"mobile","processingTime":77,"originalFileName":"video_editing_with_premiere_pro.mp4","compressionRatio":0.84,"bitrate":2596}	2025-02-11 04:56:19.52+07	2025-02-15 07:07:59.333+07	\N
ce90e76c-9fce-4410-8db3-8ab0348c93f9	React Native Navigation	Tutorial react native navigation step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	75	mobile-development	["cross-platform","react-native","flutter","mobile-app","android"]	ja	720p	501	52	5	15	1	t	t	f	f	t	all	2025-01-28 19:00:09.071+07	\N	2025-08-17 13:15:13.458+07	44	58.67	5.29	\N	7452287	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"mobile","processingTime":188,"originalFileName":"react_native_navigation.mp4","compressionRatio":0.9,"bitrate":1812}	2025-01-26 08:01:58.976+07	2025-01-30 20:05:15.154+07	\N
4e0c9cf2-dd19-4f52-94e3-e9de2579345e	Algorithm Design Patterns	Algorithm Design Patterns explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	806	programming	["python","java","algorithms","coding"]	id	1440p	139774	9190	1249	1239	565	t	t	f	f	f	all	2025-04-11 14:38:08.244+07	\N	2025-08-15 00:02:49.382+07	240	29.78	2.04	\N	95242028	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":55,"originalFileName":"algorithm_design_patterns.mp4","compressionRatio":0.69,"bitrate":3723}	2025-04-10 08:37:20.377+07	2025-04-11 23:46:52.137+07	\N
914ead88-dcaa-4aaa-93ad-120c41d4d1f9	Academic Writing Tips	Academic Writing Tips - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	200	education	["teaching","learning","study-tips","academic","knowledge"]	en	720p	502	36	3	11	0	t	t	f	f	t	13+	2025-03-27 03:59:23.131+07	\N	2025-08-06 01:36:58.197+07	71	35.5	7.04	\N	17966423	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":49,"originalFileName":"academic_writing_tips.mp4","compressionRatio":0.88,"bitrate":3426}	2025-03-21 20:46:06.376+07	2025-03-30 11:03:00.313+07	\N
51cf5bc6-67fd-4bb6-9e19-d872462a50dd	React Native Cross-Platform Apps	Tutorial react native cross-platform apps step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	489	mobile-development	["react-native","android"]	en	1080p	315	22	2	6	0	t	t	f	f	t	all	2024-11-14 11:17:51.005+07	\N	2025-08-06 21:47:45.325+07	211	43.15	4.32	\N	44708893	VP9	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":27,"originalFileName":"react_native_crossplatform_apps.mp4","compressionRatio":0.56,"bitrate":2207}	2024-11-13 09:06:31.318+07	2024-11-16 05:56:51.165+07	\N
98b32ddd-e41f-4c6a-9f42-51bb2b3e636f	Korean Skincare K-Beauty Routine	Pelajari korean skincare k-beauty routine dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	593	beauty	["makeup","skincare","beauty-tips"]	id	1080p	2903	158	14	38	5	t	t	f	f	t	all	2024-10-12 08:32:25.316+07	\N	2025-08-14 01:17:31.015+07	370	62.39	3.62	\N	79749163	VP9	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"web","processingTime":84,"originalFileName":"korean_skincare_kbeauty_routine.mp4","compressionRatio":0.64,"bitrate":3792}	2024-10-06 08:15:54.848+07	2024-10-13 12:31:51.26+07	\N
4581ec59-50fa-4779-bf48-07fba411d2a5	Responsive Design with CSS Flexbox	Dalam video ini, kita akan membahas responsive design with css flexbox. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	139	web-development	["backend","react"]	en	1080p	428	49	4	14	1	t	t	f	t	f	all	2024-10-29 15:20:23.496+07	\N	2025-08-10 11:01:27.875+07	68	48.92	1.32	\N	20847546	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"web","processingTime":133,"originalFileName":"responsive_design_with_css_flexbox.mp4","compressionRatio":0.78,"bitrate":3099}	2024-10-28 14:56:23.195+07	2024-11-03 09:02:09.273+07	\N
ccfe35d6-4108-40bf-9897-729cb3c2c5d7	Nutrition Facts and Myths	Tutorial nutrition facts and myths step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	228	health	["healthy-living","medical"]	id	1080p	218277	6633	605	1653	349	t	t	f	f	t	all	2025-07-22 12:49:05.257+07	\N	2025-08-06 14:41:34.148+07	65	28.51	9.09	\N	26634960	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":48,"originalFileName":"nutrition_facts_and_myths.mp4","compressionRatio":0.58,"bitrate":1843}	2025-07-17 05:49:47.059+07	2025-07-24 18:04:56.721+07	\N
2ba33591-af67-4fca-a71c-65fa7617dfc7	Bodyweight Training Program	Pelajari bodyweight training program dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	1846	fitness	["training","exercise","bodybuilding"]	id	720p	278	7	0	1	0	t	t	f	f	f	all	2025-01-11 15:41:45.215+07	\N	2025-07-25 02:24:26.714+07	1004	54.39	2.27	\N	81204929	VP9	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":191,"originalFileName":"bodyweight_training_program.mp4","compressionRatio":0.63,"bitrate":2229}	2025-01-09 07:51:53.191+07	2025-01-13 19:32:11.974+07	\N
f831c197-69f6-4905-99c8-38fd1423414e	JavaScript ES2024 New Features	Dalam video ini, kita akan membahas javascript es2024 new features. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	3216	web-development	["fullstack","html","javascript","react","nodejs"]	en	1440p	3453	402	47	105	18	t	t	f	f	t	all	2025-07-27 07:25:41.285+07	\N	2025-07-30 23:46:43.57+07	2107	65.52	8.37	\N	449445969	VP9	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"mobile","processingTime":115,"originalFileName":"javascript_es2024_new_features.mp4","compressionRatio":0.86,"bitrate":3831}	2025-07-26 00:16:41.218+07	2025-07-27 10:41:51.612+07	\N
965b45ff-3bdf-4d39-a564-cfc535c9dcfa	Bodyweight Training Program - Part 4	Dalam video ini, kita akan membahas bodyweight training program - part 4. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	461	fitness	["workout","exercise","gym"]	id	1440p	5141	433	53	79	19	t	t	f	f	f	all	2025-02-11 09:56:23.131+07	\N	2025-08-13 10:45:08.916+07	340	73.75	2.26	\N	54515539	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":35,"originalFileName":"bodyweight_training_program_part_4.mp4","compressionRatio":0.59,"bitrate":2965}	2025-02-06 15:37:16.729+07	2025-02-11 21:05:00.996+07	\N
ad86f349-8bd9-4b26-82d6-2f4f8661e56b	Professional Makeup Techniques - Part 5	Dalam video ini, kita akan membahas professional makeup techniques - part 5. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	1377	beauty	["self-care","grooming"]	id	480p	907876	32475	4216	8338	798	f	t	f	f	t	all	2024-09-22 09:10:18.865+07	\N	2025-08-09 09:50:47.48+07	729	52.94	9.06	\N	215318204	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"desktop","processingTime":81,"originalFileName":"professional_makeup_techniques_part_5.mp4","compressionRatio":0.76,"bitrate":2001}	2024-09-18 18:28:09.339+07	2024-09-22 16:19:15.133+07	\N
0502b718-181f-42c2-b978-869f27164a20	Hydration and Water Intake - Part 1	Hydration and Water Intake - Part 1 - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	2492	health	["nutrition","mental-health"]	ja	720p	4126	384	11	110	15	t	t	f	f	f	13+	2025-08-12 02:27:11.788+07	\N	2025-07-26 07:39:16.463+07	1137	45.63	7.37	\N	220673283	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"desktop","processingTime":149,"originalFileName":"hydration_and_water_intake_part_1.mp4","compressionRatio":0.71,"bitrate":1584}	2025-08-10 02:05:40.309+07	2025-08-16 11:23:36.916+07	\N
483ae4cf-1365-439b-8c25-e99df324f2d2	Men's Health Essentials	Pelajari men's health essentials dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	217	health	["nutrition","healthy-living","mental-health","medical","wellness"]	en	720p	2670	96	8	17	2	t	t	f	f	t	all	2024-11-25 20:29:09.796+07	\N	2025-07-25 21:23:16.886+07	128	58.99	1.69	\N	22147310	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"desktop","processingTime":101,"originalFileName":"mens_health_essentials.mp4","compressionRatio":0.8,"bitrate":2426}	2024-11-23 01:08:33.555+07	2024-11-30 17:36:32.703+07	\N
74c95306-ff67-41d9-a5f7-e2b9c4b293b4	Rust Memory Safety Fundamentals	Tutorial rust memory safety fundamentals step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	168	programming	["python","java","algorithms"]	en	1440p	3398	379	16	37	9	t	t	f	f	t	all	2025-03-08 09:28:53.965+07	\N	2025-08-08 02:13:19.7+07	96	57.14	4.94	\N	25255233	H.265	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":194,"originalFileName":"rust_memory_safety_fundamentals.mp4","compressionRatio":0.74,"bitrate":3546}	2025-03-08 08:41:02.382+07	2025-03-08 09:32:15.188+07	\N
44fef991-c819-40cb-b0ce-bc5993aea842	Hydration and Water Intake	Pelajari hydration and water intake dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	118	health	["nutrition","mental-health","healthy-living"]	id	720p	371	20	2	4	0	f	f	f	f	f	all	2025-08-14 00:34:40.771+07	\N	2025-08-18 03:45:21.833+07	72	61.02	9.97	7.610879686351384	7425840	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"mobile","processingTime":86,"originalFileName":"hydration_and_water_intake.mp4","compressionRatio":0.74,"bitrate":2646}	2025-08-11 16:38:36.623+07	2025-08-24 13:22:56.136+07	\N
605a1c3e-0008-4d85-8f3f-1de4d2291d2c	Web Performance Optimization Masterclass - Part 4	Web Performance Optimization Masterclass - Part 4 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	106	web-development	["css","fullstack","react","nodejs","html","backend"]	id	720p	44847	2812	143	784	77	t	t	f	f	f	all	2024-08-29 02:19:50.643+07	\N	2025-07-25 04:58:50.482+07	60	56.6	3.82	\N	12636776	H.265	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"mobile","processingTime":71,"originalFileName":"web_performance_optimization_masterclass_part_4.mp4","compressionRatio":0.57,"bitrate":2248}	2024-08-29 02:00:15.175+07	2024-08-30 04:46:34.336+07	\N
afd1fffb-c1d4-4807-be5e-8da4c77b6ad4	Mobile App Testing Strategies	Mobile App Testing Strategies - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	755	mobile-development	["cross-platform","flutter","react-native","ios","mobile-app"]	id	1080p	39944	1168	102	227	47	t	t	t	f	t	all	2025-07-14 01:57:40.628+07	\N	2025-07-25 03:27:38.459+07	458	60.66	3.13	\N	44028998	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"web","processingTime":113,"originalFileName":"mobile_app_testing_strategies.mp4","compressionRatio":0.64,"bitrate":1021}	2025-07-13 20:24:31.243+07	2025-07-16 19:49:46.141+07	\N
5fd6c7a3-ac63-4d50-a710-74fe64bab82d	GraphQL API with Apollo Server - Part 3	Dalam video ini, kita akan membahas graphql api with apollo server - part 3. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	194	web-development	["react","javascript"]	en	360p	52048	2429	314	527	106	t	t	f	f	t	all	2025-04-18 14:44:20.496+07	\N	2025-07-31 17:50:08.549+07	69	35.57	7.39	\N	15822092	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":181,"originalFileName":"graphql_api_with_apollo_server_part_3.mp4","compressionRatio":0.83,"bitrate":1250}	2025-04-12 00:40:21.273+07	2025-04-21 12:17:25.486+07	\N
1f21d4e3-3ef5-4d74-92da-f5240411e232	App Store Optimization Guide - Part 2	Dalam video ini, kita akan membahas app store optimization guide - part 2. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	228	mobile-development	["react-native","cross-platform","android","ios","flutter"]	en	720p	264	20	1	5	0	t	t	f	f	f	all	2024-10-15 02:18:31.426+07	\N	2025-08-01 08:42:09.713+07	86	37.72	3.42	\N	28654536	H.265	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":95,"originalFileName":"app_store_optimization_guide_part_2.mp4","compressionRatio":0.75,"bitrate":1646}	2024-10-09 18:33:26.859+07	2024-10-19 05:46:02.767+07	\N
4f966c71-8789-455c-afea-9754b526b7ec	Recovery and Rest Importance	Pelajari recovery and rest importance dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	153	fitness	["workout","exercise","gym","training","health"]	en	1440p	496	24	3	6	0	t	t	f	f	t	all	2024-12-18 00:41:40.553+07	\N	2025-08-02 23:42:24.201+07	84	54.9	3.26	\N	20936799	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":173,"originalFileName":"recovery_and_rest_importance.mp4","compressionRatio":0.79,"bitrate":2355}	2024-12-15 05:08:37.436+07	2024-12-18 19:57:12.861+07	\N
9a463295-deb0-4252-af79-85e5af2a612e	Beauty Product Reviews 2024	Beauty Product Reviews 2024 - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	963	beauty	["cosmetics","makeup"]	id	480p	3047	248	29	63	15	t	t	f	t	t	all	2024-10-24 11:47:29.134+07	\N	2025-08-05 16:37:44.339+07	660	68.54	2.7	\N	89487332	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"web","processingTime":160,"originalFileName":"beauty_product_reviews_2024.mp4","compressionRatio":0.59,"bitrate":1133}	2024-10-23 06:30:50.693+07	2024-10-26 23:20:01.309+07	\N
d85f7ae9-1172-44e9-a381-1fc0f10554c2	Clean Architecture Principles	Clean Architecture Principles explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/ScMzIvxBSi4	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	3045	programming	["python","java","algorithms","clean-code","software"]	id	480p	14488	547	60	47	13	t	t	f	f	t	all	2024-10-02 16:39:55.424+07	\N	2025-08-13 12:28:30.129+07	1753	57.57	5.27	\N	247304186	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"desktop","processingTime":38,"originalFileName":"clean_architecture_principles.mp4","compressionRatio":0.89,"bitrate":2990}	2024-09-30 03:16:17.938+07	2024-10-05 13:16:59.549+07	\N
7a584d98-f6c2-45d6-8c0e-12270286bac7	Online Learning Best Practices - Part 2	Online Learning Best Practices - Part 2 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	1276	education	["teaching","learning","skills","study-tips"]	en	720p	2018	80	10	8	4	t	t	f	t	f	all	2025-03-07 12:05:57.146+07	\N	2025-07-29 18:28:45.242+07	466	36.52	4.9	\N	182483454	H.265	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":83,"originalFileName":"online_learning_best_practices_part_2.mp4","compressionRatio":0.83,"bitrate":3475}	2025-03-02 22:14:40.028+07	2025-03-09 13:20:35.358+07	\N
5b38cc3a-79ea-41dc-bc4e-0f7fee663a88	Svelte 5 Runes System Tutorial	Tutorial svelte 5 runes system tutorial step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	561	web-development	["javascript","backend","fullstack","html"]	en	1440p	393363	22795	977	4944	231	t	t	f	f	f	all	2024-12-04 01:02:20.17+07	\N	2025-08-04 23:02:50.79+07	174	31.02	6.29	\N	64454972	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":188,"originalFileName":"svelte_5_runes_system_tutorial.mp4","compressionRatio":0.58,"bitrate":3980}	2024-11-28 20:58:10.367+07	2024-12-06 20:35:50.153+07	\N
1074c044-5f76-460f-bdaf-1960be75e48b	Morning Productivity Routine	Tutorial morning productivity routine step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/ScMzIvxBSi4	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	806	lifestyle	["wellness","life-tips","minimalism"]	id	720p	15090	553	50	156	6	t	t	f	f	t	all	2024-12-20 15:18:27.189+07	\N	2025-07-27 17:32:52.146+07	570	70.72	9.36	\N	41481355	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":130,"originalFileName":"morning_productivity_routine.mp4","compressionRatio":0.59,"bitrate":3729}	2024-12-20 01:56:14.541+07	2024-12-23 16:02:04.679+07	\N
5685be5c-7531-4728-902d-5709ff6b81ad	Cycling Training Programs	Dalam video ini, kita akan membahas cycling training programs. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	644	fitness	["gym","training","exercise"]	en	720p	2722	67	3	17	3	t	t	f	t	t	all	2025-06-30 01:06:26.725+07	\N	2025-07-26 12:45:28.788+07	300	46.58	3.95	\N	98772060	VP9	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"desktop","processingTime":103,"originalFileName":"cycling_training_programs.mp4","compressionRatio":0.61,"bitrate":2236}	2025-06-28 17:33:58.166+07	2025-07-01 22:23:51.275+07	\N
c509eb56-3c7a-4ab1-8b8b-a2188dd2e7ff	Big Data with Apache Spark	Pelajari big data with apache spark dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	847	data-science	["python","visualization","ai","statistics","analytics"]	en	480p	1361	162	9	24	2	t	t	f	f	t	13+	2024-12-02 09:20:28.509+07	\N	2025-08-16 02:31:47.252+07	675	79.69	8.22	\N	89219144	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"mobile","processingTime":179,"originalFileName":"big_data_with_apache_spark.mp4","compressionRatio":0.81,"bitrate":3682}	2024-12-01 09:20:24.408+07	2024-12-03 21:02:46.749+07	\N
a59f5c93-e284-4f24-87da-1bcd821b31fe	Node.js Event Loop Explained	Node.js Event Loop Explained explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	111	programming	["coding","software","clean-code","algorithms","java"]	id	720p	4905	504	20	105	11	t	t	f	f	t	18+	2025-01-28 07:56:59.053+07	\N	2025-08-16 23:22:19.054+07	31	27.93	2.37	\N	12842048	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":114,"originalFileName":"nodejs_event_loop_explained.mp4","compressionRatio":0.66,"bitrate":1382}	2025-01-23 20:43:30.864+07	2025-02-01 04:46:52.479+07	\N
223531b4-6d2e-4223-b358-0a20d0e9a87c	Contouring and Highlighting	Contouring and Highlighting explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	112	beauty	["skincare","makeup","grooming"]	id	480p	3034	273	12	66	15	t	t	f	t	t	all	2024-12-09 11:46:32.184+07	\N	2025-08-22 15:31:09.046+07	47	41.96	5.64	\N	14678435	H.265	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":148,"originalFileName":"contouring_and_highlighting.mp4","compressionRatio":0.79,"bitrate":1451}	2024-12-02 19:20:20.453+07	2024-12-14 05:47:45.456+07	\N
1bed2cb0-a302-4771-8894-c5534aae0492	Python Clean Code Principles	Pelajari python clean code principles dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	462	programming	["algorithms","clean-code","java","coding","development"]	en	480p	20994	399	12	116	8	t	t	f	f	t	all	2025-05-01 19:24:09.87+07	\N	2025-08-19 07:53:59.236+07	307	66.45	3	\N	31932258	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":165,"originalFileName":"python_clean_code_principles.mp4","compressionRatio":0.79,"bitrate":2551}	2025-04-25 22:22:48.624+07	2025-05-05 14:25:30.408+07	\N
ffc1291a-b988-4f4a-811d-42efe6cb5bef	Speed Reading Techniques - Part 5	Pelajari speed reading techniques - part 5 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	70	education	["study-tips","knowledge","skills","learning","teaching"]	id	720p	10975	376	53	87	14	f	t	t	f	t	all	2025-03-21 00:49:07.241+07	\N	2025-08-20 17:52:30.395+07	56	80	6.02	\N	9207269	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"web","processingTime":98,"originalFileName":"speed_reading_techniques_part_5.mp4","compressionRatio":0.62,"bitrate":1266}	2025-03-18 19:45:34.257+07	2025-03-23 05:45:25.477+07	\N
5d2d3516-7d6a-4e08-a545-6f25afca2999	Sustainable Living Practices	Tutorial sustainable living practices step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	2036	lifestyle	["life-tips","self-improvement","minimalism","wellness","productivity"]	en	480p	97	6	0	0	0	t	t	f	f	t	all	2025-03-09 15:57:19.231+07	\N	2025-08-05 13:23:39.391+07	880	43.22	2.71	\N	109682741	H.265	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":48,"originalFileName":"sustainable_living_practices.mp4","compressionRatio":0.66,"bitrate":1348}	2025-03-03 03:18:41.455+07	2025-03-14 07:13:00.273+07	\N
0564a3e7-ed66-4eca-8476-e6eb34cf8929	CSS Grid Layout Mastery Course	Dalam video ini, kita akan membahas css grid layout mastery course. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	966	web-development	["javascript","html","fullstack","backend","nodejs"]	id	720p	14502	1403	55	237	49	t	t	f	f	f	16+	2024-09-14 04:38:59.87+07	\N	2025-07-25 18:30:14.815+07	597	61.8	4.45	\N	94586961	VP9	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"mobile","processingTime":54,"originalFileName":"css_grid_layout_mastery_course.mp4","compressionRatio":0.81,"bitrate":3840}	2024-09-12 10:47:14.983+07	2024-09-17 10:51:40.675+07	\N
aa57385b-ded4-4c7e-a685-225616fc1bd8	Personal Development Journey	Tutorial personal development journey step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/2Vv-BfVoq4g	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	85	lifestyle	["productivity","self-improvement"]	id	1080p	229568	11392	396	1645	581	t	t	f	f	t	all	2025-01-04 20:49:56.194+07	\N	2025-08-08 21:14:35.358+07	60	70.59	3.41	\N	11295569	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"mobile","processingTime":69,"originalFileName":"personal_development_journey.mp4","compressionRatio":0.83,"bitrate":2735}	2025-01-03 17:37:44.083+07	2025-01-09 16:34:02.903+07	\N
4df8880e-4723-4193-a3c9-8a81a0d245b2	Email Marketing Strategies - Part 2	Tutorial email marketing strategies - part 2 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	326	tutorial	["howto","tips"]	id	720p	39243	1527	157	298	57	t	t	f	f	f	all	2024-09-10 01:21:41.437+07	\N	2025-08-20 18:51:35.34+07	125	38.34	4.78	\N	22424618	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"mobile","processingTime":171,"originalFileName":"email_marketing_strategies_part_2.mp4","compressionRatio":0.79,"bitrate":1411}	2024-09-07 01:36:00.132+07	2024-09-11 21:00:41.47+07	\N
a34183a3-5b51-49af-82dc-837729d13df5	Swimming Technique Guide	Tutorial swimming technique guide step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	398	fitness	["workout","exercise","gym","training"]	id	1080p	446	20	0	4	0	t	t	f	t	t	all	2025-05-12 08:33:05.585+07	\N	2025-08-07 07:51:11.477+07	192	48.24	6.66	\N	44048353	H.265	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":121,"originalFileName":"swimming_technique_guide.mp4","compressionRatio":0.79,"bitrate":2847}	2025-05-05 23:16:17.341+07	2025-05-16 11:53:23.228+07	\N
895f118c-4432-4770-a247-8450c7648c45	Pilates Core Strengthening	Tutorial pilates core strengthening step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	433	fitness	["bodybuilding","cardio"]	id	720p	2666	120	9	32	7	t	f	f	f	t	all	2024-08-24 03:57:09.174+07	\N	2025-08-01 07:41:45.969+07	309	71.36	7.46	\N	29909166	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":180,"originalFileName":"pilates_core_strengthening.mp4","compressionRatio":0.69,"bitrate":3406}	2024-08-24 03:54:12.911+07	2024-08-26 21:41:06.964+07	\N
15c1b817-063d-4700-82e5-76145e843aa4	SOLID Programming Principles	SOLID Programming Principles explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	229	programming	["java","python","coding","clean-code","algorithms"]	id	720p	484	38	3	10	2	t	t	f	f	t	all	2024-09-24 05:27:42.072+07	\N	2025-08-20 00:28:22.279+07	67	29.26	4.66	\N	15284063	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":56,"originalFileName":"solid_programming_principles.mp4","compressionRatio":0.74,"bitrate":2307}	2024-09-22 09:36:04.325+07	2024-09-27 19:18:54.037+07	\N
932597c5-2bf1-4580-8202-0e4345d42202	Men's Grooming Essentials - Part 2	Dalam video ini, kita akan membahas men's grooming essentials - part 2. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	257	beauty	["grooming","self-care","cosmetics","beauty-tips","makeup","skincare"]	id	1080p	53569	2412	301	494	135	t	t	f	f	t	13+	2025-02-03 02:28:44.892+07	\N	2025-08-22 04:30:00.325+07	171	66.54	3.61	\N	33161304	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":106,"originalFileName":"mens_grooming_essentials_part_2.mp4","compressionRatio":0.65,"bitrate":3922}	2025-01-30 04:49:00.901+07	2025-02-03 07:14:28.287+07	\N
ac5a8dbf-be5a-4c50-9e35-d02268121079	Python Clean Code Principles - Part 2	Tutorial python clean code principles - part 2 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	3377	programming	["python","java","algorithms","software"]	en	720p	20920	1486	189	357	91	t	t	f	f	f	all	2025-08-06 03:23:12.116+07	\N	2025-08-19 06:58:02.133+07	1576	46.67	2.33	\N	316407214	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":178,"originalFileName":"python_clean_code_principles_part_2.mp4","compressionRatio":0.79,"bitrate":1582}	2025-08-01 10:44:46.234+07	2025-08-06 07:38:09.492+07	\N
a46a7aa8-0b16-4e23-879d-eb4fbfa3fee4	Software Architecture Patterns - Part 5	Dalam video ini, kita akan membahas software architecture patterns - part 5. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	252	programming	["java","python","development","software"]	ja	1440p	108521	9213	499	2291	636	t	t	t	t	t	all	2025-07-01 08:02:49.327+07	\N	2025-08-21 07:31:44.915+07	122	48.41	7.38	\N	29594923	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":42,"originalFileName":"software_architecture_patterns_part_5.mp4","compressionRatio":0.64,"bitrate":2128}	2025-06-26 23:05:19.244+07	2025-07-05 22:24:26.03+07	\N
63b60f01-8927-4672-82e5-78435dffcb65	Social Media Management	Dalam video ini, kita akan membahas social media management. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	560	tutorial	["learn","tips"]	id	1080p	23405	907	79	198	49	t	t	f	f	t	13+	2025-03-20 17:06:39.579+07	\N	2025-08-23 08:14:36.529+07	194	34.64	5.64	\N	48630896	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"mobile","processingTime":73,"originalFileName":"social_media_management.mp4","compressionRatio":0.62,"bitrate":2938}	2025-03-16 08:13:31.87+07	2025-03-22 12:16:09.919+07	\N
bcc4b205-e1ee-4c3b-b6b2-3de050dcca58	HTML5 Semantic Elements Complete Guide	HTML5 Semantic Elements Complete Guide - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	295	web-development	["nodejs","backend","html","react","css"]	id	720p	103	5	0	1	0	t	t	f	t	t	all	2025-07-27 23:24:45.644+07	\N	2025-08-02 02:25:32.328+07	109	36.95	5.15	\N	40527980	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":144,"originalFileName":"html5_semantic_elements_complete_guide.mp4","compressionRatio":0.71,"bitrate":1923}	2025-07-22 18:19:17.706+07	2025-07-29 15:13:47.07+07	\N
6d743e13-8b7d-43f1-a045-409499196ff1	Work-Life Balance Tips	Dalam video ini, kita akan membahas work-life balance tips. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	1108	lifestyle	["wellness","minimalism","self-improvement"]	en	1080p	163	7	0	0	0	t	t	f	f	t	all	2025-07-30 23:05:49.941+07	\N	2025-08-12 03:05:28.7+07	820	74.01	3.85	\N	51518011	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":155,"originalFileName":"worklife_balance_tips.mp4","compressionRatio":0.81,"bitrate":2475}	2025-07-25 08:17:24.586+07	2025-08-04 03:18:20.62+07	\N
ec00d1e9-d4dc-450e-a134-beb02d0d66b6	Angular 17 Standalone Components - Part 1	Tutorial angular 17 standalone components - part 1 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/2Vv-BfVoq4g	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	117	web-development	["javascript","html"]	id	720p	40036	2524	373	278	127	t	t	t	t	f	all	2025-03-15 00:28:11.532+07	\N	2025-08-19 04:01:59.056+07	48	41.03	9.52	\N	6132393	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"mobile","processingTime":173,"originalFileName":"angular_17_standalone_components_part_1.mp4","compressionRatio":0.72,"bitrate":3028}	2025-03-12 11:39:13.357+07	2025-03-16 22:36:45.21+07	\N
f13678db-77c9-4a17-990c-c2319257df1c	Swift iOS App Development	Swift iOS App Development explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	1609	mobile-development	["ios","flutter","cross-platform","mobile-app","react-native"]	id	1080p	1444406	140043	19948	20886	9368	t	t	f	f	t	all	2025-05-12 06:22:42.542+07	2025-08-24 21:36:19.738+07	2025-07-30 20:28:41.936+07	1249	77.63	8.17	\N	171938964	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":100,"originalFileName":"swift_ios_app_development.mp4","compressionRatio":0.72,"bitrate":3149}	2025-05-11 21:22:26.169+07	2025-05-13 15:18:34.389+07	\N
6759853e-edcf-4d97-b5c3-b252f9418769	MLOps Production Deployment	MLOps Production Deployment explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	1803	data-science	["statistics","python","analytics"]	id	1080p	93	6	0	1	0	t	t	t	f	f	all	2024-11-09 02:45:38.044+07	2025-08-30 09:40:28.304+07	2025-08-04 16:05:17.329+07	1046	58.01	9.68	\N	172643753	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":192,"originalFileName":"mlops_production_deployment.mp4","compressionRatio":0.66,"bitrate":3929}	2024-11-02 17:57:13.373+07	2024-11-12 00:38:06.736+07	\N
d182cdd4-3f9a-426d-a0e0-cfc5c995bb97	SQL for Data Analytics - Part 4	SQL for Data Analytics - Part 4 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	515	data-science	["machine-learning","ai","visualization","analytics","statistics"]	id	1080p	133097	6290	382	522	268	t	t	f	t	t	all	2024-12-04 09:41:32.437+07	\N	2025-08-11 21:17:33.414+07	140	27.18	9.9	\N	82149334	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":192,"originalFileName":"sql_for_data_analytics_part_4.mp4","compressionRatio":0.57,"bitrate":3441}	2024-12-03 08:30:22.865+07	2024-12-04 13:44:09.535+07	\N
410272fb-d11d-4101-aa38-c2017262db92	App Store Optimization Guide	Pelajari app store optimization guide dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	700	mobile-development	["react-native","mobile-app","flutter"]	id	480p	364	31	2	5	0	t	t	t	f	t	all	2025-03-12 00:10:20.987+07	\N	2025-08-01 12:52:02.47+07	461	65.86	7.71	\N	50407893	H.265	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":45,"originalFileName":"app_store_optimization_guide.mp4","compressionRatio":0.77,"bitrate":1922}	2025-03-09 18:26:26.285+07	2025-03-16 12:07:45.608+07	\N
5f1ee932-571b-4b4e-942a-98e388f65531	Test Driven Development TDD	Tutorial test driven development tdd step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	748	programming	["clean-code","software","coding","algorithms","java","python"]	id	720p	4610	423	57	36	26	t	t	f	f	t	all	2024-11-27 22:51:16.78+07	\N	2025-08-12 14:18:29.152+07	406	54.28	3.82	\N	87891238	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"mobile","processingTime":98,"originalFileName":"test_driven_development_tdd.mp4","compressionRatio":0.89,"bitrate":3751}	2024-11-27 14:17:30.939+07	2024-11-30 14:09:45.355+07	\N
7bc909a2-a6df-4c84-a3b5-c45368dea61c	Social Media Management - Part 5	Tutorial social media management - part 5 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	1521	tutorial	["beginner","howto","guide","advanced","learn"]	id	720p	130781	6514	927	1175	319	t	t	f	f	t	all	2025-05-07 06:03:20.332+07	\N	2025-08-02 02:37:56.516+07	953	62.66	2.96	\N	96521928	VP9	7f10f633-1ed6-453a-91a8-4db228c0a68e	{"uploadedFrom":"desktop","processingTime":155,"originalFileName":"social_media_management_part_5.mp4","compressionRatio":0.56,"bitrate":2694}	2025-05-03 18:15:16.284+07	2025-05-09 14:00:33.896+07	\N
42f59929-8c26-4477-a7c2-75e578d32ba3	React Native Cross-Platform Apps - Part 4	React Native Cross-Platform Apps - Part 4 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	2052	mobile-development	["cross-platform","react-native","ios","flutter","mobile-app","android"]	en	1080p	182	6	0	0	0	t	t	f	t	t	16+	2025-04-07 04:33:44.613+07	\N	2025-08-01 19:17:19.511+07	771	37.57	1.69	\N	175453053	H.265	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"mobile","processingTime":148,"originalFileName":"react_native_crossplatform_apps_part_4.mp4","compressionRatio":0.6,"bitrate":1724}	2025-04-01 20:25:13.991+07	2025-04-11 10:27:25.583+07	\N
8dcdd862-ddd4-45ba-b0ad-92573e4c4140	Men's Grooming Essentials - Part 5	Men's Grooming Essentials - Part 5 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	509	beauty	["grooming","self-care","cosmetics"]	id	1080p	138	11	0	3	0	t	t	f	f	f	all	2025-07-21 00:50:23.732+07	\N	2025-08-08 16:29:08.272+07	279	54.81	5.85	\N	64514221	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":59,"originalFileName":"mens_grooming_essentials_part_5.mp4","compressionRatio":0.72,"bitrate":2508}	2025-07-17 19:32:37.944+07	2025-07-22 05:16:27.424+07	\N
6b8d69d7-2656-4a56-859a-beb21d882f6d	Xamarin Cross-Platform Development	Xamarin Cross-Platform Development - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	672	mobile-development	["react-native","cross-platform"]	id	720p	2982	133	14	27	2	t	t	f	f	t	all	2025-06-24 04:59:12.656+07	\N	2025-08-21 17:56:53.636+07	401	59.67	5.98	\N	85286429	H.265	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":31,"originalFileName":"xamarin_crossplatform_development.mp4","compressionRatio":0.57,"bitrate":2254}	2025-06-22 01:33:19.002+07	2025-06-28 22:27:10.477+07	\N
de0d3eb1-a119-4851-a1e5-c0e9ad3ba6c9	Posture Correction Exercises - Part 3	Posture Correction Exercises - Part 3 - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	1025	health	["nutrition","medical","mental-health","wellness"]	id	720p	160296	4174	290	408	194	t	t	f	f	t	all	2025-02-11 19:14:14.38+07	\N	2025-07-25 09:42:37.067+07	713	69.56	3.79	\N	160913519	H.265	7f10f633-1ed6-453a-91a8-4db228c0a68e	{"uploadedFrom":"web","processingTime":189,"originalFileName":"posture_correction_exercises_part_3.mp4","compressionRatio":0.75,"bitrate":2241}	2025-02-06 01:40:38.876+07	2025-02-13 09:23:16.511+07	\N
ea7480e9-df48-4228-9f62-dc59e326bc24	Graphic Design Principles	Graphic Design Principles - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	106	tutorial	["beginner","tutorial","tips","learn"]	id	1080p	5031	451	56	117	20	t	t	f	f	f	all	2025-02-24 17:51:54.034+07	\N	2025-08-07 05:53:56.07+07	81	76.42	4.33	\N	7576344	H.265	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"mobile","processingTime":38,"originalFileName":"graphic_design_principles.mp4","compressionRatio":0.6,"bitrate":3321}	2025-02-20 23:31:58.287+07	2025-02-25 22:32:45.718+07	\N
1a8975f8-7cbe-4517-8635-b0b01a791dc1	Data Structures Visualization	Tutorial data structures visualization step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	226	programming	["development","algorithms","software","java","coding","python"]	id	1080p	379	22	3	6	0	t	t	f	f	f	16+	2025-02-26 15:22:00.16+07	\N	2025-07-29 00:48:06.068+07	118	52.21	8.28	\N	30359797	VP9	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":102,"originalFileName":"data_structures_visualization.mp4","compressionRatio":0.75,"bitrate":1655}	2025-02-21 02:16:02.51+07	2025-02-27 09:17:44.486+07	\N
f546bbac-7b46-4acf-a2d0-014653185410	Eyeshadow Blending Techniques	Pelajari eyeshadow blending techniques dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	1311	beauty	["grooming","skincare","makeup"]	id	1080p	313	17	1	3	0	t	t	f	f	t	all	2025-02-05 04:32:31.246+07	\N	2025-08-18 15:46:03.47+07	544	41.5	3.04	\N	194696089	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"desktop","processingTime":119,"originalFileName":"eyeshadow_blending_techniques.mp4","compressionRatio":0.69,"bitrate":3457}	2025-01-29 22:08:43.598+07	2025-02-05 16:19:07.298+07	\N
6878bd8f-e237-426d-88de-abadbcd3df9d	Diabetes Management Tips	Diabetes Management Tips - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	987	health	["nutrition","mental-health","healthy-living","wellness"]	id	720p	332	21	2	4	1	t	t	f	f	t	all	2024-09-14 06:49:02.714+07	\N	2025-08-03 08:54:51.329+07	656	66.46	4.75	\N	93927786	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":113,"originalFileName":"diabetes_management_tips.mp4","compressionRatio":0.65,"bitrate":1096}	2024-09-13 01:53:44.524+07	2024-09-16 16:35:32.662+07	\N
13d2b3c0-144c-44b6-b5f4-0e88660c0655	Design Patterns Implementation	Dalam video ini, kita akan membahas design patterns implementation. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	814	programming	["python","coding"]	en	1080p	2072	211	26	49	10	t	t	t	f	t	13+	2025-04-09 04:21:59.645+07	\N	2025-08-14 01:50:44.212+07	533	65.48	4.97	\N	48991258	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"web","processingTime":93,"originalFileName":"design_patterns_implementation.mp4","compressionRatio":0.67,"bitrate":1983}	2025-04-07 06:10:48.976+07	2025-04-12 15:59:18.547+07	\N
dbac796d-1ea0-4b5a-b5dd-6407efe0e0e0	Healthy Aging Strategies	Dalam video ini, kita akan membahas healthy aging strategies. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	728	health	["wellness","nutrition","mental-health","medical","healthy-living"]	id	720p	2601	68	3	14	3	t	t	f	f	t	all	2025-06-28 10:21:51.694+07	\N	2025-07-27 09:22:59.213+07	374	51.37	3.84	\N	75630163	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"mobile","processingTime":91,"originalFileName":"healthy_aging_strategies.mp4","compressionRatio":0.88,"bitrate":3354}	2025-06-24 04:02:15.809+07	2025-06-30 07:20:37.766+07	\N
382b74d8-8ecd-4188-b816-803ed503b156	Yoga for Flexibility	Tutorial yoga for flexibility step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	247	fitness	["workout","cardio","exercise","bodybuilding","gym","training"]	id	720p	19093	1845	76	332	128	t	t	f	f	t	all	2025-04-24 15:37:39.658+07	\N	2025-08-12 19:56:35.974+07	196	79.35	8.36	\N	18987569	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":115,"originalFileName":"yoga_for_flexibility.mp4","compressionRatio":0.64,"bitrate":2993}	2025-04-23 09:03:59.263+07	2025-04-27 16:09:28.119+07	\N
f784a353-f6c2-4d72-8326-3891ba90611e	STEM Education Innovation	Pelajari stem education innovation dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	187	education	["skills","learning","teaching","study-tips","academic","knowledge"]	en	1080p	37923	3349	301	1092	38	t	t	f	t	f	all	2025-02-10 07:40:33.974+07	\N	2025-07-30 08:12:15.531+07	51	27.27	2.17	\N	17092601	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":92,"originalFileName":"stem_education_innovation.mp4","compressionRatio":0.68,"bitrate":2689}	2025-02-09 03:10:14.168+07	2025-02-11 21:05:40.883+07	\N
5f35d5e9-4eaa-4266-91ac-8e91169bfe1d	Online Learning Best Practices - Part 4	Tutorial online learning best practices - part 4 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	252	education	["learning","study-tips","skills","knowledge","teaching","academic"]	ko	1080p	15496	821	70	186	35	t	t	f	f	t	all	2025-05-12 08:29:19.345+07	\N	2025-08-16 17:49:45.163+07	81	32.14	6.2	\N	38664684	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"mobile","processingTime":22,"originalFileName":"online_learning_best_practices_part_4.mp4","compressionRatio":0.73,"bitrate":2185}	2025-05-12 04:35:21.439+07	2025-05-12 20:17:15.389+07	\N
ffb29c78-df99-4e29-b952-778d31e91d83	Time Series Analysis	Time Series Analysis - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	392	data-science	["statistics","analytics","python"]	en	480p	2315	128	4	19	6	t	t	f	t	f	all	2025-07-02 12:27:48.481+07	\N	2025-08-04 16:30:49.541+07	309	78.83	1.47	\N	20084925	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"mobile","processingTime":43,"originalFileName":"time_series_analysis.mp4","compressionRatio":0.84,"bitrate":1111}	2025-06-28 11:59:25.511+07	2025-07-03 01:09:32.795+07	\N
ac15caca-e720-4f37-a729-d8106a30fc20	Immune System Boosting	Dalam video ini, kita akan membahas immune system boosting. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	87	health	["nutrition","mental-health","healthy-living","wellness","medical"]	id	1080p	133	9	0	1	0	t	t	f	f	f	all	2025-01-19 22:01:35.599+07	\N	2025-08-23 13:48:22.761+07	56	64.37	2.51	\N	14184131	VP9	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":56,"originalFileName":"immune_system_boosting.mp4","compressionRatio":0.62,"bitrate":1129}	2025-01-19 05:10:38.616+07	2025-01-24 16:04:26.892+07	\N
56273af0-4570-4ff5-b1f2-16741e0137dc	Acne Treatment Solutions	Acne Treatment Solutions - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/ScMzIvxBSi4	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	885	beauty	["grooming","makeup","beauty-tips"]	id	720p	1650	57	1	12	3	t	f	t	t	t	all	2024-11-14 20:11:51.674+07	\N	2025-08-14 21:17:48.24+07	581	65.65	2.06	\N	64991642	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":127,"originalFileName":"acne_treatment_solutions.mp4","compressionRatio":0.7,"bitrate":2475}	2024-11-11 09:16:18.854+07	2024-11-15 23:45:35.631+07	\N
d0a75eb3-ef83-4a7e-adc7-b10c7829105c	Java Spring Boot Microservices - Part 3	Java Spring Boot Microservices - Part 3 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	238	programming	["python","coding","clean-code"]	en	720p	440	22	2	3	0	t	t	f	f	t	all	2025-01-10 15:24:27.667+07	\N	2025-08-01 07:30:39.65+07	114	47.9	5.06	\N	25486477	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"desktop","processingTime":44,"originalFileName":"java_spring_boot_microservices_part_3.mp4","compressionRatio":0.68,"bitrate":1245}	2025-01-08 03:24:44.823+07	2025-01-11 07:39:09.852+07	\N
1a878eb4-2e34-4348-bf61-cfdfef7305ad	Angular 17 Standalone Components	Pelajari angular 17 standalone components dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	1037	web-development	["javascript","backend","react"]	id	1440p	435	38	1	4	0	t	t	f	t	t	all	2024-09-27 10:59:13.439+07	\N	2025-08-07 12:57:48.451+07	286	27.58	6.44	\N	148402085	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"desktop","processingTime":25,"originalFileName":"angular_17_standalone_components.mp4","compressionRatio":0.83,"bitrate":1485}	2024-09-24 12:14:47.675+07	2024-10-02 00:36:33.557+07	\N
3b241d76-44f6-43e7-8aaa-b17615ccf153	Firebase Integration Tutorial	Tutorial firebase integration tutorial step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	3779	mobile-development	["flutter","react-native"]	en	1080p	702	42	1	4	1	f	t	t	t	t	all	2025-05-20 13:55:20.837+07	\N	2025-08-03 11:30:18.031+07	2530	66.95	4	\N	360814477	H.265	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":73,"originalFileName":"firebase_integration_tutorial.mp4","compressionRatio":0.78,"bitrate":1278}	2025-05-17 04:39:13.393+07	2025-05-24 05:28:31.365+07	\N
13982267-c3d9-4b29-a9c8-42952d82cd6d	Critical Thinking Skills	Critical Thinking Skills - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	1223	education	["teaching","skills","knowledge"]	id	720p	1077	37	5	8	0	t	t	f	f	f	all	2025-04-30 19:49:55.641+07	\N	2025-08-05 02:55:51.062+07	582	47.59	7.75	\N	91202012	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":28,"originalFileName":"critical_thinking_skills.mp4","compressionRatio":0.76,"bitrate":2459}	2025-04-27 16:59:06.388+07	2025-05-04 19:07:01.583+07	\N
b601e673-d2b3-4bef-82c2-c7fe18561923	Data Visualization with D3.js - Part 3	Tutorial data visualization with d3.js - part 3 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	172	data-science	["visualization","statistics","python","ai","analytics","machine-learning"]	en	1080p	1590	31	2	9	0	t	t	f	t	t	all	2024-11-19 01:42:09.246+07	\N	2025-07-25 01:14:51.096+07	81	47.09	3.88	\N	24201505	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"desktop","processingTime":33,"originalFileName":"data_visualization_with_d3js_part_3.mp4","compressionRatio":0.74,"bitrate":3458}	2024-11-15 14:47:33.976+07	2024-11-23 04:03:25.274+07	\N
2861a8ed-a272-4b43-82eb-65ce255ae33e	Stress Management Techniques	Pelajari stress management techniques dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	469	lifestyle	["productivity","wellness","self-improvement"]	id	360p	2322	162	9	38	4	t	t	f	f	t	all	2025-04-30 16:02:58.224+07	\N	2025-08-13 18:08:42.621+07	178	37.95	9.14	\N	20816715	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"desktop","processingTime":75,"originalFileName":"stress_management_techniques.mp4","compressionRatio":0.7,"bitrate":1214}	2025-04-24 21:18:09.805+07	2025-05-02 15:38:53.224+07	\N
d9489213-9ab3-46d0-8503-35f6e2b218d7	Vue 3 Composition API Deep Dive - Part 1	Tutorial vue 3 composition api deep dive - part 1 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	2333	web-development	["html","css"]	id	720p	17174	366	11	82	22	t	t	f	t	f	all	2025-07-06 11:28:34.935+07	\N	2025-08-23 01:30:53.545+07	1681	72.05	4.45	\N	122688518	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"mobile","processingTime":126,"originalFileName":"vue_3_composition_api_deep_dive_part_1.mp4","compressionRatio":0.8,"bitrate":3287}	2025-07-04 18:22:13.586+07	2025-07-08 21:14:49.682+07	\N
f8008edb-12ad-4f2a-b221-a217f33d1a0b	Professional Makeup Techniques	Tutorial professional makeup techniques step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	396	beauty	["cosmetics","skincare","makeup"]	id	1080p	4449	187	26	58	3	f	t	f	f	t	all	2024-10-02 20:22:23.458+07	\N	2025-07-29 03:31:14.396+07	288	72.73	1.62	\N	46446961	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":140,"originalFileName":"professional_makeup_techniques.mp4","compressionRatio":0.79,"bitrate":3157}	2024-09-30 20:12:46.649+07	2024-10-06 17:54:23.557+07	\N
08bf1efd-00e2-4e9c-aa13-03537653890d	Pandas Data Manipulation	Tutorial pandas data manipulation step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	792	data-science	["analytics","statistics"]	id	720p	369	15	1	1	0	t	t	f	f	t	all	2025-01-22 19:09:35.753+07	\N	2025-08-07 07:59:29.189+07	254	32.07	8.22	\N	119292560	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"desktop","processingTime":144,"originalFileName":"pandas_data_manipulation.mp4","compressionRatio":0.73,"bitrate":1291}	2025-01-16 10:47:58.594+07	2025-01-23 16:35:03.211+07	\N
fde8aab8-e14c-456f-9a64-64ce123346a9	Podcast Creation Guide - Part 2	Tutorial podcast creation guide - part 2 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	896	tutorial	["howto","guide"]	en	1080p	305903	13480	1287	3200	265	t	t	f	f	t	all	2025-07-16 06:57:58.803+07	\N	2025-08-18 12:58:55.059+07	617	68.86	9.61	\N	64264470	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":47,"originalFileName":"podcast_creation_guide_part_2.mp4","compressionRatio":0.57,"bitrate":2366}	2025-07-15 07:23:46.44+07	2025-07-19 02:48:26.211+07	\N
ab872184-ac50-4eba-8118-8288880829ca	Research Methodology Guide	Research Methodology Guide explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	153	education	["academic","study-tips"]	id	720p	867942	87972	6842	7285	1713	t	t	f	f	t	all	2025-03-05 05:31:47.683+07	\N	2025-08-04 10:45:05.135+07	48	31.37	9.59	\N	14573998	H.265	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"desktop","processingTime":88,"originalFileName":"research_methodology_guide.mp4","compressionRatio":0.57,"bitrate":3587}	2025-02-28 15:01:10.721+07	2025-03-06 14:43:48.68+07	\N
e43c5d5d-c259-472c-b384-d1a8e00f815f	C++ Modern Features 2024	Dalam video ini, kita akan membahas c++ modern features 2024. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	649	programming	["java","coding"]	id	1080p	3936	172	22	14	3	t	t	f	f	f	all	2025-02-28 12:49:11.625+07	\N	2025-08-03 09:33:53.406+07	213	32.82	2.12	\N	88093469	H.265	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"web","processingTime":146,"originalFileName":"c_modern_features_2024.mp4","compressionRatio":0.63,"bitrate":3571}	2025-02-25 23:33:34.42+07	2025-03-01 13:40:17.903+07	\N
cebcfb3f-ddcb-4f7d-9e52-ea1f39d71f9d	Ionic Hybrid App Development	Pelajari ionic hybrid app development dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	1234	mobile-development	["android","ios","mobile-app"]	en	720p	4192	200	10	39	13	t	t	f	t	t	all	2025-02-16 21:43:29.963+07	\N	2025-07-25 16:00:48.511+07	409	33.14	6.6	\N	135868756	H.265	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"mobile","processingTime":195,"originalFileName":"ionic_hybrid_app_development.mp4","compressionRatio":0.58,"bitrate":3207}	2025-02-13 21:16:41.609+07	2025-02-21 11:00:09.958+07	\N
ebd9ef47-161e-4251-9415-8ef514204ffb	Work-Life Balance Tips - Part 1	Dalam video ini, kita akan membahas work-life balance tips - part 1. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	921	lifestyle	["self-improvement","productivity","wellness","minimalism","life-tips"]	en	720p	321	11	0	3	0	t	t	f	f	t	all	2025-08-11 17:36:54.375+07	\N	2025-08-15 04:48:28+07	416	45.17	2.93	\N	140831999	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":184,"originalFileName":"worklife_balance_tips_part_1.mp4","compressionRatio":0.85,"bitrate":1025}	2025-08-07 01:59:14.366+07	2025-08-16 01:19:29.424+07	\N
0a3f4c84-4ef4-4c07-ab2a-423f524a4d3a	Ingredient Analysis Guide	Ingredient Analysis Guide - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	371	beauty	["grooming","makeup","cosmetics"]	id	720p	5410	132	6	31	1	t	t	t	f	f	all	2025-02-16 08:25:35.415+07	\N	2025-08-17 21:21:24.821+07	216	58.22	6.29	\N	38472592	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"web","processingTime":105,"originalFileName":"ingredient_analysis_guide.mp4","compressionRatio":0.68,"bitrate":3010}	2025-02-11 20:47:01.015+07	2025-02-18 22:37:20.444+07	\N
6ee87d11-1e77-42b8-9083-d41f7608074a	Blogging for Beginners	Dalam video ini, kita akan membahas blogging for beginners. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	1216	tutorial	["tips","guide","learn"]	en	1080p	2054	196	24	32	2	t	t	f	f	t	all	2025-07-15 11:53:23.298+07	\N	2025-08-16 22:42:31.197+07	911	74.92	2.41	\N	196805545	H.265	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"desktop","processingTime":53,"originalFileName":"blogging_for_beginners.mp4","compressionRatio":0.64,"bitrate":1927}	2025-07-11 14:36:02.054+07	2025-07-16 02:28:15.17+07	\N
f6f50367-0728-4868-85b4-b30a5da23ab3	Injury Prevention Exercises	Dalam video ini, kita akan membahas injury prevention exercises. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	469	fitness	["cardio","workout","bodybuilding","health","exercise"]	id	1080p	97	4	0	0	0	t	t	f	f	t	all	2025-01-11 05:40:34.468+07	\N	2025-08-18 21:16:35.777+07	324	69.08	2.89	\N	50563079	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"desktop","processingTime":118,"originalFileName":"injury_prevention_exercises.mp4","compressionRatio":0.76,"bitrate":1179}	2025-01-08 07:55:11.941+07	2025-01-12 01:28:36.395+07	\N
f8a9614a-e325-46a4-bcc7-80b83285a492	Web Performance Optimization Masterclass	Tutorial web performance optimization masterclass step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	2420	web-development	["javascript","nodejs"]	en	1080p	89	5	0	1	0	t	t	f	f	f	all	2024-12-05 14:03:34.892+07	\N	2025-07-30 06:53:15.565+07	1065	44.01	9.83	\N	133944976	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":52,"originalFileName":"web_performance_optimization_masterclass.mp4","compressionRatio":0.59,"bitrate":3466}	2024-11-30 11:16:29.379+07	2024-12-07 04:33:51.863+07	\N
0d01b387-a78b-415a-82a3-34e24472611f	Kotlin Android Programming	Kotlin Android Programming - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	747	mobile-development	["mobile-app","android","ios","flutter","react-native","cross-platform"]	en	480p	300706	8764	328	2400	336	t	t	f	f	f	all	2025-03-30 05:43:46.999+07	\N	2025-08-02 17:00:01.249+07	548	73.36	7.66	\N	80696299	VP9	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":118,"originalFileName":"kotlin_android_programming.mp4","compressionRatio":0.59,"bitrate":2140}	2025-03-26 23:00:56.082+07	2025-04-02 20:08:11.563+07	\N
d5942373-4f89-4162-8068-6b16cc6becc8	Nutrition for Athletes	Tutorial nutrition for athletes step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	119	fitness	["health","cardio"]	en	480p	505	39	3	3	1	t	t	f	f	f	all	2025-05-06 18:10:42.017+07	\N	2025-08-20 12:15:10.691+07	59	49.58	3.54	\N	19286227	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"desktop","processingTime":37,"originalFileName":"nutrition_for_athletes.mp4","compressionRatio":0.63,"bitrate":1344}	2025-04-30 00:24:37.145+07	2025-05-09 02:45:44.317+07	\N
2cd7d94e-9a9f-4b13-984d-ec6338686521	Educational Technology Tools	Educational Technology Tools - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/ScMzIvxBSi4	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	2099	education	["study-tips","academic"]	id	1080p	21019	1265	181	360	45	t	t	f	f	t	all	2025-04-08 03:50:02.069+07	\N	2025-08-20 08:57:15.528+07	747	35.59	9.43	\N	303544660	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"web","processingTime":145,"originalFileName":"educational_technology_tools.mp4","compressionRatio":0.84,"bitrate":2474}	2025-04-02 08:34:19.475+07	2025-04-10 02:38:15.957+07	\N
6b34f1d8-0d8f-43ff-a41e-aa17e64a09b7	Mobile App Security Best Practices	Tutorial mobile app security best practices step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	1263	mobile-development	["android","react-native","mobile-app","flutter"]	en	360p	36458	3592	532	709	206	t	t	f	f	t	all	2024-10-05 15:56:53.853+07	\N	2025-08-03 07:45:08.165+07	402	31.83	4.84	\N	53660973	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":168,"originalFileName":"mobile_app_security_best_practices.mp4","compressionRatio":0.78,"bitrate":2002}	2024-10-05 09:20:15.412+07	2024-10-07 16:01:28.359+07	\N
c545afb0-4955-4fd3-a904-151099299413	Budget Planning Strategies	Pelajari budget planning strategies dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	390	lifestyle	["minimalism","self-improvement","life-tips","wellness"]	en	720p	337	10	0	1	0	t	t	f	t	t	all	2025-01-12 22:28:48.096+07	2025-09-05 01:03:22.137+07	2025-08-22 19:48:20.141+07	237	60.77	3.65	\N	61158695	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":92,"originalFileName":"budget_planning_strategies.mp4","compressionRatio":0.9,"bitrate":3937}	2025-01-06 09:01:04.98+07	2025-01-14 08:19:54.42+07	\N
f8023c56-630b-44a7-824e-def8ef984d9b	Flutter Widget Development - Part 1	Flutter Widget Development - Part 1 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	839	mobile-development	["react-native","mobile-app","cross-platform"]	id	1080p	2859	237	21	48	9	t	f	f	f	t	all	2025-05-08 13:30:32.857+07	\N	2025-07-30 17:02:34.844+07	340	40.52	6.76	\N	34506484	VP9	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":193,"originalFileName":"flutter_widget_development_part_1.mp4","compressionRatio":0.72,"bitrate":3473}	2025-05-03 22:14:23.224+07	2025-05-08 23:34:16.209+07	\N
7172d9e9-c4c6-4785-befe-8b9f3aa2f258	Algorithm Design Patterns - Part 5	Pelajari algorithm design patterns - part 5 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	2056	programming	["python","java","development"]	en	1080p	26313	825	66	221	41	t	t	f	f	t	all	2025-04-04 21:19:18.426+07	\N	2025-07-25 17:06:23.563+07	649	31.57	9.2	\N	141416361	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"mobile","processingTime":110,"originalFileName":"algorithm_design_patterns_part_5.mp4","compressionRatio":0.83,"bitrate":3715}	2025-04-04 17:29:35.021+07	2025-04-08 10:50:39.299+07	\N
3e073dee-f946-46a4-a002-e585a973a840	Self-Care Routine Ideas - Part 3	Tutorial self-care routine ideas - part 3 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	1732	lifestyle	["self-improvement","life-tips","minimalism","wellness","productivity"]	id	720p	444	44	1	8	2	t	t	f	t	t	all	2025-05-18 18:07:16.702+07	\N	2025-07-28 18:36:59.834+07	1252	72.29	6.88	\N	121403924	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"mobile","processingTime":157,"originalFileName":"selfcare_routine_ideas_part_3.mp4","compressionRatio":0.82,"bitrate":2549}	2025-05-13 22:58:32.52+07	2025-05-23 09:07:38.138+07	\N
4b475e10-05c3-4729-9157-3da5c936b8dc	Recovery and Rest Importance - Part 2	Recovery and Rest Importance - Part 2 - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/fJ9rUzIMcZQ	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	888	fitness	["training","cardio"]	id	1080p	362650	6095	511	878	209	t	t	f	f	f	all	2024-10-26 05:48:39.305+07	\N	2025-07-30 15:09:15.997+07	695	78.27	5.12	\N	59968273	VP9	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":70,"originalFileName":"recovery_and_rest_importance_part_2.mp4","compressionRatio":0.58,"bitrate":1417}	2024-10-25 19:21:56.842+07	2024-10-30 03:19:28.909+07	\N
1a26c808-d738-4ef4-8f6e-beee34aa310c	Women's Health Topics	Women's Health Topics - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	1972	health	["medical","wellness","mental-health","healthy-living","nutrition"]	id	720p	125	7	0	1	0	t	t	f	f	f	all	2024-11-03 16:35:09.423+07	\N	2025-08-11 03:15:27.209+07	540	27.38	9.21	\N	287055901	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"mobile","processingTime":122,"originalFileName":"womens_health_topics.mp4","compressionRatio":0.59,"bitrate":3554}	2024-11-01 13:55:39.146+07	2024-11-04 04:51:11.777+07	\N
5fdefc15-80f6-4a53-8a3b-91148b10e036	React 18 Server Components Tutorial	Tutorial react 18 server components tutorial step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	845	web-development	["backend","css","react","frontend","html"]	ja	720p	38837	3823	503	801	206	t	t	f	f	t	all	2024-09-26 02:46:58.303+07	\N	2025-08-14 14:40:05.876+07	328	38.82	8.72	\N	103536426	H.264	7f10f633-1ed6-453a-91a8-4db228c0a68e	{"uploadedFrom":"desktop","processingTime":34,"originalFileName":"react_18_server_components_tutorial.mp4","compressionRatio":0.67,"bitrate":3902}	2024-09-21 16:14:20.457+07	2024-09-29 06:41:35.816+07	\N
3a652d00-738a-405b-a8ff-0be97b6a2bc5	Eyeshadow Blending Techniques - Part 2	Tutorial eyeshadow blending techniques - part 2 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	546	beauty	["skincare","makeup","self-care","grooming"]	id	720p	307	14	1	1	0	t	t	f	f	t	all	2025-03-15 15:52:51.998+07	\N	2025-07-27 17:57:48.952+07	192	35.16	5.09	\N	32313483	VP9	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":156,"originalFileName":"eyeshadow_blending_techniques_part_2.mp4","compressionRatio":0.58,"bitrate":2665}	2025-03-13 17:59:16.236+07	2025-03-17 11:38:38.661+07	\N
5bd7d2e6-d798-4aa4-a374-5949b29dc3bf	Progressive Web Apps PWA	Tutorial progressive web apps pwa step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/2Vv-BfVoq4g	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	3034	mobile-development	["react-native","flutter","ios","android"]	en	480p	261	27	1	3	1	t	t	f	t	t	all	2024-10-12 05:41:03.752+07	\N	2025-07-31 03:22:34.347+07	2124	70.01	8.56	\N	354438698	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":88,"originalFileName":"progressive_web_apps_pwa.mp4","compressionRatio":0.77,"bitrate":1284}	2024-10-12 03:30:20.353+07	2024-10-12 12:01:24.022+07	\N
3cf94580-4e6c-4b4d-be54-0c85533c594a	Hair Care and Styling Tips	Tutorial hair care and styling tips step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	273	beauty	["skincare","makeup","beauty-tips"]	ja	1080p	50641	3252	386	660	99	t	f	f	f	t	all	2025-05-12 20:55:16.706+07	\N	2025-08-17 22:33:44.758+07	209	76.56	3.65	\N	13080695	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":136,"originalFileName":"hair_care_and_styling_tips.mp4","compressionRatio":0.66,"bitrate":1199}	2025-05-09 20:22:18.843+07	2025-05-17 15:41:20.27+07	\N
65ca28e9-2fd1-499b-94b1-c304365c93d9	Flutter State Management	Flutter State Management explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	138	mobile-development	["mobile-app","react-native","cross-platform","android"]	en	720p	122	4	0	1	0	t	t	f	f	t	all	2025-07-02 04:29:01.19+07	\N	2025-07-28 17:37:44.373+07	79	57.25	6.46	\N	11603821	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"web","processingTime":98,"originalFileName":"flutter_state_management.mp4","compressionRatio":0.77,"bitrate":1991}	2025-07-01 17:42:41.353+07	2025-07-05 20:24:48.664+07	\N
7c4ea69b-d6d8-4728-b137-c380521fcd31	Push Notifications Implementation - Part 5	Tutorial push notifications implementation - part 5 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	120	mobile-development	["android","cross-platform","ios","flutter","mobile-app","react-native"]	en	1080p	262	10	0	1	0	t	t	f	f	t	all	2025-03-14 00:35:50.98+07	\N	2025-07-30 13:27:02.466+07	68	56.67	7.49	\N	8680000	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":177,"originalFileName":"push_notifications_implementation_part_5.mp4","compressionRatio":0.58,"bitrate":3172}	2025-03-10 10:49:44.767+07	2025-03-17 23:04:01.988+07	\N
13f9f2af-ba92-4385-bfd1-ef05763bffb2	Weight Loss Exercise Plans	Tutorial weight loss exercise plans step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	159	fitness	["bodybuilding","training","gym","exercise"]	id	720p	489	16	1	3	0	t	t	f	f	t	all	2024-11-19 18:20:53.412+07	\N	2025-08-06 14:30:46.166+07	127	79.87	7.14	\N	17618605	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":28,"originalFileName":"weight_loss_exercise_plans.mp4","compressionRatio":0.63,"bitrate":2857}	2024-11-19 02:29:43.357+07	2024-11-21 04:51:32.609+07	\N
a198d1ef-b89d-4933-a0db-6845b55fff94	Heart Health Exercise Guide	Pelajari heart health exercise guide dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/2Vv-BfVoq4g	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	391	health	["healthy-living","wellness","mental-health","nutrition","medical"]	id	1080p	230	6	0	0	0	t	t	f	f	f	all	2025-01-19 08:21:06.123+07	\N	2025-08-15 09:56:43.547+07	162	41.43	3.94	\N	34167099	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":114,"originalFileName":"heart_health_exercise_guide.mp4","compressionRatio":0.63,"bitrate":1855}	2025-01-17 07:36:12.852+07	2025-01-22 18:21:55.993+07	\N
0d2fc069-0544-43c0-a2ed-eee07a131050	Public Speaking Confidence	Pelajari public speaking confidence dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	284	education	["academic","skills","learning","study-tips"]	id	1080p	3046	162	19	48	5	t	t	f	f	f	all	2025-06-15 20:44:08.898+07	\N	2025-08-22 11:59:24.231+07	77	27.11	7.63	\N	12227369	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"mobile","processingTime":196,"originalFileName":"public_speaking_confidence.mp4","compressionRatio":0.71,"bitrate":1320}	2025-06-15 10:55:37.438+07	2025-06-17 01:30:08.721+07	\N
b112e4f1-5dc6-4cc7-ac68-322b5f70e392	Memory Improvement Techniques	Memory Improvement Techniques explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	276	education	["academic","teaching"]	en	1080p	241	21	1	3	1	t	t	f	f	f	all	2025-03-24 23:29:54.429+07	\N	2025-07-30 19:30:49.505+07	217	78.62	3.75	\N	42095990	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"desktop","processingTime":183,"originalFileName":"memory_improvement_techniques.mp4","compressionRatio":0.69,"bitrate":2866}	2025-03-18 09:16:40.101+07	2025-03-28 14:57:55.103+07	\N
e1c8841d-ceda-4f97-be87-b05e052fa343	Webpack 5 Module Federation - Part 3	Dalam video ini, kita akan membahas webpack 5 module federation - part 3. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	366	web-development	["react","backend","javascript","nodejs","html"]	id	1080p	128	3	0	0	0	t	f	f	t	f	all	2024-10-06 22:40:50.755+07	\N	2025-08-16 12:43:14.158+07	153	41.8	9.6	\N	55516699	H.265	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"mobile","processingTime":158,"originalFileName":"webpack_5_module_federation_part_3.mp4","compressionRatio":0.84,"bitrate":3175}	2024-09-30 16:44:57.002+07	2024-10-10 17:49:11.902+07	\N
e736e565-e1e6-4e26-88ab-0214b43d950e	TensorFlow 2.0 Complete Course - Part 3	Pelajari tensorflow 2.0 complete course - part 3 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	612	data-science	["ai","machine-learning"]	id	720p	8194	803	77	131	19	t	t	t	f	t	all	2025-01-26 23:46:08.157+07	\N	2025-08-17 15:01:15.54+07	172	28.1	1.47	\N	65777451	H.264	78ba8fbb-27bf-419f-a97a-bfdfdbc6a3a7	{"uploadedFrom":"web","processingTime":53,"originalFileName":"tensorflow_20_complete_course_part_3.mp4","compressionRatio":0.79,"bitrate":2707}	2025-01-22 13:48:24.891+07	2025-01-30 14:45:49.14+07	\N
54b91d45-4615-4768-826c-5ff99a477eae	Home Gym Setup Guide - Part 5	Pelajari home gym setup guide - part 5 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	722	fitness	["exercise","training","health","bodybuilding"]	id	1440p	346	33	1	5	1	t	t	f	f	f	all	2025-03-25 10:25:33.761+07	\N	2025-08-03 14:43:36.305+07	502	69.53	2.52	\N	94913676	H.264	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"mobile","processingTime":179,"originalFileName":"home_gym_setup_guide_part_5.mp4","compressionRatio":0.88,"bitrate":2119}	2025-03-22 16:29:04.564+07	2025-03-28 11:21:01.609+07	\N
057fb4cb-2d94-4cfd-bf44-3200e391c226	GraphQL API with Apollo Server	GraphQL API with Apollo Server explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/ScMzIvxBSi4	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	710	web-development	["javascript","fullstack","react"]	en	720p	46	3	0	0	0	f	t	t	f	f	13+	2025-04-23 16:44:42.945+07	\N	2025-08-05 19:42:48.913+07	394	55.49	7.9	\N	44491891	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":154,"originalFileName":"graphql_api_with_apollo_server.mp4","compressionRatio":0.73,"bitrate":3059}	2025-04-19 16:20:04.573+07	2025-04-28 15:17:40.327+07	\N
1a6d420a-23db-40c8-9d20-498656e7c3cc	Home Organization Hacks	Pelajari home organization hacks dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	1757	lifestyle	["self-improvement","productivity","wellness","life-tips","minimalism"]	id	480p	24086	1263	121	205	88	t	t	f	f	t	all	2024-12-17 17:20:59.106+07	\N	2025-08-16 03:27:28.254+07	1100	62.61	4.17	\N	231656732	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":109,"originalFileName":"home_organization_hacks.mp4","compressionRatio":0.7,"bitrate":3830}	2024-12-16 23:03:12.882+07	2024-12-20 08:01:55.574+07	\N
c0349e82-32c9-45ca-9084-d58fee12d83a	HIIT Training Methods - Part 5	Tutorial hiit training methods - part 5 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	73	fitness	["health","workout","bodybuilding","exercise","cardio","gym"]	id	480p	1123	65	5	17	3	t	t	t	f	t	all	2025-05-20 04:57:36.124+07	\N	2025-08-14 14:55:38.946+07	20	27.4	7.19	\N	6337252	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"mobile","processingTime":124,"originalFileName":"hiit_training_methods_part_5.mp4","compressionRatio":0.55,"bitrate":1564}	2025-05-19 00:31:40.105+07	2025-05-20 16:29:46.19+07	\N
6d8ecac0-5112-4d09-a909-3c08565d9fb8	Heart Health Exercise Guide - Part 5	Dalam video ini, kita akan membahas heart health exercise guide - part 5. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	195	health	["healthy-living","medical","wellness"]	id	1080p	372	29	4	8	0	t	t	f	f	t	all	2024-12-20 01:14:57.991+07	\N	2025-08-22 15:57:51.188+07	150	76.92	5.12	\N	24247898	H.265	6262077e-05e4-4b8d-86c1-84b29fcfe254	{"uploadedFrom":"mobile","processingTime":167,"originalFileName":"heart_health_exercise_guide_part_5.mp4","compressionRatio":0.79,"bitrate":1228}	2024-12-19 21:24:29.117+07	2024-12-21 16:47:05.387+07	\N
f7f73f18-adda-49ba-bc0c-f69d0fae4c45	Push Notifications Implementation - Part 4	Push Notifications Implementation - Part 4 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	1218	mobile-development	["ios","android"]	id	720p	111	11	1	2	0	t	f	f	t	f	all	2025-04-18 21:48:24.192+07	\N	2025-08-18 11:57:19.941+07	536	44.01	2.25	\N	154174805	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":166,"originalFileName":"push_notifications_implementation_part_4.mp4","compressionRatio":0.59,"bitrate":3566}	2025-04-17 21:28:57.099+07	2025-04-21 01:05:02.966+07	\N
9b688f26-7199-48db-a8ce-de8613e69fff	Functional Programming Concepts	Dalam video ini, kita akan membahas functional programming concepts. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	726	programming	["coding","development"]	id	720p	804893	71737	5917	6358	1991	f	t	f	f	t	all	2025-01-13 06:34:38.432+07	\N	2025-08-10 03:21:36.155+07	228	31.4	9.8	\N	116198789	H.264	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":91,"originalFileName":"functional_programming_concepts.mp4","compressionRatio":0.72,"bitrate":3768}	2025-01-09 22:12:25.627+07	2025-01-17 07:33:36.422+07	\N
e7104bbb-647b-48f1-8018-3b48d578f8d0	3D Modeling with Blender	Dalam video ini, kita akan membahas 3d modeling with blender. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	328	tutorial	["guide","beginner","tutorial","howto","advanced"]	id	720p	269	4	0	1	0	t	t	f	f	t	all	2024-11-10 22:49:27.3+07	\N	2025-08-01 18:04:56.788+07	216	65.85	7.89	\N	22158926	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"mobile","processingTime":128,"originalFileName":"3d_modeling_with_blender.mp4","compressionRatio":0.61,"bitrate":3567}	2024-11-07 13:47:28.028+07	2024-11-14 21:26:40.732+07	\N
ed74a6df-2532-42b2-8690-abc0b629638a	Healthy Cooking Recipes	Healthy Cooking Recipes explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	111	lifestyle	["wellness","self-improvement","productivity","life-tips","minimalism"]	id	1080p	9711	1137	117	265	46	t	t	f	t	f	all	2025-07-14 17:13:54.013+07	\N	2025-08-11 05:41:11.369+07	46	41.44	4.17	\N	9199470	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"mobile","processingTime":90,"originalFileName":"healthy_cooking_recipes.mp4","compressionRatio":0.64,"bitrate":1124}	2025-07-08 12:45:37.353+07	2025-07-15 21:06:47.585+07	\N
7b3de457-2a9f-4758-9539-72277913e421	Weight Loss Exercise Plans - Part 1	Weight Loss Exercise Plans - Part 1 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	881	fitness	["workout","training","exercise"]	id	480p	194286	18128	2162	2516	652	f	t	f	f	t	all	2025-03-05 06:19:50.284+07	\N	2025-08-10 08:05:46.258+07	587	66.63	4.52	\N	81913937	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"desktop","processingTime":188,"originalFileName":"weight_loss_exercise_plans_part_1.mp4","compressionRatio":0.59,"bitrate":2360}	2025-02-27 14:35:47.355+07	2025-03-05 13:55:15.263+07	\N
885941ec-81e2-4c5f-bca8-314d7ca7e7e4	TypeScript Advanced Types Workshop	Tutorial typescript advanced types workshop step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/dQw4w9WgXcQ	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	62	web-development	["nodejs","fullstack","javascript","backend","html"]	id	720p	193	13	1	2	0	t	f	f	f	t	16+	2024-09-16 05:36:52.953+07	\N	2025-08-21 14:37:18.809+07	47	75.81	8.22	\N	3906065	H.265	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":148,"originalFileName":"typescript_advanced_types_workshop.mp4","compressionRatio":0.73,"bitrate":3315}	2024-09-09 20:50:33.285+07	2024-09-17 10:11:43.202+07	\N
af1ab685-3cb7-4054-8322-b69abc70b04c	Data Pipeline Architecture - Part 2	Pelajari data pipeline architecture - part 2 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	3457	data-science	["statistics","analytics"]	en	1080p	4424	368	35	47	11	t	t	f	f	t	all	2025-06-04 18:46:26.053+07	\N	2025-08-05 00:54:17.537+07	1937	56.03	1.65	\N	333654981	H.264	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"mobile","processingTime":85,"originalFileName":"data_pipeline_architecture_part_2.mp4","compressionRatio":0.85,"bitrate":1657}	2025-06-04 11:40:32.69+07	2025-06-07 18:39:00.883+07	\N
2c75e162-b410-4699-8a97-f20349c53d35	Injury Prevention Exercises - Part 1	Injury Prevention Exercises - Part 1 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/9xwazD5SyVg	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	1023	fitness	["training","workout"]	en	720p	361486	22475	2453	6266	356	t	t	f	f	t	all	2024-08-31 02:12:29.043+07	\N	2025-07-27 23:38:13.932+07	459	44.87	2.93	\N	68239188	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":28,"originalFileName":"injury_prevention_exercises_part_1.mp4","compressionRatio":0.59,"bitrate":3308}	2024-08-25 06:22:16.458+07	2024-09-02 14:47:32.31+07	\N
074e9a12-45ce-4277-b732-8853248965ce	YouTube Channel Growth - Part 2	Dalam video ini, kita akan membahas youtube channel growth - part 2. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	416	tutorial	["howto","guide","tips","tutorial"]	en	480p	19475	640	20	162	32	t	t	t	t	t	all	2025-07-21 07:37:02.367+07	\N	2025-08-09 07:03:38.866+07	213	51.2	6.42	\N	62805547	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":141,"originalFileName":"youtube_channel_growth_part_2.mp4","compressionRatio":0.67,"bitrate":3791}	2025-07-19 23:20:51.355+07	2025-07-23 09:59:01.526+07	\N
f01775b3-91bd-4364-84c5-42db5f72416e	Kotlin Android Programming - Part 3	Kotlin Android Programming - Part 3 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	287	mobile-development	["android","ios","flutter","react-native","cross-platform","mobile-app"]	en	480p	32338	2952	177	380	60	t	t	f	f	t	all	2024-10-11 02:02:07.896+07	\N	2025-08-18 13:09:05.011+07	200	69.69	9.67	\N	38453822	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"mobile","processingTime":80,"originalFileName":"kotlin_android_programming_part_3.mp4","compressionRatio":0.56,"bitrate":1057}	2024-10-08 21:05:44.954+07	2024-10-12 17:16:52.882+07	\N
991b1075-5044-46e6-993c-1b089df8d99b	Machine Learning with Python - Part 4	Pelajari machine learning with python - part 4 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/kJQP7kiw5Fk	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	2054	data-science	["statistics","machine-learning"]	id	720p	1481	44	4	8	0	t	t	t	f	t	all	2025-03-11 00:10:09.178+07	\N	2025-08-14 07:37:52.694+07	1302	63.39	1.43	\N	323973250	VP9	aad7e27c-5693-44ce-8998-57d874074af7	{"uploadedFrom":"web","processingTime":197,"originalFileName":"machine_learning_with_python_part_4.mp4","compressionRatio":0.56,"bitrate":3497}	2025-03-04 08:02:13.901+07	2025-03-14 07:32:24.8+07	\N
121e6498-4a07-49b8-89e5-fcd029ac724e	Software Architecture Patterns	Software Architecture Patterns explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/L_jWHffIx5E	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	733	programming	["coding","development","clean-code"]	en	720p	261570	27845	3592	7521	532	t	f	f	f	f	all	2025-01-02 14:51:54.029+07	\N	2025-08-18 11:39:15.25+07	301	41.06	6.64	\N	67902597	VP9	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"desktop","processingTime":49,"originalFileName":"software_architecture_patterns.mp4","compressionRatio":0.81,"bitrate":2179}	2025-01-01 18:20:40.194+07	2025-01-06 02:33:06.255+07	\N
25d8502d-ce26-4a84-a0a1-1fbb56242a53	Mobile App Security Best Practices - Part 4	Dalam video ini, kita akan membahas mobile app security best practices - part 4. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	3109	mobile-development	["react-native","cross-platform"]	en	720p	341	6	0	1	0	t	t	f	f	f	all	2024-10-09 18:16:22.578+07	\N	2025-07-26 20:54:28.533+07	1891	60.82	8.18	\N	448572572	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"web","processingTime":125,"originalFileName":"mobile_app_security_best_practices_part_4.mp4","compressionRatio":0.62,"bitrate":1446}	2024-10-03 09:44:18.321+07	2024-10-10 06:19:36.481+07	\N
2a5a88fc-49bd-4cb8-a90a-46d5597501ea	Educational Technology Tools - Part 4	Dalam video ini, kita akan membahas educational technology tools - part 4. Tutorial lengkap yang mudah diikuti untuk pemula maupun yang sudah berpengalaman. Jangan lupa like dan subscribe untuk konten serupa!	https://www.youtube.com/embed/nfWlot6h_JM	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	269	education	["teaching","skills","knowledge","academic","study-tips"]	id	720p	3732	108	14	29	1	t	t	f	f	t	all	2025-05-11 19:55:04.298+07	\N	2025-08-19 21:20:41.942+07	98	36.43	5.95	\N	24572727	H.265	e06af6c1-f50b-415e-bc0e-cde2656ad5ee	{"uploadedFrom":"web","processingTime":146,"originalFileName":"educational_technology_tools_part_4.mp4","compressionRatio":0.86,"bitrate":1717}	2025-05-08 04:18:37.033+07	2025-05-13 22:41:31.05+07	\N
9503a7c1-67cd-4162-afc2-f39f745c04ad	Skincare for Different Skin Types	Pelajari skincare for different skin types dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/ZXsQAXx_ao0	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	3417	beauty	["beauty-tips","grooming"]	id	720p	29749	1360	192	355	14	t	t	f	f	t	all	2024-10-05 14:08:07.142+07	\N	2025-08-20 08:56:15.971+07	2642	77.32	6.05	\N	437538074	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"desktop","processingTime":23,"originalFileName":"skincare_for_different_skin_types.mp4","compressionRatio":0.6,"bitrate":3245}	2024-10-02 20:50:48.156+07	2024-10-10 07:05:50.047+07	\N
eaa256b9-d37d-4f6b-92d8-b15053b18858	Educational Technology Tools - Part 3	Pelajari educational technology tools - part 3 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	119	education	["skills","academic","knowledge"]	id	720p	509	34	3	9	0	t	t	f	f	t	all	2025-06-03 14:59:59.8+07	\N	2025-08-03 01:23:52.903+07	85	71.43	7.58	\N	12380955	VP9	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":60,"originalFileName":"educational_technology_tools_part_3.mp4","compressionRatio":0.8,"bitrate":3787}	2025-05-28 19:42:28.517+07	2025-06-07 04:37:56.917+07	\N
372accb5-2302-4c49-802b-496a83eafade	Push Notifications Implementation	Push Notifications Implementation - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	67	mobile-development	["mobile-app","android"]	id	480p	565	56	3	12	3	t	t	f	f	t	16+	2025-02-21 13:01:12.329+07	\N	2025-07-26 17:50:33.32+07	51	76.12	2.38	\N	7509745	H.264	3e0594aa-e52d-47a5-b5af-3ebb86f04060	{"uploadedFrom":"web","processingTime":144,"originalFileName":"push_notifications_implementation.mp4","compressionRatio":0.69,"bitrate":1290}	2025-02-20 14:11:37.901+07	2025-02-23 05:09:11.599+07	\N
77f5af40-e8f7-44cf-8746-fa8498be5ad5	Rust Memory Safety Fundamentals - Part 4	Pelajari rust memory safety fundamentals - part 4 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	177	programming	["development","clean-code","java","algorithms","python"]	id	1080p	3662	136	14	18	8	t	t	f	f	t	all	2025-06-21 23:15:37.45+07	\N	2025-07-27 01:45:21.165+07	119	67.23	1.57	\N	15848027	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":61,"originalFileName":"rust_memory_safety_fundamentals_part_4.mp4","compressionRatio":0.67,"bitrate":3747}	2025-06-19 08:43:12.307+07	2025-06-26 16:18:45.816+07	\N
3823a262-8ae9-47a7-807d-336440224c0a	MLOps Production Deployment - Part 3	Tutorial mlops production deployment - part 3 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/jNQXAC9IVRw	https://img.youtube.com/vi/kJQP7kiw5Fk/maxresdefault.jpg	953	data-science	["statistics","visualization","analytics","python","ai","machine-learning"]	id	1080p	2975	64	8	6	4	t	t	f	t	f	all	2025-06-13 05:59:28.025+07	\N	2025-08-13 21:02:31.41+07	512	53.73	4.94	\N	134786435	H.265	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":42,"originalFileName":"mlops_production_deployment_part_3.mp4","compressionRatio":0.84,"bitrate":2949}	2025-06-10 20:58:04.599+07	2025-06-17 02:24:21.713+07	\N
24b837f2-eb2b-4d5b-b9a3-9ae943660217	Swimming Technique Guide - Part 1	Swimming Technique Guide - Part 1 explained dengan cara yang mudah dipahami. Video tutorial yang detail dan terstruktur. Cocok untuk belajar mandiri atau referensi.	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/9xwazD5SyVg/maxresdefault.jpg	217	fitness	["bodybuilding","training"]	id	1080p	384	21	0	5	1	f	t	f	f	t	all	2024-11-11 21:49:03.295+07	\N	2025-08-01 18:24:43.273+07	146	67.28	6.35	\N	20102758	H.264	3092405f-8950-49c9-b1ed-d85a34e9ea23	{"uploadedFrom":"web","processingTime":113,"originalFileName":"swimming_technique_guide_part_1.mp4","compressionRatio":0.67,"bitrate":1475}	2024-11-07 08:52:26.394+07	2024-11-14 00:53:37.816+07	\N
6fd1d4bf-49ab-4f84-8cb8-f9c497b777a3	Digital Detox Challenge	Pelajari digital detox challenge dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/L_jWHffIx5E/maxresdefault.jpg	1689	lifestyle	["self-improvement","productivity","life-tips","wellness"]	id	480p	470	34	2	7	0	t	t	t	t	f	all	2025-07-19 18:16:05.161+07	\N	2025-08-05 18:02:40.24+07	832	49.26	7.99	\N	197394471	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"desktop","processingTime":136,"originalFileName":"digital_detox_challenge.mp4","compressionRatio":0.7,"bitrate":2438}	2025-07-17 10:56:49.764+07	2025-07-20 11:54:58.608+07	\N
a9acde4a-041a-4d4b-955a-d857fefbe749	Node.js Event Loop Explained - Part 4	Pelajari node.js event loop explained - part 4 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/QH2-TGUlwu4	https://img.youtube.com/vi/hFmPveauxd0/maxresdefault.jpg	308	programming	["software","clean-code","java","coding"]	id	480p	1386687	122144	10002	17267	7560	t	t	f	t	t	13+	2024-10-24 01:36:59.4+07	\N	2025-08-21 22:01:28.662+07	90	29.22	3.23	\N	33698262	H.264	03a0977b-3ae5-491f-bd77-3cec98f336a7	{"uploadedFrom":"mobile","processingTime":35,"originalFileName":"nodejs_event_loop_explained_part_4.mp4","compressionRatio":0.71,"bitrate":2812}	2024-10-18 16:39:19.303+07	2024-10-26 04:14:16.654+07	\N
3c5d0454-ca9b-4779-b46b-b5034c59e462	CrossFit Training Basics - Part 3	Pelajari crossfit training basics - part 3 dari dasar hingga mahir. Video ini dilengkapi dengan tips dan trik yang jarang diketahui orang. Perfect untuk self-learning!	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	169	fitness	["training","exercise","bodybuilding"]	en	720p	399437	5874	316	1093	113	t	t	f	f	t	all	2025-05-03 03:27:40.108+07	\N	2025-07-31 01:59:43.147+07	58	34.32	2.35	\N	23467082	H.264	2b7729a3-0631-413d-a7e3-75679bfda256	{"uploadedFrom":"mobile","processingTime":194,"originalFileName":"crossfit_training_basics_part_3.mp4","compressionRatio":0.89,"bitrate":1242}	2025-04-26 18:05:57.902+07	2025-05-05 21:57:38.895+07	\N
4471070c-0508-4f3e-8108-d937df70378f	TypeScript Advanced Types Workshop - Part 5	Tutorial typescript advanced types workshop - part 5 step by step dengan contoh praktis. Video ini cocok untuk semua level, dari pemula hingga advanced. Subscribe untuk update video terbaru!	https://www.youtube.com/embed/6stlCkUDG_s	https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg	683	web-development	["fullstack","nodejs","frontend","react"]	id	720p	3231	163	14	39	8	t	t	f	f	f	all	2025-04-15 23:39:44.205+07	\N	2025-08-21 22:52:59.15+07	496	72.62	1.99	\N	78006505	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"mobile","processingTime":171,"originalFileName":"typescript_advanced_types_workshop_part_5.mp4","compressionRatio":0.85,"bitrate":3940}	2025-04-12 05:20:20.163+07	2025-04-17 20:52:22.842+07	\N
57aa7c98-d1f8-4b07-8a8c-5dce5e9d00a0	Posture Correction Exercises	Posture Correction Exercises - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/Ke90Tje7VS0	https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg	3744	health	["healthy-living","medical","wellness","mental-health","nutrition"]	id	1080p	40661	1528	118	453	62	t	t	f	f	t	all	2025-01-30 18:09:09.518+07	\N	2025-08-18 07:56:55.051+07	1192	31.84	6.01	\N	426244623	H.264	7f10f633-1ed6-453a-91a8-4db228c0a68e	{"uploadedFrom":"web","processingTime":97,"originalFileName":"posture_correction_exercises.mp4","compressionRatio":0.79,"bitrate":1089}	2025-01-24 13:15:07.964+07	2025-02-02 22:48:54.562+07	\N
af2f1eb7-1535-430f-a488-786ca3166a19	GraphQL API with Apollo Server - Part 1	GraphQL API with Apollo Server - Part 1 - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/hFmPveauxd0	https://img.youtube.com/vi/ZXsQAXx_ao0/maxresdefault.jpg	2034	web-development	["react","fullstack","backend","html"]	id	1080p	3155	212	10	25	8	t	t	f	f	t	all	2024-09-22 06:53:15.163+07	\N	2025-08-18 17:33:05.714+07	1458	71.68	5.87	\N	281912169	H.264	108970e7-816a-4d0c-892c-657e0772729c	{"uploadedFrom":"web","processingTime":95,"originalFileName":"graphql_api_with_apollo_server_part_1.mp4","compressionRatio":0.64,"bitrate":3812}	2024-09-17 23:15:47.523+07	2024-09-26 10:44:08.652+07	\N
8f423027-e096-4b2f-b61e-ac9b0e5baa4e	Healthy Aging Strategies - Part 2	Healthy Aging Strategies - Part 2 - panduan komprehensif yang akan membantu Anda memahami konsep-konsep penting. Video ini mencakup teori dan praktek yang bisa langsung diterapkan.	https://www.youtube.com/embed/BBAyRBTfsOU	https://img.youtube.com/vi/fJ9rUzIMcZQ/maxresdefault.jpg	82	health	["wellness","medical","mental-health","nutrition","healthy-living"]	id	720p	3553	199	8	24	8	f	t	f	f	f	16+	2025-08-22 02:04:51.28+07	\N	2025-08-13 12:29:14.234+07	44	53.66	8.94	7.3442487875116775	12964226	H.265	7f10f633-1ed6-453a-91a8-4db228c0a68e	{"uploadedFrom":"mobile","processingTime":153,"originalFileName":"healthy_aging_strategies_part_2.mp4","compressionRatio":0.76,"bitrate":3074}	2025-08-18 10:37:32.931+07	2025-08-24 13:28:56.455+07	\N
\.


--
-- TOC entry 4751 (class 2606 OID 38680)
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- TOC entry 4755 (class 2606 OID 38751)
-- Name: articles articles_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_slug_key UNIQUE (slug);


--
-- TOC entry 4757 (class 2606 OID 38753)
-- Name: articles articles_slug_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_slug_key1 UNIQUE (slug);


--
-- TOC entry 4759 (class 2606 OID 38755)
-- Name: articles articles_slug_key2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_slug_key2 UNIQUE (slug);


--
-- TOC entry 4761 (class 2606 OID 38749)
-- Name: articles articles_slug_key3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_slug_key3 UNIQUE (slug);


--
-- TOC entry 4763 (class 2606 OID 38757)
-- Name: articles articles_slug_key4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_slug_key4 UNIQUE (slug);


--
-- TOC entry 4721 (class 2606 OID 38420)
-- Name: memberships memberships_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_name_key UNIQUE (name);


--
-- TOC entry 4723 (class 2606 OID 38422)
-- Name: memberships memberships_name_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_name_key1 UNIQUE (name);


--
-- TOC entry 4725 (class 2606 OID 38325)
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- TOC entry 4730 (class 2606 OID 38426)
-- Name: memberships memberships_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_slug_key UNIQUE (slug);


--
-- TOC entry 4732 (class 2606 OID 38428)
-- Name: memberships memberships_slug_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_slug_key1 UNIQUE (slug);


--
-- TOC entry 4708 (class 2606 OID 38402)
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- TOC entry 4710 (class 2606 OID 38404)
-- Name: roles roles_name_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key1 UNIQUE (name);


--
-- TOC entry 4712 (class 2606 OID 38305)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4715 (class 2606 OID 38408)
-- Name: roles roles_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_slug_key UNIQUE (slug);


--
-- TOC entry 4717 (class 2606 OID 38410)
-- Name: roles roles_slug_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_slug_key1 UNIQUE (slug);


--
-- TOC entry 4736 (class 2606 OID 38451)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4738 (class 2606 OID 38453)
-- Name: users users_email_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key1 UNIQUE (email);


--
-- TOC entry 4744 (class 2606 OID 38351)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4775 (class 2606 OID 38907)
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- TOC entry 4748 (class 1259 OID 38692)
-- Name: articles_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_created_at ON public.articles USING btree ("createdAt");


--
-- TOC entry 4749 (class 1259 OID 38694)
-- Name: articles_featured; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_featured ON public.articles USING btree (featured);


--
-- TOC entry 4752 (class 1259 OID 38691)
-- Name: articles_published_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_published_at ON public.articles USING btree ("publishedAt");


--
-- TOC entry 4753 (class 1259 OID 38758)
-- Name: articles_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX articles_slug ON public.articles USING btree (slug);


--
-- TOC entry 4764 (class 1259 OID 38690)
-- Name: articles_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_status ON public.articles USING btree (status);


--
-- TOC entry 4765 (class 1259 OID 38759)
-- Name: articles_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_title ON public.articles USING btree (title);


--
-- TOC entry 4766 (class 1259 OID 38688)
-- Name: articles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_user_id ON public.articles USING btree ("userId");


--
-- TOC entry 4767 (class 1259 OID 38693)
-- Name: articles_views_count; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX articles_views_count ON public.articles USING btree ("viewsCount");


--
-- TOC entry 4718 (class 1259 OID 38441)
-- Name: memberships_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX memberships_is_active ON public.memberships USING btree (is_active);


--
-- TOC entry 4719 (class 1259 OID 38444)
-- Name: memberships_is_featured; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX memberships_is_featured ON public.memberships USING btree (is_featured);


--
-- TOC entry 4726 (class 1259 OID 38432)
-- Name: memberships_price; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX memberships_price ON public.memberships USING btree (price);


--
-- TOC entry 4727 (class 1259 OID 38447)
-- Name: memberships_priority; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX memberships_priority ON public.memberships USING btree (priority);


--
-- TOC entry 4728 (class 1259 OID 38429)
-- Name: memberships_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX memberships_slug ON public.memberships USING btree (slug);


--
-- TOC entry 4706 (class 1259 OID 38416)
-- Name: roles_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roles_is_active ON public.roles USING btree (is_active);


--
-- TOC entry 4713 (class 1259 OID 38411)
-- Name: roles_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roles_slug ON public.roles USING btree (slug);


--
-- TOC entry 4733 (class 1259 OID 38372)
-- Name: unique_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_provider_id ON public.users USING btree (provider, provider_id) WHERE (provider_id IS NOT NULL);


--
-- TOC entry 4734 (class 1259 OID 38454)
-- Name: users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email ON public.users USING btree (email);


--
-- TOC entry 4739 (class 1259 OID 38469)
-- Name: users_email_verified_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_email_verified_at ON public.users USING btree (email_verified_at);


--
-- TOC entry 4740 (class 1259 OID 38467)
-- Name: users_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_is_active ON public.users USING btree (is_active);


--
-- TOC entry 4741 (class 1259 OID 38468)
-- Name: users_last_login_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_last_login_at ON public.users USING btree (last_login_at);


--
-- TOC entry 4742 (class 1259 OID 38366)
-- Name: users_membership_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_membership_id ON public.users USING btree (membership_id);


--
-- TOC entry 4745 (class 1259 OID 38370)
-- Name: users_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_provider ON public.users USING btree (provider);


--
-- TOC entry 4746 (class 1259 OID 38371)
-- Name: users_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_provider_id ON public.users USING btree (provider_id);


--
-- TOC entry 4747 (class 1259 OID 38365)
-- Name: users_role_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_role_id ON public.users USING btree (role_id);


--
-- TOC entry 4768 (class 1259 OID 38915)
-- Name: videos_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_category ON public.videos USING btree (category);


--
-- TOC entry 4769 (class 1259 OID 38920)
-- Name: videos_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_created_at ON public.videos USING btree ("createdAt");


--
-- TOC entry 4770 (class 1259 OID 38922)
-- Name: videos_is_featured; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_is_featured ON public.videos USING btree ("isFeatured");


--
-- TOC entry 4771 (class 1259 OID 38921)
-- Name: videos_is_public_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_is_public_is_active ON public.videos USING btree ("isPublic", "isActive");


--
-- TOC entry 4772 (class 1259 OID 38916)
-- Name: videos_language; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_language ON public.videos USING btree (language);


--
-- TOC entry 4773 (class 1259 OID 38918)
-- Name: videos_likes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_likes ON public.videos USING btree (likes);


--
-- TOC entry 4776 (class 1259 OID 38919)
-- Name: videos_published_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_published_at ON public.videos USING btree ("publishedAt");


--
-- TOC entry 4777 (class 1259 OID 38914)
-- Name: videos_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_title ON public.videos USING btree (title);


--
-- TOC entry 4778 (class 1259 OID 38913)
-- Name: videos_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_user_id ON public.videos USING btree ("userId");


--
-- TOC entry 4779 (class 1259 OID 38917)
-- Name: videos_views; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX videos_views ON public.videos USING btree (views);


--
-- TOC entry 4782 (class 2606 OID 38683)
-- Name: articles articles_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT "articles_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4780 (class 2606 OID 38460)
-- Name: users users_membership_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_membership_id_fkey FOREIGN KEY (membership_id) REFERENCES public.memberships(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4781 (class 2606 OID 38455)
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4783 (class 2606 OID 38908)
-- Name: videos videos_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT "videos_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2025-08-24 14:27:46

--
-- PostgreSQL database dump complete
--

