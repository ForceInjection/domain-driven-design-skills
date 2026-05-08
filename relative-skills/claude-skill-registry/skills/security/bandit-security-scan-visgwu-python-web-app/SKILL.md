---
name: bandit-security-scan
description: Run Bandit security analysis to find common security issues and vulnerabilities in Python code. Use when the user mentions Bandit, security analysis, vulnerability scanning, security audit, software composition analysis (SCA), or wants to check for security issues in Python code.
allowed-tools: Bash, Read, Grep, Write
---

# Bandit Security Scanner

This skill runs Bandit security analysis on your Python codebase to identify common security vulnerabilities, insecure coding patterns, and potential risks.

## When to Use This Skill

Use this skill when you need to:
- Run a Bandit security scan
- Find security vulnerabilities in Python code
- Perform software composition analysis (SCA)
- Conduct security audits
- Check for insecure coding practices
- Identify potential security risks
- Scan for common security issues (SQL injection, XSS, hardcoded passwords, etc.)

## Prerequisites

Before running a scan, ensure:
1. Python and pip are installed
2. Project contains Python (.py) files
3. Optional: Create a `.bandit` configuration file for custom settings

## How to Run a Scan

### Windows (PowerShell)

Run the PowerShell script:
```bash
powershell.exe -ExecutionPolicy Bypass -File .claude/skills/bandit/scripts/run_bandit_scan.ps1
```

### Linux/Mac (Bash)

Run the bash script:
```bash
bash .claude/skills/bandit/scripts/run_bandit_scan.sh
```

## What the Scan Does

1. **Installs Bandit** - Automatically installs Bandit with all optional features (TOML, SARIF, baseline support)
2. **Analyzes Python files** - Recursively scans all Python files in the project
3. **Detects vulnerabilities** - Identifies security issues including:
   - SQL injection vulnerabilities
   - Hardcoded passwords and secrets
   - Use of insecure functions
   - Shell injection risks
   - Weak cryptography
   - Insecure deserialization
   - Path traversal vulnerabilities
   - And many more security issues
4. **Generates reports** - Creates multiple output formats:
   - Human-readable console output
   - JSON report for machine processing
   - HTML report for easy viewing
   - SARIF format for IDE/tool integration

## Understanding Results

Bandit categorizes findings by:

### Severity Levels
- **HIGH**: Critical security issues requiring immediate attention
- **MEDIUM**: Moderate security concerns
- **LOW**: Minor issues or informational findings

### Confidence Levels
- **HIGH**: Very likely to be a real security issue
- **MEDIUM**: Probable security issue
- **LOW**: Possible issue requiring manual review

## Report Locations

After the scan completes, find reports at:
- `bandit-report.json` - JSON format for automation
- `bandit-report.html` - HTML format for viewing in browser
- Console output - Immediate feedback with issue details

## Quick Actions

After scanning:
1. Review HIGH severity issues first
2. Check issues with HIGH confidence
3. Fix critical vulnerabilities immediately
4. Use `# nosec` comments to suppress false positives (with caution)
5. Re-run scan to verify fixes

For detailed configuration options and advanced usage, see [REFERENCE.md](REFERENCE.md).

## Troubleshooting

**Issue: Bandit installation fails**
- Check your Python and pip installation
- Ensure internet connectivity
- Try manually: `pip install bandit[toml,sarif,baseline]`

**Issue: Too many false positives**
- Create a `.bandit` configuration file (see templates/)
- Use `skips` option to exclude specific test IDs
- Add `# nosec` comments to suppress individual lines

**Issue: Scan too slow**
- Exclude test directories and virtual environments
- Use `.bandit` config to specify only source directories
- Consider scanning only changed files

## Next Steps After Scanning

1. Review the HTML report in your browser
2. Prioritize fixes by severity and confidence
3. Address hardcoded secrets immediately
4. Update insecure dependencies
5. Integrate Bandit into your CI/CD pipeline
6. Set up pre-commit hooks for automatic scanning
