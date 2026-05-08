---
name: admin-windows
description: |
  Windows system administration with PowerShell 7.x. Profile-aware - reads your preferences
  for package managers (scoop vs winget), paths, and installed tools.

  Use when: Windows-specific admin tasks, PowerShell automation, PATH configuration,
  package installation, bash-to-PowerShell translation.
license: MIT
---

# Windows Administration

**Requires**: Windows platform, PowerShell 7.x

---

## Profile-First Approach

**Always load profile before operations:**

```powershell
. $HOME/.admin/scripts/Load-Profile.ps1  # Or from admin skill
Load-AdminProfile -Export
```

Then check preferences before suggesting commands:

```powershell
# User wants to install a package
$preferredManager = $AdminProfile.preferences.packages.manager
# Returns: "scoop" or "winget" or "chocolatey"
```

---

## Package Installation (Profile-Aware)

### Check Preference First

```powershell
$pkgMgr = $AdminProfile.preferences.packages.manager

switch ($pkgMgr) {
    "scoop"   { scoop install $package }
    "winget"  { winget install $package }
    "choco"   { choco install $package -y }
    default   { winget install $package }
}
```

### Quick Reference by Manager

| Manager | Install | Update | List |
|---------|---------|--------|------|
| scoop | `scoop install x` | `scoop update x` | `scoop list` |
| winget | `winget install x` | `winget upgrade x` | `winget list` |
| choco | `choco install x -y` | `choco upgrade x` | `choco list` |

---

## Python Commands (Profile-Aware)

**Check profile first:**

```powershell
$pyMgr = $AdminProfile.preferences.python.manager
# Returns: "uv", "pip", "conda", "poetry"
```

| Profile Says | Instead of `pip install x` | Use |
|--------------|---------------------------|-----|
| `uv` | ❌ | `uv pip install x` |
| `pip` | ✅ | `pip install x` |
| `conda` | ❌ | `conda install x` |
| `poetry` | ❌ | `poetry add x` |

---

## Node Commands (Profile-Aware)

```powershell
$nodeMgr = $AdminProfile.preferences.node.manager
# Returns: "npm", "pnpm", "yarn", "bun"
```

| Profile Says | Instead of `npm install` | Use |
|--------------|--------------------------|-----|
| `npm` | ✅ | `npm install` |
| `pnpm` | ❌ | `pnpm install` |
| `yarn` | ❌ | `yarn` |
| `bun` | ❌ | `bun install` |

---

## Bash to PowerShell Translation

| Bash | PowerShell | Notes |
|------|------------|-------|
| `cat file` | `Get-Content file` | Or `gc` |
| `cat file \| head -20` | `Get-Content file -Head 20` | |
| `cat file \| tail -20` | `Get-Content file -Tail 20` | |
| `ls -la` | `Get-ChildItem -Force` | |
| `grep "x" file` | `Select-String "x" file` | Or `sls` |
| `echo "x"` | `Write-Output "x"` | |
| `echo "x" > file` | `Set-Content file -Value "x"` | |
| `echo "x" >> file` | `Add-Content file -Value "x"` | |
| `export VAR=x` | `$env:VAR = "x"` | Session only |
| `export VAR=x` (perm) | `[Environment]::SetEnvironmentVariable("VAR", "x", "User")` | |
| `test -f file` | `Test-Path file -PathType Leaf` | |
| `test -d dir` | `Test-Path dir -PathType Container` | |
| `mkdir -p dir` | `New-Item -ItemType Directory -Path dir -Force` | |
| `rm -rf dir` | `Remove-Item dir -Recurse -Force` | |
| `which cmd` | `Get-Command cmd` | |
| `curl URL` | `Invoke-WebRequest URL` | |
| `jq` | `ConvertFrom-Json` / `ConvertTo-Json` | |

---

## PATH Operations

### Check Tool Path from Profile

```powershell
# Instead of searching, use profile
$gitPath = $AdminProfile.tools.git.path
# Returns: "C:/Program Files/Git/mingw64/bin/git.exe"
```

### Add to PATH (Permanent)

```powershell
$newPath = "C:/new/path"
$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($currentPath -notlike "*$newPath*") {
    [Environment]::SetEnvironmentVariable('PATH', "$newPath;$currentPath", 'User')
}
# Refresh session
$env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User') + ";" + [Environment]::GetEnvironmentVariable('PATH', 'Machine')
```

---

## Environment Variables

### From Profile

```powershell
# Key paths are in profile
$AdminProfile.paths.sshKeys      # C:/Users/Owner/.ssh
$AdminProfile.paths.npmGlobal    # C:/Users/Owner/AppData/Roaming/npm
$AdminProfile.paths.projects     # D:/
```

### Set Permanent Variable

```powershell
[Environment]::SetEnvironmentVariable("MY_VAR", "value", "User")
```

---

## Check Tool Status

Before installing, check profile:

```powershell
$tool = Get-AdminTool "docker"
if ($tool.present -and $tool.installStatus -eq "working") {
    Write-Host "Docker already installed: $($tool.version)"
} else {
    # Install using preferred manager
    $mgr = $AdminProfile.preferences.packages.manager
    # ... install logic
}
```

---

## After Installation

Update profile:

```powershell
$AdminProfile.tools["newtool"] = @{
    present = $true
    version = "1.0.0"
    installedVia = $AdminProfile.preferences.packages.manager
    path = (Get-Command newtool).Source
    installStatus = "working"
    lastChecked = (Get-Date).ToString("o")
}

# Add to history
$AdminProfile.history += @{
    date = (Get-Date).ToString("o")
    action = "install"
    tool = "newtool"
    method = $AdminProfile.preferences.packages.manager
    status = "success"
}

# Save
$AdminProfile | ConvertTo-Json -Depth 10 | Set-Content $AdminProfile.paths.deviceProfile
```

---

## Execution Policy

```powershell
# Check
Get-ExecutionPolicy -List

# Set for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Bypass for single script
powershell -ExecutionPolicy Bypass -File script.ps1
```

---

## PowerShell Profile

Location: `$AdminProfile.preferences.shell.profilePath`

```powershell
# Edit
notepad $PROFILE

# Recommended: Source admin profile loader
. "$HOME\.admin\scripts\Load-Profile.ps1"
Load-AdminProfile -Export -Quiet
```

---

## Capabilities Check

Before operations, verify capabilities:

```powershell
if (-not (Test-AdminCapability "canRunPowershell")) {
    Write-Error "PowerShell not available"
    return
}

if (Test-AdminCapability "hasDocker") {
    # Docker operations safe
}
```

---

## Related Skills

| Task | Route To |
|------|----------|
| WSL operations | `admin-wsl` |
| MCP servers | `admin-mcp` |
| Server provisioning | `admin-devops` |
| Profile management | `admin` |

---

## References

- `references/OPERATIONS.md` - Troubleshooting, known issues
