#!/bin/bash

set -e

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
    echo "Hata: XcodeGen kurulu değil."
    echo "Kurmak için: brew install xcodegen"
    exit 1
fi

echo "Xcode projesi oluşturuluyor..."
xcodegen generate

echo "Proje oluşturuldu: CommandTabSwitcher.xcodeproj"
