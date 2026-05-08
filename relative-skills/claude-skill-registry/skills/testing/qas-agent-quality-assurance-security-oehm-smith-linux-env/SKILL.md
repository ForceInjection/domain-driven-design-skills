---
name: QAS Agent (Quality Assurance & Security)
description: Creates comprehensive test suites including unit, integration, E2E, and security tests
when_to_use: when implementation is complete and needs testing, or when validating acceptance criteria
version: 1.0.0
---

# QAS Agent (Quality Assurance & Security)

## Overview

The QAS Agent creates and runs comprehensive tests to validate that implementation meets all acceptance criteria. This skill ensures code works correctly under all conditions.

## When to Use This Skill

- Implementation is complete
- Acceptance criteria defined
- Security audit complete
- Before creating PR
- When test coverage needed

## Critical Rules

1. **Use TDD with Superpowers** - Integrate with existing TDD skill
2. **Test real behavior** - Never test mocks (that's testing the test)
3. **Cover edge cases** - Happy path is not enough
4. **Security tests mandatory** - Test attack scenarios
5. **E2E tests use real APIs** - No mocks in E2E tests

## Test Types

### 1. Unit Tests
Test individual functions in isolation

### 2. Integration Tests
Test component interactions

### 3. E2E (End-to-End) Tests
Test complete user workflows

### 4. Security Tests
Test authorization, authentication, attack scenarios

## Process

### Step 1: Read All Feature Documentation

**CRITICAL**: Read all feature documentation from files.

**Files to read**:
```
docs/features/[feature-slug]/01-bsa-analysis.md  (acceptance criteria)
docs/features/[feature-slug]/02-architecture-design.md  (system design)
docs/features/[feature-slug]/03-migration.sql  (database schema)
docs/features/[feature-slug]/04-security-audit.md  (security test scenarios)
docs/features/[feature-slug]/05-documentation-summary.md  (API docs)
```

**What to extract**:
- Acceptance criteria (from BSA) - each becomes a test
- Security vulnerabilities to test (from Security Audit)
- API endpoints (from Documentation)
- Edge cases (from all sources)

### Step 2: Create Test Plan

From extracted information, create comprehensive test plan.

### Step 3: Create Test Coverage Matrix

**Test Coverage Matrix**:

| Acceptance Criterion | Unit Test | Integration Test | E2E Test | Security Test |
|---------------------|-----------|------------------|----------|---------------|
| User can create export | ✅ | ✅ | ✅ | - |
| Rate limit enforced | - | ✅ | ✅ | ✅ |
| Download link expires | ✅ | ✅ | - | ✅ |
| RLS prevents cross-access | - | ✅ | - | ✅ |

### Step 4: Write Unit Tests

**Template**:

```typescript
describe('ExportService', () => {
  describe('createExport', () => {
    it('should create export with valid parameters', async () => {
      // Arrange
      const userId = 'user-123';
      const format = 'json';

      // Act
      const result = await exportService.createExport(userId, format);

      // Assert
      expect(result).toMatchObject({
        user_id: userId,
        format: format,
        status: 'pending',
      });
      expect(result.id).toBeDefined();
      expect(result.expires_at).toBeInstanceOf(Date);
    });

    it('should reject invalid format', async () => {
      await expect(
        exportService.createExport('user-123', 'xml')
      ).rejects.toThrow('Invalid format: must be json or csv');
    });

    it('should enforce rate limit', async () => {
      const userId = 'user-123';

      // Create first export
      await exportService.createExport(userId, 'json');

      // Attempt second export within 24 hours
      await expect(
        exportService.createExport(userId, 'json')
      ).rejects.toThrow('Rate limit exceeded: 1 export per 24 hours');
    });

    it('should calculate expiration date correctly', async () => {
      const result = await exportService.createExport('user-123', 'json');

      const expectedExpiration = new Date();
      expectedExpiration.setDate(expectedExpiration.getDate() + 7);

      expect(result.expires_at.getTime()).toBeCloseTo(
        expectedExpiration.getTime(),
        -4 // Within 10 seconds
      );
    });
  });
});
```

### Step 5: Write Integration Tests

```typescript
describe('Export API Integration', () => {
  let testUser: User;
  let authToken: string;

  beforeEach(async () => {
    testUser = await createTestUser();
    authToken = await generateAuthToken(testUser.id);
  });

  afterEach(async () => {
    await cleanupTestUser(testUser.id);
  });

  it('should create export and send email notification', async () => {
    // Create export
    const response = await request(app)
      .post(`/api/users/${testUser.id}/exports`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({ format: 'json' })
      .expect(202);

    expect(response.body).toMatchObject({
      id: expect.any(String),
      status: 'pending',
      format: 'json',
    });

    // Wait for background job to process
    const exportId = response.body.id;
    await waitForExportCompletion(exportId, { timeout: 30000 });

    // Verify export completed
    const exportRecord = await db.query(
      'SELECT * FROM user_exports WHERE id = $1',
      [exportId]
    );
    expect(exportRecord.rows[0].status).toBe('completed');
    expect(exportRecord.rows[0].file_url).toBeDefined();

    // Verify email sent
    const emails = await getTestEmails(testUser.email);
    expect(emails).toHaveLength(1);
    expect(emails[0].subject).toContain('Your data export is ready');
    expect(emails[0].body).toContain(exportRecord.rows[0].file_url);
  });

  it('should enforce rate limiting', async () => {
    // First export succeeds
    await request(app)
      .post(`/api/users/${testUser.id}/exports`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({ format: 'json' })
      .expect(202);

    // Second export within 24 hours fails
    await request(app)
      .post(`/api/users/${testUser.id}/exports`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({ format: 'json' })
      .expect(429);
  });
});
```

### Step 6: Write E2E Tests

```typescript
describe('User Export E2E Flow', () => {
  let page: Page;
  let testUser: User;

  beforeAll(async () => {
    page = await browser.newPage();
    testUser = await createTestUser();
  });

  afterAll(async () => {
    await cleanupTestUser(testUser.id);
    await page.close();
  });

  it('should complete full export workflow', async () => {
    // Login
    await page.goto('/login');
    await page.fill('#email', testUser.email);
    await page.fill('#password', testUser.password);
    await page.click('button[type=submit]');
    await page.waitForSelector('.dashboard');

    // Navigate to privacy settings
    await page.goto('/settings/privacy');
    await expect(page.locator('h1')).toContainText('Privacy Settings');

    // Request export
    await page.click('button:has-text("Export My Data")');
    await page.selectOption('#format', 'json');
    await page.click('button:has-text("Create Export")');

    // Verify confirmation
    await expect(page.locator('.toast-success')).toContainText(
      'Export requested. You will receive an email when ready.'
    );

    // Wait for email (in test environment)
    const email = await waitForEmail(testUser.email, {
      subject: 'Your data export is ready',
      timeout: 60000,
    });
    expect(email).toBeDefined();

    // Extract download link from email
    const downloadLink = extractLinkFromEmail(email);
    expect(downloadLink).toMatch(/^https:\/\/.*\/exports\/.*\/download/);

    // Download export
    const exportData = await downloadFile(downloadLink);
    expect(exportData).toBeDefined();

    // Verify export contents
    const parsed = JSON.parse(exportData);
    expect(parsed).toHaveProperty('user');
    expect(parsed.user.email).toBe(testUser.email);
    expect(parsed).toHaveProperty('content');
    expect(parsed).toHaveProperty('activity');
  });
});
```

### Step 7: Write Security Tests

```typescript
describe('Export Security Tests', () => {
  let userA: User;
  let userB: User;
  let tokenA: string;
  let tokenB: string;

  beforeEach(async () => {
    userA = await createTestUser();
    userB = await createTestUser();
    tokenA = await generateAuthToken(userA.id);
    tokenB = await generateAuthToken(userB.id);
  });

  it('should prevent user from accessing another users export', async () => {
    // User A creates export
    const responseA = await request(app)
      .post(`/api/users/${userA.id}/exports`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ format: 'json' })
      .expect(202);

    const exportId = responseA.body.id;

    // User B tries to access User A's export
    await request(app)
      .get(`/api/exports/${exportId}`)
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(403); // or 404 (don't reveal existence)
  });

  it('should reject unauthenticated requests', async () => {
    await request(app)
      .post(`/api/users/${userA.id}/exports`)
      .send({ format: 'json' })
      .expect(401);
  });

  it('should validate JWT token signature', async () => {
    const invalidToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid.signature';

    await request(app)
      .post(`/api/users/${userA.id}/exports`)
      .set('Authorization', `Bearer ${invalidToken}`)
      .send({ format: 'json' })
      .expect(401);
  });

  it('should prevent SQL injection', async () => {
    await request(app)
      .get(`/api/users/${userA.id}/exports?format=json'--`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(400);
  });
});
```

## Output Format

```markdown
# QAS Test Report: [Feature Name]

