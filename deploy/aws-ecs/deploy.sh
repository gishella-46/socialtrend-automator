#!/bin/bash

# AWS ECS Deployment Script
# Requires: AWS CLI, jq
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT="${1:-production}"
CLUSTER_NAME="socialtrend-cluster"
REGION="${AWS_REGION:-us-east-1}"

echo "=========================================="
echo "Deploying to AWS ECS"
echo "Environment: ${ENVIRONMENT}"
echo "Region: ${REGION}"
echo "=========================================="

# Build and push images
echo "Building and pushing images..."
# Backend
docker build -t socialtrend-backend:latest ./backend
docker tag socialtrend-backend:latest ${ECR_REGISTRY}/socialtrend-backend:latest
docker push ${ECR_REGISTRY}/socialtrend-backend:latest

# Automation
docker build -t socialtrend-automation:latest ./automation
docker tag socialtrend-automation:latest ${ECR_REGISTRY}/socialtrend-automation:latest
docker push ${ECR_REGISTRY}/socialtrend-automation:latest

# Frontend
docker build -t socialtrend-frontend:latest ./frontend
docker tag socialtrend-frontend:latest ${ECR_REGISTRY}/socialtrend-frontend:latest
docker push ${ECR_REGISTRY}/socialtrend-frontend:latest

# Register task definition
echo "Registering task definition..."
aws ecs register-task-definition \
    --cli-input-json file://ecs-task-definition.json \
    --region ${REGION}

# Update service
echo "Updating ECS service..."
aws ecs update-service \
    --cluster ${CLUSTER_NAME} \
    --service-name socialtrend-backend \
    --force-new-deployment \
    --region ${REGION}

echo "=========================================="
echo "Deployment initiated!"
echo "Check status with:"
echo "  aws ecs describe-services --cluster ${CLUSTER_NAME} --services socialtrend-backend"
echo "=========================================="

