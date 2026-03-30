#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="WebBar.app"
SOURCE_APP="$ROOT_DIR/dist/$APP_NAME"
TARGET_APP="$HOME/Applications/$APP_NAME"

# Always rebuild before install so plist/icon changes are not skipped.
bash "$ROOT_DIR/scripts/build_app.sh"

# Stop any running instance before replacing the bundle on disk.
pkill -f "$TARGET_APP/Contents/MacOS/WebBar" || true

mkdir -p "$HOME/Applications"
rm -rf "$TARGET_APP"
cp -R "$SOURCE_APP" "$TARGET_APP"

echo "Installed: $TARGET_APP"
