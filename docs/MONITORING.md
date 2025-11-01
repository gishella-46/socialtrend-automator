# Monitoring Setup Guide

## Overview

SocialTrend Automator uses Prometheus for metrics collection and Grafana for visualization and alerting.

## Services

### Prometheus
- **URL**: http://localhost:9090
- **Purpose**: Metrics collection and storage
- **Retention**: 30 days

### Grafana
- **URL**: http://localhost:3000
- **Default Credentials**: 
  - Username: `admin`
  - Password: `admin`
- **Purpose**: Dashboards and alerting

## Metrics Endpoints

### Laravel Backend
- **Endpoint**: `/api/metrics`
- **Library**: `arkaitzgarro/laravel-prometheus-exporter`
- **Metrics**:
  - `http_requests_total` - Total HTTP requests
  - `http_request_duration_seconds` - Request latency
  - `http_errors_total` - Error count
  - `upload_operations_total` - Upload operations

### FastAPI Automation
- **Endpoint**: `/metrics`
- **Library**: `prometheus-fastapi-instrumentator`
- **Auto-collects**:
  - Request rate
  - Response time
  - Error rate

### Redis
- **Endpoint**: `redis-exporter:9121/metrics`
- **Metrics**: Memory usage, connections, commands

## Grafana Dashboard

The dashboard includes the following panels:

1. **API Request Rate (Laravel)** - Requests per second
2. **API Latency (P95)** - 95th percentile response time
3. **API Error Rate** - 4xx and 5xx errors
4. **Upload Success Rate** - Percentage of successful uploads
5. **FastAPI Request Rate** - FastAPI endpoint metrics
6. **FastAPI Latency** - FastAPI response times
7. **Celery Task Duration** - Background task execution time
8. **Celery Queue Backlog** - Number of pending tasks
9. **Redis Memory Usage** - Redis memory consumption
10. **Active Users** - Active users in last 5 minutes
11. **Total API Requests** - Request count in last hour

## Alerting

### Error Rate Alert
- **Condition**: Error rate > 5%
- **Threshold**: 5% of total requests
- **Duration**: 5 minutes
- **Notifications**: Email and/or Slack

### Setup Email Alerts

1. Update `docker/grafana/provisioning/notifiers/notifiers.yml`:
   - Set your SMTP server details
   - Set email addresses

2. Restart Grafana:
   ```bash
   docker-compose restart grafana
   ```

### Setup Slack Alerts

1. Create a Slack webhook URL
2. Update environment variables:
   ```env
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
   ```
3. Restart Grafana

## Accessing Metrics

### Prometheus Query Examples

```promql
# Request rate
rate(http_requests_total{job="laravel"}[5m])

# Error rate
rate(http_requests_total{job="laravel",status=~"5.."}[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="laravel"}[5m]))

# Upload success rate
sum(rate(upload_operations_total{status="success"}[5m])) / sum(rate(upload_operations_total[5m])) * 100
```

## Troubleshooting

### Metrics not appearing
1. Check Prometheus targets: http://localhost:9090/targets
2. Verify services are exposing `/metrics` endpoints
3. Check Prometheus logs: `docker logs socialtrend_prometheus`

### Grafana dashboard empty
1. Verify Prometheus datasource is configured
2. Check dashboard queries match available metrics
3. Ensure Prometheus is scraping metrics successfully

### Alerts not firing
1. Check alert rules in Grafana UI
2. Verify notification channels are configured
3. Check Grafana logs: `docker logs socialtrend_grafana`

## Production Setup

1. **Change default Grafana password**:
   - Login to Grafana
   - Go to Administration > Users
   - Change admin password

2. **Configure SMTP/Slack**:
   - Update notifier configuration
   - Test alert notifications

3. **Customize dashboards**:
   - Export dashboards as JSON
   - Version control dashboard files

4. **Monitor Prometheus storage**:
   - Check disk usage
   - Adjust retention if needed








