#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Detach"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_BUNDLE="$BUILD_DIR/Run/$APP_NAME.app"
DIST_DIR="$BUILD_DIR/dist"
STAGING_DIR="$BUILD_DIR/dmg-staging"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
RW_DMG_PATH="$DIST_DIR/$APP_NAME-rw.dmg"
MOUNT_DIR="$BUILD_DIR/dmg-mount"
BACKGROUND_SOURCE="$ROOT_DIR/media/dmg-background.png"
BACKGROUND_DIR="$STAGING_DIR/.background"
BACKGROUND_NAME="dmg-background.png"

cleanup() {
  if mount | grep -q "on $MOUNT_DIR "; then
    hdiutil detach "$MOUNT_DIR" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

"$ROOT_DIR/script/build_and_run.sh" --build-only

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR" "$DIST_DIR"
ditto --norsrc --noextattr "$APP_BUNDLE" "$STAGING_DIR/$APP_NAME.app"
codesign --force --deep --sign - "$STAGING_DIR/$APP_NAME.app" >/dev/null 2>&1 || true
codesign --verify --deep --strict --verbose=2 "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"
mkdir -p "$BACKGROUND_DIR"
cp "$BACKGROUND_SOURCE" "$BACKGROUND_DIR/$BACKGROUND_NAME"

rm -f "$DMG_PATH" "$RW_DMG_PATH"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -ov \
  -format UDRW \
  "$RW_DMG_PATH"

rm -rf "$MOUNT_DIR"
mkdir -p "$MOUNT_DIR"
hdiutil attach "$RW_DMG_PATH" \
  -mountpoint "$MOUNT_DIR" \
  -nobrowse \
  -noverify \
  -noautoopen

osascript <<APPLESCRIPT
set dmgFolder to POSIX file "$MOUNT_DIR" as alias
set backgroundFile to POSIX file "$MOUNT_DIR/.background/$BACKGROUND_NAME" as alias

tell application "Finder"
  open dmgFolder
  delay 1
  set containerWindow to container window of dmgFolder
  set current view of containerWindow to icon view
  try
    set toolbar visible of containerWindow to false
  end try
  try
    set statusbar visible of containerWindow to false
  end try
  set the bounds of containerWindow to {140, 120, 900, 550}
  set theViewOptions to icon view options of containerWindow
  set arrangement of theViewOptions to not arranged
  set icon size of theViewOptions to 112
  set background picture of theViewOptions to backgroundFile
  set position of item "$APP_NAME.app" of dmgFolder to {215, 188}
  set position of item "Applications" of dmgFolder to {545, 188}
  update dmgFolder without registering applications
  delay 1
  try
    close containerWindow
  end try
  delay 1
  open dmgFolder
  delay 1
  try
    close container window of dmgFolder
  end try
end tell
APPLESCRIPT

sync
hdiutil detach "$MOUNT_DIR"
rm -rf "$MOUNT_DIR"

hdiutil convert "$RW_DMG_PATH" \
  -format UDZO \
  -imagekey zlib-level=9 \
  -o "$DMG_PATH"
rm -f "$RW_DMG_PATH"

echo "$DMG_PATH"
