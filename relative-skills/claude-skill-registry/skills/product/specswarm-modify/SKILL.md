---
name: specswarm-modify
description: Impact-analysis-first modification workflow with backward compatibility assessment and breaking change detection. Auto-executes when user clearly wants to modify, change, update, adjust, enhance, extend, or alter existing feature behavior (not fixing bugs, not refactoring quality). For features that work but need to work differently.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Modify Workflow

Provides natural language access to `/specswarm:modify` command.

## When to Invoke

Trigger this skill when the user mentions:
- Modifying, changing, or updating existing feature behavior
- Enhancing or extending working features
- Altering how something works (that currently works)
- Making features work differently than they do now

**Examples:**
- "Change authentication from session to JWT"
- "Add pagination to the user list API"
- "Update search to use full-text search"
- "Modify the dashboard to show real-time data"
- "Extend the API to support filtering"

**NOT for this skill:**
- Fixing bugs (use specswarm-fix)
- Improving code quality without changing behavior (use specswarm-refactor)
- Building new features (use specswarm-build)

## Instructions

**Confidence-Based Execution:**

1. **Detect** that user mentioned modifying/changing existing functionality
2. **Extract** the modification description from their message
3. **Assess confidence and execute accordingly**:

   **High Confidence (95%+)** - Auto-execute immediately:
   - Clear modification requests: "Change authentication from session to JWT", "Add pagination to user list API", "Update search algorithm to use full-text search"
   - Action: Immediately run `/specswarm:modify "modification description"`
   - Show brief notification: "🎯 Running /specswarm:modify... (press Ctrl+C within 3s to cancel)"

   **Medium Confidence (70-94%)** - Ask for confirmation:
   - Less specific: "Update the authentication", "Modify the search"
   - Action: Use AskUserQuestion tool with two options:
     - Option 1 (label: "Run /specswarm:modify"): Use SpecSwarm's impact-analysis workflow
     - Option 2 (label: "Process normally"): Handle as regular Claude Code request

   **Low Confidence (<70%)** - Always ask:
   - Vague: "Make the feature better", "Improve the UI"
   - Action: Use AskUserQuestion as above

4. **If user cancels (Ctrl+C) or selects Option 2**, process normally without SpecSwarm
5. **After command completes**, STOP - do not continue with ship/merge

## What the Modify Command Does

`/specswarm:modify` runs complete workflow:
- Analyzes impact and backward compatibility
- Identifies breaking changes
- Creates migration plan if needed
- Updates specification and plan
- Generates modification tasks
- Implements changes
- Validates against regression tests

Stops after modification is complete - does NOT merge/ship/deploy.

## Semantic Understanding

This skill should trigger not just on exact keywords, but semantic equivalents:

**Modify equivalents**: modify, change, update, adjust, enhance, extend, alter, revise, adapt, transform, convert
**Target terms**: feature, functionality, behavior, workflow, process, mechanism, system

**Distinguish from:**
- **Fix** (broken/not working things): "fix", "repair", "resolve", "debug"
- **Refactor** (code quality): "refactor", "clean up", "reorganize", "optimize code structure"
- **Build** (new things): "build", "create", "add", "implement new"

## Example

```
User: "Change authentication from session to JWT"

Claude: 🎯 Running /specswarm:modify... (press Ctrl+C within 3s to cancel)

[Executes /specswarm:modify "Change authentication from session to JWT"]
```

```
User: "Update the authentication"

Claude: [Shows AskUserQuestion]
1. Run /specswarm:modify - Use SpecSwarm's impact-analysis workflow
2. Process normally - Handle as regular Claude Code request

User selects Option 1
```
