#!/bin/bash

# Docker Swarm Deployment Script
# Usage: ./deploy.sh [environment]
# Environments: staging, production

set -e

ENVIRONMENT="${1:-production}"
DOMAIN="${DOMAIN:-localhost}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-ghcr.io/gishella-46}"

echo "=========================================="
echo "Deploying SocialTrend Automator"
echo "Environment: ${ENVIRONMENT}"
echo "Registry: ${DOCKER_REGISTRY}"
echo "=========================================="

# Check if Docker Swarm is initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "Initializing Docker Swarm..."
    docker swarm init
fi

# Login to registry if needed
if [ -n "${DOCKER_REGISTRY_USER}" ] && [ -n "${DOCKER_REGISTRY_PASSWORD}" ]; then
    echo "Logging into registry..."
    echo "${DOCKER_REGISTRY_PASSWORD}" | docker login ${DOCKER_REGISTRY} -u ${DOCKER_REGISTRY_USER} --password-stdin
fi

# Pull latest images
echo "Pulling latest images..."
docker pull ${DOCKER_REGISTRY}/socialtrend-backend:latest
docker pull ${DOCKER_REGISTRY}/socialtrend-automation:latest
docker pull ${DOCKER_REGISTRY}/socialtrend-frontend:latest

# Deploy stack
echo "Deploying stack..."
export DOCKER_REGISTRY
export DOMAIN
export BACKEND_VERSION=latest
export AUTOMATION_VERSION=latest
export FRONTEND_VERSION=latest

docker stack deploy -c ../../docker-stack.yml socialtrend --with-registry-auth

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Show service status
docker service ls

echo "=========================================="
echo "Deployment complete!"
echo "=========================================="
echo ""
echo "Access URLs:"
echo "  Frontend: http://${DOMAIN}"
echo "  Traefik Dashboard: http://localhost:8080"
echo ""
echo "To check service status:"
echo "  docker service ls"
echo ""
echo "To view logs:"
echo "  docker service logs socialtrend_backend"
echo ""
echo "To scale services:"
echo "  docker service scale socialtrend_backend=5"
echo "=========================================="

