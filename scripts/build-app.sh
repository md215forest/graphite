#!/bin/bash
# Build Graphite into a proper macOS .app bundle for permanent local use.
#
# SwiftPM only produces a bare executable; running that (`swift run`) launches as
# an accessory process and gives the binary an unstable identity, so the Input
# Monitoring grant (needed for the double-tap "show at cursor" gesture) keeps
# resetting. A real .app bundle fixes both: stable identity + Dock/Launchpad
# launch.
#
# Usage:
#   ./scripts/build-app.sh            # build dist/Graphite.app
#   ./scripts/build-app.sh --install  # also copy it to /Applications

set -euo pipefail

APP_NAME="Graphite"
BUNDLE_ID="com.graphite.app"
VERSION="1.0.0"
MIN_MACOS="13.0"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME.app"
CONTENTS="$APP/Contents"

echo "==> Building release binary"
swift build -c release --package-path "$ROOT"
BIN="$(swift build -c release --package-path "$ROOT" --show-bin-path)/$APP_NAME"

echo "==> Generating app icon"
( cd "$ROOT" && swift "$ROOT/scripts/make-icon.swift" )

echo "==> Assembling $APP_NAME.app"
rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
cp "$BIN" "$CONTENTS/MacOS/$APP_NAME"
cp "$DIST/AppIcon.icns" "$CONTENTS/Resources/AppIcon.icns"

cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>LSMinimumSystemVersion</key><string>$MIN_MACOS</string>
    <key>NSPrincipalClass</key><string>NSApplication</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
</dict>
</plist>
PLIST

echo "==> Ad-hoc code signing"
codesign --force --deep --sign - "$APP"

echo "==> Built: $APP"

if [[ "${1:-}" == "--install" ]]; then
    echo "==> Installing to /Applications"
    rm -rf "/Applications/$APP_NAME.app"
    cp -R "$APP" "/Applications/$APP_NAME.app"
    echo "==> Installed: /Applications/$APP_NAME.app"
fi
