#!/bin/bash

set -e

cd "$(dirname "$0")/.."

APP_PATH=".build/Build/Products/Debug/CommandTabSwitcher.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Uygulama henüz derlenmemiş. Derleme başlatılıyor..."
    ./scripts/build.sh
fi

echo "CommandTabSwitcher başlatılıyor..."

pkill -x CommandTabSwitcher 2>/dev/null || true
open "$APP_PATH"
