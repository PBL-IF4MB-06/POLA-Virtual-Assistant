# Buat akun admin POLA di Supabase Auth (signup) lalu jalankan SQL promote.
# Usage: .\scripts\setup_admin.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$envFile = Join-Path $root ".env"

if (-not (Test-Path $envFile)) {
  Write-Host "File .env tidak ditemukan. Salin dari .env.example dan isi SUPABASE_*." -ForegroundColor Red
  exit 1
}

$url = ""
$key = ""
Get-Content $envFile | ForEach-Object {
  if ($_ -match '^SUPABASE_URL=(.+)$') { $url = $matches[1].Trim() }
  if ($_ -match '^SUPABASE_ANON_KEY=(.+)$') { $key = $matches[1].Trim() }
}

if ([string]::IsNullOrWhiteSpace($url) -or [string]::IsNullOrWhiteSpace($key)) {
  Write-Host "SUPABASE_URL atau SUPABASE_ANON_KEY kosong di .env" -ForegroundColor Red
  exit 1
}

$adminEmail = "admin@polibatam.ac.id"
$adminPassword = "AdminPola2026!"

$body = @{
  email = $adminEmail
  password = $adminPassword
  data = @{ full_name = "Admin POLA" }
} | ConvertTo-Json

Write-Host "Mendaftarkan $adminEmail ke Supabase Auth..." -ForegroundColor Cyan

try {
  $resp = Invoke-RestMethod `
    -Uri "$url/auth/v1/signup" `
    -Method POST `
    -Headers @{ apikey = $key; "Content-Type" = "application/json" } `
    -Body $body
  Write-Host "Signup berhasil." -ForegroundColor Green
  if ($resp.user) { Write-Host "User ID: $($resp.user.id)" }
} catch {
  $msg = $_.ErrorDetails.Message
  if ($msg -match "already registered") {
    Write-Host "Akun sudah terdaftar — lanjut ke SQL promote." -ForegroundColor Yellow
  } else {
    Write-Host "Signup gagal: $msg" -ForegroundColor Red
    exit 1
  }
}

Write-Host ""
Write-Host "Langkah berikutnya:" -ForegroundColor Cyan
Write-Host "1. Buka Supabase Dashboard → SQL Editor"
Write-Host "2. Jalankan isi file: supabase/setup_admin.sql"
Write-Host ""
Write-Host "Login di app:" -ForegroundColor Green
Write-Host "  Email   : $adminEmail"
Write-Host "  Password: $adminPassword"
Write-Host ""
Write-Host "Demo lokal (tanpa cloud):" -ForegroundColor Green
Write-Host "  Email   : admin@pola.app"
Write-Host "  Password: admin12345"
