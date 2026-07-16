#!/bin/bash

set -e

cd "$(dirname "$0")/.."

if [ ! -d "CommandTabSwitcher.xcodeproj" ]; then
    echo "Xcode project was not found. Generating it..."
    ./scripts/generate-project.sh
fi

echo "Building CommandTabSwitcher..."

xcodebuild \
    -project CommandTabSwitcher.xcodeproj \
    -scheme CommandTabSwitcher \
    -configuration Debug \
    -derivedDataPath .build \
    build

echo "Build completed."
echo "Application: .build/Build/Products/Debug/CommandTabSwitcher.app"
