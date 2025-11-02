@echo off
chcp 65001 >nul
powershell -ExecutionPolicy Bypass -File "%~dp0VIEW-LOGS.ps1"
pause
