---
name: tdd-go
description: Main TDD workflow command. Finds next test in PLAN.md and executes complete TDD cycle automatically. This is the primary command for TDD development as specified in CLAUDE.md.
---

# GO - TDD Main Workflow

## Overview

This is the primary TDD workflow skill as specified in CLAUDE.md. When the user says "go", this skill finds the next unmarked test in PLAN.md, writes the test, implements it, refactors if needed, and prepares for commit. It's the main driver for TDD development.

## When to Use

Use this skill when:
- User says "go" or "next"
- Ready to start next TDD iteration
- Following CLAUDE.md workflow
- Want automated TDD cycle
- Beginning feature development with TDD

## CLAUDE.md Specification

From CLAUDE.md:
> When I say "go", find the next unmarked test in PLAN.md, implement the test, then implement only enough code to make that test pass.

This skill follows that specification exactly.

## Complete Workflow

### Step 1: Find Next Test

**Locate in PLAN.md:**
1. Read PLAN.md file
2. Find first test that is NOT marked with [x]
3. Understand what behavior needs to be tested
4. Mark test with [ ] to indicate in progress

**If No PLAN.md:**
- Ask user what test to write
- Create PLAN.md if needed
- Document the test plan

**If All Tests Marked:**
- Report completion
- Ask user for next steps
- Suggest reviewing completed work

---

### Step 2: RED - Write the Test

**Execute tdd-red skill:**
1. Write failing test based on PLAN.md item
2. Use Korean description (from LANG.md)
3. Test should fail because feature not implemented
4. Run tests to confirm RED state

**Verify:**
- Test fails for correct reason
- Other tests still pass
- No syntax errors

---

### Step 3: GREEN - Implement Minimum Code

**Execute tdd-green skill:**
1. Implement simplest code to make test pass
2. No extra features
3. No premature optimization
4. Run all tests to confirm GREEN

**Verify:**
- New test passes
- All existing tests pass
- No warnings
- Mark test as [x] in PLAN.md

---

### Step 4: REFACTOR - Improve (If Needed)

**Execute tdd-refactor skill if warranted:**
1. Check for code smells
2. Look for duplication
3. Consider structural improvements
4. Make changes incrementally
5. Keep tests green

**Skip if:**
- Code is already clean
- No obvious improvements
- Would be premature

---

### Step 5: Prepare for Commit

**Report Status:**
- Summary of what was implemented
- Test results (all passing)
- Any refactoring done
- Ready for commit or next cycle

**Commit Guidance:**
- If structural changes: use `/commit-tidy` first
- For behavioral changes: use `/commit-behavior`
- Or continue to next test

---

## Key Behaviors

**Automatic Execution:**
- Finds next test automatically
- Executes RED → GREEN → REFACTOR
- Reports progress throughout
- Suggests next actions

**User Control:**
- User can interrupt at any phase
- Can use individual commands for more control
- Can skip refactoring if not needed
- Maintains flexibility

**Following CLAUDE.md:**
- Strictly follows TDD methodology
- One test at a time
- Minimum code to pass
- Refactor only when green
- Run all tests each time

## Important Principles

**From CLAUDE.md:**
1. Always follow RED → GREEN → REFACTOR
2. Write simplest failing test first
3. Implement minimum code to pass
4. Refactor only after tests passing
5. Separate structural from behavioral changes
6. Maintain high code quality

**TDD Discipline:**
- ONE test at a time
- SIMPLEST implementation
- RUN tests constantly
- REFACTOR when green
- COMMIT appropriately

## Command Integration

This skill orchestrates other TDD skills:
- Uses `tdd-red` for RED phase
- Uses `tdd-green` for GREEN phase
- Uses `tdd-refactor` for REFACTOR phase
- Integrates with commit commands
- Checks PLAN.md for workflow

## Example "Go" Session

```
User: go