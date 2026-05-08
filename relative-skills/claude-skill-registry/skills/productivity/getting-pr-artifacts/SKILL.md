---
name: getting-pr-artifacts
description: Use when needing workflow artifacts from PR - runs in subagent to find jobs with artifacts, returns gh commands to download them without consuming context
---

# Getting PR Artifacts

## Overview

Find workflow jobs that produced artifacts and provide commands to download them.

**Core principle:** Return download commands, not artifacts themselves. Artifacts can be large (100MB+).

**REQUIRED BACKGROUND:** Use `awaiting-pr-workflows` first to ensure workflows are complete.

## When to Use

Use when you need:
- List of available artifacts from PR workflows
- Commands to download specific artifacts
- Info about artifact contents (name, size)

**When NOT to use:**
- Workflows still running (use `awaiting-pr-workflows`)
- Need to actually download/analyze artifacts (use returned commands)

## Workflow

### Step 1: Get Workflow Runs for PR

```bash
# Get PR commit
PR_COMMIT=$(gh pr view $PR_NUM --json headRefOid -q '.headRefOid')

# Get runs for this commit
gh run list --commit $PR_COMMIT --json databaseId,name,conclusion
```

### Step 2: Check Each Run for Artifacts

```bash
RUN_ID=<from step 1>

# List artifacts for this run
gh run view $RUN_ID --json artifacts --jq '.artifacts[] | {
  name: .name,
  size: .size_in_bytes,
  expired: .expired,
  id: .id
}'
```

### Step 3: Build Download Commands

For each artifact, provide:
- Artifact name and size
- Which job/run it's from
- `gh` command to download
- Suggested extraction commands (if zip/tar)

## Return Format

```markdown
PR #{number} Workflow Artifacts (commit {sha}):

## Available Artifacts

### Run: iOS Test (id: 19727163744)

#### 1. ios-e2e-test-results (24.3 MB)
**Download:**
```bash
gh run download 19727163744 -n ios-e2e-test-results -D /tmp/ios-artifacts
```

**Contents:** Likely xcresult bundle, screenshots, logs

**Extract/Analyze:**
```bash
# List contents
ls -lh /tmp/ios-artifacts/

# If it's a zip:
unzip -l /tmp/ios-artifacts/ios-e2e-test-results.zip

# For xcresult bundles (iOS-specific):
# See the 'using-ios-xcresult-artifacts' skill
```

#### 2. test-coverage-report (1.2 MB)
**Download:**
```bash
gh run download 19727163744 -n test-coverage-report -D /tmp/coverage
```

**Contents:** HTML coverage report

**View:**
```bash
open /tmp/coverage/index.html
```

### Run: Backend Test (id: 19727163743)

*No artifacts produced*

---

**Summary:** 2 artifacts available (25.5 MB total)
**List all:** `gh run list --commit {sha} | while read id; do gh run view $id --json artifacts; done`
```

## Common Artifact Types

### iOS/Xcode Artifacts
- `*.xcresult` - Test results bundle (use `using-ios-xcresult-artifacts` skill)
- `*.app` - Application bundle
- `*.ipa` - iOS app package
- `screenshots/` - UI test screenshots

### Test Artifacts
- `coverage/` - Code coverage reports (HTML/XML)
- `test-results.xml` - JUnit test results
- `*.log` - Test execution logs

### Build Artifacts
- `dist/` - Built application files
- `*.tar.gz` - Compressed build outputs
- `build-logs/` - Compilation logs

## Download Strategies

### Download Single Artifact
```bash
# By name
gh run download $RUN_ID -n artifact-name -D /destination

# All artifacts from run
gh run download $RUN_ID -D /destination
```

### Download to Specific Location
```bash
# Project-local (in .gitignore)
gh run download $RUN_ID -n ios-results -D .artifacts/

# System temp (cleaned automatically)
gh run download $RUN_ID -n ios-results -D /tmp/pr-artifacts/

# User's Downloads
gh run download $RUN_ID -n ios-results -D ~/Downloads/
```

### Check Before Downloading Large Files
```bash
# Get size first
SIZE=$(gh api repos/{owner}/{repo}/actions/runs/$RUN_ID/artifacts \
  --jq '.artifacts[] | select(.name == "ios-results") | .size_in_bytes')

# Convert to MB
SIZE_MB=$((SIZE / 1024 / 1024))
echo "Artifact is ${SIZE_MB}MB"

# Ask user if > 50MB
if [ $SIZE_MB -gt 50 ]; then
  echo "Large artifact. Proceed? (y/n)"
fi
```

## Example Implementation

```bash
#!/bin/bash
# Run in subagent

PR_NUM=$1
PR_COMMIT=$(gh pr view $PR_NUM --json headRefOid -q '.headRefOid')
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')

# Get all runs
RUN_IDS=$(gh run list --commit $PR_COMMIT --json databaseId -q '.[].databaseId')

# For each run, check for artifacts
for RUN_ID in $RUN_IDS; do
  RUN_NAME=$(gh run view $RUN_ID --json name -q '.name')

  ARTIFACTS=$(gh api "repos/$REPO/actions/runs/$RUN_ID/artifacts" \
    --jq '.artifacts[] | {name: .name, size: .size_in_bytes}')

  if [ -n "$ARTIFACTS" ]; then
    echo "## Run: $RUN_NAME (id: $RUN_ID)"
    echo "$ARTIFACTS" | jq -r '"### \(.name) (\(.size / 1024 / 1024 | floor)MB)"'
    echo "Download: gh run download $RUN_ID -n {name} -D /tmp/artifacts"
  fi
done
```

## Common Mistakes

**Downloading artifacts in main context**
- **Problem:** Wastes tokens, slows down session
- **Fix:** Return commands, let user decide what to download

**Not checking artifact size**
- **Problem:** Downloads 500MB file unexpectedly
- **Fix:** Always show size, warn if large

**Not suggesting next steps**
- **Problem:** User has artifacts but doesn't know what to do
- **Fix:** Include extraction/viewing commands for common types

## Quick Reference

| Task | Command |
|------|---------|
| List artifacts for run | `gh run view $RUN_ID --json artifacts` |
| Download by name | `gh run download $RUN_ID -n name -D path` |
| Download all from run | `gh run download $RUN_ID -D path` |
| Get artifact metadata | `gh api repos/{owner}/{repo}/actions/runs/$RUN_ID/artifacts` |
| List all for commit | `gh run list --commit $SHA` then check each |

## Integration with Other Skills

**For xcresult bundles:** After downloading iOS test artifacts, use the `using-ios-xcresult-artifacts` skill to analyze them.

**For logs in artifacts:** If logs are packaged in artifacts rather than workflow logs, download first then analyze locally.

## Use Subagents

**CRITICAL:** Always run in subagent.

```
Use Task tool with subagent_type='general-purpose'.
Give them this skill and the PR number.
They return artifact list + download commands.
```

**Why:** Prevents downloading large files into context. Main agent gets commands and can selectively download.
