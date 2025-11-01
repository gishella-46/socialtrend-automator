# Git Repository Setup Guide

## Quick Setup for CI/CD Pipeline

Follow these steps to set up Git and activate your CI/CD pipeline:

### 1️⃣ Initialize Git Repository

```bash
# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: SocialTrend Automator with CI/CD Pipeline"
```

### 2️⃣ Create GitHub Repository

1. Go to [GitHub](https://github.com/new)
2. Create a new repository:
   - Repository name: `socialtrend-automator` (or your preferred name)
   - Description: "Full-stack social media automation platform with AI-powered caption generation"
   - Visibility: Public or Private (your choice)
   - **DO NOT** initialize with README, .gitignore, or license
3. Click "Create repository"

### 3️⃣ Connect Local Repository to GitHub

```bash
# Add remote (replace with your actual repository URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git

# Rename default branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

### 4️⃣ Update Badge URL

Edit `README.md` and replace the placeholder:

```markdown
# OLD:
![CI/CD Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY/workflows/CI%2FCD%20Pipeline/badge.svg)

# NEW (replace with your actual username/repo):
![CI/CD Pipeline](https://github.com/username/socialtrend-automator/workflows/CI%2FCD%20Pipeline/badge.svg)
```

Then commit and push:
```bash
git add README.md
git commit -m "Update CI/CD badge URL"
git push
```

### 5️⃣ Configure GitHub Secrets

Go to your GitHub repository settings:

1. Navigate to: **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** for each:

#### SSH_HOST
```
Name: SSH_HOST
Value: production.example.com (your server IP or domain)
```

#### SSH_USERNAME
```
Name: SSH_USERNAME
Value: ubuntu (or your server username)
```

#### SSH_PRIVATE_KEY
```
Name: SSH_PRIVATE_KEY
Value: -----BEGIN PRIVATE KEY-----
       [paste your full SSH private key here]
       -----END PRIVATE KEY-----
```

**To get your SSH private key:**
```bash
# On your local machine
cat ~/.ssh/id_rsa

# If you don't have one, generate it:
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Then copy the public key to your server:
ssh-copy-id username@your-server.com
```

#### SSH_PORT
```
Name: SSH_PORT
Value: 22
```

### 6️⃣ Update Deployment Configuration

Edit `.github/workflows/main.yml`:

Find this section (around line 286):
```yaml
script: |
  cd /path/to/socialtrend-automator  # ← Change this line
  docker-compose pull
  docker-compose up -d --build
  docker-compose restart
```

Replace `/path/to/socialtrend-automator` with your actual deployment path, for example:
```yaml
script: |
  cd /var/www/socialtrend-automator
  docker-compose pull
  docker-compose up -d --build
  docker-compose restart
```

Commit the change:
```bash
git add .github/workflows/main.yml
git commit -m "Update deployment path"
git push
```

### 7️⃣ Set Up Production Server

On your production server:

```bash
# Install Docker (if not installed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
cd YOUR_REPOSITORY

# Create environment files
cp backend/.env.example backend/.env
cp automation/.env.example automation/.env
cp frontend/.env.example frontend/.env

# Edit environment files with your actual values
nano backend/.env
nano automation/.env
nano frontend/.env

# Generate Laravel application key
docker-compose run --rm backend php artisan key:generate

# Run migrations
docker-compose up -d
docker-compose exec backend php artisan migrate --force
```

### 8️⃣ Test CI/CD Pipeline

Make a small change and push:

```bash
# Make a change (e.g., update README)
echo "# Test deployment" >> README.md

# Commit and push
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin main
```

### 9️⃣ Monitor Pipeline

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Watch the pipeline run:
   - 🧩 Build & Lint
   - ✅ Test
   - 🐳 Docker Build
   - ☁️ Deploy

### 🔟 Verify Deployment

SSH to your production server:

```bash
ssh username@your-server.com

# Check running containers
docker-compose ps

# Check logs
docker-compose logs -f

# Test endpoints
curl http://localhost/health
```

## Troubleshooting

### Pipeline Fails at SSH Connection

**Problem**: Can't connect to server

**Solutions**:
1. Verify SSH_HOST, SSH_USERNAME, SSH_PORT in secrets
2. Test SSH manually: `ssh username@host`
3. Check firewall allows SSH on port 22
4. Ensure SSH_PRIVATE_KEY is formatted correctly (with BEGIN/END lines)

### Deployment Path Error

**Problem**: "No such file or directory"

**Solutions**:
1. Verify the path in `.github/workflows/main.yml`
2. SSH to server and check: `ls -la /path/to/directory`
3. Update workflow file with correct path

### Docker Images Not Building

**Problem**: Build failures in Docker stage

**Solutions**:
1. Test Dockerfiles locally: `docker build -t test ./backend`
2. Check for syntax errors in Dockerfiles
3. Verify all required files are present
4. Check GitHub Actions logs for specific errors

### Tests Failing

**Problem**: PHPUnit/PyTest/Vitest failures

**Solutions**:
1. Run tests locally first
2. Check test database configuration
3. Verify all dependencies are installed
4. Review test logs in Actions tab

## Next Steps After Setup

1. ✅ Push to `main` → Triggers full pipeline + deployment
2. ✅ Create `release/*` branches → Also triggers deployment
3. ✅ Open Pull Requests → Triggers build + test only (no deploy)
4. ✅ Monitor pipeline in Actions tab
5. ✅ Set up notifications (optional)

## Additional Resources

- [Git Basics](https://git-scm.com/doc)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [SSH Key Setup Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

## Support

If you encounter issues:
1. Check GitHub Actions logs
2. Review this guide
3. Check `docs/CI_CD.md` for detailed pipeline documentation
4. Open an issue in your repository

