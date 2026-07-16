#!/bin/bash

set -e

cd "$(dirname "$0")/.."

echo "Derleme dosyaları temizleniyor..."

rm -rf .build
rm -rf CommandTabSwitcher.xcodeproj

echo "Temizleme tamamlandı."
