---
name: flow-designer
description: Design features through brainstorming and make architectural decisions. Use when user wants to brainstorm, design approach, make architecture choices, or update PLAN.md.
---

# Flow Designer

Help users design features through structured brainstorming sessions and make architectural decisions that shape the project.

## When to Use This Skill

Activate when the user wants to design or brainstorm:
- "Let's brainstorm this"
- "Design the approach"
- "How should we architect this?"
- "What's the best way to implement this?"
- "Should we use [technology]?"
- "Update architecture documentation"
- "Add a DO/DON'T rule"

## Design Philosophy

**Flow's Core Principle**: Design before implementation. Use structured brainstorming to explore options, make decisions, and document rationale before writing code.

**Brainstorming Structure**:
- **Subjects**: Questions or decisions to resolve
- **Resolution Types**: How each subject gets resolved (A/B/C/D)
- **Outcomes**: Pre-tasks (Type A), documentation (Type B), or action items (Type D)

## Brainstorming Workflow

### Step 1: Start Brainstorming

When user wants to brainstorm an iteration:

1. Read DASHBOARD.md to find current iteration
2. Read task file to check if brainstorming section exists
3. If doesn't exist, create:
   ```markdown
   #### Brainstorming

   **Status**: 🚧 IN PROGRESS

   **Subjects to Discuss**:
   1. ⏳ [Subject Name] - [Question or decision]
   2. ⏳ [Subject Name] - [Question or decision]
   ```
4. Prompt user for initial subjects if not provided
5. Add subjects as ⏳ PENDING items

### Step 2: Add Subjects

When user wants to add a new subject:

1. Find brainstorming section in current iteration
2. Add to "Subjects to Discuss" list:
   ```markdown
   N. ⏳ Subject Name - Description
   ```
3. Keep list organized (unresolved at top)

### Step 3: Discuss and Resolve Subjects

When user asks "what's next subject" or wants to discuss:

1. Find next ⏳ PENDING or 🚧 IN PROGRESS subject
2. Display subject for discussion
3. After user discusses, help determine resolution type (see [RESOLUTION_TYPES.md](RESOLUTION_TYPES.md))
4. Create subject section with resolution:
   ```markdown
   ##### Subject N: [Name]

   **Status**: ✅ RESOLVED (2025-MM-DD)

   **Question**: [What needed to be decided]

   **Decision**: [What was decided and why]

   **Resolution Type**: [A/B/C/D]

   **Action Items** (if Type A or D):
   - [ ] [Item 1]
   - [ ] [Item 2]
   ```
5. Update subject status in list: ⏳ → ✅
6. If Type B, update PLAN.md immediately (see [PLAN_UPDATES.md](PLAN_UPDATES.md))

### Step 4: Review Brainstorming

When user asks "review brainstorming" or wants to check progress:

1. List all ✅ RESOLVED subjects
2. Show resolution types breakdown:
   - Type A subjects → Pre-Implementation Tasks
   - Type B subjects → PLAN.md updates (already done)
   - Type C subjects → Auto-resolved
   - Type D subjects → Main action items
3. Calculate: Resolved vs Total subjects
4. Suggest completing if all resolved

### Step 5: Complete Brainstorming

When user says "complete brainstorming" or ready to finish:

1. **Verify**: All subjects have ✅ RESOLVED status
2. **Collect Type A subjects** → Create "Pre-Implementation Tasks" section:
   ```markdown
   #### Pre-Implementation Tasks

   **Status**: ⏳ PENDING

   These must be completed BEFORE starting main implementation:

   - [ ] [Pre-task from Subject N]
   - [ ] [Pre-task from Subject M]
   ```
3. **Collect Type D subjects** → Add to iteration's "Action Items":
   ```markdown
   #### Action Items
   - [ ] [Main work from Subject X]
   - [ ] [Main work from Subject Y]
   ```
4. **Update brainstorming status**: `**Status**: ✅ COMPLETE (2025-MM-DD)`
5. **Set iteration status**:
   - If pre-tasks exist: `**Status**: ⏳ PENDING` (must do pre-tasks first)
   - If no pre-tasks: `**Status**: 🎨 READY` (ready to implement)
6. Report to user what's next

## Subject Resolution Types

See [RESOLUTION_TYPES.md](RESOLUTION_TYPES.md) for detailed explanation. Quick reference:

### Type A: Pre-Implementation Task

**When**: Small blocking code change needed BEFORE iteration starts

**Criteria**:
- Required for iteration (blocking)
- Small scope (< 30 min)
- Can be done independently

**Examples**: Fix interface, rename file, update enum

**Outcome**: Goes into "Pre-Implementation Tasks" section, must complete before main work

