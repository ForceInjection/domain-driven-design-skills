---
name: platform-porter
description: Port CClean-Killer features to Linux and Windows platforms. Use when asked to add Linux support, Windows support, cross-platform compatibility, port a feature, or implement platform-specific scripts.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, WebSearch
---

# Platform Porter

Port CClean-Killer features from macOS to Linux and Windows platforms.

## Purpose

Enable cross-platform support by:
- Porting macOS shell scripts to Linux
- Creating Windows PowerShell equivalents
- Maintaining platform parity

## Platform Mapping Reference

### macOS to Linux

| macOS | Linux Equivalent |
|-------|------------------|
| `~/Library/Application Support` | `~/.local/share`, `~/.config` |
| `~/Library/Caches` | `~/.cache` |
| `~/Library/Preferences` | `~/.config` |
| `~/Library/LaunchAgents` | `~/.config/systemd/user`, `~/.config/autostart` |
| `/Library/LaunchAgents` | `/etc/xdg/autostart` |
| `/Library/LaunchDaemons` | `/etc/systemd/system` |
| `mdfind` | `locate`, `find` |
| `defaults read` | Direct file parsing (JSON, INI) |
| `launchctl` | `systemctl --user`, `systemctl` |

### macOS to Windows

| macOS | Windows Equivalent |
|-------|-------------------|
| `~/Library/Application Support` | `%APPDATA%`, `%LOCALAPPDATA%` |
| `~/Library/Caches` | `%LOCALAPPDATA%\Temp` |
| `~/Library/Preferences` | `%APPDATA%\[App]` |
| `~/Library/LaunchAgents` | `HKCU\...\Run`, Task Scheduler |
| `/Library/LaunchDaemons` | Services, Task Scheduler |
| `launchctl` | `sc.exe`, `schtasks` |
| Shell scripts | PowerShell scripts |

## Modes

### Mode: research

Research platform differences and document porting requirements.

**When to use:** User says "research linux", "how to port", "platform differences"

**Workflow:**

1. **Read Existing Research**
   - Check `docs/cross-platform-research.md` for existing findings

2. **Identify Platform Equivalents**
   - Map macOS paths to target platform
   - Identify command equivalents
   - Note permission model differences

3. **Document Findings**
   - Update `knowledge/hidden-locations/linux.md` or `windows.md`
   - Add platform-specific parasite patterns

**Files Modified:**
- `docs/cross-platform-research.md`
- `knowledge/hidden-locations/*.md`

---

### Mode: implement

Create or update platform-specific scripts.

**When to use:** User says "port to linux", "add windows support", "implement for [platform]"

**Workflow:**

1. **Setup Phase**
   - Create platform directory if needed:
     ```bash
     mkdir -p scripts/linux  # or scripts/windows
     ```

2. **Port Script**
   - Copy macOS script as template
   - Replace paths with platform equivalents
   - Replace commands with platform equivalents
   - Handle permission model differences

3. **Implement Common Library**
   - Create `scripts/[platform]/lib/common.sh` (or `.ps1`)
   - Port shared functions

4. **Test Locally**
   - If on macOS, test Linux scripts in Docker:
     ```bash
     docker run -it --rm -v "$PWD:/app" ubuntu:latest bash
     ```

**File Structure:**

```
scripts/
├── macos/
│   ├── scan.sh
│   ├── clean.sh
│   ├── find-parasites.sh
│   ├── find-orphans.sh
│   └── lib/
│       ├── common.sh
│       └── optimized-patterns.sh
├── linux/
│   ├── scan.sh
│   ├── clean.sh
│   ├── find-parasites.sh
│   ├── find-orphans.sh
│   └── lib/
│       └── common.sh
└── windows/
    ├── scan.ps1
    ├── clean.ps1
    ├── find-parasites.ps1
    ├── find-orphans.ps1
    └── lib/
        └── common.ps1
```

**Files Modified:**
- `scripts/[platform]/*.sh` or `*.ps1`
- `scripts/[platform]/lib/*.sh` or `*.ps1`

---

### Mode: test

Test platform-specific scripts in appropriate environment.

**When to use:** User says "test linux", "verify windows", "run platform tests"

**Workflow:**

