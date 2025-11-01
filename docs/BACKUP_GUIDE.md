# Automated Backup System Guide

## Quick Start

The backup system runs automatically every day at 02:00. No manual configuration needed!

## What Gets Backed Up

### Database Backups
- **PostgreSQL database** (socialtrend_db)
- **Format**: SQL dump with gzip compression
- **Location**: `/backup/database/db_YYYYMMDD_HHMMSS.sql.gz`
- **Schedule**: Daily at 02:00

### Log Backups
- **Nginx logs**: Access and error logs
- **Laravel logs**: Application logs
- **FastAPI logs**: Service logs
- **Celery logs**: Worker logs
- **Format**: tar.gz archive
- **Location**: `/backup/logs/logs_YYYYMMDD_HHMMSS.tar.gz`
- **Schedule**: Daily at 02:30

## Quick Commands

### Start Backup Service
```bash
docker-compose up -d backup-cron
```

### Check Backup Status
```bash
# List database backups
docker exec socialtrend_backup_cron ls -lh /backup/database/

# List log backups
docker exec socialtrend_backup_cron ls -lh /backup/logs/

# Check backup logs
docker exec socialtrend_backup_cron tail -f /backup/backup_db.log
```

### Manual Backup
```bash
# Database
docker exec socialtrend_backup_cron /scripts/backup_db.sh

# Logs
docker exec socialtrend_backup_cron /scripts/backup_logs.sh
```

### Restore Database
```bash
# List available backups
docker exec socialtrend_backup_cron ls -lh /backup/database/

# Restore
docker exec socialtrend_backup_cron /scripts/restore_db.sh /backup/database/db_20241202_020000.sql.gz
```

## File Structure

```
backup/
├── scripts/
│   ├── backup_db.sh       # Database backup
│   ├── backup_logs.sh     # Log backup
│   └── restore_db.sh      # Restore script
├── database/              # Database backups
│   └── db_YYYYMMDD_HHMMSS.sql.gz
├── logs/                  # Log backups
│   └── logs_YYYYMMDD_HHMMSS.tar.gz
├── backup_db.log         # Backup execution log
└── backup_logs.log       # Log backup execution log
```

## Configuration

### Change Backup Time

Edit `docker-compose.yml`:
```yaml
command: >
  sh -c "
  apk add --no-cache dcron bash &&
  chmod +x /scripts/*.sh &&
  echo '0 YOUR_HOUR * * * /scripts/backup_db.sh ...' | crontab - &&
  echo '30 YOUR_HOUR * * * /scripts/backup_logs.sh ...' | crontab - &&
  crond -f -l 8
  "
```

### Change Retention Period

Edit `backup/scripts/backup_db.sh` and `backup/scripts/backup_logs.sh`:
```bash
RETENTION_DAYS=7  # Change to desired days
```

### Enable Cloud Storage

Edit `docker-compose.yml` environment:
```yaml
environment:
  - ENABLE_S3_BACKUP=true
  - S3_BUCKET=your-bucket-name
  - AWS_ACCESS_KEY_ID=your-key
  - AWS_SECRET_ACCESS_KEY=your-secret
```

## Troubleshooting

See `backup/README.md` for detailed troubleshooting guide.

## More Information

- Full documentation: `backup/README.md`
- Docker Compose config: `docker-compose.yml`
- Scripts location: `backup/scripts/`

