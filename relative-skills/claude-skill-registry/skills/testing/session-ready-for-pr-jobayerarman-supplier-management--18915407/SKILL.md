---
name: session-ready-for-pr
description: Prepares branch for PR and merge. Cleans up, tests, validates commits, and generates PR/merge titles and descriptions.
---

# Session Ready for PR & Merge Skill

Comprehensive workflow for preparing a development branch for pull request submission and eventual merge into main. Ensures quality gates, proper documentation, and smooth integration.

## Auto-Trigger Keywords

The skill activates when messages contain PR/merge readiness keywords:
- **PR Readiness**: "ready for PR", "create PR", "submit PR", "open PR"
- **Merge Readiness**: "ready to merge", "ready for merge", "prepare for merge"
- **Completion**: "finished feature", "work complete", "done with changes"
- **Final Check**: "final check", "before submitting", "before merge"

---

## PR Preparation Workflow (7 Phases)

### Phase 1: Pre-PR Validation Checklist ✓

**Objective**: Verify all prerequisites met before starting PR process

1. **Code Hygiene Check**
   ```bash
   # Look for debug code, console logs, temporary files
   grep -r "Logger.log" *.gs | grep -v "test\|Test\|AuditLogger"
   grep -r "TODO\|FIXME\|HACK\|XXX" *.gs
   grep -r "debugger\|console.log" *.gs
   ls -la *.backup *.tmp 2>/dev/null
   ```
   - Remove debug logs (unless intentional error tracking)
   - Address TODOs or document as future work
   - Remove temporary files and backups
   - Clean up commented-out code (unless historically useful)

2. **Git State Verification**
   ```bash
   git status
   git log --oneline origin/main..HEAD  # Shows commits ahead
   ```
   - No uncommitted changes (all work staged and committed)
   - Branch ahead of main (has commits to merge)
   - No merge conflicts
   - Working directory clean

3. **Commit Structure Review**
   - Each commit is logical and self-contained?
   - No WIP (Work In Progress) commits?
   - No duplicate fixes or reversions?
   - Commit messages follow Angular style?

4. **Test Status**
   - All unit tests pass?
   - All integration tests pass?
   - No failing test cases?
   - Test coverage adequate for changes?

5. **Documentation**
   - CLAUDE.md updated if architecture changed?
   - README.md updated if features added?
   - Code comments added for complex logic?
   - Module responsibilities clear?

**Checklist**:
- [ ] No debug logs or temporary code
- [ ] No uncommitted changes
- [ ] Branch has commits ahead of main
- [ ] All tests passing
- [ ] Commit messages follow conventions
- [ ] Documentation updated
- [ ] No merge conflicts

---

### Phase 2: Branch Cleanup & Optimization ✓

**Objective**: Ensure clean, properly structured commit history

1. **Identify Issues**
   - Any WIP commits? (work in progress)
   - Any revert commits? (indicate rework)
   - Any empty commits?
   - Any commits with duplicate changes?

2. **Rebase/Squash Recommendations**
   - Multiple commits fixing same issue? → Consider squashing
   - Small cleanup after main commit? → Squash into original
   - Multiple phases of same feature? → Keep separate with clear messages
   - Bug fix after commit? → Squash into original fix

3. **Interactive Rebase (If Needed)**
   ```bash
   # Only if commits need consolidation
   git rebase -i origin/main
   # Then: squash, reorder, edit as needed
   ```

4. **Verify Final Commit List**
   ```bash
   git log --oneline origin/main..HEAD
   ```
   - Each commit is meaningful
   - Commits are in logical order
   - No WIP or temporary commits
   - Messages are clear and descriptive

**Decision Tree**:
- Do you have 1-2 commits? → Keep as is, good for PR
- Do you have 3-5 focused commits? → Keep separate, each tells story
- Do you have 10+ commits with fixes? → Consider squashing related ones
- Do you have WIP or revert commits? → These must be cleaned up

---

### Phase 3: Full Test Suite Execution ✓

**Objective**: Verify all code changes work correctly

1. **Run Comprehensive Tests**
   ```bash
   # From Script Editor, run all test suites
   runAllPaymentManagerTests()
   runAllCacheManagerTests()
   runAllInvoiceManagerTests()
   testInvoiceManager()
   runIntegrationTests()
   testMasterDatabaseConnection()  # If Master DB involved
   ```

2. **Test Results Analysis**
   - All tests passing? (0 failures)
   - No performance regressions? (compare with baseline)
   - Test coverage adequate for new code?
   - Edge cases tested?

