---
name: yara-manager
description: Use this skill when users need help creating, testing, deploying, or managing YARA rules for malware detection in LimaCharlie.
---

# LimaCharlie YARA Manager

This skill provides comprehensive guidance for creating, testing, and deploying YARA rules for malware detection in LimaCharlie. Use this skill when users need help with YARA rule syntax, storage, scanning methods, performance optimization, or integration with Detection & Response rules.

## Navigation

This skill is organized into multiple documents:

- **SKILL.md** (this file): Overview, quick start, and common workflows
- **[REFERENCE.md](./REFERENCE.md)**: Complete YARA syntax reference, string modifiers, functions, and operators
- **[EXAMPLES.md](./EXAMPLES.md)**: Complete YARA rule examples with D&R integration
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**: Performance optimization, suppression strategies, and debugging

---

## YARA Overview

### What is YARA?

YARA is a powerful pattern-matching tool designed to help malware researchers identify and classify malware samples. It allows you to create descriptions of malware families (or any files you want to detect) based on textual or binary patterns.

**In LimaCharlie, YARA enables:**
- File-based malware detection (on-disk scanning)
- Memory-based malware detection (in-memory/process scanning)
- Automated scanning triggered by D&R rules
- Manual on-demand scans
- Continuous background scanning across your fleet

### How YARA Works in LimaCharlie

YARA rules can be:
1. **Stored** in the Config Hive (`hive://yara/`)
2. **Referenced** from external sources (GitHub, URLs)
3. **Scanned** manually or automatically via D&R rules
4. **Detected** and reported as `YARA_DETECTION` events

---

## Quick Start

### 1. Create a Basic YARA Rule

```yara
rule Basic_Malware_Detection
{
    meta:
        description = "Detects basic malware patterns"
        author = "Your Name"
        date = "2025-01-15"

    strings:
        $mz = "MZ"
        $str1 = "malicious_function" nocase
        $hex1 = { 6A 40 68 00 30 00 00 }

    condition:
        $mz at 0 and
        filesize < 5MB and
        any of ($str*, $hex*)
}
```

### 2. Store Rule in Config Hive

**Via CLI:**
```bash
limacharlie hive set yara --key my-rule --data rule.yara --data-key rule
```

**Via Web UI:**
1. Navigate to **Automation → YARA Rules**
2. Click **Add New Rule**
3. Enter rule name: `my-rule`
4. Paste YARA rule content
5. Click **Save**

### 3. Test the Rule

**Manual scan via sensor console:**
```
yara_scan hive://yara/my-rule -f "C:\Users\user\Downloads\suspicious.exe"
```

### 4. Deploy with D&R Rule

```yaml
# Step 1: Trigger YARA scan
detect:
  event: NEW_DOCUMENT
  op: and
  rules:
    - op: ends with
      path: event/FILE_PATH
      value: .exe
      case sensitive: false

respond:
  - action: task
    command: yara_scan hive://yara/my-rule -f "{{ .event.FILE_PATH }}"
    investigation: Malware Scan
    suppression:
      is_global: false
      keys:
        - '{{ .event.FILE_PATH }}'
      max_count: 1
      period: 5m

---

# Step 2: Detect YARA match
detect:
  event: YARA_DETECTION
  op: is
  path: event/RULE_NAME
  value: Basic_Malware_Detection

respond:
  - action: report
    name: "Malware Detected - {{ .event.FILE_PATH }}"
    priority: 4
```

---

## Basic YARA Rule Structure

Every YARA rule has four components:

**1. Rule Declaration:** `rule RuleName { }`

**2. Metadata (Optional):**
```yara
meta:
    description = "What this detects"
    author = "Your Name"
```

**3. Strings:**
```yara
strings:
    $text = "malicious" nocase
    $hex = { 6A 40 68 00 }
    $regex = /md5: [0-9a-fA-F]{32}/i
```

