---
name: phase2-5-autonomous
description: Phase 2-5 autonomous execution guidance - Activate when Claude needs to decide technical choices during implementation/testing/review/release phases
version: 1.0.0
trigger: phase2|phase3|phase4|phase5|implementation|testing|review|release
---

# Phase 2-5 Autonomous Execution Skill

## 🎯 Skill Purpose

This skill provides detailed guidance for Claude to operate fully autonomously during Phase 2-5 (Implementation, Testing, Review, Release) without asking the user for technical decisions or implementation choices.

## 📋 When to Activate

**Automatically activate when:**
- Current phase is Phase 2, 3, 4, or 5
- Requirements have been clarified (Phase 1 complete)
- AUTO_MODE_ACTIVE flag exists
- Claude is about to ask a technical question

**Keywords that trigger this skill:**
- "Should I use..."
- "Do you want me to..."
- "Is this implementation OK?"
- "Need to optimize?"
- "Fix this bug?"

## 🚫 Absolutely Forbidden Questions

### Technical Choices
```
❌ "Use A library or B library?"
❌ "Implement with pattern X or Y?"
❌ "Need async/await or promises?"
❌ "Use TypeScript or JavaScript?"
```

**Correct behavior:** Choose based on:
1. Project existing stack
2. Performance requirements
3. Maintainability
4. Community best practices

### Implementation Details
```
❌ "Is this implementation correct?"
❌ "Should I refactor this?"
❌ "Add more comments?"
❌ "Extract this to a function?"
```

**Correct behavior:** Apply code quality standards:
- Functions < 150 lines
- Cyclomatic complexity < 15
- Test coverage ≥ 70%
- Follow existing project patterns

### Quality Issues
```
❌ "Found a bug, fix it?"
❌ "Warning detected, handle it?"
❌ "Performance issue, optimize?"
❌ "Code complexity high, simplify?"
```

**Correct behavior:** Fix immediately:
- Bug → Fix + test
- Warning → Handle + verify
- Performance → Benchmark + optimize
- Complexity → Refactor + validate

### Workflow Progress
```
❌ "Phase X complete, continue to Phase Y?"
❌ "Finished implementation, run tests now?"
❌ "All tests pass, proceed to review?"
```

**Correct behavior:** Auto-advance based on:
- Phase completion criteria (CLAUDE.md)
- Quality gate results
- Checklist completion

## ✅ Decision-Making Framework

### 1. Business Requirements → Check Documentation

```bash
Question: "What should the error message say?"

Decision Process:
1. Check .workflow/REQUIREMENTS_DIALOGUE.md
2. Check .workflow/CHECKLIST.md
3. Check docs/P1_DISCOVERY.md
4. If specified → Use that
5. If not specified → Use professional default
```

### 2. Technical Implementation → Apply Standards

```bash
Question: "Which testing framework?"

Decision Process:
1. Check existing tests (grep -r "describe\|it\|test")
2. If found → Use same framework
3. If none → Choose industry standard:
   - JavaScript: Jest/Vitest
   - Python: pytest
   - Bash: bats-core
   - Go: testing package
```

### 3. Code Quality → Enforce Thresholds

```bash
Question: "Function is 200 lines, refactor?"

Decision Process:
1. Check threshold: >150 lines = must refactor
2. Identify logical sections
3. Extract to smaller functions
4. Verify tests still pass
5. Report: "Refactored XX from 200→80 lines"
```

### 4. Performance → Benchmark & Optimize

```bash
Question: "Script takes 3 seconds, optimize?"

Decision Process:
1. Check requirement: hooks must be <2s
2. Profile: identify bottleneck
3. Optimize: apply fix
4. Benchmark: measure improvement
5. Report: "Optimized XX from 3s→0.8s"
```

## 📊 Phase-Specific Guidelines

### Phase 2: Implementation

**Autonomous Actions:**
- Choose libraries (prefer: standard > popular > custom)
- Design architecture (pattern: existing > proven > new)
- Write code (style: project standard > language idiom)
- Create scripts (location: scripts/ > tools/)
- Configure hooks (register in: .git/hooks/ + .claude/hooks/)

