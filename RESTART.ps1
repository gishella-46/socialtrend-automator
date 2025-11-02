# SocialTrend Automator - Restart All Services Script
# Double-click to restart the entire application

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  SocialTrend Automator - Restart All Services" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Stopping all containers..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "Waiting 5 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Starting all services..." -ForegroundColor Blue
docker-compose up -d

Write-Host ""
Write-Host "Waiting for services to be ready (20 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host ""
Write-Host "Checking container status..." -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "Services restarted!" -ForegroundColor Green
Write-Host ""

# Keep window open
Read-Host "Press Enter to exit"

