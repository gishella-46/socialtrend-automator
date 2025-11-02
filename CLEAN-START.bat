@echo off
echo ==========================================
echo   SocialTrend Automator - Clean Start
echo ==========================================
echo.

echo [1/4] Stopping all containers...
docker-compose down 2>nul

echo.
echo [2/4] Removing old images and cache...
docker system prune -a --volumes -f

echo.
echo [3/4] Restarting Docker (waiting 10 seconds)...
timeout /t 10 /nobreak >nul

echo.
echo [4/4] Building fresh images...
docker-compose build --no-cache

echo.
echo ==========================================
echo   Complete! Starting services...
echo ==========================================
echo.

docker-compose up -d

echo.
echo Waiting for services to be ready...
timeout /t 30 /nobreak >nul

echo.
echo Running database migrations...
docker exec socialtrend_backend php artisan migrate --force 2>nul

echo.
echo ==========================================
echo   SETUP COMPLETE!
echo ==========================================
echo.
echo Access your application:
echo   Frontend:       http://localhost
echo   Backend API:    http://localhost/api
echo   Laravel Docs:   http://localhost/docs
echo   FastAPI Docs:   http://localhost/automation/docs
echo.
echo Container Status:
docker-compose ps

echo.
echo ==========================================
pause

