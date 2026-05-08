---
name: specswarm-upgrade
description: Systematic compatibility analysis, migration guidance, and breaking change detection for dependency/framework upgrades. Auto-executes when user clearly wants to upgrade, update, migrate, or modernize software dependencies, frameworks, packages, or technology stacks.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Upgrade Workflow

Provides natural language access to `/specswarm:upgrade` command.

## When to Invoke

Trigger this skill when the user mentions:
- Upgrading or updating dependencies/packages
- Migrating to new frameworks or versions
- Modernizing technology stacks
- Bumping version numbers

**Examples:**
- "Upgrade React to version 19"
- "Update all dependencies"
- "Migrate from Webpack to Vite"
- "Modernize the build system"
- "Bump Node to version 20"

## Instructions

**Confidence-Based Execution:**

1. **Detect** that user mentioned upgrading/updating software
2. **Extract** what to upgrade from their message
3. **Assess confidence and execute accordingly**:

   **High Confidence (95%+)** - Auto-execute immediately:
   - Clear upgrade requests: "Upgrade React to version 19", "Update all dependencies", "Migrate from Webpack to Vite"
   - Action: Immediately run `/specswarm:upgrade "upgrade description"`
   - Show brief notification: "🎯 Running /specswarm:upgrade... (press Ctrl+C within 3s to cancel)"

   **Medium Confidence (70-94%)** - Ask for confirmation:
   - Less specific: "Update the packages", "Modernize the stack"
   - Action: Use AskUserQuestion tool with two options:
     - Option 1 (label: "Run /specswarm:upgrade"): Use SpecSwarm's upgrade workflow with compatibility analysis
     - Option 2 (label: "Process normally"): Handle as regular Claude Code request

   **Low Confidence (<70%)** - Always ask:
   - Vague: "Make it better", "Use newer stuff"
   - Action: Use AskUserQuestion as above

4. **If user cancels (Ctrl+C) or selects Option 2**, process normally without SpecSwarm
5. **After command completes**, STOP - do not continue with ship/merge

## What the Upgrade Command Does

`/specswarm:upgrade` runs complete workflow:
- Analyzes breaking changes and compatibility
- Creates comprehensive upgrade plan
- Generates migration tasks
- Updates dependencies and code
- Runs tests to verify compatibility
- Documents upgrade process

Stops after upgrade is complete - does NOT merge/ship/deploy.

## Semantic Understanding

This skill should trigger not just on exact keywords, but semantic equivalents:

**Upgrade equivalents**: upgrade, update, migrate, modernize, bump, move to, switch to, adopt
**Target terms**: dependency, package, framework, library, version, technology stack

## Example

```
User: "Upgrade React to version 19"