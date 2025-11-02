# Docker Swarm Deployment Guide

Production-ready deployment using Docker Swarm with Traefik load balancer.

## Prerequisites

- Docker Engine 20.10+ installed
- Docker Swarm cluster initialized
- Minimum 1 manager node (3 recommended for HA)
- Worker nodes for scaling (optional)
- External registry access (Docker Hub or GHCR)

## Quick Start

```bash
# Clone repository
git clone https://github.com/gishella-46/socialtrend-automator.git
cd socialtrend-automator

# Initialize Swarm (first time only)
docker swarm init

# Deploy stack
cd deploy/docker-swarm
./deploy.sh production
```

## Architecture

### Services

- **Traefik**: Load balancer with SSL termination (3 replicas)
- **Backend**: Laravel API (3 replicas, auto-scaling capable)
- **Automation**: FastAPI service (3 replicas)
- **Frontend**: Vue.js app (2 replicas)
- **Celery**: Task workers (2 replicas)
- **PostgreSQL**: Database (1 replica, persisted)
- **Redis**: Cache/Queue (1 replica)
- **Prometheus**: Metrics collection
- **Grafana**: Dashboards
- **ELK Stack**: Log aggregation

### Load Balancing

Traefik automatically:
- Discovers services via Docker labels
- Load balances across replicas
- Terminates SSL/TLS
- Issues Let's Encrypt certificates
- Performs health checks
- Routes traffic based on host/path

## Configuration

### Environment Variables

Create `.env` file:

```bash
# Domain
DOMAIN=yourdomain.com

# Database
DB_DATABASE=socialtrend_db
DB_USERNAME=socialtrend_user
DB_PASSWORD=secure_password

# Docker Registry
DOCKER_REGISTRY=ghcr.io/gishella-46
BACKEND_VERSION=latest
AUTOMATION_VERSION=latest
FRONTEND_VERSION=latest

# SSL
ACME_EMAIL=admin@yourdomain.com

# Monitoring
GRAFANA_PASSWORD=secure_password
```

### Scaling

Edit `docker-stack.yml` or use commands:

```bash
# Scale services
docker service scale socialtrend_backend=5
docker service scale socialtrend_automation=5
docker service scale socialtrend_frontend=3

# Check current scale
docker service ls

# Update service
docker service update --replicas 10 socialtrend_backend
```

## Deployment Steps

### 1. Initialize Swarm

```bash
# On manager node
docker swarm init

# Get join token
docker swarm join-token worker

# On worker nodes
docker swarm join --token SWMTKN-xxx MANAGER_IP:2377
```

### 2. Deploy Stack

```bash
./deploy.sh production
```

This will:
- Pull latest images from registry
- Deploy all services
- Configure Traefik routing
- Set up SSL certificates
- Enable health checks

### 3. Verify Deployment

```bash
# Check services
docker service ls

# View logs
docker service logs socialtrend_backend

# Check Traefik dashboard
open http://localhost:8080
```

## Rolling Updates

### Update Single Service

```bash
# Update backend
docker service update \
  --image ghcr.io/gishella-46/socialtrend-backend:v2.0 \
  socialtrend_backend
```

### Update All Services

```bash
# Redeploy stack
docker stack deploy -c docker-stack.yml socialtrend

# Or use deploy script
./deploy.sh production
```

### Rollback

```bash
# Automatic rollback on failure
# Or manual rollback:
docker service rollback socialtrend_backend
```

## Monitoring

### Service Health

```bash
# Service status
docker service ls

# Task status
docker service ps socialtrend_backend

# Service inspection
docker service inspect socialtrend_backend
```

### Logs

```bash
# All tasks
docker service logs socialtrend_backend

# Follow logs
docker service logs -f socialtrend_backend

# Specific task
docker service logs socialtrend_backend --task TASK_ID
```

### Metrics

- **Prometheus**: http://manager-node:9090
- **Grafana**: http://manager-node:3000
- **Traefik Dashboard**: http://manager-node:8080

## Troubleshooting

### Service Not Starting

```bash
# Check service state
docker service ps socialtrend_backend --no-trunc

# View logs
docker service logs socialtrend_backend --tail 100

# Check node resources
docker node ls
docker node inspect NODE_NAME
```

### High CPU/Memory

```bash
# Check resource usage
docker stats

# Scale up
docker service scale socialtrend_backend=10

# Add more nodes
docker swarm join-token worker
```

### SSL Issues

```bash
# Check Traefik logs
docker service logs socialtrend_traefik

# Verify certificates
docker exec $(docker ps -q -f name=traefik) ls -la /letsencrypt/

# Force certificate renewal
docker service update --force socialtrend_traefik
```

## Backup & Restore

Database backups run automatically via backup-cron service.

### Manual Backup

```bash
# Database backup
docker exec $(docker ps -q -f name=db) pg_dump -U socialtrend_user socialtrend_db > backup.sql

# Volume backup
docker run --rm -v socialtrend_db_data:/data -v $(pwd):/backup alpine tar czf /backup/db_backup.tar.gz /data
```

### Restore

```bash
# Database restore
cat backup.sql | docker exec -i $(docker ps -q -f name=db) psql -U socialtrend_user socialtrend_db

# Volume restore
docker run --rm -v socialtrend_db_data:/data -v $(pwd):/backup alpine tar xzf /backup/db_backup.tar.gz -C /
```

## Security Best Practices

1. **Use secrets** for sensitive data
2. **Restrict network access** with overlay networks
3. **Enable TLS** for all traffic
4. **Rotate certificates** regularly
5. **Monitor logs** for suspicious activity
6. **Keep images updated** with security patches

### Secrets Management

```bash
# Create secret
echo "my_secret" | docker secret create db_password -

# Use in service
docker service update \
  --secret-add source=db_password,target=/run/secrets/db_password \
  socialtrend_backend
```

## Production Checklist

- [ ] Swarm cluster with 3+ managers
- [ ] All nodes healthy
- [ ] Registry authentication configured
- [ ] Environment variables set
- [ ] SSL certificates issued
- [ ] Health checks passing
- [ ] Monitoring dashboards working
- [ ] Backup system tested
- [ ] Log aggregation working
- [ ] Alerting configured

## Maintenance

### Regular Tasks

- Monitor service health
- Update container images
- Rotate SSL certificates
- Review logs for errors
- Check resource usage
- Test backup/restore
- Update dependencies

### Zero-Downtime Updates

Docker Swarm supports zero-downtime updates with:
- Rolling updates
- Health checks
- Graceful shutdown
- Circuit breakers
- Automatic rollback

## Support

- [Docker Swarm Docs](https://docs.docker.com/engine/swarm/)
- [Traefik Docs](https://doc.traefik.io/traefik/)
- [Main Project README](../../README.md)

