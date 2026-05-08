---
name: discovery-tree-workflow
description: Use when planning and tracking work - creates visible, emergent work breakdown using bd (beads) with just-in-time planning and hierarchical task trees
---

# Discovery Tree Workflow

## Overview

Discovery Trees make work visible through hierarchical **outcome** breakdown that emerges just-in-time. Track work with bd (beads), grow the tree as you discover new requirements, coordinate implementing agents through clear, deliverable outcomes.

**Core principle:** Start minimal, plan just-in-time, grow through discovery, make status visible, think in outcomes not steps.

**Announce at start:** "I'm using the Discovery Tree workflow to track this work with bd."

## When to Use

**Always use when:**
- Starting any non-trivial work (more than a single simple task)
- Planning features, bugs, or investigations
- Working with multiple related tasks
- Coordinating work with implementing agents
- Need to make progress visible

**Instead of:**
- TodoWrite for tracking progress
- Upfront detailed planning
- Hidden mental task lists
- Step-by-step task lists
- Linear work breakdown structures

## Core Philosophy

### Outcome Thinking (Not Step Thinking)

**Beads describe WHAT will be true, not HOW to make it true:**

❌ **Step thinking:**
- "Add validation to login form"
- "Create API endpoint"
- "Write tests"

✅ **Outcome thinking:**
- "Invalid login shows clear error message"
- "User can sign in with valid credentials"
- "Login fails safely without revealing account existence"

**Why outcomes?**
- Implementing agents understand the goal, not just the action
- PRs are reviewable against the outcome
- Outcomes can be verified (acceptance criteria)
- Leaves room for agent to choose implementation approach

### Just-in-Time Planning
- Start with minimal detail (one bead describing user value)
- Have short conversations (2-10 minutes) to discover next outcomes
- Don't plan everything upfront - discover what outcomes are needed as you go
- Delays planning until the last responsible moment

### Emergent Work
- New requirements discovered during work → add to tree
- Unexpected complexity → break down into smaller outcomes
- Distractions or ideas → capture as beads, mark low priority
- Tree grows organically as understanding deepens

### Agent Coordination
- Beads are the unit of work for implementing agents
- One bead = one PR = one agent session
- Agents read bead for context, implement outcome, create PR
- Status controlled by orchestrator, not implementing agents

### Visual Status
- Color by status (open, in_progress, closed, blocked)
- Progress visible at a glance
- No context needed to see what's done, active, remaining
- Bottom-up view shows full context for any bead

## The Discovery Tree Workflow

### 1. Create Root Epic and Bead

Every Discovery Tree starts with an epic (container) and a root bead (actual work):

```bash
# Create epic (container for all work)
bd create "Users can securely access their accounts" -t epic -p 1 --json

# Create root bead (describes the user value)
bd create "User authentication system [root]" -t task -p 1 --json

# Link root bead to epic
bd dep add <root-bead-id> <epic-id> -t parent-child
```

**Why both epic and root bead?**
- Epic: Container that tracks overall completion
- Root bead: Actual work item that can have sub-outcomes

**Naming convention:**
- Epic: User-facing value ("Users can...")
- Root bead: Technical outcome ("[system] delivers [capability]")

### 2. Initial Breakdown Conversation

Have a quick conversation (2-10 minutes) to discover first level of **outcomes**:

**Questions to ask:**
- "What outcomes do users need?"
- "What should be true when this is done?"
- "What can we verify independently?"

**NOT:**
- "What steps do we take?"
- "What files do we change?"
- "What functions do we write?"

**Create beads for discovered outcomes:**

```bash
# Think: What will be true?
bd create "User can sign in with email and password" -t task -p 1 --json
bd create "Invalid credentials show clear error message" -t task -p 1 --json
bd create "Session persists across browser restarts" -t task -p 1 --json

# Link them to root bead
bd dep add <bead-id> <root-bead-id> -t parent-child
```

**Add context and acceptance criteria to each bead:**

```bash
bd update <bead-id> --description "
OUTCOME: Invalid credentials show clear error message

CONTEXT:
- Part of authentication epic
- Users currently confused by silent failures
- Security: don't reveal whether email exists

ACCEPTANCE:
- Wrong password shows 'Invalid email or password'
- Wrong email shows same message (no enumeration)
- Error appears within 500ms
- No console errors in browser
"
```

**Don't over-plan:** Stop when you have enough to start. More outcomes emerge as you work.

### 3. Bead Sizing for Agents

**A well-sized bead is:**
- ✅ **Agent-completable**: One agent, one session, done
- ✅ **PR-sized**: Results in one mergeable pull request
- ✅ **Outcome-focused**: Describes what will be true, not what to do
- ✅ **Independently verifiable**: Can test/review without other work
- ✅ **Context-rich**: Contains enough "why" for good decisions

