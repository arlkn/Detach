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
MOUNT_DIR="/Volumes/$APP_NAME"
BACKGROUND_SOURCE="$ROOT_DIR/media/dmg-background.png"
BACKGROUND_DIR="$STAGING_DIR/.background"
BACKGROUND_NAME="dmg-background.png"
SIGN_IDENTITY="${DETACH_SIGN_IDENTITY:--}"
NOTARY_PROFILE="${DETACH_NOTARY_PROFILE:-}"
REQUIRE_NOTARIZATION="${DETACH_REQUIRE_NOTARIZATION:-0}"

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
if [[ "$SIGN_IDENTITY" == "-" ]]; then
  echo "Warning: using ad-hoc signing. Downloaded builds will not pass Gatekeeper without Developer ID notarization." >&2
  if [[ "$REQUIRE_NOTARIZATION" == "1" ]]; then
    echo "DETACH_REQUIRE_NOTARIZATION=1 was set, but DETACH_SIGN_IDENTITY is missing." >&2
    exit 1
  fi
  codesign --force --deep --sign - "$STAGING_DIR/$APP_NAME.app" >/dev/null 2>&1 || true
else
  if [[ "$REQUIRE_NOTARIZATION" == "1" && "$SIGN_IDENTITY" != Developer\ ID\ Application:* ]]; then
    echo "DETACH_REQUIRE_NOTARIZATION=1 requires a Developer ID Application signing identity." >&2
    echo "Current DETACH_SIGN_IDENTITY: $SIGN_IDENTITY" >&2
    exit 1
  fi
  codesign \
    --force \
    --deep \
    --options runtime \
    --timestamp \
    --sign "$SIGN_IDENTITY" \
    "$STAGING_DIR/$APP_NAME.app"
fi
codesign --verify --deep --strict --verbose=2 "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"
mkdir -p "$BACKGROUND_DIR"
cp "$BACKGROUND_SOURCE" "$BACKGROUND_DIR/$BACKGROUND_NAME"

rm -f "$DMG_PATH" "$RW_DMG_PATH"
cleanup
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -ov \
  -format UDRW \
  "$RW_DMG_PATH"

hdiutil attach "$RW_DMG_PATH" \
  -noverify \
  -noautoopen

if [[ ! -d "$MOUNT_DIR" ]]; then
  echo "Expected DMG mount at $MOUNT_DIR, but it was not found." >&2
  exit 1
fi

osascript <<APPLESCRIPT
set backgroundFile to POSIX file "$MOUNT_DIR/.background/$BACKGROUND_NAME" as alias

tell application "Finder"
  tell disk "$APP_NAME"
    open
    delay 2
    set current view of container window to icon view
    try
      set toolbar visible of container window to false
    end try
    try
      set statusbar visible of container window to false
    end try
    set the bounds of container window to {140, 120, 900, 550}
    set theViewOptions to icon view options of container window
    set arrangement of theViewOptions to not arranged
    set icon size of theViewOptions to 112
    set background picture of theViewOptions to backgroundFile
    set position of item "$APP_NAME.app" of container window to {215, 188}
    set position of item "Applications" of container window to {545, 188}
    update without registering applications
    delay 2
    try
      close container window
    end try
  end tell
end tell
APPLESCRIPT

sync
hdiutil detach "$MOUNT_DIR"

hdiutil convert "$RW_DMG_PATH" \
  -format UDZO \
  -imagekey zlib-level=9 \
  -o "$DMG_PATH"
rm -f "$RW_DMG_PATH"

if [[ "$SIGN_IDENTITY" != "-" ]]; then
  codesign --force --sign "$SIGN_IDENTITY" --timestamp "$DMG_PATH"
fi

if [[ -n "$NOTARY_PROFILE" ]]; then
  xcrun notarytool submit "$DMG_PATH" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait
  xcrun stapler staple "$DMG_PATH"
  spctl -a -vv -t open --context context:primary-signature "$DMG_PATH"
elif [[ "$REQUIRE_NOTARIZATION" == "1" ]]; then
  echo "DETACH_REQUIRE_NOTARIZATION=1 was set, but DETACH_NOTARY_PROFILE is missing." >&2
  exit 1
else
  echo "Warning: DMG was not notarized. macOS Gatekeeper may block downloaded builds." >&2
fi

echo "$DMG_PATH"
