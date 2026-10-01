# Recovery and Rollback Procedures

This document covers recovery scenarios for FedDeck.

## Backup Locations

### Dotfiles Backups

**Location:** `~/.feddeck-backup/`

Each installation creates a timestamped backup:
```
~/.feddeck-backup/
├── 20261001-143022/
│   ├── .config/
│   │   ├── hypr/
│   │   ├── quickshell/
│   │   └── theme/
│   └── other-files/
└── 20261001-150045/
    └── ...
```

### Btrfs Snapshots

**Location:** `/@snapshots/`

If using Btrfs, system snapshots are stored here:
```
/@snapshots/
├── pre-update-20261001/
├── post-update-20261001/
└── ...
```

## Recovery Scenarios

### Scenario 1: Shell Not Starting

**Symptoms:** Hyprland starts but the custom Quickshell doesn't appear.

**Recovery:**

1. Check Quickshell logs:
```bash
journalctl --user -u quickshell -n 50
```

2. Try starting Quickshell manually:
```bash
quickshell
```

3. If it fails, check the config:
```bash
# Validate QML syntax
qmlscene ~/.config/quickshell/config.qml
```

4. Restore from backup if config is corrupted:
```bash
# Find latest backup
ls ~/.feddeck-backup/

# Restore Quickshell config
cp -r ~/.feddeck-backup/TIMESTAMP/.config/quickshell ~/.config/
```

5. Restart Hyprland:
```
Super + Shift + R
```

### Scenario 2: Hyprland Won't Start

**Symptoms:** SDDM login fails or Hyprland crashes immediately.

**Recovery:**

1. Check Hyprland logs:
```bash
cat ~/.local/share/hyprland/hyprland.log
```

2. Try starting Hyprland manually from TTY:
```bash
# Switch to TTY (Ctrl+Alt+F3)
# Login
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
Hyprland
```

3. If config is the issue, restore from backup:
```bash
cp -r ~/.feddeck-backup/TIMESTAMP/.config/hypr ~/.config/
```

4. If that fails, use a basic Hyprland config:
```bash
# Create minimal config
cat > ~/.config/hypr/hyprland.conf << 'EOF'
source = /usr/share/hyprland/hyprland.conf
EOF
```

5. Reinstall Hyprland if needed:
```bash
sudo dnf reinstall hyprland
```

### Scenario 3: System Won't Boot

**Symptoms:** System fails to boot after update.

**Recovery (with Btrfs):**

1. Boot from Fedora installation USB
2. Mount root filesystem:
```bash
mount /dev/sdXY /mnt
```

3. List snapshots:
```bash
sudo btrfs subvolume list -s /mnt
```

4. Rollback to previous snapshot:
```bash
# Unmount current root
umount /mnt

# Mount snapshot as root
mount -o subvolid=SUBVOLID /dev/sdXY /mnt

# Or use subvolume name
mount -o subvol=@snapshots/pre-update-20261001 /dev/sdXY /mnt
```

5. Chroot and update:
```bash
sudo chroot /mnt
sudo dnf upgrade
exit
```

6. Reboot

**Recovery (without Btrfs):**

1. Boot from Fedora installation USB
2. Use "Rescue a system" option
3. Chroot into your system
4. Reinstall packages:
```bash
sudo dnf reinstall kernel hyprland
```

### Scenario 4: Package Installation Failed

**Symptoms:** Installer failed during package installation.

**Recovery:**

1. Check what failed:
```bash
sudo dnf history
```

2. Undo the transaction:
```bash
sudo dnf history undo ID
```

3. Fix broken dependencies:
```bash
sudo dnf check
sudo dnf repair
```

4. Retry installation:
```bash
./installer/feddeck-installer
```

### Scenario 5: Symlinks Broken

**Symptoms:** Config files not loading, apps using defaults.

**Recovery:**

1. Check symlinks:
```bash
ls -la ~/.config/hypr
ls -la ~/.config/quickshell
```

2. If symlinks are broken (red), recreate them:
```bash
# Remove broken symlinks
rm ~/.config/hypr
rm ~/.config/quickshell

# Reinstall dotfiles
./installer/feddeck-installer
```

3. Or manually recreate:
```bash
ln -s ~/.feddeck/hyprland ~/.config/hypr
ln -s ~/.feddeck/quickshell ~/.config/quickshell
```

### Scenario 6: Update Broke Something

**Symptoms:** System worked before update, now broken.

**Recovery (with Btrfs):**

1. List snapshots:
```bash
sudo btrfs subvolume list -s /
```

2. Identify pre-update snapshot
3. Rollback (see Scenario 3)

**Recovery (without Btrfs):**

1. Rollback packages:
```bash
sudo dnf history
sudo dnf history undo ID
```

2. Restore dotfiles from backup:
```bash
cp -r ~/.feddeck-backup/PRE-UPDATE-TIMESTAMP/.config/* ~/.config/
```

3. Reboot

## Emergency Fallback

If everything is broken and you can't recover:

### Use a Different WM Temporarily

1. Install a simple fallback:
```bash
sudo dnf install sway
```

2. Create a basic Sway config:
```bash
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config
```

3. Select Sway from SDDM login

### Reinstall from Scratch

1. Backup important data:
```bash
# Home directory
tar -czf ~/backup-home.tar.gz ~/

# List installed packages for reference
rpm -qa > ~/installed-packages.txt
```

2. Reinstall Fedora minimal (see FEDORA_MINIMAL_INSTALL.md)
3. Run FedDeck installer
4. Restore data from backup

## Preventive Measures

### Regular Backups

Set up automatic backups:

```bash
# Add to crontab
crontab -e

# Weekly backup of dotfiles
0 0 * * 0 tar -czf ~/dotfiles-backup-$(date +\%Y\%m\%d).tar.gz ~/.config/hypr ~/.config/quickshell ~/.config/theme
```

### Automatic Btrfs Snapshots

Configure snapper or timeshift for automatic snapshots:

```bash
# Install snapper
sudo dnf install snapper snapper-plugins

# Create config
sudo snapper -c root create-config /

# Enable timeline
sudo snapper -c root set-config "TIMELINE_CREATE=yes"
sudo snapper -c root set-config "TIMELINE_CLEANUP=yes"
```

### Test Updates Before Applying

Always test in a VM or snapshot first:

```bash
# Create snapshot before update
sudo btrfs subvolume snapshot / /@snapshots/pre-update-$(date +%Y%m%d)

# Update
sudo dnf upgrade

# Test system for a day
# If issues, rollback to snapshot
```

## Getting Help

If you can't recover:

1. Check logs:
```bash
journalctl -xe
journalctl --user -xe
~/.local/share/hyprland/hyprland.log
```

2. Search for similar issues:
- Hyprland: https://github.com/hyprwm/Hyprland/issues
- Quickshell: https://github.com/woutwoor/quickshell/issues
- Fedora: https://discussion.fedoraproject.org/

3. Open an issue on this repository with:
- Fedora version
- Hardware specs
- Exact error messages
- Steps to reproduce
- What you've tried already
