#!/bin/ash
#
# This script installs and configures AmneziaWG from OpenWRT 24.10.2.
# It downloads and installs packages based on device architecture, using functions from lib.sh.txt.
#
# Usage: ./install_amneziawg.sh
#
# Copyright (C) 2025 IranWRT
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Source the library functions
. $(pwd)/lib.sh

# Define version and base URL for package downloads
VERSION="24.10.2"
BASE_URL="https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/v${VERSION}"

# Function to check OpenWRT version
check_amneziawg_requirements() {
    local major_version minor_version distrib_release target device_id recommended_packages
    major_version=$(echo "$DISTRIB_RELEASE" | cut -d '.' -f 1)
    minor_version=$(echo "$DISTRIB_RELEASE" | cut -d '.' -f 2-)
    distrib_release="$DISTRIB_RELEASE"
    target="$DISTRIB_TARGET"
    device_id="$DISTRIB_ID"
    recommended_packages="kmod-amneziawg amneziawg-tools luci-app-amneziawg"
    check_openwrt_version "$major_version" "$minor_version" "$distrib_release" "$target" "$device_id" "$recommended_packages"
}

# Function to install a package
install_package() {
    local pkg="$1"
    local file="${pkg}_v${VERSION}_${ARCH_SUFFIX}.ipk"
    info "Downloading ${file}..."
    wget -O /tmp/${file} "${BASE_URL}/${file}"
    check_status "Download of ${file}"
    info "Installing ${file}..."
    opkg install /tmp/${file}
    check_status "Installation of ${file}"
    rm /tmp/${file}
    success "Installed ${file}"
}

# Main script
info "Starting Amnezia WG installation on OpenWRT $DISTRIB_RELEASE"

# Check if /etc/openwrt_release exists
if [ ! -f /etc/openwrt_release ]; then
    error "/etc/openwrt_release not found. Cannot determine device architecture."
fi

# Source OpenWRT release info
. /etc/openwrt_release

# Check OpenWRT version
check_amneziawg_requirements

# Construct architecture suffix
TARGET_MOD="${DISTRIB_TARGET//\//_}"
ARCH_SUFFIX="${DISTRIB_ARCH}_${TARGET_MOD}"
info "Detected architecture suffix: ${ARCH_SUFFIX}"

# List of packages to install
PACKAGES="kmod-amneziawg amneziawg-tools luci-app-amneziawg"

# Update opkg package lists
info "Updating package lists..."
opkg update
check_status "opkg update"

# Install packages
for PKG in ${PACKAGES}; do
    if is_installed "$PKG"; then
        warning "${PKG} is already installed, skipping."
    else
        install_package "$PKG"
    fi
done

success "Amnezia AWG installation completed successfully."