## Test Coverage

### Unit Tests
- **Files**: 3
- **Tests**: 24
- **Coverage**: 95%
- **Status**: ✅ All passing

### Integration Tests
- **Files**: 2
- **Tests**: 12
- **Coverage**: 85%
- **Status**: ✅ All passing

### E2E Tests
- **Files**: 1
- **Tests**: 3
- **Coverage**: 100% of user flows
- **Status**: ✅ All passing

### Security Tests
- **Files**: 1
- **Tests**: 8
- **Status**: ✅ All passing

## Acceptance Criteria Validation

| Criterion | Test | Status |
|-----------|------|--------|
| User can create export | `integration/exports.test.ts:12` | ✅ PASS |
| Rate limit enforced | `integration/exports.test.ts:45` | ✅ PASS |
| Email notification sent | `integration/exports.test.ts:23` | ✅ PASS |
| Export expires after 7 days | `unit/export-service.test.ts:67` | ✅ PASS |
| Download link expires 1 hour | `integration/download.test.ts:34` | ✅ PASS |
| RLS prevents cross-access | `security/exports.test.ts:15` | ✅ PASS |

**All acceptance criteria validated**: ✅

## Edge Cases Tested

1. ✅ Concurrent export requests (race condition)
2. ✅ Export while user is deleted (graceful failure)
3. ✅ Export of empty dataset (valid export)
4. ✅ Export exceeding size limit (handled)
5. ✅ Background job failure (retry logic)
6. ✅ Email service down (queued for retry)
7. ✅ Storage full (error reported)

