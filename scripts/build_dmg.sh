#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="WebBar"
APP_PATH="$ROOT_DIR/dist/$APP_NAME.app"
DMG_STAGE_DIR="$ROOT_DIR/dist/dmg"
VOLUME_NAME="WebBar"
INFO_PLIST="$ROOT_DIR/Resources/Info.plist"
SHORT_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
DMG_PATH="$ROOT_DIR/dist/${APP_NAME}-${SHORT_VERSION}.dmg"

bash "$ROOT_DIR/scripts/build_app.sh"

rm -rf "$DMG_STAGE_DIR" "$DMG_PATH"
mkdir -p "$DMG_STAGE_DIR"

cp -R "$APP_PATH" "$DMG_STAGE_DIR/$APP_NAME.app"
ln -s /Applications "$DMG_STAGE_DIR/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$DMG_STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

echo "Built dmg: $DMG_PATH"
