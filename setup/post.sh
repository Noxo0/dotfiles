#!/bin/bash
# Post-installation tasks (runs on all distributions)
set -e

echo "==> Running post-installation tasks"

# Create backup directory
BACKUP_DIR="$HOME/.feddeck-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Backup directory: $BACKUP_DIR"

# Backup existing configs if they exist
for dir in .config/hypr .config/quickshell .config/theme; do
    if [ -d "$HOME/$dir" ]; then
        echo "Backing up $HOME/$dir to $BACKUP_DIR/"
        mv "$HOME/$dir" "$BACKUP_DIR/"
    fi
done

echo "==> Post-installation tasks complete"
