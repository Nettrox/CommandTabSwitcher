#!/bin/bash

set -e

cd "$(dirname "$0")/.."

SOURCE_ICON="CommandTabSwitcher/Resources/AppIcon.png"
APPICON_DIR="CommandTabSwitcher/Resources/Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon was not found:"
    echo "$SOURCE_ICON"
    exit 1
fi

mkdir -p "$APPICON_DIR"

echo "Generating macOS application icons..."

sips -z 16 16 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_16x16.png" >/dev/null

sips -z 32 32 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_16x16@2x.png" >/dev/null

sips -z 32 32 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_32x32.png" >/dev/null

sips -z 64 64 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_32x32@2x.png" >/dev/null

sips -z 128 128 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_128x128.png" >/dev/null

sips -z 256 256 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_128x128@2x.png" >/dev/null

sips -z 256 256 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_256x256.png" >/dev/null

sips -z 512 512 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_256x256@2x.png" >/dev/null

sips -z 512 512 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_512x512.png" >/dev/null

sips -z 1024 1024 "$SOURCE_ICON" \
    --out "$APPICON_DIR/icon_512x512@2x.png" >/dev/null

echo "Application icons generated successfully."
