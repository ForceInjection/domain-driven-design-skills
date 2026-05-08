---
name: pmc-ticket-init
description: Create ticket directories with 1-definition.md from PRD and planning docs. Use this skill to initialize new tickets with self-contained context, relationships, testing draft, and expectations.
---

# PMC Ticket Init

Creates ticket directories with comprehensive `1-definition.md` files based on PRD and planning documentation. Each definition is self-contained with context, relationships, testing approach, and success expectations.

## When to Use

- When PRD features need corresponding tickets
- After planning docs identify unimplemented features
- When initializing tickets for a new phase
- When you need tickets with testing considerations upfront

## References

- `references/ticket-workflow.md` - Complete ticket structure, numbering, document formats, and test definitions

## Workflow

### Step 1: Read PRD Documents

Read all PRD files in `docs/1-prd/`:

1. Parse feature definitions, requirements, and scope
2. Extract acceptance criteria and constraints
3. Note technical specifications
4. Identify testable behaviors

Skip `99-discrepancies.md` (not a PRD doc).

### Step 2: Read Planning Documents

Read planning docs in `docs/2-current/`:

1. `00-overall-plan.md` - roadmap and phases
2. `02-completed.md` - already done (skip these)
3. Existing ticket definitions (for relationships)

Also read:
- `docs/tickets/index.md` - existing tickets
- Existing `docs/tickets/T*/1-definition.md` files

Determine:
- **Last ticket number** (continue from next)
- Which features already have tickets
- Dependencies between features

### Step 3: Identify Tickets to Create

For each unimplemented feature from PRD:

1. Check if ticket already exists
2. If not, add to creation list
3. Analyze relationships to other tickets

### Step 4: Create Ticket Definitions

For each new ticket:

1. Determine ticket number (T0000N format, zero-padded 5 digits)
2. Create directory `docs/tickets/T0000N/`
3. Create `1-definition.md` with enhanced format below

**Enhanced 1-definition.md Format:**

```markdown
# T0000N: Feature Name

## Objective

Clear statement of what this ticket accomplishes.

## Background

Self-contained context extracted from PRD. Include:
- Why this feature exists
- How it fits into the larger system
- Key constraints and requirements
- Relevant technical details

Do NOT just reference PRD sections - copy relevant content here.

## Requirements

- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

## Out of Scope

- What this ticket does NOT include
- Boundaries with related features

## Related Tickets

| Ticket | Relationship |
|--------|--------------|
| T0000X | Depends on (must complete first) |
| T0000Y | Blocks (this must complete first) |
| T0000Z | Related (shares components) |

If no relationships, state "None - independent ticket"

## Testing Approach (Draft)

### Test Categories
- **Unit tests**: Internal logic validation
- **Integration tests**: Component interaction
- **E2E tests**: User-facing behavior

### Key Test Scenarios
1. **Happy path**: [describe main success scenario]
2. **Error handling**: [describe error cases to test]
3. **Edge cases**: [describe boundary conditions]

### Testing Methods
- [ ] Automated: [pytest/jest/etc.]
- [ ] Manual verification: [if needed]
- [ ] Visual inspection: [if UI involved]

### Infrastructure Needs
- [Any test fixtures, mocks, or setup required]

## Expectations

Success criteria that must be met to complete this ticket:

- [ ] Expectation 1: [precise, verifiable statement]
- [ ] Expectation 2: [precise, verifiable statement]
- [ ] Expectation 3: [precise, verifiable statement]

Each expectation should be:
- Objectively verifiable
- Tied to a testable behavior
- Clear pass/fail determination
```

### Step 5: Verify

Check all created tickets:

1. Each `docs/tickets/T0000N/` directory exists
2. Each has `1-definition.md` (not empty)
3. All sections are populated
4. Ticket numbers are sequential

If verification fails, fix and re-verify (max 3 retries).

### Step 6: Commit

Stage and commit ticket definitions:

```bash
git add docs/tickets/T*/1-definition.md
git commit -m "Initialize ticket definitions from PRD"
```

**Note:** Do NOT add to `docs/tickets/index.md` yet - that happens when `2-plan.md` is created.

## Output

After running this skill:
- New ticket directories created
- Each has `1-definition.md` with:
  - Self-contained PRD context
  - Ticket relationships
  - Testing approach draft
  - Verifiable expectations
- Changes committed

## 1-definition.md Quality Checklist

| Section | Quality Check |
|---------|---------------|
| Objective | One clear sentence |
| Background | Self-contained, no external refs needed |
| Requirements | Actionable checklist items |
| Out of Scope | Clear boundaries |
| Related Tickets | Accurate relationships or "None" |
| Testing Approach | Concrete scenarios, not generic |
| Expectations | Precise, verifiable statements |

## Example Usage

```
User: Create ticket definitions for phase 2 features
Assistant: [Uses pmc-ticket-init to create T00005, T00006, T00007]
```

```
User: Initialize tickets from PRD
Assistant: [Uses pmc-ticket-init skill]
```

## Relation to Other Skills

| Skill | Purpose |
|-------|---------|
| `pmc-planning` | Updates roadmap (run before this) |
| `pmc-ticket-init` | Creates ticket definitions - this skill |
| `project-manager` | Handles ticket implementation |
