# SocialTrend Automation Microservice

Python FastAPI microservice for AI-powered social media automation.

## 🚀 Features

- **FastAPI** REST API with Swagger UI
- **Celery** task queue with Redis broker
- **PostgreSQL** database (SQLAlchemy async)
- **JSON logging** compatible with ELK stack
- **AI-powered** caption generation (OpenAI/HuggingFace)
- **Trend fetching** from Google, Reddit, Twitter
- **Social media upload** to Instagram, LinkedIn

## 📋 Endpoints

### Upload
- `POST /api/upload` - Upload content to social media platforms

### Trends
- `POST /api/trends/fetch` - Fetch trends from various platforms

### Caption Generation
- `POST /api/generate_caption` - Generate caption and hashtags using AI

### Documentation
- `GET /docs` - Swagger UI
- `GET /redoc` - ReDoc documentation

## 🛠️ Setup

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Required variables:
- `DB_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection URL
- `OPENAI_API_KEY` - OpenAI API key (optional)
- Social media API keys (for production)

### Docker

```bash
# Build and start
docker-compose build automation
docker-compose up -d automation celery

# View logs
docker-compose logs -f automation
```

### Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run FastAPI
uvicorn main:app --reload --host 0.0.0.0 --port 5000

# Run Celery worker
celery -A tasks worker --loglevel=info --queue=uploads
```

## 📊 Celery Tasks

- `tasks.auto_upload` - Auto-upload scheduled posts
- `tasks.ai_process` - AI content processing

## 🔍 Logging

Logs are in JSON format, compatible with ELK stack:
- Structured fields: timestamp, level, service, module
- Compatible with Logstash, Elasticsearch, Kibana

## 📝 API Documentation

Visit `/docs` for interactive Swagger UI documentation.


















