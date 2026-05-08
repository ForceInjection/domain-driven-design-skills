---
name: using-jj
description: Use when working with Jujutsu (jj) version control for task management and change tracking - provides workflows for examine-commit-work-squash cycle, checkpointing progress, and managing working copies
---

# Using Jujutsu (jj)

## Overview

Jujutsu (jj) uses a **working copy model** where you maintain a described task change and an empty working copy above it. This enables fine-grained checkpointing while building a single cohesive change.

**Core principle:** Work happens in an empty working copy (@) that gets squashed into the parent described task change, preserving incremental progress as bullet points.

## When to Use

Use this skill when:
- Starting new work in a jj repository
- Implementing features with checkpointing
- Managing task workflow with jj's TypeScript API
- You see errors like "Current change has no description"

Don't use for:
- Basic git workflows (jj is different)
- Repositories not using jj
- When the codebase doesn't provide a jj API

## The Working Copy Model

**Key Concept:** jj separates "what you're building" (task change) from "where you edit" (working copy).

```
INITIAL STATE:
@  (empty) ← you are here

AFTER startChange("Add login"):
@  (empty working) ← you edit here
○  "Add login"    ← task description

AFTER making changes + checkpoint("Created form"):
@  (empty working) ← squashed and recreated
○  "Add login     ← updated with progress
   - Created form"

AFTER more changes + checkpoint("Added validation"):
@  (empty working)
○  "Add login
   - Created form
   - Added validation"

AFTER finishChange():
@  (empty)        ← new working copy
○  "Add login     ← completed task
   - Created form
   - Added validation"
```

**Why This Matters:**
- Checkpoint squashes @ into parent, then creates new @
- Task change accumulates all your work
- Checkpoints become bullet points in description
- Final change is clean and reviewable

## Quick Reference

| Function | Preconditions | What It Does |
|----------|---------------|--------------|
| `setRepository()` | Repo exists, is jj repo | Initialize context (in-memory only), return status |
| `startChange()` | @ is empty OR has description | Create described task + working copy |
| `checkpoint()` | In task, @ has changes | Squash @ to parent, append bullet point |
| `finishChange()` | In task | Move to parent, create new @ |
| `getContext()` | Repository set | Return current change ID |
| `getChangedFiles()` | Repository set | List modified files |
| `cleanup()` | None | Clear repository context |

## Implementation

### Complete Workflow Example

```typescript
import * as jj from './src/jj';

// 1. Set repository (required at start of each script/session)
// This is NOT persistent - stored in module memory only
await jj.setRepository({ repositoryPath: '/path/to/repo' });

// 2. Start task
await jj.startChange({ description: 'Add authentication' });

// 3. Make changes to files
// ... edit code ...

// 4. Checkpoint progress
await jj.checkpoint({ summary: 'Created login form' });

// 5. Make more changes
// ... edit more code ...

// 6. Checkpoint again
await jj.checkpoint({ summary: 'Added password validation' });

// 7. Finish task
await jj.finishChange();
// Task change now contains:
// "Add authentication
//  - Created login form
//  - Added password validation"
```

### Error Recovery

**Error: "Current change has no description"**

This means @ has uncommitted work but no description. Two options:

```typescript
// Option 1: Describe and preserve the work
// $ jj describe -m "Previous work"
await jj.startChange({ description: 'New task' });

// Option 2: Ask your human partner what to do
// "The current change has uncommitted work without a description.
//  Should I describe it as 'X' or is this work safe to discard?"
```

**Error: "No repository set"**

Call `setRepository()` first:

```typescript
await jj.setRepository({ repositoryPath: '/path/to/repo' });
```

### Handling Errors Gracefully

Just try the operation - the API will tell you if there's a problem:

```typescript
await jj.setRepository({ repositoryPath: './repo' });

try {
  await jj.startChange({ description: 'New feature' });
} catch (error) {
  if (error.message.includes('no description')) {
    // Current @ has uncommitted work without description
    // SAFE: Describe it to preserve the work
    // $ jj describe -m "Previous work in progress"
    // Then retry startChange

    // OR ask your human partner:
    // "I found uncommitted work. Should I describe it or is it safe to discard?"
  }
  throw error;
}
```

