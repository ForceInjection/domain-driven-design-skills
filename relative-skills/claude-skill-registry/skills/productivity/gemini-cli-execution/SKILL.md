---
name: gemini-cli-execution
description: Expert guide for executing the Google Gemini CLI in non-interactive and headless modes. Covers command syntax, piping input, output handling, and automation patterns. Use when running gemini commands, piping context to Gemini, scripting Gemini workflows, or using interactive shell mode. Delegates to gemini-cli-docs for official command references.
allowed-tools: Read, Glob, Grep, Skill, Bash
---

# Gemini CLI Execution

## 🚨 MANDATORY: Invoke gemini-cli-docs First

> **STOP - Before executing ANY Gemini CLI command:**
>
> 1. **INVOKE** `gemini-cli-docs` skill
> 2. **QUERY** for the specific CLI command syntax (e.g., "headless mode", "piping input")
> 3. **BASE** all execution patterns EXCLUSIVELY on official documentation loaded

## Overview

This skill provides the operational knowledge to execute the `gemini` binary effectively within scripts, sub-agents, and automation workflows. It focuses on **non-interactive** usage.

## Command Syntax (v0.18+)

**IMPORTANT**: Gemini CLI uses **positional prompts**, not subcommands.

```bash
# Correct syntax (positional prompt):
gemini "Your prompt here"

# With options:
gemini "Your prompt" --output-format json -m gemini-2.5-flash

# DEPRECATED (will be removed):
gemini -p "Your prompt"  # -p flag is deprecated

# WRONG (no 'query' subcommand exists):
gemini query "Your prompt"  # This does NOT work
```

## When to Use This Skill

**Keywords:** run gemini, execute gemini, gemini cli command, headless gemini, pipe to gemini, automated planning, gemini prompt, interactive shell

**Use this skill when:**

- Invoking Gemini CLI from an agent (e.g., `gemini-planner`)
- Running one-off queries: `gemini "prompt"`
- Piping context: `cat file.js | gemini "refactor this"`
- Using **Interactive Shell** for tools like `vim` or `top`
- Scripting complex workflows involving Gemini

## Execution Patterns

### 1. Single Shot Query (Non-Interactive)

Use positional prompt for direct queries:

```bash
gemini "Create a plan for a React app"

# With JSON output for parsing:
gemini "Create a plan for a React app" --output-format json
```

### 2. Piping Context

Pass file content or logs via stdin:

```bash
cat logs.txt | gemini "Analyze these error logs"

# With model selection:
cat src/*.ts | gemini "Review this code" -m gemini-2.5-flash
```

### 3. JSON Output for Automation

Always use `--output-format json` for scripting:

```bash
result=$(gemini "What is 2+2?" --output-format json)
response=$(echo "$result" | jq -r '.response')
tokens=$(echo "$result" | jq '.stats.models | to_entries | map(.value.tokens.total) | add')
```

### 4. Sandbox Execution

Run commands in isolated environment:

```bash
gemini -s "Run: npm install untrusted-package" --yolo --output-format json
```

### 5. Interactive Shell Mode

Enable interactive shell for commands requiring user input (e.g., `vim`, `git rebase`).

- **Enable:** Set `tools.shell.enableInteractiveShell: true` in `settings.json`.
- **Usage:** `gemini "run vim file.txt"` (User must handle input).

## Key CLI Flags

| Flag | Description |
| --- | --- |
| `--output-format json` | Return structured JSON (essential for automation) |
| `-m, --model` | Select model (gemini-2.5-flash, gemini-2.5-pro) |
| `-s, --sandbox` | Run in sandbox isolation |
| `-y, --yolo` | Auto-approve all tool calls |
| `-r, --resume` | Resume previous session |
| `-i, --prompt-interactive` | Start interactive mode after prompt |

## Keyword Registry (Delegates to gemini-cli-docs)

| Topic | Query Keywords |
| :--- | :--- |
| **Basic Query** | `cli prompt syntax`, `positional prompt` |
| **Headless/Scripting** | `headless mode`, `non-interactive`, `scripting gemini` |
| **Output Formatting** | `json output`, `output-format`, `stream-json` |
| **Sandbox** | `sandbox`, `-s flag`, `docker sandbox` |
| **Interactive Shell** | `interactive shell tool`, `enableInteractiveShell`, `interactive commands` |

## Quick Decision Tree

**What do you want to do?**

1. **Ask a Question** -> `gemini "Question"`
2. **Analyze a File** -> `cat file | gemini "Analyze"`
3. **Generate a Plan** -> `gemini "Plan for X"`
4. **Run Interactive Tool** -> `gemini "run vim file.txt"` (with enableInteractiveShell)
5. **Parse Results** -> Add `--output-format json` and use `jq`

## Troubleshooting

**Issue:** CLI hangs or waits for input.
**Fix:** Ensure you are NOT using the interactive chat mode. Use positional prompt for one-shot queries.

**Issue:** Command not found: `gemini query`
**Fix:** There is no `query` subcommand. Use positional prompt: `gemini "your prompt"`

**Issue:** Warning about deprecated `-p` flag
**Fix:** Use positional syntax instead: `gemini "prompt"` not `gemini -p "prompt"`

## Test Scenarios

### Scenario 1: Single Shot Query

**Query**: "Run a Gemini query to analyze this code"
**Expected Behavior**:

- Skill activates on "run gemini" keyword
- Delegates to gemini-cli-docs for command syntax
- Returns proper positional prompt syntax
**Success Criteria**: User receives correct `gemini "prompt"` syntax

### Scenario 2: Piped Input

**Query**: "How do I send file contents to Gemini CLI?"
**Expected Behavior**:

- Skill activates on "pipe to gemini"
- Provides `cat file | gemini "prompt"` pattern
**Success Criteria**: User receives working piping example

### Scenario 3: JSON Output Parsing

**Query**: "How do I get JSON output from Gemini for automation?"
**Expected Behavior**:

- Skill activates on "automated" or "json output"
- Returns `--output-format json` flag usage
**Success Criteria**: User receives parseable JSON output pattern

## References

**Official Documentation:**
Query `gemini-cli-docs` for:

- "cli commands"
- "headless usage"
- "output format"

## Version History

- v1.1.0 (2025-12-01): Added Test Scenarios section
- v1.0.0 (2025-11-25): Initial release
