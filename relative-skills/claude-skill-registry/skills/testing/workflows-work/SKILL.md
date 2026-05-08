---
name: workflows-work
description: This skill should be used when executing work plans, specifications, or todo files systematically while maintaining quality and shipping complete features.
---

# Work Plan Execution Skill

Execute a work plan efficiently while maintaining quality and finishing features.

## Input

Reference the work document (plan, specification, or todo file) using `@file/path/to/plan.md`.

## Execution Workflow

### Phase 1: Quick Start

1. **Read Plan and Clarify**
   - Read the work document completely
   - Review any references or links provided in the plan
   - If anything is unclear or ambiguous, ask clarifying questions now
   - Get user approval to proceed
   - **Do not skip this** - better to ask questions now than build the wrong thing

2. **Setup Environment**

   Choose work style:

   **Option A: Live work on current branch**
   ```bash
   git checkout main && git pull origin main
   git checkout -b feature-branch-name
   ```

   **Option B: Parallel work with worktree (recommended for parallel development)**
   
   Use `@skill/git-worktree` to create a new branch from main in an isolated worktree.

   **Recommendation**: Use worktree if:
   - Working on multiple features simultaneously
   - Keeping main clean while experimenting
   - Planning to switch between branches frequently

   Use live branch if:
   - Working on a single feature
   - Prefer staying in the main repository

3. **Create Todo List**
   - Maintain a todo list (in a markdown file or inline) to break plan into actionable tasks
   - Include dependencies between tasks
   - Prioritize based on what needs to be done first
   - Include testing and quality check tasks
   - Keep tasks specific and completable

### Phase 2: Execute

1. **Task Execution Loop**

   For each task in priority order:

   ```
   while (tasks remain):
     - Mark task as in_progress
     - Read any referenced files from the plan
     - Look for similar patterns in codebase
     - Implement following existing conventions
     - Write tests for new functionality
     - Run tests after changes
     - Mark task as completed
   ```

2. **Follow Existing Patterns**
   - The plan should reference similar code - read those files first
   - Match naming conventions exactly
   - Reuse existing components where possible
   - Follow project coding standards (see @file/AGENTS.md)
   - When in doubt, grep for similar implementations

3. **Test Continuously**
   - Run relevant tests after each significant change
   - Don't wait until the end to test
   - Fix failures immediately
   - Add new tests for new functionality

4. **Track Progress**
   - Keep todo list updated as tasks complete
   - Note any blockers or unexpected discoveries
   - Create new tasks if scope expands
   - Keep user informed of major milestones

### Phase 3: Quality Check

1. **Run Core Quality Checks**

   Always run before submitting:
   - Run full test suite
   - Run linting per project configuration

2. **Review Guidance** (Optional for complex changes)

   For large, risky, or complex changes, consider using:
   - `@guidance/code-simplicity-review` - Check for unnecessary complexity
   - `@guidance/rails-review` - Verify Rails conventions (Rails projects)
   - `@guidance/performance-review` - Check for performance issues
   - `@guidance/security-review` - Scan for security vulnerabilities

3. **Final Validation**
   - All todo tasks marked completed
   - All tests pass
   - Linting passes
   - Code follows existing patterns
   - No console errors or warnings

### Phase 4: Ship It

1. **Create Commit**

   ```bash
   git add .
   git status  # Review what's being committed
   git diff --staged  # Check the changes

   # Commit with conventional format
   git commit -m "feat(scope): description of what and why"
   ```

2. **Create Pull Request**

   ```bash
   git push -u origin feature-branch-name
   gh pr create --title "Feature: [Description]" --body "..."
   ```

   Include in PR description:
   - Summary of what was built and why
   - Testing notes
   - Screenshots for UI changes (before/after)

3. **Notify User**
   - Summarize what was completed
   - Link to PR
   - Note any follow-up work needed

---

## Key Principles

### Start Fast, Execute Faster
- Get clarification once at the start, then execute
- Don't wait for perfect understanding - ask questions and move
- The goal is to **finish the feature**, not create perfect process

### The Plan is Your Guide
- Work documents should reference similar code and patterns
- Load those references and follow them
- Don't reinvent - match what exists

### Test As You Go
- Run tests after each change, not at the end
- Fix failures immediately
- Continuous testing prevents big surprises

### Quality is Built In
- Follow existing patterns
- Write tests for new code
- Run linting before pushing

### Ship Complete Features
- Mark all tasks completed before moving on
- Don't leave features 80% done
- A finished feature that ships beats a perfect feature that doesn't

## Quality Checklist

Before creating PR, verify:

- [ ] All clarifying questions asked and answered
- [ ] All todo tasks marked completed
- [ ] Tests pass
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] Commit messages follow conventional format
- [ ] PR description includes summary and testing notes

## Common Pitfalls to Avoid

- **Analysis paralysis** - Don't overthink, read the plan and execute
- **Skipping clarifying questions** - Ask now, not after building wrong thing
- **Ignoring plan references** - The plan has links for a reason
- **Testing at the end** - Test continuously or suffer later
- **80% done syndrome** - Finish the feature, don't move on early
