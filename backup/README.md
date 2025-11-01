# Backup System Documentation

## Overview

Automated daily backup system for SocialTrend Automator with 7-day retention policy.

## Architecture

```
┌─────────────────┐
│  Cron Schedule  │
│  Daily @ 02:00  │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌──────────┐
│  DB     │ │  Logs    │
│  Backup │ │  Backup  │
└────┬────┘ └────┬─────┘
     │           │
     ▼           ▼
┌─────────────────────────┐
│  Local Storage          │
│  /backup/database/      │
│  /backup/logs/          │
└─────────────────────────┘
     │
     ▼
┌─────────────────────────┐
│  Optional: Cloud        │
│  AWS S3 / GCS          │
└─────────────────────────┘
```

## Features

- **Automated Daily Backups**: Runs at 02:00 every day
- **Database Backups**: PostgreSQL dumps with compression
- **Log Backups**: Nginx, Laravel, FastAPI, Celery logs
- **7-Day Retention**: Automatic cleanup of old backups
- **Cloud Upload**: Optional S3/GCS integration
- **Restore Script**: Quick database restoration

## Backup Schedule

| Time | Job | Description |
|------|-----|-------------|
| 02:00 | Database Backup | PostgreSQL dump + compression |
| 02:30 | Log Backup | Compress and archive logs |

## Files Structure

```
backup/
├── scripts/
│   ├── backup_db.sh      # Database backup script
│   ├── backup_logs.sh    # Log backup script
│   └── restore_db.sh     # Database restore script
├── database/             # Database backups (7-day retention)
│   └── db_YYYYMMDD_HHMMSS.sql.gz
├── logs/                 # Log backups (7-day retention)
│   └── logs_YYYYMMDD_HHMMSS.tar.gz
├── backup_db.log        # Database backup log
└── backup_logs.log      # Log backup log
```

## Usage

### Automatic Backups

Backups run automatically via cron job at 02:00 daily.

**Start backup service:**
```bash
docker-compose up -d backup-cron
```

**Check backup logs:**
```bash
# Database backup log
docker exec socialtrend_backup_cron tail -f /backup/backup_db.log

# Log backup log
docker exec socialtrend_backup_cron tail -f /backup/backup_logs.log
```

### Manual Backup

**Database backup:**
```bash
docker exec socialtrend_backup_cron /scripts/backup_db.sh
```

**Log backup:**
```bash
docker exec socialtrend_backup_cron /scripts/backup_logs.sh
```

### Restore Database

**List available backups:**
```bash
docker exec socialtrend_backup_cron ls -lh /backup/database/
```

**Restore from backup:**
```bash
docker exec socialtrend_backup_cron /scripts/restore_db.sh /backup/database/db_20241202_020000.sql.gz
```

## Configuration

### Retention Policy

Default: **7 days**

To change, edit `backup/scripts/backup_db.sh` and `backup/scripts/backup_logs.sh`:
```bash
RETENTION_DAYS=7  # Change to desired number of days
```

### Backup Schedule

Default: Daily at 02:00 (Database) and 02:30 (Logs)

To change, edit `docker-compose.yml`:
```yaml
command: >
  sh -c "
  ...
  echo '0 2 * * * /scripts/backup_db.sh >> /backup/backup_db.log 2>&1' | crontab - &&
  echo '30 2 * * * /scripts/backup_logs.sh >> /backup/backup_logs.log 2>&1' | crontab - &&
  ...
  "
```

**Cron Schedule Format:**
```
┌───────────── minute (0-59)
│ ┌─────────── hour (0-23)
│ │ ┌───────── day of month (1-31)
│ │ │ ┌─────── month (1-12)
│ │ │ │ ┌───── day of week (0-6, Sunday=0)
│ │ │ │ │
* * * * * command
```

**Examples:**
- Daily at 02:00: `0 2 * * *`
- Every 6 hours: `0 */6 * * *`
- Daily at 23:00: `0 23 * * *`

### Cloud Storage (Optional)

#### AWS S3

**Enable S3 backup:**
```bash
# Add to docker-compose.yml backup-cron environment
environment:
  - ENABLE_S3_BACKUP=true
  - S3_BUCKET=your-bucket-name
  - AWS_ACCESS_KEY_ID=your-key
  - AWS_SECRET_ACCESS_KEY=your-secret
  - AWS_DEFAULT_REGION=us-east-1
```

#### Google Cloud Storage

**Enable GCS backup:**
```bash
# Add to docker-compose.yml backup-cron environment
environment:
  - ENABLE_GCS_BACKUP=true
  - GCS_BUCKET=your-bucket-name
  # Add service account key as volume mount
```

## Monitoring

### Check Backup Status

```bash
# Recent backups
docker exec socialtrend_backup_cron ls -lht /backup/database/ | head -10
docker exec socialtrend_backup_cron ls -lht /backup/logs/ | head -10

# Backup size
docker exec socialtrend_backup_cron du -sh /backup/database/
docker exec socialtrend_backup_cron du -sh /backup/logs/

# Cron logs
docker logs socialtrend_backup_cron
```

### Verify Backup Integrity

```bash
# Extract and verify database backup
docker exec socialtrend_backup_cron gzip -l /backup/database/db_latest.sql.gz

# List contents of log backup
docker exec socialtrend_backup_cron tar -tzf /backup/logs/logs_latest.tar.gz
```

## Troubleshooting

### Backup Failed

**Check logs:**
```bash
docker logs socialtrend_backup_cron
docker exec socialtrend_backup_cron cat /backup/backup_db.log
```

**Common issues:**
- Database not accessible: Check `DB_HOST`, `DB_PORT` in environment
- Insufficient disk space: Check with `df -h`
- Permission issues: Ensure scripts are executable (`chmod +x`)

### Restore Failed

**Check restore logs:**
```bash
docker exec socialtrend_backup_cron /scripts/restore_db.sh /path/to/backup.sql.gz
```

**Common issues:**
- Wrong database credentials
- Backup file corrupted: Check with `gzip -t`
- Insufficient database size

### Cron Not Running

**Verify cron service:**
```bash
# Check if cron is running
docker exec socialtrend_backup_cron ps aux | grep crond

# Check cron schedule
docker exec socialtrend_backup_cron crontab -l

# Restart cron service
docker-compose restart backup-cron
```

## Best Practices

### Backup Storage

1. **Local**: Keep recent backups (7 days) for quick restore
2. **Cloud**: Archive older backups for disaster recovery
3. **Offsite**: Maintain backups in separate location
4. **Test Restore**: Periodically test restore procedure

### Security

1. **Encrypt backups**: Use `openssl` or similar
2. **Secure storage**: Restrict access to backup directories
3. **Credential management**: Use environment variables
4. **Audit logs**: Monitor backup access

### Performance

1. **Compression**: Always use gzip (default enabled)
2. **Schedule**: Run during low-traffic hours (02:00)
3. **Retention**: Balance storage vs recovery needs
4. **Monitoring**: Alert on backup failures

## Additional Resources

- [PostgreSQL Backup Documentation](https://www.postgresql.org/docs/current/backup.html)
- [Cron Guide](https://en.wikipedia.org/wiki/Cron)
- [AWS S3 Backup](https://aws.amazon.com/s3/)
- [Google Cloud Storage](https://cloud.google.com/storage)

