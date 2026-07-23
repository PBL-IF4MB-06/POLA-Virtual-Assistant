# Hosting publik sementara via Cloudflare Tunnel (HP/PC bisa akses dari internet).
# Website + proxy AI jalan di PC ini. Untuk hosting permanen lihat HOSTING.md
#
#   powershell -ExecutionPolicy Bypass -File scripts\host_public.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$SiteDir = Join-Path $Root "releases\POLA-website"
if (-not (Test-Path (Join-Path $SiteDir "index.html"))) {
    Write-Host "Website belum di-build. Membangun sekarang..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_website.ps1")
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

try {
    $null = Invoke-WebRequest -Uri "http://127.0.0.1:8787/health" -TimeoutSec 2 -UseBasicParsing
} catch {
    Write-Host "Menyalakan backend AI di port 8787..." -ForegroundColor Yellow
    $serverPath = Join-Path $Root "server"
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "Set-Location '$serverPath'; Write-Host 'Backend POLA (jangan tutup)' -ForegroundColor Green; npm start"
    ) | Out-Null
    Start-Sleep -Seconds 5
}

$port = 8080
foreach ($p in 8080..8090) {
    $b = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
    if (-not $b) { $port = $p; break }
}

$ProxyScript = Join-Path $Root "scripts\pola_site_server.py"
Write-Host "Menyalakan website + API proxy di port $port ..." -ForegroundColor Yellow
$env:POLA_BACKEND_PROXY = "http://127.0.0.1:8787"
$env:POLA_SITE_ROOT = $SiteDir
$siteProc = Start-Process powershell -PassThru -ArgumentList @(
    "-NoExit", "-Command",
    "`$env:POLA_BACKEND_PROXY='http://127.0.0.1:8787'; `$env:POLA_SITE_ROOT='$SiteDir'; Set-Location '$Root'; Write-Host 'Website+proxy POLA :$port (jangan tutup)' -ForegroundColor Green; python '$ProxyScript' $port"
)

Start-Sleep -Seconds 3

$cloudflared = Get-Command cloudflared -ErrorAction SilentlyContinue
$cfPath = $null
if ($cloudflared) {
    $cfPath = $cloudflared.Source
} else {
    $found = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "cloudflared.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $cfPath = $found.FullName }
}

Write-Host ""
Write-Host "Salin URL publik yang muncul. Contoh:" -ForegroundColor Yellow
Write-Host "  Landing : URL/" -ForegroundColor White
Write-Host "  Chatbot : URL/app/" -ForegroundColor White
Write-Host "  APK     : URL/downloads/POLA-v1.0.0-android.apk" -ForegroundColor White
Write-Host "Ctrl+C untuk berhenti. Jangan tutup jendela backend/website." -ForegroundColor Gray
Write-Host ""

if ($cfPath) {
    Write-Host "Membuka Cloudflare Tunnel..." -ForegroundColor Cyan
    & $cfPath tunnel --url "http://127.0.0.1:$port"
} else {
    Write-Host "cloudflared tidak di PATH - pakai localtunnel..." -ForegroundColor Yellow
    npx --yes localtunnel --port $port
}
