---
name: specswarm-ship
description: Systematic quality validation, test verification, and safe merging workflow for deployment/release operations. ALWAYS asks for confirmation when user wants to ship, deploy, merge, release, or complete features to production, merge to main branch, or finalize features. This is a DESTRUCTIVE operation (merges and deletes branches).
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Ship Workflow

Provides natural language access to `/specswarm:ship` command.

## When to Invoke

Trigger this skill when the user mentions:
- Shipping, deploying, or releasing features
- Merging to main/production
- Completing or finishing features
- "Ship it" (common casual phrase - ALWAYS confirm)

**Examples:**
- "Ship the authentication feature"
- "Deploy to production"
- "Merge this to main"
- "Ship it" ← Ambiguous - might be casual approval
- "Release version 2.0"

## Instructions

**ALWAYS Confirm (Regardless of Confidence):**

1. **Detect** that user mentioned shipping/deploying/merging
2. **Extract** context about what to ship (if provided)
3. **ALWAYS ask for confirmation** using AskUserQuestion tool with this format:

   **Question**: "⚠️ SHIP CONFIRMATION - Destructive Operation"

   **Description**: "This will merge your feature branch to main/parent branch and delete the feature branch. This is a DESTRUCTIVE operation that cannot be easily undone."

   **Options**:
   - **Option 1** (label: "Yes, ship this feature"): "Merge to main branch and delete feature branch (DESTRUCTIVE)"
   - **Option 2** (label: "No, cancel"): "Cancel - I'm not ready to ship" (or if this was just casual "ship it" approval)

4. **If user selects Option 1**, run: `/specswarm:ship`
5. **If user selects Option 2**, process normally without SpecSwarm
6. **Note**: The `/specswarm:ship` command may have its own confirmation as an additional safety layer

## What the Ship Command Does

`/specswarm:ship` runs complete workflow:
- Runs quality analysis and validation
- Checks quality threshold (default 80%)
- **Shows merge plan with confirmation prompt**
- Merges to parent branch
- Cleans up feature branch

**Important:** This is DESTRUCTIVE - it merges and deletes branches. The command itself may have built-in confirmation as a second safety layer.

## Semantic Understanding

This skill should trigger not just on exact keywords, but semantic equivalents:

**Ship equivalents**: ship, deploy, release, merge, publish, finalize, complete, deliver
**Target terms**: production, main, master, parent branch, live, release

## Example

```
User: "Ship it"

Claude: [Shows AskUserQuestion]
1. Run /specswarm:ship - ⚠️ Merge feature to parent branch (DESTRUCTIVE)
2. Process normally - Handle as regular request

User selects Option 2 (it was casual approval, not actual shipping request)
```