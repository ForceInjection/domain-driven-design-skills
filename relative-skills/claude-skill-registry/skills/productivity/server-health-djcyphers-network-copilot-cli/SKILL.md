---
name: server-health
description: "Check Windows Server health: CPU, memory, disk, services, event logs, uptime. Use when user asks about server performance or wants a health check."
license: MIT
compatibility:
  - copilot-cli
  - vscode-copilot
  - claude
allowed-tools:
  - windows-command-line
  - console-automation
---

# Server Health Check Skill

## When to Activate
- User mentions: health check, performance, slow server, disk space, memory, CPU
- User asks "is the server OK?" or "check the server"
- User reports application slowness

## Quick Health Summary (One-Liner)

```powershell
# Fast health snapshot
$cpu = (Get-CimInstance Win32_Processor).LoadPercentage
$mem = Get-CimInstance Win32_OperatingSystem
$memPct = [math]::Round((($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100)
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, @{N='FreeGB';E={[math]::Round($_.FreeSpace/1GB)}}, @{N='UsedPct';E={[math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100)}}
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

Write-Host "CPU: $cpu% | Memory: $memPct% | Uptime: $($uptime.Days)d $($uptime.Hours)h"
$disk | Format-Table -AutoSize
```

## Detailed Health Checks

### CPU Analysis
```powershell
# Current CPU with top processes
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet64

# CPU over time (5 samples, 2 sec apart)
Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 2 -MaxSamples 5
```

### Memory Analysis
```powershell
# Memory breakdown
$os = Get-CimInstance Win32_OperatingSystem
[PSCustomObject]@{
    'Total GB' = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    'Free GB' = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    'Used %' = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100)
}

# Top memory consumers
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name, @{N='MemMB';E={[math]::Round($_.WorkingSet64/1MB)}}
```

### Disk Analysis
```powershell
# All fixed disks
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    [PSCustomObject]@{
        Drive = $_.DeviceID
        'Size GB' = [math]::Round($_.Size / 1GB)
        'Free GB' = [math]::Round($_.FreeSpace / 1GB)
        'Used %' = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100)
        Status = if (($_.FreeSpace / $_.Size) -lt 0.1) { '⚠️ LOW' } else { '✅ OK' }
    }
}
```

### Critical Services
```powershell
# Check essential services
$criticalServices = @('wuauserv', 'W32Time', 'EventLog', 'Netlogon', 'DNS', 'DFSR')
$criticalServices | ForEach-Object {
    $svc = Get-Service -Name $_ -ErrorAction SilentlyContinue
    if ($svc) {
        [PSCustomObject]@{
            Name = $svc.DisplayName
            Status = $svc.Status
            StartType = $svc.StartType
        }
    }
}
```

### Recent Errors (Event Log)
```powershell
# Last 24h errors
Get-WinEvent -FilterHashtable @{
    LogName = 'System', 'Application'
    Level = 1, 2  # Critical, Error
    StartTime = (Get-Date).AddHours(-24)
} -MaxEvents 20 -ErrorAction SilentlyContinue |
Select-Object TimeCreated, LogName, LevelDisplayName, Message
```

## Thresholds & Alerts

| Metric | Warning | Critical |
|--------|---------|----------|
| CPU | > 80% sustained | > 95% sustained |
| Memory | > 85% used | > 95% used |
| Disk | < 15% free | < 5% free |
| Uptime | > 90 days (patch!) | > 180 days |
