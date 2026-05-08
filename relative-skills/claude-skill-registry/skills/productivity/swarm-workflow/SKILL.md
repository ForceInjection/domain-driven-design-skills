---
name: swarm-workflow
description: Split large tasks across multiple Claude Code sessions or branches. Coordinate parallel work with merge gates. Use when task is too large for one session, want parallel work, or need to split work across branches.
allowed-tools: Read, Grep, Glob
---

# Swarm Workflow

Coordinates parallel work across multiple sessions and branches.

## When to Use

- "This is too big for one session"
- "Split this into parallel tasks"
- "How do I swarm this?"
- "Divide and conquer this feature"
- "Parallel development workflow"

## Swarm Strategy

### When to Swarm

- Task touches 5+ unrelated files
- Multiple independent features in one request
- Long-running task risks context overflow
- Work can proceed in parallel without blocking

### When NOT to Swarm

- Simple single-file changes
- Tightly coupled changes that must be atomic
- Exploratory work where scope is unclear
- Tasks requiring deep context continuity

## Branch Strategy

```
main
├── feature/task-a-auth
├── feature/task-b-api
├── feature/task-c-ui
└── feature/integration (merge point)
```

### Naming Convention

```
feature/{task-id}-{short-description}
```

### Merge Order

1. Independent branches merge to integration branch
2. Resolve conflicts in integration
3. Integration branch merges to main

## Procedure

### Step 1: Analyze Task

Break down the request into independent units:

```markdown
## Task Decomposition

### Original Request

{user's request}

### Independent Units

1. **{Unit A}**
   - Files: {list}
   - Dependencies: none
   - Can run parallel: yes

2. **{Unit B}**
   - Files: {list}
   - Dependencies: Unit A types only
   - Can run parallel: yes (with interface)

3. **{Unit C}**
   - Files: {list}
   - Dependencies: Units A and B
   - Must wait for: A, B to complete
```

### Step 2: Define Interfaces

For units that depend on each other, define interfaces first:

```typescript
// Shared interface (commit first)
export interface UserService {
  getUser(id: string): Promise<User>;
  updateUser(id: string, data: Partial<User>): Promise<User>;
}
```

### Step 3: Create Branch Plan

```markdown
## Branch Plan

### Branch 1: feature/task-auth

- Assignee: Session 1
- Files:
  - packages/auth/src/...
  - apps/web/app/api/auth/...
- Tests: packages/tests/src/auth.\*.test.ts
- Definition of Done:
  - [ ] Auth endpoints working
  - [ ] Tests passing
  - [ ] TypeScript compiles

### Branch 2: feature/task-api

- Assignee: Session 2
- Files:
  - apps/web/app/api/users/...
- Tests: packages/tests/src/users.test.ts
- Definition of Done:
  - [ ] CRUD endpoints working
  - [ ] Tests passing
  - [ ] TypeScript compiles

### Merge Gate

- [ ] All branches pass CI
- [ ] No merge conflicts
- [ ] Integration tests pass
```

### Step 4: Handoff Instructions

For each branch/session:

```markdown
## Session Handoff: {Branch Name}

### Context

{Brief description of overall task}

### Your Assignment

{Specific work for this session}

### Files to Modify

- {file1}: {what to do}
- {file2}: {what to do}

### Interfaces to Use (Do Not Modify)

- {interface file}

### Definition of Done

1. {criterion 1}
2. {criterion 2}
3. pnpm typecheck passes
4. pnpm lint passes
5. Tests pass

### When Complete

1. Commit with message: "{conventional commit}"
2. Push to branch: {branch-name}
3. Create PR to: feature/integration
```

## Merge Gates

### Before Merge to Integration

- [ ] CI passes on branch
- [ ] No uncommitted changes
- [ ] All DoD criteria met
- [ ] PR reviewed (if required)

### Before Merge to Main

- [ ] All branches merged to integration
- [ ] Conflicts resolved
- [ ] Full test suite passes
- [ ] Integration testing complete

## Guardrails

- ALWAYS define interfaces before parallel work
- NEVER have two branches modify same file
- Commit interfaces first, then implementations
- Each branch must pass CI independently
- Merge frequently to avoid drift
- Document assumptions in PR descriptions
