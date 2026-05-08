---
name: test-github-actions
description:
  Test GitHub Actions workflows locally using act before pushing changes. Use
  when modifying .github/workflows files, before committing workflow changes,
  when debugging GitHub Actions failures, or when the user mentions testing
  workflows, act tool, or validating CI/CD changes.
allowed-tools: Bash, Read, Glob, Grep
---

# Test GitHub Actions with act

This Skill helps you test GitHub Actions workflows locally using the `act` tool,
allowing you to validate workflow changes before pushing to GitHub and catch
issues early.

## When to use this Skill

Automatically activate this Skill when:

- User is modifying files in `.github/workflows/`
- User mentions testing GitHub Actions, workflows, or CI/CD
- User asks to validate changes before pushing
- User mentions the `act` tool
- There's a GitHub Actions workflow failure that needs debugging
- User is creating a new workflow file

## Prerequisites

### 1. Check if act is installed

```bash
act --version
```

If not installed:

- **macOS**: `brew install act`
- **Linux**: See https://github.com/nektos/act#installation
- **Windows**: See https://github.com/nektos/act#installation

### 2. Verify Docker is running

act requires Docker to run workflow containers. If Docker is not running, inform
the user and provide instructions to start it.

### 3. Ensure act configuration exists

Check for `~/Library/Application Support/act/actrc` (macOS) or `~/.actrc`
(Linux/Windows).

If missing, create it with:

```
-P ubuntu-latest=catthehacker/ubuntu:act-latest
```

This configures act to use the medium Docker image (~500MB) which includes
necessary tools for most workflows.

## Testing workflow process

Follow these steps in order:

### Step 1: Identify the workflow to test

If the user hasn't specified which workflow to test:

```bash
# List all workflows
act -l
```

Then either:

- Ask the user which workflow to test
- Look at recent file changes to suggest which workflow might be affected:
  ```bash
  git diff --name-only | grep ".github/workflows/"
  ```

### Step 2: Perform a dry-run first

Always start with a dry-run to validate workflow syntax quickly:

```bash
act -W .github/workflows/{workflow-file}.yml -j {job-name} --dryrun
```

The dry-run will:

- Validate YAML syntax
- Check workflow structure
- Show which steps would execute
- Complete in seconds

### Step 3: Run the full workflow

If dry-run succeeds, execute the actual workflow:

```bash
act -W .github/workflows/{workflow-file}.yml -j {job-name} --container-architecture linux/amd64
```

**Important flags:**

- `--container-architecture linux/amd64`: Required on Apple Silicon Macs
- `-W .github/workflows/{file}`: Specify exact workflow file
- `-j {job-name}`: Specify job to run (get from `act -l` output)

**Note on execution time:**

- First run may take 5-10 minutes (downloading Docker images)
- Subsequent runs are much faster (images cached)

### Step 4: Analyze the results

Review the output and categorize issues:

#### ✅ Successful steps

- Dependency installation completed
- Scripts executed without errors
- Tests passed

#### ❌ Real failures (must fix)

- Missing dependencies in package.json
- Script errors or syntax issues
- Failed tests
- Configuration problems

#### ⚠️ Expected act limitations (can ignore)

- Git operations failing in worktrees: `fatal: not a git repository`
- PR creation failures: Missing GitHub secrets
- Actions requiring GitHub context that isn't available locally

### Step 5: Provide recommendations

Based on results, tell the user:

**If only expected failures:**

```
✅ Workflow validation passed! The core logic works correctly.
The only failures were expected act limitations (git operations, PR creation).
Safe to commit and push your changes.
```

**If real failures exist:**

```
❌ Found issues that need fixing:
1. [Specific issue with file:line reference]
2. [Another issue]

Fix these before committing.
```

**If fixes were made:** Offer to re-run the workflow to verify the fixes.

## Known limitations of act

Be aware of these limitations when interpreting results:

### Git operations in worktrees

- **Symptom**: `fatal: not a git repository: .git/worktrees/...`
- **Why**: act has trouble with git worktrees
- **Action**: Ignore this error - it works fine in real GitHub Actions

### Missing secrets

- **Symptom**: Steps that need `secrets.GITHUB_TOKEN` or other secrets are
  skipped
- **Why**: act doesn't have access to GitHub secrets
- **Action**: Expected behavior - secrets work in real GitHub Actions

### PR creation actions

- **Symptom**: PR creation steps fail
- **Why**: Requires GitHub API access and secrets
- **Action**: Expected - these work in real GitHub Actions

### Action compatibility

- **Symptom**: Some actions behave differently
- **Why**: Local Docker environment vs GitHub's hosted runners
- **Action**: Test the core workflow logic; some differences are acceptable

## Examples

### Example 1: Test after modifying a workflow

User says: "I just updated the bullish-docs-update workflow, can we test it?"

Response:

1. Check act is installed
2. Run dry-run:
   `act -W .github/workflows/bullish-docs-update.yml -j update-docs --dryrun`
3. If successful, run full test with `--container-architecture linux/amd64`
4. Report results with specific pass/fail for each step
5. Recommend whether safe to commit

### Example 2: Debug a workflow failure

User says: "The Binance workflow is failing in GitHub Actions, let's test it
locally"

Response:

1. Run the workflow with act
2. Compare local results with GitHub Actions logs
3. Identify if it's a real issue or environment difference
4. Suggest fixes based on the specific failure

### Example 3: Proactive suggestion

User modifies `.github/workflows/new-venue.yml`

Proactively suggest: "I see you modified a GitHub Actions workflow. Would you
like me to test it locally with act before you push? This will help catch any
issues early."

## Workflow validation checklist

When testing workflows, verify:

- [ ] All required dependencies are listed in package.json files
- [ ] Node.js version matches workflow configuration
- [ ] Install steps complete successfully (shared, venue-specific)
- [ ] Main script execution completes without errors
- [ ] Documentation is generated successfully
- [ ] No unexpected errors in step output

## Tips for faster iteration

1. **Cache Docker images**: First run is slow, subsequent runs are fast
2. **Test specific jobs**: Use `-j {job-name}` instead of running all jobs
3. **Use dry-run first**: Quickly validate syntax before full execution
4. **Watch for patterns**: Similar workflows often have similar issues

## Platform-specific notes

### macOS (Apple Silicon)

- Always use `--container-architecture linux/amd64`
- Docker Desktop must be running
- Config file location: `~/Library/Application Support/act/actrc`

### macOS (Intel)

- Usually doesn't need `--container-architecture` flag
- Docker Desktop must be running

### Linux

- Config file location: `~/.actrc`
- Ensure Docker daemon is running: `sudo systemctl status docker`

## Troubleshooting

### "act: command not found"

Install act:

```bash
brew install act  # macOS
# or see https://github.com/nektos/act#installation
```

### "Cannot connect to Docker daemon"

Start Docker Desktop (macOS) or Docker daemon (Linux):

```bash
# Linux
sudo systemctl start docker
```

### "Error: pull access denied"

act needs to pull Docker images. Ensure:

- Docker is running
- Internet connection is available
- actrc is configured with the correct image

### Workflow takes too long

- First run downloads images (~500MB) - this is normal
- Subsequent runs use cached images and are much faster
- You can interrupt with Ctrl+C if needed

## Remember

- act tests the **workflow logic**, not the exact GitHub Actions environment
- Some failures are expected and can be ignored (git operations, secrets)
- The goal is to catch real issues (missing dependencies, script errors) before
  pushing
- Always provide clear guidance on whether changes are safe to push
