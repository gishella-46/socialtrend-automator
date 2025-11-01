# CI/CD Pipeline Documentation

## Overview

The CI/CD pipeline automates build, test, and deployment processes for SocialTrend Automator. Every push to `main` or `release/*` branches triggers a complete workflow.

## Pipeline Architecture

```
┌─────────────────┐
│  Push to main   │
│  or release/*   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  🧩 Build & Lint Stage                      │
│  - Composer install (Backend)               │
│  - npm install (Frontend)                   │
│  - pip install (Automation)                 │
│  - Code linting (pint, flake8, black, ruff) │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  ✅ Test Stage                              │
│  - PHPUnit tests (Laravel)                  │
│  - PyTest tests (FastAPI)                   │
│  - Vitest tests (Vue.js)                    │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  🐳 Docker Build Stage                      │
│  - Build Backend image                      │
│  - Build Automation image                   │
│  - Build Frontend image                     │
│  - Push to GHCR                             │
└────────┬────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────┐
│  ☁️ Deploy Stage                           │
│  - SSH to production server                 │
│  - Pull latest images                       │
│  - Restart containers                       │
└─────────────────────────────────────────────┘
```

## Workflow Triggers

### Automatic Triggers
- **Push to `main` branch**: Full pipeline including deployment
- **Push to `release/*` branches**: Full pipeline including deployment
- **Pull Requests**: Build, lint, and test only (no deployment)

### Manual Triggers
You can manually trigger workflows from GitHub Actions UI.

## Pipeline Stages

### 🧩 Build & Lint Stage

**Purpose**: Install dependencies and check code quality

**Services**: Run in parallel matrix strategy
- Backend (PHP)
- Automation (Python)
- Frontend (Node.js)

**Actions Per Service**:

#### Backend
- Setup PHP 8.2 with required extensions
- `composer install --prefer-dist`
- Run Laravel Pint (code style check)

#### Automation
- Setup Python 3.11
- `pip install -r requirements.txt`
- Install linting tools: ruff, flake8, black
- Run linting checks:
  - `flake8` (max 100 chars per line)
  - `black --check` (formatting)
  - `ruff check` (linting)

#### Frontend
- Setup Node.js 20
- `npm ci` (clean install)
- Run ESLint

### ✅ Test Stage

**Purpose**: Run automated tests

**Services**: Backend, Automation, Frontend (parallel execution)

**Infrastructure**:
- PostgreSQL 16 database
- Redis 7 cache

**Actions Per Service**:

#### Backend
- Run PHPUnit: `php artisan test`
- Tests located in `backend/tests/`

#### Automation
- Run PyTest: `pytest --tb=short -v`
- Tests located in `automation/tests/`

#### Frontend
- Run Vitest: `npm test -- --run`
- Tests located in `frontend/tests/`

### 🐳 Docker Build Stage

**Purpose**: Build and push Docker images

**Trigger**: Only on push to `main` or `release/*` (not PRs)

**Actions**:
1. Setup Docker Buildx
2. Login to GitHub Container Registry (GHCR)
3. Extract metadata for all services (tags, labels)
4. Build and push images:
   - `ghcr.io/<org>/socialtrend-backend:latest`
   - `ghcr.io/<org>/socialtrend-automation:latest`
   - `ghcr.io/<org>/socialtrend-frontend:latest`

**Image Tagging**:
- Branch name (e.g., `main`, `release/v1.0`)
- SHA prefix (e.g., `main-abc123`)
- Semantic versioning (if applicable)

**Caching**: Uses GitHub Actions cache for faster builds

### ☁️ Deploy Stage

**Purpose**: Deploy to production server

**Trigger**: Only after successful Docker build

**Actions**:
1. SSH to production server
2. Navigate to application directory
3. Pull latest images: `docker-compose pull`
4. Rebuild and start containers: `docker-compose up -d --build`
5. Restart services: `docker-compose restart`

**Environment**: Production

## GitHub Secrets Configuration

Configure these secrets in GitHub repository settings:

### SSH Deployment Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SSH_HOST` | Production server hostname or IP | `production.example.com` |
| `SSH_USERNAME` | SSH username | `ubuntu` |
| `SSH_PRIVATE_KEY` | Private SSH key | `-----BEGIN PRIVATE KEY-----...` |
| `SSH_PORT` | SSH port | `22` |

