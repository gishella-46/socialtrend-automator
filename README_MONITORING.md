# 🚀 Prometheus & Grafana Monitoring Setup

## Quick Start

1. **Start services:**
   ```bash
   docker-compose up -d prometheus grafana redis-exporter
   ```

2. **Access Grafana:**
   - URL: http://localhost:3000
   - Username: `admin`
   - Password: `admin` (change in production!)

3. **Access Prometheus:**
   - URL: http://localhost:9090

## Services

### Prometheus
- Collects metrics from Laravel, FastAPI, and Redis
- Retention: 30 days
- Port: 9090

### Grafana
- Visualizes metrics in dashboards
- Alerting for error rate > 5%
- Port: 3000

### Redis Exporter
- Exports Redis metrics to Prometheus
- Port: 9121

## Metrics Endpoints

### Laravel Backend
- **Endpoint**: `http://localhost/api/metrics`
- **Library**: `arkaitzgarro/laravel-prometheus-exporter`

### FastAPI Automation
- **Endpoint**: `http://localhost/automation/metrics`
- **Library**: `prometheus-fastapi-instrumentator`

### Redis
- **Endpoint**: `http://localhost:9121/metrics` (via redis-exporter)

## Dashboard Panels

1. ✅ API Request Rate (Laravel)
2. ✅ API Latency (P95)
3. ✅ API Error Rate (with alert if > 5%)
4. ✅ Upload Success Rate
5. ✅ FastAPI Request Rate
6. ✅ FastAPI Latency
7. ✅ Celery Task Duration
8. ✅ Celery Queue Backlog
9. ✅ Redis Memory Usage
10. ✅ Active Users
11. ✅ Total API Requests

## Alerting

### Error Rate Alert
- **Condition**: Error rate > 5%
- **Duration**: 5 minutes
- **Notifications**: Email & Slack (configurable)

### Setup Notifications

1. **Email**: Update `docker/grafana/provisioning/notifiers/notifiers.yml`
2. **Slack**: Set `SLACK_WEBHOOK_URL` environment variable

## Next Steps

1. Install dependencies:
   ```bash
   docker exec socialtrend_backend composer install
   docker exec socialtrend_automation pip install -r requirements.txt
   ```

2. Restart services:
   ```bash
   docker-compose restart backend automation
   ```

3. Verify metrics:
   - Check Prometheus targets: http://localhost:9090/targets
   - View dashboard: http://localhost:3000

## Documentation

See `docs/MONITORING.md` for detailed setup and troubleshooting.








