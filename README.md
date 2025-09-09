# Backend - IT Programmer

## Overview

Backend service untuk aplikasi fullstack web dengan sistem membership yang menyediakan akses bertingkat terhadap konten artikel dan video. Dibangun menggunakan Node.js, Express.js, dan PostgreSQL dengan fokus pada keamanan, performa, dan skalabilitas.

## Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL 12+
- **ORM**: Sequelize
- **Authentication**: JWT + OAuth (Google, Facebook)
- **Password Hashing**: Argon2
- **Validation**: Joi/Yup
- **File Upload**: Multer
- **Image Processing**: Sharp (optional)

## Features

- 🔐 Authentication & Authorization (JWT + OAuth)
- 👥 Role-based Access Control (RBAC)
- 💳 Membership System (Free, Premium, Enterprise)
- 📝 Article Management dengan Rich Text Editor
- 🎥 Video Management dengan Analytics
- 🖼️ File Upload & Management
- 🔍 Search & Filtering
- 📊 Pagination & Sorting
- 🛡️ Security (Input Validation, XSS Protection, SQL Injection Prevention)

## Installation & Setup

### Prerequisites

- Node.js 18+
- PostgreSQL 12+
- npm atau yarn

### 1. Clone Repository

```bash
git clone <repository-url>
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Configuration

Buat file `.env` di root directory:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=membership_app
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# JWT
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=24h

# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret

# Server
PORT=5000
NODE_ENV=development

# File Upload
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
ALLOWED_EXTENSIONS=jpg,jpeg,png,gif,webp

# CORS
FRONTEND_URL=http://localhost:3000
```

### 4. Database Setup

#### Membuat Database

```bash
# Login ke PostgreSQL
psql -U postgres

# Buat database
CREATE DATABASE membership_app;
CREATE USER your_db_user WITH PASSWORD 'your_db_password';
GRANT ALL PRIVILEGES ON DATABASE membership_app TO your_db_user;
```

### 5. Menjalankan Aplikasi

```bash
# Development mode
npm run dev

# Production mode
npm start

```

Server akan berjalan di `http://localhost:5000`

## Database Schema

### Core Tables

- **users**: User authentication & profile data
- **roles**: Role-based access control
- **memberships**: Membership plans & pricing
- **articles**: Article content & metadata
- **videos**: Video content & analytics

### Key Relationships

- Users ↔ Roles (Many-to-One)
- Users ↔ Memberships (Many-to-One)
- Users ↔ Articles (One-to-Many)
- Users ↔ Videos (One-to-Many)

## API Endpoints

### Authentication Routes

- `POST /api/auth/login` - Login dengan email/password
- `POST /api/auth/register` - Register user baru
- `POST /api/auth/facebook/login` - Facebook OAuth login
- `GET /api/auth/google` - Google OAuth redirect
- `GET /api/auth/google/callback` - Google OAuth callback

### User Management

- `POST /api/users` - Get users dengan pagination
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user profile
- `POST /api/users/:id/image` - Upload profile picture
- `DELETE /api/users/:id` - Delete user (admin only)

### Article Management

- `POST /api/article` - Get articles dengan filter & pagination
- `GET /api/article/:id` - Get article by ID
- `PUT /api/article/:id` - Update article
- `DELETE /api/article/:id` - Delete article
- `POST /api/upload-direct` - Upload files untuk editor

### Video Management

- `GET /api/videos/trending` - Get trending videos
- `GET /api/videos/category/:category` - Get videos by category
- `POST /api/videos` - Get videos dengan filter & pagination
- `GET /api/videos/:id` - Get video by ID
- `POST /api/videos/create` - Create new video
- `PUT /api/videos/:id` - Update video
- `DELETE /api/videos/:id` - Delete video
- `POST /api/videos/:id/like` - Like video
- `POST /api/videos/:id/view` - Increment view count

## Middleware

### Authentication Middleware

- `jwtAuth`: Validasi JWT token
- `membershipType`: Membership-based access control

### Security Middleware

- Rate limiting
- CORS configuration
- Input sanitization
- File upload validation