### Optional Secrets

| Secret Name | Description | Default |
|-------------|-------------|---------|
| `DOCKER_REGISTRY` | Alternative Docker registry | `ghcr.io` |

## Setup Instructions

### 1. Configure Repository

1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Add required secrets (SSH_HOST, SSH_USERNAME, SSH_PRIVATE_KEY, SSH_PORT)
3. Update badge URL in `README.md`:
   ```markdown
   ![CI/CD Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/CI%2FCD%20Pipeline/badge.svg)
   ```

### 2. Production Server Setup

On your production server:

1. Install Docker and Docker Compose
2. Clone repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```

3. Create `.env` files for each service
4. Configure SSH access for CI/CD user
5. Set up SSH key authentication
6. Ensure `docker-compose.yml` is configured for production

### 3. Deploy Configuration

Update deployment path in `.github/workflows/main.yml`:

```yaml
script: |
  cd /path/to/socialtrend-automator  # ← Update this path
  docker-compose pull
  docker-compose up -d --build
  docker-compose restart
```

### 4. First Deployment

1. Push code to `main` branch:
   ```bash
   git push origin main
   ```

2. Monitor pipeline:
   - Go to **Actions** tab in GitHub
   - Watch workflow progress
   - Check logs for errors

3. Verify deployment:
   - SSH to production server
   - Check container status: `docker-compose ps`
   - Test endpoints

## Workflow Status Badge

The badge in README.md shows pipeline status:

- ![Passing](https://img.shields.io/badge/CI/CD-Passing-brightgreen): All checks passed
- ![Failing](https://img.shields.io/badge/CI/CD-Failing-red): One or more checks failed
- ![Running](https://img.shields.io/badge/CI/CD-Running-blue): Workflow in progress

## Troubleshooting

### Pipeline Fails at Build & Lint

**Possible causes**:
- Missing dependencies
- Linting errors
- Version compatibility issues

**Solutions**:
- Check workflow logs for specific errors
- Run linting tools locally
- Update dependencies

### Tests Fail

**Possible causes**:
- Database connection issues
- Missing test data
- Flaky tests

**Solutions**:
- Verify test database configuration
- Add fixtures/seeders
- Review test logs

### Docker Build Fails

**Possible causes**:
- Dockerfile syntax errors
- Missing files
- Registry authentication issues

**Solutions**:
- Test Dockerfiles locally
- Check file paths in Dockerfiles
- Verify registry credentials

### Deployment Fails

**Possible causes**:
- SSH connection issues
- Wrong deployment path
- Docker Compose errors
- Missing environment variables

**Solutions**:
- Test SSH connection manually
- Verify deployment path
- Check docker-compose logs on server
- Ensure .env files are configured

## Best Practices

### Development Workflow

1. **Feature branches**: Create PRs to `main`
2. **Test locally**: Run tests before pushing
3. **Fix linting**: Address linting issues locally
4. **Review PR**: Ensure CI checks pass

### Release Workflow

1. Create release branch: `release/v1.0.0`
2. Push to trigger deployment
3. Monitor pipeline
4. Verify production deployment
5. Tag release after verification

### Security

1. **Secrets**: Never commit secrets to repository
2. **SSH keys**: Use deploy keys or service accounts
3. **Registry**: Limit access to production images
4. **Audit**: Review deployment logs regularly

## Advanced Configuration

### Conditional Deployment

Skip deployment for certain changes:

```yaml
deploy:
  if: |
    github.event_name == 'push' &&
    github.ref == 'refs/heads/main' &&
    !contains(github.event.head_commit.message, '[skip deploy]')
```

### Environment-Specific Deployments

Deploy to different environments:

```yaml
staging:
  if: github.ref == 'refs/heads/develop'
  environment:
    name: staging
    url: https://staging.example.com

production:
  if: github.ref == 'refs/heads/main'
  environment:
    name: production
    url: https://production.example.com
```

### Notifications

Add Slack or email notifications:

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Buildx Documentation](https://docs.docker.com/buildx/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

## Support

For issues or questions:
1. Check workflow logs
2. Review this documentation
3. Open an issue in the repository

