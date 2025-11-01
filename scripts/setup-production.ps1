#!/usr/bin/env pwsh
# Production Setup Script for SocialTrend Automator
# This script automates the production deployment steps

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🚀 PRODUCTION SETUP - SocialTrend Automator 🚀                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Step 1: Generate Laravel APP_KEY
Write-Host "Step 1: Generate Laravel APP_KEY..." -ForegroundColor Yellow
$backendContainer = docker ps --format "{{.Names}}" | Select-String "backend|socialtrend"
if ($backendContainer) {
    Write-Host "  ✅ Backend container found: $backendContainer" -ForegroundColor Green
    Write-Host "  Running: php artisan key:generate --force" -ForegroundColor Gray
    docker exec $backendContainer php artisan key:generate --force
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ APP_KEY generated successfully" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  Failed to generate APP_KEY" -ForegroundColor Red
    }
}
else {
    Write-Host "  ⚠️  Backend container not running" -ForegroundColor Yellow
    Write-Host "  Please run: docker-compose up -d" -ForegroundColor Gray
    Write-Host "  Then run: docker exec socialtrend_backend php artisan key:generate" -ForegroundColor Gray
}

# Step 2: Generate and set JWT_SECRET_KEY
Write-Host "`nStep 2: Set JWT_SECRET_KEY for FastAPI..." -ForegroundColor Yellow
$jwtKey = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 64 | ForEach-Object { [char]$_ })
Write-Host "  Generated JWT_SECRET_KEY (64 characters)" -ForegroundColor Gray

if (Test-Path "automation\.env") {
    $envContent = Get-Content "automation\.env"
    $hasJwtKey = $envContent | Where-Object { $_ -match "^JWT_SECRET_KEY=" } | Measure-Object | Select-Object -ExpandProperty Count
    $newContent = $envContent | ForEach-Object {
        if ($_ -match "^JWT_SECRET_KEY=") {
            "JWT_SECRET_KEY=$jwtKey"
        }
        else {
            $_
        }
    }
    if ($hasJwtKey -eq 0) {
        $newContent += "JWT_SECRET_KEY=$jwtKey"
    }
    $newContent | Set-Content "automation\.env"
    Write-Host "  ✅ JWT_SECRET_KEY updated in automation/.env" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  automation/.env not found" -ForegroundColor Yellow
    Write-Host "  Add this line to automation/.env:" -ForegroundColor Gray
    Write-Host "    JWT_SECRET_KEY=$jwtKey" -ForegroundColor Gray
}

# Step 3: Enable HTTPS redirect in Nginx
Write-Host "`nStep 3: Enable HTTPS redirect in Nginx..." -ForegroundColor Yellow
if (Test-Path "docker\nginx\conf.d\default.conf") {
    $nginxContent = Get-Content "docker\nginx\conf.d\default.conf" -Raw
    if ($nginxContent -match "# return 301 https://") {
        $nginxContent = $nginxContent -replace "# return 301 https://", "return 301 https://"
        $nginxContent | Set-Content "docker\nginx\conf.d\default.conf" -NoNewline
        Write-Host "  ✅ HTTPS redirect enabled" -ForegroundColor Green
    }
    else {
        Write-Host "  ℹ️  HTTPS redirect already enabled or not found" -ForegroundColor Gray
    }
}
else {
    Write-Host "  ⚠️  Nginx config not found" -ForegroundColor Yellow
}

# Step 4: Run migrations
Write-Host "`nStep 4: Run database migrations..." -ForegroundColor Yellow
$backendContainer = docker ps --format "{{.Names}}" | Select-String "backend|socialtrend"
if ($backendContainer) {
    Write-Host "  Running: php artisan migrate --force" -ForegroundColor Gray
    docker exec $backendContainer php artisan migrate --force
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Migrations completed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  Migration failed" -ForegroundColor Red
    }
}
else {
    Write-Host "  ⚠️  Backend container not running" -ForegroundColor Yellow
    Write-Host "  Run manually: docker exec socialtrend_backend php artisan migrate" -ForegroundColor Gray
}

# Step 5: Verify environment variables
Write-Host "`nStep 5: Verify environment variables..." -ForegroundColor Yellow
if (Test-Path "backend\.env") {
    $appKey = Select-String -Path "backend\.env" -Pattern "^APP_KEY="
    if ($appKey -and $appKey.Line -notmatch "APP_KEY=$") {
        Write-Host "  ✅ Laravel APP_KEY is set" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  Laravel APP_KEY is empty" -ForegroundColor Yellow
    }
}

if (Test-Path "automation\.env") {
    $jwtKey = Select-String -Path "automation\.env" -Pattern "^JWT_SECRET_KEY="
    if ($jwtKey -and $jwtKey.Line -notmatch "change-this") {
        Write-Host "  ✅ FastAPI JWT_SECRET_KEY is set" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  FastAPI JWT_SECRET_KEY needs to be set" -ForegroundColor Yellow
    }
}

# Final summary
Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     ✅ PRODUCTION SETUP COMPLETE! ✅                                     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Install SSL certificate (Certbot or Cloudflare)" -ForegroundColor White
Write-Host "  2. Update FRONTEND_URL in .env files with production domain" -ForegroundColor White
Write-Host "  3. Restart containers: docker-compose restart" -ForegroundColor White
Write-Host "  4. Test HTTPS redirect and security headers" -ForegroundColor White
Write-Host "`n"

