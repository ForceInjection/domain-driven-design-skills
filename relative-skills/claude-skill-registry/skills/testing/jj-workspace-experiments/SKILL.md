---
name: jj-workspace-experiments
description: Create isolated jj workspaces for testing changes, running experiments in parallel, and exploring alternative implementations. Use when testing breaking changes, comparing different approaches, or running long-running operations without blocking other work. (project)
---

# Jj Workspace Experiments

## Overview

Create isolated jj workspaces in the `work/` directory to test changes, run experiments concurrently, and explore alternative implementations without affecting the main workspace. All workspaces share the same repository history, enabling seamless switching and comparison between approaches.

## When to Use

Use this skill when:
- Testing breaking changes or refactors that might not work
- Comparing multiple implementation approaches side-by-side
- Running long-running tests or builds without blocking other work
- Exploring alternative solutions to a problem concurrently
- Testing changes that require extensive experimentation
- Working on multiple independent features simultaneously

## Core Workflows

### Single Experiment Workspace

Create a workspace to test changes in isolation.

#### 1. Create the Workspace

```bash
jj workspace add --name=<experiment-name> work/<directory-name>
```

**Examples:**
```bash
# Test a refactoring
jj workspace add --name=async-refactor work/async-refactor

# Try a different architecture
jj workspace add --name=new-db-layer work/new-db-layer

# Experiment with a breaking change
jj workspace add --name=api-v2 work/api-v2
```

The workspace starts from the current commit (`@`) by default. To start from a different commit:

```bash
jj workspace add --name=<name> -r <revision> work/<directory>
```

#### 2. Work in the Workspace

Navigate to the workspace and make changes:

```bash
cd work/<directory-name>

# Make changes, run tests, build
# Commits created here are isolated to this workspace
```

Changes are visible from the main workspace via `jj log` - all workspaces share the repository history.

#### 3. Evaluate and Decide

After testing:

**If successful:** Merge the changes back to the main branch:
```bash
# From main workspace
jj rebase -s <experiment-name>@ -d @
```

**If unsuccessful:** Simply forget the workspace:
```bash
jj workspace forget <experiment-name>
rm -rf work/<directory-name>
```

The commits remain in the repository history but can be abandoned if needed.

### Parallel Experiments

Test multiple approaches simultaneously by creating multiple workspaces.

#### 1. Create Multiple Workspaces

```bash
# Create first approach workspace
jj workspace add --name=approach-a work/approach-a

# Create second approach workspace
jj workspace add --name=approach-b work/approach-b

# Create third approach workspace (optional)
jj workspace add --name=approach-c work/approach-c
```

Each workspace starts from the same commit, creating parallel branches of development.

#### 2. Implement Different Approaches

Work in each workspace independently:

```bash
# Terminal 1: Implement approach A
cd work/approach-a
# Make changes...

# Terminal 2: Implement approach B
cd work/approach-b
# Make changes...

# Terminal 3: Implement approach C
cd work/approach-c
# Make changes...
```

#### 3. Compare Results

From the main workspace, compare implementations:

```bash
# View all workspace changes
jj log -r 'working_copies()'

# Compare approach A to approach B
jj diff -r approach-a@ -r approach-b@

# View specific workspace state
jj show approach-a@
```

#### 4. Choose Winner and Clean Up

Select the best approach and merge it:

```bash
# Merge winning approach
jj rebase -s approach-b@ -d @

# Forget the other workspaces
jj workspace forget approach-a
jj workspace forget approach-c

# Clean up directories
rm -rf work/approach-a work/approach-c
```

### Long-Running Operations

Use a workspace to run long builds/tests without blocking other work.

#### 1. Create Workspace for Long Operation

```bash
jj workspace add --name=test-run work/test-run
```

#### 2. Start Long Operation

```bash
cd work/test-run

# Start long-running operation
buck2 test //... &
```

#### 3. Continue Work Elsewhere

While the operation runs, work normally in the main workspace:

```bash
cd $REPO_ROOT  # Back to main workspace
# Continue development normally
```

#### 4. Check Results When Ready

Return to the test workspace to check results:

```bash
cd work/test-run
# Check test results, build artifacts, etc.
```

## Advanced Patterns

### Testing Changes on Different Base Commits

Create workspaces from different commits to test compatibility:

```bash
# Test on current commit
jj workspace add --name=current-test work/current-test

# Test on older commit
jj workspace add --name=backport-test -r @-- work/backport-test

# Test on main branch
jj workspace add --name=main-test -r main work/main-test
```

### Darcs-Style Multiple Workspaces

Create a sparse main workspace with all real work in sub-workspaces:

```bash
# Make main workspace sparse (only work/ directory)
jj sparse set --clear --add work

# Create multiple workspaces for different tasks
jj workspace add work/feature-a
jj workspace add work/feature-b
jj workspace add work/bugfix-123
```

Now the main workspace is empty, but `work/` contains multiple full checkouts that all share the repository history.

### Workspace as Scratch Space

Create temporary workspaces for quick experiments:

```bash
# Create scratch workspace
jj workspace add --name=scratch work/scratch

cd work/scratch
# Experiment freely without concern

# When done, forget it
jj workspace forget scratch
rm -rf work/scratch
```

## Best Practices

### Naming Conventions

Use descriptive names that indicate purpose:
- **Experiments:** `sqlite-vs-postgres`, `algorithm-a`, `refactor-v2`
- **Features:** `feature-auth`, `feature-search`
- **Tests:** `test-integration`, `perf-benchmark`
- **Scratch:** `scratch`, `temp-experiment`

### Workspace Lifecycle

1. **Create** workspace with clear purpose
2. **Work** in isolation until complete or failed
3. **Evaluate** results and make decision
4. **Merge** successful work or **forget** failed attempts
5. **Clean up** directories after forgetting

### Managing Multiple Workspaces

List active workspaces regularly:

```bash
jj workspace list
```

Keep track of workspace purposes in notes or commit messages.

### Resource Considerations

Each workspace is a full working copy, consuming disk space. Clean up unused workspaces promptly.

## Workspace Commands Reference

```bash
# Create workspace from current commit
jj workspace add --name=<name> work/<dir>

# Create workspace from specific revision
jj workspace add --name=<name> -r <rev> work/<dir>

# List all workspaces
jj workspace list

# Forget workspace (keeps commits, removes workspace reference)
jj workspace forget <name>

# View all workspace commits
jj log -r 'working_copies()'

# Reference a workspace's current commit
<workspace-name>@
```

## Limitations

- **Disk space:** Each workspace is a full working copy
- **Manual cleanup:** Must remember to forget and remove old workspaces
- **Coordination:** When working in multiple workspaces, ensure you're in the correct directory
- **Build artifacts:** Each workspace has its own build outputs, which can consume significant space

## Related Skills

- `jj-clone-third-party` - For examining external repositories
- `jj-graft-third-party` - For integrating third-party repository history