### Type B: Immediate Documentation

**When**: Architectural decision affecting system design

**Criteria**:
- No code changes yet
- Updates PLAN.md Architecture section NOW
- High-level design decision

**Examples**: Design pattern choice, API contract, data model

**Outcome**: Update PLAN.md immediately during brainstorming (see [PLAN_UPDATES.md](PLAN_UPDATES.md))

### Type C: Auto-Resolved

**When**: Subject answered by another subject's decision

**Criteria**:
- No independent decision needed
- Cascade from another subject

**Examples**: Implementation detail determined by architecture choice

**Outcome**: No action items, just note which subject resolved this

### Type D: Iteration Action Items

**When**: Substantial feature work that IS the iteration

**Criteria**:
- Main implementation work
- Takes significant time (> 30 min)

**Examples**: Build API endpoint, implement validator, create service

**Outcome**: These become the iteration's implementation action items

## Architecture Decision Making

When brainstorming reveals architectural decisions (Type B), update PLAN.md:

### When to Update PLAN.md

**Always update for**:
- Technology choices (libraries, frameworks, tools)
- Design patterns adopted
- System architecture changes
- API contracts or interfaces
- Data model decisions
- DO/DON'T guidelines that emerge

**Don't update for**:
- Implementation details (those go in task notes)
- Temporary decisions (those stay in brainstorming)
- Personal preferences (only team-wide guidelines)

### How to Update PLAN.md

See [PLAN_UPDATES.md](PLAN_UPDATES.md) for detailed patterns. Quick guide:

**Architecture Section Update**:
```markdown
### [Component/Feature Name]

**Decision**: [What was decided]

**Rationale**: [Why this approach]

**Trade-offs**:
- **Chosen**: [Approach X] because [reason]
- **Not chosen**: [Approach Y] because [reason]
```

**DO/DON'T Guidelines**:
```markdown
**DO**:
- [Guideline from experience]

**DON'T**:
- [Anti-pattern to avoid]
```

## Subject Discussion Guidance

### Asking the Right Questions

Help users explore decisions:
- "What are the options?"
- "What are the trade-offs?"
- "What are the constraints?"
- "What's the impact if we choose wrong?"
- "Is this decision reversible?"

### Recommending Resolution Types

**Recommend Type A if**:
- User says "we need to fix [X] first"
- Small blocking change mentioned
- Quick prerequisite work identified

**Recommend Type B if**:
- Major architectural decision
- Technology choice discussion
- System-wide pattern emerging
- User asks "how should we architect"

**Recommend Type C if**:
- Subject is consequence of another decision
- No independent choice to make
- Answer is implied by previous subjects

**Recommend Type D if**:
- Main feature work described
- Core implementation discussed
- User describes "what we're building"

## Examples

### Example 1: Complete Brainstorming Session

```
User: "Let's brainstorm the retry logic for API calls"

AI Process:
1. Find current iteration in task file
2. Create brainstorming section with status 🚧 IN PROGRESS
3. Suggest initial subjects:
   - Retry Strategy (exponential backoff vs fixed delay)
   - Error Classification (which errors retry)
   - Max Retry Attempts (how many before giving up)
   - Existing Error Handler (need async support)
   - Timeout Configuration (per-request vs total)

User provides input, AI adds subjects to list as ⏳ PENDING

---

User: "What's the next subject?"

AI Response:
Subject 1: Retry Strategy

Let's discuss - what are the options?
- Exponential backoff (1s, 2s, 4s, 8s...)
- Fixed delay (1s between each retry)
- Linear backoff (1s, 2s, 3s, 4s...)

Which approach fits your needs?

User: "Exponential backoff with base delay 1 second"

AI Response:
This is Type D (Iteration Action Items) - the main feature work.

Creating resolution:
**Resolution Type**: D
**Action Items**:
- [ ] Create RetryPolicy class
- [ ] Implement exponential backoff algorithm (base: 1s, max: 32s)
- [ ] Add configuration for max retries (default: 3)
- [ ] Integrate with API client
- [ ] Add tests for retry scenarios

Marked Subject 1 as ✅ RESOLVED. Next subject?

---

User: "Subject about error handler needing async support"

AI Response:
Subject 4: Existing Error Handler - Need Async Support

This sounds like a blocking prerequisite. Let me confirm:
✅ Is it blocking? YES - can't implement retry without async
✅ Is it small? YES - estimated 20-30 minutes
✅ Can be done independently? YES

This is Type A (Pre-Implementation Task).

**Resolution Type**: A
**Action Items**:
- [ ] Update ErrorHandler.ts to support async operations
- [ ] Add retryAsync() method
- [ ] Update 3 existing call sites
- [ ] Add tests for async error handling

This will go into "Pre-Implementation Tasks" - must complete BEFORE main implementation.

---

After all subjects resolved...

User: "Complete brainstorming"

AI Process:
1. Verify all 5 subjects ✅ RESOLVED
2. Collect Type A subjects:
   - Subject 4 action items → Pre-Implementation Tasks section
3. Collect Type D subjects:
   - Subject 1, 2, 3, 5 action items → Iteration Action Items
4. Mark brainstorming ✅ COMPLETE (2025-10-20)
5. Set iteration status: ⏳ PENDING (pre-tasks exist)

AI Response:
✅ Brainstorming complete!

**Pre-Implementation Tasks** (4 items):
Must complete these BEFORE starting main implementation.

**Iteration Action Items** (12 items):
Main retry logic implementation.

**Next Steps**:
1. Complete pre-implementation tasks first
2. Then run implementation on this iteration

Iteration is now ⏳ PENDING (will be 🎨 READY after pre-tasks done).
```

