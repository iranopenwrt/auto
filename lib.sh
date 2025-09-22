#!/bin/ash
#
# This script installs and configures Passwall2 on OpenWRT 24.10.2.
# It follows the provided tutorial steps automatically, verifying each step.
# Optional features can be enabled via command-line arguments or user prompts.
# Skips repository key and addition if repositories exist and initial update succeeds.
#
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

# Color codes for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print info
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to print success
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to print error and exit
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Function to check command success
check_status() {
    if [ $? -ne 0 ]; then
        error "$1 failed."
    fi
}

# Function to check if package is installed
is_installed() {
    opkg list-installed | grep -q "^$1 -"
}

# Function to prompt user yes/no
prompt_yes_no() {
    while true; do
        echo -e "${YELLOW}[QUESTION]${NC} $1 (y/n): "
        read yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Function to check OpenWrt version and provide upgrade instructions
check_openwrt_version() {
    local major_version="$1"
    local minor_version="$2"
    local distrib_release="$3"
    local target="$4"
    local device_id="$5"
    local recommended_packages="$6"

    if [ "$major_version" -lt 23 ] 2>/dev/null; then
        warning "You are using an outdated OpenWrt version ($distrib_release)."
        info "Please perform a clean update to the latest stable version using the OpenWrt Firmware Selector:"
        info "https://firmware-selector.openwrt.org/?version=24.10.2&target=$target&id=$device_id"
        info "Recommended: Add the following packages to the 'Installed Packages' dialog on the Firmware Selector page:"
        info "$recommended_packages"
        info "If needed, you can apply Script to run on first boot (uci-defaults), for example:"
        info "uci set network.lan.ipaddr='192.168.3.1'"
        info "uci commit network"
        info "Download the appropriate factory image and follow the installation instructions for your device."
        error "Please upgrade before running this script."
    elif [ "$major_version" -eq 23 ] && [ "$minor_version" != "05.6" ]; then
        warning "You are using an outdated 23.05.x version ($distrib_release)."
        info "Please update to the latest 23.05.6 for your device from the link below:"
        info "https://firmware-selector.openwrt.org/?version=23.05.6&target=$target&id=$device_id"
        info "Recommended: Add the following packages to the 'Installed Packages' dialog on the Firmware Selector page:"
        info "$recommended_packages"
        info "If needed, you can apply Script to run on first boot (uci-defaults), for example:"
        info "uci set network.lan.ipaddr='192.168.3.1'"
        info "uci commit network"
        info "Download the sysupgrade image and update using 'sysupgrade' command."
        error "Please upgrade before running this script."
    elif [ "$major_version" -eq 24 ] && [ "$minor_version" != "10.3" ]; then
        warning "You are using an outdated 24.10.x version ($distrib_release)."
        info "Please update to the latest 24.10.3 for your device from the link below:"
        info "https://firmware-selector.openwrt.org/?version=24.10.3&target=$target&id=$device_id"
        info "Recommended: Add the following packages to the 'Installed Packages' dialog on the Firmware Selector page:"
        info "$recommended_packages"
        info "If needed, you can apply Script to run on first boot (uci-defaults), for example:"
        info "uci set network.lan.ipaddr='192.168.3.1'"
        info "uci commit network"
        info "Download the sysupgrade image, update using 'sysupgrade', and rerun this script after upgrading."
        error "Please upgrade before running this script."
    fi
}

