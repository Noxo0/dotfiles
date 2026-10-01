# FedDeck Quick Reference

Quick reference for daily usage of FedDeck.

## Daily Keybinds

### Window Management
| Keybind | Action |
|---------|--------|
| `Super + Return` | Open terminal (kitty) |
| `Super + D` | Application launcher (wofi) |
| `Super + Q` | Kill active window |
| `Super + F` | Toggle fullscreen |
| `Super + Space` | Toggle floating |
| `Super + M` | Toggle monochrome (if configured) |

### Focus Movement
| Keybind | Action |
|---------|--------|
| `Super + ←` | Focus left |
| `Super + →` | Focus right |
| `Super + ↑` | Focus up |
| `Super + ↓` | Focus down |

### Window Movement
| Keybind | Action |
|---------|--------|
| `Super + Shift + ←` | Move window left |
| `Super + Shift + →` | Move window right |
| `Super + Shift + ↑` | Move window up |
| `Super + Shift + ↓` | Move window down |

### Window Resizing
| Keybind | Action |
|---------|--------|
| `Super + Ctrl + ←` | Resize narrower |
| `Super + Ctrl + →` | Resize wider |
| `Super + Ctrl + ↑` | Resize taller |
| `Super + Ctrl + ↓` | Resize shorter |

### Workspaces
| Keybind | Action |
|---------|--------|
| `Super + 1-5` | Switch to workspace 1-5 |
| `Super + Shift + 1-5` | Move window to workspace 1-5 |

### System
| Keybind | Action |
|---------|--------|
| `Super + E` | Logout menu (wlogout) |
| `Super + Shift + R` | Reload Hyprland config |
| `Print` | Screenshot |
| `Super + Print` | Region screenshot |

### Media & Hardware
| Keybind | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

## Common Commands

### System Updates
```bash
# Update Fedora packages
sudo dnf upgrade

# Update dotfiles
cd ~/.feddeck
git pull
./installer/feddeck-installer
```

### Package Management
```bash
# Search for package
sudo dnf search PACKAGE_NAME

# Install package
sudo dnf install PACKAGE_NAME

# Remove package
sudo dnf remove PACKAGE_NAME

# Remove package and dependencies
sudo dnf autoremove
```

### Btrfs Snapshots
```bash
# Create snapshot
sudo btrfs subvolume snapshot / /@snapshots/snapshot-name

# List snapshots
sudo btrfs subvolume list -s /

# Delete snapshot
sudo btrfs subvolume delete /@snapshots/snapshot-name
```

### Logs
```bash
# System journal
journalctl -xe

# User journal
journalctl --user -xe

# Hyprland log
cat ~/.local/share/hyprland/hyprland.log

# Quickshell log
journalctl --user -u quickshell
```

### Config Locations
```bash
# Hyprland config
~/.config/hypr/hyprland.conf

# Quickshell config
~/.config/quickshell/config.qml

# Theme config
~/.config/theme/

# Dotfiles source
~/.feddeck/
```

## Shell Components

### Bar
- **Location**: Top or bottom edge of screen
- **Features**: Workspace indicator, launcher trigger, clock, date, system tray
- **Interaction**: Hover for popout cards

### Launcher
- **Trigger**: Click launcher icon or `Super + D`
- **Features**: Search apps, commands, files
- **Exit**: Click outside or Esc

### Control Sidebar
- **Trigger**: Click status widget on bar
- **Features**: Session controls, connect tiles, sound, brightness, media, calendar
- **Exit**: Click outside or Esc

## Troubleshooting Quick Fixes

### Shell Not Responding
```bash
# Restart Quickshell
killall quickshell
quickshell &
```

### Hyprland Issues
```bash
# Reload config
Super + Shift + R

# Or restart Hyprland
killall Hyprland
# SDDM will restart it
```

### Audio Not Working
```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Check with pavucontrol
pavucontrol
```

### WiFi Not Connecting
```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Or use nmcli
nmcli networking off
nmcli networking on
```

### Bluetooth Not Working
```bash
# Restart Bluetooth
sudo systemctl restart bluetooth

# Use blueman manager
blueman-manager
```

## Customization

### Change Wallpaper
```bash
# With swww
swww img /path/to/wallpaper.jpg

# Set random wallpaper
swww img $(find ~/Pictures -type f -name "*.jpg" | shuf -n 1)
```

### Change Theme Colors
Edit `~/.config/theme/colors.conf` then reload:
```bash
killall quickshell
quickshell &
```

### Add Custom Keybind
Edit `~/.config/hypr/hyprland.conf`:
```
bind=$mod,KEY,exec,COMMAND
```
Then reload: `Super + Shift + R`

### Modify Shell Layout
Edit `~/.config/quickshell/config.qml` - it's QML so you can:
- Change bar position
- Add/remove widgets
- Modify animations
- Change colors

## Performance Tips

### Reduce Resource Usage
```bash
# Disable blur in Hyprland
# Edit hyprland.conf:
decoration {
    blur {
        enabled=false
    }
}

# Reduce animations
animations {
    enabled=false
}
```

### Monitor Resource Usage
```bash
# System monitor
btop

# Check RAM usage
free -h

# Check disk usage
df -h

# Check CPU usage
htop
```

### Clean Up
```bash
# Clean package cache
sudo dnf clean all

# Remove old kernels (keep 2 latest)
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q)

# Clean journal logs
sudo journalctl --vacuum-time=7d
```

## Security

### Update System Regularly
```bash
# Weekly updates recommended
sudo dnf upgrade
```

### Check for Security Updates
```bash
sudo dnf updateinfo list sec
```

### Firewall
```bash
# Check firewall status
sudo firewall-cmd --state

# List active zones
sudo firewall-cmd --get-active-zones
```

### Encrypted Backup
```bash
# Encrypt backup
gpg --symmetric --cipher-algo AES256 backup.tar.gz

# Decrypt
gpg --decrypt backup.tar.gz.gpg > backup.tar.gz
```

## Useful Applications

Pre-installed with FedDeck:
- **kitty**: Terminal emulator
- **thunar**: File manager
- **pavucontrol**: Audio control
- **blueman**: Bluetooth manager
- **wofi**: Application launcher
- **grim/slurp**: Screenshots
- **btop**: System monitor

Recommended additions:
```bash
# Web browser
sudo dnf install firefox

# Email client
sudo dnf install thunderbird

# Office suite
sudo dnf install libreoffice

# Image editor
sudo dnf install gimp

# Video player
sudo dnf install vlc
```

## Emergency Recovery

If system is unresponsive:
```bash
# Switch to TTY (Ctrl+Alt+F3)
# Login
# Restart Hyprland
killall Hyprland

# Or reboot
sudo reboot
```

If GUI won't start:
```bash
# Check XDG variables
echo $XDG_SESSION_TYPE
echo $XDG_SESSION_DESKTOP

# Should be:
# XDG_SESSION_TYPE=wayland
# XDG_SESSION_DESKTOP=Hyprland
```

See RECOVERY.md for detailed recovery procedures.
