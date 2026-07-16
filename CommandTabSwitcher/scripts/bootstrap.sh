#!/bin/bash

set -e

cd "$(dirname "$0")/.."

echo "Geliştirme ortamı kontrol ediliyor..."

for command_name in swift xcodebuild xcrun xcodegen; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Eksik araç: $command_name"

        if [ "$command_name" = "xcodegen" ]; then
            echo "Kurmak için: brew install xcodegen"
        fi

        exit 1
    fi

    echo "Bulundu: $command_name"
done

echo ""
echo "Swift:"
swift --version

echo ""
echo "Xcode:"
xcodebuild -version

echo ""
echo "macOS SDK:"
xcrun --sdk macosx --show-sdk-path

echo ""
echo "XcodeGen:"
xcodegen --version

echo ""
echo "Proje oluşturuluyor..."
./scripts/generate-project.sh

echo ""
echo "İlk derleme yapılıyor..."
./scripts/build.sh

echo ""
echo "Bootstrap tamamlandı."
