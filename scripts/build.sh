#!/usr/bin/env bash
set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_FILE="$PROJECT_DIR/src/BridgeFix.m"
OUTPUT_DIR="$PROJECT_DIR/build"
OUTPUT_FILE="$OUTPUT_DIR/BridgeFix.dylib"

mkdir -p "$OUTPUT_DIR"

echo "==> Detecting Xcode iOS SDK..."
SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"
echo "    Using SDK: $SDK_PATH"

echo "==> Compiling BridgeFix.dylib for arm64 & arm64e..."
xcrun --sdk iphoneos clang \
    -arch arm64 \
    -arch arm64e \
    -shared \
    -framework Foundation \
    -framework WebKit \
    -isysroot "$SDK_PATH" \
    -miphoneos-version-min=15.0 \
    -install_name @executable_path/BridgeFix.dylib \
    -O2 \
    -o "$OUTPUT_FILE" \
    "$SRC_FILE"

echo "==> Ad-hoc signing BridgeFix.dylib..."
codesign -s - --force "$OUTPUT_FILE"

echo "==> Verifying architectures..."
lipo -info "$OUTPUT_FILE"

echo "==> Build successful: $OUTPUT_FILE"
