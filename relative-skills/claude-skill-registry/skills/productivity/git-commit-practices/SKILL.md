---
name: git-commit-practices
description: |
  CRITICAL: ALWAYS activate this skill at the start of ANY task in a git
  repository. ALWAYS activate this skill when the user asks you to commit. 
  Check git status first - if on feature/topic branch, activate
  immediately. If on master/main, create a feature branch first, then activate.
  If not in git repo, skip. This skill guides continuous atomic commits
  throughout work sessions. Key trigger: ANY task involving code changes in a
  git repo. Plan commits during planning phase, execute continuously during
  implementation. Commit early, commit often - one concern per commit. Never
  batch commits at the end. (project, gitignored)
---

# Git Commit Practices

**CRITICAL: Commit early, commit often, one concern per commit!**

This skill ensures you follow proper git commit practices to maintain clean, reviewable git history.

## Automatic Activation Workflow

**This skill should be automatically activated based on git repository status:**

### Workflow Steps

1. **Check if in git repository** - At the start of any work session or task
   ```bash
   git status
   # or
   git branch --show-current
   ```

2. **If in a git repository:**
   - **On a feature/topic branch** → Activate this skill and follow commit-early-often practices
   - **On master/main branch** → Create a new branch with a descriptive name, then activate this skill
   - **Use the skill throughout the session** - Make atomic commits after each logical change

