---
name: code-critique
description: Identifies, categorizes, and articulates code issues with brutal honesty and quantifiable specificity. Use when reviewing code, providing feedback, performing code audits, or when user needs direct assessment of code quality.
---

# Code Critique

Systematic methodology for identifying code problems and communicating them with precision, specificity, and quantifiable evidence. No hedging, no softening, no vague suggestions.

## Quick Start

**Full code critique:**
```
Perform a brutally honest code critique of this file. Identify all issues with specific line numbers, categories, and severity scores.
```

**Targeted review:**
```
Review this function for violations. Name each code smell, cite the line, and score severity 1-10.
```

**Pre-PR audit:**
```
Audit this code before PR submission. List every issue that would fail review, with exact locations.
```

## Core Principles

### The Three Commandments

1. **Be Direct** - State the problem, not a suggestion
2. **Be Specific** - Line numbers, counts, exact violations
3. **Be Quantitative** - Numbers, metrics, comparisons

### Language Standards

| Never Say | Always Say |
|-----------|------------|
| "Perhaps consider..." | "This violates X because Y" |
| "It might be nice if..." | "Line 47 requires Z" |
| "Generally speaking..." | "Lines 23-89 contain 7 instances of X" |
| "Could be improved" | "Fails criterion X, scores 2/10" |
| "Seems a bit long" | "This is 200 lines - 4x the recommended maximum" |
| "Error handling could be better" | "Line 47 catches Error but ignores it" |
| "Changes require touching many files" | "This is Shotgun Surgery - 12 files need modification" |

---

## Critique Methodology

### Phase 1: Structural Scan

Identify violations in code organization and architecture.

```
STRUCTURAL CHECKLIST
[ ] File length (>300 lines = violation)
[ ] Function length (>50 lines = violation)
[ ] Class responsibility count (>1 = violation)
[ ] Nesting depth (>3 levels = violation)
[ ] Parameter count (>4 = violation)
[ ] Return points (>3 per function = violation)
```

**Output format:**
```
STRUCTURAL VIOLATIONS: 7

1. FILE LENGTH: 487 lines (limit: 300, 62% over)
   - Extract: lines 234-340 (user validation logic)
   - Extract: lines 400-487 (formatting utilities)

2. FUNCTION: processOrder() at line 45 - 89 lines (limit: 50, 78% over)
   - Cyclomatic complexity: 23 (limit: 10)
   - Nesting depth: 5 levels (limit: 3)
```

### Phase 2: Naming Audit

Evaluate identifier quality with specific violations.

```
NAMING VIOLATIONS: 12

1. Line 23: `d` - Single letter variable (data? date? delta?)
2. Line 45: `handleStuff()` - Vague action verb
3. Line 67: `temp` - Meaningless temporary
4. Line 89: `data2` - Numeric suffix instead of meaning
5. Line 112: `doIt()` - Completely opaque purpose
```

**Naming severity scale:**
- **Critical (9-10)**: Actively misleading (`isValid` returns void)
- **High (7-8)**: Completely opaque (`x`, `temp`, `data`)
- **Medium (4-6)**: Vague but guessable (`handle`, `process`, `doStuff`)
- **Low (1-3)**: Suboptimal but clear (`getUserData` vs `fetchUser`)

### Phase 3: Logic Review

Find bugs, edge cases, and logical flaws.

```
LOGIC ISSUES: 5

1. Line 78: NULL DEREFERENCE - `user.name` accessed without null check
   - user comes from getUserById() which returns null on miss
   - Will throw at runtime when user not found

2. Line 112: OFF-BY-ONE - Loop iterates i <= array.length
   - Last iteration accesses array[array.length] = undefined
   - Should be i < array.length

3. Line 156: RACE CONDITION - Async write without await
   - saveToDatabase() is async but not awaited
   - Subsequent read may see stale data
```

### Phase 4: Performance Scan

Identify inefficiencies with quantified impact.

```
PERFORMANCE ISSUES: 4

1. Line 45-67: N+1 QUERY - Database called in loop
   - 1 query per user, N users = N+1 total queries
   - Current: ~200ms per user * 100 users = 20 seconds
   - Fixed: 1 batch query = ~250ms total
   - Impact: 80x improvement

2. Line 89: REDUNDANT COMPUTATION - filter().map() chain
   - Array iterated twice, can be single reduce()
   - Memory: 2x array allocation vs 1x
```

