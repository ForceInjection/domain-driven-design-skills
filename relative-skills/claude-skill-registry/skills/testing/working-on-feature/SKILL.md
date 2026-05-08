---
name: working-on-feature
description: |
  Load when executing spec/design/plan/implement commands for a specific feature. Provides templates, agent dispatch patterns, and workflow orchestration for per-feature work.
---

# Working on Feature Skill

Orchestrates the per-feature workflow from spec through implementation.

## When to Load

Load this skill when executing:
- `/katachi:spec-feature <ID>`
- `/katachi:design-feature <ID>`
- `/katachi:plan-feature <ID>`
- `/katachi:implement-feature <ID>`
- `/katachi:retrofit-design <ID>` (retrofit mode)

## Key References

**Guidance documents** (how to write each document type):
- `references/spec-template.md` - How to write feature specifications
- `references/design-template.md` - How to write design rationale
- `references/plan-template.md` - How to write implementation plans

**Document templates** (actual templates to follow):
- `references/feature-spec.md` - Feature specification template
- `references/feature-design.md` - Design document template
- `references/implementation-plan.md` - Implementation plan template

## Workflow

### 1. Pre-Check

Before starting any per-feature command:

```python
# Check feature exists in FEATURES.md
feature = get_feature(FEATURE_ID)
if not feature:
    error("Feature not found in FEATURES.md")

# Check dependencies are complete (for design/plan/implement)
if command in ["design", "plan", "implement"]:
    deps = get_dependencies(FEATURE_ID)
    incomplete = [d for d in deps if not is_complete(d, required_phase)]
    if incomplete:
        warn(f"Dependencies not complete: {incomplete}")
```

### 2. Status Update (Start)

Update status when starting:

```bash
# spec-feature
python scripts/features.py status set FEATURE-ID "⧗ Spec"

# design-feature
python scripts/features.py status set FEATURE-ID "⧗ Design"

# plan-feature
python scripts/features.py status set FEATURE-ID "⧗ Plan"

# implement-feature
python scripts/features.py status set FEATURE-ID "⧗ Implementation"
```

### 3. Document Creation Workflow

For spec/design/plan commands:

1. **Research Phase (Silent)**
   - Read relevant context (FEATURES.md, DEPENDENCIES.md)
   - Read previous documents (spec before design, design before plan)
   - Read relevant ADRs and DES patterns
   - Research any libraries/APIs involved

2. **Draft Proposal**
   - Create complete document following template
   - Note uncertainties and assumptions
   - Base choices on research

3. **Present for Review**
   - Show complete document to user
   - Highlight uncertainties
   - Ask: "What needs adjustment?"

4. **Iterate**
   - Apply user corrections
   - Repeat until approved

5. **Validate**
   - Dispatch reviewer agent
   - Review findings with user
   - Apply accepted recommendations

6. **Finalize**
   - Write document to file
   - Update status

### 4. Agent Dispatch

Each command dispatches its reviewer agent:

| Command | Agent | Input |
|---------|-------|-------|
| spec-feature | `katachi:spec-reviewer` | Feature description, completed spec |
| design-feature | `katachi:design-reviewer` | Spec, design, ADR/DES summaries |
| plan-feature | `katachi:plan-reviewer` | Spec, design, plan, ADR/DES summaries |
| implement-feature | `katachi:code-reviewer` | Spec, design, plan, code, ADR/DES |
| retrofit-design | `katachi:codebase-analyzer`, `katachi:design-reviewer` | Spec, implementation code, ADR/DES indexes |

Dispatch pattern:

```python
Task(
    subagent_type="katachi:spec-reviewer",
    prompt=f"""
Review this feature specification:

## Feature Description (from FEATURES.md)
{feature_description}

## Completed Spec
{spec_content}

Provide structured critique following your review criteria.
"""
)
```

### 5. Status Update (Complete)

Update status when completing:

```bash
# After successful completion
python scripts/features.py status set FEATURE-ID "✓ Spec"
python scripts/features.py status set FEATURE-ID "✓ Design"
python scripts/features.py status set FEATURE-ID "✓ Plan"
python scripts/features.py status set FEATURE-ID "✓ Implementation"
```

## Implementation Specifics

### For implement-feature

The implementation workflow is more autonomous:

1. **Read all documentation silently**
   - Plan, spec, design
   - Full ADR/DES documents (not just indexes)
   - Dependency code

2. **Implement all steps autonomously**
   - Follow plan without asking questions
   - Documentation is source of truth
   - Verify each step works before proceeding

3. **Validate with code-reviewer**
   - Dispatch agent after implementation
   - Fix ALL issues automatically
   - Re-run tests after fixes

4. **Present for user review**
   - Show what was implemented
   - Highlight any deviations
   - Note emergent patterns

5. **Iterate based on feedback**
   - Apply user corrections
   - Update documents if implementation differs

6. **Surface patterns for DES**
   - Present discovered patterns
   - User selects which to document

## Pattern Detection

During implementation, watch for:

- **Repeated code structures** → Candidate for DES
- **Cross-cutting concerns** → Document in DES
- **Emerging conventions** → Standardize in DES
- **Better approaches found** → Update existing DES
