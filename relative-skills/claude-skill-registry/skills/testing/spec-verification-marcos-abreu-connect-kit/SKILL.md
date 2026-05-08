---
name: spec-verification
description: Use during Phase 5 of spec creation to verify completeness and accuracy before implementation - checks requirements accuracy, visual integration, reusability leverage, task specificity, and identifies over-engineering concerns
---

# Spec Verification

## What It Does

Verifies specification through systematic checks:
1. Requirements accuracy (vs original Q&A)
2. Visual asset integration
3. Reusability opportunities leveraged
4. Task specificity and traceability
5. Over-engineering concerns
6. Creates verification report with findings

**Pass = ready for implementation. Fail = fix issues first.**

## The Process

### Step 1: Load All Documentation

```bash
SPEC="[provided by workflow]"

cat "$SPEC/planning/initialization.md"
cat "$SPEC/planning/requirements.md"
cat "$SPEC/spec.md"
cat "$SPEC/tasks.md"
ls -la "$SPEC/planning/visuals/"
```

Keep original Q&A from requirements gathering in memory.

### Step 2: Run Verification Checks

#### Check 1: Requirements Accuracy

Compare requirements.md against original Q&A:

```
✓ All questions documented
✓ All answers captured exactly
✓ Follow-ups included
✓ Reusability opportunities documented

Flag:
✗ Missing answers
✗ Modified answers (should be exact)
✗ Missing follow-ups
```

#### Check 2: Visual Assets

```bash
VISUALS=$(ls "$SPEC/planning/visuals/" 2>/dev/null)

if [ ! -z "$VISUALS" ]; then
  # Read each visual
  # Check requirements.md mentions them
  grep -q "Visual Assets" "$SPEC/planning/requirements.md"
fi
```

**If visuals exist, verify:**
```
✓ Mentioned in requirements.md
✓ Design elements in spec.md
✓ Tasks reference visual files
✓ Fidelity level noted

Flag:
✗ Visuals not in requirements
✗ Elements missing from spec
✗ Tasks don't reference mockups
```

#### Check 3: Visual Design Analysis

**Only if visuals exist** - Read each file:

```
For each visual:
1. Identify components (header, sidebar, cards, forms)
2. Note layout structure
3. Observe colors/typography (if high-fi)
4. Document interactive elements

Then verify:
✓ Visual Design section exists in spec.md
✓ Each file has description
✓ Key components mentioned
✓ Layout captured

And in tasks.md:
✓ Frontend tasks reference visual files
✓ Tasks mention building shown components
```

#### Check 4: Requirements Coverage

From requirements.md, build checklist:

**Explicit features:**
- [Feature A]
- [Feature B]

**Check spec.md:**
```
✓ Each feature has requirement
✗ Missing features
✗ Added features (not in requirements)
✗ Changed scope
```

**Reusability opportunities:**
```
User mentioned:
- [Similar feature/path]

Check spec.md "Existing Code to Leverage":
✓ User-mentioned features referenced
✓ Paths documented
✗ Opportunities ignored
```

**Out of scope:**
```
User said NOT to include:
- [Item A]

Check spec.md "Out of Scope":
✓ All exclusions listed
✗ Missing exclusions
✗ Excluded items in requirements
```

#### Check 5: Spec Structure

```
✓ Goal section (1-2 sentences)
✓ User Stories (2-3 stories)
✓ Specific Requirements
✓ Visual Design (if visuals exist)
✓ Existing Code to Leverage
✓ Out of Scope

Flag:
✗ Extra sections (violates template)
✗ Missing required sections
✗ Vague requirements
✗ Ignoring reusability
```

#### Check 6: Task List Validation

**Task specificity:**
```
✓ Each task references specific component
✓ Traceable to spec requirements
✓ Clear acceptance criteria

Flag:
✗ Vague tasks ("add validation")
✗ Tasks not in requirements
✗ Missing visual references (if visuals exist)
```

**Reusability references:**
```
✓ Tasks note "(reuse: [name])" where applicable

Flag:
✗ Tasks recreate existing components
✗ Missing reuse notes
```

