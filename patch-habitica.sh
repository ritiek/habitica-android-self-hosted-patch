#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 new.hostname"
  echo ""
  echo "  new.hostname  Target hostname to replace habitica.com with"
  echo ""
  echo "Example: $0 my-habitica-server.com"
  exit 1
}

# APK download URL and expected checksum
APK_URL="https://github.com/HabitRPG/habitica-android/releases/download/4.4/7971.apk"
EXPECTED_SHA256_CHECKSUM="960a24f9ffeb7258ff628f2ca470c52ac8feb91ed4f7b2540a05400e8b5de2b8"

# Check arguments
if [[ $# -ne 1 ]]; then
  usage
fi

TO="$1"

FROM="habitica.com"
APK_FILENAME="7971.apk"
BUILD_DIR="build"
TARGET_DIR="target"
APK_PATH="$BUILD_DIR/$APK_FILENAME"
BASENAME="$(basename "$APK_FILENAME" .apk)"
OUTDIR="$BUILD_DIR/patched_${BASENAME}"
OUTAPK="$TARGET_DIR/${BASENAME}.apk"
KEYSTORE="$BUILD_DIR/temp-key.jks"

mkdir -p "$BUILD_DIR"

# Clean previous artifacts
if [[ -d "$OUTDIR" ]]; then
  echo "[*] Removing old decompiled directory: $OUTDIR"
  rm -rf "$OUTDIR"
fi

if [[ -f "$OUTAPK" ]]; then
  echo "[*] Removing previous APK: $OUTAPK"
  rm -f "$OUTAPK"
fi

if [[ -f "$KEYSTORE" ]]; then
  echo "[*] Removing old keystore: $KEYSTORE"
  rm -f "$KEYSTORE"
fi

# Download APK if it doesn't exist
if [[ ! -f "$APK_PATH" ]]; then
  echo "[*] Downloading APK from GitHub..."
  if command -v wget >/dev/null 2>&1; then
    wget -c -O "$APK_PATH" "$APK_URL"
  else
    echo "Error: wget not found. Please install."
    exit 1
  fi
else
  echo "[*] APK already exists: $APK_PATH"
fi

# Verify checksum
echo "[*] Verifying checksum..."
if command -v sha256sum >/dev/null 2>&1; then
  ACTUAL_CHECKSUM=$(sha256sum "$APK_PATH" | cut -d' ' -f1)
elif command -v shasum >/dev/null 2>&1; then
  ACTUAL_CHECKSUM=$(shasum -a 256 "$APK_PATH" | cut -d' ' -f1)
else
  echo "Error: Neither sha256sum nor shasum found. Cannot verify checksum."
  exit 1
fi

if [[ "$ACTUAL_CHECKSUM" != "$EXPECTED_SHA256_CHECKSUM" ]]; then
  echo "Error: Checksum mismatch!"
  echo "Expected: $EXPECTED_SHA256_CHECKSUM"
  echo "Actual:   $ACTUAL_CHECKSUM"
  exit 1
fi
echo "[✓] Checksum verification passed"

echo "[*] Decompiling APK..."
apktool d "$APK_PATH" -o "$OUTDIR" -f > /dev/null

echo "[*] Replacing '$FROM' with '$TO'..."
find "$OUTDIR" -type f -exec sed -i "s|$FROM|$TO|g" {} +

echo "[*] Rebuilding APK..."
apktool b "$OUTDIR" -o "$OUTAPK"

echo "[*] Generating temp signing key..."
keytool -genkey -v \
  -keystore "$KEYSTORE" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias temp-key \
  -storepass password \
  -keypass password \
  -dname "CN=Temp, OU=Dev, O=Self, L=None, ST=None, C=US" \
  > /dev/null

echo "[*] Signing APK..."
apksigner sign \
  --ks "$KEYSTORE" \
  --ks-key-alias temp-key \
  --ks-pass pass:password \
  --key-pass pass:password \
  "$OUTAPK"

echo "[✓] Patched and signed APK created at: $OUTAPK"
