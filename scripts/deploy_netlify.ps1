# Deploy website POLA ke Netlify (butuh login sekali).
#   npx --yes netlify-cli login
#   powershell -ExecutionPolicy Bypass -File scripts\deploy_netlify.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$SiteDir = Join-Path $Root "releases\POLA-website"
if (-not (Test-Path (Join-Path $SiteDir "index.html"))) {
    Write-Host "Build website dulu..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_website.ps1")
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Deploy ke Netlify (production)..." -ForegroundColor Cyan
npx --yes netlify-cli deploy --dir="$SiteDir" --prod --message "POLA website deploy"
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Gagal. Login dulu:" -ForegroundColor Yellow
    Write-Host "  npx --yes netlify-cli login" -ForegroundColor White
    Write-Host "Lalu jalankan ulang skrip ini." -ForegroundColor Yellow
    exit $LASTEXITCODE
}
