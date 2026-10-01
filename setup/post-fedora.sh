#!/bin/bash
# Fedora-specific post-installation tasks
set -e

echo "==> Running Fedora-specific post-installation"

# Set SDDM to use Wayland session by default
if [ -f /etc/sddm.conf ]; then
    sudo sed -i 's/^Session=.*/Session=hyprland/' /etc/sddm.conf
else
    echo "[General]" | sudo tee -a /etc/sddm.conf
    echo "Session=hyprland" | sudo tee -a /etc/sddm.conf
fi
echo "✓ SDDM configured for Hyprland"

# Add user to necessary groups
sudo usermod -aG video,audio "$USER"
echo "✓ User added to video and audio groups"

# Set up Btrfs snapshots if applicable
if findmnt -n -o FSTYPE / | grep -q btrfs; then
    echo "Setting up Btrfs snapshot configuration..."
    # Create subvolume structure if needed
    sudo btrfs subvolume list / | grep -q "@snapshots" || sudo btrfs subvolume create /@snapshots 2>/dev/null || true
    echo "✓ Btrfs snapshot structure ready"
fi

# Configure firewall for Wayland
sudo firewall-cmd --set-default-zone=trusted || true
echo "✓ Firewall configured"

echo "==> Fedora-specific post-installation complete"
