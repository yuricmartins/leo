#!/bin/bash
set -e
APP_NAME="Leo"
BUNDLE="$APP_NAME.app"
CONTENTS="$BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
killall Leo 2>/dev/null || true

echo "🎨 Generating app icon..."
SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null || echo "")
if [ -n "$SDK_PATH" ]; then
    swiftc -framework Cocoa -O -sdk "$SDK_PATH" -o GenerateIcon GenerateIcon.swift
else
    swiftc -framework Cocoa -O -o GenerateIcon GenerateIcon.swift
fi
./GenerateIcon
rm -f GenerateIcon

echo "🔨 Compiling Leo..."
if [ -n "$SDK_PATH" ]; then
    swiftc -framework Cocoa -O -sdk "$SDK_PATH" -o "$APP_NAME" Leo.swift
else
    swiftc -framework Cocoa -O -o "$APP_NAME" Leo.swift
fi

echo "📦 Bundling..."
rm -rf "$BUNDLE"
mkdir -p "$MACOS" "$RESOURCES"
mv "$APP_NAME" "$MACOS/"
if [ -f "AppIcon.icns" ]; then cp AppIcon.icns "$RESOURCES/"; fi

cat > "$CONTENTS/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Leo</string>
    <key>CFBundleDisplayName</key><string>Leo</string>
    <key>CFBundleIdentifier</key><string>com.custom.leo</string>
    <key>CFBundleVersion</key><string>1.0.0</string>
    <key>CFBundleShortVersionString</key><string>1.0.0</string>
    <key>CFBundleExecutable</key><string>Leo</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>LSUIElement</key><true/>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
</dict>
</plist>
PLIST

echo "🚚 Installing to /Applications..."
rm -rf "/Applications/$BUNDLE"
cp -r "$BUNDLE" /Applications/

echo "🚀 Launching..."
open "/Applications/$BUNDLE"
echo "✅ Leo installed and running."