1. **Setup Test Environment**
   - For Linux: Use Docker container
     ```bash
     docker run -it --rm -v "$PWD:/app" ubuntu:latest bash
     cd /app && ./scripts/linux/scan.sh --dry-run
     ```
   - For Windows: Use VM or WSL

2. **Run Tests**
   - Execute platform-specific test suite:
     ```bash
     # Linux
     ./tests/run-tests.sh --platform linux

     # Windows (PowerShell)
     .\tests\run-tests.ps1 -Platform windows
     ```

3. **Verify Parity**
   - Compare output format with macOS version
   - Ensure same categories and structure
   - Check JSON output compatibility

---

## Linux Porting Guide

### Persistence Locations

```bash
# User autostart
~/.config/autostart/*.desktop
~/.config/systemd/user/*.service

# System services
/etc/systemd/system/*.service
/etc/init.d/*
/etc/xdg/autostart/*.desktop

# Cron jobs (parasites!)
/var/spool/cron/crontabs/*
/etc/cron.d/*
```

### Key Command Translations

```bash
# List user services
systemctl --user list-units --type=service

# List system services
systemctl list-units --type=service

# Disable user service
systemctl --user disable [service]

# Find orphaned data
find ~/.local/share -maxdepth 1 -type d ! -name "applications" | while read dir; do
  app=$(basename "$dir")
  if ! command -v "$app" &>/dev/null && ! flatpak list | grep -qi "$app"; then
    echo "Orphan: $dir"
  fi
done
```

### Package Manager Integration

```bash
# Check if app installed (Debian/Ubuntu)
dpkg -l | grep -i "[app]"

# Check if app installed (RHEL/Fedora)
rpm -qa | grep -i "[app]"

# Check Flatpak
flatpak list | grep -i "[app]"

# Check Snap
snap list | grep -i "[app]"
```

---

## Windows Porting Guide

### Persistence Locations

```powershell
# User startup (Run key)
HKCU:\Software\Microsoft\Windows\CurrentVersion\Run

# System startup (Run key)
HKLM:\Software\Microsoft\Windows\CurrentVersion\Run

# Task Scheduler
C:\Windows\System32\Tasks\*

# Services
Get-Service

# Startup folder
$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup
```

### Key Command Translations

```powershell
# List startup programs
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run

# List scheduled tasks
Get-ScheduledTask

# List services
Get-Service | Where-Object {$_.Status -eq 'Running'}

# Find orphaned data
Get-ChildItem "$env:APPDATA" -Directory | ForEach-Object {
    $app = $_.Name
    $installed = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Where-Object { $_.DisplayName -like "*$app*" }
    if (-not $installed) {
        Write-Output "Orphan: $_"
    }
}
```

### Registry Cleanup

```powershell
# Remove startup entry
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "[AppName]"

# Disable scheduled task
Disable-ScheduledTask -TaskName "[TaskName]"

# Stop and disable service
Stop-Service -Name "[ServiceName]"
Set-Service -Name "[ServiceName]" -StartupType Disabled
```

---

## Safety Rules

1. **ALWAYS** test in isolated environment (Docker/VM) first
2. **NEVER** modify system files without backup
3. **RESPECT** platform permission models
4. **VERIFY** command equivalents actually work
5. **MAINTAIN** output format parity with macOS

## Examples

### Example 1: Port scan.sh to Linux

```
User: "Port the scanner to Linux"

1. Read scripts/macos/scan.sh
2. Create scripts/linux/scan.sh
3. Replace:
   - ~/Library/Caches → ~/.cache
   - ~/Library/Application Support → ~/.local/share
   - du -sh → du -sh (same)
   - mdfind → find or locate
4. Test in Docker:
   docker run -it -v $PWD:/app ubuntu bash
   cd /app && ./scripts/linux/scan.sh
5. Verify output matches macOS format
```

### Example 2: Add Windows parasite detection

```
User: "Add Windows support for parasite detection"

1. Create scripts/windows/find-parasites.ps1
2. Implement registry scanning:
   - HKCU:\...\Run
   - HKLM:\...\Run
3. Implement Task Scheduler scanning
4. Implement Service detection
5. Output same JSON format as macOS
```

## Related Skills

- **knowledge-manager**: For adding platform-specific parasites
- **quality-assurance**: For adding platform-specific tests
