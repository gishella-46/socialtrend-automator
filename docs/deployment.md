# Deployment Guide

Panduan deployment SocialTrend Automator ke berbagai platform cloud.

## Table of Contents

- [Prerequisites](#prerequisites)
- [DigitalOcean Deployment](#digitalocean-deployment)
- [AWS ECS Deployment](#aws-ecs-deployment)
- [GCP Cloud Run Deployment](#gcp-cloud-run-deployment)
- [Environment Variables](#environment-variables)
- [Post-Deployment](#post-deployment)

## Prerequisites

- Docker & Docker Compose installed
- Cloud account (DigitalOcean/AWS/GCP)
- Domain name (optional but recommended)
- SSL certificate (Let's Encrypt recommended)

## Environment Variables

### Laravel Backend (.env)
```env
APP_NAME=SocialTrend
APP_ENV=production
APP_KEY=base64:xxxxx
APP_DEBUG=false
APP_URL=https://api.yourdomain.com

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=socialtrend_db
DB_USERNAME=socialtrend_user
DB_PASSWORD=your_secure_password

REDIS_HOST=redis
REDIS_PORT=6379

QUEUE_CONNECTION=redis
```

### FastAPI Service (.env)
```env
DB_URL=postgresql+asyncpg://socialtrend_user:password@postgres:5432/socialtrend_db
REDIS_URL=redis://redis:6379/0
LOG_LEVEL=INFO
OPENAI_API_KEY=your_openai_api_key
```

### Frontend (.env)
```env
VITE_API_URL=https://api.yourdomain.com
VITE_LARAVEL_API_URL=https://backend.yourdomain.com
```

---

## DigitalOcean Deployment

### Option 1: Droplets (Docker Compose)

1. **Create Droplet**
   - Ubuntu 22.04 LTS
   - Minimum: 2GB RAM, 2 vCPUs
   - Recommended: 4GB RAM, 4 vCPUs

2. **Setup Server**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

3. **Clone Repository**
```bash
git clone <your-repo-url>
cd socialTrend-automator-7v
```

4. **Configure Environment**
```bash
# Backend
cd backend
cp .env.example .env
nano .env  # Edit dengan production values
php artisan key:generate

# Automation
cd ../automation
cp .env.example .env
nano .env  # Edit dengan production values

# Frontend
cd ../frontend
cp .env.example .env
nano .env  # Edit dengan production values
```

5. **Deploy with Docker Compose**
```bash
cd ..
docker-compose up -d --build
```

6. **Setup Nginx Reverse Proxy**
```nginx
# /etc/nginx/sites-available/socialtrend
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /docs {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

7. **SSL with Let's Encrypt**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### Option 2: App Platform

1. **Create App Spec** (`app.yaml`)
```yaml
name: socialtrend-automator
services:
- name: backend
  github:
    repo: your-org/socialtrend-automator
    branch: main
    deploy_on_push: true
  dockerfile_path: ./backend/Dockerfile
  instance_count: 1
  instance_size_slug: basic-xxs
  envs:
  - key: APP_ENV
    value: production
  - key: DB_HOST
    scope: RUN_TIME
    type: SECRET
  routes:
  - path: /api
    preserve_path_prefix: true

- name: automation
  github:
    repo: your-org/socialtrend-automator
    branch: main
    deploy_on_push: true
  dockerfile_path: ./automation/Dockerfile
  instance_count: 1
  instance_size_slug: basic-xxs
  envs:
  - key: DB_URL
    scope: RUN_TIME
    type: SECRET

- name: frontend
  github:
    repo: your-org/socialtrend-automator
    branch: main
    deploy_on_push: true
  dockerfile_path: ./frontend/Dockerfile
  instance_count: 1
  instance_size_slug: basic-xxs
  routes:
  - path: /
```

2. **Deploy via DigitalOcean CLI**
```bash
doctl apps create --spec app.yaml
```

---

## AWS ECS Deployment

### 1. Create ECR Repositories

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Create repositories
aws ecr create-repository --repository-name socialtrend-backend --region us-east-1
aws ecr create-repository --repository-name socialtrend-automation --region us-east-1
aws ecr create-repository --repository-name socialtrend-frontend --region us-east-1
```

### 2. Build and Push Images

```bash
# Backend
cd backend
docker build -t socialtrend-backend .
docker tag socialtrend-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-backend:latest

# Automation
cd ../automation
docker build -t socialtrend-automation .
docker tag socialtrend-automation:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-automation:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-automation:latest

# Frontend
cd ../frontend
docker build -t socialtrend-frontend .
docker tag socialtrend-frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-frontend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-frontend:latest
```

### 3. Create ECS Task Definitions

**Backend Task Definition** (`backend-task.json`):
```json
{
  "family": "socialtrend-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-backend:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "APP_ENV", "value": "production"}
      ],
      "secrets": [
        {"name": "DB_HOST", "valueFrom": "arn:aws:secretsmanager:region:account:secret:db-host"},
        {"name": "DB_PASSWORD", "valueFrom": "arn:aws:secretsmanager:region:account:secret:db-password"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/socialtrend-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**Automation Task Definition** (`automation-task.json`):
```json
{
  "family": "socialtrend-automation",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "automation",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-automation:latest",
      "portMappings": [
        {
          "containerPort": 5000,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/socialtrend-automation",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**Frontend Task Definition** (`frontend-task.json`):
```json
{
  "family": "socialtrend-frontend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "frontend",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/socialtrend-frontend:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/socialtrend-frontend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### 4. Register Task Definitions

```bash
aws ecs register-task-definition --cli-input-json file://backend-task.json
aws ecs register-task-definition --cli-input-json file://automation-task.json
aws ecs register-task-definition --cli-input-json file://frontend-task.json
```

### 5. Create ECS Cluster and Services

```bash
# Create cluster
aws ecs create-cluster --cluster-name socialtrend-cluster

# Create services
aws ecs create-service \
  --cluster socialtrend-cluster \
  --service-name backend-service \
  --task-definition socialtrend-backend \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"

# Repeat for automation and frontend services
```

### 6. Setup Application Load Balancer

1. Create ALB with target groups for each service
2. Configure listener rules:
   - `/api/*` → backend-service
   - `/docs` → automation-service
   - `/*` → frontend-service

### 7. Setup RDS PostgreSQL

```bash
aws rds create-db-instance \
  --db-instance-identifier socialtrend-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username socialtrend_user \
  --master-user-password <password> \
  --allocated-storage 20
```

### 8. Setup ElastiCache Redis

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id socialtrend-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

---

## GCP Cloud Run Deployment

### 1. Setup Google Cloud Project

```bash
# Set project
gcloud config set project your-project-id

# Enable APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

### 2. Build and Deploy with Cloud Build

**Backend** (`cloudbuild-backend.yaml`):
```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/socialtrend-backend', './backend']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/socialtrend-backend']
- name: 'gcr.io/cloud-builders/gcloud'
  args:
  - 'run'
  - 'deploy'
  - 'backend'
  - '--image=gcr.io/$PROJECT_ID/socialtrend-backend'
  - '--region=us-central1'
  - '--platform=managed'
  - '--allow-unauthenticated'
  - '--set-env-vars=APP_ENV=production'
```

**Automation** (`cloudbuild-automation.yaml`):
```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/socialtrend-automation', './automation']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/socialtrend-automation']
- name: 'gcr.io/cloud-builders/gcloud'
  args:
  - 'run'
  - 'deploy'
  - 'automation'
  - '--image=gcr.io/$PROJECT_ID/socialtrend-automation'
  - '--region=us-central1'
  - '--platform=managed'
  - '--allow-unauthenticated'
```

**Frontend** (`cloudbuild-frontend.yaml`):
```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/socialtrend-frontend', './frontend']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/socialtrend-frontend']
- name: 'gcr.io/cloud-builders/gcloud'
  args:
  - 'run'
  - 'deploy'
  - 'frontend'
  - '--image=gcr.io/$PROJECT_ID/socialtrend-frontend'
  - '--region=us-central1'
  - '--platform=managed'
  - '--allow-unauthenticated'
```

### 3. Deploy Services

```bash
# Submit builds
gcloud builds submit --config cloudbuild-backend.yaml
gcloud builds submit --config cloudbuild-automation.yaml
gcloud builds submit --config cloudbuild-frontend.yaml
```

### 4. Setup Cloud SQL PostgreSQL

```bash
gcloud sql instances create socialtrend-db \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1

gcloud sql databases create socialtrend_db --instance=socialtrend-db
gcloud sql users create socialtrend_user --instance=socialtrend-db --password=<password>
```

### 5. Setup Cloud Memorystore Redis

```bash
gcloud redis instances create socialtrend-redis \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_6_x
```

### 6. Configure Service URLs

```bash
# Get service URLs
BACKEND_URL=$(gcloud run services describe backend --region=us-central1 --format='value(status.url)')
AUTOMATION_URL=$(gcloud run services describe automation --region=us-central1 --format='value(status.url)')
FRONTEND_URL=$(gcloud run services describe frontend --region=us-central1 --format='value(status.url)')

# Update environment variables
gcloud run services update backend \
  --update-env-vars DATABASE_URL=$DATABASE_URL,API_URL=$AUTOMATION_URL \
  --region=us-central1
```

### 7. Setup Load Balancer (Optional)

```yaml
# Load balancer config for custom domain
apiVersion: networking.gke.io/v1
kind: FrontendConfig
metadata:
  name: socialtrend-lb
spec:
  redirectToHttps:
    enabled: true
```

---

## Post-Deployment

### 1. Database Migrations

**Laravel:**
```bash
docker exec -it backend_container php artisan migrate --force
php artisan db:seed --force
```

**FastAPI:**
```bash
# Run migrations if using Alembic
docker exec -it automation_container alembic upgrade head
```

### 2. Generate API Documentation

**Laravel (Scribe):**
```bash
docker exec -it backend_container php artisan scribe:generate
```

**FastAPI:**
- Documentation automatically available at `/docs`

### 3. Setup Celery Workers

```bash
# For automation service
docker exec -it automation_container celery -A tasks worker --loglevel=info
```

### 4. Health Checks

```bash
# Backend
curl https://api.yourdomain.com/api/health

# Automation
curl https://api.yourdomain.com/health

# Frontend
curl https://yourdomain.com
```

### 5. Monitoring Setup

- **Laravel**: Setup Laravel Telescope or Log viewer
- **FastAPI**: Configure JSON logging to ELK stack
- **Infrastructure**: Use cloud provider monitoring (CloudWatch, Stackdriver, etc.)

---

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Verify database credentials
   - Check firewall rules allow connections
   - Ensure database is accessible from service network

2. **Redis Connection Errors**
   - Verify Redis URL
   - Check security groups/firewall
   - Ensure Redis is accessible

3. **CORS Errors**
   - Update CORS configuration in Laravel and FastAPI
   - Add frontend domain to allowed origins

4. **Queue Not Processing**
   - Ensure Celery workers are running
   - Check Redis connection
   - Verify task routing configuration

---

## Scaling

### Horizontal Scaling

- **Laravel**: Scale ECS services or Cloud Run instances
- **FastAPI**: Scale independently based on load
- **Celery**: Scale workers based on queue depth

### Database Scaling

- Use read replicas for PostgreSQL
- Implement connection pooling
- Consider database clustering for high load

### Caching Strategy

- Use Redis for session storage
- Implement application-level caching
- Use CDN for static assets

---

## Security Checklist

- [ ] Enable HTTPS/TLS everywhere
- [ ] Use secrets management (AWS Secrets Manager, GCP Secret Manager)
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Regular security updates
- [ ] Database backups configured
- [ ] Monitoring and alerting setup
- [ ] Log aggregation configured








