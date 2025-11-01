# SocialTrend Automator

Full-stack social media automation platform with AI-powered caption generation.

![CI/CD Pipeline](https://github.com/gishella-46/socialtrend-automator/workflows/CI%2FCD%20Pipeline/badge.svg)

## 🚀 Quick Start

### Using Init Script (Recommended)

```bash
./init.sh
```

This script will:
- Check Docker installation
- Build Docker images
- Start all services
- Run database migrations
- Generate API documentation
- Display access URLs

### Manual Setup

```bash
# Build and start services
docker-compose up -d --build

# Run migrations
docker exec socialtrend_backend php artisan migrate --force

# Generate Laravel docs
docker exec socialtrend_backend php artisan scribe:generate
```

## 📍 Access URLs

After running `./init.sh`, access your application at:

- **Frontend**: http://localhost
- **Backend API**: http://localhost/api
- **Laravel Docs**: http://localhost/docs
- **FastAPI Docs**: http://localhost/automation/docs
- **FastAPI ReDoc**: http://localhost/automation/redoc

## 🏗️ Architecture

### Services

- **Frontend**: Vue.js 3 application (Port 8080)
- **Backend**: Laravel 11 API (Port 8000)
- **Automation**: FastAPI microservice (Port 5000)
- **Database**: PostgreSQL 16 (Port 5432)
- **Cache/Queue**: Redis 7 (Port 6379)
- **Worker**: Celery for background tasks
- **Nginx**: Reverse proxy (Port 80/443)

### Routing

- `/` → Frontend (Vue.js)
- `/api/*` → Laravel Backend
- `/automation/*` → FastAPI Service
- `/automation/docs` → FastAPI Swagger UI
- `/docs` → Laravel API Documentation

## 🔒 SSL Configuration

### Using Certbot (Let's Encrypt)

1. Uncomment SSL sections in `docker/nginx/conf.d/default.conf`
2. Update domain names
3. Run certbot:

```bash
docker exec socialtrend_nginx certbot --nginx -d yourdomain.com
```

### Using Cloudflare

1. Get Origin Certificate from Cloudflare
2. Place certificates in `docker/nginx/ssl/`
3. Uncomment Cloudflare SSL config in `docker/nginx/conf.d/default.conf`
4. Update certificate paths

## 📚 Documentation

- **API Specification**: `docs/api-spec.md`
- **Architecture**: `docs/architecture.md`
- **Deployment**: `docs/deployment.md`
- **Monitoring**: `docs/MONITORING.md`
- **Logging**: `docs/LOGGING.md`
- **CI/CD**: `docs/CI_CD.md`

## 🛠️ Development

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f automation
docker-compose logs -f nginx
```

### Access Container Shell

```bash
# Backend
docker exec -it socialtrend_backend bash

# Automation
docker exec -it socialtrend_automation bash

# Database
docker exec -it socialtrend_postgres psql -U socialtrend_user -d socialtrend_db
```

### Stop Services

```bash
docker-compose down
```

### Restart Services

```bash
docker-compose restart
```

## 🧪 Testing

```bash
# Laravel tests
docker exec socialtrend_backend php artisan test

# Check API health
curl http://localhost/api/health
curl http://localhost/automation/health
```

## 📦 Environment Variables

See `.env.example` files in each service directory:
- `backend/.env.example`
- `automation/.env.example`
- `frontend/.env.example`

## 🔧 Troubleshooting

### Services not starting

```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs

# Rebuild containers
docker-compose up -d --build
```

### Database connection issues

```bash
# Check database health
docker exec socialtrend_postgres pg_isready -U socialtrend_user

# Check environment variables
docker exec socialtrend_backend env | grep DB_
```

### Nginx routing issues

```bash
# Test nginx configuration
docker exec socialtrend_nginx nginx -t

# Reload nginx
docker exec socialtrend_nginx nginx -s reload
```

## 📝 License

Proprietary
