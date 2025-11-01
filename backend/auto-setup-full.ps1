# Backend Auto-Setup Script - FULL VERSION (PowerShell)
# Includes queue worker and scheduler setup

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 Backend Laravel 11 - Full Auto Setup" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Function to check Docker
function Test-DockerRunning {
    try {
        docker info | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check Docker Desktop
Write-Host "🔍 Checking Docker Desktop..." -ForegroundColor Yellow
if (-not (Test-DockerRunning)) {
    Write-Host "❌ Docker Desktop is not running!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker Desktop is running" -ForegroundColor Green
Write-Host ""

# Step 1-4: Basic Setup (same as auto-setup.ps1)
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Steps 1-4: Basic Setup (Rebuild, Migrate, Key, Optimize)..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Rebuild
Write-Host "🔨 Rebuilding backend..." -ForegroundColor Yellow
docker-compose build backend
docker-compose up -d backend
Start-Sleep -Seconds 10

# Migrate
Write-Host "📊 Running migrations..." -ForegroundColor Yellow
docker-compose exec -T backend php artisan migrate --force

# Generate Key
Write-Host "🔑 Generating app key..." -ForegroundColor Yellow
docker-compose exec -T backend php artisan key:generate --force | Out-Null

# Optimize
Write-Host "⚡ Optimizing application..." -ForegroundColor Yellow
docker-compose exec -T backend php artisan config:cache | Out-Null
docker-compose exec -T backend php artisan route:cache | Out-Null

Write-Host "✅ Basic setup complete" -ForegroundColor Green
Write-Host ""

# Step 5: Queue Worker Setup (Optional)
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Step 5: Queue Worker Setup (Optional)..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "❓ Do you want to start queue worker? (Y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "Y" -or $response -eq "y") {
    Write-Host ""
    Write-Host "🔄 Starting queue worker in background..." -ForegroundColor Yellow
    Write-Host "   Command: docker-compose exec -d backend php artisan queue:work redis --queue=uploads" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Note: Queue worker will run in background" -ForegroundColor Cyan
    Write-Host "   To view logs: docker-compose logs -f backend | grep queue" -ForegroundColor Gray
    Write-Host ""
    
    # Start in background (detached)
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "docker-compose exec backend php artisan queue:work redis --queue=uploads" -WindowStyle Minimized
    Write-Host "✅ Queue worker started in separate window" -ForegroundColor Green
}
else {
    Write-Host "⏭️  Skipping queue worker (can start manually later)" -ForegroundColor Yellow
}
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
Write-Host "📝 Manual Commands:" -ForegroundColor Cyan
Write-Host "   - Queue Worker: docker-compose exec backend php artisan queue:work redis --queue=uploads" -ForegroundColor Yellow
Write-Host "   - Scheduler:   docker-compose exec backend php artisan schedule:run" -ForegroundColor Yellow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan


















