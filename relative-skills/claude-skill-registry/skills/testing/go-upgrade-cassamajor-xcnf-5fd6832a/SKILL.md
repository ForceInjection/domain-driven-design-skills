---
name: go-upgrade
description: Upgrade Go to the latest version via Homebrew and update all go.mod files in the examples directory. Use when the user mentions upgrading Go, updating Go version, or wants to use the latest Go.
---

# Go Upgrade Skill

This skill automates upgrading Go to the latest version and updating all example projects in the repository.

## What This Skill Does

1. Upgrades Go to the latest version using Homebrew
2. Detects the newly installed Go version
3. Updates the `go` directive in all example go.mod files
4. Runs `go mod tidy` to update dependencies

## When to Use

- User asks to "upgrade go"
- User wants to update to the latest Go version
- User mentions updating Go across the project
- After a new Go version is released

## Examples to Update

The skill updates these example projects:
- `examples/flow/`
- `examples/ip-counter/`
- `examples/netkit/`
- `examples/netkit-ipv6/`

Note: `examples/trace-kills/` is skipped (no go.mod file)

## Step-by-Step Instructions

### 1. Upgrade Go via Homebrew

```bash
brew update
brew upgrade go
```

Display the output to the user. If Go is already at the latest version, Homebrew will indicate this.

### 2. Detect New Go Version

```bash
go version
```

Parse the output to extract the version number. The output format is:
```
go version go1.25.2 darwin/arm64
```

Extract the version number (e.g., "1.25.2") from the string after "go version go".

### 3. Update go.mod Files and Run go mod tidy

**IMPORTANT: Use absolute paths to avoid shell session issues**

First, get the repository root directory:
```bash
pwd
```

Then for each example directory, use the **absolute path** to update the Go version and tidy dependencies:

```bash
cd /absolute/path/to/xcnf/examples/flow && go mod edit -go=<VERSION> && go mod tidy
cd /absolute/path/to/xcnf/examples/ip-counter && go mod edit -go=<VERSION> && go mod tidy
cd /absolute/path/to/xcnf/examples/netkit && go mod edit -go=<VERSION> && go mod tidy
cd /absolute/path/to/xcnf/examples/netkit-ipv6 && go mod edit -go=<VERSION> && go mod tidy
```

Replace:
- `/absolute/path/to/xcnf` with the output from `pwd` (e.g., `/Users/username/code/xcnf`)
- `<VERSION>` with the detected version (e.g., "1.25.4")

**Why use absolute paths?**
- Parallel Bash tool calls run in separate shell sessions
- Relative `cd` commands don't persist across different tool calls
- Absolute paths ensure each command starts from the correct location

**Why combined commands?**
- `go mod edit -go=X.Y.Z` updates the go directive using Go's official tooling
- `go mod tidy` immediately updates dependencies for the new version
- Running together with `&&` ensures consistency and stops on errors

### 4. Display Summary

Show the user a summary:
```
Go Upgrade Summary
==================
Old version: 1.25.1
New version: 1.25.2

Updated go.mod files:
✓ examples/flow/go.mod
✓ examples/ip-counter/go.mod
✓ examples/netkit/go.mod
✓ examples/netkit-ipv6/go.mod

All dependencies tidied successfully.
```

## Error Handling

### Homebrew Not Installed
If `brew` command is not found:
```
Error: Homebrew is not installed. Please install Homebrew first:
https://brew.sh
```

### Go Upgrade Failed
If `brew upgrade go` fails, display the error and stop.

### Version Parsing Failed
If unable to parse `go version` output:
```
Error: Could not detect Go version. Please verify Go is installed correctly.
```

### go mod edit Failed
If any `go mod edit` command fails, display the error for that specific example and continue with others.

### go mod tidy Failed
If `go mod tidy` fails for any example, display the error and diagnostic information.

## Implementation Notes

- Always run commands from the repository root directory
- Use `&&` to chain commands so failures stop execution
- **Use absolute paths when running parallel Bash commands**
- Display clear output for each step
- Show both successes and failures

## Troubleshooting

### Shell Session Behavior

**Problem:** Commands like `cd examples/flow && ...` fail when run in parallel.

**Explanation:** Each Bash tool call runs in a separate shell session. When you make parallel calls:
```bash
# Call 1 - succeeds
cd examples/flow && go mod edit -go=1.25.4 && go mod tidy

# Call 2 - fails (separate shell, starts from original pwd)
cd examples/ip-counter && go mod edit -go=1.25.4 && go mod tidy
```

**Solution:** Always use absolute paths constructed from `pwd`:
```bash
# Get repo root first
REPO_ROOT=$(pwd)

# Then use absolute paths
cd $REPO_ROOT/examples/flow && go mod edit -go=1.25.4 && go mod tidy
cd $REPO_ROOT/examples/ip-counter && go mod edit -go=1.25.4 && go mod tidy
cd $REPO_ROOT/examples/netkit && go mod edit -go=1.25.4 && go mod tidy
cd $REPO_ROOT/examples/netkit-ipv6 && go mod edit -go=1.25.4 && go mod tidy
```

This ensures each command starts from the correct location regardless of shell session.

## Example Usage

**User:** "Upgrade go to the latest version"

**Assistant:**
1. Runs `brew update && brew upgrade go`
2. Detects new version: "1.25.2"
3. Updates all four example go.mod files
4. Runs go mod tidy for each
5. Displays summary of changes
