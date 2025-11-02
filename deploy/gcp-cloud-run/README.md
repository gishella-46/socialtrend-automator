# Google Cloud Run Deployment Guide

Serverless deployment on Google Cloud Run with automatic scaling.

## Prerequisites

- Google Cloud account with billing enabled
- gcloud CLI installed and configured
- Cloud Build API enabled
- Cloud Run API enabled
- Artifact Registry or Container Registry access

## Architecture

### Services

- **Backend**: Fully managed, auto-scaling from 3 to 10 instances
- **Automation**: Fully managed, auto-scaling from 3 to 10 instances
- **Frontend**: Fully managed, auto-scaling from 2 to 5 instances

### Managed Services

- **Cloud SQL**: PostgreSQL database
- **Memorystore**: Redis cache
- **Cloud Load Balancing**: Global load balancer
- **Cloud Armor**: DDoS protection

## Quick Start

```bash
# Set project
gcloud config set project PROJECT_ID

# Deploy all services
./deploy.sh production
```

## Setup Steps

### 1. Enable APIs

```bash
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  sqladmin.googleapis.com \
  redis.googleapis.com
```

### 2. Create Cloud SQL Instance

```bash
gcloud sql instances create socialtrend-db \
  --database-version=POSTGRES_16 \
  --tier=db-f1-micro \
  --region=us-central1
```

### 3. Create Memorystore Redis

```bash
gcloud redis instances create socialtrend-redis \
  --size=1 \
  --region=us-central1
```

### 4. Create Secrets

```bash
# Database password
echo -n "secure_password" | gcloud secrets create db-password --data-file=-

# Redis host
echo -n "redis-ip" | gcloud secrets create redis-host --data-file=-

# API keys
echo -n "api_key" | gcloud secrets create openai-api-key --data-file=-
```

### 5. Build and Deploy

```bash
# Set environment variables
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=us-central1

# Deploy
./deploy.sh production
```

## Auto Scaling

Cloud Run automatically scales based on:
- Request volume
- CPU utilization
- Concurrent requests
- Response time

Configure in `cloud-run.yaml`:

```yaml
autoscaling:
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilization: 70
```

## Load Balancing

### Global Load Balancer

```bash
# Create backend service
gcloud compute backend-services create socialtrend-backend \
  --load-balancing-scheme=EXTERNAL

# Add Cloud Run backend
gcloud compute backend-services add-backend socialtrend-backend \
  --network-endpoint-group=CLOUD_RUN_NEG \
  --global

# Create URL map
gcloud compute url-maps create socialtrend-lb \
  --default-backend-service=socialtrend-backend

# Create HTTPS proxy
gcloud compute target-https-proxies create socialtrend-https-proxy \
  --url-map=socialtrend-lb \
  --ssl-certificates=your-ssl-cert

# Create forwarding rule
gcloud compute forwarding-rules create socialtrend-forwarding \
  --global \
  --target-https-proxy=socialtrend-https-proxy \
  --ports=443
```

## Monitoring

### Cloud Monitoring

```bash
# View metrics
gcloud monitoring dashboards create dashboard.json

# Create alerts
gcloud alpha monitoring policies create alert-policy.json
```

### Key Metrics

- Request count
- Request latency
- Error rate
- Container instances
- CPU utilization
- Memory usage

## Cost Optimization

### Pricing

- $0.00002400 per vCPU-second
- $0.00000250 per GiB-second
- $0.40 per million requests

### Optimizations

1. Use min instances to reduce cold starts
2. Optimize container startup time
3. Use appropriate CPU/memory allocation
4. Cache responses to reduce requests
5. Use Cloud CDN for static content

### Estimated Costs

For 3 services with 3-10 instances:
- Compute: ~$50-100/month
- Requests: ~$10-20/month
- Cloud SQL: ~$10-20/month
- Memorystore: ~$30-50/month
- Load Balancing: ~$20/month

**Total**: ~$120-210/month

## Security

### IAM

```bash
# Create service account
gcloud iam service-accounts create socialtrend-sa

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:socialtrend-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"
```

### Network Security

```bash
# VPC connector for private resources
gcloud compute networks vpc-access connectors create socialtrend-connector \
  --region=us-central1 \
  --subnet=subnet-name
```

## Troubleshooting

### Service Not Starting

```bash
# View logs
gcloud run services logs read socialtrend-backend --limit 50

# Describe service
gcloud run services describe socialtrend-backend

# Check revisions
gcloud run revisions list --service=socialtrend-backend
```

### High Latency

```bash
# Check metrics
gcloud monitoring time-series list \
  --filter='metric.type="run.googleapis.com/request_latencies"'
```

## Deployment Checklist

- [ ] Project set up with billing
- [ ] APIs enabled
- [ ] Cloud SQL instance created
- [ ] Memorystore Redis created
- [ ] Secrets configured
- [ ] Service accounts created
- [ ] Images built and pushed
- [ ] Services deployed
- [ ] Custom domains configured
- [ ] SSL certificates issued
- [ ] Load balancer configured
- [ ] Monitoring and alerts set
- [ ] Cloud Armor rules configured
- [ ] Backup strategy implemented

## References

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run Pricing](https://cloud.google.com/run/pricing)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Memorystore Documentation](https://cloud.google.com/memorystore/docs/redis)