3. **Document Test Results**
   ```
   TEST RESULTS SUMMARY
   ════════════════════════════════════════
   ✅ PaymentManager Tests: 45 passed, 0 failed
   ✅ CacheManager Tests: 38 passed, 0 failed
   ✅ InvoiceManager Tests: 52 passed, 0 failed
   ✅ Integration Tests: 28 passed, 0 failed
   ✅ Master Database Tests: 12 passed, 0 failed

   Total: 175 passed, 0 failed (100% pass rate)
   ```

4. **Performance Validation** (If performance changes)
   - Run benchmark suite
   - Compare metrics with baseline
   - Document improvement (if any)
   - Check for regressions

---

### Phase 4: Commit Message Validation ✓

**Objective**: Ensure all commits follow Angular conventions

1. **Review Each Commit**
   ```bash
   git log --oneline origin/main..HEAD
   # For each commit, verify:
   # - Type: feat, fix, refactor, perf, docs, test, chore
   # - Scope: (optional but recommended)
   # - Subject: max 50 chars, imperative mood, clear
   ```

2. **Use Commit Helper Skill**
   - Review each commit message
   - Ensure format consistency
   - Verify type/scope match actual changes
   - Check subject clarity

3. **Common Commit Issues**
   - ❌ "Updated some stuff" → ✅ "refactor(cache-manager): improve clarity"
   - ❌ "Fixed bug" → ✅ "fix(payment-manager): correct cache invalidation timing"
   - ❌ "stuff" → ✅ "feat(api): add invoice lookup endpoint"

4. **Validation Checklist**
   - [ ] All commits follow Angular style
   - [ ] Types are correct (feat, fix, refactor, etc.)
   - [ ] Scopes are consistent
   - [ ] Subjects are under 50 characters
   - [ ] Subjects use imperative mood
   - [ ] No vague commit messages

---

### Phase 5: Code Quality & Risk Assessment ✓

**Objective**: Identify code quality issues and potential risks

1. **Use Code-Reviewer Agent**
   - Run code review on changed files
   - Check for security vulnerabilities
   - Identify code duplication
   - Verify error handling
   - Check test coverage

2. **Identify Affected Modules**
   ```bash
   git diff --name-only origin/main..HEAD
   # Maps files to modules:
   # PaymentManager.gs → Payment processing
   # CacheManager.gs → Caching system
   # Code.gs → Event handlers
   # etc.
   ```

3. **Risk Assessment**
   - Critical modules changed? (Cache, Payment, Lock)
   - Breaking changes introduced?
   - Data migration needed?
   - Backwards compatibility maintained?
   - Master Database mode affected?

4. **Review Focus Areas**
   - What areas need careful review?
   - What could break with this change?
   - What edge cases might exist?
   - What's the rollback plan if issues?

---

### Phase 6: PR Title & Description Generation ✓

**Objective**: Auto-generate comprehensive PR documentation

1. **Extract PR Information**
   ```bash
   # Analyze commits to determine PR purpose
   git log --oneline origin/main..HEAD
   git diff --stat origin/main..HEAD
   ```

2. **Determine PR Type**
   - **Feature**: New functionality added
   - **Bugfix**: Defects corrected
   - **Performance**: Speed/efficiency improvements
   - **Refactoring**: Code improvement without behavior change
   - **Mixed**: Multiple types of changes

3. **Draft PR Title** (Examples)
   ```
   ✅ GOOD:
   - feat: add performance profiling & optimization skill
   - fix: correct cache invalidation timing in payment processing
   - perf: implement 75% lock scope reduction in PaymentManager
   - refactor: consolidate duplicate constants to CONFIG

   ❌ BAD:
   - Updates
   - Stuff
   - Multiple changes
   - Random fixes
   ```

4. **Draft PR Description Template**
   ```markdown
   ## Summary
   [2-3 sentence summary of what this PR accomplishes]

   ## Changes Made
   - [Feature/change 1]: what it does
   - [Feature/change 2]: what it does
   - [Feature/change 3]: what it does

   ## Type of Change
   - [ ] ✨ Feature (new functionality)
   - [ ] 🐛 Bugfix (fixes defect)
   - [ ] ⚡ Performance (improvement)
   - [ ] 🔄 Refactor (code improvement)
   - [ ] 📚 Docs (documentation)
   - [ ] 🧪 Tests (test coverage)

   ## Test Plan
   - [ ] All unit tests passing (175/175)
   - [ ] All integration tests passing (28/28)
   - [ ] Manual testing: [describe steps]
   - [ ] Edge cases tested: [list cases]

   ## Breaking Changes?
   - [ ] No breaking changes
   - [ ] Yes (describe migration path)

   ## Checklist
   - [x] Tests added/updated
   - [x] Documentation updated
   - [x] Commits follow Angular convention
   - [x] No debug code left
   - [x] Code reviewed for quality

   ## Affected Areas
   - Module 1 (Cache system)
   - Module 2 (Performance)

   ## Performance Impact
   [If performance related]
   - Improvement: 75% reduction in lock duration
   - Baseline: 100-200ms
   - Optimized: 20-50ms
   - Scales to: 10,000+ records

   ## Related Issues
   Closes #123, Relates to #456
   ```

