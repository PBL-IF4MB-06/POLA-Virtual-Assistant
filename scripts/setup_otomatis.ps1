# Setup otomatis POLA — jalankan sekali
#   powershell -ExecutionPolicy Bypass -File scripts\setup_otomatis.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  POLA - Setup Otomatis" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path (Join-Path $Root ".env"))) {
    Copy-Item (Join-Path $Root ".env.example") (Join-Path $Root ".env")
    Write-Host "[!] .env dibuat dari template" -ForegroundColor Yellow
}
if (-not (Test-Path (Join-Path $Root "server\.env"))) {
    Copy-Item (Join-Path $Root "server\.env.example") (Join-Path $Root "server\.env")
    Write-Host "[!] server\.env dibuat dari template" -ForegroundColor Yellow
}

Write-Host "`n[1/4] Install backend Node.js..." -ForegroundColor Green
Set-Location (Join-Path $Root "server")
npm install --silent
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[2/4] Flutter pub get..." -ForegroundColor Green
Set-Location $Root
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[3/4] Build website (1-2 menit)..." -ForegroundColor Green
powershell -ExecutionPolicy Bypass -File (Join-Path $Root "scripts\build_website.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "[4/4] Menjalankan backend AI..." -ForegroundColor Green
try {
    $h = Invoke-RestMethod -Uri "http://127.0.0.1:8787/health" -TimeoutSec 2
    Write-Host "  Backend sudah jalan (provider: $($h.provider))" -ForegroundColor Gray
} catch {
    $serverPath = Join-Path $Root "server"
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "Set-Location '$serverPath'; Write-Host 'Backend POLA - jangan tutup' -ForegroundColor Green; npm start"
    ) | Out-Null
    Start-Sleep -Seconds 4
    try {
        $h = Invoke-RestMethod -Uri "http://127.0.0.1:8787/health" -TimeoutSec 5
        Write-Host "  Backend started (provider: $($h.provider))" -ForegroundColor Green
    } catch {
        Write-Host "  Backend belum bisa dihubungi - jalankan: cd server; npm start" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SETUP SELESAI" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Jalankan website:" -ForegroundColor Yellow
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\serve_website.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Isi GEMINI_API_KEY di server\.env:" -ForegroundColor Yellow
Write-Host "  https://aistudio.google.com/apikey" -ForegroundColor Gray
Write-Host ""
Write-Host "Aktifkan Google Login di Supabase:" -ForegroundColor Yellow
Write-Host "  https://supabase.com/dashboard/project/opdfrimqnmzudvmfgwvd/auth/providers" -ForegroundColor Gray
Write-Host ""

Start-Process "https://supabase.com/dashboard/project/opdfrimqnmzudvmfgwvd/auth/providers"
Start-Process "https://aistudio.google.com/apikey"
