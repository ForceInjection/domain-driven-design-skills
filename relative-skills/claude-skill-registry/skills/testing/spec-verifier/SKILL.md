---
name: spec-verifier
description: Verify specification quality and completeness. Use after writing spec.md to ensure it meets standards before task breakdown - checks for clarity, feasibility, testability, and completeness.
---

# Spec Verifier

Validate specification documents before proceeding to task creation.

## When to Use
- After completing spec.md
- Before creating tasks.md
- When reviewing existing specs for quality

## Verification Process

1. **Load Checklist**
   - Review [spec-verification-checklist.md](resources/spec-verification-checklist.md)

2. **Analyze Spec**
   - Read `amp-os/specs/[feature]/spec.md`
   - Cross-reference with `planning/requirements.md`

3. **Score Each Category**
   - Clarity & Structure
   - Technical Completeness
   - Feasibility
   - Testability
   - Dependency Awareness

4. **Generate Report**
   - List passing criteria
   - Flag issues with specific recommendations
   - Provide overall readiness assessment

## Output Format
```
## Spec Verification: [Feature Name]

### ✅ Passing
- [criterion]: [evidence]

### ⚠️ Issues
- [criterion]: [problem] → [recommendation]

### Verdict: READY / NEEDS REVISION
```

## Amp Tools to Use
- `oracle` - For complex feasibility analysis
- `finder` - Verify referenced code exists