### Phase 5: Security Audit

Flag vulnerabilities with severity ratings.

```
SECURITY VULNERABILITIES: 3

1. CRITICAL - Line 34: SQL INJECTION
   - Query built with string concatenation: `"SELECT * FROM users WHERE id = " + userId`
   - Exploitable: userId = "1; DROP TABLE users;--"
   - Fix: Use parameterized queries

2. HIGH - Line 78: XSS VULNERABILITY
   - User input rendered without escaping: innerHTML = userComment
   - Fix: Use textContent or sanitize HTML

3. MEDIUM - Line 112: HARDCODED SECRET
   - API key in source: `apiKey = "sk_live_abc123"`
   - Fix: Environment variable
```

### Phase 6: Style Violations

Consistency and convention issues.

```
STYLE VIOLATIONS: 18

1. Lines 23, 45, 67, 89: INCONSISTENT QUOTES
   - 4 single quotes, rest of file uses double quotes

2. Lines 34-56: INCONSISTENT INDENTATION
   - Mix of 2-space and 4-space indentation

3. Line 78: TRAILING WHITESPACE
   - 4 trailing spaces
```

---

## Issue Categorization

### Category Taxonomy

| Category | Description | Severity Weight |
|----------|-------------|-----------------|
| **Security** | Vulnerabilities, injection, exposure | x3 |
| **Logic** | Bugs, edge cases, incorrect behavior | x3 |
| **Performance** | Inefficiency, resource waste | x2 |
| **Structural** | Organization, complexity, coupling | x2 |
| **Naming** | Unclear, misleading identifiers | x1 |
| **Style** | Formatting, consistency | x1 |

### Severity Scoring

Each issue gets a raw severity (1-10) multiplied by category weight.

```
WEIGHTED SEVERITY CALCULATION

Issue: SQL Injection at line 34
- Raw severity: 10 (critical exploitable vulnerability)
- Category: Security (weight: x3)
- Weighted score: 30

Issue: Vague variable name at line 23
- Raw severity: 4 (guessable meaning)
- Category: Naming (weight: x1)
- Weighted score: 4
```

### Quality Score Calculation

```
QUALITY SCORE = 100 - (sum of weighted severities / lines of code * 10)

Example:
- File: 200 lines
- Total weighted severity: 85
- Score: 100 - (85/200 * 10) = 100 - 4.25 = 95.75/100

Interpretation:
- 90-100: Production ready, minor polish only
- 70-89: Acceptable with noted improvements
- 50-69: Significant issues, review required
- Below 50: Not production ready, major rework needed
```

---

## Communication Patterns

### The Critique Template

```markdown
## Code Critique: {filename}

**Quality Score: {X}/100** ({interpretation})

### Summary
- {N} critical issues requiring immediate fix
- {N} high-priority issues for this PR
- {N} medium issues to address soon
- {N} low-priority style/polish items

### Critical Issues
| # | Line | Category | Issue | Severity |
|---|------|----------|-------|----------|
| 1 | 34 | Security | SQL injection via string concatenation | 10 |
| 2 | 78 | Logic | Null dereference on user.name | 9 |

### High Priority
...

### Quantified Summary
- Lines of code: {N}
- Issues per 100 LOC: {N}
- Worst function: {name} at line {N} - {count} issues
- Most common violation: {type} - {count} occurrences
```

### Brutal But Professional Phrasing

See [references/brutal-phrasing.md](references/brutal-phrasing.md) for comprehensive phrasing examples.

**The Pattern:**
```
"{This is} [named problem]. {Evidence: specific location and count}. {Impact: what breaks}."
```

**Examples:**
```
"This is a God Class. UserManager has 47 methods across 1,200 lines handling auth, email, billing, and analytics. Changes to any feature risk breaking unrelated functionality."

"Line 67 has a resource leak. FileInputStream opened but never closed in finally block. Each call leaks one file descriptor; production will hit ulimit after ~1000 requests."

"This function violates SRP. processOrder() at line 45 does validation (lines 46-78), pricing (lines 79-112), inventory check (lines 113-145), and notification (lines 146-189). That's 4 distinct responsibilities in one 144-line function."
```

---

## Evidence Gathering

### Quantification Requirements

Every critique must include:

