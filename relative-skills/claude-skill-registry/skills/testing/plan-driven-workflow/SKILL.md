---
name: plan-driven-workflow
description: Follow plan.md-driven development workflow with strict TDD discipline. Use when the user says "go", references plan.md, asks to proceed with next test or task, create implementation plan, or needs step-by-step test-driven development from a plan file. Enforces one test at a time with explicit user control.
---

# Plan-Driven Workflow

## Instructions

Always follow the instructions in plan.md when this workflow is activated.

### Activation

When the user says **"go"**:
1. Find the next unmarked test in plan.md
2. Implement that test
3. Implement only enough code to make that test pass

### Workflow Steps

1. **Create plan.md**:
   - Before starting development, create a plan.md file outlining tests or tasks to implement.
   - Each test/task should be clearly described and unmarked (not yet completed).

2. **Read plan.md**
   - Locate the plan file in the project
   - Identify the next unmarked/incomplete test or task

3. **Implement the test**
   - Write the test exactly as specified in plan.md
   - Follow TDD principles (Red phase)
   - Run the test to confirm it fails

4. **Implement minimum code**
   - Write only enough code to make the test pass
   - Follow the simplest solution that could work
   - Run the test to confirm it passes (Green phase)

5. **Mark as complete**
   - Update plan.md to mark the test as complete
   - Consider if refactoring is needed

6. **Wait for next "go"**
   - Do not proceed to the next test automatically
   - Wait for user to say "go" again

### Plan File Format

The plan.md file typically contains:
- [ ] Unmarked tests (not yet implemented)
- [x] Marked tests (completed)
- Test descriptions or specifications
- Acceptance criteria

### Key Principles

- **One test at a time**: Only implement one test per "go" command
- **Minimum implementation**: Write the smallest amount of code to pass
- **Wait for instruction**: Do not auto-advance to the next test
- **Follow TDD**: Always maintain Red → Green → Refactor discipline
- **Update plan**: Mark tests as complete in plan.md

### Integration with TDD

This workflow enforces strict TDD discipline by:
- Ensuring tests are written before code
- Limiting scope to one test at a time
- Maintaining explicit user control over progress
- Documenting progress in plan.md

### Example Interaction

**User**: "Please write the plan.md for adding a calculator feature."

**Assistant**:
1. Creates plan.md with description of the feature and tests:
```
# Calculator

## Feature description

create a simple calculator with basic operations: add, subtract, multiply, divide.

## Tests
- [ ] Test that Add(2, 3) returns 5
- [ ] Test that Subtract(5, 3) returns 2
- [ ] Test that Multiply(2, 3) returns 6
- [ ] Test that Divide(6, 3) returns 2
```

**User**: "go"

**Assistant**:
1. Reads plan.md
2. Finds: "[ ] Test that Add(2, 3) returns 5"
3. Writes the test
4. Runs test (Red)
5. Implements Add function
6. Runs test (Green)
7. Updates plan.md: "[x] Test that Add(2, 3) returns 5"
8. Waits for next "go"

### Benefits

- **Explicit control**: User controls pace of development
- **Clear progress**: Plan file shows what's done and what's next
- **Prevents over-implementation**: Can't skip ahead
- **Enforces TDD**: Each step follows proper cycle
- **Accountability**: Clear record of completed work
