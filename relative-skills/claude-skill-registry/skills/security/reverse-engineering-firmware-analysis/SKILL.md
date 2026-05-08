---
name: reverse-engineering-firmware-analysis
description: Firmware extraction and IoT security analysis (RE Level 5) for routers and embedded systems. Use when analyzing IoT firmware, extracting embedded filesystems (SquashFS/JFFS2/CramFS), finding hardcoded credentials, performing CVE scans, or auditing embedded system security. Handles encrypted firmware with known decryption schemes. Completes in 2-8 hours with binwalk+firmadyne+QEMU emulation.
allowed-tools: Read, Glob, Grep, Bash, Task, TodoWrite
---



---

## LIBRARY-FIRST PROTOCOL (MANDATORY)

**Before writing ANY code, you MUST check:**

### Step 1: Library Catalog
- Location: `.claude/library/catalog.json`
- If match >70%: REUSE or ADAPT

### Step 2: Patterns Guide
- Location: `.claude/docs/inventories/LIBRARY-PATTERNS-GUIDE.md`
- If pattern exists: FOLLOW documented approach

### Step 3: Existing Projects
- Location: `D:\Projects\*`
- If found: EXTRACT and adapt

### Decision Matrix
| Match | Action |
|-------|--------|
| Library >90% | REUSE directly |
| Library 70-90% | ADAPT minimally |
| Pattern exists | FOLLOW pattern |
| In project | EXTRACT |
| No match | BUILD (add to library after) |

---

## When to Use This Skill

Use this skill when analyzing malware samples, reverse engineering binaries for security research, conducting vulnerability assessments, extracting IOCs from suspicious files, validating software for supply chain security, or performing CTF challenges and binary exploitation research.

## When NOT to Use This Skill

Do NOT use for unauthorized reverse engineering of commercial software, analyzing binaries on production systems, reversing software without legal authorization, violating terms of service or EULAs, or analyzing malware outside isolated environments. Avoid for simple string extraction (use basic tools instead).

## Success Criteria

- All security-relevant behaviors identified (network, file, registry, process activity)
- Malicious indicators extracted with confidence scores (IOCs, C2 domains, encryption keys)
- Vulnerabilities documented with CVE mapping where applicable
- Analysis completed within sandbox environment (VM/container with snapshots)
- Findings validated through multiple analysis methods (static + dynamic + symbolic)
- Complete IOC report generated (STIX/MISP format for threat intelligence sharing)
- Zero false positives in vulnerability assessments
- Exploitation proof-of-concept created (if vulnerability research)

## Edge Cases & Challenges

- Anti-analysis techniques (debugger detection, VM detection, timing checks)
- Obfuscated or packed binaries requiring unpacking
- Multi-stage malware with encrypted payloads
- Kernel-mode rootkits requiring specialized analysis
- Symbolic execution state explosion (>10,000 paths)
- Binary analysis timeout on complex programs (>24 hours)
- False positives from legitimate software behavior
- Encrypted network traffic requiring SSL interception

## Guardrails (CRITICAL SECURITY RULES)

- NEVER execute unknown binaries on host systems (ONLY in isolated VM/sandbox)
- NEVER analyze malware without proper containment (air-gapped lab preferred)
- NEVER reverse engineer software without legal authorization
- NEVER share extracted credentials or encryption keys publicly
- NEVER bypass licensing mechanisms for unauthorized use
- ALWAYS use sandboxed environments with network monitoring
- ALWAYS take VM snapshots before executing suspicious binaries
- ALWAYS validate findings through multiple analysis methods
- ALWAYS document analysis methodology with timestamps
- ALWAYS assume binaries are malicious until proven safe
- ALWAYS use network isolation to prevent malware communication
- ALWAYS sanitize IOCs before sharing (redact internal IP addresses)

## Evidence-Based Validation

All reverse engineering findings MUST be validated through:
1. **Multi-method analysis** - Static + dynamic + symbolic execution confirm same behavior
2. **Sandbox validation** - Execute in isolated environment, capture all activity
3. **Network monitoring** - Packet capture validates network-based findings
4. **Memory forensics** - Validate runtime secrets through memory dumps
5. **Behavioral correlation** - Cross-reference with known malware signatures (YARA, ClamAV)
6. **Reproducibility** - Second analyst can replicate findings from analysis artifacts

# Reverse Engineering: Firmware Analysis

## What This Skill Does

Extracts and analyzes firmware from IoT devices, routers, and embedded systems:
- **Extraction (30min-2hrs)**: Use binwalk to extract SquashFS/JFFS2/CramFS filesystems
- **Service Analysis (1-3hrs)**: Map init scripts, daemons, network listeners
- **Vulnerability Assessment (1-3hrs)**: Find hardcoded credentials, CVEs, injection points
- **Binary Analysis (1-2hrs)**: Apply Levels 1-4 to extracted binaries

**Timebox**: 2-8 hours total

---

## Prerequisites

### Tools
- **binwalk** - Firmware extraction (`binwalk -Me firmware.bin`)
- **unsquashfs** - SquashFS extraction
- **file** - File type identification
- **QEMU** (optional) - Emulate extracted binaries
- **Jefferson** (optional) - JFFS2 extraction
- **strings** - For string analysis on firmware

### MCP Servers
- `filesystem` - Navigate extracted firmware
- `security-manager` - CVE scanning
- `connascence-analyzer` - Code quality analysis
- `memory-mcp` - Store findings
- `sequential-thinking` - Decision gate for binary analysis

---

## ⚠️ CRITICAL SECURITY WARNING

**NEVER execute firmware binaries or extracted files on your host system!**

All firmware extraction, binary execution, and emulation MUST be performed in:
- **Isolated VM** (VMware/VirtualBox with network isolation and snapshots)
- **Docker container** with strict security policies and no host filesystem access
- **E2B sandbox** via sandbox-configurator skill with monitored execution
- **Firmware analysis environment** (QEMU with `-snapshot`, firmadyne sandbox)

**Consequences of unsafe execution:**
- Backdoor installation and persistent network access
- Extraction of hardcoded credentials compromising related devices
- Malware propagation to development infrastructure
- IoT botnet recruitment (Mirai, Hajime variants)
- Compromise of cloud API keys and services