## Performance Tests

- Export generation: 2.3s avg (< 5s requirement ✅)
- API response time: 45ms avg
- Database queries: All < 100ms

## Test Execution

```bash
# Run all tests
npm test

# Results
Test Suites: 7 passed, 7 total
Tests:       47 passed, 47 total
Snapshots:   0 total
Time:        42.156 s
Coverage:    91.2%
```

## Next Steps
- **File saved**: `docs/features/[feature-slug]/06-test-report.md`
- **Handoff to**: RTE Agent (reads test report for PR creation)
```

## Boundaries

**This skill does NOT**:
- Skip TDD process (use Superpowers TDD skill)
- Test mocked behavior
- Deploy code (that's RTE)

**This skill DOES**:
- **Read all feature documentation from files**
- Create comprehensive tests
- Validate acceptance criteria
- Test security scenarios
- Report test coverage
- Test edge cases
- **Save test report to file** for next agent

## Related Skills

- TDD (`/Users/brooke/.config/superpowers/skills/skills/testing/test-driven-development/SKILL.md`) - Use for TDD process
- Security Engineer (`~/.claude/skills/crosscutting/security/policy_auditing/SKILL.md`) - Provides security test scenarios
- RTE Agent (`~/.claude/skills/crosscutting/configuration/release_management/SKILL.md`) - Next step after testing

## Version History
- 1.0.0 (2025-10-14): Initial skill creation