1. **Location** - File, line number(s), function name
2. **Count** - How many occurrences
3. **Measurement** - Size, complexity, percentage
4. **Comparison** - To standard, limit, or best practice
5. **Impact** - What breaks, degrades, or fails

See [references/evidence-gathering.md](references/evidence-gathering.md) for detailed measurement techniques.

### Standard Measurements

| Metric | Tool/Method | Threshold |
|--------|-------------|-----------|
| Cyclomatic complexity | escomplex, radon | >10 = problem |
| Cognitive complexity | SonarQube | >15 = problem |
| Lines per function | wc -l | >50 = problem |
| Lines per file | wc -l | >300 = problem |
| Nesting depth | manual/lint | >3 = problem |
| Parameters per function | manual/lint | >4 = problem |
| Dependencies per module | madge | >10 = problem |

---

## Common Issue Patterns

See [references/issue-patterns.md](references/issue-patterns.md) for the complete catalog.

### Quick Reference

| Pattern | Detection | One-liner |
|---------|-----------|-----------|
| God Class | >500 lines, >20 methods | "This class has {N} responsibilities; should have 1" |
| Shotgun Surgery | Change requires N files | "Modifying X requires touching {N} files" |
| Feature Envy | Method uses other class more | "This method accesses OtherClass {N} times, self {M} times" |
| Primitive Obsession | Strings for structured data | "Email/phone/money represented as raw strings {N} times" |
| Long Parameter List | >4 parameters | "Function takes {N} parameters; max recommended is 4" |
| Magic Numbers | Unexplained literals | "Lines {list} contain unexplained numeric literals" |
| Dead Code | Unreachable/unused | "Lines {N-M} are unreachable due to early return at line {X}" |
| Copy-Paste | Duplicated blocks | "Lines {A-B} duplicate lines {C-D} with {N}% similarity" |

---

## Critique Workflows

### Quick Review

```
1. File length check - over 300 lines?
2. Function length scan - any over 50 lines?
3. Complexity hotspots - deeply nested code?
4. Obvious violations - hardcoded values, console.logs?
5. Top 3 issues with line numbers
```

### Standard Review

```
1. STRUCTURE - Run full structural scan
2. NAMING - Audit all identifiers in modified code
3. LOGIC - Trace happy path and 2 edge cases
4. SECURITY - Check all inputs/outputs
5. STYLE - Verify consistency
6. Generate quantified report
```

### Deep Audit

```
1. Run static analysis tools
2. Complete all 6 phases with full documentation
3. Calculate quality score
4. Generate dependency analysis
5. Document technical debt items
6. Produce remediation roadmap with effort estimates
```

---

## Output Templates

### Issue Entry

```markdown
### [{CATEGORY}] {Issue Name}
**Location:** `{file}:{line}` in `{function}()`
**Severity:** {N}/10 (weighted: {N*weight})
**Count:** {N} occurrence(s)

**Evidence:**
{Specific code snippet or measurement}

**Impact:**
{What breaks, fails, or degrades}

**Fix:**
{Specific remediation with example}
```

### Critique Summary

```markdown
# Code Critique Report

## Metadata
- **File:** {path}
- **Lines:** {N}
- **Functions:** {N}
- **Review depth:** {Quick|Standard|Deep}

## Quality Score: {N}/100

## Issue Distribution
| Category | Count | Weighted Score |
|----------|-------|----------------|
| Security | {N} | {N} |
| Logic | {N} | {N} |
| Performance | {N} | {N} |
| Structural | {N} | {N} |
| Naming | {N} | {N} |
| Style | {N} | {N} |
| **Total** | **{N}** | **{N}** |

## Issues by Severity
- Critical (9-10): {N}
- High (7-8): {N}
- Medium (4-6): {N}
- Low (1-3): {N}

## Top 5 Issues
1. {Brief description with line number}
2. ...

## Detailed Findings
{Full issue entries}
```

---

## Reference Files

- [references/issue-patterns.md](references/issue-patterns.md) - Complete catalog of code smells and anti-patterns
- [references/brutal-phrasing.md](references/brutal-phrasing.md) - Direct language patterns for honest feedback
- [references/categorization.md](references/categorization.md) - Issue category taxonomy and severity weights
- [references/evidence-gathering.md](references/evidence-gathering.md) - Quantification techniques and measurement tools
