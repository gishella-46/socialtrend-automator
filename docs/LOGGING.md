# ELK Stack Integration - Centralized Logging

## Overview

SocialTrend Automator uses the ELK Stack (Elasticsearch + Logstash + Kibana) for centralized logging. All logs from Laravel, FastAPI, and Nginx are collected, processed, and visualized in Kibana.

## Architecture

```
┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
│ Laravel │ ─UDP→│          │      │          │      │          │
│ (5044)  │      │ Logstash │ ───→ │Elasticsearch│ ←─ │  Kibana  │
└──────────┘      │          │      │          │      │          │
                  │          │ ←─── │          │      │          │
┌──────────┐      │          │      └──────────┘      └──────────┘
│ FastAPI  │ ─TCP→│          │           ▲
│ (5000)   │      └──────────┘           │
└──────────┘           ▲                │
                        │                │
                  ┌─────┴─────┐          │
                  │   Nginx   │          │
                  │  (files)  │          │
                  └───────────┘          │
                                        │
                        Logs stored in Elasticsearch
```

## Services

### Elasticsearch (Port 9200)
- Stores all logs in indices: `socialtrend-logs-YYYY.MM.DD`
- Single-node setup for development
- Disabled security for easier access

### Logstash (Ports 5044, 5000)
- Receives Laravel logs via UDP (5044)
- Receives FastAPI logs via TCP (5000)
- Reads Nginx logs from shared volume
- Processes and filters logs
- Sends to Elasticsearch

### Kibana (Port 5601)
- Web UI for log visualization
- Filter by user_id, endpoint, status_code
- Real-time log streaming
- Dashboard creation

## Configuration

### Laravel Logging

**File:** `backend/config/logging.php`

- **Daily Channel**: Rotates logs daily (14 days retention)
- **Logstash Channel**: Sends logs to Logstash via UDP (5044) in JSON format

```php
'logstash' => [
    'driver' => 'monolog',
    'handler' => SyslogUdpHandler::class,
    'handler_with' => [
        'host' => env('LOGSTASH_HOST', 'logstash'),
        'port' => env('LOGSTASH_PORT', 5044),
    ],
    'formatter' => \Monolog\Formatter\JsonFormatter::class,
],
```

### FastAPI Logging

**File:** `automation/app/utils/logging.py`

- **JSON Format**: Structured logging with CustomJsonFormatter
- **Logstash TCP Handler**: Sends logs to Logstash via TCP (5000)
- **Fallback**: Console logging if Logstash unavailable

Environment variables:
- `LOGSTASH_ENABLED=true` (default)
- `LOGSTASH_HOST=logstash` (default)
- `LOGSTASH_PORT=5000` (default)

### Nginx Logging

**File:** `docker/nginx/nginx.conf`

- **JSON Format**: Access logs in JSON format
- **Shared Volume**: Logs accessible to Logstash container
- **Paths**: `/var/log/nginx/access.log` and `/var/log/nginx/error.log`

### Logstash Pipeline

**File:** `docker/logstash/pipeline/logstash.conf`

**Inputs:**
- UDP 5044: Laravel logs
- TCP 5000: FastAPI logs
- File: Nginx access and error logs

**Filters:**
- Extracts `user_id` from context/extra fields
- Extracts `endpoint` from route/path
- Extracts `status_code` from context/response
- Adds `service` field (laravel/fastapi/nginx)

**Output:**
- Elasticsearch: `socialtrend-logs-YYYY.MM.DD` indices

## Usage

### Starting ELK Stack

```bash
docker-compose up -d elasticsearch logstash kibana
```

Wait for services to be healthy:
```bash
docker-compose ps
```

### Accessing Kibana

1. Open http://localhost:5601
2. Go to **Stack Management** → **Index Patterns**
3. Create index pattern: `socialtrend-logs-*`
4. Select `@timestamp` as time field
5. Explore logs in **Discover**

### Filtering Logs

#### By User ID
```
user_id:123
```

#### By Endpoint
```
endpoint:"/api/upload"
```

#### By Status Code
```
status_code:500
```

#### By Service
```
service:"laravel"
service:"fastapi"
service:"nginx"
```

#### Combined Filters
```
service:"laravel" AND status_code:500 AND user_id:123
```

### Viewing Specific Log Types

#### Laravel Logs
```
service:"laravel"
```

#### FastAPI Logs
```
service:"fastapi"
```

#### Nginx Access Logs
```
service:"nginx" AND type:"nginx_access"
```

#### Nginx Error Logs
```
service:"nginx" AND type:"nginx_error"
```

## Index Management

Logs are stored with daily indices:
- `socialtrend-logs-2024.12.01`
- `socialtrend-logs-2024.12.02`
- etc.

To delete old indices:
```bash
curl -X DELETE "localhost:9200/socialtrend-logs-2024.11.*"
```

## Troubleshooting

### Logs Not Appearing in Kibana

1. Check Logstash is running:
   ```bash
   docker logs socialtrend_logstash
   ```

2. Check Elasticsearch indices:
   ```bash
   curl http://localhost:9200/_cat/indices?v
   ```

3. Check Logstash pipeline status:
   ```bash
   curl http://localhost:9600/_node/stats/pipelines?pretty
   ```

### Laravel Logs Not Reaching Logstash

1. Verify UDP port 5044 is open:
   ```bash
   docker exec socialtrend_logstash netstat -tuln | grep 5044
   ```

2. Check Laravel logging channel:
   ```bash
   docker logs socialtrend_backend | grep logstash
   ```

### FastAPI Logs Not Reaching Logstash

1. Verify TCP connection:
   ```bash
   docker exec socialtrend_automation python -c "import socket; s = socket.socket(); s.connect(('logstash', 5000)); print('Connected')"
   ```

2. Check LOGSTASH_ENABLED environment variable:
   ```bash
   docker exec socialtrend_automation env | grep LOGSTASH
   ```

### Elasticsearch Health

Check cluster health:
```bash
curl http://localhost:9200/_cluster/health?pretty
```

Should return `"status" : "green"` or `"yellow"` (yellow is OK for single-node).

## Production Considerations

1. **Security**: Enable X-Pack security for Elasticsearch
2. **Persistence**: Configure proper data retention policies
3. **Resources**: Increase Elasticsearch heap size for production
4. **SSL/TLS**: Enable SSL for Elasticsearch and Kibana
5. **Authentication**: Set up Kibana authentication
6. **Index Templates**: Configure index templates for better performance
7. **Backup**: Regular snapshots of Elasticsearch indices

## Environment Variables

### Laravel
```env
LOG_CHANNEL=daily
LOG_LEVEL=debug
LOGSTASH_HOST=logstash
LOGSTASH_PORT=5044
```

### FastAPI
```env
LOG_LEVEL=INFO
LOGSTASH_ENABLED=true
LOGSTASH_HOST=logstash
LOGSTASH_PORT=5000
```

## Resources

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Logstash Documentation](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)








