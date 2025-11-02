# Scaling Guide

Complete guide for deploying SocialTrend Automator at scale with horizontal scaling capabilities.

## Table of Contents

1. [Docker Swarm](#docker-swarm)
2. [AWS ECS/Fargate](#aws-ecsfargate)
3. [Google Cloud Run](#google-cloud-run)
4. [DigitalOcean Apps](#digitalocean-apps)
5. [Load Balancing](#load-balancing)
6. [Auto Scaling](#auto-scaling)
7. [Best Practices](#best-practices)

## Docker Swarm

### Prerequisites

- Docker Swarm cluster with at least 1 manager node
- External registry access (Docker Hub or GHCR)

### Deployment

```bash
# Initialize Swarm (if not already done)
docker swarm init

# Join workers (optional)
docker swarm join --token SWMTKN-xxx MANAGER_IP:2377

# Deploy stack
cd deploy/docker-swarm
./deploy.sh production
```

### Configuration

Edit `docker-stack.yml`:

- **Replicas**: Configure `replicas: 3` for backend/automation
- **Resources**: Adjust CPU/memory limits
- **Placement**: Configure node labels/constraints
- **Rolling Updates**: Adjust `update_config` parameters

### Scaling

```bash
# Scale services
docker service scale socialtrend_backend=5
docker service scale socialtrend_automation=5
docker service scale socialtrend_frontend=3

# Check status
docker service ls
docker service ps socialtrend_backend

# Update images
docker service update --image ghcr.io/gishella-46/socialtrend-backend:v2.0 socialtrend_backend
```

### Load Balancing

Traefik automatically load balances traffic across replicas:
- HTTP/HTTPS termination
- Automatic SSL with Let's Encrypt
- Health checks
- Service discovery

## AWS ECS/Fargate

### Prerequisites

- AWS CLI configured
- ECR repository created
- VPC with subnets/security groups
- Application Load Balancer

### Setup

```bash
# Create ECR repositories
aws ecr create-repository --repository-name socialtrend-backend
aws ecr create-repository --repository-name socialtrend-automation
aws ecr create-repository --repository-name socialtrend-frontend

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build and push images
cd deploy/aws-ecs
./deploy.sh production
```

### Service Configuration

**Task Definition** (`ecs-task-definition.json`):
- CPU: 1024 (1 vCPU)
- Memory: 2048 (2 GB)
- Container definitions
- Health checks

**Service Configuration** (`ecs-service.json`):
- Desired count: 3
- Min healthy: 100%
- Max deploy: 200%
- Circuit breaker enabled

### Auto Scaling

Create CloudWatch alarms and auto-scaling policies:

```json
{
  "TargetValue": 70.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
  },
  "ScaleInCooldown": 300,
  "ScaleOutCooldown": 60
}
```

### Load Balancing

- Application Load Balancer (ALB)
- Target groups with health checks
- HTTPS with ACM certificates
- Cross-zone load balancing

## Google Cloud Run

### Prerequisites

- gcloud CLI installed
- GCP project with billing enabled
- Cloud Build API enabled

### Setup

```bash
# Set project
gcloud config set project PROJECT_ID

# Deploy services
cd deploy/gcp-cloud-run
./deploy.sh production
```

### Service Configuration

**Cloud Run Service** (`cloud-run.yaml`):
- Min instances: 3
- Max instances: 10
- CPU: 2 vCPU
- Memory: 2 GB
- Concurrency: 80

### Auto Scaling

Cloud Run automatically scales based on:
- Request volume
- CPU utilization
- Memory usage
- Concurrent requests

Configure in `cloud-run.yaml`:
```yaml
autoscaling:
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilization: 70
```

### Load Balancing

- Cloud Load Balancer
- Managed SSL certificates
- CDN integration
- HTTP/2 and HTTP/3 support

## DigitalOcean Apps

### Prerequisites

- DigitalOcean account
- doctl CLI authenticated
- App specification ready

### Setup

```bash
# Authenticate
doctl auth init

# Deploy
cd deploy/digitalocean
doctl apps create --spec apps.yaml
```

### Service Configuration

**Apps Specification** (`apps.yaml`):
- Backend: 3 instances, professional-xs
- Automation: 3 instances, professional-xs
- Frontend: 2 instances, basic-xxs
- Managed databases (PostgreSQL + Redis)
- Auto-scaling alerts

### Scaling

```bash
# Scale services
doctl apps update APP_ID --spec apps.yaml

# Check status
doctl apps list
doctl apps get APP_ID
```

### Load Balancing

- DigitalOcean Load Balancer
- SSL/TLS termination
- Health checks
- Sticky sessions

## Load Balancing

### Traefik (Docker Swarm)

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.services.backend.loadbalancer.server.port=8000"
  - "traefik.http.routers.backend.rule=PathPrefix(`/api`)"
  - "traefik.http.routers.backend-secure.tls.certresolver=letsencrypt"
```

Features:
- Automatic service discovery
- Let's Encrypt SSL
- Health checks
- Circuit breakers
- Retry logic

### Application Load Balancer (AWS)

- Layer 7 routing
- Content-based routing
- SSL/TLS offloading
- WebSocket support
- Health checks

### Cloud Load Balancer (GCP)

- Global load balancing
- Managed SSL certificates
- CDN integration
- Cloud Armor (DDoS protection)
- HTTP/2 and QUIC

## Auto Scaling

### Metrics to Monitor

1. **CPU Utilization**: Target 70-80%
2. **Memory Usage**: Alert at 80%
3. **Request Rate**: Scale on RPS increase
4. **Response Time**: Alert if > 1s
5. **Queue Depth** (Celery): Scale workers on backlog

### Scaling Strategies

#### Horizontal Pod Autoscaler (Kubernetes)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

#### AWS ECS Auto Scaling

```json
{
  "scalableDimension": "ecs:service:DesiredCount",
  "serviceNamespace": "ecs",
  "resourceId": "service/cluster-name/service-name",
  "policyType": "TargetTrackingScaling",
  "targetTrackingScalingPolicyConfiguration": {
    "targetValue": 70.0,
    "scaleInCooldown": 300,
    "scaleOutCooldown": 60
  }
}
```

### Celery Worker Scaling

Scale Celery workers separately:

```bash
# Docker Swarm
docker service scale socialtrend_celery=5

# ECS
aws ecs update-service --desired-count 5

# Kubernetes
kubectl scale deployment celery-worker --replicas=5
```

## Best Practices

### Performance Optimization

1. **Database Connection Pooling**
   - PgBouncer for PostgreSQL
   - Redis connection pooling
   - Set appropriate pool sizes

2. **Caching Strategy**
   - Redis for session/query cache
   - CDN for static assets
   - Browser caching headers

3. **Database Optimization**
   - Read replicas for scaling reads
   - Connection pooling
   - Query optimization
   - Proper indexing

### Monitoring

1. **Metrics Collection**
   - Prometheus for metrics
   - Grafana for visualization
   - CloudWatch/Stackdriver integration

2. **Logging**
   - Centralized logging (ELK)
   - Structured logging (JSON)
   - Log aggregation
   - Alert on errors

3. **Health Checks**
   - Liveness probes
   - Readiness probes
   - Startup probes
   - Graceful shutdown

### Security

1. **Network Security**
   - VPC isolation
   - Security groups/firewalls
   - Private subnets
   - VPN/bastion hosts

2. **Application Security**
   - HTTPS everywhere
   - Rate limiting
   - Authentication/authorization
   - Secret management (Vault/KMS)

3. **Container Security**
   - Image scanning
   - Least privilege
   - Non-root users
   - Security updates

### Cost Optimization

1. **Right-Sizing**
   - Monitor resource usage
   - Adjust instance sizes
   - Use spot instances (AWS)
   - Reserved instances for stable workloads

2. **Auto Scaling**
   - Scale down during low traffic
   - Scheduled scaling
   - Predictive scaling

3. **Database Optimization**
   - Managed databases
   - Storage optimization
   - Backup retention policies

## Troubleshooting

### High Latency

1. Check database connections
2. Verify cache hit rates
3. Monitor network latency
4. Check load balancer health

### Memory Issues

1. Increase container memory
2. Check for memory leaks
3. Optimize application code
4. Adjust garbage collection

### Connection Pool Exhaustion

1. Increase pool sizes
2. Check for connection leaks
3. Implement circuit breakers
4. Add connection timeouts

### Scaling Failures

1. Check resource quotas
2. Verify instance availability
3. Review auto-scaling policies
4. Check load balancer limits

## Next Steps

1. Set up monitoring dashboards
2. Configure alerting
3. Implement chaos engineering
4. Load testing
5. Disaster recovery planning

