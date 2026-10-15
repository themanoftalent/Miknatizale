#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "💿 Packaging Miknatizale.dmg..."

DMG_TEMP_DIR="$DIR/dmg_root"
DMG_OUTPUT="$DIR/Miknatizale.dmg"

# Clean up any existing temp dir and old dmg
rm -rf "$DMG_TEMP_DIR" "$DMG_OUTPUT"
mkdir -p "$DMG_TEMP_DIR"

# Copy Miknatizale.app
echo "📁 Copying Miknatizale.app..."
cp -R "$DIR/Miknatizale.app" "$DMG_TEMP_DIR/"

# Create /Applications symlink for easy drag-and-drop installation
echo "🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# Create disk image with compressed read-only format (UDZO)
echo "📦 Generating compressed UDZO disk image..."
hdiutil create -volname "Miknatizale" \
               -srcfolder "$DMG_TEMP_DIR" \
               -ov \
               -format UDZO \
               "$DMG_OUTPUT"

# Clean up staging directory
rm -rf "$DMG_TEMP_DIR"

echo "✨ Successfully created $DMG_OUTPUT!"
ls -lh "$DMG_OUTPUT"
