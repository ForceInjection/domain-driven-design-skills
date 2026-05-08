---
name: specswarm-fix
description: Systematic bugfix workflow with regression testing, auto-retry logic, and comprehensive validation. Auto-executes when user clearly wants to fix, debug, repair, resolve, broken, not working, doesn't work, not showing up, not appearing, not displaying, not rendering, doesn't show, won't show, isn't showing, doesn't appear, doesn't display, failing, errors, bugs, issues, not loading, doesn't load, crashed, crashes, problem with, trouble with.
allowed-tools: AskUserQuestion, SlashCommand
---

# SpecSwarm Fix Workflow

Provides natural language access to `/specswarm:fix` command.

## When to Invoke

Trigger this skill when the user describes ANY software problem:
- Things not working or broken
- Errors, bugs, or failures
- Features not loading or functioning
- Requests to fix, debug, or resolve issues
- ANY report of unexpected behavior

**Examples:**
- "Please fix that the images don't load"
- "Images don't load"
- "Fix the login bug"
- "The checkout is broken"
- "There's an error when submitting forms"
- "Authentication doesn't work"
- "Payment processing fails"
- "The search isn't working"

## Instructions

**Confidence-Based Execution:**

1. **Detect** that user described a software problem
2. **Extract** the problem description from their message
3. **Assess confidence and execute accordingly**:

   **High Confidence (95%+)** - Auto-execute immediately:
   - Clear bug descriptions: "fix the login bug", "images don't load", "checkout is broken"
   - Action: Immediately run `/specswarm:fix "problem description"`
   - Show brief notification: "🎯 Running /specswarm:fix... (press Ctrl+C within 3s to cancel)"

   **Medium Confidence (70-94%)** - Ask for confirmation:
   - Less specific: "something's wrong with authentication", "the app has issues"
   - Action: Use AskUserQuestion tool with two options:
     - Option 1 (label: "Run /specswarm:fix"): Use SpecSwarm's systematic bugfix workflow
     - Option 2 (label: "Process normally"): Handle as regular Claude Code request

   **Low Confidence (<70%)** - Always ask:
   - Vague: "the app isn't working right", "there's a problem"
   - Action: Use AskUserQuestion as above

4. **If user cancels (Ctrl+C) or selects Option 2**, process normally without SpecSwarm
5. **After command completes**, STOP - do not continue with ship/merge

## What the Fix Command Does

`/specswarm:fix` runs complete workflow:
- Creates regression tests to reproduce bug
- Implements the fix
- Verifies fix works
- Re-runs tests to catch new failures
- Auto-retries up to 2 times if needed

Stops after bug is fixed - does NOT merge/ship/deploy.

## Semantic Understanding

This skill should trigger not just on exact keywords, but semantic equivalents:

**Fix equivalents**: fix, repair, resolve, debug, correct, address, handle, patch
**Broken equivalents**: broken, not working, doesn't work, not showing, not appearing, not displaying, not rendering, not loading, failing, crashed
**Issue terms**: bug, error, problem, issue, trouble, failure