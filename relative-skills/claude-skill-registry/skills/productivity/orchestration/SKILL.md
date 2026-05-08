---
name: orchestration
description: Intelligently orchestrate agents to complete tasks with optimal strategy selection, phase breakdown, and quality verification
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, TaskOutput, WebFetch, WebSearch, TodoWrite
---

# Orchestration Skill

Orchestrate agents to complete any task by intelligently breaking it down, selecting the optimal execution strategy, and ensuring complete delivery with quality verification.

## Core Principles

1. **Complete the task fully** - Never stop until everything is done
2. **Choose the right strategy** - Parallel when possible, sequential when necessary
3. **Quality is non-negotiable** - Every phase must pass quality gates
4. **Self-healing** - Fix all issues found in review automatically
5. **Double-check everything** - Verify completion before reporting done
6. **Production-ready code only** - No workarounds, no technical debt, no code smells

## Implementation Standards (CRITICAL)

**Every implementation MUST be production-ready:**

- **No workarounds**: Implement the proper solution, not quick hacks or temporary fixes
- **No technical debt**: Do not defer work with TODOs or "fix later" comments
- **No code smells**: Follow clean code principles, avoid duplication, keep functions focused
- **Full implementation**: Complete the feature end-to-end, including error handling, edge cases, and validation
- **Production quality**: Write code as if it will be deployed immediately after merge

**If the "right" solution is unclear:**

1. Ask for clarification before implementing
2. Research existing patterns in the codebase
3. Choose the approach that is maintainable long-term, not just the fastest to implement

---

## Phase 1: Task Analysis

### Step 1.1: Understand the Task

Parse the task description to identify:

- **Scope**: Backend (Server Components, Actions), frontend (Client Components), full-stack
- **Type**: Feature, bug fix, refactoring, documentation, migration
- **Complexity**: Simple (1-2 files), Medium (3-10 files), Complex (10+ files or architectural)
- **Component type**: Server Component, Client Component, Server Action

### Step 1.2: Explore Codebase

Spawn Explore agent to understand affected areas:

```
Task: Explore codebase for: {task description}

Find:
1. Related existing implementations
2. Patterns and conventions used
3. Files likely to be affected
4. Dependencies and imports
5. Server vs Client component boundaries

Thoroughness: {quick|medium|very thorough based on complexity}
```

### Step 1.3: Break Into Phases

Create atomic phases that can be independently completed. Each phase should:

- Have a single, clear deliverable
- Be testable in isolation
- Take no more than one agent to complete
- Have clear success criteria

Example breakdown for "Add question bookmarking":

```
Phase 1: Database - Add bookmarks table to schema
Phase 2: Backend - Create Server Actions for bookmark operations
Phase 3: Frontend - Build bookmark button component (Client)
Phase 4: Frontend - Integrate bookmark into QuestionCard
Phase 5: Testing - Verify in browser
```

### Step 1.4: Map Dependencies

Create dependency graph:

```
Phase 1 (DB) → Phase 2 (Server Actions) → Phase 3 (UI) + Phase 4 (Integration)
                                        ↘ Phase 5 (Testing)
```

Identify:

- **Independent phases**: Can run in parallel
- **Dependent phases**: Must run sequentially
- **Blocking phases**: Other phases wait for this

---

## Phase 2: Strategy Selection

### Decision Matrix

| Task Characteristics             | Strategy   | Rationale                                    |
| -------------------------------- | ---------- | -------------------------------------------- |
| All phases independent           | Parallel   | Maximum speed                                |
| Linear dependency chain          | Sequential | Each phase needs previous output             |
| Some independent, some dependent | Hybrid     | Parallel where safe, sequential where needed |
| Long-running + quick phases      | Background | Don't block on slow operations               |
| Unknown dependencies             | Sequential | Safest approach                              |

### Parallel Strategy

Use when phases don't share:

- Same files
- Database state
- Generated code
- Global configuration

```
# Spawn multiple agents in ONE message
Task(agent1) + Task(agent2) + Task(agent3)
```

Example: Updating 3 independent components

### Sequential Strategy

Use when:

- Phase N outputs are Phase N+1 inputs
- Database migrations must complete before Server Action work
- Types must be defined before component work