**Task count per group:**
```
✓ 3-10 tasks per group

Flag:
✗ More than 10 (possibly over-engineered)
✗ Fewer than 3 (possibly too broad)
```

#### Check 7: Over-Engineering

```
Flag unnecessary complexity:
✗ New component when existing works
✗ Duplicating existing logic
✗ Features beyond requirements
✗ Premature optimization
✗ Unnecessary abstractions
```

### Step 3: Create Verification Report

```bash
mkdir -p "$SPEC/verification"

cat > "$SPEC/verification/spec-verification.md" <<'EOF'
# Specification Verification Report

## Summary
- **Status:** [✅ Passed / ⚠️ Issues / ❌ Failed]
- **Date:** [Current date]
- **Spec:** [Spec name]
- **Reusability:** [✅ Passed / ⚠️ Concerns / ❌ Failed]

## Structural Verification

### Check 1: Requirements Accuracy
[Findings]

### Check 2: Visual Assets
[Findings]

## Content Validation

### Check 3: Visual Design Tracking
[If visuals exist - each visual's tracking]

### Check 4: Requirements Coverage

**Explicit Features:**
- Feature A: [✅ Covered / ❌ Missing]

**Reusability:**
- [Feature] at [path]: [✅ Referenced / ⚠️ Not leveraged]

**Out of Scope:**
- Correctly excluded: [list]
- Issues: [list if any]

### Check 5: Spec Structure
[Findings]

### Check 6: Task List
[Findings on specificity, reusability, visual references]

### Check 7: Over-Engineering
[Any unnecessary complexity identified]

## Issues Summary

### Critical Issues (MUST fix)
1. [Issue]

### Important Issues (Should fix)
1. [Issue]

### Minor Issues (Optional)
1. [Issue]

### Over-Engineering Concerns
1. [Issue]

## Recommendations
1. [Specific recommendation]

## Conclusion
[Assessment with guidance]

[If passed:]
Spec complete, accurate, ready for implementation.

[If issues:]
Address [X] critical and [Y] important issues before implementation.
EOF
```

### Step 4: Present Results

**If PASSED:**
```
✅ Specification Verification PASSED

Checks completed:
✅ Requirements accurate
✅ Visuals integrated ([X] files)
✅ Reusability leveraged
✅ Tasks specific and traceable
✅ No over-engineering

Report: verification/spec-verification.md

🎉 Spec ready for implementation!

What next?
1. Start implementation
2. Review report
3. Optional improvements
4. Return to /catchup
```

**If ISSUES:**
```
⚠️  Specification Verification Found Issues

Status: [⚠️ Issues / ❌ Failed]

Summary:
- Critical: [X] (MUST fix)
- Important: [Y] (Should fix)
- Minor: [Z] (Optional)
- Over-engineering: [A]

Critical:
1. [Brief description]

Report: verification/spec-verification.md

Options:
1. Review full report
2. Fix automatically
3. Fix specific issues
4. I'll fix manually

What next?
```

**WAIT for choice.**

### Step 5: Handle Issues

**If automatic fix:**

For each critical/important:
1. Identify affected file
2. Determine fix
3. Apply fix
4. Show change
5. Continue

**After fixes:**
```
Applied fixes:
✅ [Issue 1] - [Change]

Re-running verification...
```

**Re-run from Step 2.**

**If specific fixes:**
- User specifies issues
- Fix those
- Re-verify

**If manual:**
- Provide guidance
- Return to workflow

## Red Flags

**Never:**
- Skip visual analysis if files exist
- Approve with critical issues
- Ignore reusability opportunities
- Allow feature creep

**Always:**
- Run bash to verify visuals
- Read and analyze visual files
- Verify reusability leveraged
- Distinguish issue severity

## Integration

**Called by:**
- `spec-creation-workflow` (Phase 5)

**Returns to:**
- `spec-creation-workflow` with status

**Creates:**
- `[spec]/verification/spec-verification.md`

**May trigger:**
- Re-execution of Phases 2-4 to fix issues

**Next if passed:**
- Ready for `spec-implementation-workflow`
