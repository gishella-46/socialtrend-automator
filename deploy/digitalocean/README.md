# DigitalOcean Apps Deployment Guide

Managed platform deployment on DigitalOcean App Platform.

## Prerequisites

- DigitalOcean account
- doctl CLI installed
- GitHub repository connected
- App Platform access

## Architecture

### Components

1. **Backend Service**: 3 instances, professional-xs
2. **Automation Service**: 3 instances, professional-xs
3. **Frontend Service**: 2 instances, basic-xxs
4. **PostgreSQL Database**: Managed cluster
5. **Redis Database**: Managed cluster
6. **Load Balancer**: Automatic HTTPS

### Managed Services

- Database clusters
- Redis clusters
- Managed backups
- DDoS protection
- Auto-scaling
- Monitoring

## Quick Start

```bash
# Authenticate
doctl auth init

# Create app
doctl apps create --spec apps.yaml

# Check status
doctl apps list
```

## Configuration

### apps.yaml

Key settings:

- **instance_count**: Number of replicas
- **instance_size_slug**: Size (basic-xxs, professional-xs, etc.)
- **health_check**: Path and timing
- **envs**: Environment variables
- **alerts**: Auto-scaling triggers
- **routes**: URL routing

### Environment Variables

Configure in Apps dashboard or apps.yaml:

```yaml
envs:
  - key: DB_HOST
    scope: RUN_TIME
    value: ${db.DATABASE_HOST}  # Reference managed database
  - key: DB_PASSWORD
    scope: RUN_TIME
    type: SECRET                 # Secret variable
    value: ${db.DATABASE_PASSWORD}
```

## Deployment

### Manual Deployment

```bash
# Create app from spec
doctl apps create --spec apps.yaml

# Get app ID
APP_ID=$(doctl apps list -o json | jq -r '.[0].id')

# Create deployment
doctl apps create-deployment $APP_ID

# Check status
doctl apps get-deployment $APP_ID DEPLOYMENT_ID
```

### GitHub Integration

Apps Platform automatically deploys on:
- Push to main branch
- Tagged releases
- Manual triggers

Configure in Apps dashboard:
1. Go to Settings → Integrations
2. Connect GitHub repository
3. Enable auto-deploy
4. Configure branch/tag filters

## Auto Scaling

### Automatic Scaling

Configured in apps.yaml:

```yaml
alerts:
  - rule: CPU_UTILIZATION
    disabled: false
    value: 80
  - rule: MEM_UTILIZATION
    disabled: false
    value: 80
```

### Manual Scaling

```bash
# Update instance count
doctl apps update $APP_ID --spec apps.yaml

# Scale service
doctl apps update $APP_ID \
  --components '{"name":"backend","instance_count":5}'
```

## Database Management

### PostgreSQL

```bash
# Create database cluster
doctl databases create socialtrend-db \
  --engine pg \
  --region nyc1 \
  --size db-s-1vcpu-1gb

# Get connection info
doctl databases connection socialtrend-db

# Create backups
doctl databases backup-create socialtrend-db
```

### Redis

```bash
# Create Redis cluster
doctl databases create socialtrend-redis \
  --engine redis \
  --region nyc1 \
  --size db-s-1vcpu-1gb

# Get connection info
doctl databases connection socialtrend-redis
```

## Monitoring

### Metrics

Available in Apps dashboard:
- CPU utilization
- Memory usage
- Request count
- Response time
- Error rate
- Network traffic

### Alerts

Configured in apps.yaml:

```yaml
alerts:
  - rule: CPU_UTILIZATION
    disabled: false
    value: 80
  - rule: DEPLOYMENT_FAILED
    disabled: false
  - rule: DOMAIN_FAILED
    disabled: false
```

### Logs

```bash
# View logs
doctl apps logs $APP_ID --component backend

# Follow logs
doctl apps logs $APP_ID --component backend --follow

# Filter by type
doctl apps logs $APP_ID --component backend --type run
```

## Custom Domains

```bash
# Add domain
doctl apps create-domain $APP_ID yourdomain.com

# Verify ownership (check email or DNS)

# Enable HTTPS
doctl apps create-alert $APP_ID \
  --type DOMAIN_FAILED \
  --email your@email.com
```

## Cost Optimization

### Pricing

- **Backend**: $12/month per instance (professional-xs)
- **Frontend**: $5/month per instance (basic-xxs)
- **PostgreSQL**: $15/month (db-s-1vcpu-1gb)
- **Redis**: $15/month (db-s-1vcpu-1gb)

**Estimated Total**: ~$150/month (default config)

### Recommendations

1. Right-size based on usage
2. Use basic-xxs for non-critical services
3. Enable auto-scaling
4. Monitor resource usage
5. Optimize application code

## Security

### Secrets Management

```bash
# Add secret
doctl apps create-alert $APP_ID \
  --type DEPLOYMENT_FAILED

# View secrets
doctl apps get $APP_ID | jq '.spec.services[].envs'
```

### Network Security

- Built-in DDoS protection
- Firewall rules
- Private networking
- SSL/TLS termination

## Troubleshooting

### Deployment Failed

```bash
# Check deployment logs
doctl apps get-deployment $APP_ID DEPLOYMENT_ID

# View service logs
doctl apps logs $APP_ID --component backend --type run

# Check build logs
doctl apps logs $APP_ID --component backend --type build
```

### High Costs

```bash
# Check resource usage
doctl apps get $APP_ID | jq '.spec.services[].instance_count'

# Scale down
doctl apps update $APP_ID --spec apps.yaml

# Review alerts
doctl apps list-alerts $APP_ID
```

## CLI Commands

### Common Operations

```bash
# List apps
doctl apps list

# Get app details
doctl apps get $APP_ID

# List deployments
doctl apps list-deployments $APP_ID

# Get deployment logs
doctl apps get-deployment $APP_ID $DEPLOYMENT_ID

# Update app
doctl apps update $APP_ID --spec apps.yaml

# Delete app
doctl apps delete $APP_ID

# Restart service
doctl apps create-deployment $APP_ID
```

## Deployment Checklist

- [ ] DigitalOcean account created
- [ ] doctl CLI installed and authenticated
- [ ] apps.yaml configured
- [ ] Environment variables set
- [ ] Database clusters created
- [ ] Redis cluster created
- [ ] GitHub repository connected
- [ ] Auto-deploy enabled
- [ ] Health checks configured
- [ ] Custom domain added
- [ ] SSL enabled
- [ ] Monitoring configured
- [ ] Alerts set up
- [ ] Backups enabled
- [ ] Logs accessible

## References

- [App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [App Platform Pricing](https://www.digitalocean.com/pricing/app-platform)
- [doctl CLI Docs](https://docs.digitalocean.com/reference/doctl/)

