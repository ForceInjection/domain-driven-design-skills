---
name: screenshot-capture
description: Capture screenshots of windows or monitors. Use this skill when you need to take a screenshot for testing, debugging, or documentation purposes. Supports cross-virtual-desktop capture and annotation.
---

# Screenshot Capture

Capture screenshots using PowerShell with support for cross-virtual-desktop window capture.

## Output Location

Screenshots saved to `.screenshots/` at repo root (in `.gitignore`).

## Important: Resize Large Captures

When capturing screenshots to read/analyze, always use `-MaxWidth 1920` or smaller to keep file size manageable. Large screenshots (e.g., 3440x1440) should be scaled down for efficient processing.

## Quick Reference

| User Says | Command | What Happens |
|-----------|---------|--------------|
| "POE2 window" | `-WindowTitle "Path of Exile"` | Captures window content directly via PrintWindow (works across VD) |
| "POE2 monitor" | `-WindowTitle "Path of Exile" -CaptureMonitor` | Switches to POE2's VD, captures full monitor, switches back |
| "monitor 0" | `-Monitor 0` | Captures primary monitor (current desktop) |

## Three Use Cases

### 1. Capture Monitor

```powershell
.\.claude\skills\screenshot-capture\scripts\capture_screenshot.ps1 -Monitor 0
```

### 2. "POE2 window" - Capture Window Content

Captures window content directly using PrintWindow API. **Works across virtual desktops** without switching.

```powershell
.\.claude\skills\screenshot-capture\scripts\capture_screenshot.ps1 -WindowTitle "Path of Exile" -OutputName "poe2_window" -MaxWidth 1920
```

### 3. "POE2 monitor" - Capture Window's Monitor

Switches to window's virtual desktop, captures the full monitor, switches back.

```powershell
.\.claude\skills\screenshot-capture\scripts\capture_screenshot.ps1 -WindowTitle "Path of Exile" -CaptureMonitor -OutputName "poe2_monitor" -MaxWidth 1920
```

## Capture Parameters

| Parameter | Description |
|-----------|-------------|
| `-WindowTitle` | Partial window title to match |
| `-Monitor` | Monitor index (0 = primary) |
| `-CaptureMonitor` | Capture full monitor of window (with VD switching) |
| `-OutputName` | Custom filename (without extension) |
| `-MaxWidth` | Scale down if wider |
| `-MaxHeight` | Scale down if taller |
| `-NoSwitchBack` | Stay on target VD after capture |

---

## Annotation Features

### Add Grid with Percentage Markers

```powershell
# "add grid to poe2_window.png"
.\.claude\skills\screenshot-capture\scripts\annotate_screenshot.ps1 -InputPath "poe2_window.png" -AddGrid
```

### Draw Rectangle at Percentage Coordinates

```powershell
# "draw rectangle from 45,35 to 75,65 on poe2.png"
.\.claude\skills\screenshot-capture\scripts\annotate_screenshot.ps1 -InputPath "poe2.png" -DrawRect "45,35,75,65"
```

### Combined Grid + Rectangle

```powershell
.\.claude\skills\screenshot-capture\scripts\annotate_screenshot.ps1 -InputPath "poe2.png" -AddGrid -DrawRect "45,35,75,65"
```

## Annotation Parameters

| Parameter | Description |
|-----------|-------------|
| `-InputPath` | Input image (filename if in `.screenshots/`) |
| `-OutputPath` | Output path (default: adds `_annotated` suffix) |
| `-AddGrid` | Add 10% gridlines with markers |
| `-DrawRect` | Rectangle(s) as "X1,Y1,X2,Y2" percentages |
| `-GridColor` | Grid color (default: Yellow) |
| `-RectColor` | Rectangle color (default: Red) |

---

## List Windows

```powershell
.\.claude\skills\screenshot-capture\scripts\list_windows.ps1
```

Shows all windows with virtual desktop status (Current/Other).