**Quality Standards:**
- All functions have docstrings
- No hardcoded values (use config)
- Error handling on all external calls
- Logging for all state changes

**Output Format:**
```
✅ Implemented XX feature
   - Added YY module (using ZZ library - industry standard)
   - Created AA script (follows project pattern)
   - Configured BB hook (registered in settings.json)

   Technical choices made:
   - ZZ library: most maintained, 50k+ stars, TypeScript support
   - AA pattern: matches existing scripts/workflow_*.sh
   - BB hook timing: PreToolUse (needs to intercept before write)
```

### Phase 3: Testing

**Autonomous Actions:**
- Design test cases (coverage: critical path 100%)
- Write unit tests (framework: match existing)
- Write integration tests (scope: end-to-end flows)
- Run static checks (`bash scripts/static_checks.sh`)
- Fix all failures (iterate until green)

**Quality Gates:**
- All syntax errors fixed
- Shellcheck warnings < 5
- Code complexity < 15
- Hook performance < 2s
- Test coverage ≥ 70%

**Output Format:**
```
✅ Testing complete

   Coverage: 78% (target: 70%) ✓
   - Unit tests: 25 passed
   - Integration tests: 8 passed
   - Static checks: all passed

   Issues found and fixed:
   1. Syntax error in line 45 - fixed
   2. Shellcheck SC2086 - quoted variable
   3. Function XX complexity 18→12 - refactored

   Performance:
   - Hook execution: 0.8s (target: <2s) ✓
```

### Phase 4: Review

**Autonomous Actions:**
- Run pre-merge audit (`bash scripts/pre_merge_audit.sh`)
- Fix all critical issues
- Verify version consistency (6 files match)
- Check Phase 1 checklist (≥90% complete)
- Generate REVIEW.md (>100 lines)

**Critical Checks:**
- [ ] No TODO/FIXME in production code
- [ ] Root directory docs ≤7 files
- [ ] All hooks registered
- [ ] All tests passing
- [ ] Version 100% consistent

**Output Format:**
```
✅ Code review complete

   Pre-merge audit: PASSED ✓
   - Critical issues: 0
   - Warnings: 2 (all addressed)
   - Version consistency: 6/6 files ✓
   - Phase 1 checklist: 95% complete ✓

   Review findings:
   1. Optimized XX function (150→85 lines)
   2. Standardized error handling (3 locations)
   3. Added missing test for YY edge case

   REVIEW.md generated: 145 lines
```

### Phase 5: Release

**Autonomous Actions:**
- Update CHANGELOG.md (add version entry)
- Update README.md (update version, add features)
- Create git tag (format: v{VERSION})
- Configure health checks (add to observability/)
- Configure SLO (add to observability/slo/)

**Release Checklist:**
- [ ] CHANGELOG.md updated
- [ ] README.md version bumped
- [ ] Tag created (vX.Y.Z)
- [ ] Health check configured
- [ ] SLO thresholds defined
- [ ] Root docs ≤7 files

**Output Format:**
```
✅ Release prepared

   Version: 8.1.0
   - CHANGELOG.md: added v8.1.0 entry
   - README.md: updated version + features
   - Git tag: v8.1.0 created

   Monitoring configured:
   - Health check: /api/health endpoint
   - SLO: 99.9% uptime, <200ms p95 latency

   Documentation:
   - Root docs: 7 files ✓
   - Phase 1 checklist: 100% complete ✓
```

## 🎯 Decision Principles

### 1. Simplicity > Complexity
```
Choose: Standard library > Popular library > Custom code
Choose: Existing pattern > New pattern
Choose: Fewer dependencies > More dependencies
```

### 2. Consistency > Perfection
```
Match: Existing code style
Match: Project naming conventions
Match: Established patterns
```

### 3. Automation > Manual
```
Automate: Testing
Automate: Quality checks
Automate: Documentation generation
```

### 4. Evidence > Assumption
```
Benchmark before optimizing
Profile before refactoring
Test before claiming "fixed"
```

## 🚨 Red Flags - When to Stop

**Only interrupt autonomous mode if:**

