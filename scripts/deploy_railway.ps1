# Build website + salin ke server/public + deploy Railway (gratis).
#
#   powershell -ExecutionPolicy Bypass -File scripts\deploy_railway.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$BackendUrl = "https://pola-backend-production.up.railway.app"
$env:POLA_BACKEND_URL = $BackendUrl

Write-Host "=== 1/3 Build website ===" -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_website.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n=== 2/3 Salin ke server/public ===" -ForegroundColor Cyan
$Src = Join-Path $Root "releases\POLA-website"
$Dst = Join-Path $Root "server\public"
if (Test-Path $Dst) { Remove-Item $Dst -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Dst | Out-Null
Copy-Item "$Src\*" $Dst -Recurse -Force

Write-Host "`n=== 3/3 Deploy Railway ===" -ForegroundColor Cyan
Set-Location (Join-Path $Root "server")
railway up --no-gitignore -y -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "SELESAI. Buka:" -ForegroundColor Green
Write-Host "  $BackendUrl/" -ForegroundColor Yellow
Write-Host "  $BackendUrl/app/" -ForegroundColor Yellow
