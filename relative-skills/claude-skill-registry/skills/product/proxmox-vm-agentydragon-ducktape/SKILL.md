---
name: proxmox-vm
description: Interact with Proxmox VMs - screenshots, keystrokes, network info (user)
---

# Proxmox VM Interaction

Interact with VMs on Proxmox via QEMU monitor. Actions execute sequentially in command-line order.

## Usage

```bash
~/.claude/skills/proxmox-vm/vm-interact.py <vmid> [actions...]
```

## Actions

| Action                        | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| `--screenshot`, `-s`          | Take screenshot, save to `~/.cache/proxmox-vm/vm<id>/<timestamp>.png` |
| `--type "text"`, `-t "text"`  | Type text (converts chars to QEMU keys)                               |
| `--enter`, `-e`               | Press Enter                                                           |
| `--sendkey <key>`, `-k <key>` | Send QEMU key code (e.g., `ctrl-c`, `ret`, `shift-a`)                 |
| `--info`, `-i`                | Show VM network interfaces via guest agent                            |
| `--sleep <secs>`              | Sleep between actions                                                 |
| `--stdin`                     | Read commands from stdin (one per line)                               |

## Examples

```bash
# Take screenshot
./vm-interact.py 110 --screenshot

# Type command and press Enter
./vm-interact.py 110 --type "ip addr" --enter

# Log in and run command
./vm-interact.py 110 --type "root" --enter --sleep 0.5 --type "password" --enter

# Send Ctrl+C then screenshot
./vm-interact.py 110 --sendkey ctrl-c --screenshot

# Get network info
./vm-interact.py 110 --info

# From stdin
echo -e "type ip addr\nenter\nsleep 1\nscreenshot" | ./vm-interact.py 110 --stdin
```

## QEMU Key Names

Common keys: `a`-`z`, `0`-`9`, `ret` (Enter), `spc` (Space), `tab`, `minus`, `equal`, `comma`, `dot`, `slash`, `backslash`, `semicolon`, `apostrophe`, `bracket_left`, `bracket_right`, `grave_accent`

Modifiers: `shift-X`, `ctrl-X`, `alt-X` (e.g., `shift-a` for 'A', `ctrl-c` for Ctrl+C)

## stdin Format

One command per line:

```
screenshot
type ip addr
enter
sendkey ctrl-c
info
sleep 1.5
# comments start with #
```