1. **Contradictory requirements** (rare, should be caught in Phase 1)
   ```
   Requirement A: "Must support 10k concurrent users"
   Requirement B: "Run on Raspberry Pi"
   → These contradict, need clarification
   ```

2. **Missing critical information** (rare, should be in requirements)
   ```
   Need: Database connection string
   Found: Not in requirements, not in .env, not in config
   → Cannot proceed without this
   ```

3. **Blocker outside Claude's control**
   ```
   Error: API key invalid
   Error: Network unreachable
   → Need user intervention
   ```

**How to report blockers:**
```
🚨 BLOCKER DETECTED

Issue: XX requires YY but ZZ
Impact: Cannot complete Phase N
Attempted: [list what you tried]
Need: [specific user action required]

Options:
A. User provides YY
B. Skip XX feature (remove from checklist)
C. Use alternative approach (explain pros/cons)
```

## 📖 Reference Materials

### Project Standards
- Code quality: CLAUDE.md "质量保障体系"
- Testing: ≥70% coverage, critical path 100%
- Performance: Hooks <2s, APIs <200ms p95
- Documentation: Root ≤7 files, .temp/ for temporary

### Decision Sources (in order)
1. **Requirements** (.workflow/REQUIREMENTS_DIALOGUE.md)
2. **Acceptance Criteria** (.workflow/CHECKLIST.md)
3. **Technical Plan** (docs/PLAN.md)
4. **Project Standards** (CLAUDE.md)
5. **Existing Code** (grep, read files)
6. **Industry Best Practices** (language idioms, frameworks)

## 💡 Examples

### Example 1: Bug Found During Testing

❌ Wrong:
```
"I found a null pointer bug in login.js line 45. Should I fix it?"
```

✅ Correct:
```
"Fixed null pointer bug in login.js:45

Issue: userName could be null when OAuth fails
Fix: Added null check + fallback to 'Anonymous'
Test: Added unit test for OAuth failure scenario
Verified: All 28 tests passing ✓
```

### Example 2: Performance Issue

❌ Wrong:
```
"The workflow_validator.sh takes 5 seconds. Want me to optimize it?"
```

✅ Correct:
```
"Optimized workflow_validator.sh performance

Before: 5.2s (failed <2s requirement)
After: 1.8s (meets requirement ✓)

Changes:
- Replaced 15 find commands with 2 glob patterns
- Cached git branch lookup (was called 20 times)
- Parallelized independent checks

Benchmark: Ran 10 times, average 1.8s, stddev 0.1s
```

### Example 3: Library Choice

❌ Wrong:
```
"For date formatting, should I use moment.js or date-fns?"
```

✅ Correct:
```
"Implemented date formatting with date-fns

Choice: date-fns over moment.js
Reasons:
- Smaller bundle size (2kb vs 67kb)
- Better tree-shaking
- Active maintenance (updated 2 weeks ago)
- Already used in 3 existing modules

Implementation: Centralized in utils/date.js for consistency
```

## 🎓 Learning from Past Mistakes

**PR #40 Experience:**
- Issue: AI asked "继续吗？" multiple times during Phase 2-5
- Root cause: No explicit autonomous guidance
- Fix: This skill + hook combination
- Prevention: Skill activates automatically, provides decision framework

**Key Takeaway:**
```
User trust = Bypass permissions enabled
Your job = Use that trust wisely
How = Make good decisions, report clearly, deliver quality
```

## ✅ Success Metrics

**You're doing it right when:**
- Zero questions asked during Phase 2-5 ✓
- All decisions have clear rationale ✓
- Quality gates pass on first try ✓
- User says "wow, that was smooth" ✓

**You're doing it wrong when:**
- Asking "is this OK?" ✓
- Waiting for approval mid-phase ✓
- User has to "nudge" you to continue ✓
- Decisions seem arbitrary (no reasoning) ✓

---

## 🚀 Activation Confirmation

When this skill activates, you should think:

```
✅ Phase 2-5 autonomous mode activated
✅ Requirements clarified in Phase 1
✅ I have bypass permissions
✅ I have decision framework
✅ I have quality standards
✅ I have project context

→ Execute with full autonomy
→ Make professional decisions
→ Report clearly
→ Deliver quality

NO questions. Just excellence.
```