```
# Wait for each to complete before next
Task(phase1) → wait → Task(phase2) → wait → Task(phase3)
```

Example: DB migration → Server Action → Client Component integration

### Background Strategy

Use when:

- Running quality gates while reviewing code
- Building while working on documentation
- Type checking while exploring next phase

```
# Start background task
Task(background_agent, run_in_background=true)

# Continue with other work
Task(foreground_agent)

# Check background result when needed
TaskOutput(background_agent_id)
```

### Hybrid Strategy (Most Common)

Combine strategies based on dependency graph:

```
Phase 1 (DB) - Sequential first
    ↓
Phase 2 (Server Actions) - Sequential, depends on Phase 1
    ↓
Phase 3+4+5 (Components) - Parallel, all depend on Phase 2
    ↓
Phase 6 (Integration) - Sequential, depends on 3+4+5
```

---

## Phase 3: Execution

### Step 3.1: Initialize Tracking

Use TodoWrite to track all phases:

```typescript
TodoWrite([
  {
    content: 'Phase 1: {description}',
    status: 'pending',
    activeForm: 'Working on Phase 1',
  },
  {
    content: 'Phase 2: {description}',
    status: 'pending',
    activeForm: 'Working on Phase 2',
  },
  // ... all phases
  {
    content: 'Quality gates verification',
    status: 'pending',
    activeForm: 'Running quality gates',
  },
  {
    content: 'Browser verification',
    status: 'pending',
    activeForm: 'Verifying in browser',
  },
])
```

### Step 3.2: Execute Phases

For each phase, spawn the appropriate agent:

#### Software Engineer Agent (Most Common)

```
Task: Implement {phase description}

## Context
- Feature: {overall task}
- Phase: {N} of {total}
- Dependencies completed: {list}

## Deliverables
{specific files and changes expected}

## Constraints
- Follow existing patterns in codebase
- Default to Server Components unless interactivity required
- Use Server Actions for mutations (not API routes)
- No breaking changes to existing functionality
- Leave code in clean, working state

## Verification
{how to verify this phase is complete}

## Quality Gates
After implementation, run:
npm run check
```

### Step 3.3: Monitor and Handle Results

For **sequential** phases:

```
result = await Task(agent)
if (result.failed) {
  // Fix immediately before continuing
  Task(software-engineer, "Fix issue: {error details}")
}
update_todo(phase, "completed")
continue_to_next_phase()
```

For **parallel** phases:

```
// Spawn all at once
task1 = Task(agent1, run_in_background=true)
task2 = Task(agent2, run_in_background=true)
task3 = Task(agent3, run_in_background=true)

// Wait for all
result1 = TaskOutput(task1)
result2 = TaskOutput(task2)
result3 = TaskOutput(task3)

// Handle any failures
for each failed result:
  Task(software-engineer, "Fix: {error}")
```

### Step 3.4: Handle Failures

When an agent fails:

1. **Analyze the error** - Is it a code issue or dependency issue?
2. **Fix immediately** - Spawn software-engineer to fix
3. **Re-verify** - Run the phase again if needed
4. **Update tracking** - Keep todos accurate

```
if phase.failed:
  Todo: Mark phase as "in_progress" again
  Task(software-engineer): "Fix error in Phase {N}: {error details}"
  Verify fix worked
  Then continue
```

---

## Phase 4: Quality Verification

### Step 4.1: Run Quality Gates

After ALL phases complete:

```bash
npm run check && npm run build
```

If any fail:

1. Identify which phase caused the issue
2. Spawn software-engineer to fix
3. Re-run quality gates
4. Loop until all pass

### Step 4.2: Verify in Browser

Test as a user would:

- Start dev server: `npm run dev`
- Open http://localhost:3000 in browser
- Navigate to affected pages/features
- Verify Server/Client component boundaries work
- Test the new functionality end-to-end

### Step 4.3: Fix All Issues

For every issue found:

1. Spawn software-engineer to fix
2. Re-run quality gates
3. Re-verify in browser if significant changes

```
while (issues.length > 0):
  for each issue:
    Task(software-engineer, "Fix: {issue description}")

  run_quality_gates()
  verify_in_browser()
  issues = gather_remaining_issues()
```

---

## Phase 5: Finalization

### Step 5.1: Double-Check Completion

