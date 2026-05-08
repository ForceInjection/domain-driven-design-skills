---
name: desktop
description: |
  Desktop customization for Bazzite. GTK theme restoration, terminal transparency,
  and MOTD settings. Use when users need to customize their desktop appearance.
---

# Desktop - Bazzite Desktop Customization

## Overview

Desktop appearance customization for Bazzite including GTK themes, terminal transparency, and message of the day settings.

## Quick Reference

| Command | Description |
|---------|-------------|
| `ujust restore-bazzite-breeze-gtk-theme` | Restore Bazzite GTK4 theme |
| `ujust ptyxis-transparency` | Set terminal transparency |
| `ujust toggle-user-motd` | Toggle terminal MOTD |

## GTK Theme

### Restore Bazzite Theme

```bash
# Restore default Bazzite Breeze GTK4 theme
ujust restore-bazzite-breeze-gtk-theme
```

**Restores:**
- Bazzite Breeze GTK4 colors
- Window decorations
- Widget styling
- Default Bazzite appearance

**Use when:**
- Theme got corrupted
- Changed themes and want to revert
- Fresh desktop appearance needed

## Terminal Transparency

### Set Transparency

```bash
# Set Ptyxis terminal transparency (0-1)
ujust ptyxis-transparency 0.8   # 80% opaque
ujust ptyxis-transparency 0.5   # 50% opaque
ujust ptyxis-transparency 1.0   # Fully opaque (no transparency)
ujust ptyxis-transparency 0.0   # Fully transparent
```

**Values:**
- `1.0` = Fully opaque (solid)
- `0.0` = Fully transparent
- `0.8` = Recommended for readability

**Note:** Ptyxis is the default terminal on Bazzite GNOME.

## Message of the Day

### Toggle MOTD

```bash
# Toggle user MOTD display on terminal
ujust toggle-user-motd
```

**MOTD (Message of the Day):**
- Shows system info on terminal open
- Welcome message
- Tips and notifications

**Toggle:**
- Enabled → Disabled
- Disabled → Enabled

## Common Workflows

### Clean Desktop Reset

```bash
# Restore default theme
ujust restore-bazzite-breeze-gtk-theme

# Reset terminal transparency
ujust ptyxis-transparency 1.0
```

### Aesthetic Terminal

```bash
# Light transparency
ujust ptyxis-transparency 0.85

# Enable MOTD for info
ujust toggle-user-motd
```

### Minimal Setup

```bash
# Disable MOTD
ujust toggle-user-motd

# Full opacity
ujust ptyxis-transparency 1.0
```

## Manual Customization

### GTK Themes

```bash
# List available themes
ls /usr/share/themes/

# Set theme (GNOME)
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
```

### Cursor Theme

```bash
# List cursors
ls /usr/share/icons/*/cursors

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
```

### Font Settings

```bash
# Set interface font
gsettings set org.gnome.desktop.interface font-name "Cantarell 11"

# Set monospace font
gsettings set org.gnome.desktop.interface monospace-font-name "Source Code Pro 10"
```

## Troubleshooting

### Theme Not Applying

**GTK4 apps:**

```bash
# Restart GTK4 apps or:
# Log out and log back in
```

**Check theme exists:**

```bash
ls /usr/share/themes/ | grep -i breeze
```

### Transparency Not Working

**Check compositor:**

```bash
# Wayland sessions have transparency support
echo $XDG_SESSION_TYPE
```

**Ptyxis specific:**

```bash
# Check Ptyxis is running
pgrep ptyxis
```

### MOTD Still Showing

**Check config:**

```bash
# MOTD config location
cat ~/.config/motd-disabled 2>/dev/null
```

**Manual disable:**

```bash
touch ~/.config/motd-disabled
```

## Desktop Environments

### Bazzite GNOME

Default desktop with:
- Ptyxis terminal
- Nautilus file manager
- GNOME extensions

### Bazzite KDE

Alternative with:
- Konsole terminal
- Dolphin file manager
- KDE Plasma customization

**Note:** Some commands may differ on KDE.

## Cross-References

- **bazzite-ai:shell** - Shell customization
- **bazzite:gaming** - Game Mode appearance
- **bazzite:system** - System cleanup

## When to Use This Skill

Use when the user asks about:
- "GTK theme", "restore theme", "Bazzite theme", "Breeze"
- "terminal transparency", "Ptyxis", "transparent terminal"
- "MOTD", "message of the day", "terminal welcome"
- "desktop appearance", "customize desktop"