**Safe Practices:**
- Extract firmware in isolated containers with no network access
- Use QEMU emulation with snapshot mode (`-snapshot` flag)
- Never connect emulated devices to production networks
- Validate extracted credentials in isolated environments only
- Monitor all network connections during firmware emulation
- Treat all IoT firmware as potentially compromised
- Use read-only mounts for extracted filesystems

---

## Quick Start

```bash
# 1. Full firmware analysis
/re:firmware router-firmware.bin

# 2. Extract filesystem only
/re:firmware iot-device.img --extract-only

# 3. Analyze extracted services
/re:firmware camera-fw.bin --analyze-services true

# 4. Extract + analyze specific binary
/re:firmware router.bin --analyze-binary /usr/sbin/httpd
```

---

## Phase 1: Firmware Identification (5-10 minutes)

### Step 1: Basic File Analysis

```bash
# Identify file type
file firmware.bin

# Expected output examples:
# - "firmware.bin: u-boot legacy uImage, MIPS OpenWrt Linux-4.14.63"
# - "firmware.bin: data" (encrypted or compressed)
# - "firmware.bin: Flattened device tree blob (DTB)"
```

### Step 2: Entropy Analysis

Check if firmware is encrypted or compressed:

```bash
# Entropy analysis
binwalk --entropy firmware.bin

# Output visualization:
# High entropy throughout (> 0.9): Likely encrypted
# Low entropy with peaks: Normal firmware with compressed sections
# Uniform low entropy (< 0.5): Uncompressed firmware
```

**Interpretation**:
- **Entropy 0.9-1.0**: Encrypted firmware (need decryption key)
- **Entropy 0.6-0.8**: Compressed sections (normal)
- **Entropy 0.3-0.5**: Uncompressed data

### Step 3: Component Identification

```bash
# Identify firmware components
binwalk --signature firmware.bin

# Expected output:
# DECIMAL       HEXADECIMAL     DESCRIPTION
# --------------------------------------------------------------------------------
# 0             0x0             uImage header, header size: 64 bytes
# 64            0x40            LZMA compressed data
# 1048576       0x100000        Squashfs filesystem, little endian
# 15728640      0xF00000        JFFS2 filesystem, little endian
```

**Components**:
- **Bootloader**: u-boot, Das U-Boot
- **Kernel**: Linux kernel (compressed with LZMA/gzip)
- **Root Filesystem**: SquashFS, JFFS2, CramFS, UBIFS
- **Configuration**: JFFS2 partition for persistent data

---

## Phase 2: Filesystem Extraction (30 minutes - 2 hours)

### Step 1: Automatic Extraction

```bash
# Extract all filesystem components automatically
binwalk --extract --matryoshka firmware.bin

# --extract (-e): Extract identified components
# --matryoshka (-M): Recursively scan extracted files

# Output directory structure:
# _firmware.bin.extracted/
# ├── 0.lzma              # Compressed kernel
# ├── 100000.squashfs     # Root filesystem
# ├── squashfs-root/      # Extracted root filesystem
# └── jffs2-root/         # Extracted configuration partition
```

### Step 2: Verify Extraction

```bash
# Navigate to extracted filesystem
cd _firmware.bin.extracted/squashfs-root/

# Verify critical directories exist
ls -la

# Expected structure:
# drwxr-xr-x  bin/        # Binaries
# drwxr-xr-x  etc/        # Configuration files
# drwxr-xr-x  lib/        # Shared libraries
# drwxr-xr-x  usr/        # User programs
# drwxr-xr-x  www/        # Web interface
# drwxr-xr-x  sbin/       # System binaries
```

### Step 3: Manual Extraction (if automatic fails)

#### For SquashFS:

```bash
# Find SquashFS offset from binwalk
binwalk firmware.bin | grep -i squashfs
# Output: 1048576       0x100000        Squashfs filesystem

# Extract from offset
dd if=firmware.bin bs=1 skip=1048576 of=squashfs.img

# Unsquash manually
unsquashfs -dest ./squashfs-root squashfs.img

# Verify
ls ./squashfs-root/
```

#### For JFFS2:

```bash
# Install jefferson (JFFS2 extractor)
pip install jefferson

# Extract JFFS2
jefferson jffs2.img --dest ./jffs2-root

# Or use firmware-mod-kit
extract-firmware.sh firmware.bin
```

#### For CramFS:

```bash
# Install cramfs tools
sudo apt install cramfsprogs

# Mount (requires root)
sudo mount -t cramfs -o loop cramfs.img /mnt/cramfs

# Or extract
cramfsck -x ./cramfs-root cramfs.img
```

### Step 4: Handle Encrypted Firmware

```bash
# Check entropy
binwalk --entropy firmware.bin

# If high entropy (encrypted):
# 1. Search for decryption keys in vendor documentation
# 2. Check for known encryption schemes (AES, 3DES, RSA)
# 3. Use firmware-mod-kit or binwalk plugins for known devices

# Example: TP-Link firmware decryption
tplink-safeloader -d firmware.bin -o decrypted.bin

# Example: D-Link firmware decryption
binwalk -e --dd='.*' firmware.bin
```

---

## Phase 3: Service Discovery (1-3 hours)

### Step 1: Identify Init System

```bash
# Check for init scripts
ls ./squashfs-root/etc/init.d/

# Common init systems:
# - init.d/ scripts (SysVinit)
# - rc.d/ scripts (BSD-style init)
# - systemd/ units (systemd)
# - procd/ configs (OpenWrt procd)
```

### Step 2: Analyze Startup Services

```bash
# OpenWrt/procd example
cat ./squashfs-root/etc/rc.d/*

# SysVinit example
cat ./squashfs-root/etc/init.d/rcS

# Example output:
# #!/bin/sh
# /usr/sbin/telnetd -l /bin/sh
# /usr/sbin/httpd -p 80 -h /www
# /usr/sbin/dropbear -p 22
```

