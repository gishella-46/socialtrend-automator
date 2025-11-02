#!/usr/bin/env pwsh
# SocialTrend Automator - Stop All Services Script
# Double-click to stop the entire application

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║     SocialTrend Automator - Stop All Services                             ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

Write-Host "🛑 Stopping all containers..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "✅ All services stopped!" -ForegroundColor Green
Write-Host ""

# Keep window open
Read-Host "Press Enter to exit"

