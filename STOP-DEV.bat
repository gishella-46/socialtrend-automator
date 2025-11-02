@echo off
echo Stopping DEV containers...
docker-compose -f docker-compose.dev.yml down
echo Done!
pause

