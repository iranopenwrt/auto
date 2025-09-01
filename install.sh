#!/bin/ash
#
# Parent script to perform pre-installation checks and execute OpenWrt tool installation scripts.
# Performs network, DNS, and GitHub connectivity tests before downloading and running user-selected scripts.
# Outputs of test commands are printed to the screen.
#
# Usage: ./main.sh [--passwall2] [--amneziawg]
#   --passwall2: Install Passwall2 without prompt
#   --amneziawg: Install AmneziaWG without prompt
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
info() (
    echo -e "${BLUE}[INFO]${NC} $1"
)

# Function to print success
success() (
    echo -e "${GREEN}[SUCCESS]${NC} $1"
)

# Function to print warning
warning() (
    echo -e "${YELLOW}[WARNING]${NC} $1"
)

# Function to print error and exit
error() (
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
)

# Function to check command success
check_status() (
    if [ $? -ne 0 ]; then
        error "$1 failed."
    fi
)

# Function to prompt user yes/no
prompt_yes_no() (
    while true; do
        echo -e "${YELLOW}[QUESTION]${NC} $1 (y/n): "
        read yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
)

# Function to check GitHub connectivity by downloading lib.sh
githubtest() (
    local lib_url="https://raw.githubusercontent.com/iranopenwrt/auto/refs/heads/main/lib.sh"
    local lib_file="/tmp/lib.sh"

    info "Checking GitHub connectivity by downloading lib.sh from $lib_url..."
    wget -q -O "$lib_file" "$lib_url" 2>&1 | tee /dev/tty
    check_status "GitHub connectivity test (downloading lib.sh)"
    success "GitHub connectivity test passed."
)

# Function to check internet connectivity
check_internet() (
    info "Checking internet connectivity by pinging 8.8.8.8..."
    ping -c 4 8.8.8.8 | tee /dev/tty
    if [ $? -eq 0 ]; then
        success "Internet connectivity test passed."
    else
        error "No internet connectivity. Please check your network connection."
    fi
)

# Function to check DNS resolution
check_dns() (
    info "Checking DNS resolution for downloads.openwrt.org..."
    nslookup downloads.openwrt.org | tee /dev/tty
    if [ $? -eq 0 ]; then
        success "DNS resolution for downloads.openwrt.org passed."
    else
        error "DNS resolution for downloads.openwrt.org failed. Please check your DNS settings."
    fi

    info "Checking DNS resolution for master.dl.sourceforge.net..."
    nslookup master.dl.sourceforge.net | tee /dev/tty
    if [ $? -eq 0 ]; then
        success "DNS resolution for master.dl.sourceforge.net passed."
    else
        error "DNS resolution for master.dl.sourceforge.net failed. Please check your DNS settings."
    fi
)

# Function to check package download
check_package_download() (
    local lib_file="/tmp/lib.sh"
    [ -f "$lib_file" ] || error "lib.sh not found in /tmp/. Please run githubtest first."

    # Source lib.sh if it contains necessary functions (e.g., check_openwrt_version)
    if [ -s "$lib_file" ]; then
        . "$lib_file"
        info "Sourced lib.sh for additional functions."
    else
        warning "lib.sh is empty or invalid. Proceeding without sourcing."
    fi

    local release arch
    read release arch << EOF
    $(. /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF
    local url="https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/passwall2/Packages.gz"
    info "Checking ability to download package from $url..."
    wget -q --spider "$url" 2>&1 | tee /dev/tty
    if [ $? -eq 0 ]; then
        success "Package download test passed."
    else
        error "Failed to access package at $url. Please check your internet or SourceForge access."
    fi
)

# Function to download and execute a script
execute_script() (
    local script_name="$1"
    local url="$2"
    local temp_script="/tmp/$script_name"

    info "Downloading $script_name from $url..."
    wget -O "$temp_script" "$url"
    check_status "Downloading $script_name"

    info "Making $script_name executable..."
    chmod +x "$temp_script"
    check_status "Making $script_name executable"

    info "Executing $script_name..."
    sh "$temp_script"
    check_status "Executing $script_name"

    info "Cleaning up $script_name..."
    rm -f "$temp_script"
    success "$script_name executed successfully."
)

# Parse command-line arguments
install_passwall2=false
install_amneziawg=false

while [ $# -gt 0 ]; do
    case "$1" in
        --passwall2) install_passwall2=true ;;
        --amneziawg) install_amneziawg=true ;;
        *) warning "Unknown argument: $1" ;;
    esac
    shift
done

# Perform pre-installation checks
info "Starting pre-installation checks..."
githubtest
check_internet
check_dns
check_package_download
success "All pre-installation checks passed."

# Prompt for installations if not specified via arguments
if [ "$install_passwall2" != "true" ]; then
    if prompt_yes_no "Would you like to install Passwall2?"; then
        install_passwall2=true
    fi
fi

if [ "$install_amneziawg" != "true" ]; then
    if prompt_yes_no "Would you like to install AmneziaWG?"; then
        install_amneziawg=true
    fi
fi

# Execute selected installations
if [ "$install_passwall2" = "true" ]; then
    execute_script "install_passwall2.sh" "https://raw.githubusercontent.com/iranopenwrt/auto/refs/heads/main/install_passwall2.sh"
fi

if [ "$install_amneziawg" = "true" ]; then
    execute_script "install_amneziawg.sh" "https://raw.githubusercontent.com/iranopenwrt/auto/refs/heads/main/install_amneziawg.sh"
fi

success "All requested installations completed."
