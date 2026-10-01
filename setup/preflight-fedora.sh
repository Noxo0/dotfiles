#!/bin/bash
# Fedora-specific preflight checks
set -e

echo "==> Fedora-specific checks"

# Enable RPM Fusion (needed for some codecs/drivers)
echo "Checking RPM Fusion repositories..."
if ! rpm -q rpmfusion-free-release &>/dev/null; then
    echo "RPM Fusion not enabled. Installing..."
    sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi
echo "✓ RPM Fusion enabled"

# Check for development tools
if ! command -v git &>/dev/null; then
    echo "WARNING: git not installed. Will be installed with dependencies."
fi

echo "==> Fedora-specific checks passed"