**Too small:**
- "Add import statement"
- "Fix typo in error message"
- One commit, no PR needed

**Just right:**
- "Invalid login shows clear error message"
- "API returns user profile in <200ms"
- "Password reset email arrives within 5 minutes"

**Too large:**
- "Build authentication system"
- "Implement all validation"
- Needs multiple PRs, break down further

**The test:** Can an implementing agent deliver a mergeable PR in one session?

### 4. Coordinating with Implementing Agents

When a bead is ready to implement, spawn an agent (PUSH pattern):

```bash
# Review the bead
bd show wms-123

# Ensure it has:
# - Clear outcome description
# - Relevant context (why this matters)
# - Acceptance criteria (how to verify)

# Spawn implementing agent
/dtw:handoff wms-123
```

**The implementing agent:**
1. Reads bead details (`bd show wms-123`)
2. Implements the outcome in isolated worktree
3. Adds progress comments (`bd comment wms-123 --author "agent-name" "message"`)
4. Creates PR when done
5. Exits

**You (orchestrator):**
1. Review PR against bead's outcome
2. Provide feedback via PR comments
3. When satisfied, merge PR and close bead
4. Update parent bead with completed outcome

**Agent communication via comments:**
```bash
# Implementing agent adds progress notes
bd comment wms-123 --author "wt-redis-impl" "Started Redis approach"
bd comment wms-123 --author "wt-redis-impl" "Found connection timeout issue, adding retry"
bd comment wms-123 --author "wt-redis-impl" "PR #45 ready for review"

# View all communication
bd comments wms-123
```

### 5. Competing Implementations

For complex problems, spawn multiple agents with different approaches:

```bash
# Same bead, different approaches
/dtw:handoff wms-456 --approach redis
/dtw:handoff wms-456 --approach memory
/dtw:handoff wms-456 --approach hybrid

# Three agents work in parallel, each creates PR
# Review all three, merge best, close bead
```

Agents coordinate via comments:
```bash
bd comment wms-456 --author "wt-redis" "Using Redis, 50ms latency"
bd comment wms-456 --author "wt-memory" "In-memory LRU, simpler but 100MB limit"
bd comment wms-456 --author "wt-hybrid" "Redis + local cache, best of both"
```

### 6. Complete and Continue

When agent's PR is merged:

```bash
# Close the bead
bd close <bead-id> --reason "Merged PR #45 (Redis approach)"
```

**IMPORTANT: Update parent bead with what outcome was delivered:**

```bash
# View parent bead to see current state
bd show <parent-bead-id>

# Add comment documenting completed outcome
bd comment <parent-bead-id> "Completed: Invalid login shows clear error. Implementation: Redis-backed rate limiting with friendly error messages."

# If parent outcome is now complete, close it too
bd close <parent-bead-id> --reason "All sub-outcomes delivered"
```

**Check progress:**

```bash
bd epic status --no-daemon
```

**If more work remains:** Discover next outcome, create bead, spawn agent

**If new outcomes emerge:** Add to tree, keep going

**If blocked:** Mark blocked, work on unblocked beads

### 7. View Progress

**Bottom-up view (from any bead):**
```bash
bd dep tree <bead-id>
# Shows: current bead → parent → grandparent → root
```

**Epic completion:**
```bash
bd epic status --no-daemon
# Shows: progress percentage for each epic
```

**See what's ready for agents:**
```bash
bd ready
# Shows: all unblocked open beads ready to implement
```

## Outcome Examples

### Authentication Epic

❌ **Step-focused beads:**
```bash
bd create "Add login API endpoint"
bd create "Hash passwords"
bd create "Create session table"
bd create "Write validation tests"
```

✅ **Outcome-focused beads:**
```bash
bd create "User can sign in with valid credentials"
bd create "Invalid credentials show clear, secure error"
bd create "Session persists for 30 days unless logged out"
bd create "Brute force attempts are rate-limited"
```

### API Performance Epic

❌ **Step-focused beads:**
```bash
bd create "Add Redis caching"
bd create "Optimize database queries"
bd create "Add response compression"
```

✅ **Outcome-focused beads:**
```bash
bd create "API responds in <200ms for cached requests"
bd create "Database queries use indexes for all lookups"
bd create "Response payload is <50KB compressed"
```

**Notice:** Outcomes are testable, verifiable, and leave implementation choices to agents.

## Quick Reference