**4. Condition (Required):**
```yara
condition:
    all of them                  // All strings
    any of them                  // At least one
    2 of ($text*)                // At least 2
    filesize < 1MB               // File size
    uint16(0) == 0x5A4D          // PE header
```

**See [REFERENCE.md](./REFERENCE.md) for complete syntax details.**

---

## Scanning Methods

### 1. Manual Sensor Command

**Scan a file:**
```
yara_scan hive://yara/my-rule -f "C:\Users\user\Downloads\suspicious.exe"
```

**Scan a process (in memory):**
```
yara_scan hive://yara/my-rule --pid 1234
```

**Scan a directory:**
```
yara_scan hive://yara/my-rule --path "C:\Users\user\Downloads"
```

### 2. Via D&R Rules

Automatically trigger YARA scans in response to events:

```yaml
respond:
  - action: task
    command: yara_scan hive://yara/my-rule --pid "{{ .event.PROCESS_ID }}"
    suppression:
      is_global: false
      keys:
        - '{{ .event.PROCESS_ID }}'
      max_count: 1
      period: 5m
```

### 3. Via YARA Extension

The YARA Extension (`ext-yara`) provides automated continuous scanning:
- Scans files loaded in memory
- Scans process memory
- Configure via **Add-ons → Extensions → YARA**

### 4. Via API

```python
import limacharlie

lc = limacharlie.Manager()
sensor = lc.sensor('SENSOR_ID')
sensor.task('yara_scan hive://yara/my-rule -f "C:\\malware.exe"')
```

---

## Common Workflows

### Workflow 1: Scan New Executables

```yaml
detect:
  event: NEW_DOCUMENT
  op: ends with
  path: event/FILE_PATH
  value: .exe
  case sensitive: false

respond:
  - action: task
    command: yara_scan hive://yara/malware-rule -f "{{ .event.FILE_PATH }}"
    suppression:
      is_global: false
      keys:
        - '{{ .event.FILE_PATH }}'
      max_count: 1
      period: 5m
```

### Workflow 2: Detect YARA Matches (Memory)

```yaml
detect:
  event: YARA_DETECTION
  op: exists
  path: event/PROCESS/*

respond:
  - action: report
    name: YARA Detection in Memory - {{ .event.RULE_NAME }}
    priority: 4
  - action: task
    command: history_dump
```

### Workflow 3: Detect YARA Matches (On-Disk)

```yaml
detect:
  event: YARA_DETECTION
  op: and
  rules:
    - not: true
      op: exists
      path: event/PROCESS/*
    - op: exists
      path: event/RULE_NAME

respond:
  - action: report
    name: YARA Detection on Disk - {{ .event.RULE_NAME }}
```

**See [EXAMPLES.md](./EXAMPLES.md) for more complete workflow examples.**

---

## Suppression Overview (Critical!)

**WARNING:** YARA scanning is CPU-intensive. Always use suppression when triggering YARA scans via D&R rules.

### Why Suppression is Critical

Without suppression:
- Same file/process scanned repeatedly
- High CPU utilization on endpoints
- Performance degradation
- Wasted resources

### Basic Suppression Pattern

```yaml
respond:
  - action: task
    command: yara_scan hive://yara/my-rule --pid "{{ .event.PROCESS_ID }}"
    suppression:
      is_global: false
      keys:
        - '{{ .event.PROCESS_ID }}'
        - Yara Scan Process
      max_count: 1
      period: 5m
```

### Suppression Parameters

- **is_global**:
  - `false`: Per-sensor suppression (recommended)
  - `true`: Organization-wide suppression
- **keys**: List of values to track (use template strings)
- **max_count**: Maximum executions allowed in period
- **period**: Time window (e.g., `1m`, `5m`, `1h`)

### Common Suppression Patterns

**Suppress by Process ID:**
```yaml
keys:
  - '{{ .event.PROCESS_ID }}'
max_count: 1
period: 1m
```

**Suppress by File Path:**
```yaml
keys:
  - '{{ .event.FILE_PATH }}'
max_count: 1
period: 5m
```

