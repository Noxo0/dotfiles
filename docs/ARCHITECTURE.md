# FedDeck Architecture

This document explains the architecture and design decisions behind FedDeck.

## Design Philosophy

FedDeck combines two powerful approaches:

1. **Ryoku's Cohesive Desktop**: A unified, beautiful Wayland desktop with custom shell
2. **ML4W's Safe Installation**: Profile-based management with automated backups

The result is a stable, minimal, production-ready system for professional use.

## Core Principles

### 1. Minimal Base
- No GNOME, no GDM, no unnecessary bloat
- Lightweight display manager (SDDM)
- Only required packages installed
- Easy to maintain and update

### 2. Wayland-First
- Hyprland compositor (modern, performant)
- No X11 dependencies where possible
- Native Wayland applications preferred
- Proper environment variables for compatibility

### 3. Cohesive Design
- Single motion language across all surfaces
- Unified color scheme retinted from wallpaper
- Consistent animations and transitions
- One continuous desktop experience

### 4. Safety First
- All changes backed up before application
- Safe sandbox for dotfiles installation
- Btrfs snapshots for system recovery
- Rollback capability at every level

### 5. Reproducible
- Single repository contains entire system definition
- Automated installer for consistent deployments
- Version-controlled configurations
- Easy to replicate across machines

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         Custom Quickshell Shell        │
│  (Bar, Launcher, Widgets, Popouts)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Hyprland Compositor           │
│  (Window management, Input, Output)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Wayland Display Server        │
│  (Graphics, Input, Output handling)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Fedora Minimal Base            │
│  (Kernel, Systemd, Package Manager)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Btrfs Filesystem              │
│  (Snapshots, Subvolumes, Backups)       │
└─────────────────────────────────────────┘
```

## Component Breakdown

### 1. System Layer (Fedora Minimal)

**Purpose**: Clean, stable base for the desktop

**Components**:
- Fedora Server/Minimal ISO
- systemd init system
- dnf package manager
- Btrfs filesystem (recommended)
- SDDM display manager

**Rationale**: Fedora provides stable packages and good hardware support. Minimal ISO avoids GNOME bloat.

### 2. Display Layer (Wayland)

**Purpose**: Modern graphics and input handling

**Components**:
- Wayland display server
- Mesa drivers (AMD/Intel/NVIDIA)
- PipeWire for audio
- Input handling via libinput

**Rationale**: Wayland is more secure and performant than X11. Native support avoids compatibility issues.

### 3. Compositor Layer (Hyprland)

**Purpose**: Window management and compositing

**Components**:
- Hyprland dynamic tiling compositor
- Configuration in `~/.config/hypr/hyprland.conf`
- Keybinds, rules, animations, decorations

**Rationale**: Hyprland is actively developed, feature-rich, and highly configurable. Better than i3/Sway for custom shell integration.

### 4. Shell Layer (Quickshell)

**Purpose**: Unified desktop shell and UI

**Components**:
- Quickshell (Qt/QML-based shell framework)
- Custom QML configuration
- Bar, launcher, widgets, popouts
- Live blur and animations

**Rationale**: Quickshell allows building a cohesive shell like Ryoku's. QML is declarative and easy to customize.

### 5. Installation Layer (ML4W-style)

**Purpose**: Safe, reproducible installation

**Components**:
- Profile definition (`.dotinst`)
- Setup scripts (preflight, dependencies, post)
- Safe symlinking with backups
- Btrfs snapshot integration

**Rationale**: ML4W's approach is proven and safe. Avoids destroying existing configs.

## Data Flow

### Installation Flow

```
User runs installer
    ↓
Preflight checks (system, hardware, space)
    ↓
Fedora-specific checks (RPM Fusion, etc.)
    ↓
Install packages (core, Hyprland, shell)
    ↓
Backup existing configs
    ↓
Copy dotfiles to sandbox (~/.feddeck)
    ↓
Create symlinks to HOME
    ↓
Post-install tasks (services, groups, snapshots)
    ↓
Reboot and enjoy
```

### Boot Flow

```
System boots (systemd)
    ↓
SDDM starts (display manager)
    ↓
User logs in (selects Hyprland session)
    ↓
Hyprland starts (compositor)
    ↓
Quickshell starts (custom shell)
    ↓
Desktop is ready
```

### Update Flow

```
User runs installer again
    ↓
Create new backup (timestamped)
    ↓
Pull latest dotfiles from repo
    ↓
Reinstall packages (if needed)
    ↓
Update symlinks
    ↓
User tests new configuration
    ↓
If issues: restore from backup
    ↓
If good: delete old backup
```

## Filesystem Layout

### System Directories

```
/                      # Root
├── @                  # Root subvolume (Btrfs)
├── @home              # Home subvolume
├── @snapshots         # System snapshots
└── boot               # Boot partition
```

### User Directories

```
~/
├── .feddeck/             # Dotfiles sandbox
│   ├── hyprland/              # Hyprland config
│   ├── quickshell/            # Shell QML
│   └── theming/               # Theme assets
├── .config/                   # Active configs (symlinks)
│   ├── hypr -> ~/.feddeck/hyprland
│   ├── quickshell -> ~/.feddeck/quickshell
│   └── theme -> ~/.feddeck/theming
└── .feddeck-backup/      # Backups
    └── 20261001-143022/       # Timestamped backups
