#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --apk FILE.apk --to new.hostname"
  exit 1
}

APK=""
TO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apk)
      APK="$2"
      shift 2
      ;;
    --to)
      TO="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

[[ -z "$APK" || -z "$TO" ]] && usage

FROM="habitica.com"
BASENAME="$(basename "$APK" .apk)"

BUILD_DIR="build"
OUTDIR="$BUILD_DIR/patched_${BASENAME}"
OUTAPK="$BUILD_DIR/modified_${BASENAME}.apk"
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

echo "[*] Decompiling APK..."
apktool d "$APK" -o "$OUTDIR" -f > /dev/null

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
