---
name: sdd-orchestrator
description: Use when the user is starting a project or wants to catch up on project progress - scans the specs/ folder, surfaces current status, proposes the next SDD phase, and routes to the appropriate workflow after confirmation.
---

# Spec-Driven Development Orchestrator

## What It Does

1. Scans `specs/` folder structure
2. Detects state (product docs? active specs? current phase?)
3. **Announces** status clearly with visual indicators
4. **Proposes** logical next step with reasoning
5. **Waits** for your confirmation
6. **Routes** to appropriate workflow skill

**Core principle:** Never proceed without confirmation. Always present options.

## The Process

### Step 1: Scan Project State

```bash
# Check product documentation
[ -f "specs/product/mission.md" ] && \
[ -f "specs/product/roadmap.md" ] && \
[ -f "specs/product/tech-stack.md" ]
PRODUCT_COMPLETE=$?

# Find spec folders (dated format: YYYY-MM-DD-name) (limit to 5 most recent)
find specs/features -maxdepth 1 -type d -name "20*" 2>/dev/null | sort -r | head -5
```

### Step 2: Detect Each Spec's Phase

For each spec folder:

```bash
SPEC="specs/features/2025-11-09-feature-name"

# Check phase progression
if [ ! -f "$SPEC/planning/initialization.md" ]; then
  STATUS="NOT_STARTED"
elif [ ! -f "$SPEC/planning/requirements.md" ]; then
  STATUS="IN_REQUIREMENTS"
elif [ ! -f "$SPEC/spec.md" ]; then
  STATUS="IN_SPEC_WRITING"
elif [ ! -f "$SPEC/tasks.md" ]; then
  STATUS="IN_TASKS_PLANNING"
elif [ ! -f "$SPEC/verification/spec-verification.md" ]; then
  STATUS="IN_SPEC_VERIFICATION"
elif grep -q "Status.*Failed" "$SPEC/verification/spec-verification.md"; then
  STATUS="SPEC_FAILED_VERIFICATION"
elif [ ! -f "$SPEC/verification/final-verification.md" ]; then
  if grep -q "^- \[ \]" "$SPEC/tasks.md"; then
    STATUS="IN_IMPLEMENTATION"
  else
    STATUS="IMPLEMENTATION_READY"
  fi
else
  STATUS="FULLY_COMPLETE"
fi
```

### Step 3: Announce Status

```
📋 Spec-Driven Development Status

Product Documentation:
[If complete]
  ✅ specs/product/mission.md
  ✅ specs/product/roadmap.md
  ✅ specs/product/tech-stack.md
[If missing]
  ⚠️  Product documentation needed

Active Specs:
[For each spec]
  [Icon] 2025-11-09-feature-name
    └─ Phase: [Phase description]
    [If implementing]
    └─ Tasks: [X/Y] complete

Next Roadmap Item:
  [ ] Feature name - Description
```

**Status Icons:**
- ⚪ NOT_STARTED
- 🔵 IN_REQUIREMENTS
- 🟡 IN_SPEC_WRITING
- 🟠 IN_TASKS_PLANNING
- 🟣 IN_SPEC_VERIFICATION
- ❌ SPEC_FAILED_VERIFICATION
- 🟢 IMPLEMENTATION_READY
- 🔄 IN_IMPLEMENTATION
- ✅ FULLY_COMPLETE

### Step 4: Propose Next Step

Based on state:

**No product docs:**
```
Proposed: Create product documentation
Required before creating specs.
```

**Incomplete spec:**
```
Proposed: Continue [spec-name] - [phase]
[What this phase does]
```

**Spec ready:**
```
Proposed: Implement [spec-name]
[X] task groups ready to build
```

**No active specs:**
```
Proposed: Start next roadmap item - [feature]
Or create new spec for different feature.
```

### Step 5: Present Options

```
What would you like to do?

1. [Proposed action]
2. Start a new spec
3. Review completed work
4. Something else (describe)

Choose option or tell me what you'd like to work on.
```

**STOP. Wait for response.**

### Step 6: Route to Workflow

| State | Route To |
|-------|----------|
| No product docs | `product-planning` |
| In requirements | `spec-creation-workflow` (Phase 2) |
| In spec writing | `spec-creation-workflow` (Phase 3) |
| In tasks planning | `spec-creation-workflow` (Phase 4) |
| In verification | `spec-creation-workflow` (Phase 5) |
| Ready for implementation | `spec-implementation-workflow` |
| In implementation | `spec-implementation-workflow` (continue) |

## State Detection Reference

**File-based detection only** - no hidden state:

```
specs/features/YYYY-MM-DD-name/
├─ planning/initialization.md     [EXISTS = Phase 1 complete]
├─ planning/requirements.md        [EXISTS = Phase 2 complete]
├─ spec.md                         [EXISTS = Phase 3 complete]
├─ tasks.md                        [EXISTS = Phase 4 complete]
├─ verification/spec-verification.md [EXISTS = Phase 5 complete]
└─ verification/final-verification.md [EXISTS = Fully complete]

tasks.md checkboxes:
- [ ] = incomplete
- [x] = complete

roadmap.md checkboxes:
1. [ ] = not done
2. [x] = done
```

## Red Flags

**Never:**
- Proceed without user confirmation
- Assume what user wants
- Skip status announcement
- Auto-route without offering alternatives

**Always:**
- Scan filesystem for current state
- Present clear status
- Propose with reasoning
- Offer alternatives
- Wait for explicit choice

## Integration

**Routes to:**
- `product-planning` - First-time setup
- `spec-creation-workflow` - Creating/completing specs
- `spec-implementation-workflow` - Implementing specs

**Returns from:**
- All workflows return here when complete
- Orchestrator re-scans and shows updated status

## Context Preservation
When returning from other workflows, briefly summarize what was accomplished to maintain continuity.
