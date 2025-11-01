# Backend Auto-Setup Script (PowerShell)
# Script untuk rebuild backend dan menjalankan next steps secara otomatis

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 Backend Laravel 11 - Auto Setup" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Function to check Docker
function Test-DockerRunning {
    try {
        docker info | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Check Docker Desktop
Write-Host "🔍 Checking Docker Desktop..." -ForegroundColor Yellow
if (-not (Test-DockerRunning)) {
    Write-Host "❌ Docker Desktop is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker Desktop is running" -ForegroundColor Green
Write-Host ""

# Step 1: Rebuild Backend
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 1: Rebuilding Backend Container..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔨 Building Docker image (this may take a few minutes)..." -ForegroundColor Yellow

docker-compose build backend
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker image built successfully" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Starting backend container..." -ForegroundColor Yellow
docker-compose up -d backend
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start backend container!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backend container started" -ForegroundColor Green
Write-Host ""

# Wait for container to be ready
Write-Host "⏳ Waiting for backend to be ready (10 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Write-Host ""

# Step 2: Run Migrations
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 2: Running Database Migrations..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Running migrations..." -ForegroundColor Yellow
docker-compose exec -T backend php artisan migrate --force
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Migration failed!" -ForegroundColor Red
    Write-Host "   Trying to continue anyway..." -ForegroundColor Yellow
} else {
    Write-Host "✅ Migrations completed successfully" -ForegroundColor Green
}
Write-Host ""

# Step 3: Generate App Key (if needed)
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 3: Generating Application Key..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔑 Generating app key..." -ForegroundColor Yellow
docker-compose exec -T backend php artisan key:generate --force
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  App key generation failed (may already exist)" -ForegroundColor Yellow
} else {
    Write-Host "✅ App key generated" -ForegroundColor Green
}
Write-Host ""

# Step 4: Cache Configuration
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 4: Optimizing Application..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚡ Caching configuration..." -ForegroundColor Yellow
docker-compose exec -T backend php artisan config:cache
docker-compose exec -T backend php artisan route:cache
Write-Host "✅ Application optimized" -ForegroundColor Green
Write-Host ""

# Final Status
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Container Status:" -ForegroundColor Cyan
docker-compose ps backend
Write-Host ""
Write-Host "🌐 API Endpoints:" -ForegroundColor Cyan
Write-Host "   - Main:      http://localhost/api" -ForegroundColor White
Write-Host "   - Health:     http://localhost/api/health" -ForegroundColor White
Write-Host "   - Register:   http://localhost/api/register" -ForegroundColor White
Write-Host "   - Login:      http://localhost/api/login" -ForegroundColor White
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   - Start queue worker: docker-compose exec backend php artisan queue:work redis --queue=uploads" -ForegroundColor Yellow
Write-Host "   - Run scheduler: docker-compose exec backend php artisan schedule:run" -ForegroundColor Yellow
Write-Host "   - Or use cron for scheduler (every minute)" -ForegroundColor Yellow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan


















