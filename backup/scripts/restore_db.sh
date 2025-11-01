#!/bin/bash

# PostgreSQL Database Restore Script
# Restore database from backup file
# Usage: ./restore_db.sh [backup_file.sql.gz]

set -e  # Exit on error

# Configuration
BACKUP_DIR="/backup/database"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-socialtrend_db}"
DB_USER="${POSTGRES_USER:-socialtrend_user}"
DB_PASSWORD="${POSTGRES_PASSWORD:-socialtrend_pass}"

echo "========================================="
echo "PostgreSQL Database Restore"
echo "========================================="

# Check if backup file is provided
if [ -z "$1" ]; then
  echo "âŒ ERROR: No backup file specified!"
  echo ""
  echo "Usage: ./restore_db.sh [backup_file]"
  echo ""
  echo "Available backups:"
  ls -lh "${BACKUP_DIR}"/*.sql.gz 2>/dev/null || echo "No backups found"
  exit 1
fi

BACKUP_FILE="$1"

# Check if file exists
if [ ! -f "${BACKUP_FILE}" ]; then
  echo "âŒ ERROR: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

echo "Backup file: ${BACKUP_FILE}"
echo "Database: ${DB_NAME}"
echo "Host: ${DB_HOST}:${DB_PORT}"
echo ""
read -p "âš ï¸  WARNING: This will REPLACE all data in ${DB_NAME}. Continue? (yes/no): " CONFIRM

if [ "${CONFIRM}" != "yes" ]; then
  echo "Restore cancelled by user."
  exit 0
fi

# Export password for psql/pg_restore
export PGPASSWORD="${DB_PASSWORD}"

echo "========================================="
echo "Starting database restore..."
echo "========================================="

# Check if file is compressed
if [[ "${BACKUP_FILE}" == *.gz ]]; then
  echo "Detected compressed backup, extracting..."
  
  # Check if backup uses custom format (pg_dump -Fc)
  if gunzip -c "${BACKUP_FILE}" | head -c 5 | grep -q "PGDMP" 2>/dev/null; then
    echo "Detected custom format backup (.sql.gz with custom format)"
    gunzip -c "${BACKUP_FILE}" > "/tmp/restore_temp.sql"
    
    # Drop database and recreate
    echo "Dropping existing database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true
    
    echo "Creating new database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "CREATE DATABASE ${DB_NAME};"
    
    # Restore from custom format
    echo "Restoring database..."
    pg_restore \
      -h "${DB_HOST}" \
      -p "${DB_PORT}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      -v \
      -F c \
      "/tmp/restore_temp.sql" || \
    pg_restore \
      -h "${DB_HOST}" \
      -p "${DB_PORT}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      -v \
      -F t \
      "/tmp/restore_temp.sql"
  else
    echo "Detected plain SQL backup (.sql.gz)"
    # Plain SQL backup
    echo "Dropping existing database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true
    
    echo "Creating new database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "CREATE DATABASE ${DB_NAME};"
    
    echo "Restoring database..."
    gunzip -c "${BACKUP_FILE}" | psql \
      -h "${DB_HOST}" \
      -p "${DB_PORT}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}"
  fi
  
  # Cleanup
  rm -f "/tmp/restore_temp.sql"
else
  # Non-compressed backup
  echo "Detected non-compressed backup"
  
  # Check backup format
  if head -c 5 "${BACKUP_FILE}" | grep -q "PGDMP" 2>/dev/null; then
    echo "Detected custom format backup"
    
    # Drop and recreate database
    echo "Dropping existing database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true
    
    echo "Creating new database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "CREATE DATABASE ${DB_NAME};"
    
    # Restore
    echo "Restoring database..."
    pg_restore \
      -h "${DB_HOST}" \
      -p "${DB_PORT}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      -v \
      -F c \
      "${BACKUP_FILE}" || \
    pg_restore \
      -h "${DB_HOST}" \
      -p "${DB_PORT}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      -v \
      "${BACKUP_FILE}"
  else
    echo "Detected plain SQL backup"
    
    # Drop and recreate database
    echo "Dropping existing database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "DROP DATABASE IF EXISTS ${DB_NAME};" || true
    
    echo "Creating new database..."
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d postgres \
      -c "CREATE DATABASE ${DB_NAME};"
    
    # Restore
    echo "Restoring database..."
    psql \
      -h "${DB_HOST}" \
      -p "${DB_PORT}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      -f "${BACKUP_FILE}"
  fi
fi

echo "========================================="
echo "âœ… Database restore completed successfully!"
echo "========================================="

# Verify restoration
echo "Verifying database..."
TABLE_COUNT=$(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null || echo "0")
echo "Tables restored: ${TABLE_COUNT}"

echo "========================================="
echo "âœ… Restore verification completed!"
echo "========================================="

