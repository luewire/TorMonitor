#!/bin/bash
set -euo pipefail

APP_NAME="TorMonitor"
BUNDLE_DIR="build/${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
# Auto-detect architecture
ARCH=$(uname -m)
if [ "${ARCH}" = "x86_64" ]; then
    TARGET="x86_64-apple-macos13.0"
else
    TARGET="arm64-apple-macos13.0"
fi
SDK=$(xcrun --show-sdk-path --sdk macosx)

SOURCES=(
    TorMonitor/App/TorMonitorApp.swift
    TorMonitor/Core/SMCService.swift
    TorMonitor/Core/CPUService.swift
    TorMonitor/Core/MemoryService.swift
    TorMonitor/Core/NetworkService.swift
    TorMonitor/Core/MonitorManager.swift
    TorMonitor/Core/CpuTempToggle.swift
    TorMonitor/Core/CpuToggle.swift
    TorMonitor/Core/MemoryToggle.swift
    TorMonitor/Core/NetworkToggle.swift
    TorMonitor/Core/BatteryService.swift
    TorMonitor/Core/BatteryToggle.swift
    TorMonitor/Core/LaunchAtLoginService.swift
    TorMonitor/Core/PrivilegeService.swift
    TorMonitor/Core/StatusBarController.swift
    TorMonitor/Core/Localization.swift
    TorMonitor/Core/ProcessNetworkService.swift
    TorMonitor/Core/ProcessCPUService.swift
    TorMonitor/Core/ProcessMemoryService.swift
    TorMonitor/Core/ConnectionService.swift
    TorMonitor/Core/NetworkProcessPanel.swift
    TorMonitor/Core/CPUProcessPanel.swift
    TorMonitor/Core/MemoryProcessPanel.swift
    TorMonitor/Core/ClickableLabel.swift
    TorMonitor/Core/IP2RegionService.swift

    TorMonitor/Core/EnergyService.swift
    TorMonitor/Core/GPUService.swift
    TorMonitor/Core/GpuToggle.swift
    TorMonitor/Core/GpuTempToggle.swift
    TorMonitor/Views/AppKitSwitch.swift
    TorMonitor/Views/PopoverView.swift
    TorMonitor/Views/SettingsView.swift
)

CONFIG="${1:-release}"

echo "==> Building ${APP_NAME} (${CONFIG})..."

# Clean
rm -rf build
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

# Compile ip2region C sources
C_FLAGS="-std=c99 -Wall -O2 -target ${TARGET} -isysroot ${SDK}"
IP2REGION_DIR="TorMonitor/Vendor/ip2region"
xcrun clang ${C_FLAGS} -c "${IP2REGION_DIR}/xdb_searcher.c" -o build/xdb_searcher.o -I"${IP2REGION_DIR}"
xcrun clang ${C_FLAGS} -c "${IP2REGION_DIR}/xdb_util.c" -o build/xdb_util.o -I"${IP2REGION_DIR}"

# Compile Swift + link C objects
SWIFT_FLAGS="-target ${TARGET} -sdk ${SDK} -framework IOKit -framework SwiftUI -framework AppKit -framework ServiceManagement -framework Security -import-objc-header ${IP2REGION_DIR}/bridge.h -I${IP2REGION_DIR}"
if [ "${CONFIG}" = "debug" ]; then
    SWIFT_FLAGS="${SWIFT_FLAGS} -g -Onone"
else
    SWIFT_FLAGS="${SWIFT_FLAGS} -O"
fi

xcrun swiftc ${SWIFT_FLAGS} -o "${MACOS_DIR}/${APP_NAME}" "${SOURCES[@]}" build/xdb_searcher.o build/xdb_util.o

# Copy resources
cp TorMonitor/Resources/Info.plist "${CONTENTS_DIR}/Info.plist"
cp TorMonitor/Resources/AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"
cp TorMonitor/Resources/ip2region_v4.xdb "${RESOURCES_DIR}/ip2region_v4.xdb"

# Build FinderSync extension (.appex)
APPEX_DIR="${CONTENTS_DIR}/PlugIns/FinderMenu.appex"
APPEX_CONTENTS="${APPEX_DIR}/Contents"
APPEX_MACOS="${APPEX_CONTENTS}/MacOS"
mkdir -p "${APPEX_MACOS}"

xcrun swiftc -target ${TARGET} -sdk ${SDK} \
    -framework Cocoa -framework FinderSync \
    -application-extension \
    -o "${APPEX_MACOS}/FinderMenuSync" \
    TorMonitor/Extensions/main.swift \
    TorMonitor/Extensions/FinderMenuSync.swift

cp TorMonitor/Extensions/FinderMenuSync-Info.plist "${APPEX_CONTENTS}/Info.plist"

# Sign inside-out: appex first (with sandbox entitlements), then main app
codesign --force --sign - --entitlements TorMonitor/Extensions/FinderMenuSync.entitlements "${APPEX_DIR}"
codesign --force --sign - "${BUNDLE_DIR}"

echo "==> Build complete: ${BUNDLE_DIR}"
echo "==> Run with: open ${BUNDLE_DIR}"
echo "==> Binary size: $(du -h "${MACOS_DIR}/${APP_NAME}" | cut -f1)"

# --- DMG Creation ---
echo "==> Creating DMG..."
DMG_NAME="${APP_NAME}.dmg"
DMG_STAGING="build/dmg_staging"

# Clean up any old staging
rm -rf "${DMG_STAGING}"
mkdir -p "${DMG_STAGING}"

# Copy .app and create Applications symlink
cp -R "${BUNDLE_DIR}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

# Create the DMG
hdiutil create -volname "${APP_NAME}" -srcfolder "${DMG_STAGING}" -ov -format UDZO "build/${DMG_NAME}"

# Move DMG to parent directory (Documents)
mv "build/${DMG_NAME}" "../${DMG_NAME}"

# Clean up
rm -rf "${DMG_STAGING}"

echo "==> Success! DMG created at: $(cd .. && pwd)/${DMG_NAME}"