## Arsitektur & Keputusan Teknis

### 1. Database Design

**Keputusan**: PostgreSQL dengan Sequelize ORM
**Alasan**:

- ACID compliance untuk data integrity
- Complex queries untuk analytics
- JSON support untuk flexible data (permissions, metadata)
- Mature ecosystem dengan Node.js

### 2. Authentication Strategy

**Keputusan**: JWT + OAuth hybrid approach
**Alasan**:

- JWT untuk stateless authentication
- OAuth untuk user convenience
- Argon2 untuk password hashing (lebih secure daripada bcrypt)
- Role-based access control untuk granular permissions

### 3. Membership System

**Keputusan**: Database-driven limits dengan real-time validation
**Alasan**:

- Flexible pricing & feature management
- Easy membership upgrade/downgrade
- Automatic expiration handling
- Analytics tracking per membership tier

### 4. File Upload Strategy

**Keputusan**: Local storage dengan validation
**Alasan**:

- Cost-effective untuk MVP
- Full control over file management
- Easy migration ke cloud storage later
- Security validation (type, size, malware scanning)

### 5. API Design

**Keputusan**: RESTful API dengan consistent response format
**Alasan**:

- Industry standard
- Easy to document & test
- Consistent error handling
- Pagination & filtering support

## Security Features

### 1. Authentication Security

- JWT token dengan expiration
- Password hashing dengan Argon2
- OAuth state parameter validation
- Session management

### 2. Data Protection

- Input validation & sanitization
- SQL injection prevention (ORM-based)
- XSS protection
- CSRF protection
- File upload security

### 3. Authorization

- Role-based access control
- Membership-based content limiting
- Owner-based resource access
- API rate limiting

## Performance Optimizations

### 1. Database

- Strategic indexing pada frequently queried fields
- Database connection pooling
- Query optimization dengan Sequelize
- Soft delete untuk data integrity

### 2. API

- Pagination untuk large datasets
- Response caching untuk static data
- Debounced search implementation
- Optimistic updates support

### 3. File Handling

- File size & type validation
- Image optimization (dengan Sharp)
- CDN-ready architecture
- Lazy loading support

## Waktu Pengembangan & Trade-offs

### Estimasi Waktu (12 jam total)

Strategi MVP:

3 jam: Setup database, Express, JWT auth dasar
6 jam: API CRUD untuk user, artikel, video + file upload basic
2 jam: Logic membership sederhana

Trade-offs utama:

Skip OAuth (hemat 4-6 jam)
Database schema sederhana tanpa optimasi
Validasi minimal
Error handling basic
File upload sederhana tanpa processing

### Trade-offs Decisions

#### 1. Local File Storage vs Cloud Storage

**Pilihan**: Local storage
**Trade-off**:

- ✅ Lower cost, faster development
- ❌ Scalability concerns, backup complexity
- **Mitigasi**: Easy migration path ke AWS S3/CloudFront

#### 2. Sequelize ORM vs Raw SQL

**Pilihan**: Sequelize ORM
**Trade-off**:

- ✅ Faster development, type safety, migration management
- ❌ Performance overhead, learning curve
- **Mitigasi**: Optimized queries, proper indexing

#### 3. Monolithic vs Microservices

**Pilihan**: Monolithic architecture
**Trade-off**:

- ✅ Simpler deployment, easier development
- ❌ Scalability limitations
- **Mitigasi**: Modular code structure, preparation for future split

#### 4. Real-time Features vs Polling

**Pilihan**: HTTP polling untuk analytics
**Trade-off**:

- ✅ Simpler implementation, lower complexity
- ❌ Not truly real-time, higher bandwidth usage
- **Mitigasi**: WebSocket implementation planned for v2

### Environment Considerations

- Node.js 18+ required
- PostgreSQL 12+ required
- Minimum 2GB RAM recommended
- SSD storage recommended untuk database

## Monitoring & Maintenance

### Performance Monitoring

- Database connection pool monitoring
- API response time tracking
- Memory usage monitoring
- Error rate tracking