## Common Mistakes

### ❌ Ignoring Error Messages

```typescript
// BAD: Catching and ignoring errors
try {
  await jj.startChange({ description: 'Feature' });
} catch (error) {
  // Ignore and continue?
}
```

```typescript
// GOOD: Handle errors meaningfully
try {
  await jj.startChange({ description: 'Feature' });
} catch (error) {
  console.error('Failed to start task:', error.message);
  // Take corrective action based on the error
  throw error;
}
```

### ❌ Checkpointing Without Changes

```typescript
// BAD: Checkpointing empty working copy does nothing useful
await jj.checkpoint({ summary: 'Did nothing' });
```

```typescript
// GOOD: Only checkpoint after making changes
// ... edit files ...
const files = await jj.getChangedFiles();
if (files.length > 0) {
  await jj.checkpoint({ summary: 'Made actual changes' });
}
```

### ❌ Forgetting to Finish Task

```typescript
// BAD: Task left in-progress
await jj.startChange({ description: 'Feature' });
// ... make changes ...
await jj.checkpoint({ summary: 'Done' });
// ❌ Never called finishChange()
```

```typescript
// GOOD: Always finish
await jj.startChange({ description: 'Feature' });
// ... make changes ...
await jj.checkpoint({ summary: 'Done' });
await jj.finishChange(); // ✓ Completes the workflow
```

### ❌ Not Understanding the Two-Change Creation

```typescript
// CONFUSION: "Why are there two changes after startChange?"
await jj.startChange({ description: 'Feature' });
// Creates TWO changes:
// @  (empty working) ← you edit here
// ○  "Feature"      ← accumulates your work
```

This is **intentional**. The working copy (@) is your scratch space. When you checkpoint, it gets folded into the task change above it.

## Common Rationalizations - Use The API

**CRITICAL: The TypeScript API is designed for this workflow. It's safer than raw jj commands.**

If you catch yourself wanting to run `jj status` or `jj log` before trying an API operation, STOP. You are rationalizing.

| Rationalization | Reality |
|----------------|---------|
| "Check state with jj status/log first" | **WRONG.** Use the TypeScript API instead. It's designed for this workflow and safer than raw commands. |
| "Being defensive/prudent/careful" | **WRONG.** The API is designed to be safe. Just try the API operation. |
| "Need to know current state" | **WRONG.** The API tells you what you need when you try the operation. |
| "Error docs imply I should check" | **WRONG.** Error recovery is for HANDLING API errors, not running raw jj commands. |
| "Quick check won't hurt" | **WRONG.** You're circumventing the API's safety mechanisms. |

**Why this matters:**
- The TypeScript API was **explicitly built for this workflow**
- Using the API is **safer than raw jj commands**
- Checking first with raw commands **defeats the API's design**
- Just try the API operation - handle errors if they occur

**Red Flags - You're Rationalizing:**
- Running `jj status`, `jj log`, or other raw commands before API calls
- Thinking "let me just check..."
- Worrying about "what if there's uncommitted work"
- Not trusting the API to tell you what you need

**All of these mean: Just try the API operation. Handle errors when they occur.**

## Workflow Checklist

When starting new work:

- [ ] Call `setRepository()` first
- [ ] Try `startChange()` with clear description
- [ ] If it fails with "no description" error, describe the uncommitted work or ask your human partner for guidance
- [ ] Make changes to files
- [ ] Call `checkpoint()` with meaningful summaries (as often as needed)
- [ ] Call `finishChange()` when done
- [ ] Verify with `jj log` that task change looks correct

## Real-World Impact

**Without this pattern:** Changes are monolithic, no visibility into progress, hard to review.

**With this pattern:**
- Each checkpoint is documented
- Task description shows incremental progress
- Single reviewable change with clear history
- Easy to resume work or backtrack
