# SocialTrend Automator - Quick Start Script
# Double-click to start the entire application

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  SocialTrend Automator - One-Click Start" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    Write-Host "Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    Write-Host "   Download: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Docker is running
Write-Host "Checking if Docker is running..." -ForegroundColor Yellow
try {
    docker ps 2>&1 | Out-Null
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Stopping any existing containers..." -ForegroundColor Yellow
docker-compose down 2>$null

Write-Host ""
Write-Host "Building Docker images (this may take a few minutes)..." -ForegroundColor Blue
docker-compose build

Write-Host ""
Write-Host "Starting all services..." -ForegroundColor Blue
docker-compose up -d

Write-Host ""
Write-Host "Waiting for services to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Running database migrations..." -ForegroundColor Blue
docker exec socialtrend_backend php artisan migrate --force 2>$null

Write-Host ""
Write-Host "Generating Laravel application key (if needed)..." -ForegroundColor Blue
docker exec socialtrend_backend php artisan key:generate --force 2>$null

Write-Host ""
Write-Host "Generating API documentation..." -ForegroundColor Blue
docker exec socialtrend_backend php artisan scribe:generate 2>$null

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Frontend:       http://localhost" -ForegroundColor Green
Write-Host "   Backend API:    http://localhost/api" -ForegroundColor Green
Write-Host "   Laravel Docs:   http://localhost/docs" -ForegroundColor Green
Write-Host "   FastAPI Docs:   http://localhost/automation/docs" -ForegroundColor Green
Write-Host ""
Write-Host "Container Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "TIP: Double-click this file again to restart all services!" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Keep window open
Read-Host "Press Enter to exit"

