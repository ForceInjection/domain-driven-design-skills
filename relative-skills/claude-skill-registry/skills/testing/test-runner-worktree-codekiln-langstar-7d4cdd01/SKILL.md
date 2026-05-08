---
name: test-runner-worktree
description: Run Rust cargo tests properly in git worktrees with environment variable sourcing. Use when cargo test fails, when seeing authentication errors, when test results differ between runs, or before running pre-commit checks in worktrees. Essential for integration tests requiring LANGSMITH_API_KEY or ANTHROPIC_API_KEY.
scope: project
---

# Test Runner for Worktrees

Guide for running integration tests properly in both git worktrees and the main repository, with emphasis on environment variable sourcing and working directory context.

## ⚠️ CRITICAL FIRST STEP: Source Environment Variables

**Before running ANY tests, pre-commit checks, or cargo commands in a worktree, ALWAYS source environment variables:**

```bash
source /workspace/.devcontainer/.env
```

**Why this matters:**
- Integration tests require `LANGSMITH_API_KEY` and other credentials
- **Pre-commit checks** (`cargo test`, `cargo clippy`, etc.) will fail without proper environment
- Worktrees do NOT automatically inherit environment variables from the main workspace
- Tests will fail with authentication errors or panics if variables are missing
- This was the root cause of test failures in issue #232

**This applies to:**
- ✅ `cargo test` - Any test command
- ✅ **Pre-commit checks** - The full `cargo fmt && cargo check && cargo clippy && cargo test` suite
- ✅ `cargo clippy` - Linting may trigger tests
- ✅ `cargo build` - Build may run build scripts that need credentials
- ✅ Any cargo command that might run tests or build scripts

**Quick Check:**
```bash
# Verify environment variables are set
[ -n "$LANGSMITH_API_KEY" ] && echo "✓ Ready to test" || echo "✗ Run: source /workspace/.devcontainer/.env"
```

**Quick Start for Pre-Commit Checks:**
```bash
# One command to source and run full pre-commit suite
source /workspace/.devcontainer/.env && cargo fmt && cargo check --workspace --all-features && cargo clippy --workspace --all-features -- -D warnings && cargo test --workspace --all-features && cargo fmt --check
```

## Overview

During development in git worktrees, running tests requires careful attention to:
1. **Environment variables** - MUST be sourced from `/workspace/.devcontainer/.env` before testing
2. **Working directory** - Tests may behave differently in main vs worktree due to SDK version differences
3. **Context awareness** - Understanding whether you're in main workspace or a feature branch worktree

This skill codifies the lessons learned from issues #186 and #232 to prevent future confusion and wasted time.

## Key Principles

### 1. Always Check Environment Variables First

**Problem:** Repeatedly asking users for credentials when they're already available in the environment.

**Solution:** Check if environment variables are set BEFORE asking the user.

```bash
# ✅ CORRECT: Check without exposing values
[ -n "$LANGSMITH_API_KEY" ] && echo "LANGSMITH_API_KEY is set" || echo "LANGSMITH_API_KEY not set"
[ -n "$ANTHROPIC_API_KEY" ] && echo "ANTHROPIC_API_KEY is set" || echo "ANTHROPIC_API_KEY not set"
```

**If not set, source from devcontainer:**
```bash
# Source devcontainer environment file
source /workspace/.devcontainer/.env

# Verify variables are now set
[ -n "$LANGSMITH_API_KEY" ] && echo "LANGSMITH_API_KEY is set" || echo "LANGSMITH_API_KEY not set"
```

**Never expose actual values:**
```bash
# ❌ WRONG: Exposes sensitive data
echo "LANGSMITH_API_KEY=$LANGSMITH_API_KEY"

# ✅ CORRECT: Checks without exposing
[ -n "$LANGSMITH_API_KEY" ] && echo "Set" || echo "Not set"
```

### 2. Always Verify Current Working Directory