```

### Repository Structure

```
feddeck/
├── .dotinst                    # Profile definition
├── setup/                      # Installation scripts
│   ├── preflight.sh
│   ├── preflight-fedora.sh
│   ├── dependencies/
│   │   └── packages-fedora
│   ├── post.sh
│   └── post-fedora.sh
├── system/                     # Package lists
│   ├── packages-core.txt
│   ├── packages-hyprland.txt
│   └── packages-shell.txt
├── desktop/                    # Desktop configuration
│   ├── hyprland/
│   ├── quickshell/
│   ├── waybar/
│   └── theming/
├── installer/                  # Installer scripts
│   └── feddeck-installer
└── docs/                       # Documentation
```

## Safety Mechanisms

### 1. Backup System

**Before Installation**:
- Existing configs backed up to `~/.feddeck-backup/TIMESTAMP/`
- Never overwrites without backup
- Timestamped for easy rollback

**During Installation**:
- Dotfiles copied to sandbox first
- Symlinks created from sandbox to HOME
- Original files preserved

**After Installation**:
- Easy to restore: `cp -r backup/TIMESTAMP/* ~/.config/`
- Multiple backups retained

### 2. Btrfs Snapshots

**Pre-Update**:
- Automatic snapshot before package updates
- Manual snapshot before major changes

**Post-Update**:
- If issues: rollback to snapshot
- If good: keep snapshot for safety

**Snapshot Types**:
- Pre-update snapshots
- Pre-config-change snapshots
- Manual user snapshots

### 3. Preflight Checks

**System Checks**:
- Not running as root
- Fedora detected
- Sufficient disk space
- Graphics hardware present

**Configuration Checks**:
- GNOME detection (warning)
- Btrfs detection (recommendation)
- Existing conflicts

### 4. Symlink Safety

**Smart Symlinking**:
- Detects existing symlinks
- Checks if symlink points to correct target
- Only replaces if different
- Backs up before replacement

**Broken Link Detection**:
- Validates symlinks before use
- Easy to recreate if broken
- Installer can fix automatically

## Performance Considerations

### Resource Usage

**Hyprland**:
- RAM: ~200-300MB
- CPU: Minimal when idle
- GPU: Minimal (compositing only)

**Quickshell**:
- RAM: ~100-150MB
- CPU: Minimal (Qt event loop)
- GPU: Moderate (blur, animations)

**Total Desktop**:
- RAM: ~500-800MB at rest (8GB RAM is sufficient)
- CPU: ~1-2% at rest
- GPU: Depends on animations

### Optimization Strategies

**Blur**:
- Can be disabled for older GPUs
- Adjustable passes and size
- Smart blur regions

**Animations**:
- Can be disabled globally
- Customizable curves
- Per-animation control

**Compositing**:
- Hardware acceleration by default
- Software rendering fallback
- Tunable refresh rate

## Security Considerations

### Wayland Security

**Benefits**:
- No X11 security issues
- Input isolation
- Screen capture protection
- No keylogger access

**Trade-offs**:
- Some X11 apps need XWayland
- Screen sharing requires portals
- Global hotkeys limited

### System Security

**Hardening**:
- Minimal attack surface (few packages)
- No unnecessary services
- Regular security updates
- Firewall enabled

**Best Practices**:
- Regular updates
- Encrypted backups
- Secure boot (if configured)
- Strong passwords

## Extensibility

### Adding Components

**New Widgets**:
- Add QML component to Quickshell config
- Reuse existing animations and styles
- Follow component pattern

**New Keybinds**:
- Add to Hyprland config
- Follow naming convention
- Document in README

**New Packages**:
- Add to appropriate package list
- Test in VM first
- Update documentation

### Theming

**Color Schemes**:
- Define in theme config
- Live retint from wallpaper
- Easy to switch

**Fonts**:
- Install via package manager
- Reference in config
- Fallback fonts defined

**Icons**:
- Use standard icon themes
- Custom icons in theme dir
- SVG for scalability

## Comparison with Alternatives

### vs. Ryoku

**Similarities**:
- Wayland-first approach
- Custom shell concept
- Cohesive design philosophy

**Differences**:
- Fedora instead of Arch
- ML4W installer instead of custom
- More modular approach
- Easier to customize

### vs. ML4W

**Similarities**:
- Safe installation approach
- Profile management
- Backup system

**Differences**:
- Custom shell instead of Waybar
- More cohesive design
- Fedora-specific optimizations
- Hyprland instead of multiple WMs

### vs. Vanilla Fedora

**Similarities**:
- Same base system
- Same package manager
- Same repositories

**Differences**:
- No GNOME/GDM bloat
- Custom desktop experience
- Pre-configured for productivity
- Automated setup

## Future Enhancements

### Planned Features

**Plugin System**:
- Modular shell components
- User-contributed plugins
- Easy installation

**Multiple Profiles**:
- Work vs home configs
- Easy profile switching
- Profile-specific overrides

**Cloud Sync**:
- Config synchronization
- Machine-to-machine sync
- Conflict resolution

**AI Integration**:
- Smart workspace management
- Predictive app launching
- Adaptive layouts

### Community Contributions

We welcome contributions in:
- Shell components (QML)
- Hyprland configs
- Package optimizations
- Documentation
- Testing and bug reports

## Conclusion

FedDeck is designed for:
- **Stability**: Fedora base + Btrfs snapshots
- **Minimalism**: No bloat, only what's needed
- **Beauty**: Cohesive design, smooth animations
- **Safety**: Backups, snapshots, safe installer
- **Reproducibility**: Single source of truth

Perfect for professional use where reliability and aesthetics matter.
