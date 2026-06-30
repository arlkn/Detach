#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="Detach"
DISPLAY_NAME="Detach"
BUNDLE_ID="dev.local.Detach"
MIN_SYSTEM_VERSION="13.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/Run"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
PKG_INFO="$APP_CONTENTS/PkgInfo"
PROJECT="$ROOT_DIR/Detach.xcodeproj"
APP_LOGO="$ROOT_DIR/Detach/Resources/AppLogo.png"
APP_ICON="$ROOT_DIR/Detach/Resources/AppIcon.png"

SOURCES=(
  "$ROOT_DIR/Detach/AppUninstallerApp.swift"
  "$ROOT_DIR/Detach/Views/ContentView.swift"
  "$ROOT_DIR/Detach/Views/SettingsView.swift"
  "$ROOT_DIR/Detach/ViewModels/AppUninstallerViewModel.swift"
  "$ROOT_DIR/Detach/Models/InstalledApp.swift"
  "$ROOT_DIR/Detach/Models/AppPreferences.swift"
  "$ROOT_DIR/Detach/Models/RelatedFile.swift"
  "$ROOT_DIR/Detach/Models/DeletionManifest.swift"
  "$ROOT_DIR/Detach/Services/AppScanner.swift"
  "$ROOT_DIR/Detach/Services/RelatedFileScanner.swift"
  "$ROOT_DIR/Detach/Services/FileDeletionService.swift"
  "$ROOT_DIR/Detach/Services/TrashService.swift"
  "$ROOT_DIR/Detach/Services/AdminTrashService.swift"
  "$ROOT_DIR/Detach/Services/AccessibilityPermissionService.swift"
  "$ROOT_DIR/Detach/Services/RestoreService.swift"
  "$ROOT_DIR/Detach/Services/RiskClassifier.swift"
  "$ROOT_DIR/Detach/Services/ManifestStore.swift"
  "$ROOT_DIR/Detach/Utilities/FileManager+Sizing.swift"
  "$ROOT_DIR/Detach/Utilities/ByteCount.swift"
)

stop_running_app() {
  pkill -x "$APP_NAME" >/dev/null 2>&1 || true
  pkill -x "Panelmac" >/dev/null 2>&1 || true
  pkill -x "Detach" >/dev/null 2>&1 || true
}

build_with_xcode_if_available() {
  local xcodebuild_bin=""
  if [[ -x "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
    xcodebuild_bin="/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
  elif xcrun xcodebuild -version >/dev/null 2>&1; then
    xcodebuild_bin="$(xcrun --find xcodebuild)"
  else
    return 1
  fi

  if ! "$xcodebuild_bin" -version >/dev/null 2>&1; then
    return 1
  fi

  "$xcodebuild_bin" \
    -project "$PROJECT" \
    -scheme "$APP_NAME" \
    -configuration Debug \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    CODE_SIGNING_ALLOWED=NO \
    build

  local built_app
  built_app="$(find "$BUILD_DIR/DerivedData/Build/Products/Debug" -maxdepth 1 -name "$APP_NAME.app" -print -quit)"
  [[ -n "$built_app" ]]
  rm -rf "$APP_BUNDLE"
  cp -R "$built_app" "$APP_BUNDLE"
}

build_with_swiftc() {
  rm -rf "$APP_BUNDLE"
  mkdir -p "$APP_MACOS"
  CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-/private/tmp/detach-module-cache}" \
    xcrun swiftc -o "$APP_BINARY" "${SOURCES[@]}"
  chmod +x "$APP_BINARY"

  cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon.png</string>
  <key>CFBundleIconName</key>
  <string>AppIcon</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST
  mkdir -p "$APP_RESOURCES"
  cp "$APP_LOGO" "$APP_RESOURCES/AppLogo.png"
  cp "$APP_ICON" "$APP_RESOURCES/AppIcon.png"
  printf "APPL????" >"$PKG_INFO"
  xattr -cr "$APP_BUNDLE" 2>/dev/null || true
  codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null 2>&1 || true
  touch "$APP_BUNDLE"
}

build_app() {
  mkdir -p "$BUILD_DIR"
  if ! build_with_xcode_if_available; then
    echo "Full Xcode is not available; falling back to swiftc app bundle build." >&2
    build_with_swiftc
  fi
}

open_app() {
  xattr -cr "$APP_BUNDLE" 2>/dev/null || true
  codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null 2>&1 || true
  /usr/bin/open -n "$APP_BUNDLE" || true
}

stop_running_app
build_app

case "$MODE" in
  --build-only|build)
    ;;
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 2
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--build-only|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