**Key Services to Map**:
- **telnetd**: Telnet server (port 23)
- **httpd**: Web server (port 80/443)
- **dropbear/sshd**: SSH server (port 22)
- **ftpd**: FTP server (port 21)
- **upnpd**: UPnP daemon
- **dnsmasq**: DNS/DHCP server

### Step 3: Find Network Listeners

```bash
# Search for network binding code
grep -r "0.0.0.0" ./squashfs-root/etc/
grep -r "bind(" ./squashfs-root/usr/sbin/ 2>/dev/null
grep -r "listen(" ./squashfs-root/usr/sbin/ 2>/dev/null

# Search for port numbers
grep -rE ":[0-9]{2,5}" ./squashfs-root/etc/ | grep -E "(80|443|23|22|21)"

# Example findings:
# ./squashfs-root/etc/config/uhttpd:  option listen_http '0.0.0.0:80'
# ./squashfs-root/etc/config/dropbear: option Port '22'
# ./squashfs-root/etc/inetd.conf:telnet stream tcp nowait root /usr/sbin/telnetd
```

### Step 4: Map CGI Scripts and Web Interface

```bash
# Find web root
ls ./squashfs-root/www/
ls ./squashfs-root/usr/www/

# Find CGI scripts (potential injection points)
find ./squashfs-root/www/ -name "*.cgi" -o -name "*.sh"

# Example CGI scripts:
# ./squashfs-root/www/cgi-bin/login.cgi
# ./squashfs-root/www/cgi-bin/admin.cgi
# ./squashfs-root/www/cgi-bin/status.sh

# Analyze for command injection
grep -E "(system|popen|exec)" ./squashfs-root/www/cgi-bin/*.cgi
```

**Output Summary**:
```
Network Services Detected:
- telnetd on 0.0.0.0:23 (CRITICAL: Unauthenticated shell access)
- httpd on 0.0.0.0:80 (Web interface)
- dropbear on 0.0.0.0:22 (SSH with password auth)
- upnpd on 0.0.0.0:1900 (UPnP potential SSRF)

CGI Scripts Found:
- /cgi-bin/admin.cgi (Command injection vulnerable)
- /cgi-bin/login.cgi (Credential check)
- /cgi-bin/upgrade.cgi (Firmware upload)
```

---

## Phase 4: Credential Hunting (30 minutes - 1 hour)

### Step 1: Check Shadow and Passwd Files

```bash
# Unix password files
cat ./squashfs-root/etc/passwd
cat ./squashfs-root/etc/shadow

# Example vulnerable shadow file:
# root:$1$12345678$abcdefghijklmnopqrstuv:0:0:root:/root:/bin/sh
# admin:admin:0:0:admin:/root:/bin/sh  # CRITICAL: Plaintext password!
```

**Common Issues**:
- Empty password hashes (passwordless login)
- Weak/default passwords (admin/admin)
- Hardcoded hashes (crackable)

### Step 2: Search Configuration Files

```bash
# Search for common password keywords
grep -ri "password" ./squashfs-root/etc/ 2>/dev/null
grep -ri "passwd" ./squashfs-root/etc/ 2>/dev/null
grep -ri "pwd" ./squashfs-root/etc/ 2>/dev/null
grep -ri "secret" ./squashfs-root/etc/ 2>/dev/null

# Example findings:
# ./etc/config/wireless: option key 'default_wifi_password_12345'
# ./etc/shadow: root:5up:0:0:root:/root:/bin/sh
# ./etc/config/system: option admin_password 'admin'
```

### Step 3: Find API Keys and Tokens

```bash
# Search for long alphanumeric strings (API keys)
grep -rE "[A-Za-z0-9]{32,}" ./squashfs-root/etc/config/

# Search for common API key patterns
grep -ri "api_key\|token\|secret_key" ./squashfs-root/etc/

# Search for cloud service credentials
grep -ri "aws\|azure\|gcp\|s3" ./squashfs-root/etc/

# Example findings:
# ./etc/cloud-config.json: "api_key": "sk_live_abcdef1234567890"
# ./etc/mqtt.conf: mqtt_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Step 4: Extract SSL Certificates and Private Keys

```bash
# Find SSL certificates
find ./squashfs-root/ -name "*.pem" -o -name "*.key" -o -name "*.crt"

# Example findings:
# ./etc/ssl/private/server.key (CRITICAL: Private key embedded)
# ./etc/ssl/certs/ca.crt

# Check for weak/default keys
openssl rsa -in ./etc/ssl/private/server.key -text -noout

# If key is weak (512-bit RSA), flag as critical
```

**Credential Summary**:
```
Hardcoded Credentials Found:
- Root password: "5up" (plaintext in /etc/shadow)
- Admin password: "admin" (default credentials)
- WiFi password: "default_wifi_password_12345" (weak)
- API key: "sk_live_abcdef..." (exposed in /etc/cloud-config.json)
- SSL private key: /etc/ssl/private/server.key (512-bit RSA, weak)
```

---

## Phase 5: Vulnerability Scanning (1-3 hours)

### Step 1: Identify Library Versions

```bash
# Find shared libraries
ls ./squashfs-root/lib/
ls ./squashfs-root/usr/lib/

# Check library versions
strings ./squashfs-root/lib/libc.so.0 | grep -i version

# Example output:
# OpenSSL 1.0.1e (VULNERABLE: Heartbleed CVE-2014-0160)
# BusyBox v1.24.1 (CHECK: Known CVEs)
# Dropbear 2014.63 (CHECK: Known CVEs)
```

### Step 2: CVE Scanning with MCP

```bash
# Use security-manager MCP for automated CVE scanning
/re:firmware router.bin --cve-scan true
```

**Under the Hood**:

```javascript
// Automatically invoked by skill
const cveResults = await mcp__security-manager__scan_vulnerabilities({
  filesystem_root: "./squashfs-root/",
  library_scan: true,
  cve_database: "nvd",  // National Vulnerability Database
  check_versions: true
})

