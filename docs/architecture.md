# System Architecture

## Overview

SocialTrend Automator adalah aplikasi full-stack untuk otomasi social media dengan AI-powered caption generation dan scheduled posting.

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend Layer                           │
│                     (Vue 3 + Vite + TailwindCSS)                 │
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Login   │  │Register  │  │Dashboard │  │   Upload  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                       │
│  │ Trends   │  │AI Caption│  │Schedule  │                       │
│  └──────────┘  └──────────┘  └──────────┘                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST API
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                           │
        ▼                                           ▼
┌───────────────────────┐              ┌───────────────────────┐
│   Laravel Backend     │              │   FastAPI Service      │
│   (PHP 8.3)           │              │   (Python 3.11)        │
│                       │              │                        │
│  • Authentication     │              │  • AI Caption Gen      │
│  • User Management    │◄─────────────┤  • Content Upload      │
│  • Scheduling         │   Webhook    │  • Trends Fetch        │
│  • Data Management    │   Callback   │  • Celery Tasks        │
└───────────────────────┘              └───────────────────────┘
        │                                       │
        │                                       │
        ▼                                       ▼
┌───────────────────────┐              ┌───────────────────────┐
│   PostgreSQL          │              │   Redis (Broker)      │
│   Database            │              │   • Task Queue        │
│   • Users             │              │   • Cache             │
│   • Scheduled Posts   │              │   • Session           │
│   • Trends            │              │                        │
│   • Social Accounts   │              │   ┌─────────────────┐ │
└───────────────────────┘              │   │  Celery Worker  │ │
                                      │   │  • Auto Upload  │ │
                                      │   │  • AI Process   │ │
                                      │   └─────────────────┘ │
                                      └───────────────────────┘
                                                  │
                                                  ▼
                                      ┌───────────────────────┐
                                      │   External APIs       │
                                      │   • OpenAI API         │
                                      │   • Instagram API     │
                                      │   • LinkedIn API      │
                                      │   • Google Trends     │
                                      │   • Reddit API        │
                                      │   • Twitter API       │
                                      └───────────────────────┘
```

## Component Details

### Frontend (Vue.js)
- **Framework**: Vue 3 with Composition API
- **Build Tool**: Vite
- **Styling**: TailwindCSS
- **State Management**: Pinia
- **Routing**: Vue Router
- **HTTP Client**: Axios
- **Charts**: Chart.js
- **Calendar**: FullCalendar
- **Icons**: Lucide Vue
- **Animations**: @motionone/vue

### Backend - Laravel API
- **Framework**: Laravel 11
- **Language**: PHP 8.3
- **Authentication**: Laravel Sanctum
- **Database**: PostgreSQL (via SQLAlchemy async di Python)
- **Features**:
  - User registration & authentication
  - Scheduled post management
  - Social account management
  - Trend data storage
  - Webhook callbacks from Python service

### Backend - FastAPI Microservice
- **Framework**: FastAPI
- **Language**: Python 3.11
- **Task Queue**: Celery
- **Message Broker**: Redis
- **Database**: PostgreSQL (async via SQLAlchemy)
- **Features**:
  - AI-powered caption generation (OpenAI GPT-4)
  - Social media upload automation
  - Trend fetching (Google, Reddit, Twitter)
  - Background task processing
  - Automated scheduled uploads

### Database - PostgreSQL
- **Storage**:
  - Users & authentication
  - Scheduled posts
  - Social media accounts
  - Trends data
  - Permissions & roles

### Cache & Queue - Redis
- **Purpose**:
  - Celery task queue
  - Session storage
  - Cache layer
  - Rate limiting

### External Services
- **OpenAI API**: GPT-4 for AI caption generation
- **Social Media APIs**: Instagram, LinkedIn
- **Trend APIs**: Google Trends, Reddit (PRAW), Twitter (Tweepy)

## Data Flow

### 1. User Registration/Login Flow
```
Frontend → Laravel API → PostgreSQL → Laravel API → Frontend (with token)
```

### 2. Schedule Post Flow
```
Frontend → Laravel API → PostgreSQL
                    ↓
            Scheduled Post Created
                    ↓
        (At scheduled time)
                    ↓
        Laravel → FastAPI (via queue)
                    ↓
        FastAPI → Social Media API
                    ↓
        FastAPI → Laravel (webhook callback)
                    ↓
        Laravel → Update status in PostgreSQL
```

### 3. AI Caption Generation Flow
```
Frontend → FastAPI → OpenAI API
                ↓
        FastAPI → Process response
                ↓
        FastAPI → Return to Frontend
```

### 4. Trend Fetching Flow
```
Frontend → FastAPI → External APIs (Google/Reddit/Twitter)
                ↓
        FastAPI → Process & Aggregate
                ↓
        FastAPI → Return to Frontend
                ↓
        (Optional) → Laravel → Store in PostgreSQL
```

## Technology Stack Summary

| Layer | Technology |
|-------|-----------|
| Frontend | Vue 3, Vite, TailwindCSS, Pinia, Vue Router |
| Backend API | Laravel 11 (PHP 8.3) |
| Microservice | FastAPI (Python 3.11) |
| Database | PostgreSQL |
| Cache/Queue | Redis |
| Task Queue | Celery |
| AI Service | OpenAI GPT-4 |
| Authentication | Laravel Sanctum |
| Documentation | Scribe (Laravel), Swagger (FastAPI) |

## Security

- **Authentication**: Token-based (Laravel Sanctum)
- **API Security**: CORS configured, rate limiting
- **Data Encryption**: HTTPS/TLS in production
- **Environment Variables**: Sensitive data in `.env` files
- **Input Validation**: Laravel validation + FastAPI Pydantic models

## Scalability

- **Horizontal Scaling**: Stateless APIs can scale horizontally
- **Task Processing**: Celery workers can scale independently
- **Database**: PostgreSQL with connection pooling
- **Cache**: Redis for high-performance caching
- **Load Balancing**: Nginx reverse proxy support