Verify ALL original requirements are met:

```
Original task: {$ARGUMENTS}

Checklist:
[ ] All phases completed and verified
[ ] Quality gates pass
[ ] Browser verification passed
[ ] Code works as expected (end-to-end)
[ ] No regressions introduced
```

### Step 5.2: Final Quality Gates

One more pass to ensure clean state:

```bash
npm run check && npm run build
```

### Step 5.3: Report Completion

Provide summary to user:

```
## Task Complete: {task description}

### Phases Completed
1. {Phase 1} - {status and notes}
2. {Phase 2} - {status and notes}
...

### Changes Made
- {file1}: {what changed}
- {file2}: {what changed}
...

### Quality Status
- TypeScript: ✓
- ESLint: ✓
- Prettier: ✓
- Build: ✓
- Browser: ✓

### Ready for Commit
All changes are ready. Suggested commit message:

{type}({scope}): {description}

- {bullet point 1}
- {bullet point 2}
```

---

## Decision Flowchart

```
START: Analyze Task
         ↓
    Is task simple?
    (1-2 files, single change)
         ↓
   YES → Sequential with single agent
         ↓
   NO → Break into phases
         ↓
    Map dependencies
         ↓
    Are phases independent?
    ├─ ALL YES → Parallel strategy
    ├─ ALL NO → Sequential strategy
    └─ MIXED → Hybrid strategy
         ↓
    Execute phases with chosen strategy
         ↓
    All phases complete?
    ├─ NO → Handle failures, continue
    └─ YES ↓
         ↓
    Run quality gates
         ↓
    All pass?
    ├─ NO → Fix, re-run
    └─ YES ↓
         ↓
    Verify in browser
         ↓
    Issues found?
    ├─ YES → Fix, re-run quality gates, re-verify
    └─ NO → Continue
         ↓
    Double-check requirements
         ↓
    Report completion
         ↓
    END
```

---

## Snowflake Quiz Specific Guidelines

### Quality Gates Command

```bash
npm run check && npm run build
```

`npm run check` runs:
1. TypeScript strict mode checking
2. ESLint with Next.js rules (zero warnings)
3. Prettier formatting check

### Database Changes

When schema changes are needed:

```bash
npm run db:migrate  # Apply Drizzle migrations
```

### Architecture Patterns

#### Server Components (Default)

No 'use client' directive. Can use async/await, direct DB access.

```tsx
// app/stats/page.tsx
import { getStats } from '@/lib/db/queries'

export default async function StatsPage() {
  const stats = await getStats()
  return <StatsDisplay stats={stats} />
}
```

#### Client Components

Must have 'use client'. Use for interactivity.

```tsx
// components/quiz/QuestionCard.tsx
'use client'
import { useState } from 'react'

export function QuestionCard({ question }: Props) {
  const [selected, setSelected] = useState<number[]>([])
  // Interactive logic
}
```

#### Server Actions

For mutations. Mark with 'use server'.

```tsx
// lib/actions/quiz.ts
'use server'
import { revalidatePath } from 'next/cache'

export async function submitAnswer(sessionId: string, answers: number[]) {
  // Save to database
  revalidatePath(`/quiz/${sessionId}`)
}
```

### Key Directories

```
app/                    # Next.js App Router pages
├── layout.tsx          # Root layout (Server)
├── page.tsx            # Home (Server)
├── quiz/               # Quiz routes
├── questions/          # Question browser
└── stats/              # Statistics

components/
├── ui/                 # Base components
├── quiz/               # Quiz components (mostly Client)
├── stats/              # Stats components
└── layout/             # Layout components

lib/
├── db/                 # Database (Drizzle + SQLite)
│   ├── index.ts        # Client
│   ├── schema.ts       # Schema
│   └── queries.ts      # Query functions
├── actions/            # Server Actions
└── utils.ts            # Utilities

types/
└── index.ts            # Shared types
```

### Tech Stack Reference

| Component | Technology |
|-----------|------------|
| Framework | Next.js 15 (App Router) |
| Runtime | React 19 |
| Language | TypeScript 5.9 (strict) |
| Styling | Tailwind CSS 4 |
| Database | SQLite + Drizzle ORM |
| Validation | Zod |
| Charts | Recharts |
