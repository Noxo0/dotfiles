# Fedora Minimal Installation Guide

This guide explains how to install Fedora minimal before running the FedDeck installer.

## Why Fedora Minimal?

Fedora Workstation comes with GNOME and GDM pre-installed, which adds significant bloat. For a stable, minimal system, we start with Fedora Server or Fedora Minimal ISO, which gives us a clean base.

## Download Fedora Minimal

1. Visit: https://fedoraproject.org/spins/
2. Download **Fedora Server** or **Fedora Cloud Base** ISO
3. Verify the download with checksums

## Create Bootable USB

Using Fedora Media Writer (recommended):
```bash
# Install on Fedora
sudo dnf install mediawriter

# Or use dd on Linux
sudo dd if=Fedora-Server-x86_64.iso of=/dev/sdX bs=4M status=progress
```

## Installation Steps

### 1. Boot from USB

- Boot your machine with the USB
- Select "Install Fedora Server" from the menu

### 2. Partitioning

**Recommended Layout (Btrfs with subvolumes):**

| Mount Point | Type | Size | Subvolume |
|-------------|------|------|-----------|
| /boot/efi | EFI | 512MB | - |
| /boot | ext4 | 1GB | - |
| / | btrfs | Remaining | @ (root) |
| /home | btrfs | - | @home |
| /@snapshots | btrfs | - | @snapshots |

**Manual Partitioning (Anaconda):**

1. Select "Custom" partitioning
2. Create `/boot/efi` (512MB, EFI System Partition)
3. Create `/boot` (1GB, ext4)
4. Create Btrfs volume for root
5. Create subvolumes:
   - `@` mounted at `/`
   - `@home` mounted at `/home`
   - `@snapshots` for system snapshots

### 3. Software Selection

**Minimal Installation:**
- Deselect "Infrastructure Server"
- Deselect "File and Print Server"
- Select minimal base system only

### 4. Network Configuration

- Configure your network connection
- Set hostname (optional)
- Enable network connection on boot

### 5. User Creation

- Create a regular user account
- Set a strong password
- Make the user a sudoer (Anaconda does this by default)

### 6. Begin Installation

- Review settings
- Begin installation
- Set root password during installation

### 7. Reboot

- Remove USB when prompted
- Reboot into your new Fedora minimal system

## Post-Installation: First Boot

### Update System

```bash
sudo dnf upgrade -y
```

### Install Basic Tools

```bash
sudo dnf install -y vim git curl wget tmux
```

### Verify Installation

```bash
# Check Fedora version
cat /etc/fedora-release

# Check filesystem
df -h

# Check if Btrfs is being used
findmnt -o FSTYPE /
```

### Enable RPM Fusion (Optional, will be done by installer)

The installer will enable RPM Fusion automatically, but you can do it manually:

```bash
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

## Network Setup (if needed)

If you're not using DHCP or need wireless:

```bash
# Check network devices
nmcli device

# Connect to WiFi
nmcli device wifi connect "SSID" password "password"

# Enable auto-connect
nmcli connection modify "SSID" connection.autoconnect yes
```

## Verify System Ready for FedDeck

Before running the FedDeck installer, verify:

```bash
# 1. Check you're not root
whoami
# Should show your username, not root

# 2. Check disk space (need at least 20GB free)
df -h /

# 3. Check for GNOME (should not be installed)
rpm -q gnome-shell
# Should return "package gnome-shell is not installed"

# 4. Check for existing desktop configs
ls ~/.config/
# Should be minimal (no hypr, quickshell, etc.)
```

## Next Steps

Once your minimal Fedora is ready:

```bash
# Clone the repository
git clone https://github.com/yourusername/feddeck.git
cd feddeck

# Run the installer
./installer/feddeck-installer
```

The installer will handle everything else.

## Troubleshooting

### Installation Won't Boot

- Try BIOS/UEFI settings: disable Secure Boot, enable UEFI boot
- Try different USB port (USB 2.0 vs 3.0)
- Verify ISO checksum

### No Network After Install

```bash
# Check network manager
sudo systemctl status NetworkManager

# Start it if not running
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Restart networking
sudo nmcli networking off
sudo nmcli networking on
```

### Btrfs Issues

If Btrfs subvolumes weren't created correctly, you can create them post-install:

```bash
# List current subvolumes
sudo btrfs subvolume list /

# Create snapshot subvolume
sudo btrfs subvolume create /@snapshots
```

## Alternative: Convert Existing Fedora

If you already have Fedora Workstation with GNOME and want to convert:

**Warning: This is more complex and riskier than a fresh install.**

1. Remove GNOME:
```bash
sudo dnf remove gnome-shell gnome-session gdm
```

2. Clean up dependencies:
```bash
sudo dnf autoremove
```

3. Then run the FedDeck installer (it will detect GNOME and warn you)

**Recommended: Fresh minimal install is cleaner and more stable.**
