---
name: scraper-qa
description: Use this skill when implementing, modifying, or fixing ANY scraper, discovery, or extraction code in the packages/scrapers directory. Triggers for tasks involving SmartDiscoveryAgent, SmartDishFinderAgent, PuppeteerFetcher, search engines, platform adapters, or related components. Orchestrates a rigorous test-driven workflow with use case definition BEFORE coding, followed by verification.
---

# Scraper QA Workflow

This skill implements a rigorous test-driven workflow for backend scraper/discovery/extraction systems. It ensures changes are verified against defined use cases before being marked complete.

## When This Skill Activates

**Triggers on work involving:**
- `packages/scrapers/src/agents/smart-discovery/` - Discovery agent
- `packages/scrapers/src/agents/smart-dish-finder/` - Dish extraction agent
- `packages/scrapers/src/platforms/` - Platform adapters (Lieferando, UberEats, etc.)
- `packages/scrapers/src/cli/` - CLI tools
- Search engine integration (Google, Bing, etc.)
- Query caching, rate limiting, country detection
- Puppeteer/browser automation

## Workflow Overview

```
┌─────────────────────┐     ┌──────────────────────┐     ┌─────────────────────┐
│  1. SCOPE ANALYSIS  │────▶│  2. USE CASE SETUP   │────▶│  3. IMPLEMENTATION  │
│  (What's changing?) │     │ (Define test cases)  │     │   (Code changes)    │
└─────────────────────┘     └──────────────────────┘     └─────────────────────┘
                                                                   │
┌─────────────────────┐     ┌──────────────────────┐              │
│  5. FINAL REPORT    │◀────│  4. VERIFICATION     │◀─────────────┘
│  (All tests pass)   │     │ (Run all use cases)  │
└─────────────────────┘     └──────────────────────┘
```

## CRITICAL: Test-First Approach

**BEFORE writing any code:**
1. Analyze what's being changed
2. Define specific, executable use cases
3. Document expected outcomes
4. Get user acknowledgment of test plan

**AFTER code changes:**
1. Execute ALL defined use cases
2. Fix any failures
3. Re-run until 100% pass
4. Only then report success to user

---

## Phase 1: Scope Analysis

Identify what's being changed:

```markdown
## Scope Analysis: [Task Description]

**Components Affected:**
- [ ] SmartDiscoveryAgent
- [ ] SmartDishFinderAgent
- [ ] PuppeteerFetcher
- [ ] Platform adapters (specify which)
- [ ] Search engine pool
- [ ] Query cache
- [ ] Country detection
- [ ] CLI tools
- [ ] Config/types

**Risk Level:** low / medium / high

**Potential Impact:**
- Discovery accuracy
- Extraction quality
- Performance/rate limits
- Data integrity
- Cross-country handling
```

---

## Phase 2: Use Case Setup

**MANDATORY:** Define executable use cases BEFORE implementing.

Consult `TESTING-MANUAL.md` for existing use cases, then add task-specific ones.

### Use Case Format

```markdown
### TC-[MODULE]-[NUMBER]: [Test Case Name]
**Component:** [Which agent/file]
**Type:** unit / integration / dry-run / live
**Preconditions:** [Setup required]
**Test Command:** [Exact command to run]
**Verification Steps:**
1. Step 1
2. Step 2
**Expected Result:** [Specific, measurable outcome]
**Pass Criteria:** [How to determine pass/fail]
```

### Required Test Categories

For any change, define tests in these categories:

1. **Build Verification** (always required)
   - TypeScript compiles without errors
   - No import/type errors

2. **Unit Tests** (for logic changes)
   - Function returns expected output
   - Edge cases handled

3. **Dry Run Tests** (for scraper changes)
   - Run with `--dry-run` flag
   - Verify no database writes
   - Check log output for expected behavior

4. **Integration Tests** (for multi-component changes)
   - Components interact correctly
   - Data flows through pipeline

5. **Live Tests** (for critical paths, with care)
   - Small-scale real execution
   - Verify actual results in Firestore

---

## Phase 3: Implementation

Now implement the changes, keeping use cases in mind.

**During implementation:**
- Write code that can be tested
- Add logging for verification
- Handle error cases explicitly

---

## Phase 4: Verification

Execute ALL defined use cases. **Do NOT report to user until all pass.**

### Verification Workflow

```bash
# 1. Build verification (ALWAYS FIRST)
cd planted-availability-db && pnpm build

# 2. Dry run tests
cd packages/scrapers && pnpm run local --dry-run -c ../../scraper-config-test.json

# 3. Specific test scenarios (from use cases)
# ... run each defined test case
```

### Recording Results

For each use case:
```markdown
| TC ID | Description | Status | Output/Evidence |
|-------|-------------|--------|-----------------|
| TC-DISC-001 | Country detection | PASS | Logs show "Using detected country (DE)" |
| TC-DISC-002 | URL validation | PASS | Build succeeded, no type errors |
```

### Failure Handling

If ANY test fails:
1. Analyze failure
2. Fix the issue
3. Re-run ALL tests (not just failed one)
4. Repeat until 100% pass

---

## Phase 5: Final Report

Only after ALL use cases pass, generate final report:

```markdown
## Test Report: [Task Name]
**Date:** YYYY-MM-DD
**Status:** ALL TESTS PASSED

### Use Cases Executed
| TC ID | Description | Status |
|-------|-------------|--------|
| TC-XXX-001 | ... | PASS |
| TC-XXX-002 | ... | PASS |

### Build Status
- `pnpm build`: PASS
- TypeScript errors: 0

### Evidence
[Key log outputs, screenshots, or data samples proving success]

### Changes Made
- `file1.ts`: Description
- `file2.ts`: Description
```

---

## Test Commands Reference

```bash
# Build all packages
cd planted-availability-db && pnpm build

# Build scrapers only
cd planted-availability-db/packages/scrapers && pnpm build

# Dry run discovery (no DB writes)
cd packages/scrapers && pnpm run local --dry-run -c ../../scraper-config.json

# Run with specific config
cd packages/scrapers && pnpm run local -c ../../scraper-config-test.json

# Discovery only
cd packages/scrapers && pnpm run discovery -c ../../scraper-config.json

# Dish extraction only
cd packages/scrapers && pnpm run extraction -c ../../scraper-config.json

# Test search pool
cd packages/scrapers && pnpm run search-pool

# Interactive review
cd packages/scrapers && pnpm run review
```

---

## Test Config Files

Create minimal test configs for verification:

**scraper-config-test.json** (for quick tests):
```json
{
  "mode": "discovery",
  "countries": ["DE"],
  "platforms": ["lieferando"],
  "maxQueries": 5,
  "maxVenues": 3,
  "batchCitySize": 1,
  "extractDishesInline": false
}
```

---

## Reference Documents

- `TESTING-MANUAL.md` - Full use case library
- `TEST-REPORT-TEMPLATE.md` - Report template
- `planted-availability-db/.claude/skills/fixes-done.md` - Previous bugs and fixes

---

## Key Principle

**User sees ONLY the final result:**
- If all tests pass: Report success with evidence
- If tests fail: Fix issues, re-test, then report
- Never report partial results or "try running this"
