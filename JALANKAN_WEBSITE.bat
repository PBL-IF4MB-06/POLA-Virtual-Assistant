@echo off
title POLA Website Server
cd /d "%~dp0"
echo.
echo  ========================================
echo   POLA - Menjalankan Website
echo  ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\serve_website.ps1"
pause