5. **Customize Description**
   - Summarize what changed and why
   - List specific improvements
   - Document test coverage
   - Highlight breaking changes (if any)
   - Identify risky areas needing review
   - Add performance metrics (if applicable)

---

### Phase 7: Merge Commit Generation & Final Checks ✓

**Objective**: Prepare merge commit message and final verification

1. **Analyze PR for Merge Commit**
   - Determine main achievement of PR
   - Check if consolidation needed
   - Identify if history should be preserved

2. **Use Commit Helper for Merge Message**
   - Create comprehensive merge message
   - Document what PR accomplished
   - Include scope and impact
   - Add breaking changes section (if any)

3. **Merge Commit Message Format**
   ```
   Merge branch 'feature-name' into main

   [Summary of what this PR accomplished]

   Key changes:
   - [Change 1 with impact]
   - [Change 2 with impact]

   Performance impact: [if applicable]
   - [Metric before] → [Metric after]

   Breaking changes: [if any, list them]

   Reviewed by: [list reviewers when merged]
   Closes #123, #456
   ```

4. **Final Pre-Merge Checklist**
   - [ ] PR description complete and clear
   - [ ] All tests passing
   - [ ] Code review approved
   - [ ] No merge conflicts
   - [ ] Branch up to date with main
   - [ ] Commits properly organized
   - [ ] Performance impact documented (if applicable)
   - [ ] Breaking changes documented (if any)
   - [ ] Related issues linked
   - [ ] Merge commit message ready

5. **Ready for Merge**
   - When all items checked, branch is ready
   - PR can be submitted for review
   - Merge can proceed when approved
   - Merge commit message saved for later

---

## Pre-Merge Quality Gates

Must pass before merging to main:

### Automated Checks
- [ ] All tests pass (100% pass rate)
- [ ] No merge conflicts
- [ ] No debug code/logs
- [ ] Commits follow conventions
- [ ] Code review approved

### Manual Verification
- [ ] Changes match PR description
- [ ] No unexpected files modified
- [ ] Documentation updated appropriately
- [ ] Breaking changes clearly documented
- [ ] Performance impact assessed

### Risk Verification
- [ ] Critical modules reviewed (Cache, Payment, Lock)
- [ ] Edge cases tested
- [ ] Master Database compatibility checked (if applicable)
- [ ] Backwards compatibility maintained
- [ ] Rollback strategy understood

---

## PR Description Template Details

### Summary Section
- What problem does this solve?
- What feature does it add?
- Why was this change needed?
- Keep to 2-3 sentences

### Changes Made Section
- Specific, concrete changes
- One bullet per significant change
- Include impact or benefit
- Clear and concise language

### Type of Change Section
- Select appropriate type(s)
- Guides reviewers on focus areas
- Helps with change categorization
- Multiple types possible for mixed PRs

### Test Plan Section
- How was this tested?
- Which tests were run?
- What manual testing was done?
- Edge cases covered?
- Performance tested (if applicable)?

### Breaking Changes Section
- Any breaking changes introduced?
- If yes, what's the migration path?
- How should users update?
- Any deprecation notices?

### Affected Areas Section
- Which modules modified? (CacheManager, PaymentManager, etc.)
- Which features could be impacted?
- Which user workflows affected?

### Performance Impact Section
- Only if performance changes made
- Document before/after metrics
- Explain optimization technique
- Include scalability verification

---

## Commit Review Guidelines

When validating commit messages:

✅ **GOOD Examples**
```
feat(agents): add code-reviewer agent for quality assurance

perf(payment-manager): implement 75% lock scope reduction

fix(cache-manager): correct timing in incremental updates

docs: add Master Database setup instructions

refactor(test-suite): standardize naming and add coverage
```

❌ **NEEDS IMPROVEMENT Examples**
```
Update stuff              → Be specific about what changed
Fixed bugs                → Which bugs? What was broken?
Changes to multiple files → Too vague, break into logical commits
WIP                       → Incomplete work shouldn't be committed
Merge main               → Document what merge accomplished
```

---

