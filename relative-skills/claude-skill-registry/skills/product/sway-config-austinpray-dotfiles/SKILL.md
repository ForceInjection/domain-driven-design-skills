---
name: sway-config
description: Configures Sway window manager. Use when user asks about sway keybindings, window rules, outputs, inputs, workspaces, or any sway/i3 configuration.
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# Sway Configuration

## Config location
~/dotfiles/.config/sway/config

## Man pages
- `man 5 sway` - Main config reference
- `man 5 sway-input` - Input devices (keyboard, mouse, touchpad)
- `man 5 sway-output` - Displays and monitors
- `man 5 sway-bar` - Status bar configuration

## Common patterns

### Keybindings
bindsym $mod+Return exec foot
bindsym --locked XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle

### Window rules (make windows float, assign to workspace, etc)
for_window [app_id="firefox"] floating enable
for_window [class="Steam"] move to workspace 5
assign [app_id="discord"] workspace 4

### Finding window identifiers
Run: swaymsg -t get_tree | grep -E "app_id|class"

### Input configuration
input "type:keyboard" {
    xkb_options ctrl:nocaps
}

### Output configuration
output eDP-1 resolution 1920x1080 position 0,0

### Startup programs
exec /usr/bin/program           # runs once at startup
exec_always nm-applet           # runs on startup and reload

### Variables
set $mod Mod4
set $term foot

## Criteria for window matching
- app_id - Wayland app identifier
- class - X11 window class (XWayland)
- title - Window title (regex)
- floating/tiling - Window state

## After editing
Reload config with $mod+Shift+c or run: swaymsg reload
