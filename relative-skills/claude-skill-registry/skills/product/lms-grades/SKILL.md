---
name: lms-grades
description: LMS gradebook system for LT/IT (English Language Arts) and KCFS (Kang Chiao Future Skill) courses. Use this skill when implementing grade calculation, gradebook features, expectations system, or assessment title management.
---

# LMS Grades - Gradebook System

## Quick Reference

| System | Score Range | Formula |
|--------|-------------|---------|
| LT/IT | 0-100 | Weighted avg: FA 15%, SA 20%, Final 10% |
| KCFS | 0-5 (→50-100) | Base 50 + weighted categories |

## Two Calculation Engines

| Engine | File | Final Code | Use Case |
|--------|------|-----------|----------|
| Core Grade | `lib/grade/calculations.ts` | **FINAL** | Historical reports |
| Formula Engine | `lib/gradebook/FormulaEngine.ts` | **MID** | Live gradebook |

## LT/IT Grades (English)

### Assessment Codes (14 total)
- **FA1-FA8**: Formative Assessments (15% total, 0.0188 each)
- **SA1-SA4**: Summative Assessments (20% total, 0.05 each)
- **FINAL/MID**: Final/Midterm Exam (10%)

### Formula
```
Semester = (FA_avg × 0.15 + SA_avg × 0.20 + FINAL × 0.10) ÷ 0.45
```

**Rules**:
- Only scores >0 included
- All zeros → null

→ See: [references/lt-it-formula.md](references/lt-it-formula.md)

## KCFS Grades (Future Skills)

### Formula
```
Term Grade = 50 + Σ(category_score × weight)
```

### Categories by Grade

| Grade | Categories | Weight |
|-------|------------|--------|
| G1-2 | COMM, COLLAB, SD, CT | 2.5 |
| G3-4 | + BW (5 total) | 2.0 |
| G5-6 | + PORT, PRES (6 total) | 5/3 |

**Rules**:
- Scores 0-5 (0.5 increments)
- Zero counts (lowers grade)
- Blank/Absent excluded

→ See: [references/kcfs-formula.md](references/kcfs-formula.md)

## Key Files

| Purpose | Location |
|---------|----------|
| Core Calculations | `lib/grade/calculations.ts` |
| KCFS Calculations | `lib/grade/kcfs-calculations.ts` |
| Formula Engine | `lib/gradebook/FormulaEngine.ts` |
| Gradebook Page | `app/(lms)/class/[classId]/gradebook/` |
| Spreadsheet | `components/gradebook/Spreadsheet.tsx` |
| Expectations | `components/gradebook/ExpectationsManager.tsx` |

## Features

### Gradebook Expectations (v1.52.0)
- Head Teachers set completion targets
- Track teacher progress by grade/course
- Status: on_track / behind / not_started

### Assessment Title Override
- Priority: Class > Grade×Track > Default
- Affects display only, not calculation

## References
- LT/IT Formula: [references/lt-it-formula.md](references/lt-it-formula.md)
- KCFS Formula: [references/kcfs-formula.md](references/kcfs-formula.md)
- KCFS Config: [references/kcfs-config.md](references/kcfs-config.md)
