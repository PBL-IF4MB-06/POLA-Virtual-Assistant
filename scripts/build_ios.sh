#!/usr/bin/env bash
# Build file instalasi POLA untuk iOS (.ipa)
# Jalankan di Mac dengan Xcode terpasang:
#   chmod +x scripts/build_ios.sh
#   POLA_BACKEND_URL=http://192.168.1.10:8787 ./scripts/build_ios.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT_DIR="$ROOT/releases"
mkdir -p "$OUT_DIR"

BACKEND_URL="${POLA_BACKEND_URL:-http://127.0.0.1:8787}"
if [[ "$BACKEND_URL" == "http://127.0.0.1:8787" ]]; then
  echo "⚠️  POLA_BACKEND_URL tidak di-set. Pakai default: $BACKEND_URL"
  echo "   Untuk iPhone fisik, set IP PC Anda:"
  echo '   export POLA_BACKEND_URL="http://192.168.1.10:8787"'
fi

DEFINE_ARGS=(--dart-define="POLA_BACKEND_URL=$BACKEND_URL")

echo ""
echo "=== Build iOS IPA ==="
flutter build ipa --release "${DEFINE_ARGS[@]}"

IPA_SRC="$ROOT/build/ios/ipa/pola_app.ipa"
IPA_DST="$OUT_DIR/POLA-v1.0.0-ios.ipa"

if [[ -f "$IPA_SRC" ]]; then
  cp -f "$IPA_SRC" "$IPA_DST"
  echo "✅ OK: releases/POLA-v1.0.0-ios.ipa"
else
  echo "❌ File IPA tidak ditemukan di $IPA_SRC"
  echo "   Cek output flutter build ipa di atas."
  exit 1
fi

echo ""
echo "=== Cara distribusi ke iPhone ==="
echo "1. TestFlight — upload .ipa via Xcode Organizer atau Transporter (butuh Apple Developer \$99/tahun)"
echo "2. Xcode langsung — connect iPhone, buka ios/Runner.xcworkspace, Run ke device terdaftar"
echo "3. Alternatif tanpa Mac: bagikan versi web (releases/POLA-web) → Safari → Add to Home Screen"
echo ""
echo "Selesai."
