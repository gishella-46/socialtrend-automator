@echo off
chcp 65001 >nul
powershell -ExecutionPolicy Bypass -File "%~dp0START.ps1"
pause
