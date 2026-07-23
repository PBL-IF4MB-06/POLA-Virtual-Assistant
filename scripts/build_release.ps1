# Build file instalasi POLA untuk Android, Windows, dan Web.
# Jalankan dari root proyek:
#   powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$OutDir = Join-Path $Root "releases"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# URL backend AI — WAJIB untuk APK/iOS di HP fisik (ganti IP PC Anda).
# Contoh: http://192.168.1.10:8787  (server npm start harus jalan di PC itu)
$BackendUrl = $env:POLA_BACKEND_URL
if (-not $BackendUrl) {
    $BackendUrl = "http://127.0.0.1:8787"
    Write-Host "POLA_BACKEND_URL tidak di-set. Pakai default: $BackendUrl" -ForegroundColor Yellow
    Write-Host "Untuk HP Android fisik, set dulu:" -ForegroundColor Yellow
    Write-Host '  $env:POLA_BACKEND_URL = "http://IP-PC-ANDA:8787"' -ForegroundColor Cyan
}

$DefineArgs = @("--dart-define=POLA_BACKEND_URL=$BackendUrl")

Write-Host "`n=== 1/3 Build Android APK ===" -ForegroundColor Green
flutter build apk --release @DefineArgs
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" `
    (Join-Path $OutDir "POLA-v1.0.0-android.apk") -Force
Write-Host "OK: releases\POLA-v1.0.0-android.apk" -ForegroundColor Green

Write-Host "`n=== 2/3 Build Web (bisa di-host / dibuka browser) ===" -ForegroundColor Green
flutter build web --release @DefineArgs
$WebOut = Join-Path $OutDir "POLA-web"
if (Test-Path $WebOut) { Remove-Item $WebOut -Recurse -Force }
Copy-Item "build\web" $WebOut -Recurse
Write-Host "OK: releases\POLA-web\" -ForegroundColor Green

Write-Host "`n=== 3/3 Build Windows (butuh Visual Studio C++) ===" -ForegroundColor Green
try {
    flutter build windows --release @DefineArgs
    $WinSrc = "build\windows\x64\runner\Release"
    if (Test-Path $WinSrc) {
        $WinZip = Join-Path $OutDir "POLA-v1.0.0-windows"
        if (Test-Path $WinZip) { Remove-Item $WinZip -Recurse -Force }
        Copy-Item $WinSrc $WinZip -Recurse
        Write-Host "OK: releases\POLA-v1.0.0-windows\" -ForegroundColor Green
    }
} catch {
    Write-Host "Windows build gagal — install Visual Studio 'Desktop development with C++'" -ForegroundColor Red
}

Write-Host "`n=== 4/4 Build website download ===" -ForegroundColor Green
try {
    powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_website.ps1")
} catch {
    Write-Host "Website build gagal - lihat pesan di atas." -ForegroundColor Red
}

Write-Host "`n=== iOS ===" -ForegroundColor Yellow
Write-Host "Build iOS hanya bisa di Mac + Xcode. Perintah:" -ForegroundColor Yellow
Write-Host "  flutter build ipa --release --dart-define=POLA_BACKEND_URL=<url>" -ForegroundColor Cyan

Write-Host "`nSelesai. File ada di folder: releases\" -ForegroundColor Green
