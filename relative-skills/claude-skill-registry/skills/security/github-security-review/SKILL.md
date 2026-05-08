---
name: github-security-review
description: Analyze GitHub repository security alerts and generate remediation plans. Use when the user asks to review security alerts, fix vulnerabilities, check dependabot alerts, review code scanning issues, or address secret scanning findings for a GitHub repository. Triggers on requests mentioning GitHub security, repo security review, vulnerability remediation, or security audit.
---

# GitHub Security Review

Analyze GitHub security alerts (Code Scanning, Dependabot, Secret Scanning) and generate actionable remediation plans with specific code fixes.

## Prerequisites

Requires `gh` CLI and `jq`. Verify before running:

```bash
gh auth status  # Must be authenticated
jq --version    # Must be installed
```

If gh not installed: https://cli.github.com/
If gh not authenticated: `gh auth login`
If jq not installed: `brew install jq` / `apt install jq`

## Workflow

When a user asks to review security for a repository, follow these steps:

### Step 1: Verify Prerequisites
```bash
gh auth status
jq --version
```

### Step 2: Fetch Security Data
Run the fetch script to get all security alerts as JSON:
```bash
./scripts/fetch.sh <owner/repo> | python3 scripts/analyze.py --json
```

Use `--json` output so you can analyze the raw data yourself.

### Step 3: Analyze and Provide Remediation

After getting the JSON data, **you must analyze each issue and provide specific remediation**:

#### For Dependabot Alerts:
1. Identify the vulnerable packages and versions
2. Check what the patched version is
3. Provide the exact upgrade command for the ecosystem
4. If it's a major version upgrade, warn about potential breaking changes
5. Offer to check the package changelog for migration notes

#### For Code Scanning Alerts:
1. Read the affected files at the reported line numbers
2. Understand the security issue (SQL injection, XSS, etc.)
3. Provide a **specific code fix** - not generic advice
4. Explain why the current code is vulnerable
5. Show the corrected code that resolves the issue

#### For Secret Scanning Alerts:
1. Identify the type of secret exposed
2. Provide service-specific rotation instructions:
   - **AWS keys**: Use IAM console to rotate, update ~/.aws/credentials
   - **GitHub tokens**: Settings → Developer settings → Revoke and regenerate
   - **API keys**: Go to the service's dashboard to rotate
3. Help remove the secret from git history if needed
4. Suggest using environment variables or a secrets manager

### Step 4: Generate Actionable Report

Present findings in this format:

```markdown
# Security Review: {repository}

## Summary
| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| ... | ... | ... | ... | ... |

## Critical Issues (Fix Immediately)

### Issue 1: {vulnerability name}
**File:** `path/to/file.js:42`
**Severity:** Critical
**Problem:** {explain the vulnerability}

**Current vulnerable code:**
```{language}
// the actual code from the file
```

**Fixed code:**
```{language}
// your corrected version
```

**Why this fixes it:** {explanation}

---

## High Priority Issues
...

## Recommended Actions
1. {specific action with command}
2. {specific action with command}
...
```

## Important Guidelines

1. **Always read the actual source files** before suggesting fixes for code scanning issues
2. **Provide copy-paste ready commands** for dependency updates
3. **Prioritize by severity** - Critical and High first
4. **Explain the risk** of each vulnerability in plain terms
5. **Offer to apply fixes** if the user wants you to edit the files directly
6. **Check for breaking changes** when suggesting major version upgrades

## Error Handling

If fetch.sh returns empty arrays `[]` for an alert type:
- Feature may not be enabled for this repo → Enable in repo Settings > Security
- Insufficient permissions → User needs Security alerts read access
- No alerts exist (good news!)

## Example Interaction

**User:** "Review security for my-org/my-repo"

**You should:**
1. Run `./scripts/fetch.sh my-org/my-repo | python3 scripts/analyze.py --json`
2. Parse the JSON output
3. For each vulnerability:
   - Read the affected file if it's a code issue
   - Provide specific fix with actual code
4. Present prioritized remediation plan
5. Ask: "Would you like me to apply any of these fixes?"
