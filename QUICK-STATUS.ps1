#!/usr/bin/env pwsh
# SocialTrend Automator - Quick Status Script
# Double-click to check application status

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     SocialTrend Automator - Quick Status                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Container Status:" -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "Quick Access URLs:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Frontend:       " -NoNewline -ForegroundColor White
Write-Host "http://localhost" -ForegroundColor Green
Write-Host "   Backend API:    " -NoNewline -ForegroundColor White
Write-Host "http://localhost/api" -ForegroundColor Green
Write-Host "   Laravel Docs:   " -NoNewline -ForegroundColor White
Write-Host "http://localhost/docs" -ForegroundColor Green
Write-Host "   FastAPI Docs:   " -NoNewline -ForegroundColor White
Write-Host "http://localhost/automation/docs" -ForegroundColor Green
Write-Host "   Grafana:        " -NoNewline -ForegroundColor White
Write-Host "http://localhost:3000" -ForegroundColor Green
Write-Host "   Prometheus:     " -NoNewline -ForegroundColor White
Write-Host "http://localhost:9090" -ForegroundColor Green
Write-Host ""

Write-Host "Tips:" -ForegroundColor Yellow
Write-Host "   - Double-click START.bat to start all services" -ForegroundColor Gray
Write-Host "   - Double-click STOP.bat to stop all services" -ForegroundColor Gray
Write-Host "   - Double-click RESTART.bat to restart all services" -ForegroundColor Gray
Write-Host "   - Double-click VIEW-LOGS.bat to view logs" -ForegroundColor Gray
Write-Host "   - Double-click OPEN-WEBSITE.bat to open in browser" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"

