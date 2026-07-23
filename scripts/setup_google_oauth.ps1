# Isi Client ID Google OAuth ke .env lalu (opsional) rebuild web.
# Client Secret TIDAK disimpan di sini — tempel di Supabase Dashboard.
#
#   powershell -ExecutionPolicy Bypass -File scripts\setup_google_oauth.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host ""
Write-Host "=== Setup Login Google POLA ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Buka: https://console.cloud.google.com/apis/credentials"
Write-Host "2. Buat OAuth client → Web application"
Write-Host "3. Authorized JavaScript origins:"
Write-Host "     http://127.0.0.1:8080"
Write-Host "     https://YOUR-SITE.netlify.app   (setelah hosting)"
Write-Host "4. Authorized redirect URIs:"
Write-Host "     https://opdfrimqnmzudvmfgwvd.supabase.co/auth/v1/callback"
Write-Host "5. Salin Client ID (…apps.googleusercontent.com) dan Client Secret"
Write-Host "6. Di Supabase → Authentication → Providers → Google → Enable"
Write-Host "   tempel Client ID + Client Secret, lalu Save"
Write-Host ""

$ClientId = Read-Host "Tempel GOOGLE Client ID (Web)"
if ([string]::IsNullOrWhiteSpace($ClientId)) {
    Write-Host "Dibatalkan — Client ID kosong." -ForegroundColor Yellow
    exit 1
}
$ClientId = $ClientId.Trim()

$EnvFile = Join-Path $Root ".env"
if (-not (Test-Path $EnvFile)) {
    Copy-Item (Join-Path $Root ".env.example") $EnvFile
}

$raw = Get-Content $EnvFile -Raw
if ($raw -notmatch 'GOOGLE_WEB_CLIENT_ID=') {
    $raw += "`nGOOGLE_WEB_CLIENT_ID=`nGOOGLE_SERVER_CLIENT_ID=`n"
}
$raw = [regex]::Replace($raw, '(?m)^GOOGLE_WEB_CLIENT_ID=.*$', "GOOGLE_WEB_CLIENT_ID=$ClientId")
$raw = [regex]::Replace($raw, '(?m)^GOOGLE_SERVER_CLIENT_ID=.*$', "GOOGLE_SERVER_CLIENT_ID=$ClientId")
Set-Content -Path $EnvFile -Value $raw -NoNewline

Write-Host ""
Write-Host "OK: .env diperbarui (WEB + SERVER Client ID)." -ForegroundColor Green
Write-Host "WAJIB: aktifkan Provider Google di Supabase dengan Client Secret." -ForegroundColor Yellow
Write-Host ""
$rebuild = Read-Host "Rebuild website sekarang? (y/N)"
if ($rebuild -match '^[yY]') {
    powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_website.ps1")
}
