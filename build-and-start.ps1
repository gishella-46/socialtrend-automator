# Script untuk build dan start Docker containers
# Pastikan Docker Desktop sudah berjalan sebelum menjalankan script ini

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  BUILD DAN START DOCKER CONTAINERS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check Docker
Write-Host "=== Memeriksa Docker Desktop ===" -ForegroundColor Yellow
try {
    docker ps | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker Desktop berjalan!" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Docker Desktop belum berjalan!" -ForegroundColor Red
        Write-Host "Silakan start Docker Desktop terlebih dahulu." -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "❌ Docker Desktop belum berjalan!" -ForegroundColor Red
    Write-Host "Silakan start Docker Desktop terlebih dahulu." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== Membangun Docker images ===" -ForegroundColor Yellow
Write-Host "Ini akan memakan waktu beberapa menit..." -ForegroundColor Gray
Write-Host ""

docker-compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build berhasil!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Menjalankan containers ===" -ForegroundColor Yellow
    docker-compose up -d
    
    Write-Host ""
    Write-Host "=== Status containers ===" -ForegroundColor Yellow
    docker-compose ps
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  SERVICES BERJALAN DI:" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Frontend:    http://localhost:5173" -ForegroundColor White
    Write-Host "  Backend:     http://localhost:8000" -ForegroundColor White
    Write-Host "  Automation:  http://localhost:8001" -ForegroundColor White
    Write-Host ""
    Write-Host "Untuk melihat logs:" -ForegroundColor Gray
    Write-Host "  docker-compose logs -f" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "❌ Build gagal. Cek error di atas." -ForegroundColor Red
    exit 1
}


















