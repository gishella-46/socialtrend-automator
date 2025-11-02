#!/bin/bash

# Google Cloud Run Deployment Script
# Requires: gcloud CLI
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT="${1:-production}"
PROJECT_ID="${GCP_PROJECT_ID}"
REGION="${GCP_REGION:-us-central1}"

echo "=========================================="
echo "Deploying to Google Cloud Run"
echo "Environment: ${ENVIRONMENT}"
echo "Project: ${PROJECT_ID}"
echo "Region: ${REGION}"
echo "=========================================="

# Set project
gcloud config set project ${PROJECT_ID}

# Build and submit images
echo "Building and submitting images..."
# Backend
gcloud builds submit --tag gcr.io/${PROJECT_ID}/socialtrend-backend:latest ./backend

# Automation
gcloud builds submit --tag gcr.io/${PROJECT_ID}/socialtrend-automation:latest ./automation

# Frontend
gcloud builds submit --tag gcr.io/${PROJECT_ID}/socialtrend-frontend:latest ./frontend

# Deploy services
echo "Deploying services..."
# Backend
gcloud run deploy socialtrend-backend \
    --image gcr.io/${PROJECT_ID}/socialtrend-backend:latest \
    --platform managed \
    --region ${REGION} \
    --min-instances 3 \
    --max-instances 10 \
    --cpu 2 \
    --memory 2Gi \
    --allow-unauthenticated \
    --port 8000

# Automation
gcloud run deploy socialtrend-automation \
    --image gcr.io/${PROJECT_ID}/socialtrend-automation:latest \
    --platform managed \
    --region ${REGION} \
    --min-instances 3 \
    --max-instances 10 \
    --cpu 2 \
    --memory 2Gi \
    --allow-unauthenticated \
    --port 5000

# Frontend
gcloud run deploy socialtrend-frontend \
    --image gcr.io/${PROJECT_ID}/socialtrend-frontend:latest \
    --platform managed \
    --region ${REGION} \
    --min-instances 2 \
    --max-instances 5 \
    --cpu 1 \
    --memory 512Mi \
    --allow-unauthenticated \
    --port 8080

echo "=========================================="
echo "Deployment complete!"
echo "View services:"
echo "  gcloud run services list"
echo "=========================================="

