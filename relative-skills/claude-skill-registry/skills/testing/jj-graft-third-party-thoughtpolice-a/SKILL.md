---
name: jj-graft-third-party
description: Integrate third-party repository history into the monorepo by adding remotes and creating workspaces. Use when testing patches to upstream projects, making local modifications to dependencies, or maintaining forks that need to track upstream changes. (project)
---

# Jj Graft Third Party

## Overview

Integrate third-party repository history into the monorepo by adding git remotes and creating workspaces that point to upstream branches. This connects external repository history to the main repo through jj's virtual `root()` commit, enabling local modifications and patch testing while maintaining the relationship with upstream.

## When to Use

Use this skill when:
- Testing patches to upstream projects before submitting them
- Making local modifications to third-party code that need to be tracked
- Maintaining a fork of a dependency with upstream tracking
- Developing features that require changes to both the monorepo and a dependency
- Experimenting with modifications to third-party libraries

**Do not use when:** Simply examining source code without modifications (use `jj-clone-third-party` instead).

## Workflow

### 1. Add the Remote Repository

Add a git remote for the upstream repository:

```bash
jj git remote add <remote-name> <repository-url>
```

**Examples:**
```bash
# Add tokio as a remote
jj git remote add tokio https://github.com/tokio-rs/tokio

# Add serde as a remote
jj git remote add serde https://github.com/serde-rs/serde

# Add custom library
jj git remote add mylib https://github.com/someorg/mylib
```

**Best practice:** Use descriptive remote names that match the project name for clarity.

### 2. Fetch from the Remote

Fetch the remote repository's history:

```bash
jj git fetch --remote=<remote-name>
```

**Examples:**
```bash
jj git fetch --remote=tokio
jj git fetch --remote=serde
```

This imports the remote's git history into the jj repository. The history becomes accessible but doesn't affect working copies yet.

### 3. Create a Workspace Pointing to the Remote Branch

Create a workspace in `work/` that points to the remote's main branch:

```bash
jj workspace add \
  --name=<workspace-name> \
  -r <branch>@<remote-name> \
  work/<directory-name>
```

**Examples:**
```bash
# Create workspace for tokio's main branch
jj workspace add \
  --name=tokio \
  -r main@tokio \
  work/tokio

# Create workspace for serde's master branch
jj workspace add \
  --name=serde \
  -r master@serde \
  work/serde

# Create workspace for a specific tag or commit
jj workspace add \
  --name=mylib-v2 \
  -r v2.0.0@mylib \
  work/mylib
```

**Important:** The branch name must match what the upstream repository uses (commonly `main`, `master`, or `trunk`). Use `jj git fetch --remote=<name>` output to see available branches.

### 4. Work in the Workspace

Navigate to the workspace and make changes:

```bash
cd work/<directory-name>

# Make modifications to the code
# Test changes
# Create commits as normal with jj

# View the integrated history
jj log
```

The workspace is a full working copy with the third-party history connected to the main repository. Changes made here create new commits on top of the upstream history.

### 5. Sync with Upstream (Optional)

Update the workspace with latest upstream changes:

```bash
# Fetch latest changes from remote
jj git fetch --remote=<remote-name>

# From within the workspace, rebase onto latest upstream
cd work/<directory-name>
jj rebase -d <branch>@<remote-name>
```

### 6. Clean Up When Done

When finished with the workspace:

```bash
# Forget the workspace (keeps commits in the main repo)
jj workspace forget <workspace-name>

# Remove the directory
rm -rf work/<directory-name>

# Optionally remove the remote if no longer needed
jj git remote remove <remote-name>
```

**Important:** `jj workspace forget` removes the workspace reference but preserves all commits. The commits remain in the repository's history and can be accessed via `jj log`.

## Advanced Patterns

### Testing Patches Before Upstream Submission

1. Create grafted workspace pointing to upstream
2. Make changes and test thoroughly in the workspace
3. Generate patch files or create a branch for submission:
   ```bash
   cd work/<directory-name>
   jj git export  # Export to git format if needed
   ```

### Maintaining a Long-Term Fork

1. Graft the upstream repository
2. Create a named branch for local modifications:
   ```bash
   cd work/<directory-name>
   jj branch create <fork-branch-name>
   ```
3. Periodically sync with upstream and rebase local changes

### Comparing Local Changes to Upstream

View differences between local modifications and upstream:

```bash
cd work/<directory-name>
jj diff -r <branch>@<remote-name>
```

## Best Practices

### Remote Naming

Use descriptive remote names matching the project:
- `tokio` for tokio-rs/tokio
- `serde` for serde-rs/serde
- `buck2` for facebook/buck2

### Workspace Naming

Match workspace names to remote names for consistency:
```bash
jj workspace add --name=tokio -r main@tokio work/tokio
```

### Branch Discovery

Check available branches after fetching:
```bash
jj git fetch --remote=<remote-name>
# Look for "remote: <remote-name>/branch-name" in output
```

Common branch names: `main`, `master`, `trunk`, `develop`

### Commit Organization

Keep local modifications in separate, well-documented commits on top of upstream to make patch generation easier.

## Troubleshooting

See `references/troubleshooting.md` for common issues and solutions.

## Limitations

- **Requires network access:** Fetching from remotes requires internet connectivity
- **Workspace management overhead:** Must track workspace lifecycle and cleanup
- **Potential merge conflicts:** Syncing with upstream may require conflict resolution
- **Storage overhead:** Fetching large repositories adds to repository size

## Related Skills

- `jj-clone-third-party` - For simple examination without history integration
- `jj-workspace-experiments` - For creating isolated experimental workspaces
