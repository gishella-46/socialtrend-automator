@echo off
echo ==========================================
echo   SocialTrend Automator - DEV Start (FAST)
echo ==========================================
echo.

echo Using lightweight docker-compose.dev.yml
echo (No Prometheus, Grafana, ELK - faster startup!)
echo.

echo [1/3] Stopping old containers...
docker-compose -f docker-compose.dev.yml down 2>nul

echo.
echo [2/3] Building images...
docker-compose -f docker-compose.dev.yml build

echo.
echo [3/3] Starting services...
docker-compose -f docker-compose.dev.yml up -d

echo.
echo Waiting for services to be ready...
timeout /t 30 /nobreak >nul

echo.
echo Running database migrations...
docker exec socialtrend_backend php artisan migrate --force 2>nul

echo.
echo ==========================================
echo   DEV MODE COMPLETE!
echo ==========================================
echo.
echo Access your application:
echo   Frontend:       http://localhost
echo   Backend API:    http://localhost/api
echo   FastAPI Docs:   http://localhost/automation/docs
echo.
echo Container Status:
docker-compose -f docker-compose.dev.yml ps

echo.
echo ==========================================
pause

