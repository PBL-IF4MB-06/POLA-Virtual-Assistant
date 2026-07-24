# Wizard: isi Client ID + Secret Google, simpan ke .env + Railway.
#
#   powershell -ExecutionPolicy Bypass -File scripts\aktifkan_google.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$RailwayUrl = "https://pola-backend-production.up.railway.app"
$Callback = "$RailwayUrl/auth/google/callback"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AKTIFKAN LOGIN GOOGLE — POLA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Membuka Google Cloud Console..." -ForegroundColor Yellow
Start-Process "https://console.cloud.google.com/apis/credentials"
Write-Host ""
Write-Host "Buat OAuth Client -> Web application, lalu isi:" -ForegroundColor Green
Write-Host "  Origins : $RailwayUrl"
Write-Host "  Redirect: $Callback"
Write-Host ""

$ClientId = Read-Host "Tempel GOOGLE Client ID"
$ClientSecret = Read-Host "Tempel GOOGLE Client Secret"
if ([string]::IsNullOrWhiteSpace($ClientId) -or [string]::IsNullOrWhiteSpace($ClientSecret)) {
    Write-Host "Dibatalkan — Client ID/Secret kosong." -ForegroundColor Yellow
    exit 1
}
$ClientId = $ClientId.Trim()
$ClientSecret = $ClientSecret.Trim()

# Root .env (untuk Flutter native / build)
$EnvFile = Join-Path $Root ".env"
$raw = Get-Content $EnvFile -Raw -ErrorAction SilentlyContinue
if (-not $raw) { $raw = "" }
if ($raw -notmatch 'GOOGLE_WEB_CLIENT_ID=') { $raw += "`nGOOGLE_WEB_CLIENT_ID=`nGOOGLE_SERVER_CLIENT_ID=`n" }
$raw = [regex]::Replace($raw, '(?m)^GOOGLE_WEB_CLIENT_ID=.*$', "GOOGLE_WEB_CLIENT_ID=$ClientId")
$raw = [regex]::Replace($raw, '(?m)^GOOGLE_SERVER_CLIENT_ID=.*$', "GOOGLE_SERVER_CLIENT_ID=$ClientId")
Set-Content -Path $EnvFile -Value $raw -NoNewline

# server/.env lokal
$ServerEnv = Join-Path $Root "server\.env"
if (-not (Test-Path $ServerEnv)) { Copy-Item (Join-Path $Root "server\.env.example") $ServerEnv -ErrorAction SilentlyContinue }
if (Test-Path $ServerEnv) {
    $sraw = Get-Content $ServerEnv -Raw
    if ($sraw -notmatch 'GOOGLE_CLIENT_ID=') { $sraw += "`nGOOGLE_CLIENT_ID=`nGOOGLE_CLIENT_SECRET=`n" }
    $sraw = [regex]::Replace($sraw, '(?m)^GOOGLE_CLIENT_ID=.*$', "GOOGLE_CLIENT_ID=$ClientId")
    $sraw = [regex]::Replace($sraw, '(?m)^GOOGLE_CLIENT_SECRET=.*$', "GOOGLE_CLIENT_SECRET=$ClientSecret")
    Set-Content -Path $ServerEnv -Value $sraw -NoNewline
}

Write-Host ""
Write-Host "Menyimpan ke Railway Variables..." -ForegroundColor Cyan
Set-Location (Join-Path $Root "server")
railway variable set "GOOGLE_CLIENT_ID=$ClientId" --skip-deploys
railway variable set "GOOGLE_CLIENT_SECRET=$ClientSecret" --skip-deploys
railway variable set "PUBLIC_BASE_URL=$RailwayUrl" --skip-deploys
Write-Host "Redeploy..." -ForegroundColor Cyan
railway up -y -d
Write-Host ""
Write-Host "SELESAI. Tes:" -ForegroundColor Green
Write-Host "  $RailwayUrl/auth/google/status" -ForegroundColor Yellow
Write-Host "  $RailwayUrl/app/  -> Login -> Lanjutkan dengan Google" -ForegroundColor Yellow
