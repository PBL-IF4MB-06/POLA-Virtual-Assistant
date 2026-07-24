# Jalankan POLA di iPhone TANPA Mac - via Safari Add to Home Screen
#
# Syarat:
#   - PC Windows dan iPhone di WiFi yang SAMA
#   - Python terpasang (biasanya sudah ada di Windows)
#   - Backend AI sudah jalan (script ini bisa jalankan otomatis)
#
# Cara pakai (dari root proyek):
#   powershell -ExecutionPolicy Bypass -File scripts\serve_ios_pwa.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

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

function Ensure-FirewallPort {
    param([int]$Port)
    try {
        $existing = Get-NetFirewallRule -DisplayName "POLA Port $Port" -ErrorAction SilentlyContinue
        if (-not $existing) {
            New-NetFirewallRule -DisplayName "POLA Port $Port" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -ErrorAction Stop | Out-Null
            Write-Host "Firewall: port $Port diizinkan." -ForegroundColor Green
        }
    } catch {
        Write-Host "Firewall: tidak bisa buka port $Port otomatis (butuh Run as Administrator)." -ForegroundColor Yellow
        Write-Host "         Chatbot mungkin loading terus jika port diblokir." -ForegroundColor Yellow
    }
}

$LanIp = Get-LanIp
if (-not $LanIp) {
    Write-Host "Tidak menemukan IP WiFi. Pastikan PC terhubung WiFi." -ForegroundColor Red
    exit 1
}

$WebPort = 8080
$WebUrl = "http://${LanIp}:${WebPort}"
$LocalBackend = "http://127.0.0.1:8787"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  POLA untuk iPhone (tanpa Mac)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IP PC Anda    : $LanIp" -ForegroundColor Green
Write-Host "Link iPhone   : $WebUrl" -ForegroundColor Yellow
Write-Host "Backend lokal : $LocalBackend (proxy lewat port $WebPort)" -ForegroundColor Green
Write-Host ""

Ensure-FirewallPort -Port $WebPort

Write-Host "Mem-build versi web (sekitar 1-2 menit)..." -ForegroundColor Gray
Write-Host "Backend URL untuk iPhone: $WebUrl" -ForegroundColor Gray
flutter build web --release --dart-define="POLA_BACKEND_URL=$WebUrl"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$WebDir = Join-Path $Root "build\web"
if (-not (Test-Path $WebDir)) {
    Write-Host "Build web gagal - folder build\web tidak ada." -ForegroundColor Red
    exit 1
}

$ServerRunning = $false
try {
    $null = Invoke-WebRequest -Uri "$LocalBackend/health" -TimeoutSec 2 -UseBasicParsing
    $ServerRunning = $true
} catch {}

if (-not $ServerRunning) {
    Write-Host "Backend belum jalan. Menjalankan server AI..." -ForegroundColor Yellow
    $serverPath = Join-Path $Root "server"
    Start-Process powershell -ArgumentList @(
        "-NoExit", "-Command",
        "Set-Location '$serverPath'; Write-Host 'Backend POLA - jangan tutup jendela ini' -ForegroundColor Green; npm start"
    ) | Out-Null
    Write-Host "Menunggu backend siap..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    try {
        $null = Invoke-WebRequest -Uri "$LocalBackend/health" -TimeoutSec 5 -UseBasicParsing
        $ServerRunning = $true
    } catch {}
}

if (-not $ServerRunning) {
    Write-Host "Backend AI belum bisa dihubungi di $LocalBackend" -ForegroundColor Red
    Write-Host "Jalankan manual: cd server lalu npm start" -ForegroundColor Yellow
    exit 1
}

$health = Invoke-RestMethod -Uri "$LocalBackend/health" -TimeoutSec 5
if (-not ($health.koboiConfigured -or $health.geminiConfigured -or $health.hfConfigured)) {
    Write-Host ""
    Write-Host "PERINGATAN: API key AI belum di-set di server/.env" -ForegroundColor Red
    Write-Host "Isi KOBOI_API_KEY (KoboiLLM) atau GEMINI_API_KEY." -ForegroundColor Red
    Write-Host "Salin server/.env.example ke server/.env lalu isi key Anda." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "Menjalankan web + proxy API di $WebUrl ..." -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CARA INSTALL DI iPhone:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host '  1. iPhone dan PC harus WiFi SAMA' -ForegroundColor White
Write-Host '  2. Buka Safari di iPhone' -ForegroundColor White
Write-Host "  3. Ketik alamat: $WebUrl" -ForegroundColor Yellow
Write-Host '  4. Tap ikon Share (kotak + panah)' -ForegroundColor White
Write-Host '  5. Pilih Add to Home Screen / Tambahkan ke Layar Utama' -ForegroundColor White
Write-Host '  6. Tap Add / Tambah' -ForegroundColor White
Write-Host ""
Write-Host 'Jika sudah pernah Add to Home Screen, buka link Safari lagi (build baru).' -ForegroundColor Yellow
Write-Host ""
Write-Host 'Tekan Ctrl+C untuk stop web server.' -ForegroundColor Gray
Write-Host ""

$ProxyScript = Join-Path $Root "scripts\pola_web_proxy.py"
$env:POLA_BACKEND_PROXY = $LocalBackend
python $ProxyScript $WebDir $WebPort
