#!/bin/bash

# PostgreSQL Database Backup Script
# Daily backup with 7-day retention
# Usage: ./backup_db.sh

set -e  # Exit on error

# Configuration
BACKUP_DIR="/backup/database"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-socialtrend_db}"
DB_USER="${POSTGRES_USER:-socialtrend_user}"
DB_PASSWORD="${POSTGRES_PASSWORD:-socialtrend_pass}"
RETENTION_DAYS=7

# Create backup directory if not exists
mkdir -p "${BACKUP_DIR}"

# Generate backup filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/db_${TIMESTAMP}.sql.gz"

# Export password for pg_dump (no prompt)
export PGPASSWORD="${DB_PASSWORD}"

echo "========================================="
echo "Starting PostgreSQL Backup"
echo "Timestamp: ${TIMESTAMP}"
echo "Database: ${DB_NAME}"
echo "========================================="

# Perform database dump with compression
pg_dump \
  -h "${DB_HOST}" \
  -p "${DB_PORT}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  -F c \
  -Z 9 \
  -v \
  -f "${BACKUP_FILE}"

# If pg_dump compression not available, use gzip
if [ ! -f "${BACKUP_FILE}" ]; then
  echo "Using alternative pg_dump + gzip method..."
  DUMP_FILE="${BACKUP_DIR}/db_${TIMESTAMP}.sql"
  pg_dump \
    -h "${DB_HOST}" \
    -p "${DB_PORT}" \
    -U "${DB_USER}" \
    -d "${DB_NAME}" \
    -F p \
    -v \
    -f "${DUMP_FILE}"
  
  # Compress with gzip
  gzip "${DUMP_FILE}"
  BACKUP_FILE="${DUMP_FILE}.gz"
fi

# Verify backup file exists and has content
if [ -f "${BACKUP_FILE}" ]; then
  BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
  echo "========================================="
  echo "âœ… Backup completed successfully!"
  echo "File: ${BACKUP_FILE}"
  echo "Size: ${BACKUP_SIZE}"
  echo "========================================="
else
  echo "âŒ ERROR: Backup file not created!"
  exit 1
fi

# Cleanup old backups (older than retention days)
echo "========================================="
echo "Cleaning up backups older than ${RETENTION_DAYS} days..."
echo "========================================="

find "${BACKUP_DIR}" \
  -name "db_*.sql.gz" \
  -type f \
  -mtime +${RETENTION_DAYS} \
  -delete

echo "âœ… Cleanup completed"

# List current backups
echo "========================================="
echo "Current backups:"
echo "========================================="
ls -lh "${BACKUP_DIR}"/*.sql.gz 2>/dev/null || echo "No backups found"

# Optional: Upload to S3 or Cloud Storage
if [ "${ENABLE_S3_BACKUP}" = "true" ] && [ -n "${S3_BUCKET}" ]; then
  echo "========================================="
  echo "Uploading to S3: ${S3_BUCKET}"
  echo "========================================="
  
  # Install AWS CLI if not present
  if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    apk add --no-cache aws-cli 2>/dev/null || apt-get update && apt-get install -y awscli 2>/dev/null
  fi
  
  S3_PATH="s3://${S3_BUCKET}/backups/database/${TIMESTAMP}.sql.gz"
  aws s3 cp "${BACKUP_FILE}" "${S3_PATH}"
  echo "âœ… Uploaded to S3: ${S3_PATH}"
fi

# Optional: Upload to Google Cloud Storage
if [ "${ENABLE_GCS_BACKUP}" = "true" ] && [ -n "${GCS_BUCKET}" ]; then
  echo "========================================="
  echo "Uploading to GCS: ${GCS_BUCKET}"
  echo "========================================="
  
  # Install gsutil if not present
  if ! command -v gsutil &> /dev/null; then
    echo "Installing Google Cloud SDK..."
    curl https://sdk.cloud.google.com | bash
  fi
  
  GCS_PATH="gs://${GCS_BUCKET}/backups/database/${TIMESTAMP}.sql.gz"
  gsutil cp "${BACKUP_FILE}" "${GCS_PATH}"
  echo "âœ… Uploaded to GCS: ${GCS_PATH}"
fi

echo "========================================="
echo "âœ… Backup process completed!"
echo "========================================="

