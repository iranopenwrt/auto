#!/bin/sh

set -e

echo "[*] Loading OpenWrt release information..."

if [ ! -f /etc/openwrt_release ]; then
    echo "[!] /etc/openwrt_release not found"
    exit 1
fi

. /etc/openwrt_release

# Extract fields
VERSION="${DISTRIB_RELEASE}"
ARCH="${DISTRIB_ARCH}"
TARGET="$(echo "$DISTRIB_TARGET" | cut -d/ -f1)"
SUBTARGET="$(echo "$DISTRIB_TARGET" | cut -d/ -f2)"

if [ -z "$VERSION" ] || [ -z "$ARCH" ] || [ -z "$TARGET" ] || [ -z "$SUBTARGET" ]; then
    echo "[!] Failed to parse OpenWrt system information"
    exit 1
fi

PKG_NAME="psiphon_v${VERSION}_${ARCH}_${TARGET}_${SUBTARGET}.ipk"
DOWNLOAD_URL="https://github.com/izhdaha/psiphon/releases/download/v${VERSION}/${PKG_NAME}"

echo "[*] OpenWrt version : $VERSION"
echo "[*] Architecture    : $ARCH"
echo "[*] Target          : $TARGET"
echo "[*] Subtarget       : $SUBTARGET"
echo "[*] Package         : $PKG_NAME"
echo "[*] Download URL    : $DOWNLOAD_URL"

cd /tmp/

echo "[*] Downloading Psiphon package..."
if ! wget -O "$PKG_NAME" "$DOWNLOAD_URL"; then
    echo "[!] Download failed"
    exit 1
fi

echo "[*] Installing package..."
if ! opkg install "/tmp/$PKG_NAME"; then
    echo "[!] Installation failed"
    exit 1
fi

echo "[✓] Psiphon installed successfully"
