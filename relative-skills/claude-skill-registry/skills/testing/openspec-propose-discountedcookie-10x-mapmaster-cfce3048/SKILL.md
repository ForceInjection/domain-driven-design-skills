---
name: openspec-propose
description: >-
  Use when adding features, changing behavior, or modifying architecture.
  Creates change proposal with specs and tasks. ALWAYS ask for approval before
  proceeding to implementation. Do NOT use for bug fixes or trivial changes.
---

# OpenSpec Propose

Create change proposals for new features or behavioral changes.

> **Announce:** "I'm using openspec-propose to create a change proposal for approval."

## Iron Law

```
NO IMPLEMENTATION WITHOUT APPROVED PROPOSAL
```

Do NOT write implementation code during this phase. Only create:
- `proposal.md`
- `tasks.md`
- `design.md` (if complex)
- Spec deltas

## Process

### Phase 1: Gather Context

1. Read `openspec/project.md` for conventions
2. Run `openspec list --specs` to see current capabilities
3. Run `openspec list` to check for conflicts
4. Search codebase for related code: `rg [keyword]`

### Phase 2: Choose Change ID

Format: `verb-noun` in kebab-case

Examples:
- `add-leaderboard`
- `update-scoring-algorithm`
- `refactor-game-state`

Verify uniqueness against `openspec list`.

### Phase 3: Create Proposal

Create `openspec/changes/[id]/proposal.md`:

```markdown
# Change: [Brief description]

## Why

[1-2 sentences: What problem does this solve?]

## What Changes

- [Change 1]
- [Change 2]
- **BREAKING**: [If any breaking changes]

## Impact

- Affected specs: [list]
- Affected code: [key files/directories]
```

### Phase 4: Create Spec Deltas

For each affected capability, create `openspec/changes/[id]/specs/[capability]/spec.md`:

```markdown
## ADDED Requirements

### Requirement: [Name]

The system SHALL [behavior].

#### Scenario: [Name]

- **WHEN** [condition]
- **THEN** [expected result]

## MODIFIED Requirements

### Requirement: [Existing Name]

[Complete updated requirement text - not just the diff]

#### Scenario: [Name]

- **WHEN** [condition]
- **THEN** [expected result]
```

Every requirement MUST have at least one scenario.

### Phase 5: Create Tasks

Create `openspec/changes/[id]/tasks.md`:

```markdown
## 1. [Category]

- [ ] 1.1 [Specific task - 2-5 minutes]
- [ ] 1.2 [Specific task - 2-5 minutes]

## 2. [Category]

- [ ] 2.1 [Specific task - 2-5 minutes]
```

### Phase 6: Validate

```bash
openspec validate [id] --strict
```

Fix ALL issues before presenting to user.

### Phase 7: Request Approval

Present summary to user:

```markdown
## Proposal: [id]

**Goal:** [One sentence]

**Changes:**
- [Key change 1]
- [Key change 2]

**Tasks:** [X] items

**Ready for your review.** Run `openspec show [id]` for full details.

Do you approve this proposal?
```

WAIT for explicit approval before proceeding.

## REQUIRED SUB-SKILL

After approval:
→ Load `task-planning` skill if tasks need more detail
→ Load `openspec-apply` skill to begin implementation

## Red Flags - STOP

If you catch yourself:
- Writing implementation code
- Skipping validation
- Proceeding without user approval
- Creating vague tasks ("implement feature")

STOP. This phase is planning only.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "This is small, skip the proposal" | Small changes compound. Spec it anyway. |
| "I'll document after implementing" | After-the-fact docs miss the reasoning. |
| "User seems impatient" | Wrong implementation wastes more time. |
| "Tasks are obvious, I'll figure it out" | Vague tasks lead to scope creep. |