## Risk Assessment Framework

### High Risk Changes
- Modifications to cache invalidation logic
- Changes to lock scope or timing
- Payment calculation modifications
- User resolution logic changes
- Changes affecting data integrity

### Medium Risk Changes
- New features in established modules
- UI/UX modifications
- Performance optimizations (if extensive)
- Refactoring in critical areas

### Low Risk Changes
- Documentation updates
- Test additions
- Code formatting/organization
- Non-critical module changes

---

## Approval Checklist Before Merge

- [ ] PR title clearly describes changes
- [ ] PR description complete and thorough
- [ ] All test suites passing (100%)
- [ ] Code review approved
- [ ] Commits follow Angular convention
- [ ] No debug code or temporary files
- [ ] Documentation updated appropriately
- [ ] Breaking changes documented (if any)
- [ ] Performance impact noted (if applicable)
- [ ] Related issues linked
- [ ] Merge strategy clear (merge or rebase)
- [ ] Rollback plan understood
- [ ] No merge conflicts remaining

---

## Integration with Other Skills

This skill works with:

- **Commit Helper** - Validate and generate commit messages
- **Code Reviewer** - Quality assurance on changes
- **Performance Profiling** - Document performance improvements
- **Debugging** - Verify fixes work correctly
- **All Other Skills** - Clean up any temporary work

---

## Examples of PR Workflow

### Example 1: Feature Implementation
```
Branch: feature/add-invoice-search
Commits:
  - feat(invoice-manager): add search capability
  - test(invoice-manager): add search tests
  - docs: update invoice search documentation

PR Title: "feat(invoice-manager): add invoice search by date range"

PR Description:
  - Allows users to search invoices by date range
  - Improves discoverability of old invoices
  - Test coverage: 95%
  - Breaking changes: None
```

### Example 2: Performance Optimization
```
Branch: perf/optimize-cache
Commits:
  - perf(cache-manager): implement incremental updates
  - test(cache-manager): add performance benchmarks

PR Title: "perf(cache-manager): implement incremental updates (250x faster)"

PR Description:
  - Reduces cache update time from 500ms to 1ms
  - Improves user experience on large datasets
  - Maintains data integrity
  - Performance: 250x faster, O(1) complexity
  - Tested at 10,000 records
```

### Example 3: Bug Fix
```
Branch: fix/balance-calculation
Commits:
  - fix(balance-calculator): correct Due payment calculation
  - test(balance-calculator): add test for Due payments
  - docs: update CLAUDE.md with fix details

PR Title: "fix(balance-calculator): correct negative balance for Due payments"

PR Description:
  - Fixes incorrect balance calculation for Due payments
  - Balance now matches expected values
  - Root cause: missing payment type check
  - Tested with: 100 invoice scenarios
  - Breaking changes: None (bug fix only)
```

---

## Tools & Commands Available

### Git Commands
```bash
git status                          # Check working state
git log --oneline origin/main..HEAD # Show commits ahead
git diff --stat origin/main..HEAD   # Show file changes
git diff origin/main..HEAD          # Show full diff
git rebase -i origin/main          # Interactive rebase
git push origin branch-name        # Push to remote
```

### Test Commands
```bash
runAllPaymentManagerTests()     # All payment tests
runAllCacheManagerTests()       # All cache tests
runAllInvoiceManagerTests()     # All invoice tests
runIntegrationTests()           # Integration tests
testMasterDatabaseConnection()  # Master DB tests
```

### Code Review
```bash
git log --oneline origin/main..HEAD  # Review commits
grep -r "Logger.log" *.gs            # Check for debug logs
grep -r "TODO\|FIXME" *.gs           # Find incomplete work
```

---

## Key Principles

- **Quality First** - All tests must pass before PR
- **Clear Communication** - PR description tells complete story
- **Clean History** - Commits are logical and organized
- **Risk Assessment** - Know what could break
- **Proper Conventions** - Follow project patterns
- **Documentation** - Keep CLAUDE.md and README current
- **Test Coverage** - New code has tests
- **Performance Awareness** - Document improvements
- **Breaking Changes** - Clear migration path if needed
- **Merge Ready** - Everything verified before merge

---

## Output Format

At end of PR preparation, provide:

1. **PR Summary** - What changed and why
2. **Changes List** - Specific modifications
3. **Test Results** - Pass/fail status with counts
4. **Commits List** - All commits in PR with messages
5. **Risk Assessment** - What could break, focus areas
6. **PR Title & Description** - Ready to copy-paste
7. **Merge Commit Message** - Ready for merge
8. **Final Checklist Status** - All items verified