3. **If NOT in a git repository:**
   - Skip this skill (git commit practices don't apply)

### Branch Creation When on master/main

If you find yourself on the master or main branch:

```bash
# Create a new descriptive branch
git checkout -b feature-name

# Examples of good branch names:
# - fix-parser-error
# - add-export-feature
# - refactor-authentication
# - update-documentation
```

Then activate this skill and proceed with atomic commits.

### Integration into Workflow

This means:
- **Proactively check** `git status` when starting work
- **Automatically activate** this skill when in a git repo on a feature branch
- **Create branches** when on master/main before making any commits
- **Make atomic commits** throughout the work session, not just at the end
- **Skip the skill** entirely when not in a git repository

**Example:**
```
Task starts → Check git status → On feature branch → Activate skill →
Work on change → Complete logical unit → Commit → Continue working
```

## Planning Commit Milestones

**During the planning phase**, before implementation begins, identify commit milestones. Commits should be planned, not an afterthought.

### Workflow

1. **When creating a task plan** - Identify natural commit points
2. **Mark commit milestones** - Note where atomic commits should occur
3. **Execute continuously** - Commit at each milestone as you reach it

### Example: Planning a Feature

Task: "Add user authentication"

**Bad approach (commits as afterthought):**
```
Plan:
1. Add user model
2. Add API endpoint
3. Add UI component
4. Add tests

[Then at end: "Now let's commit everything"]
```

**Good approach (commits planned upfront):**
```
Plan with commit milestones:
1. Add user model → COMMIT: "Add user authentication data model"
2. Add API endpoint → COMMIT: "Add user authentication API endpoint"
3. Add UI component → COMMIT: "Add user authentication UI component"
4. Add tests → COMMIT: "Add user authentication tests"
```

### Integration with TodoWrite

When using TodoWrite tool, each todo item is a potential commit milestone:

```
Todo: "Add input validation to form"
├── Implementation work
├── Verify it works
└── COMMIT immediately → Mark todo completed
```

**Never batch commits at task completion.**

## Core Principle: Atomic Commits

Each commit should represent **one logical change** - a single fix, feature, or refactoring that can be understood, reviewed, and reverted independently.

### Benefits of Atomic Commits
- **Easier code review** - Reviewers can understand one change at a time
- **Safer reverts** - Can undo specific changes without losing other work
- **Clearer history** - Git log tells the story of the project
- **Better debugging** - Git bisect works effectively
- **Professional workflow** - Industry standard practice

## When to Commit

### ✅ Commit Immediately After

1. **Fixing a single bug** - One bug, one commit
2. **Completing a logical unit** - Function works, tests pass
3. **Refactoring one aspect** - Before and after are both working states
4. **Adding one feature component** - Each independent piece
5. **Updating documentation** - Separate from code changes
6. **Making configuration changes** - Isolated from feature work
7. **Quoted all variables in one file** - Before moving to next file
8. **Fixed one specific issue** - Don't bundle unrelated fixes

### ❌ Don't Wait Until

- You've fixed "everything"
- The entire feature is complete
- You've made changes to many files
- End of the day/session
- You remember to commit

## Commit Granularity Guide

### Perfect Granularity Examples

**Scenario: Fixing critical bugs in grading scripts**

Bad (what you did):
```
✗ One commit: "Fix critical bugs in grading scripts"
  - Fixed timestamp bug
  - Fixed undefined variable
  - Fixed SSH injection
  - Quoted all variables everywhere
  (5 files, 90 insertions, 88 deletions)
```

Good (what you should have done):
```
✓ Commit 1: "Fix terminal grading timestamp format mismatch"
  modules/terminal/grading/grade.sh.nw | 2 +-

✓ Commit 2: "Fix LaTeX grading undefined variable reference"
  modules/latex/grading/grade.sh.nw | 8 ++++----

✓ Commit 3: "Fix SSH command injection in common.sh"
  adm/grading/common.sh.nw | 3 ++-

✓ Commit 4: "Quote variables in common.sh for safety"
  adm/grading/common.sh.nw | 12 ++++++------

✓ Commit 5: "Quote variables in git grading script"
  modules/git/grading/grade.sh.nw | 8 ++++----

✓ Commit 6: "Quote variables in latex grading script"
  modules/latex/grading/grade.sh.nw | 12 ++++++------

✓ Commit 7: "Quote variables in ssh grading script"
  modules/ssh/grading/grade.sh.nw | 6 +++---

✓ Commit 8: "Quote variables in terminal grading script"
  modules/terminal/grading/grade.sh.nw | 10 +++++-----
```

### More Examples

**Scenario: Adding a new feature**
```
✓ Commit 1: "Add user authentication data model"
✓ Commit 2: "Add user authentication API endpoint"
✓ Commit 3: "Add user authentication UI component"
✓ Commit 4: "Add user authentication tests"
✓ Commit 5: "Add user authentication documentation"
```

**Scenario: Refactoring**
```
✓ Commit 1: "Extract validation logic to separate function"
✓ Commit 2: "Rename ambiguous variable names for clarity"
✓ Commit 3: "Remove unused imports and dead code"
```

### What Constitutes "One Logical Change"?

A single logical change is one **conceptual** modification that can be described
with a single purpose statement, even if it touches multiple files or locations.

**Example: Replacing magic numbers with constants**

Bad (too granular - split what should be one commit):
```
✗ Commit 1: "Define threshold constants at module level"
✗ Commit 2: "Use constants for command-line argument defaults"
✗ Commit 3: "Use constants for function parameter defaults"
✗ Commit 4: "Use constants in documentation"
```

Good (single logical change):
```
✓ One commit: "Replace hardcoded threshold values with named constants"
  - Define DEFAULT_THRESHOLD_FIXED and DEFAULT_THRESHOLD_PERCENT
  - Update argument parser defaults to use constants
  - Update function parameter defaults to use constants
  - Update documentation to reference constants
```

**Why this is one commit:**
- Single conceptual change: "eliminate magic numbers"
- Changes are not independently useful (defining constants without using them
  accomplishes nothing)
- Would never want to revert just part of this change
- Reviewer understands the complete picture in one diff

**Contrast with truly independent changes:**
```
✓ Commit 1: "Add --threshold-fixed option"
  (Independent: adds new functionality)

✓ Commit 2: "Add --threshold-percent option"
  (Independent: adds different functionality)

✓ Commit 3: "Replace hardcoded values with constants"
  (Independent: refactoring that doesn't add features)
```

**Rule of thumb:** If you can't describe the change without using "and" to link
unrelated concepts, it should be multiple commits. But if "and" connects steps
of the same change, it's one commit.

- "Add user model **and** update constants" → Two commits
- "Define constants **and** use them everywhere" → One commit

## Workflow for Multiple Changes

### Step-by-Step Process

When you have multiple fixes to make:

1. **Fix the first issue**
   ```bash
   # Make the change
   vim file1.nw

   # Verify it works (if applicable)
   make

   # Commit immediately
   git add file1.nw
   git commit -m "Fix specific issue in file1"
   ```

2. **Fix the second issue**
   ```bash
   # Make the change
   vim file2.nw

   # Commit immediately
   git add file2.nw
   git commit -m "Fix specific issue in file2"
   ```

3. **Continue for each issue**
   - Never batch multiple fixes
   - Each commit should be independently reviewable

### Interactive Staging for Mixed Changes

If you've already made multiple changes (not ideal but happens):

```bash
# Stage changes selectively
git add -p file.nw

# Review what's staged
git diff --staged

# Commit the staged portion
git commit -m "First logical change"

# Repeat for remaining changes
git add -p file.nw
git commit -m "Second logical change"
```

## Commit Message Guidelines

### Format

```
Short summary (50 chars or less)

Detailed explanation if needed:
- What changed
- Why it changed
- Impact or implications

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Summary Line Rules

- **Imperative mood**: "Fix bug" not "Fixed bug" or "Fixes bug"
- **Capitalize first word**: "Add feature" not "add feature"
- **No period at end**: "Update docs" not "Update docs."
- **Be specific**: "Fix timestamp mismatch in terminal grading" not "Fix bug"
- **Stay under 50 characters** when possible

### Good vs Bad Messages

**Bad:**
```
✗ "Fix stuff"
✗ "Updates"
✗ "WIP"
✗ "Fixed various issues"
✗ "Changes to multiple files"
```

**Good:**
```
✓ "Fix timestamp format mismatch in terminal grading"
✓ "Remove undefined variable from check_student"
✓ "Quote variables in common.sh for space safety"
✓ "Add error handling for missing config file"
```

## Proactive Reminders

### During Planning Phase

When creating a plan (using plan mode or TodoWrite):
- **Identify commit milestones** - Each major step should have a planned commit
- **Include commit messages** - Plan what each commit will say
- **Map todos to commits** - One todo = one commit (approximately)

This ensures commits are intentional, not an afterthought.

### After Reading Multiple Files

If you read multiple files to understand an issue:
- **Don't fix them all at once**
- Fix the first one and commit
- Then move to the next

### After Making a Plan

If you create a todo list with multiple items:
- **Commit after completing each todo item**
- Don't wait until all items are complete
- Each item should ideally be one commit

### When User Says "Fix all..."

If user requests fixing multiple issues:
- **Clarify**: "I'll fix these one at a time and commit each separately"
- **Proceed sequentially**: Fix, commit, next
- **Update user**: "Fixed X (committed), now working on Y"

## Red Flags (Stop and Commit)

Watch for these signs you should commit NOW:

1. **Multiple file changes** - If you've modified 3+ files, you've probably done multiple things
2. **Large diffs** - If `git diff` output is long, break it up
3. **Mixed concerns** - If commit message needs "and", split it
4. **Time passing** - If 15+ minutes since last commit, commit something
5. **Before switching tasks** - Always commit current work before starting new work
6. **After "done"** - When you think "that works", commit it

## Exception: When to Combine

Very rarely, commits can be combined IF:

1. **Mechanical changes** - Same operation applied everywhere (e.g., "Rename function X to Y across codebase")
2. **Tiny fixes** - Fixing typos in multiple places
3. **Broken state** - Change #1 breaks build and change #2 fixes it (but avoid this situation)

**Default rule**: When in doubt, commit separately.

## Integration with TodoWrite

When using TodoWrite tool:

```
Todo item completed → Commit immediately → Mark todo as completed
```

**Not:**
```
Complete all todos → One big commit → Mark all completed
```

## Branch Safety: Never Commit Directly to main/master

**CRITICAL**: Before making any commits, verify you're on the correct branch.

### Pre-Commit Branch Check

```bash
# Always check current branch first
git branch --show-current
```

**Rules:**
- ✅ **NEVER** commit directly to `main` or `master` branches
- ✅ **ALWAYS** work on a feature/topic branch
- ✅ **ASK** the user about the branch if uncertain

### Branch Workflow

**Before starting work:**
```bash
# Check current branch
git branch --show-current

# If on main/master, ask user:
# "I see you're on the main branch. Should I create a feature branch
# or switch to an existing one before making changes?"
```

**If user hasn't specified a branch:**
- Ask which branch to use
- Suggest creating a descriptive branch name based on the work
- Wait for confirmation before committing

**Example dialogue:**
```
User: "Please fix the bug in authentication.py"
Assistant: "I see you're currently on the main branch. Should I create
a new branch like 'fix-authentication-bug' for these changes, or would
you like to use an existing branch?"
```

### Creating Feature Branches

```bash
# Create and switch to new branch
git checkout -b feature-name

# Verify you're on the new branch
git branch --show-current
```

**Branch naming conventions:**
- Use descriptive names: `fix-auth-bug` not `fix1`
- Use hyphens: `add-user-feature` not `add_user_feature`
- Be specific: `fix-timestamp-parsing` not `fixes`

### Checking Branch Suitability

**Before committing to an existing branch, verify it's suitable for the current work:**

When you're about to commit changes:
1. Check the current branch name
2. Assess if the work matches the branch purpose
3. If uncertain or mismatched, ask the user

**When to ask about branching:**
- Current branch name doesn't match the work being done
  - Example: On `fix/calendar-stdlib-shadowing` but working on a different issue
- Work is independent and could be a separate PR
  - Example: Removing duplicate code (separate concern from renaming modules)
- Preferring to branch from master/main for independence
  - Allows PRs to be merged independently without dependencies

**Example dialogue:**
```
Assistant: "I notice we're on branch 'fix/calendar-stdlib-shadowing' which is for
renaming the calendar module. The current fix (removing duplicate format_canvas_time)
is a separate concern. Should I:"

Options presented to user:
1. "Create new branch from master" - For independent PR, cleaner separation
2. "Create new branch from current" - If this fix depends on the rename
3. "Use current branch" - Group related cleanup together in one PR
```

**Benefits of proper branching:**
- **Independent PRs** - Each fix can be reviewed and merged separately
- **Clearer history** - Branch names accurately describe their changes
- **Easier rollback** - Can revert one fix without affecting others
- **Better collaboration** - Multiple people can work on different branches

**Branching strategy preference:**
- **Branch from master/main when possible** - Makes PRs independent
- **Branch from feature branch only when** - The new work depends on uncommitted changes
- **Use current branch only when** - Changes are closely related and belong together

### Exception: Repository-Specific Workflows

Some repositories may allow direct commits to main (e.g., personal notes, documentation repos). In these cases:
- User will explicitly confirm it's acceptable
- Still follow atomic commit practices
- Consider the repository's workflow

## Checklist for Each Commit

Before committing, verify:

- [ ] **On correct branch** - Not on main/master (unless explicitly approved)
- [ ] This commit represents ONE logical change
- [ ] The commit message clearly describes what changed
- [ ] All related changes are included (nothing missing)
- [ ] No unrelated changes are included (nothing extra)
- [ ] The code works/builds at this commit (if applicable)
- [ ] The commit can be understood independently
- [ ] **No generated files** - If literate programming project, verify no .py/.tex files with .nw sources are staged

## Special Case: Literate Programming Projects

**CRITICAL WARNING**: In literate programming projects (using noweb, .nw files), NEVER commit generated files.

### Pre-Commit Validation for Literate Projects

Before committing in a project with .nw files:

```bash
# Check what's staged
git diff --staged --name-only

# Look for generated files that shouldn't be committed
# A file is generated if there's a corresponding .nw file
```

### Common Mistake: Committing Generated Files

**BAD** - Committing generated files:
```bash
✗ git add src/module.py    # Generated from module.nw - DO NOT COMMIT
✗ git add src/module.tex   # Generated from module.nw - DO NOT COMMIT
✗ git commit -m "Update module"
```

**GOOD** - Only committing source:
```bash
✓ git add src/module.nw    # Source file - OK to commit
✓ git commit -m "Update module to add new feature"
```

### Identifying Generated Files

A .py or .tex file is **generated** (DO NOT COMMIT) if:
- There's a corresponding .nw file with same base name
- It's listed in a Makefile as a target from notangle/noweave
- The project uses literate programming

A .py file is **source** (OK to commit) if:
- No .nw file exists with same name
- It's a hand-written file (like some `__init__.py` files)
- It's explicitly marked as an exception in .gitignore

### Fixing Accidentally Committed Generated Files

If you discover generated files in git:

```bash
# Untrack but keep in working directory
git rm --cached path/to/generated.py
git rm --cached path/to/generated.tex

# Update .gitignore to prevent future accidents
# Then commit the .gitignore changes
git add .gitignore
git commit -m "Remove generated files from version control"

# Regenerate fresh files from .nw sources
make
```

### Integration with Literate Programming Workflow

In literate programming projects:

1. **Edit .nw files** - Make changes to literate source
2. **Regenerate code** - Run `make` or `notangle` to generate .py/.tex
3. **Test the changes** - Verify generated code works
4. **Commit ONLY .nw** - Never commit the generated files
5. **Let .gitignore work** - Ensure .gitignore covers all generated files

## Recovery from Large Commits

If you've already made a large commit with multiple concerns:

### Option 1: Accept and Move Forward
- Learn from it for future commits
- Don't amend/rewrite if already pushed

### Option 2: Split with Interactive Rebase (if not pushed)
```bash
# Reset to before the commit
git reset HEAD~1

# Stage and commit each logical piece
git add -p
git commit -m "First logical change"

git add -p
git commit -m "Second logical change"
```

## Summary

**Remember:**
1. **Commit early and often** - After each logical unit of work
2. **One concern per commit** - Each commit is independently reviewable
3. **Good messages** - Future you (and reviewers) will thank you
4. **Before refactoring** - Save working state first
5. **Stop and commit** - When any red flag appears

**The mantra:** "Working state reached → Commit now → Continue working"
