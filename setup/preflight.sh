#!/bin/bash
# Preflight checks for FedDeck installation
set -e

echo "==> FedDeck Preflight Checks"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run as root. This script should be run as a regular user."
    exit 1
fi

# Check if on Fedora
if [ ! -f /etc/fedora-release ]; then
    echo "ERROR: This system is not Fedora. This installer is Fedora-specific."
    exit 1
fi

# Check Fedora version
FEDORA_VERSION=$(rpm -E %fedora)
echo "Detected Fedora $FEDORA_VERSION"

# Check for existing desktop environments
if rpm -q gnome-shell &>/dev/null; then
    echo "WARNING: GNOME is installed. This may conflict with the minimal setup."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for Btrfs (recommended for snapshots)
if findmnt -n -o FSTYPE / | grep -q btrfs; then
    echo "✓ Root filesystem is Btrfs (snapshots supported)"
else
    echo "WARNING: Root is not Btrfs. Snapshot support will be limited."
fi

# Check for sufficient disk space
AVAILABLE_SPACE=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 20 ]; then
    echo "ERROR: Less than 20GB available space. Need at least 20GB."
    exit 1
fi
echo "✓ Sufficient disk space available"

# Check for Wayland support
if lspci | grep -i vga &>/dev/null; then
    echo "✓ Graphics hardware detected"
else
    echo "WARNING: No graphics hardware detected"
fi

echo "==> Preflight checks passed"
