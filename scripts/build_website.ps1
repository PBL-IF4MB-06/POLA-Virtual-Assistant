# Rakit website download POLA + aplikasi web + file APK.
# Jalankan dari root proyek:
#   powershell -ExecutionPolicy Bypass -File scripts\build_website.ps1
#
# Untuk website publik, set URL backend AI yang bisa diakses internet:
#   $env:POLA_BACKEND_URL = "https://api-pola.polibatam.ac.id"
#   powershell -ExecutionPolicy Bypass -File scripts\build_website.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$OutDir = Join-Path $Root "releases\POLA-website"
$WebsiteSrc = Join-Path $Root "website"
$DownloadsDir = Join-Path $OutDir "downloads"
$AppDir = Join-Path $OutDir "app"

$DefineBackend = @()
$DefineExtra = @()

function Read-DotEnvValue {
    param([string]$File, [string]$Key)
    if (-not (Test-Path $File)) { return "" }
    foreach ($line in Get-Content $File) {
        $t = $line.Trim()
        if ($t -match "^\s*#") { continue }
        if ($t -match "^\s*$Key\s*=\s*(.*)$") {
            return $matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return ""
}

$EnvFile = Join-Path $Root ".env"
$BackendUrl = $env:POLA_BACKEND_URL
if (-not $BackendUrl) {
    $BackendUrl = Read-DotEnvValue $EnvFile "POLA_BACKEND_URL"
}

# Jangan bake localhost ke build web publik - Flutter web pakai origin + proxy.
$isLocalBackend = $BackendUrl -match '^(https?://)?(127\.0\.0\.1|localhost)(:|/|$)'
if ($BackendUrl -and -not $isLocalBackend) {
    Write-Host "Backend URL (publik): $BackendUrl" -ForegroundColor Gray
    $DefineBackend = @("--dart-define=POLA_BACKEND_URL=$BackendUrl")
} elseif ($isLocalBackend) {
    Write-Host "Backend lokal terdeteksi - web build pakai origin halaman (proxy)." -ForegroundColor Gray
    $DefineBackend = @()
} else {
    Write-Host "Web app: backend otomatis dari origin halaman (proxy website)." -ForegroundColor Gray
    $DefineBackend = @()
}

foreach ($key in @("SUPABASE_URL", "SUPABASE_ANON_KEY", "GOOGLE_WEB_CLIENT_ID", "GOOGLE_SERVER_CLIENT_ID")) {
    $val = Read-DotEnvValue $EnvFile $key
    if ($val) {
        $DefineExtra += @("--dart-define=${key}=$val")
        Write-Host "  $key dari .env" -ForegroundColor Gray
    }
}

Write-Host "`n=== 1/4 Build aplikasi web (Flutter) ===" -ForegroundColor Green
flutter build web --release --base-href="/app/" @DefineBackend @DefineExtra
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n=== 2/4 Salin halaman website ===" -ForegroundColor Green
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $DownloadsDir | Out-Null

Copy-Item $WebsiteSrc\* $OutDir -Recurse -Force

Write-Host "`n=== 3/4 Salin aplikasi web ke /app/ ===" -ForegroundColor Green
Copy-Item "build\web" $AppDir -Recurse -Force

Write-Host "`n=== 4/4 Salin file download ===" -ForegroundColor Green
$ApkSrc = Join-Path $Root "releases\POLA-v1.0.0-android.apk"
if (-not (Test-Path $ApkSrc)) {
    Write-Host "APK belum ada. Build dulu:" -ForegroundColor Yellow
    Write-Host "  flutter build apk --release --dart-define=POLA_BACKEND_URL=$BackendUrl" -ForegroundColor Cyan
} else {
    Copy-Item $ApkSrc (Join-Path $DownloadsDir "POLA-v1.0.0-android.apk") -Force
    Write-Host "OK: downloads/POLA-v1.0.0-android.apk" -ForegroundColor Green
}

$WinSrc = Join-Path $Root "releases\POLA-v1.0.0-windows"
$WinZip = Join-Path $DownloadsDir "POLA-v1.0.0-windows.zip"
if (Test-Path $WinSrc) {
    if (Test-Path $WinZip) { Remove-Item $WinZip -Force }
    Compress-Archive -Path "$WinSrc\*" -DestinationPath $WinZip -Force
    Write-Host "OK: downloads/POLA-v1.0.0-windows.zip" -ForegroundColor Green
} else {
    Write-Host "Windows build belum ada (opsional)." -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  BUILD SELESAI - Website BELUM terbuka" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "File ada di: releases\POLA-website\" -ForegroundColor Cyan
Write-Host ""
Write-Host "Langkah BERIKUTNYA (wajib) - jalankan server:" -ForegroundColor Yellow
Write-Host '  powershell -ExecutionPolicy Bypass -File scripts\serve_website.ps1' -ForegroundColor White
Write-Host ""
Write-Host "Baru setelah itu website terbuka di browser." -ForegroundColor Yellow