// Example output:
// {
//   "vulnerabilities": [
//     {
//       "cve": "CVE-2014-0160",
//       "severity": "CRITICAL",
//       "component": "OpenSSL 1.0.1e",
//       "description": "Heartbleed vulnerability allows memory disclosure",
//       "cvss": 7.5
//     },
//     {
//       "cve": "CVE-2019-12345",
//       "severity": "HIGH",
//       "component": "httpd CGI handler",
//       "description": "Command injection via admin.cgi parameter",
//       "cvss": 8.8
//     }
//   ]
// }
```

### Step 3: Manual Vulnerability Assessment

#### Check for Command Injection:

```bash
# Analyze CGI scripts for command injection
grep -E "(system|exec|popen|shell_exec)" ./squashfs-root/www/cgi-bin/*.cgi

# Example vulnerable code in admin.cgi:
# system("ping -c 1 " . $QUERY_STRING);  # CRITICAL: Command injection!
```

#### Check for SQL Injection:

```bash
# Find database queries
grep -rE "(SELECT|INSERT|UPDATE|DELETE)" ./squashfs-root/www/

# Example vulnerable query:
# $query = "SELECT * FROM users WHERE username='" . $_GET['user'] . "'";
```

#### Check for Path Traversal:

```bash
# Find file operations
grep -rE "(fopen|readfile|include)" ./squashfs-root/www/

# Example vulnerable code:
# readfile("/www/" . $_GET['file']);  # Path traversal: ?file=../etc/shadow
```

### Step 4: Check for Backdoors

```bash
# Search for suspicious listening ports
grep -rE "port.*[0-9]{4,5}" ./squashfs-root/etc/

# Search for reverse shell code
grep -rE "(nc.*-e|bash.*>&|/dev/tcp)" ./squashfs-root/

# Search for hidden services
find ./squashfs-root/ -name ".*" -type f

# Check for suspicious cron jobs
cat ./squashfs-root/etc/crontabs/*
```

**Vulnerability Report**:
```
CRITICAL Vulnerabilities:
1. CVE-2014-0160 (Heartbleed) - OpenSSL 1.0.1e
2. Command Injection - admin.cgi (unauthenticated)
3. Hardcoded credentials - root:5up

HIGH Vulnerabilities:
4. Path Traversal - download.cgi
5. Weak SSL certificate - 512-bit RSA key
6. Telnet enabled on 0.0.0.0:23 (no authentication)

MEDIUM Vulnerabilities:
7. Default credentials - admin:admin
8. UPnP enabled (SSRF potential)
9. SQL Injection - login.cgi
```

---

## Phase 6: Binary Analysis (1-2 hours)

After extracting firmware, apply Levels 1-4 to interesting binaries.

### Step 1: Identify Target Binaries

```bash
# Web server binary
ls ./squashfs-root/usr/sbin/httpd

# Telnet daemon
ls ./squashfs-root/usr/sbin/telnetd

# Custom binaries
find ./squashfs-root/usr/bin/ -type f -executable
```

### Step 2: Apply Level 1 (String Analysis)

```bash
# Analyze web server strings
/re:strings ./squashfs-root/usr/sbin/httpd

# Look for:
# - Hardcoded URLs (C2 servers, update servers)
# - Debug messages revealing logic
# - Version strings
# - Hardcoded credentials
```

**Example Output**:
```
Strings Found in httpd:
- "admin:5up" (hardcoded credential)
- "http://firmware-updates.vendor.com/check" (update URL)
- "DEBUG: Command executed: %s" (command injection point)
- "OpenSSL/1.0.1e" (vulnerable version)
```

### Step 3: Apply Level 2 (Static Analysis)

```bash
# Disassemble httpd binary
/re:static ./squashfs-root/usr/sbin/httpd --tool ghidra

# Find critical functions:
# - handle_cgi_request()
# - authenticate_user()
# - execute_command()
```

**Decompiled Code Example** (Ghidra output):

```c
// Function: handle_admin_cgi
void handle_admin_cgi(char *query_string) {
  char command[256];
  char *cmd_param;

  // VULNERABILITY: No input validation!
  cmd_param = get_param(query_string, "cmd");
  sprintf(command, "sh -c '%s'", cmd_param);
  system(command);  // CRITICAL: Command injection!
}
```

### Step 4: Apply Level 3 (Dynamic Analysis) - Optional

```bash
# Emulate binary with QEMU
qemu-mipsel-static ./squashfs-root/usr/sbin/httpd

# Or use full system emulation with firmadyne
firmadyne.sh router-firmware.bin

# Debug with GDB
gdb-multiarch ./squashfs-root/usr/sbin/httpd
(gdb) set architecture mips
(gdb) break handle_admin_cgi
(gdb) run
```

### Step 5: Apply Level 4 (Symbolic Execution) - Advanced

```bash
# Use Angr for symbolic analysis
/re:symbolic ./squashfs-root/usr/sbin/httpd \
  --target-addr 0x401234 \  # execute_command function
  --input-symbolic cmd_param \
  --find-exploits true
```

---

## Comprehensive Workflow Examples

### Workflow 1: Router Firmware Complete Analysis

**Scenario**: Analyze TP-Link router firmware for vulnerabilities

**Step 1: Extraction (30 min)**

```bash
# Download firmware
wget http://vendor.com/TL-WR841N-v14-firmware.bin

# Identify and extract
binwalk -E TL-WR841N-v14-firmware.bin  # Check entropy
binwalk -Me TL-WR841N-v14-firmware.bin # Extract

# Navigate to filesystem
cd _TL-WR841N-v14-firmware.bin.extracted/squashfs-root/
```

**Step 2: Service Discovery (1 hr)**

```bash
# Find init scripts
cat etc/rc.d/S*

# Services found:
# - telnetd on 0.0.0.0:23 (CRITICAL)
# - httpd on 0.0.0.0:80
# - dnsmasq on 0.0.0.0:53

# Map CGI scripts
find www/ -name "*.cgi"

# CGI scripts found:
# - www/cgi-bin/admin.cgi (admin interface)
# - www/cgi-bin/upgrade.cgi (firmware upload)
```

**Step 3: Credential Hunting (15 min)**

```bash
# Check shadow file
cat etc/shadow
# Output: admin:5up:0:0:admin:/root:/bin/sh

# Check config files
grep -ri "password" etc/config/
# Output: option admin_password 'admin'

# CRITICAL: Default credentials admin:5up
```

**Step 4: CVE Scanning (30 min)**

```bash
# Check library versions
strings lib/libc.so.0 | grep version
# OpenSSL 1.0.1e (CVE-2014-0160 Heartbleed)

# Automated CVE scan
/re:firmware TL-WR841N-v14-firmware.bin --cve-scan true

# Results:
# - CVE-2014-0160 (CRITICAL): Heartbleed
# - CVE-2019-12345 (HIGH): Command injection in admin.cgi
```

**Step 5: Binary Analysis (1 hr)**

```bash
# Analyze admin CGI
/re:strings www/cgi-bin/admin.cgi
# Found: "system(sh -c %s)" - command injection

# Static analysis
/re:static www/cgi-bin/admin.cgi --tool ghidra

# Decompiled code shows:
# char *cmd = getenv("QUERY_STRING");
# system(cmd);  # CRITICAL: No sanitization!
```

**Final Report**:

```
TP-Link TL-WR841N Firmware Analysis
====================================

CRITICAL Vulnerabilities:
1. Hardcoded credentials: admin:5up
2. Unauthenticated telnet on port 23
3. Command injection in admin.cgi
4. Heartbleed (CVE-2014-0160) in OpenSSL 1.0.1e

HIGH Vulnerabilities:
5. Weak default WiFi password
6. No CSRF protection on admin interface

Attack Scenario:
1. Telnet to router (no password required)
2. Or exploit command injection: http://router/cgi-bin/admin.cgi?cmd=reboot
3. Gain root shell access

Recommendation: Update to patched firmware version
```

**Time**: 3.25 hours total

---

### Workflow 2: IoT Camera Firmware Security Audit

**Scenario**: Audit Wyze camera firmware for cloud API security

**Step 1: Extraction (45 min)**

```bash
# Extract firmware
binwalk --extract --matryoshka wyze-cam-v3-firmware.bin

# Filesystem type: UBIFS (NAND flash filesystem)
# Manual extraction required
jefferson ubifs.img --dest ./wyze-root/
```

**Step 2: Service Discovery (1.5 hrs)**

```bash
# Find cloud service configuration
grep -ri "api\|cloud\|server" ./wyze-root/etc/

# Found:
# ./etc/cloud-config.json:
# {
#   "api_endpoint": "https://api.wyze.com/v1",
#   "device_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "api_key": "sk_live_abcdef1234567890"
# }

# CRITICAL: Hardcoded API credentials!
```

**Step 3: Analyze Cloud Communication (1 hr)**

```bash
# Find MQTT broker configuration
cat ./wyze-root/etc/mqtt.conf

# Broker: mqtt.wyze.com:8883
# Username: camera-12345
# Password: hardcoded_mqtt_pass

# Analyze cloud binary
/re:strings ./wyze-root/usr/bin/cloud-agent

# Found:
# - "Bearer eyJhbGci..." (hardcoded auth token)
# - "https://firmware-updates.wyze.com/" (update URL)
```

**Step 4: CVE Scan (30 min)**

```bash
# Check libraries
ls ./wyze-root/lib/

# Found vulnerable libraries:
# - libssl.so.1.0.0 (CVE-2014-0160 Heartbleed)
# - libcurl.so.4 (CVE-2020-8231 Remote code execution)
```

**Step 5: Binary Analysis of Cloud Agent (1 hr)**

```bash
# Static analysis
/re:static ./wyze-root/usr/bin/cloud-agent --tool ghidra

# Decompiled authentication function:
void cloud_authenticate() {
  char *token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
  char *api_key = "sk_live_abcdef1234567890";

  http_request("POST", "https://api.wyze.com/v1/auth",
               headers=["Authorization: Bearer " + token]);
}

# CRITICAL: All cameras use same API key!
```

**Final Report**:

```
Wyze Cam v3 Firmware Security Audit
====================================

CRITICAL Vulnerabilities:
1. Hardcoded API credentials shared across all devices
2. Hardcoded JWT token for cloud authentication
3. MQTT credentials in plaintext
4. CVE-2014-0160 (Heartbleed)
5. CVE-2020-8231 (libcurl RCE)

Attack Scenario:
1. Extract API key from firmware
2. Authenticate to Wyze cloud API
3. Access all cameras using same API key
4. Stream/download video from any camera

Impact: Complete compromise of all Wyze cameras using this firmware

Recommendation:
- Implement per-device API keys
- Remove hardcoded credentials
- Update vulnerable libraries
```

**Time**: 4.75 hours total

---

### Workflow 3: Smart Thermostat Firmware - Finding Debug Interface

**Scenario**: Analyze Nest-like thermostat for hidden debug interfaces

**Step 1: Extraction (1 hr)**

```bash
# Encrypted firmware (high entropy)
binwalk --entropy thermostat-firmware.bin
# Entropy: 0.95 (encrypted)

# Search for decryption keys in vendor SDK
find ./vendor-sdk/ -name "*.key" -o -name "*aes*"

# Found: encryption_key.bin
# Decrypt firmware
openssl enc -d -aes-256-cbc -in thermostat-firmware.bin \
  -out decrypted.bin -K $(cat encryption_key.bin)

# Extract decrypted firmware
binwalk --extract --matryoshka decrypted.bin
```

**Step 2: Find Debug Interfaces (30 min)**

```bash
# Search for UART/serial references
grep -ri "uart\|serial\|console" ./squashfs-root/etc/

# Found:
# ./etc/inittab: ttyS0::respawn:/bin/sh  # UART console!

# Search for debug commands
grep -ri "debug\|test\|diag" ./squashfs-root/usr/bin/

# Found debug binary
ls ./squashfs-root/usr/bin/debug-shell
```

**Step 3: Analyze Debug Shell (1 hr)**

```bash
# String analysis of debug shell
/re:strings ./squashfs-root/usr/bin/debug-shell

# Found:
# - "Enter admin password:" (authentication required)
# - "Debug mode enabled"
# - "dump_nvram" (NVRAM dumping command)
# - "factory_reset"

# Static analysis
/re:static ./squashfs-root/usr/bin/debug-shell --tool ghidra

# Decompiled password check:
bool check_debug_password(char *input) {
  char *correct_password = "DebugMode2023";  // Hardcoded!
  return strcmp(input, correct_password) == 0;
}
```

**Step 4: Test Debug Interface (30 min)**

```bash
# Emulate debug shell
qemu-arm-static ./squashfs-root/usr/bin/debug-shell

# Connect to UART console
screen /dev/ttyUSB0 115200

# Enter debug password: DebugMode2023
# Access granted!

# Available debug commands:
# - dump_nvram (dumps all settings including WiFi password)
# - factory_reset (wipes device)
# - enable_telnet (enables telnet on port 23)
```

**Final Report**:

```
Smart Thermostat Debug Interface Analysis
==========================================

CRITICAL Findings:
1. UART console enabled with debug shell access
2. Hardcoded debug password: "DebugMode2023"
3. Debug commands allow full device control
4. NVRAM dump reveals WiFi credentials

Attack Scenario:
1. Open device and connect to UART pins
2. Boot device and access serial console
3. Launch debug-shell
4. Enter password "DebugMode2023"
5. Execute dump_nvram to extract WiFi password
6. Execute enable_telnet for remote access

Impact: Physical access to device = full compromise

Recommendation:
- Disable debug interfaces in production firmware
- Use unique per-device debug passwords
- Implement secure boot to prevent firmware modifications
```

**Time**: 3 hours total

---

## Advanced Options

### Custom Extraction Targets

```bash
# Extract specific filesystem only
/re:firmware router.bin --extract-filesystem squashfs --skip-analysis

# Extract and analyze specific binary
/re:firmware router.bin --analyze-binary /usr/sbin/httpd --level 2

# Extract configuration partition only
/re:firmware router.bin --extract-jffs2-only
```

### Multi-Firmware Analysis

```bash
# Compare multiple firmware versions
/re:firmware router-v1.bin --output ./v1-analysis/
/re:firmware router-v2.bin --output ./v2-analysis/

# Diff analysis
diff -r ./v1-analysis/squashfs-root/ ./v2-analysis/squashfs-root/

# Find newly introduced binaries
diff <(ls ./v1-analysis/squashfs-root/usr/bin/) \
     <(ls ./v2-analysis/squashfs-root/usr/bin/)
```

### Automated Firmware Emulation

```bash
# Use firmadyne for full system emulation
git clone https://github.com/firmadyne/firmadyne
cd firmadyne

# Setup database
./download.sh

# Emulate firmware
./scripts/inferNetwork.sh router-firmware.bin
./scripts/makeImage.sh router-firmware.bin

# Access emulated device
http://192.168.1.1  # Default gateway
telnet 192.168.1.1 23  # Telnet access
```

---

## Troubleshooting

### Issue 1: Encrypted Firmware

**Symptoms**: High entropy (>0.9), binwalk finds no filesystems

**Cause**: Firmware is encrypted

**Solution 1**: Find decryption key

```bash
# Search vendor SDK for keys
find ./vendor-sdk/ -name "*.key" -o -name "*aes*" -o -name "*decrypt*"

# Common key locations:
# - vendor-sdk/tools/encryption_key.bin
# - vendor-docs/firmware-encryption.txt
# - GPL source code archives
```

**Solution 2**: Check for known encryption schemes

```bash
# TP-Link uses custom encryption
tplink-safeloader -d firmware.bin -o decrypted.bin

# D-Link uses AES-256-CBC with known IV
openssl enc -d -aes-256-cbc -in firmware.bin -out decrypted.bin \
  -K <known_key> -iv <known_iv>
```

**Solution 3**: Reverse engineer bootloader

```bash
# Extract bootloader (usually at offset 0)
dd if=firmware.bin bs=1 count=65536 of=bootloader.bin

# Analyze bootloader for decryption routine
/re:static bootloader.bin --tool ghidra

# Look for AES/DES crypto initialization
```

---

### Issue 2: Unable to Extract Filesystem

**Symptoms**: binwalk extraction fails or produces corrupted files

**Cause**: Non-standard filesystem format or compression

**Solution 1**: Try manual extraction with different tools

```bash
# SquashFS variants
unsquashfs -d ./output squashfs.img                # Standard
unsquashfs-lzma -d ./output squashfs.img          # LZMA compressed
jefferson ./output squashfs.img                    # Alternative tool

# JFFS2
jefferson jffs2.img -d ./output

# UBIFS
ubireader_extract_images -o ./output firmware.bin

# CramFS
cramfsck -x ./output cramfs.img
```

**Solution 2**: Use firmware-mod-kit

```bash
# Firmware mod kit supports many formats
git clone https://github.com/rampageX/firmware-mod-kit
cd firmware-mod-kit/src
./configure && make

# Extract
./extract-firmware.sh ../firmware.bin

# Filesystem extracted to ./fmk/rootfs/
```

**Solution 3**: Manual carving

```bash
# Find filesystem magic bytes
binwalk firmware.bin

# Example: SquashFS at offset 0x100000 (1048576)
# Magic: 68 73 71 73 (hsqs)

# Extract from offset to end
dd if=firmware.bin bs=1 skip=1048576 of=filesystem.img

# Try unsquash
unsquashfs filesystem.img
```

---

### Issue 3: Binaries Won't Execute (Architecture Mismatch)

**Symptoms**: "Exec format error" when running extracted binaries

**Cause**: Binary compiled for different architecture (MIPS, ARM, etc.)

**Solution 1**: Identify architecture and use correct QEMU

```bash
# Identify architecture
file ./squashfs-root/usr/sbin/httpd

# Example outputs:
# - "ELF 32-bit LSB executable, MIPS" → Use qemu-mipsel-static
# - "ELF 32-bit LSB executable, ARM" → Use qemu-arm-static
# - "ELF 64-bit LSB executable, ARM aarch64" → Use qemu-aarch64-static

# Run with appropriate QEMU
qemu-mipsel-static ./squashfs-root/usr/sbin/httpd

# Or with chroot
sudo chroot ./squashfs-root qemu-mipsel-static /usr/sbin/httpd
```

**Solution 2**: Full system emulation with QEMU

```bash
# Create QEMU disk image
qemu-img create -f qcow2 firmware.qcow2 1G

# Boot with QEMU
qemu-system-mips -M malta -kernel vmlinux -hda firmware.qcow2 \
  -append "root=/dev/sda1 console=ttyS0" -nographic

# Or use firmadyne (automated)
firmadyne.sh firmware.bin
```

**Solution 3**: Use Docker with QEMU user emulation

```bash
# Docker with multi-arch support
docker run --rm -it --platform linux/arm/v7 \
  -v $(pwd)/squashfs-root:/firmware \
  arm32v7/ubuntu:20.04 bash

# Inside container
cd /firmware
./usr/sbin/httpd
```

---

### Issue 4: CVE Scan Misses Vulnerabilities

**Symptoms**: Known vulnerabilities not detected by automated scan

**Cause**: Version string doesn't match CVE database format

**Solution 1**: Manual version checking

```bash
# Extract version strings
strings ./squashfs-root/lib/libssl.so.1.0.0 | grep -i version

# Output: "OpenSSL 1.0.1e 11 Feb 2013"

# Manually check CVE database
# CVE-2014-0160 affects OpenSSL 1.0.1 - 1.0.1f
# Result: VULNERABLE
```

**Solution 2**: Use multiple CVE scanners

```bash
# Use cve-bin-tool
cve-bin-tool ./squashfs-root/

# Use grype
grype dir:./squashfs-root/

# Use trivy
trivy fs ./squashfs-root/
```

**Solution 3**: Custom signature matching

```bash
# Create custom CVE rules
cat > custom-cve-rules.txt <<EOF
OpenSSL 1.0.1[a-f]: CVE-2014-0160 (Heartbleed)
BusyBox 1.2[0-4]: CVE-2021-28831 (Command injection)
Dropbear 201[0-6]: CVE-2016-7406 (Format string)
EOF

# Scan with custom rules
grep -f custom-cve-rules.txt <(find ./squashfs-root/ -exec strings {} \; 2>/dev/null)
```

---

### Issue 5: Cannot Find Hardcoded Credentials

**Symptoms**: grep searches return no passwords despite expecting them

**Cause**: Credentials encoded/encrypted or stored in binary format

**Solution 1**: Search for encoded strings

```bash
# Base64 encoded credentials
find ./squashfs-root/ -type f -exec grep -l "YWRtaW46YWRtaW4=" {} \;
# (base64 decode: admin:admin)

# Hex encoded
grep -rE "61646d696e" ./squashfs-root/etc/
# (hex decode: admin)

# URL encoded
grep -rE "%61%64%6d%69%6e" ./squashfs-root/
```

**Solution 2**: Search in binaries and databases

```bash
# SQLite databases
find ./squashfs-root/ -name "*.db" -o -name "*.sqlite"
sqlite3 ./etc/config.db "SELECT * FROM users;"

# Binary config files
strings ./squashfs-root/etc/config.bin | grep -i "password\|admin"
```

**Solution 3**: Reverse engineer authentication binary

```bash
# Analyze login binary
/re:static ./squashfs-root/usr/bin/login --tool ghidra

# Decompiled code often reveals credential check:
# if (strcmp(input, "hardcoded_password") == 0) { ... }
```

---

## Performance Optimization

### Speed Up Extraction

```bash
# Parallel extraction (if multiple partitions)
binwalk -e partition1.bin &
binwalk -e partition2.bin &
wait

# Use faster decompression
unsquashfs -p 4 squashfs.img  # 4 parallel threads
```

### Speed Up Service Discovery

```bash
# Parallel grep searches
grep -r "telnetd" ./squashfs-root/etc/ &
grep -r "httpd" ./squashfs-root/etc/ &
grep -r "sshd" ./squashfs-root/etc/ &
wait
```

### Optimize CVE Scanning

```bash
# Skip common false positives
mcp__security-manager__scan_vulnerabilities({
  filesystem_root: "./squashfs-root/",
  skip_binaries: ["busybox", "dropbear"],  # Manually verified
  only_critical: true  # Only report CRITICAL and HIGH
})
```

---

## Memory-MCP Integration

### Storing Firmware Analysis

```javascript
// After firmware extraction completes
mcp__memory-mcp__memory_store({
  content: {
    firmware_hash: "sha256:abc123...",
    device_info: {
      vendor: "TP-Link",
      model: "TL-WR841N",
      version: "v14",
      arch: "MIPS"
    },
    filesystem: {
      type: "squashfs",
      extracted_files: 1247,
      total_size_mb: 8.5
    },
    services: [
      {name: "telnetd", port: 23, auth: false, severity: "CRITICAL"},
      {name: "httpd", port: 80, auth: true, severity: "MEDIUM"},
      {name: "dropbear", port: 22, auth: true, severity: "LOW"}
    ],
    credentials: [
      {type: "root", user: "root", pass: "5up", location: "/etc/shadow"},
      {type: "admin", user: "admin", pass: "admin", location: "/etc/config/system"}
    ],
    vulnerabilities: [
      {cve: "CVE-2014-0160", severity: "CRITICAL", component: "OpenSSL 1.0.1e"},
      {cve: "CVE-2019-12345", severity: "HIGH", component: "httpd command injection"}
    ],
    attack_surface: [
      "Unauthenticated telnet on 0.0.0.0:23",
      "Command injection in /cgi-bin/admin.cgi",
      "Path traversal in /cgi-bin/download.cgi"
    ],
    binary_analysis: {
      analyzed: ["/usr/sbin/httpd", "/www/cgi-bin/admin.cgi"],
      findings: "Command injection confirmed in admin.cgi"
    }
  },
  metadata: {
    agent: "RE-Firmware-Analyst",
    category: "reverse-engineering",
    intent: "firmware-analysis",
    layer: "long_term",
    project: `firmware-analysis-${date}`,
    keywords: ["firmware", "iot", "router", "embedded"],
    re_level: 5,
    firmware_hash: "sha256:abc123...",
    timestamp: new Date().toISOString()
  }
})
```

---

## Agents & Commands

### Agents Invoked

1. **RE-Firmware-Analyst** (Level 5)
   - Specialist: Firmware extraction and IoT security analysis
   - Tools: binwalk, unsquashfs, jefferson, firmadyne, QEMU
   - Output: Extracted filesystem, service map, credential list, CVE report

2. **RE-String-Analyst** (Level 1, for extracted binaries)
   - Applied to extracted binaries for IOC extraction

3. **RE-Disassembly-Expert** (Level 2, for extracted binaries)
   - Applied to extracted binaries for vulnerability analysis

4. **security-manager** (automatic)
   - Performs CVE scanning on extracted libraries

### Slash Commands

- `/re:firmware <firmware>` - Full Level 5 analysis (this skill's primary command)
- `/re:strings <binary>` - Apply to extracted binaries
- `/re:static <binary>` - Apply to extracted binaries

### MCP Servers

- **filesystem**: Navigate extracted firmware directories
- **security-manager**: Automated CVE scanning
- **connascence-analyzer**: Code quality analysis on extracted code
- **memory-mcp**: Cross-session persistence of firmware analysis
- **sequential-thinking**: Decision gates for binary analysis escalation

---

## Related Skills

- [Reverse Engineering: Quick Triage](../reverse-engineering-quick/) - Levels 1-2 (apply to extracted binaries)
- [Reverse Engineering: Deep Analysis](../reverse-engineering-deep/) - Levels 3-4 (apply to extracted binaries)
- [Code Review Assistant](../code-review-assistant/) - Review extracted source code
- [Security Manager](../security-manager/) - Comprehensive vulnerability scanning

---

## Resources

### External Tools

- [binwalk](https://github.com/ReFirmLabs/binwalk) - Firmware extraction
- [firmware-mod-kit](https://github.com/rampageX/firmware-mod-kit) - Firmware modification toolkit
- [firmadyne](https://github.com/firmadyne/firmadyne) - Firmware emulation
- [QEMU](https://www.qemu.org/) - CPU emulator
- [jefferson](https://github.com/sviehb/jefferson) - JFFS2 filesystem extractor

### Learning Resources

- [Firmware Analysis Guide](https://github.com/fkie-cad/firmware-analysis-toolkit) - Comprehensive guide
- [IoT Security Handbook](https://www.iotsecurityhandbook.com/) - IoT security best practices
- [binwalk Usage Guide](https://github.com/ReFirmLabs/binwalk/wiki) - binwalk documentation

### Community

- [r/ReverseEngineering](https://reddit.com/r/ReverseEngineering) - Subreddit
- [IoT Village](https://www.iotvillage.org/) - DEF CON IoT security research
- [Firmware Security Research](https://firmwaresecurity.com/) - Blog and resources

---

**Created**: 2025-11-01
**RE Level**: 5 (Firmware Analysis)
**Timebox**: 2-8 hours
**Category**: IoT Security, Embedded Systems, Firmware Reverse Engineering
**Difficulty**: Advanced
---

## Core Principles

Reverse Engineering: Firmware Analysis operates on 3 fundamental principles:

### Principle 1: Layered Extraction Strategy
Firmware contains multiple nested components (bootloader, kernel, filesystem, configuration) requiring progressive extraction.

In practice:
- Use binwalk entropy analysis to detect encryption before extraction attempts
- Extract filesystems recursively (matryoshka mode) to handle nested archives
- Identify component boundaries with signature scanning (SquashFS, JFFS2, UBIFS magic bytes)
- Manual carving with dd when automatic extraction fails

### Principle 2: Attack Surface Mapping
IoT devices expose attack surfaces through network services, web interfaces, and hardcoded credentials.

In practice:
- Map all network listeners from init scripts (telnetd, httpd, UPnP daemons)
- Analyze CGI scripts for command injection and path traversal vulnerabilities
- Extract credentials from shadow files, configuration databases, and binary strings
- Document firmware update mechanisms for supply chain attack vectors

### Principle 3: Cross-Component Correlation
Vulnerabilities often span multiple firmware components (web interface + binary daemon + kernel module).

In practice:
- Correlate CGI script vulnerabilities with backend binary analysis
- Link hardcoded credentials to service authentication mechanisms
- Validate CVEs across shared libraries (OpenSSL, BusyBox, Dropbear)
- Apply Levels 1-4 binary analysis to extracted executables

---

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Executing firmware binaries on host** | Architecture mismatch (MIPS/ARM), potential backdoors, system compromise | Use QEMU user-mode emulation or full system emulation with firmadyne |
| **Ignoring encrypted firmware** | Incomplete analysis, missed vulnerabilities, false sense of security | Search vendor SDKs for decryption keys, reverse bootloader crypto routines, check known device decryption schemes |
| **Skipping service discovery** | Miss network-exposed attack surfaces (unauthenticated telnet, vulnerable CGI) | Analyze init scripts, grep for bind/listen calls, map network listeners to binaries |
| **Not validating extraction** | Corrupted filesystems, missing files, incomplete analysis | Verify critical directories exist (/bin, /etc, /lib, /www), check file counts match expectations |
| **Sharing raw credentials publicly** | Legal liability, compromise of related devices, customer privacy violation | Redact internal IPs, sanitize credentials before publishing IOCs, use secure disclosure channels |

---

## Conclusion

Reverse Engineering: Firmware Analysis is the gateway to understanding the security posture of billions of IoT and embedded devices deployed worldwide. By systematically extracting filesystems, mapping network services, hunting for hardcoded credentials, and scanning for CVEs, this skill reveals the critical vulnerabilities that make IoT devices prime targets for botnet recruitment and supply chain attacks.

The skill's value extends beyond individual device analysis - findings apply to entire product lines sharing the same firmware base. A single extracted default password or command injection vulnerability can compromise thousands of devices. Combined with Level 1-4 binary analysis of extracted executables, this skill enables comprehensive security assessments from bootloader to application layer.

Use this skill when analyzing router firmware before deployment, auditing smart home devices for privacy concerns, or conducting vulnerability research on embedded systems. The 2-8 hour timebox makes it suitable for both targeted security audits and large-scale IoT security research programs. Integration with memory-mcp enables cross-firmware correlation to identify common vulnerabilities across vendors, accelerating IoT security research at scale.