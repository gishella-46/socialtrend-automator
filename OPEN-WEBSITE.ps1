#!/usr/bin/env pwsh
# SocialTrend Automator - Open Website Script
# Double-click to open the application in your browser

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     SocialTrend Automator - Open Website                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Select website to open:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Frontend (Main Application)" -ForegroundColor White
Write-Host "   2. Backend API (Laravel)" -ForegroundColor White
Write-Host "   3. Laravel Docs" -ForegroundColor White
Write-Host "   4. FastAPI Docs (Swagger)" -ForegroundColor White
Write-Host "   5. FastAPI ReDoc" -ForegroundColor White
Write-Host "   6. Grafana Dashboard" -ForegroundColor White
Write-Host "   7. Prometheus Metrics" -ForegroundColor White
Write-Host "   8. Kibana Logs" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1-8)"

switch ($choice) {
    "1" {
        Write-Host "🌐 Opening Frontend..." -ForegroundColor Green
        Start-Process "http://localhost"
    }
    "2" {
        Write-Host "🌐 Opening Backend API..." -ForegroundColor Green
        Start-Process "http://localhost/api"
    }
    "3" {
        Write-Host "🌐 Opening Laravel Docs..." -ForegroundColor Green
        Start-Process "http://localhost/docs"
    }
    "4" {
        Write-Host "🌐 Opening FastAPI Swagger Docs..." -ForegroundColor Green
        Start-Process "http://localhost/automation/docs"
    }
    "5" {
        Write-Host "🌐 Opening FastAPI ReDoc..." -ForegroundColor Green
        Start-Process "http://localhost/automation/redoc"
    }
    "6" {
        Write-Host "🌐 Opening Grafana Dashboard..." -ForegroundColor Green
        Start-Process "http://localhost:3000"
    }
    "7" {
        Write-Host "🌐 Opening Prometheus..." -ForegroundColor Green
        Start-Process "http://localhost:9090"
    }
    "8" {
        Write-Host "🌐 Opening Kibana..." -ForegroundColor Green
        Start-Process "http://localhost:5601"
    }
    default {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✅ Website opened in your default browser!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"

