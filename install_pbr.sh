#!/bin/ash
#
# This script installs and configures pbr on OpenWrt 24.10.
# It follows similar steps to other installation scripts, verifying each step.
# Optional features can be enabled via command-line arguments.
#
# Usage: ./install_pbr.sh [--ir]
#   --ir: Automatically add Iranian policies without prompt
#
# Copyright (C) IranWRT
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

# Source lib.sh for common functions
. $(pwd)/lib.sh

# Parse command-line arguments
ir=false

if [ $# -eq 0 ]; then
    if prompt_yes_no "Do you want to add iran .ir tld and geoip to the wan exception list?"; then
        ir=true
    fi
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --ir) ir=true ;;
        *) warning "Unknown argument: $1" ;;
    esac
    shift
done

# Gather system information
. /etc/openwrt_release
distrib_release="$DISTRIB_RELEASE"
major_version=$(echo "$distrib_release" | cut -d. -f1)
minor_version=$(echo "$distrib_release" | cut -d. -f2-)
target="$DISTRIB_TARGET"
. /lib/functions/system.sh
device_id=$(board_name)
recommended_packages="luci-app-pbr"

# Error if not 24.10.x
if [ "$major_version" -ne 24 ] || ! echo "$minor_version" | grep -q "^10\."; then
    error "This script requires OpenWrt 24.10.x. Your version is $distrib_release."
fi

# Check OpenWrt version using the function
info "Checking OpenWrt version..."
check_openwrt_version "$major_version" "$minor_version" "$distrib_release" "$target" "$device_id" "$recommended_packages"
success "OpenWrt version check passed."

# Check for conflicts
if is_installed luci-app-passwall2; then
    warning "Conflict detected: luci-app-passwall2 is installed. pbr may conflict with it."
fi

# Install pbr if luci-app-pbr is not installed
if ! is_installed luci-app-pbr; then
    info "Updating package list..."
    opkg update
    check_status "opkg update"

    info "Installing pbr..."
    opkg install luci-app-pbr
    check_status "pbr installation"
    success "pbr installed successfully."
else
    success "luci-app-pbr is already installed; skipping pbr installation."
fi

# Add Iranian configurations if --ir is specified and they do not exist
if [ "$ir" = "true" ]; then
    info "Adding Iranian policies if not present..."

    if ! uci show pbr | grep -q "\.name='irip'"; then
        uci add pbr policy
        uci set pbr.@policy[-1].name='irip'
        uci set pbr.@policy[-1].dest_addr='https://raw.githubusercontent.com/iranopenwrt/auto/refs/heads/main/resources/pbr-iplist-iran-v4'
        uci set pbr.@policy[-1].interface='wan'
    else
        info "Policy 'irip' already exists; skipping addition."
    fi

    if ! uci show pbr | grep -q "\.name='irdomains'"; then
        uci add pbr policy
        uci set pbr.@policy[-1].name='irdomains'
        uci set pbr.@policy[-1].dest_addr='ir'
        uci set pbr.@policy[-1].interface='wan'
    else
        info "Policy 'irdomains' already exists; skipping addition."
    fi

    uci commit pbr
    check_status "Committing pbr configurations"
    success "Iranian policies added successfully."
fi

# Warn if pbr is not enabled or running
if ! /etc/init.d/pbr enabled; then
    warning "pbr is not enabled. Recommend running: service pbr enable"
fi
if ! /etc/init.d/pbr running; then
    warning "pbr is not running. Recommend running: service pbr start"
fi

success "pbr installation and configuration completed."
