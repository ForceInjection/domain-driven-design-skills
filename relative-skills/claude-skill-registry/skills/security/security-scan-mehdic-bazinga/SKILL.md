---
name: security-scan
description: "Run comprehensive security vulnerability scans when reviewing code. Automatically uses basic mode (fast, high/medium severity only) for first reviews, advanced mode (comprehensive, all severities) for iterations. Detects SQL injection, XSS, hardcoded secrets, insecure dependencies. Use before approving any code changes or pull requests."
version: 1.0.0
allowed-tools: [Bash, Read]
---

# Security Scanning Skill

You are the security-scan skill. When invoked, you run appropriate security scanners based on project language and provide structured security reports.

## When to Invoke This Skill

**Invoke this skill when:**
- Tech Lead is reviewing code changes
- Before approving pull requests
- Security-sensitive code modified (auth, database, API endpoints)
- Before deployment to production
- Reviewing dependencies or third-party code

**Do NOT invoke when:**
- Documentation-only changes
- Test file changes only
- Non-code changes (README, config, .gitignore)
- Work-in-progress drafts not ready for review

---

## Your Task

When invoked:
1. Execute the security scan script
2. Read the generated security report
3. Return a summary to the calling agent

---

## Step 1: Execute Security Scan Script

Use the **Bash** tool to run the pre-built security scanning script.

**On Unix/macOS:**
```bash
bash .claude/skills/security-scan/scripts/scan.sh
```

**On Windows (PowerShell):**
```powershell
pwsh .claude/skills/security-scan/scripts/scan.ps1
```

> **Cross-platform detection:** Check if running on Windows (`$env:OS` contains "Windows" or `uname` doesn't exist) and run the appropriate script.

The script automatically determines scan mode:
- **Basic mode** (default): Fast scan, high/medium severity only (5-10 seconds)
- **Advanced mode**: Comprehensive scan, all severities (30-60 seconds)

Mode selection is controlled by `SECURITY_SCAN_MODE` environment variable (set by Tech Lead based on revision count).

The script will:
- Detect project language (Python, JavaScript, Go, Ruby, Java)
- Run appropriate security scanner (bandit, npm audit, gosec, brakeman, spotbugs)
- Parse results and categorize by severity
- Generate `bazinga/artifacts/{SESSION_ID}/skills/security_scan.json`

---

## Step 2: Read Generated Report

Use the **Read** tool to read:

```bash
bazinga/artifacts/{SESSION_ID}/skills/security_scan.json
```

Extract key information:
- `scan_mode` - Basic or advanced
- `status` - success/partial/error
- `critical_issues`, `high_issues`, `medium_issues` - Issue counts
- `issues` - Array of security findings with file/line/recommendation

---

## Step 3: Return Summary

Return a concise summary to the calling agent:

```
Security Scan Report ({mode} mode):
- Tool: {tool_name}
- Critical issues: {count}
- High issues: {count}
- Medium issues: {count}

{If issues found:}
Top issues:
1. {severity}: {issue title} ({file}:{line})
2. {severity}: {issue title} ({file}:{line})
3. {severity}: {issue title} ({file}:{line})

Details saved to: bazinga/artifacts/{SESSION_ID}/skills/security_scan.json
```

---

## Example Invocation

**Scenario: First Review (Basic Mode)**

Input: Tech Lead reviewing auth changes before deployment

Expected output:
```
Security Scan Report (basic mode):
- Tool: bandit
- Critical issues: 0
- High issues: 2
- Medium issues: 5

Top issues:
1. HIGH: SQL injection risk (auth.py:45)
2. HIGH: Hardcoded secret detected (config.py:12)
3. MEDIUM: Weak random number generation (token.py:89)

Details saved to: bazinga/artifacts/{SESSION_ID}/skills/security_scan.json
```

**Scenario: Persistent Issues (Advanced Mode)**

Input: Tech Lead reviewing after 2nd revision

Expected output:
```
Security Scan Report (advanced mode):
- Tool: bandit + semgrep
- Critical issues: 1
- High issues: 3
- Medium issues: 8
- Low issues: 12

Top issues:
1. CRITICAL: Remote code execution vulnerability (upload.py:156)
2. HIGH: Authentication bypass possible (middleware.py:78)
3. HIGH: XSS vulnerability in user input (forms.py:45)

Details saved to: bazinga/artifacts/{SESSION_ID}/skills/security_scan.json
```

---

## Error Handling

**If security tool not installed:**
- Script attempts auto-installation
- Falls back gracefully if installation fails
- Returns error with installation instructions

**If scan fails:**
- Check `status` field in report (will be "error" or "partial")
- Empty issues array with status="error" means scan FAILED, not that code is secure
- Return error details to calling agent

**If no issues found:**
- Return successful report with 0 issues
- Status: "success"

---

## Notes

- The script (446+ lines) handles all language detection, tool installation, and scanning
- Supports both bash (Linux/Mac) and PowerShell (Windows)
- Basic mode prioritizes speed, advanced mode prioritizes thoroughness
- Always check the `status` field before interpreting results
- Tools may produce false positives - findings should be reviewed by humans
