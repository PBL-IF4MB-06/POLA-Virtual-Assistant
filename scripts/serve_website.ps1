# Jalankan website download POLA + aplikasi web di jaringan lokal.
# Cocok untuk test di HP (Android/iPhone) sebelum upload ke internet.
#
#   powershell -ExecutionPolicy Bypass -File scripts\serve_website.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$SiteDir = Join-Path $Root "releases\POLA-website"
if (-not (Test-Path (Join-Path $SiteDir "index.html"))) {
    Write-Host "Website belum di-build. Jalankan dulu:" -ForegroundColor Yellow
    Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\build_website.ps1" -ForegroundColor Cyan
    exit 1
}

function Get-LanIp {
    $addrs = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*" -and
            $_.PrefixOrigin -ne "WellKnown"
        } |
        Sort-Object InterfaceMetric
    if ($addrs) { return $addrs[0].IPAddress }
    return $null
}

$LanIp = Get-LanIp
if (-not $LanIp) { $LanIp = "127.0.0.1" }

$LocalBackend = "http://127.0.0.1:8787"

function Test-PolaWebsitePort {
    param([int]$CheckPort)
    try {
        $root = Invoke-WebRequest -Uri "http://127.0.0.1:${CheckPort}/" -TimeoutSec 2 -UseBasicParsing
        $app = Invoke-WebRequest -Uri "http://127.0.0.1:${CheckPort}/app/" -TimeoutSec 2 -UseBasicParsing
        $okRoot = $root.Content -match "Download Aplikasi Chatbot AI Polibatam"
        return ($okRoot -and $app.StatusCode -eq 200)
    } catch {
        return $false
    }
}

function Get-FreePolaPort {
    param([int]$StartPort = 8080)
    foreach ($candidate in ($StartPort..($StartPort + 10))) {
        $busy = Get-NetTCPConnection -LocalPort $candidate -State Listen -ErrorAction SilentlyContinue
        if (-not $busy) { return $candidate }
        if (Test-PolaWebsitePort $candidate) { return $candidate }
        Write-Host ""
        Write-Host "Port $candidate dipakai server LAIN (bukan website POLA)." -ForegroundColor Red
        Write-Host "Tutup jendela PowerShell lama yang menjalankan python/http.server, lalu coba lagi." -ForegroundColor Yellow
        Write-Host "Mencoba port berikutnya..." -ForegroundColor Gray
    }
    throw "Tidak ada port kosong ($StartPort-$($StartPort + 10)). Tutup server lama dulu."
}

$Port = Get-FreePolaPort
$SiteUrl = "http://${LanIp}:${Port}"

try {
    $null = Invoke-WebRequest -Uri "$LocalBackend/health" -TimeoutSec 2 -UseBasicParsing
} catch {
    Write-Host "Backend belum jalan. Menjalankan server AI..." -ForegroundColor Yellow
    $serverPath = Join-Path $Root "server"
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "Set-Location '$serverPath'; Write-Host 'Backend POLA - jangan tutup' -ForegroundColor Green; npm start"
    ) | Out-Null
    Start-Sleep -Seconds 4
}

if (Test-PolaWebsitePort $Port) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Website POLA sudah berjalan!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  BUKA DI BROWSER:" -ForegroundColor White
    Write-Host "  http://127.0.0.1:${Port}/" -ForegroundColor Yellow
    Write-Host "  http://127.0.0.1:${Port}/app/" -ForegroundColor Yellow
    Write-Host ""
    if ($Port -ne 8080) {
        Write-Host "  PENTING: Jangan buka port 8080 (server lama/error)." -ForegroundColor Red
        Write-Host "  Gunakan port $Port di atas." -ForegroundColor Red
        Write-Host ""
    }
    Start-Process "http://127.0.0.1:${Port}/"
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Website POLA siap dibuka" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Membuka browser..." -ForegroundColor Gray
Start-Process "http://127.0.0.1:${Port}/"
Write-Host ""
Write-Host "  BUKA DI BROWSER (salin jika perlu):" -ForegroundColor White
Write-Host "  Download : http://127.0.0.1:${Port}/" -ForegroundColor Yellow
Write-Host "  Chatbot  : http://127.0.0.1:${Port}/app/" -ForegroundColor Yellow
Write-Host "  APK      : http://127.0.0.1:${Port}/downloads/POLA-v1.0.0-android.apk" -ForegroundColor Yellow
Write-Host ""
if ($Port -ne 8080) {
    Write-Host "  PENTING: Port 8080 dipakai server lama -> halaman kosong." -ForegroundColor Red
    Write-Host "  Gunakan port $Port, BUKAN 8080." -ForegroundColor Red
    Write-Host ""
}
Write-Host "iPhone: buka $SiteUrl/app/ di Safari -> Add to Home Screen" -ForegroundColor Cyan
Write-Host "Tekan Ctrl+C untuk stop." -ForegroundColor Gray
Write-Host ""

$ProxyScript = Join-Path $Root "scripts\pola_site_server.py"
$env:POLA_BACKEND_PROXY = $LocalBackend
$env:POLA_SITE_ROOT = $SiteDir
python $ProxyScript $Port