**Suppress by File Hash:**
```yaml
keys:
  - '{{ .event.HASH }}'
max_count: 1
period: 10m
```

**See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for advanced suppression strategies.**

---

## YARA Manager Extension

The YARA Manager Extension (`ext-yara-manager`) syncs rules from external sources automatically.

**Sources supported:**
- Predefined community rulesets
- Public GitHub repositories: `[github,Yara-Rules/rules/email]`
- Private GitHub repos: `[github,org/repo/path,token,TOKEN]`
- Direct URLs

**Syncing:** Automatic every 24 hours, or click **Manual Sync** button.

Access via **Add-ons → Extensions → YARA Manager**

---

## YARA_DETECTION Event Structure

When a YARA rule matches, a `YARA_DETECTION` event is generated:

```json
{
  "RULE_NAME": "malware_detection_rule",
  "FILE_PATH": "C:\\malicious.exe",
  "HASH": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "PROCESS": {
    "PROCESS_ID": 1234,
    "FILE_PATH": "C:\\malicious.exe"
  }
}
```

**Key fields:**
- `RULE_NAME`: Name of the YARA rule that matched
- `FILE_PATH`: Path to the file scanned
- `HASH`: SHA256 hash of the file
- `PROCESS`: Present only for memory scans (contains PID and process path)

---

## Quick Reference

### YARA Command Syntax

```bash
# Scan a file
yara_scan hive://yara/RULE_NAME -f "FILE_PATH"

# Scan a process
yara_scan hive://yara/RULE_NAME --pid PID

# Scan a directory
yara_scan hive://yara/RULE_NAME --path "DIRECTORY_PATH"
```

### Config Hive CLI Commands

```bash
# Set YARA rule
limacharlie hive set yara --key RULE_NAME --data RULE_FILE --data-key rule

# Get YARA rule
limacharlie hive get yara --key RULE_NAME

# Delete YARA rule
limacharlie hive del yara --key RULE_NAME

# List all YARA rules
limacharlie hive list yara
```

### D&R Pattern: Scan and Detect

```yaml
# Rule 1: Trigger YARA scan
detect:
  event: SOME_EVENT
  # detection logic

respond:
  - action: task
    command: yara_scan hive://yara/RULE_NAME --pid "{{ .event.PROCESS_ID }}"
    suppression:
      is_global: false
      keys:
        - '{{ .event.PROCESS_ID }}'
      max_count: 1
      period: 5m

---

# Rule 2: Detect YARA match
detect:
  event: YARA_DETECTION
  op: is
  path: event/RULE_NAME
  value: YOUR_YARA_RULE_NAME

respond:
  - action: report
    name: "YARA Detection - {{ .event.RULE_NAME }}"
```

---

## Best Practices Summary

1. **Always use suppression** when triggering YARA scans via D&R rules
2. **Target scans** to specific events and file types
3. **Limit file sizes** to avoid scanning large files
4. **Test rules locally** before deployment
5. **Use descriptive names** and comprehensive metadata
6. **Monitor performance** after deploying YARA scans
7. **Start with high-confidence rules** and expand gradually
8. **Include relevant strings** and avoid overly generic patterns
9. **Use fullword** modifier for common terms
10. **Optimize conditions** (fast checks first, slow checks last)

---

## When to Use This Skill

Use the yara-manager skill when users ask about:

- Creating YARA rules
- YARA rule syntax and structure
- Storing YARA rules in Config Hive
- Scanning files or processes with YARA
- Triggering YARA scans from D&R rules
- Detecting YARA_DETECTION events
- Managing YARA rules (YARA Manager extension)
- External YARA rule sources (GitHub, URLs)
- YARA performance optimization
- Suppression strategies for YARA scans
- Integrating YARA with Detection & Response
- Troubleshooting YARA rules
- YARA best practices
- Malware detection with YARA
- Automated YARA scanning

This skill provides comprehensive, authoritative guidance for all YARA-related operations in LimaCharlie.
