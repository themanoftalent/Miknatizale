#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "🔨 Building Miknatizale in release mode..."
swift build -c release

echo "📦 Updating Miknatizale.app bundle..."
mkdir -p Miknatizale.app/Contents/MacOS Miknatizale.app/Contents/Resources
cp .build/release/Miknatizale Miknatizale.app/Contents/MacOS/
if [ -f Miknatizale.icns ]; then
    cp Miknatizale.icns Miknatizale.app/Contents/Resources/
fi

cat << 'EOF' > Miknatizale.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Miknatizale</string>
    <key>CFBundleIconFile</key>
    <string>Miknatizale</string>
    <key>CFBundleIdentifier</key>
    <string>com.replica.miknatizale</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Miknatizale</string>
    <key>CFBundleDisplayName</key>
    <string>Miknatizale</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>3.0</string>
    <key>CFBundleVersion</key>
    <string>3.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Miknatizale. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "🔏 Signing application bundle..."
codesign --force --deep --sign - Miknatizale.app

echo "💿 Building Miknatizale.dmg..."
./make_dmg.sh

echo "✅ All done! Miknatizale.app and Miknatizale.dmg are ready."
