#!/bin/bash

# DigitalOcean Apps Deployment Script
# Requires: doctl CLI
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT="${1:-production}"

echo "=========================================="
echo "Deploying to DigitalOcean Apps"
echo "Environment: ${ENVIRONMENT}"
echo "=========================================="

# Check doctl authentication
if ! doctl auth init > /dev/null 2>&1; then
    echo "Please authenticate doctl first:"
    echo "  doctl auth init"
    exit 1
fi

# Deploy app
echo "Deploying app..."
doctl apps create-deployment $(doctl apps list -o json | jq -r '.[0].id') --spec apps.yaml

echo "=========================================="
echo "Deployment initiated!"
echo "Check status:"
echo "  doctl apps list"
echo "  doctl apps get-deployments APP_ID"
echo "=========================================="

