@echo off
title POLA - Demo Presentasi Dosen
cd /d "%~dp0"
echo.
echo  ========================================
echo   POLA - Siap Presentasi ke Dosen
echo  ========================================
echo.
echo  [1] Menjalankan backend AI (port 8787)...
start "POLA Backend" cmd /k "cd /d "%~dp0server" && npm start"
timeout /t 3 /nobreak >nul
echo  [2] Menjalankan website (port 8081)...
echo  Pastikan internet aktif untuk chatbot AI.
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\serve_website.ps1"
pause
