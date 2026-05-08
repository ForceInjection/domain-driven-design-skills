---
name: speckit-validator

description: >
  Validates specification completeness and quality by checking for mandatory sections,
  [NEEDS CLARIFICATION] markers, testable criteria, and clear scope boundaries.
  Ensures specifications are ready for architecture and implementation phases.

triggers:
  - "Is my spec complete?"
  - "Check spec"
  - "Validate specification"
  - "spec validation"
  - "review spec.md"
  - "spec quality check"
  - "is my specification ready"
  - "validate spec.md"
  - "check specification completeness"

allowed-tools: [Read, Grep, Glob, TodoWrite]

model: claude-sonnet-4-5-20250929

color: "#3B82F6"

expertise:
  - specification-validation
  - requirements-quality
  - spec-driven-development

examples:
  - "Is my spec complete?"
  - "Check if my specification is ready"
  - "Validate spec.md"
  - "Review my feature specification"

boundaries: "Does not write specifications - only validates existing spec.md files for completeness and quality"
---

# SpecKit Validator Skill

## Purpose

Automatically validates specification files (spec.md) for completeness, quality, and readiness for architecture and implementation phases. Implements FR-004 from the feature specification.

## How It Works

### Step 1: Locate Specification

- Search for `specs/*/spec.md` files in the repository
- If specific feature directory provided, validate that spec.md
- Report if spec.md not found

### Step 2: Validate Mandatory Sections

Check for required sections per Speckit specification template:

- **User Scenarios & Testing** (mandatory)
  - User stories with acceptance scenarios
  - Independent test criteria
  - Edge cases identified

- **Requirements** (mandatory)
  - Functional requirements
  - Key entities

- **Success Criteria** (mandatory)
  - Measurable outcomes

- **Scope** (mandatory)
  - In scope
  - Out of scope

- **Assumptions** (optional but recommended)
- **Dependencies** (optional but recommended)
- **References** (optional)

### Step 3: Check for Clarification Markers

- Grep for `[NEEDS CLARIFICATION]` markers
- Report all instances with line numbers
- Specification not ready if any markers remain

### Step 4: Validate Testable Criteria

- Check that each user story has clear acceptance scenarios
- Verify success criteria are measurable (contain numbers/percentages)
- Ensure requirements have validation criteria

### Step 5: Check Scope Boundaries

- Verify "In Scope" section exists and is populated
- Verify "Out of Scope" section exists (clear boundaries)
- Check that scope is clearly bounded (not open-ended)

### Step 6: Generate Validation Report

Report format:
```
✅ Specification Validation Report

File: specs/{feature-id}/spec.md

Mandatory Sections:
- [✓/✗] User Scenarios & Testing
- [✓/✗] Requirements (Functional Requirements)
- [✓/✗] Success Criteria
- [✓/✗] Scope (In/Out)

Quality Checks:
- [✓/✗] No [NEEDS CLARIFICATION] markers
- [✓/✗] All requirements testable
- [✓/✗] Scope clearly bounded
- [✓/✗] Success criteria measurable

Status: READY / NOT READY

Issues Found:
1. [Issue description with line number]
2. [Issue description with line number]

Recommendations:
- [Specific action to resolve each issue]
```

## Examples

### Example 1: Complete Specification

**User Query**: "Is my spec complete?"

**Skill Actions**:
1. Read `specs/005-create-a-specification/spec.md`
2. Check all mandatory sections present
3. Grep for [NEEDS CLARIFICATION] - none found
4. Validate testable criteria - all pass
5. Check scope boundaries - clearly defined

**Result**:
```
✅ Specification Validation: READY

File: specs/005-create-a-specification/spec.md

All mandatory sections present ✓
No clarification markers found ✓
All requirements testable ✓
Scope clearly bounded ✓

Your specification is ready for /speckit.plan!
```

### Example 2: Incomplete Specification

**User Query**: "Check spec.md"

**Skill Actions**:
1. Read `specs/004-feature/spec.md`
2. Missing "Success Criteria" section
3. Found 3 [NEEDS CLARIFICATION] markers
4. Some requirements not testable

**Result**:
```
✗ Specification Validation: NOT READY

Issues Found:
1. Missing mandatory section: Success Criteria
2. Found 3 [NEEDS CLARIFICATION] markers:
   - Line 42: "[NEEDS CLARIFICATION] How should errors be handled?"
   - Line 78: "[NEEDS CLARIFICATION] What is the performance target?"
   - Line 103: "[NEEDS CLARIFICATION] Which authentication method?"
3. Requirements lack testable criteria:
   - FR-003: No validation method specified
   - FR-007: Vague acceptance criteria

Recommendations:
1. Add Success Criteria section with measurable outcomes
2. Resolve all [NEEDS CLARIFICATION] markers using /speckit.clarify
3. Add specific validation criteria to FR-003 and FR-007

Run /speckit.clarify to resolve clarification markers.
```

## Integration

### Uses

- **Read**: Load spec.md file contents
- **Grep**: Search for [NEEDS CLARIFICATION] markers and section headers
- **Glob**: Find spec.md files if location not specified
- **TodoWrite**: Track validation issues if fixing specification

### Updates

- None (read-only validation)

### Invokes

- Can suggest using /speckit.clarify command if clarifications needed

## Validation Logic

```bash
# Find specification
find specs/ -name "spec.md"

# Check for mandatory sections
grep "## User Scenarios & Testing" spec.md
grep "## Requirements" spec.md
grep "## Success Criteria" spec.md
grep "## Scope" spec.md

# Check for clarification markers
grep -n "\[NEEDS CLARIFICATION\]" spec.md

# Check for testable criteria
grep -A 5 "Acceptance Scenarios:" spec.md
grep -E "[0-9]+%" spec.md  # Measurable success criteria
```

## Constitutional Compliance

- **Specification-Driven**: Enforces spec completion before proceeding (Principle II)
- **Quality Focus**: Ensures high-quality specifications for better outcomes
- **Read-Only**: No modifications to specs, only validation
