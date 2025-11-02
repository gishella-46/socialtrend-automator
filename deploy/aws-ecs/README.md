# AWS ECS/Fargate Deployment Guide

Production deployment on AWS ECS with Fargate launch type.

## Prerequisites

- AWS account with ECS access
- AWS CLI installed and configured
- ECR repository created
- VPC with subnets and security groups
- Application Load Balancer (ALB)
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- IAM roles with proper permissions

## Architecture

### Components

1. **ECS Cluster**: `socialtrend-cluster`
2. **Services**: Backend, Automation, Frontend
3. **Task Definitions**: Container configurations
4. **Load Balancer**: ALB for traffic distribution
5. **Target Groups**: Health checks and routing
6. **Auto Scaling**: Based on CPU/memory metrics
7. **CloudWatch**: Logs and metrics
8. **RDS**: PostgreSQL database
9. **ElastiCache**: Redis cache

### Services

- **Backend**: 3-10 replicas, 1 vCPU, 2GB RAM
- **Automation**: 3-10 replicas, 1 vCPU, 2GB RAM
- **Frontend**: 2-5 replicas, 0.5 vCPU, 512MB RAM
- **Celery**: 2-5 workers, 0.5 vCPU, 512MB RAM

## Setup Steps

### 1. Create ECR Repositories

```bash
aws ecr create-repository --repository-name socialtrend-backend
aws ecr create-repository --repository-name socialtrend-automation
aws ecr create-repository --repository-name socialtrend-frontend
```

### 2. Configure VPC and Networking

```bash
# Create security group
aws ec2 create-security-group \
  --group-name socialtrend-sg \
  --description "SocialTrend Automator SG"

# Allow HTTP/HTTPS
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

### 3. Create Load Balancer

```bash
aws elbv2 create-load-balancer \
  --name socialtrend-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx
```

### 4. Create RDS Instance

```bash
aws rds create-db-instance \
  --db-instance-identifier socialtrend-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username socialtrend_user \
  --master-user-password secure_password \
  --allocated-storage 20
```

### 5. Create ElastiCache Redis

```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id socialtrend-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

### 6. Build and Push Images

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build and push
./deploy.sh production
```

### 7. Create Task Definitions

```bash
# Update variables in ecs-task-definition.json
export DB_HOST=socialtrend-db.xxx.us-east-1.rds.amazonaws.com
export REDIS_HOST=socialtrend-redis.xxx.cache.amazonaws.com

# Register task definition
aws ecs register-task-definition \
  --cli-input-json file://ecs-task-definition.json
```

### 8. Create Services

```bash
# Update variables in ecs-service.json
export TARGET_GROUP_ARN=arn:aws:elasticloadbalancing:xxx

# Create service
aws ecs create-service \
  --cli-input-json file://ecs-service.json
```

## Auto Scaling

### Create Auto Scaling Target

```bash
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/socialtrend-cluster/socialtrend-backend \
  --min-capacity 3 \
  --max-capacity 10
```

### Create Scaling Policy

```bash
aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/socialtrend-cluster/socialtrend-backend \
  --policy-name cpu-scaling-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration file://scaling-policy.json
```

## Monitoring

### CloudWatch Metrics

- CPUUtilization
- MemoryUtilization
- RequestCount
- TargetResponseTime
- HealthyHostCount
- UnhealthyHostCount

### CloudWatch Logs

```bash
# View logs
aws logs tail /ecs/socialtrend --follow

# Create log groups
aws logs create-log-group --log-group-name /ecs/socialtrend
```

### CloudWatch Alarms

```bash
# High CPU alarm
aws cloudwatch put-metric-alarm \
  --alarm-name socialtrend-high-cpu \
  --alarm-description "Alert when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

## Troubleshooting

### Service Not Starting

```bash
# Check service events
aws ecs describe-services \
  --cluster socialtrend-cluster \
  --services socialtrend-backend

# Check task status
aws ecs list-tasks --cluster socialtrend-cluster

# Describe task
aws ecs describe-tasks \
  --cluster socialtrend-cluster \
  --tasks TASK_ARN
```

### High Costs

- Use Spot Instances for non-critical services
- Right-size instances based on metrics
- Enable auto-scaling to scale down
- Use CloudWatch to identify unused resources

## Security

### IAM Roles

Create task execution role with:
- ecr:GetAuthorizationToken
- ecr:BatchCheckLayerAvailability
- ecr:GetDownloadUrlForLayer
- ecr:BatchGetImage
- logs:CreateLogStream
- logs:PutLogEvents

### Secrets Management

Use AWS Secrets Manager:

```bash
# Store secret
aws secretsmanager create-secret \
  --name socialtrend/db-password \
  --secret-string "secure_password"

# Reference in task definition
{
  "secrets": [
    {
      "name": "DB_PASSWORD",
      "valueFrom": "arn:aws:secretsmanager:us-east-1:xxx:secret:socialtrend/db-password"
    }
  ]
}
```

## Cost Optimization

### Recommendations

1. Use Fargate Spot for 70% cost savings
2. Right-size based on actual usage
3. Enable auto-scaling to avoid over-provisioning
4. Use Reserved Instances for steady workloads
5. Monitor and optimize CloudWatch costs

### Estimated Costs

- ECS Fargate: $0.04/hour per vCPU + $0.004/hour per GB RAM
- RDS PostgreSQL: $0.017/hour (db.t3.micro)
- ElastiCache Redis: $0.017/hour (cache.t3.micro)
- ALB: $0.0225/hour + $0.008 per GB transferred
- Data transfer: $0.09/GB

Total: ~$150-300/month (3 service replicas)

## Deployment Checklist

- [ ] ECR repositories created
- [ ] VPC and subnets configured
- [ ] Security groups configured
- [ ] Load balancer created
- [ ] RDS instance created
- [ ] ElastiCache cluster created
- [ ] IAM roles configured
- [ ] Task definitions registered
- [ ] Services created
- [ ] Auto-scaling configured
- [ ] CloudWatch alarms set
- [ ] Logs flowing to CloudWatch
- [ ] Health checks passing
- [ ] SSL certificates configured
- [ ] DNS configured
- [ ] Monitoring dashboards ready

## References

- [ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
- [ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)
- [RDS Documentation](https://docs.aws.amazon.com/rds/)

