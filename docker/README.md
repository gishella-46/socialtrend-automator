# Docker Configuration

This directory contains Docker-related configurations and files.

## Structure

- Individual service Dockerfiles are located in their respective folders:
  - `../frontend/Dockerfile` - Vue.js frontend
  - `../backend/Dockerfile` - Laravel backend
  - `../automation/Dockerfile` - FastAPI automation service

## Network

All containers communicate through the `socialtrend_net` internal network defined in `docker-compose.yml`.

## Volumes

- `./db` - PostgreSQL data persistence
- Service volumes are mapped for hot-reload during development




















