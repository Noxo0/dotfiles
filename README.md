# FedDeck

A stable, minimal Fedora system with a cohesive desktop design and safe installation approach.

## Philosophy

**力と美のために** - For the sake of power and beauty.

This system builds on two excellent projects:
- **ML4W Dotfiles Installer**: Safe profile management with automated backups
- Custom Quickshell-based shell for cohesive desktop experience

The result is a stable, production-ready Fedora system without GNOME/GDM bloat, using Hyprland as the compositor and a custom shell for a unified desktop experience.

## Features

- **Minimal Base**: Fedora without GNOME/GDM, using SDDM as lightweight display manager
- **Wayland-First**: Hyprland compositor with custom Quickshell-based shell
- **Cohesive Design**: Single motion language across all surfaces, retinted from wallpaper
- **Safe Installation**: ML4W-style sandbox approach with automated backups
- **Profile Management**: Easy updates and rollbacks with symlinking system
- **Btrfs Snapshots**: Built-in snapshot support for system stability

## System Requirements

- **OS**: Fedora (tested on Fedora 39+)
- **Architecture**: x86_64
- **RAM**: 8GB (16GB only for heavy development)
- **Storage**: 64GB SSD minimum (Btrfs recommended for snapshots)
- **GPU**: Any card with working KMS and OpenGL/Vulkan

## Installation

### Prerequisites

Start with a **fresh Fedora minimal installation** (not Fedora Workstation with GNOME).

Download Fedora Server or Minimal ISO from: https://fedoraproject.org/

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/feddeck.git
cd feddeck

# Run the installer
./installer/feddeck-installer
```

The installer will:
1. Run preflight checks
2. Enable RPM Fusion repositories
3. Install all required packages
4. Configure system services
5. Install dotfiles with safe backups
6. Set up Hyprland and custom shell

### Manual Installation

If you prefer to control each step:

```bash
# 1. Run preflight checks
bash setup/preflight.sh
bash setup/preflight-fedora.sh

# 2. Install dependencies
bash setup/dependencies/packages-fedora

# 3. Run post-installation tasks
bash setup/post.sh
bash setup/post-fedora.sh

# 4. Install dotfiles manually
cp -r desktop/* ~/.feddeck/
ln -s ~/.feddeck/hyprland ~/.config/hypr
ln -s ~/.feddeck/quickshell ~/.config/quickshell
```

## Structure

```
feddeck/
├── .dotinst                    # Profile definition (ML4W format)
├── setup/                      # Installation scripts
│   ├── preflight.sh           # General checks
│   ├── preflight-fedora.sh    # Fedora-specific checks
│   ├── dependencies/
│   │   └── packages-fedora    # Package installation
│   ├── post.sh                # General post-install
│   └── post-fedora.sh         # Fedora-specific post-install
├── system/                     # Package lists
│   ├── packages-core.txt      # Base system packages
│   ├── packages-hyprland.txt  # Hyprland dependencies
│   └── packages-shell.txt     # Quickshell and shell deps
├── desktop/                    # Desktop configuration
│   ├── hyprland/              # Hyprland config
│   ├── quickshell/            # Custom shell QML
│   ├── waybar/                # Status bar (fallback)
│   └── theming/               # Colors, fonts, assets
├── installer/                  # Installer scripts
│   └── feddeck-installer # Main installer
└── docs/                       # Documentation
```

## Keybinds

- `Super + Return`: Open terminal (kitty)
- `Super + D`: Application launcher (wofi)
- `Super + Q`: Kill active window
- `Super + E`: Logout menu (wlogout)
- `Super + R`: Reload Hyprland config
- `Super + Arrow keys`: Move focus
- `Super + Shift + Arrow keys`: Move window
- `Super + Ctrl + Arrow keys`: Resize window
- `Super + 1-5`: Switch workspaces
- `Super + Shift + 1-5`: Move to workspace
- `Super + F`: Toggle fullscreen
- `Super + Space`: Toggle floating
- `Print`: Screenshot
- `Super + Print`: Region screenshot

## Backup and Recovery

All configurations are backed up before installation:
- **Backup location**: `~/.feddeck-backup/`
- **Timestamped**: Each backup is dated (YYYYMMDD-HHMMSS)
- **Safe symlinking**: Existing configs are never deleted, only moved

To restore from backup:
```bash
# List available backups
ls ~/.feddeck-backup/

# Restore specific backup
cp -r ~/.feddeck-backup/TIMESTAMP/* ~/.config/
```

## Btrfs Snapshots

If your root filesystem is Btrfs, the system will:
- Create snapshot structure at `/@snapshots`
- Enable automatic snapshots on updates
- Allow rollback to previous states

Manual snapshot:
```bash
# Create snapshot
sudo btrfs subvolume snapshot / /@snapshots/pre-update-$(date +%Y%m%d)

# List snapshots
sudo btrfs subvolume list -s /

# Rollback (advanced, see documentation)
```

## Updates

To update the system:

```bash
# Update Fedora packages
sudo dnf upgrade

# Update dotfiles from repository
cd ~/.feddeck
git pull

# Reinstall dotfiles (will create new backup)
./installer/feddeck-installer
```

## Customization

### Modifying the Shell

Edit the Quickshell configuration:
```bash
~/.config/quickshell/config.qml
```

The shell uses QML with Qt Quick for easy customization. Key components:
- **Bar**: Main status bar with workspace indicator and launcher
- **Launcher**: Search-based app launcher
- **Popout cards**: Status widgets that expand on hover

### Modifying Hyprland

Edit the Hyprland configuration:
```bash
~/.config/hypr/hyprland.conf
```

Reload without restarting:
```
Super + Shift + R
```

### Adding Packages

Add to the appropriate package list in `system/`:
- `packages-core.txt`: Base system packages
- `packages-hyprland.txt`: Wayland/Hyprland packages
- `packages-shell.txt`: Quickshell and theme packages

Then reinstall:
```bash
bash setup/dependencies/packages-fedora
```

## Troubleshooting

### Shell not starting

Check Quickshell logs:
```bash
journalctl --user -u quickshell
```

### Hyprland issues

Check Hyprland logs:
```bash
~/.local/share/hyprland/hyprland.log
```

### Wayland applications not working

Ensure environment variables are set in `hyprland.conf`. Check with:
```bash
echo $XDG_SESSION_TYPE
```

### SDDM not showing Hyprland

Ensure SDDM is configured:
```bash
cat /etc/sddm.conf
# Should contain: Session=hyprland
```

## Contributing

This is a personal system build, but suggestions are welcome:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Credits

Built on the shoulders of giants:
- **Ryoku**: Cohesive desktop design philosophy and Quickshell shell inspiration
- **ML4W**: Safe installation approach and profile management system
- **Hyprland**: The amazing Wayland compositor
- **Quickshell**: The Qt-based shell framework
- **Fedora**: The stable base distribution

## License

GPL-3.0

## Support

For issues specific to this system, open an issue on GitHub.

For issues with components:
- Hyprland: https://github.com/hyprwm/Hyprland
- Quickshell: https://github.com/woutwoor/quickshell
- Fedora: https://discussion.fedoraproject.org/

---

**力と美のために** - Stable, minimal, beautiful.
