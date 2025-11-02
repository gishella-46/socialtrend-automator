#!/usr/bin/env pwsh
# SocialTrend Automator - View Logs Script
# Double-click to view application logs

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     SocialTrend Automator - View Logs                                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Select logs to view:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. All services" -ForegroundColor White
Write-Host "   2. Backend only" -ForegroundColor White
Write-Host "   3. Automation only" -ForegroundColor White
Write-Host "   4. Frontend only" -ForegroundColor White
Write-Host "   5. Nginx only" -ForegroundColor White
Write-Host "   6. Database only" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "📋 Showing logs for all services... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        docker-compose logs -f
    }
    "2" {
        Write-Host ""
        Write-Host "📋 Showing logs for backend... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        docker-compose logs -f backend
    }
    "3" {
        Write-Host ""
        Write-Host "📋 Showing logs for automation... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        docker-compose logs -f automation
    }
    "4" {
        Write-Host ""
        Write-Host "📋 Showing logs for frontend... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        docker-compose logs -f frontend
    }
    "5" {
        Write-Host ""
        Write-Host "📋 Showing logs for nginx... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        docker-compose logs -f nginx
    }
    "6" {
        Write-Host ""
        Write-Host "📋 Showing logs for database... (Press Ctrl+C to exit)" -ForegroundColor Cyan
        docker-compose logs -f db
    }
    default {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
    }
}

Write-Host ""
Read-Host "Press Enter to exit"

