---
name: command-executor
version: "0.2.0"
description: Executes safe commands and captures real output to extend command-verify functionality. Only runs when explicitly requested. Use when asked to actually run commands, execute commands, test if commands work, or verify commands actually execute.
author: "Claude Code"
categories: ["execution", "testing", "automation", "validation"]
keywords: ["command", "execution", "testing", "output", "performance", "safety"]
allowed-tools: Read,Glob,Bash,AskUserQuestion
---

# Command Executor

## Overview

This skill extends the command-verify skill to actually execute safe commands and capture real output. It provides execution capabilities with safety checks and output capture.

## When to Use

Invoke this skill when the user asks to:
- "Actually run the commands"
- "Execute the commands"
- "Test if commands work"
- "Verify commands actually execute"
- "Run the safe commands and show output"

## Safety First

**NEVER auto-execute dangerous commands.** Always follow these safety rules:

### Commands to NEVER Execute:
- `rm -rf` (destructive deletion)
- `git push --force` (destructive git operation)
- `npm run clean/clear/reset` (destructive cleanup)
- `drop database` (database destruction)
- Any command with `--delete` or `--force` flags
- `truncate` operations

### Commands Requiring Confirmation:
- `npm install` (modifies node_modules)
- `npm run format` (modifies source files)
- Commands with `--force` flags
- Any command modifying files

### Commands Safe to Auto-Execute:
- `npm run build`
- `npm run test`
- `npm run lint`
- `npm run typecheck`
- `git status`
- `node --version`
- Read-only operations

## How It Works

### 1. Pre-Flight Checks

Before executing any commands:
- Check git status (ensure working directory is clean)
- Check git branch (warn if on main/master)
- Check for uncommitted changes (ask before running)

### 2. Execution Plan

Always show the user what will be executed:

```
Execution Plan:
✓ npm run build (safe, will execute)
✓ npm run test (safe, will execute)
? npm install (conditional, will ask)
⊝ rm -rf node_modules (dangerous, will skip)

Continue? [y/N]
```

Use the AskUserQuestion tool to get confirmation.

### 3. Command Execution

Execute commands sequentially (not in parallel for safety):
- Capture stdout, stderr, exit code, duration
- Stop on first failure (fail-fast)
- Log all executions to audit log

### 4. Output Capture

For each executed command, capture:
- **stdout:** Standard output
- **stderr:** Error output
- **exit code:** Success/failure status
- **duration:** Execution time in milliseconds
- **timestamp:** When it was executed

Store in `.cache/command-validations/executions/<hash>.json`:

```json
{
  "command": "npm run build",
  "executedAt": "2025-10-29T10:00:00Z",
  "duration": 2341,
  "exitCode": 0,
  "stdout": "Successfully compiled 42 files",
  "stderr": "",
  "success": true,
  "commit": "a1b2c3d"
}
```

### 5. Performance Comparison

Compare execution results with previous runs to detect:
- **Performance regressions:** Duration > previous * 1.5
- **New errors:** stderr differs from previous
- **Output changes:** Significant stdout differences

## Instructions for Claude

When this skill is invoked:

1. **Pre-Flight Phase**
   - Run `git status` to check working directory state
   - Run `git branch` to identify current branch
   - Warn if on main/master
   - Check for uncommitted changes

2. **Discovery Phase**
   - Use command-verify skill to discover all commands
   - Categorize each command (safe/conditional/dangerous)

3. **Planning Phase**
   - Create execution plan showing which commands will run
   - Use AskUserQuestion tool to get confirmation
   - Show clear indicators (✓ safe, ? conditional, ⊝ dangerous)

4. **Execution Phase**
   - Execute commands sequentially using Bash tool
   - For each command:
     - Capture full output (stdout/stderr)
     - Measure execution time
     - Record exit code
     - Save to cache
   - Stop on first failure

5. **Reporting Phase**
   - Show execution results:
     ```
     Execution Report:

     ✓ npm run build (2.3s)
       Output: Successfully compiled 42 files

     ✓ npm run test (4.5s)
       Output: 87 tests passed

     Summary:
     - Executed: 2/4 commands
     - Success: 2/2
     - Duration: 6.8s
     - Performance: ✓ No regressions detected
     ```
   - Highlight any performance regressions
   - Show any new errors or warnings

6. **Cache Update Phase**
   - Save execution results to `.cache/command-validations/executions/`
   - Update audit log at `.cache/command-validations/audit.log`
   - Format: `[timestamp] command - STATUS - duration`

## Error Handling

- **Command fails:** Capture error, report clearly, continue if user approves
- **Timeout:** Kill process after 5 minutes, mark as timeout
- **Permission denied:** Skip command, suggest permission fix
- **Missing dependencies:** Provide installation instructions

## Performance Expectations

- **Discovery:** ~100ms (reuse command-verify)
- **Planning:** ~50ms (categorization)
- **Execution:** Depends on commands
- **Reporting:** ~50ms

## Safety Features

### Dry Run Mode
Show what would be executed without actually running:
```
Dry Run - Would execute:
✓ npm run build
✓ npm run test

Would skip:
⊝ rm -rf node_modules (dangerous)
```

### Audit Log
All executions logged to `.cache/command-validations/audit.log`:
```
[2025-10-29 10:00:00] npm run build - SUCCESS - 2.3s
[2025-10-29 10:00:03] npm run test - SUCCESS - 4.5s
[2025-10-29 10:00:08] npm install - SKIPPED - user declined
```

### Confirmation Required For
- First time executing a command
- Commands in dangerous category
- Commands on production branch
- Commands with side effects

## Integration

This skill works alongside command-verify:
1. command-verify discovers and validates commands
2. command-executor actually runs safe ones
3. Both share the same cache structure
4. Results enhance future validations

## Example Usage

**User:** "Verify and execute the safe commands"

**Claude's actions:**
1. Invoke command-verify to discover commands
2. Categorize commands (safe/conditional/dangerous)
3. Show execution plan to user
4. Get user confirmation via AskUserQuestion
5. Execute safe commands using Bash
6. Capture and report results
7. Update cache with execution data

**Output:**
```
✓ Found 15 commands
✓ 8 safe, 5 conditional, 2 dangerous

Execution Plan:
✓ npm run build
✓ npm run test
✓ npm run lint

Continue? y

Executing...
✓ npm run build (2.3s) - Success
✓ npm run test (4.5s) - Success
✓ npm run lint (1.2s) - Success

All commands executed successfully!
No performance regressions detected.
```
