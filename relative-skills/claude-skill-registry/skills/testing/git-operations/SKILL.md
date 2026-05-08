---
name: git-operations
description: Enforce git-expert agent delegation for all git operations in the MCP for LifeOS project. This skill should be used when performing git status checks, branching, merging, committing, or pushing to ensure MCP deployment compliance and Linear integration. (project, gitignored)
---

# Git Operations Skill

## Purpose

All git write operations for this project must be handled exclusively by the `git-expert` agent to ensure:

- Proper MCP server deployment compliance
- Linear issue tracking integration (Team ID: `d1aae15e-d5b9-418d-a951-adcf8c7e39a8`)
- Correct commit message formatting for MCP projects
- Safe git operations with appropriate validations
- Integration with project-specific git workflows

## When to Use This Skill

Use this skill whenever any of the following git operations are requested:

- **Status Checks**: Viewing git status, checking working tree state
- **Branch Operations**: Creating, switching, listing, or deleting branches
- **Merging**: Merging branches, resolving conflicts
- **Committing**: Staging changes and creating commits
- **Pushing**: Pushing commits to remote repositories
- **Any other git write operations**

## Core Principle

Never perform git operations directly. Always delegate to the `git-expert` agent.

## How to Use

When any git operation is requested:

1. Immediately invoke the Task tool with `subagent_type="git-expert"`
2. Provide clear context about what git operation is needed
3. Wait for the agent's response before proceeding
4. Trust the agent's structured output - it returns validated results

## Examples

### Committing Changes

**User Request**: "Commit these changes"

**Correct Approach**:

```text
Use Task tool → git-expert agent
Prompt: "Handle git commit process for [changes description]"
```

Prompt: "Handle git commit process for [changes description]"

```text
**Incorrect Approach**:  
Running `git add .` and `git commit -m "message"` directly

### Checking Git Status

**User Request**: "What's the git status?"

**Correct Approach**:

```text
Use Task tool → git-expert agent  
Prompt: "Check current git status and working tree state"
```

**Incorrect Approach**:  
Running `git status` via Bash tool

### Creating and Pushing Branch

**User Request**: "Create a feature branch and push it"

**Correct Approach**:

```text
Use Task tool → git-expert agent  
Prompt: "Create feature branch for [feature] and push to remote with proper MCP deployment practices"
```

**Incorrect Approach**:  
Running `git checkout -b feature/x` and `git push -u origin feature/x` directly

### Merging Branches

**User Request**: "Merge the feature branch into master"

**Correct Approach**:

```text
Use Task tool → git-expert agent  
Prompt: "Perform git merge from feature branch to master with MCP deployment workflow"
```

**Incorrect Approach**:  
Running `git checkout master && git merge feature/x` directly

## Exception

Read-only git operations may be performed directly:

- `git log` (viewing commit history)
- `git diff` (viewing changes) - though preferably through git-expert

All other operations must use the `git-expert` agent.

## Decision Rules

- If it writes to git → Use git-expert agent
- If it's a critical git operation → Use git-expert agent
- If uncertain → Use git-expert agent

This is mandatory for this project.
