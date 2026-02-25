#!/usr/bin/env bash
set -euo pipefail

# Generate an Xcode project using xcodegen.
# Installs xcodegen via Homebrew if it's not present.

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Installing via Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Please install Homebrew or install xcodegen manually: https://github.com/yonaskolb/XcodeGen"
    exit 1
  fi
  brew install xcodegen
fi

echo "Generating Xcode project..."
pushd "$(dirname "$0")" >/dev/null
xcodegen generate --spec project.yml
popd >/dev/null

echo "Done. Open PaceTracker.xcodeproj in Xcode." 
