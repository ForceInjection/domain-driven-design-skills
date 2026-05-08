---
name: Workflow Execution
description: This skill should be used when implementing tracks, following workflow methodologies, updating plan status, or when the user asks about "TDD workflow", "how to follow workflow", "task execution", "phase completion", or "status updates". Provides patterns for executing work according to defined methodologies.
version: 0.1.0
---

# Workflow Execution

This skill provides patterns for executing Conductor tracks according to defined workflow methodologies, updating progress, and verifying completion.

## Overview

Workflow execution is the implementation phase where plans become reality. This skill covers:
- Following workflow methodologies (TDD, BDD, standard)
- Updating plan status in real-time
- Phase completion verification
- Commit strategies
- Error handling during implementation

## Workflow Methodologies

### Test-Driven Development (TDD)

**Pattern**: Red → Green → Refactor

For each task requiring code:
1. **Write Test**: Create failing test that defines expected behavior
2. **Run Test**: Execute test, verify it fails (Red)
3. **Implement**: Write minimal code to make test pass
4. **Run Test**: Execute test, verify it passes (Green)
5. **Refactor**: Improve code quality without changing behavior
6. **Run Test**: Execute test again, verify still passes

**Example Task**:
```markdown
### [~] Task: Add user email validation
- [x] Sub-task: Write email validation tests
- [x] Sub-task: Run tests (expect failure)
- [~] Sub-task: Implement validation logic
- [ ] Sub-task: Run tests (expect pass)
- [ ] Sub-task: Refactor for clarity
- [ ] Sub-task: Run tests (verify still passes)
```

### Behavior-Driven Development (BDD)

**Pattern**: Specify → Implement → Verify

For each task:
1. **Specify**: Define behavior in Given-When-Then format
2. **Implement**: Write code to satisfy specification
3. **Verify**: Run scenarios to confirm behavior

### Standard Workflow

**Pattern**: Implement → Test → Review

For each task:
1. **Implement**: Write the code or make the change
2. **Test**: Verify it works (manual or automated)
3. **Review**: Check code quality and standards

## Status Management

### Status Markers

Update plan.md markers as work progresses:

| Transition | When | Example |
|------------|------|---------|
| `[ ]` → `[~]` | Starting work | Beginning a task |
| `[~]` → `[x]` | Completing work | Finishing a task |
| `[~]` → `[!]` | Encountering blocker | Cannot proceed |
| `[!]` → `[~]` | Resolving blocker | Resuming work |

### Real-Time Updates

Update plan.md immediately when status changes:
1. Read current plan.md
2. Update status marker
3. Write updated plan.md
4. Commit change (if using per-task commits)

### TodoWrite Integration

Mirror plan.md structure in TodoWrite:
- Create todos for phases, tasks, sub-tasks
- Update todo status when plan.md status changes
- Keep both synchronized throughout implementation

## Phase Completion Verification

### Automated Checks

Run at phase boundaries:

**Tests**:
```bash
npm test          # JavaScript/TypeScript
pytest            # Python
go test ./...     # Go
mvn test          # Java
```

**Build**:
```bash
npm run build     # JavaScript/TypeScript
python setup.py build  # Python
go build          # Go
mvn package       # Java
```

**Linting**:
```bash
npm run lint      # JavaScript/TypeScript
pylint src/       # Python
golangci-lint run # Go
```

**Type Checking**:
```bash
npx tsc --noEmit  # TypeScript
mypy src/         # Python
```

### User Confirmation

After automated checks, present results and ask:
- Question: "Phase '<Phase Name>' is complete. Verification results: [summary]. Ready to proceed?"
- Options:
  - "Yes, proceed to next phase"
  - "No, let me review/fix issues"

If issues found, halt and await user instructions.

## Commit Strategies

### Conventional Commits

Format: `type(scope): description`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `test`: Adding tests
- `docs`: Documentation
- `chore`: Maintenance

**Examples**:
```bash
git commit -m "feat(auth): add user registration endpoint"
git commit -m "test(auth): add registration validation tests"
git commit -m "conductor(plan): mark registration task complete"
```

### Commit Frequency

**Per Task**:
- Commit after each task completion
- Include task description in commit message
- Update plan.md in same commit

**Per Phase**:
- Commit after each phase completion
- Include phase summary in commit message
- Update plan.md and tracks.md in same commit

### Plan Update Commits

Always commit plan.md updates:
```bash
git add conductor/tracks/<track_id>/plan.md
git commit -m "conductor(plan): Update <task/phase> status"
```

## Error Handling

### Task Failures

If implementation fails:
1. Mark task as blocked: `[!]`
2. Document blocker in plan.md
3. Update TodoWrite status
4. Inform user with error details
5. Ask how to proceed:
   - "Retry this task"
   - "Skip and continue"
   - "Halt implementation"

### Test Failures

If tests fail during verification:
1. Present test output to user
2. Mark phase as needs-review
3. Ask: "Tests failed. How to proceed?"
   - "Fix issues now"
   - "Continue anyway (not recommended)"
   - "Halt and review"

### Build Failures

If build fails:
1. Present build output
2. Halt implementation
3. Inform: "Build failed. Please fix issues before continuing."
4. Do not proceed to next phase

## Phase-Level Execution Pattern

For each phase:

1. **Announce Phase Start**:
   ```
   🚀 Starting Phase: <Phase Name>
   Tasks in this phase: <N>
   ```

2. **Execute Tasks Sequentially**:
   - For each task in phase:
     - Mark as in_progress: `[~]`
     - Follow workflow methodology
     - Implement the task
     - Mark as completed: `[x]`
     - Update TodoWrite

3. **Run Automated Checks**:
   - Execute tests
   - Run build
   - Check linting
   - Verify type checking

4. **User Verification**:
   - Present check results
   - Ask for confirmation
   - If approved, continue
   - If not, halt and await instructions

5. **Update Phase Status**:
   - Mark phase as complete
   - Commit changes
   - Proceed to next phase

## Context Loading

Before implementing, load all context:
1. `conductor/tracks/<track_id>/spec.md` - Requirements
2. `conductor/tracks/<track_id>/plan.md` - Implementation plan
3. `conductor/workflow.md` - Methodology
4. `conductor/tech-stack.md` - Technical constraints
5. `conductor/product.md` - Product context
6. `conductor/code_styleguides/` - Style standards

## Tips for Implementation

1. **Follow the Plan**: Don't deviate without updating plan first
2. **Update in Real-Time**: Keep plan.md current as you work
3. **Commit Frequently**: Per task or phase, not at the end
4. **Run Checks**: Automated verification at phase boundaries
5. **Respect Methodology**: Follow TDD/BDD/standard as defined
6. **Handle Errors Gracefully**: Mark blockers, inform user, await instructions
7. **Verify Completion**: Don't skip phase verification steps
8. **Keep User Informed**: Announce progress throughout

## Additional Resources

- **`references/tdd-patterns.md`** - Detailed TDD workflows
- **`references/commit-strategies.md`** - Advanced commit patterns
- **`examples/workflow-execution/`** - Real-world execution examples
