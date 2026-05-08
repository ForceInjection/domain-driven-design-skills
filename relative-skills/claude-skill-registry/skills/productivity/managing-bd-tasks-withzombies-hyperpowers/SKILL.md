---
name: managing-bd-tasks
description: Use for advanced bd operations - splitting tasks mid-flight, merging duplicates, changing dependencies, archiving epics, querying metrics, cross-epic dependencies
---

<skill_overview>
Advanced bd operations for managing complex task structures; bd is single source of truth, keep it accurate.
</skill_overview>

<rigidity_level>
HIGH FREEDOM - These are operational patterns, not rigid workflows. Adapt operations to your specific situation while following the core principles (keep bd accurate, merge don't delete, document changes).
</rigidity_level>

<quick_reference>
| Operation | When | Key Command |
|-----------|------|-------------|
| Split task | Task too large mid-flight | Create subtasks, add deps, close parent |
| Merge duplicates | Found duplicate tasks | Combine designs, move deps, close with reference |
| Change dependencies | Dependencies wrong/changed | `bd dep remove` then `bd dep add` |
| Archive epic | Epic complete, hide from views | `bd close bd-X --reason "Archived"` |
| Query metrics | Need status/velocity data | `bd list` + filters + `wc -l` |
| Cross-epic deps | Task depends on other epic | `bd dep add` works across epics |
| Bulk updates | Multiple tasks need same change | Loop with careful review first |
| Recover mistakes | Accidentally closed/wrong dep | `bd update --status` or `bd dep remove` |

**Core principle:** Track all work in bd, update as you go, never batch updates.
</quick_reference>

<when_to_use>
Use this skill for **advanced** bd operations:
- Split task that's too large (discovered mid-implementation)
- Merge duplicate tasks
- Reorganize dependencies after work started
- Archive completed epics (hide from views, keep history)
- Query bd for metrics (velocity, progress, bottlenecks)
- Manage cross-epic dependencies
- Bulk status updates
- Recover from bd mistakes

**For basic operations:** See skills/common-patterns/bd-commands.md (create, show, close, update)
</when_to_use>

<operations>
## Operation 1: Splitting Tasks Mid-Flight

**When:** Task in-progress but turns out too large.

**Example:** Started "Implement authentication" - realize it's 8+ hours of work across multiple areas.

**Process:**

### Step 1: Create subtasks for remaining work

```bash
# Original task bd-5 is in-progress
# Already completed: Login form
# Remaining work gets split:

bd create "Auth API endpoints" --type task --priority P1 --design "
POST /api/login and POST /api/logout endpoints.
## Success Criteria
- [ ] POST /api/login validates credentials, returns JWT
- [ ] POST /api/logout invalidates token
- [ ] Tests pass
"
# Returns bd-12

bd create "Session management" --type task --priority P1 --design "
JWT token tracking and validation.
## Success Criteria
- [ ] JWT generated on login
- [ ] Tokens validated on protected routes
- [ ] Token expiration handled
- [ ] Tests pass
"
# Returns bd-13

bd create "Password hashing" --type task --priority P1 --design "
Secure password hashing with bcrypt.
## Success Criteria
- [ ] Passwords hashed before storage
- [ ] Hash verification on login
- [ ] Tests pass
"
# Returns bd-14
```

### Step 2: Set up dependencies

```bash
# Password hashing must be done first
# API endpoints depend on password hashing
bd dep add bd-12 bd-14  # bd-12 depends on bd-14

# Session management depends on API endpoints
bd dep add bd-13 bd-12  # bd-13 depends on bd-12

# View tree
bd dep tree bd-5
```

### Step 3: Update original task and close

```bash
bd edit bd-5 --design "
Implement user authentication.

## Status
✓ Login form completed (frontend)
✗ Remaining work split into subtasks:
  - bd-14: Password hashing (do first)
  - bd-12: Auth API endpoints (depends on bd-14)
  - bd-13: Session management (depends on bd-12)

## Success Criteria
- [x] Login form renders
- [ ] See subtasks for remaining criteria
"

bd close bd-5 --reason "Split into bd-12, bd-13, bd-14"
```

### Step 4: Work on subtasks in order

```bash
bd ready  # Shows bd-14 (no dependencies)
bd update bd-14 --status in_progress
# Complete bd-14...
bd close bd-14

# Now bd-12 is unblocked
bd ready  # Shows bd-12
```

---

## Operation 2: Merging Duplicate Tasks

**When:** Discovered two tasks are same thing.

**Example:**
```
bd-7: "Add email validation"
bd-9: "Validate user email addresses"
^ Duplicates
```

### Step 1: Choose which to keep

Based on:
- Which has more complete design?
- Which has more work done?
- Which has more dependencies?

**Example:** Keep bd-7 (more complete)

### Step 2: Merge designs

```bash
bd show bd-7
bd show bd-9

# Combine into bd-7
bd edit bd-7 --design "
Add email validation to user creation and update.

## Background
Originally tracked as bd-7 and bd-9 (now merged).

## Success Criteria
- [ ] Email validated on creation
- [ ] Email validated on update
- [ ] Rejects invalid formats
- [ ] Rejects empty strings
- [ ] Tests cover all cases

## Notes from bd-9
Need validation on update, not just creation.
"
```

### Step 3: Move dependencies

```bash
# Check bd-9 dependencies
bd show bd-9

# If bd-10 depended on bd-9, update to bd-7
bd dep remove bd-10 bd-9
bd dep add bd-10 bd-7
```

### Step 4: Close duplicate with reference

```bash
bd edit bd-9 --design "DUPLICATE: Merged into bd-7

This task was duplicate of bd-7. All work tracked there."

bd close bd-9
```

---

## Operation 3: Changing Dependencies

**When:** Dependencies were wrong or requirements changed.

**Example:** bd-10 depends on bd-8 and bd-9, but bd-9 got merged and bd-10 now also needs bd-11.

```bash
# Remove obsolete dependency
bd dep remove bd-10 bd-9

# Add new dependency
bd dep add bd-10 bd-11

# Verify
bd dep tree bd-1  # If bd-10 in epic bd-1
bd show bd-10 | grep "Blocking"
```

**Common scenarios:**
- Discovered hidden dependency during implementation
- Requirements changed mid-flight
- Tasks reordered for better flow

---

## Operation 4: Archiving Completed Epics

**When:** Epic complete, want to hide from default views but keep history.

```bash
# Verify all tasks closed
bd list --parent bd-1 --status open
# Output: [empty] = all closed

# Archive epic
bd close bd-1 --reason "Archived - completed Oct 2025"

# Won't show in open listings
bd list --status open  # bd-1 won't appear

# Still accessible
bd show bd-1  # Still shows full epic
```

**Use archived for:** Completed epics, shipped features, historical reference
**Use open/in-progress for:** Active work
**Use closed with note for:** Cancelled work (explain why)

---

## Operation 5: Querying for Metrics

### Velocity

```bash
# Tasks closed this week
bd list --status closed | grep "closed_at" | grep "2025-10-" | wc -l

# Tasks closed by epic
bd list --parent bd-1 --status closed | wc -l
```

### Blocked vs Ready

```bash
# Ready to work on
bd ready
bd ready | grep "^bd-" | wc -l

# All open tasks
bd list --status open | wc -l

# Blocked = open - ready
```

### Epic Progress

```bash
# Show tree
bd dep tree bd-1

# Total tasks in epic
bd list --parent bd-1 | grep "^bd-" | wc -l

# Completed tasks
bd list --parent bd-1 --status closed | grep "^bd-" | wc -l

# Percentage = (completed / total) * 100
```

**For detailed metrics guidance:** See [resources/metrics-guide.md](resources/metrics-guide.md)

---

## Operation 6: Cross-Epic Dependencies

**When:** Task in one epic depends on task in different epic.

**Example:**
```
Epic bd-1: User Management
  - bd-10: User CRUD API

Epic bd-2: Order Management
  - bd-20: Order creation (needs user API)
```

```bash
# Add cross-epic dependency
bd dep add bd-20 bd-10
# bd-20 (in bd-2) depends on bd-10 (in bd-1)

# Check dependencies
bd show bd-20 | grep "Blocking"

# Check ready tasks
bd ready
# Won't show bd-20 until bd-10 closed
```

**Best practices:**
- Document cross-epic dependencies clearly
- Consider if epics should be merged
- Coordinate if different people own epics

---

## Operation 7: Bulk Status Updates

**When:** Need to update multiple tasks.

**Example:** Mark all test tasks closed after suite complete.

```bash
# Get tasks
bd list --parent bd-1 --status open | grep "test:" > test-tasks.txt

# Review list
cat test-tasks.txt

# Update each
while read task_id; do
  bd close "$task_id"
done < test-tasks.txt

# Verify
bd list --parent bd-1 --status open | grep "test:"
```

**Use bulk for:**
- Marking completed work closed
- Reopening related tasks
- Updating priorities

**Never bulk:**
- Thoughtless changes
- Hiding problems (closing unfinished tasks)

---

## Operation 8: Recovering from Mistakes

### Accidentally closed task

```bash
bd update bd-15 --status open
# Or if was in progress
bd update bd-15 --status in_progress
```

### Wrong dependency

```bash
bd dep remove bd-10 bd-8  # Remove wrong
bd dep add bd-10 bd-9     # Add correct
```

### Undo design changes

```bash
# bd has no undo, restore from git
git log -p -- .beads/issues.jsonl | grep -A 50 "bd-10"
# Find previous version, copy

bd edit bd-10 --design "[paste previous]"
```

### Epic structure wrong

1. Create new tasks with correct structure
2. Move work to new tasks
3. Close old tasks with reference
4. Don't delete (keep audit trail)
</operations>

<examples>
<example>
<scenario>Developer closes duplicate without merging information</scenario>

<code>
# Found duplicates
bd-7: "Add email validation"
bd-9: "Validate user email addresses"

# Developer just closes bd-9
bd close bd-9

# Loses information from bd-9's design
# bd-9 mentioned validation on update (bd-7 didn't)
# Now that requirement is lost
# Work on bd-7 completes, but misses update validation
# Bug ships to production
</code>

<why_it_fails>
- Closed duplicate without reading its design
- Lost requirement mentioned only in duplicate
- Information not preserved
- Incomplete implementation ships
- bd not accurate source of truth
</why_it_fails>

<correction>
**Correct process:**

```bash
# Read BOTH tasks
bd show bd-7  # Only mentions validation on creation
bd show bd-9  # Mentions validation on update too

# Merge information
bd edit bd-7 --design "
Email validation for user creation and update.

## Background
Merged from bd-9.

## Success Criteria
- [ ] Validate on creation (from bd-7)
- [ ] Validate on update (from bd-9)  ← Preserved!
- [ ] Tests for both cases
"

# Then close duplicate with reference
bd edit bd-9 --design "DUPLICATE: Merged into bd-7"
bd close bd-9
```

**What you gain:**
- All requirements preserved
- bd remains accurate
- No information lost
- Complete implementation
- Audit trail clear
</correction>
</example>

<example>
<scenario>Developer doesn't split large task, struggles through</scenario>

<code>
bd-15: "Implement payment processing" (started)

# 3 hours in, developer realizes:
# - Need Stripe API integration (4 hours)
# - Need payment validation (2 hours)
# - Need retry logic (3 hours)
# - Need receipt generation (2 hours)
# Total: 11 more hours!

# Developer thinks: "Too late to split, I'll power through"
# Works 14 hours straight
# Gets exhausted, makes mistakes
# Ships buggy code
# Has to fix in production
</code>

<why_it_fails>
- Didn't split when discovered size
- "Sunk cost" rationalization (already started)
- No clear stopping points
- Exhaustion leads to bugs
- Can't track progress granularly
- If interrupted, hard to resume
</why_it_fails>

<correction>
**Correct approach (split mid-flight):**

```bash
# 3 hours in, stop and split

bd edit bd-15 --design "
Implement payment processing.

## Status
✓ Completed: Payment form UI (3 hours)
✗ Split remaining work into subtasks:
  - bd-20: Stripe API integration
  - bd-21: Payment validation
  - bd-22: Retry logic
  - bd-23: Receipt generation
"

bd close bd-15 --reason "Split into bd-20, bd-21, bd-22, bd-23"

# Create subtasks with dependencies
bd create "Stripe API integration" ...  # bd-20
bd create "Payment validation" ...      # bd-21
bd create "Retry logic" ...             # bd-22
bd create "Receipt generation" ...      # bd-23

bd dep add bd-21 bd-20  # Validation needs API
bd dep add bd-22 bd-20  # Retry needs API
bd dep add bd-23 bd-22  # Receipts after retry works

# Work on one at a time
bd update bd-20 --status in_progress
# Complete bd-20 (4 hours)
bd close bd-20

# Take break
# Next day: bd-21
```

**What you gain:**
- Clear stopping points (can pause between tasks)
- Track progress granularly
- No exhaustion (spread over days)
- Better quality (not rushed)
- If interrupted, easy to resume
- Each subtask gets proper focus
</correction>
</example>

<example>
<scenario>Developer adds dependency but doesn't update dependent task</scenario>

<code>
# Initial state
bd-10: "Add user dashboard" (in progress)
bd-15: "Add analytics to dashboard" (blocked on bd-10)

# During bd-10 implementation, discover need for new API
bd create "Analytics API endpoints" ...  # Creates bd-20

# Add dependency
bd dep add bd-15 bd-20  # bd-15 now depends on bd-20 too

# But bd-10 completes, closes
bd close bd-10

# bd-15 shows as ready (bd-10 closed)
bd ready  # Shows bd-15

# Developer starts bd-15
bd update bd-15 --status in_progress

# Immediately blocked - needs bd-20!
# bd-20 not done yet
# Have to stop work on bd-15
# Time wasted
</code>

<why_it_fails>
- Added dependency but didn't document in bd-15
- bd-15's design doesn't mention bd-20 requirement
- Appears ready when not actually ready
- Wastes time starting work that's blocked
- Dependencies not obvious from task design
</why_it_fails>

<correction>
**Correct approach:**

```bash
# Create new API task
bd create "Analytics API endpoints" ...  # bd-20

# Add dependency
bd dep add bd-15 bd-20

# UPDATE bd-15 to document new requirement
bd edit bd-15 --design "
Add analytics to dashboard.

## Dependencies
- bd-10: User dashboard (completed)
- bd-20: Analytics API endpoints (NEW - discovered during bd-10)

## Success Criteria
- [ ] Integrate with analytics API (bd-20)
- [ ] Display charts on dashboard
- [ ] Tests pass
"

# Close bd-10
bd close bd-10

# Check ready
bd ready  # Does NOT show bd-15 (blocked on bd-20)

# Work on bd-20 first
bd update bd-20 --status in_progress
# Complete bd-20
bd close bd-20

# NOW bd-15 is truly ready
bd ready  # Shows bd-15
```

**What you gain:**
- Dependencies documented in task design
- Clear why task is blocked
- No false "ready" signals
- Work proceeds in correct order
- No wasted time starting blocked work
</correction>
</example>
</examples>

<critical_rules>
## Rules That Have No Exceptions

1. **Keep bd accurate** → Single source of truth for all work
2. **Merge duplicates, don't just close** → Preserve information from both
3. **Split large tasks when discovered** → Not after struggling through
4. **Document dependency changes** → Update task designs when deps change
5. **Update as you go** → Never batch updates "for later"

## Common Excuses

All of these mean: **STOP. Follow the operation properly.**

- "Task too complex to split" (Every task can be broken down)
- "Just close duplicate" (Merge first, preserve information)
- "Won't track this in bd" (All work tracked, no exceptions)
- "bd is out of date, update later" (Later never comes, update now)
- "This dependency doesn't matter" (Dependencies prevent blocking, they matter)
- "Too much overhead to split" (More overhead to fail huge task)
</critical_rules>

<bd_best_practices>
**For detailed guidance on:**
- Task naming conventions
- Priority guidelines (P0-P4)
- Task granularity
- Success criteria
- Dependency management

**See:** [resources/task-naming-guide.md](resources/task-naming-guide.md)
</bd_best_practices>

<red_flags>
Watch for these patterns:

- **Multiple in-progress tasks** → Focus on one
- **Tasks stuck in-progress for days** → Blocked? Split it?
- **Many open tasks, no dependencies** → Prioritize!
- **Epics with 20+ tasks** → Too large, split epic
- **Closed tasks, incomplete criteria** → Not done, reopen
</red_flags>

<verification_checklist>
After advanced bd operations:

- [ ] bd still accurate (reflects reality)
- [ ] Dependencies correct (nothing blocked incorrectly)
- [ ] Duplicate information merged (not lost)
- [ ] Changes documented in task designs
- [ ] Ready tasks are actually unblocked
- [ ] Metrics queries return sensible numbers
- [ ] No orphaned tasks (all part of epics)

**Can't check all boxes?** Review operation and fix issues.
</verification_checklist>

<integration>
**This skill covers:** Advanced bd operations

**For basic operations:**
- skills/common-patterns/bd-commands.md

**Related skills:**
- hyperpowers:writing-plans (creating epics and tasks)
- hyperpowers:executing-plans (working through tasks)
- hyperpowers:verification-before-completion (closing tasks properly)

**CRITICAL:** Use bd CLI commands, never read `.beads/issues.jsonl` directly.
</integration>

<resources>
**Detailed guides:**
- [Metrics guide (cycle time, WIP limits)](resources/metrics-guide.md)
- [Task naming conventions](resources/task-naming-guide.md)
- [Dependency patterns](resources/dependency-patterns.md)

**When stuck:**
- Task seems unsplittable → Ask user how to break it down
- Duplicates complex → Merge designs carefully, don't rush
- Dependencies tangled → Draw diagram, untangle systematically
- bd out of sync → Stop everything, update bd first
</resources>
