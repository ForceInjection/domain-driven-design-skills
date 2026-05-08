---
name: pmc-planning
description: Update planning docs from PRD files or discrepancies report. Use this skill to update roadmap and dependencies without creating tickets. Works directly with PRD documents and/or 99-discrepancies.md when available.
---

# PMC Planning

Updates planning documentation based on PRD files or discrepancies report. This skill focuses on roadmap and dependency analysis without creating ticket definitions.

## Input Sources (Priority Order)

1. **`docs/1-prd/99-discrepancies.md`** - If exists with `Status: COMPLETE`, use gap analysis
2. **PRD files in `docs/1-prd/`** - Parse directly for features and requirements

## When to Use

- When you want to update planning docs without creating tickets
- When you have PRD files but no discrepancies report
- When you need to analyze dependencies and development order
- When roadmap needs to reflect current PRD state

## Gap Types Handled (from discrepancies)

| Gap Type | Action |
|----------|--------|
| `DOCUMENTED_NOT_IMPLEMENTED` | Add to roadmap |
| `DIVERGED` | Note in planning |

## Workflow

### Step 1: Read Input Sources

**Option A: Discrepancies Available**
1. Check for `docs/1-prd/99-discrepancies.md`
2. If exists with `Status: COMPLETE`, parse gap analysis
3. Filter for planning-related gaps (DOCUMENTED_NOT_IMPLEMENTED, DIVERGED)

**Option B: Direct PRD Parsing**
1. Read PRD files in `docs/1-prd/` (excluding 99-discrepancies.md)
2. Extract features, requirements, and scope items
3. Compare against completed items to identify unimplemented features

### Step 2: Read Planning State

Read existing planning documents:

1. `docs/2-current/00-overall-plan.md` - current roadmap
2. `docs/2-current/02-completed.md` - completed features
3. `docs/tickets/index.md` - existing tickets

Determine:
- Which features already have tickets
- Current project phase
- What's missing from roadmap

### Step 3: Update Planning Docs

Update `docs/2-current/` documents:

**00-overall-plan.md:**
- Add unimplemented features to roadmap
- Update phases if needed
- Mark completed items appropriately
- **Analyze dependencies and development order** (see below)

**02-completed.md:**
- Add any features found complete during analysis

If no updates needed, report and exit.

#### Dependency Analysis

After listing items in `00-overall-plan.md`, add dependencies section:

```markdown
## Ticket Dependencies

### Dependency Graph
| Ticket | Depends On | Can Start After |
|--------|------------|-----------------|
| T00001 | - | Immediate |
| T00002 | - | Immediate |
| T00003 | T00001 | T00001 complete |
| T00004 | T00001, T00002 | T00001+T00002 complete |

### Parallel Development
Tickets that can be developed simultaneously:
- **Group 1 (no dependencies):** T00001, T00002
- **Group 2 (after Group 1):** T00003, T00005
- **Group 3 (after T00004):** T00006

### Recommended Order
1. T00001, T00002 (parallel)
2. T00003 (depends on T00001)
3. T00004 (depends on T00001, T00002)
4. T00005, T00006 (parallel, after T00004)
```

**Dependency criteria:**
- Shared data models or APIs
- Feature builds on another feature
- Infrastructure requirements
- Test dependencies

### Step 4: Verify

Check planning docs are valid:

1. `00-overall-plan.md` exists and not empty
2. No dangling references
3. Dependency graph is consistent

If verification fails, fix issues and re-verify (max 3 retries).

### Step 5: Commit

Stage and commit planning changes:

```bash
git add docs/2-current/*.md
git commit -m "Update planning docs from PRD analysis"
```

## Output

After running this skill:
- Planning docs updated with unimplemented features
- Dependency analysis added/updated
- Changes committed with descriptive message
- **No ticket definitions created**

## Example Usage

```
User: Update planning docs from PRD
Assistant: [Uses pmc-planning skill to update 00-overall-plan.md]
```

```
User: Analyze roadmap dependencies
Assistant: [Uses pmc-planning skill to add dependency analysis]
```

```
User: Sync planning without creating tickets
Assistant: [Uses pmc-planning skill]
```

## Relation to Other Skills

| Skill | Purpose |
|-------|---------|
| `analyze-gaps` | Generates discrepancies report (optional input) |
| `sync-prd` | Updates PRD docs |
| `pmc-planning` | Updates planning without tickets - this skill |
| `project-manager` | Coordinates ticket implementation |
