#!/bin/bash

# Log Files Backup Script
# Compress and backup important logs with 7-day retention
# Usage: ./backup_logs.sh

set -e  # Exit on error

# Configuration
BACKUP_DIR="/backup/logs"
RETENTION_DAYS=7

# Log sources
NGINX_LOGS="/var/log/nginx"
LARAVEL_LOGS="/var/www/html/storage/logs"
FASTAPI_LOGS="/app/logs"
CELERY_LOGS="/app/celery.log"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_BACKUP_FILE="${BACKUP_DIR}/logs_${TIMESTAMP}.tar.gz"

echo "========================================="
echo "Starting Log Files Backup"
echo "Timestamp: ${TIMESTAMP}"
echo "========================================="

# Create temporary directory for collecting logs
TEMP_DIR=$(mktemp -d)
echo "Temp directory: ${TEMP_DIR}"

# Function to copy logs if they exist
copy_logs_if_exists() {
  local source_dir=$1
  local dest_dir=$2
  
  if [ -d "${source_dir}" ]; then
    echo "Copying logs from: ${source_dir}"
    cp -r "${source_dir}" "${dest_dir}" 2>/dev/null || true
  else
    echo "âš ï¸  Directory not found (skipping): ${source_dir}"
  fi
}

# Collect logs
echo "Collecting logs..."

# Nginx logs
if [ -d "${NGINX_LOGS}" ]; then
  copy_logs_if_exists "${NGINX_LOGS}" "${TEMP_DIR}/nginx"
else
  echo "âš ï¸  Nginx logs directory not found"
fi

# Laravel logs
if [ -d "${LARAVEL_LOGS}" ]; then
  copy_logs_if_exists "${LARAVEL_LOGS}" "${TEMP_DIR}/laravel"
else
  echo "âš ï¸  Laravel logs directory not found"
fi

# FastAPI logs
if [ -d "${FASTAPI_LOGS}" ]; then
  copy_logs_if_exists "${FASTAPI_LOGS}" "${TEMP_DIR}/fastapi"
else
  echo "âš ï¸  FastAPI logs directory not found"
fi

# Celery logs
if [ -f "${CELERY_LOGS}" ]; then
  mkdir -p "${TEMP_DIR}/celery"
  cp "${CELERY_LOGS}" "${TEMP_DIR}/celery/" 2>/dev/null || true
  echo "Copied Celery logs"
fi

# Create compressed archive
echo "========================================="
echo "Creating compressed archive..."
echo "========================================="

# Only create archive if there's content
if [ "$(ls -A ${TEMP_DIR})" ]; then
  cd "${TEMP_DIR}"
  tar -czf "${LOG_BACKUP_FILE}" *
  cd -
  
  # Verify archive
  if [ -f "${LOG_BACKUP_FILE}" ]; then
    BACKUP_SIZE=$(du -h "${LOG_BACKUP_FILE}" | cut -f1)
    echo "========================================="
    echo "âœ… Log backup completed successfully!"
    echo "File: ${LOG_BACKUP_FILE}"
    echo "Size: ${BACKUP_SIZE}"
    echo "========================================="
  else
    echo "âŒ ERROR: Log backup file not created!"
    rm -rf "${TEMP_DIR}"
    exit 1
  fi
else
  echo "âš ï¸  No logs found to backup, skipping..."
fi

# Cleanup temp directory
rm -rf "${TEMP_DIR}"

# Cleanup old backups (older than retention days)
echo "========================================="
echo "Cleaning up backups older than ${RETENTION_DAYS} days..."
echo "========================================="

find "${BACKUP_DIR}" \
  -name "logs_*.tar.gz" \
  -type f \
  -mtime +${RETENTION_DAYS} \
  -delete

echo "âœ… Cleanup completed"

# List current log backups
echo "========================================="
echo "Current log backups:"
echo "========================================="
ls -lh "${BACKUP_DIR}"/logs_*.tar.gz 2>/dev/null || echo "No log backups found"

# Optional: Upload to cloud storage
if [ "${ENABLE_S3_BACKUP}" = "true" ] && [ -n "${S3_BUCKET}" ]; then
  echo "========================================="
  echo "Uploading to S3: ${S3_BUCKET}"
  echo "========================================="
  
  if ! command -v aws &> /dev/null; then
    apk add --no-cache aws-cli 2>/dev/null || apt-get update && apt-get install -y awscli 2>/dev/null
  fi
  
  S3_PATH="s3://${S3_BUCKET}/backups/logs/${TIMESTAMP}.tar.gz"
  aws s3 cp "${LOG_BACKUP_FILE}" "${S3_PATH}"
  echo "âœ… Uploaded to S3: ${S3_PATH}"
fi

if [ "${ENABLE_GCS_BACKUP}" = "true" ] && [ -n "${GCS_BUCKET}" ]; then
  echo "========================================="
  echo "Uploading to GCS: ${GCS_BUCKET}"
  echo "========================================="
  
  if ! command -v gsutil &> /dev/null; then
    curl https://sdk.cloud.google.com | bash
  fi
  
  GCS_PATH="gs://${GCS_BUCKET}/backups/logs/${TIMESTAMP}.tar.gz"
  gsutil cp "${LOG_BACKUP_FILE}" "${GCS_PATH}"
  echo "âœ… Uploaded to GCS: ${GCS_PATH}"
fi

echo "========================================="
echo "âœ… Log backup process completed!"
echo "========================================="

