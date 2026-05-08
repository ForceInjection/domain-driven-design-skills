---
name: test-e2e-account
description: Execute E2E tests for the account service with proper server setup, test execution, and cleanup. Use when user requests account E2E testing, test execution, or running Playwright tests for account features.
allowed-tools: Bash, Read, KillShell, TaskOutput
---

# Account Service E2E Test Executor

Execute E2E tests for the ClaudeMix account service with complete workflow management.

## When to Use

- User asks to "run E2E tests for account"
- User requests "test account service"
- User wants to verify account functionality
- After implementing account-related features
- Before committing account service changes

## Execution Workflow

### 1. Pre-flight Check

Verify environment readiness:

- Confirm project directory
- Check if dev server is running on port 8788
- Kill existing server if necessary for clean state

**Optional: Clean Wrangler cache** (if previous tests had issues):

```bash
npm run clean:wrangler
```

This clears `.wrangler/state/v3` and reapplies D1 migrations, resolving cache-related issues.

### 2. Start Development Server

```bash
npm run dev:wrangler
```

**Wait criteria**:

- Build completion message appears
- "Ready on <http://127.0.0.1:8788>" confirmation
- Minimum 10 seconds after ready message

**Why**: Server needs time to initialize Wrangler runtime and D1 database.

### 3. Execute Tests

```bash
npx playwright test tests/e2e/account \
  --config=tests/e2e/playwright.config.ts \
  --reporter=list
```

**Critical flags**:

- `--config=tests/e2e/playwright.config.ts` - MANDATORY (project-specific config)
- `--reporter=list` - Recommended (suppresses HTML report generation)

### 4. Report Results

Provide clear summary:

**Per-test status**:

- ✅ Passed: Test name
- ❌ Failed: Test name + concise error

**Overall summary**:

- Total tests: X
- Passed: X
- Failed: X
- Duration: X seconds

### 5. Cleanup (CRITICAL)

**Always stop dev server**:

1. Locate background task ID
2. Execute kill command
3. Verify server stopped

**Why critical**: Leaving server running causes port conflicts in next execution.

## Troubleshooting Guidance

### If Connection Errors Occur

**Symptoms**:

- `ERR_CONNECTION_REFUSED`
- All tests fail immediately
- "Cannot navigate to invalid URL"
- Server shows "Ready" but connections timeout

**Diagnosis**: Windows/Wrangler cache issue

**Solution (try in order)**:

1. **First attempt**: Clean Wrangler cache

   ```bash
   npm run clean:wrangler
   ```

   Then retry the test execution.

2. **If issue persists**: Recommend PC restart to user

**Why this order**: Cache cleanup resolves most issues quickly. PC restart is needed only for deeper Windows/Wrangler process problems.

**Evidence**: Historical cases (2025-12-26, 2025-12-28):

- Navigation test failures → Cache clean → Resolved
- Modal rendering issues → PC restart → Resolved
- FlashMessage problems → PC restart → Resolved
- Login SESSION_KV errors → Cache clean → Resolved

### If Specific Tests Fail

**Provide**:

- Error context analysis
- Specific failure reason
- Suggested fix (if code issue)
- PC restart recommendation (if Windows/Wrangler issue)

## Success Criteria

- [ ] Server started successfully
- [ ] Tests executed with correct configuration
- [ ] Results clearly reported to user
- [ ] Server cleanly stopped
- [ ] Any failures diagnosed with actionable guidance

## Related Resources

- E2E test guidelines: `CLAUDE.md` lines 142-208
- Playwright config: `tests/e2e/playwright.config.ts`
- Test files: `tests/e2e/account/*.spec.ts`

## Common Pitfalls to Avoid

1. **Server not stopped**: Port 8788 remains occupied
2. **Insufficient wait time**: Tests start before server ready
3. **Missing config flag**: Wrong configuration used
4. **Ignoring Windows cache**: Repeated failures without PC restart
