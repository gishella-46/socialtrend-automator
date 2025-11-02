# Deployment Guides

This directory contains deployment configurations for various cloud platforms and container orchestration systems.

## Directory Structure

```
deploy/
├── docker-swarm/          # Docker Swarm deployment
│   ├── deploy.sh          # Deployment script
│   └── README.md          # Docker Swarm guide
├── aws-ecs/              # AWS ECS/Fargate deployment
│   ├── ecs-task-definition.json
│   ├── ecs-service.json
│   ├── deploy.sh
│   └── README.md
├── gcp-cloud-run/        # Google Cloud Run deployment
│   ├── cloud-run.yaml
│   ├── deploy.sh
│   └── README.md
├── digitalocean/         # DigitalOcean Apps deployment
│   ├── apps.yaml
│   ├── deploy.sh
│   └── README.md
└── kubernetes/           # Kubernetes deployment (optional)
    ├── k8s-manifests/
    └── README.md
```

## Quick Start

### Docker Swarm

```bash
cd deploy/docker-swarm
./deploy.sh production
```

### AWS ECS

```bash
cd deploy/aws-ecs
export ECR_REGISTRY=ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
./deploy.sh production
```

### Google Cloud Run

```bash
cd deploy/gcp-cloud-run
export GCP_PROJECT_ID=your-project-id
./deploy.sh production
```

### DigitalOcean Apps

```bash
cd deploy/digitalocean
doctl auth init
doctl apps create --spec apps.yaml
```

## Scaling

All deployment methods support horizontal scaling:

- **Backend**: 3-10 replicas
- **Automation**: 3-10 replicas
- **Frontend**: 2-5 replicas
- **Celery**: 2-5 workers

See [docs/SCALING.md](../docs/SCALING.md) for detailed scaling strategies.

## Load Balancing

All platforms include load balancing:

- **Docker Swarm**: Traefik
- **AWS ECS**: Application Load Balancer
- **GCP Cloud Run**: Cloud Load Balancer
- **DigitalOcean**: Managed Load Balancer

## Requirements

### Docker Swarm
- Docker Engine 20.10+
- Swarm mode enabled
- External registry access

### AWS ECS
- AWS CLI
- ECR repository
- VPC and subnets
- IAM roles configured

### Google Cloud Run
- gcloud CLI
- GCP project with billing
- Cloud Build API enabled

### DigitalOcean Apps
- doctl CLI
- DigitalOcean account
- App platform access

## Environment Variables

Required environment variables for production:

```
# Database
DB_HOST=xxx
DB_PORT=5432
DB_DATABASE=socialtrend_db
DB_USERNAME=socialtrend_user
DB_PASSWORD=xxx

# Redis
REDIS_HOST=xxx
REDIS_PORT=6379

# Application
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

# API Keys
OPENAI_API_KEY=xxx
REDDIT_CLIENT_ID=xxx
REDDIT_CLIENT_SECRET=xxx
TWITTER_API_KEY=xxx
TWITTER_API_SECRET=xxx

# Registry
DOCKER_REGISTRY=ghcr.io/gishella-46
```

## Continuous Deployment

All deployment methods integrate with CI/CD:

- **GitHub Actions**: Push to registry, update services
- **GitLab CI**: Build images, deploy to clusters
- **Jenkins**: Automated pipelines

See `.github/workflows/main.yml` for reference.

## Monitoring

All deployments include:

- **Metrics**: Prometheus, CloudWatch, Stackdriver
- **Logging**: ELK Stack, CloudWatch Logs
- **Traces**: Jaeger, Cloud Trace
- **Alerts**: PagerDuty, Slack, Email

## Support

For deployment issues:

1. Check logs: `docker service logs` or cloud console
2. Review configuration files
3. Verify environment variables
4. Check network connectivity
5. Review [docs/SCALING.md](../docs/SCALING.md)

## Additional Resources

- [Docker Swarm Docs](https://docs.docker.com/engine/swarm/)
- [AWS ECS Docs](https://docs.aws.amazon.com/ecs/)
- [Cloud Run Docs](https://cloud.google.com/run/docs)
- [DigitalOcean Apps Docs](https://docs.digitalocean.com/products/app-platform/)

