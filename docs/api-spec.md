# API Specification

## Overview

SocialTrend Automator API terdiri dari dua layanan:
- **Laravel API** - Backend utama untuk authentication, scheduling, dan data management
- **FastAPI** - Microservice untuk AI processing, upload automation, dan trend analysis

## Base URLs

- **Laravel API**: `http://localhost:8000/api`
- **FastAPI**: `http://localhost:5000`

## Authentication

Laravel API menggunakan Laravel Sanctum untuk authentication. Token harus dikirim dalam header:

```
Authorization: Bearer {token}
```

---

## Laravel API Endpoints

### Authentication

#### Register User
```http
POST /api/register
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response (201):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "token": "1|xxxxxxxxxxxxx"
}
```

#### Login
```http
POST /api/login
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "token": "1|xxxxxxxxxxxxx"
}
```

### User Management

#### Get Current User
```http
GET /api/user
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2024-01-01T00:00:00.000000Z"
}
```

### Trends

#### Get Trends
```http
GET /api/trends
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "keyword": "AI Technology",
      "platform": "google",
      "score": 85,
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

### Scheduling

#### Create Scheduled Post
```http
POST /api/schedule
```

**Headers:**
```
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "social_account_id": 1,
  "content": "Post content here",
  "scheduled_at": "2024-12-25 10:00:00",
  "media_urls": ["https://example.com/image.jpg"],
  "platform": "instagram"
}
```

**Response (201):**
```json
{
  "message": "Post scheduled successfully",
  "data": {
    "id": 1,
    "social_account_id": 1,
    "content": "Post content here",
    "scheduled_at": "2024-12-25 10:00:00",
    "status": "scheduled"
  }
}
```

### Webhooks

#### Upload Callback
```http
POST /api/upload/callback
```

**Request Body:**
```json
{
  "scheduled_post_id": 1,
  "status": "posted",
  "message": "Upload successful",
  "post_url": "https://instagram.com/p/xxxxx"
}
```

**Response (200):**
```json
{
  "message": "Callback received"
}
```

### Health Check

#### Health Status
```http
GET /api/health
```

**Response (200):**
```json
{
  "status": "healthy",
  "service": "SocialTrend Automator API",
  "version": "1.0.0"
}
```

---

## FastAPI Endpoints

### Upload

#### Upload Content
```http
POST /api/upload
```

**Request Body:**
```json
{
  "platform": "instagram",
  "content": "Post content here",
  "media_urls": ["https://example.com/image.jpg"],
  "scheduled_post_id": 1,
  "callback_url": "http://backend/api/upload/callback"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Upload initiated successfully",
  "data": {
    "status": "uploaded",
    "platform": "instagram",
    "post_url": "https://instagram.com/p/xxxxx"
  }
}
```

### Trends

#### Fetch Trends
```http
POST /api/trends/fetch
```

**Request Body:**
```json
{
  "platform": "google",
  "keywords": ["AI", "Technology"],
  "timeframe": "today 12-m"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "platform": "google",
    "trends": [
      {
        "keyword": "AI Technology",
        "score": 85,
        "change": "+12%"
      }
    ]
  }
}
```

**Platform Options:**
- `google` - Google Trends (pytrends)
- `reddit` - Reddit API (PRAW)
- `twitter` - Twitter API (Tweepy)

### AI Caption Generation

#### Generate Caption (Legacy)
```http
POST /api/generate_caption
```

**Request Body:**
```json
{
  "content": "Technology trends",
  "image_description": "Tech conference photo",
  "platform": "instagram",
  "style": "professional"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "caption": "Exciting technology trends...",
    "hashtags": ["#tech", "#AI", "#innovation"],
    "provider": "openai",
    "style": "professional"
  }
}
```

#### Generate AI Caption (New)
```http
POST /api/ai/caption
```

**Request Body:**
```json
{
  "topic": "AI Technology",
  "style": "professional",
  "trend": ["AI", "Machine Learning", "Tech"]
}
```

**Response (200):**
```json
{
  "caption": "Exploring the latest in AI technology...",
  "hashtags": [
    "#AI",
    "#Technology",
    "#MachineLearning",
    "#Innovation"
  ],
  "recommended_time": "09:00 AM"
}
```

**Style Options:**
- `professional` - Professional tone
- `casual` - Casual tone
- `creative` - Creative tone

### Health Check

#### Health Status
```http
GET /health
```

**Response (200):**
```json
{
  "status": "healthy",
  "service": "socialtrend-automation"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid request data"
}
```

### 401 Unauthorized
```json
{
  "message": "Unauthenticated"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

---

## Rate Limiting

- **Laravel API**: 60 requests per minute per IP
- **FastAPI**: 100 requests per minute per IP

---

## API Documentation URLs

- **Laravel API Docs**: `http://localhost:8000/docs` (Scribe)
- **FastAPI Docs**: `http://localhost:5000/docs` (Swagger UI)
- **FastAPI ReDoc**: `http://localhost:5000/redoc`
- **FastAPI OpenAPI**: `http://localhost:5000/openapi.json`