### Example 2: Architecture Decision (Type B)

```
User: "Should we use REST or GraphQL for our API?"

AI Response:
This is a major architectural decision. Let's brainstorm:

**Subject**: API Technology Choice

**Options**:
- REST: Simple, well-understood, stateless
- GraphQL: Flexible queries, reduces over-fetching

What are your requirements? (data complexity, client needs, team experience)

User: "Team knows REST well, simple CRUD operations, mobile app needs specific fields"

AI Response:
Based on your context:
- Team experience: REST ✅
- Use case: CRUD operations fit REST
- Mobile optimization: Could benefit from GraphQL, but REST + field selection achievable

**Recommendation**: REST with field selection query params

This is Type B (Immediate Documentation) - architectural decision.

**Resolution Type**: B

I'm updating PLAN.md Architecture section now:

**PLAN.md Update**:
```markdown
### API Architecture

**Decision**: RESTful API with field selection via query parameters

**Rationale**:
- Team has strong REST experience (faster development)
- CRUD operations map naturally to REST resources
- Field selection (`?fields=name,email`) addresses mobile bandwidth concerns
- Simpler stack (no GraphQL server/client overhead)

**Trade-offs**:
- **Chosen**: REST + field selection
  - Pros: Simpler, team-ready, adequate for needs
  - Cons: Less flexible than GraphQL for complex queries
- **Not chosen**: GraphQL
  - Pros: Perfect field selection, great for evolving requirements
  - Cons: Learning curve, additional infrastructure

**DO**:
- Use field selection query params for bandwidth optimization
- Follow RESTful resource naming conventions
- Version API endpoints (/v1/users)

**DON'T**:
- Return full objects when mobile clients need subsets
- Create custom endpoint for every use case (use field selection)
```

✅ PLAN.md updated. Subject marked ✅ RESOLVED.
```

### Example 3: Auto-Resolved Subject (Type C)

```
User: "What about the retry delay calculation?"

AI Response:
Subject 5: Retry Delay Calculation

Looking at previous decisions...

This was answered by Subject 1 (Retry Strategy):
- You chose exponential backoff with base 1s
- Formula: delay = base_delay * (2 ^ attempt_number)
- Max delay: 32s

**Resolution Type**: C (Auto-Resolved by Subject 1)

No additional action needed - implementation in Subject 1 covers this.

Subject marked ✅ RESOLVED.
```

## Files Read/Write

**READ**:
- `.flow/DASHBOARD.md` - Find current work (which iteration to brainstorm)
- `.flow/phase-N/task-M.md` - Current iteration, existing brainstorming
- `.flow/PLAN.md` - Current architecture, DO/DON'T guidelines

**WRITE**:
- `.flow/phase-N/task-M.md` - Add/update brainstorming section, subjects, resolutions
- `.flow/PLAN.md` - Update Architecture section, DO/DON'T guidelines, Technology Choices

## Validation Gates

- Before starting: Verify iteration exists in task file
- Before completing: Verify all subjects have ✅ RESOLVED status
- Before marking iteration READY: Verify no pending pre-tasks (or mark PENDING if pre-tasks exist)
- After Type B resolution: Verify PLAN.md updated correctly

## References

- **Subject Resolution Types**: [RESOLUTION_TYPES.md](RESOLUTION_TYPES.md) - Detailed guide on A/B/C/D types
- **PLAN.md Updates**: [PLAN_UPDATES.md](PLAN_UPDATES.md) - How to update architecture documentation
- **Brainstorming Pattern**: .flow/framework/DEVELOPMENT_FRAMEWORK.md lines 1167-1797
- **Framework Reference**: .flow/framework/DEVELOPMENT_FRAMEWORK.md lines 1-353
