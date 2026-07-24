# Test runner script for POLA Chatbot
# Usage: powershell -ExecutionPolicy Bypass -File run_tests.ps1

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
Set-Location $Root

Write-Host "=== 1/3 Setup Python Environment ===" -ForegroundColor Green

# Verify python is installed
try {
    $pyVersion = python --version
    Write-Host "Found Python: $pyVersion" -ForegroundColor Gray
} catch {
    Write-Host "Error: Python is not installed or not in PATH. Please install Python 3." -ForegroundColor Red
    exit 1
}

$VenvDir = Join-Path $Root ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Creating virtual environment in .venv..." -ForegroundColor Gray
    python -m venv .venv
} else {
    Write-Host "Virtual environment .venv already exists." -ForegroundColor Gray
}

$PipExe = Join-Path $VenvDir "Scripts\pip.exe"
$PyExe = Join-Path $VenvDir "Scripts\python.exe"
$PytestExe = Join-Path $VenvDir "Scripts\pytest.exe"

Write-Host "`n=== 2/3 Installing dependencies ===" -ForegroundColor Green
& $PipExe install --upgrade pip
& $PipExe install -r tests_python\requirements.txt

Write-Host "`n=== 3/3 Running test suite with pytest ===" -ForegroundColor Green
Write-Host "Running: pytest tests_python/ -v" -ForegroundColor Cyan
Write-Host "This will automatically spawn the backend Node.js and website proxy servers as needed." -ForegroundColor Gray
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

try {
    & $PytestExe tests_python/ -v --capture=no
    Write-Host "`n============================================================" -ForegroundColor Green
    Write-Host "  SELESAI: Semua pengujian berhasil dijalankan!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
} catch {
    Write-Host "`n============================================================" -ForegroundColor Red
    Write-Host "  GAGAL: Beberapa pengujian mengalami error/kegagalan." -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    exit 1
}