**Problem:** Running tests from the wrong directory leads to unexpected failures and confusion.

**Key Difference:** Tests run from worktrees use the feature branch SDK, while tests from main workspace use the main branch SDK.

**Example from #186:**
- Background tests ran from `/workspace` (main branch) → **FAILED** (old SDK without `Queued` enum)
- Worktree tests ran from `/workspace/wip/codekiln-186-test-helpers` → **PASSED** (new SDK with `Queued` from PR #185)

**Solution:** Always verify working directory before running tests.

```bash
# ✅ CORRECT: Verify and navigate to worktree
pwd
cd /workspace/wip/<worktree-name>

# Run tests from worktree
cargo test --test integration_test -- --ignored --nocapture
```

### 3. Understand Test Types and Their Requirements

Different tests have different requirements and durations:

**Unit Tests (No API Required):**
```bash
# Fast (<1 second), no credentials needed
cargo test --test integration_deployment_workflow test_deployment_url_extraction -- --nocapture
```

**Helper Tests (API Required, 1-5 seconds):**
```bash
# Require credentials, fast feedback
cargo test --test integration_deployment_workflow test_list_github_integrations -- --ignored --nocapture
cargo test --test integration_deployment_workflow test_list_github_repositories -- --ignored --nocapture
cargo test --test integration_deployment_workflow test_find_integration_for_repo -- --ignored --nocapture
```

**Full Workflow Tests (5-30 minutes):**
```bash
# Long-running, creates real resources
cargo test --test integration_deployment_workflow test_deployment_workflow -- --ignored --nocapture
```

## Workflows

### Workflow 1: Run Tests in Worktree (Recommended)

When working on a feature branch in a worktree, always run tests from the worktree directory.

**Steps:**

```bash
# Step 1: Navigate to worktree
cd /workspace/wip/<worktree-name>

# Step 2: Source environment variables (CRITICAL - do this first!)
source /workspace/.devcontainer/.env

# Step 3: Verify you're in the correct location
pwd
# Should output: /workspace/wip/<worktree-name>

# Step 4: Verify environment variables are loaded
[ -n "$LANGSMITH_API_KEY" ] && echo "✓ LANGSMITH_API_KEY is set" || echo "✗ LANGSMITH_API_KEY not set"

# Step 5: Run tests
# For unit tests (no API)
cargo test --test integration_deployment_workflow test_deployment_url_extraction -- --nocapture

# For helper tests (fast, require API)
cargo test --test integration_deployment_workflow test_list_github_integrations -- --ignored --nocapture

# For full workflow tests (slow, require API)
cargo test --test integration_deployment_workflow test_deployment_workflow -- --ignored --nocapture
```

**Why this matters:**
- Worktree has the feature branch code
- Feature branch may have SDK changes not in main
- Tests will use the correct SDK version

### Workflow 2: Run Tests in Main Workspace

When testing against the main/release branch SDK, run from main workspace.

**Steps:**

```bash
# Step 1: Navigate to main workspace
cd /workspace

# Step 2: Verify branch
git branch --show-current
# Should output: main (or release/vX.Y.Z)

# Step 3: Check environment variables
[ -n "$LANGSMITH_API_KEY" ] && echo "LANGSMITH_API_KEY is set" || echo "LANGSMITH_API_KEY not set"

# Step 4: Run tests
cargo test --workspace --all-features
```

### Workflow 3: Pre-Commit Testing

Before committing, run all checks from the worktree.

**Steps:**

```bash
# From worktree directory
cd /workspace/wip/<worktree-name>

# CRITICAL: Source environment variables first!
source /workspace/.devcontainer/.env

# Run pre-commit checklist
cargo fmt
cargo check --workspace --all-features
cargo clippy --workspace --all-features -- -D warnings
cargo test --workspace --all-features
cargo fmt --check
```

**Why from worktree:**
- Tests your feature branch changes
- Catches issues before CI
- Prevents wasted CI cycles

## Common Mistakes to Avoid

### ❌ Mistake 1: Running Pre-Commit Checks Without Sourcing Environment

**Wrong approach:**
```bash
# Running pre-commit checks immediately in worktree without sourcing
cd /workspace/wip/<worktree-name>
cargo fmt && cargo check --workspace --all-features && cargo clippy --workspace --all-features -- -D warnings && cargo test --workspace --all-features && cargo fmt --check
# Tests will fail with "byte index out of bounds" or authentication errors
```

**Symptom:** Tests fail with cryptic errors like:
- `byte index 8 is out of bounds of \`\``
- `thread 'main' panicked at cli/src/commands/prompt.rs:183:52`
- Authentication failures in integration tests

**Correct approach:**
```bash
# ALWAYS source environment variables FIRST in worktrees
cd /workspace/wip/<worktree-name>
source /workspace/.devcontainer/.env
cargo fmt && cargo check --workspace --all-features && cargo clippy --workspace --all-features -- -D warnings && cargo test --workspace --all-features && cargo fmt --check
```

**Why this happens:**
- Worktrees don't inherit environment variables from main workspace
- Tests that require credentials fail without `LANGSMITH_API_KEY`
- Some tests read empty environment variables and panic on string operations
- This is the #1 cause of mysterious test failures in worktrees

### ❌ Mistake 2: Asking User for Credentials When Already Set

**Wrong approach:**
```bash
# Don't ask user to provide credentials without checking first
echo "Please provide your LANGSMITH_API_KEY"
```

**Correct approach:**
```bash
# Check first
if [ -z "$LANGSMITH_API_KEY" ]; then
  # Try sourcing from devcontainer
  source /workspace/.devcontainer/.env

  # If still not set, then ask
  if [ -z "$LANGSMITH_API_KEY" ]; then
    echo "LANGSMITH_API_KEY not found. Please set it in /workspace/.devcontainer/.env"
  fi
fi
```

### ❌ Mistake 3: Running Tests from Wrong Directory

**Wrong approach:**
```bash
# Running from main workspace when working on feature branch
cd /workspace
cargo test --test integration_deployment_workflow -- --ignored
# May fail due to old SDK version in main branch
```

**Correct approach:**
```bash
# Always verify pwd first
pwd
cd /workspace/wip/codekiln-186-test-helpers
cargo test --test integration_deployment_workflow -- --ignored
```

### ❌ Mistake 4: Exposing Sensitive Environment Variables

**Wrong approach:**
```bash
# Never expose actual values
echo "LANGSMITH_API_KEY=$LANGSMITH_API_KEY"
echo "Using key: ${LANGSMITH_API_KEY}"
```

**Correct approach:**
```bash
# Only check if set, never show value
[ -n "$LANGSMITH_API_KEY" ] && echo "LANGSMITH_API_KEY is set" || echo "LANGSMITH_API_KEY not set"
```

### ❌ Mistake 5: Not Understanding Test Context

**Wrong approach:**
```bash
# Running background tests from main workspace while developing in worktree
cd /workspace
cargo test --test integration_test -- --ignored &
# This will test old SDK from main, not your changes
```

**Correct approach:**
```bash
# Run from worktree to test your changes
cd /workspace/wip/<worktree-name>
cargo test --test integration_test -- --ignored
```

## Environment Variable Reference

### Required Variables for Integration Tests

**LangSmith API:**
- `LANGSMITH_API_KEY` - API key for LangSmith authentication
- `LANGSMITH_ORGANIZATION_ID` - Organization ID (optional, auto-detected)

**Anthropic API:**
- `ANTHROPIC_API_KEY` - API key for Claude models

### Checking Variables (Template)

```bash
# Check all required variables at once
echo "Checking required environment variables..."
[ -n "$LANGSMITH_API_KEY" ] && echo "✓ LANGSMITH_API_KEY is set" || echo "✗ LANGSMITH_API_KEY not set"
[ -n "$ANTHROPIC_API_KEY" ] && echo "✓ ANTHROPIC_API_KEY is set" || echo "✗ ANTHROPIC_API_KEY not set"

# Source from devcontainer if any are missing
if [ -z "$LANGSMITH_API_KEY" ] || [ -z "$ANTHROPIC_API_KEY" ]; then
  echo "Sourcing from /workspace/.devcontainer/.env..."
  source /workspace/.devcontainer/.env

  # Check again
  [ -n "$LANGSMITH_API_KEY" ] && echo "✓ LANGSMITH_API_KEY is set" || echo "✗ LANGSMITH_API_KEY not set"
  [ -n "$ANTHROPIC_API_KEY" ] && echo "✓ ANTHROPIC_API_KEY is set" || echo "✗ ANTHROPIC_API_KEY not set"
fi
```

## Test Execution Templates

### Template 1: Run Single Test

```bash
# Navigate to worktree
cd /workspace/wip/<worktree-name>

# Source environment (ALWAYS do this first!)
source /workspace/.devcontainer/.env

# Verify location
pwd

# Run specific test
cargo test --test <test_file> <test_name> -- --ignored --nocapture
```

### Template 2: Run All Helper Tests

```bash
# Navigate to worktree
cd /workspace/wip/<worktree-name>

# Source environment (ALWAYS do this first!)
source /workspace/.devcontainer/.env

# Run all integration tests (fast ones)
cargo test --test integration_deployment_workflow test_list_ -- --ignored --nocapture
```

### Template 3: Run Long-Running Test in Background

```bash
# Navigate to worktree
cd /workspace/wip/<worktree-name>

# Source environment (ALWAYS do this first!)
source /workspace/.devcontainer/.env

# Run test in background
cargo test --test integration_deployment_workflow test_deployment_workflow -- --ignored --nocapture > test_output.log 2>&1 &

# Save PID
echo $! > test_pid.txt

# Monitor progress
tail -f test_output.log
```

## Troubleshooting

### Tests Fail with "API key not found"

**Symptom:** Tests fail immediately with authentication errors.

**Diagnosis:**
```bash
# Check if env vars are set
[ -n "$LANGSMITH_API_KEY" ] && echo "Set" || echo "Not set"
```

**Solution:**
```bash
# Source from devcontainer
source /workspace/.devcontainer/.env

# Verify
[ -n "$LANGSMITH_API_KEY" ] && echo "Set" || echo "Not set"
```

### Tests Fail with "type/enum not found"

**Symptom:** Tests fail with compilation errors about missing types or enum variants.

**Diagnosis:**
```bash
# Check current location
pwd
# If output is /workspace, you're in main workspace (may have old SDK)
```

**Solution:**
```bash
# Navigate to worktree with feature branch
cd /workspace/wip/<worktree-name>

# Run tests from worktree
cargo test --test integration_test -- --ignored --nocapture
```

### Tests Pass in Worktree, Fail in CI

**Symptom:** Tests work locally in worktree but fail when pushed to CI.

**Common Causes:**
1. Feature branch depends on another PR not yet merged
2. SDK changes in worktree not compatible with main branch

**Diagnosis:**
```bash
# Test from main workspace to simulate CI environment
cd /workspace
git checkout main
git pull origin main
cargo test --workspace --all-features
```

**Solution:**
- Ensure prerequisite PRs are merged first
- Update feature branch to include necessary changes

### Background Tests Show Different Results

**Symptom:** Running tests in background from main workspace shows failures, but running same test from worktree passes.

**Cause:** Background tests are using main branch SDK, not feature branch SDK.

**Solution:**
```bash
# Always run from worktree when testing feature branch
cd /workspace/wip/<worktree-name>
cargo test --test integration_test -- --ignored --nocapture
```

## Security Best Practices

### Never Expose Credentials

**✅ CORRECT:**
```bash
# Check without exposing
[ -n "$LANGSMITH_API_KEY" ] && echo "Set" || echo "Not set"

# Use in commands without echoing
cargo test --test integration_test -- --ignored --nocapture
```

**❌ WRONG:**
```bash
# Never do these
echo $LANGSMITH_API_KEY
echo "Key: $LANGSMITH_API_KEY"
env | grep LANGSMITH
```

### Store Credentials Securely

**Best practices:**
- Store in `/workspace/.devcontainer/.env` (gitignored)
- Never commit `.env` files
- Use placeholders in documentation: `<your-api-key>`

## Integration with Other Tools

### With git-worktrees Skill

After creating a worktree, use this skill to run tests:

```bash
# Create worktree (from git-worktrees skill)
git worktree add -b codekiln/186-test-helpers wip/codekiln-186-test-helpers main

# Navigate and run tests (from this skill)
cd wip/codekiln-186-test-helpers
[ -n "$LANGSMITH_API_KEY" ] && echo "Set" || source /workspace/.devcontainer/.env
cargo test --test integration_test -- --ignored --nocapture
```

### With Pre-Commit Checklist

Before committing, run the pre-commit checklist from worktree:

```bash
cd /workspace/wip/<worktree-name>
cargo fmt && \
cargo check --workspace --all-features && \
cargo clippy --workspace --all-features -- -D warnings && \
cargo test --workspace --all-features && \
cargo fmt --check
```

## Quick Reference

### Environment Check One-Liner

```bash
[ -n "$LANGSMITH_API_KEY" ] && echo "✓ LANGSMITH_API_KEY set" || (source /workspace/.devcontainer/.env && [ -n "$LANGSMITH_API_KEY" ] && echo "✓ LANGSMITH_API_KEY set after source" || echo "✗ LANGSMITH_API_KEY not found")
```

### Worktree Test One-Liner

```bash
cd /workspace/wip/<worktree-name> && [ -n "$LANGSMITH_API_KEY" ] || source /workspace/.devcontainer/.env && cargo test --test integration_test -- --ignored --nocapture
```

### Complete Test Flow

```bash
# 1. Navigate to worktree
cd /workspace/wip/<worktree-name>

# 2. Source environment variables (CRITICAL FIRST STEP!)
source /workspace/.devcontainer/.env

# 3. Verify location
pwd

# 4. Run tests
cargo test --test integration_test -- --ignored --nocapture
```

## Related Documentation

- **Issue #186** - Where environment sourcing patterns were discovered
- **Issue #232** - Where test failures led to skill improvements
- **git-worktrees skill** - For creating and managing worktrees
- **Pre-Commit Checklist** - `@docs/dev/README.md` "Pre-Commit Checklist" section
- **GitHub Workflow** - `@docs/dev/github-workflow.md`

## Key Takeaways

1. **ALWAYS source environment variables FIRST: `source /workspace/.devcontainer/.env`**
   - **This applies to ALL cargo commands in worktrees**, including pre-commit checks
   - `cargo test`, `cargo clippy`, `cargo check`, `cargo build` may all require environment variables
2. **Pre-commit checks MUST source environment first** - Don't run the pre-commit suite without sourcing
3. **Always verify `pwd` before running tests** - Ensure you're in the correct worktree
4. **Run tests from worktree when working on feature branch** - Use feature branch SDK
5. **Never expose sensitive environment variable values** - Check without showing
6. **Understand test context (main workspace vs worktree)** - Different SDK versions

**The #1 cause of test failures in worktrees is missing environment variables.** Always source them first, especially before running pre-commit checks.

**The #1 symptom:** Cryptic panics like `byte index 8 is out of bounds of \`\`` that disappear after sourcing environment variables.

These principles save time, prevent confusion, and improve security.