| Action | Command |
|--------|---------|
| Create epic | `bd create "Users can..." -t epic -p 1 --json` |
| Create root bead | `bd create "System delivers [capability]" -t task -p 1 --json` |
| Link to parent | `bd dep add <child-id> <parent-id> -t parent-child` |
| Add context to bead | `bd update <bead-id> --description "OUTCOME:\n...\n\nCONTEXT:\n...\n\nACCEPTANCE:\n..."` |
| Handoff to agent | `/dtw:handoff <bead-id>` |
| Agent adds comment | `bd comment <bead-id> --author "agent-name" "message"` |
| View comments | `bd comments <bead-id>` |
| Complete bead | `bd close <bead-id> --reason "Merged PR #X"` |
| Update parent | `bd comment <parent-id> "Completed: [outcome]"` |
| View tree | `bd dep tree <bead-id>` |
| Check progress | `bd epic status --no-daemon` |
| Find ready work | `bd ready` |
| Mark blocked | `bd update <bead-id> --status blocked` |

## Common Patterns

### Capture Distractions
```bash
# Something came up while working
bd create "Refactor auth utils for clarity" -t task -p 3 --json
bd dep add <distraction-id> <current-parent-id> -t parent-child
# Now it's captured, back to current work
```

### Break Down Complex Outcome
```bash
# Realized outcome needs multiple deliverables
bd create "Password meets complexity requirements" -t task -p 1 --json
bd create "Password complexity errors are user-friendly" -t task -p 1 --json
bd dep add <sub-outcome-1-id> <complex-bead-id> -t parent-child
bd dep add <sub-outcome-2-id> <complex-bead-id> -t parent-child
bd update <complex-bead-id> --status open  # Parent stays open until children done
```

### Handle Discovered Prerequisites
```bash
# Found something that must be true first
bd create "Database has user_sessions table with indexes" -t task -p 0 --json
bd dep add <current-bead-id> <prerequisite-id> -t blocks
bd update <current-bead-id> --status blocked
bd update <prerequisite-id> --status in_progress
```

### Document Competing Approaches
```bash
# Multiple agents tried different solutions
bd comment wms-789 "Evaluated three approaches:
- Redis (PR #45): 50ms, scalable, complex setup
- Memory (PR #46): 5ms, simple, 100MB limit
- Hybrid (PR #47): 10ms, balanced

Chose hybrid approach (PR #47) - best tradeoff"

bd close wms-789 --reason "Merged PR #47 (hybrid caching)"
```

## Red Flags

**STOP if you catch yourself:**
- ❌ Planning all details upfront before starting work
- ❌ Using TodoWrite instead of bd for multi-step work
- ❌ Creating beads that describe steps ("Add X", "Create Y")
- ❌ Creating beads without context or acceptance criteria
- ❌ Making beads too big (requires multiple PRs)
- ❌ Making beads too small (doesn't need a PR)
- ❌ Spawning agents without clear outcomes in beads
- ❌ Agents changing bead status (orchestrator-only)
- ❌ Closing beads without updating parent
- ❌ Forgetting to check `bd ready` when looking for next work
- ❌ Creating flat lists instead of hierarchical trees

**All of these mean: Refocus on outcomes, right-sized beads, and emergent planning.**

## Why This Works

**Outcome thinking:**
- Agents understand the goal, not just the steps
- PRs are reviewable against clear criteria
- Implementation approach is discovered, not prescribed
- Outcomes are verifiable and measurable

**Just-in-time planning:**
- Short conversations vs hours of upfront meetings
- Discover outcomes as you learn, not before
- Less waste from planning things that change

**Agent coordination:**
- Clear bead = clear work for agent
- Comments provide communication channel
- Status shows what's available to implement
- PRs connect outcomes to code

**Emergent structure:**
- Tree grows as understanding deepens
- Captures reality of software development (new discoveries)
- Makes unexpected work visible, not hidden

**Visual progress:**
- Anyone can see status without asking
- Bottom-up tree shows full context
- Epic progress shows completion percentage

**Focus maintenance:**
- Distractions captured as low-priority beads
- Current work stays visible
- Easy to return to main path

## Bead Sizing Decision Tree

```
Is this a user-facing outcome?
├─ YES: Make it an epic
│   └─ Break down into technical outcomes (beads)
│
└─ NO: Is it agent-completable in one session?
    ├─ YES: Make it a bead
    │   └─ Add context + acceptance criteria
    │
    └─ NO: Break down into smaller outcomes
        └─ Each becomes a bead
```

**Examples:**

- "Users can authenticate" → **Epic**
  - "User can sign in with email" → **Bead** (agent-completable)
  - "Invalid login shows error" → **Bead** (agent-completable)

- "API is fast" → **Epic**
  - "API responds in <200ms" → **Bead** (agent-completable)
  - "DB queries use indexes" → **Bead** (agent-completable)

- "Fix authentication bugs" → **Too vague**
  - "Session expires correctly after 30 days" → **Bead** (specific outcome)
  - "Logout clears all session cookies" → **Bead** (specific outcome)
