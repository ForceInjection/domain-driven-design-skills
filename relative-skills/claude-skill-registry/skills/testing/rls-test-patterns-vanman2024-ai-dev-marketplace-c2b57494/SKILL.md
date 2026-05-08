---
name: rls-test-patterns
description: RLS policy testing patterns for Supabase - automated test cases for Row Level Security enforcement, user isolation verification, multi-tenant security, and comprehensive security audit scripts. Use when testing RLS policies, validating user isolation, auditing Supabase security, verifying tenant isolation, testing row level security, running security tests, or when user mentions RLS testing, security validation, policy testing, or data leak prevention.
allowed-tools: Bash, Read, Write, Edit
---

# RLS Test Patterns

Comprehensive testing framework for Row Level Security (RLS) policies in Supabase. Catch security vulnerabilities before production with automated tests for user isolation, multi-tenant security, role-based access, and anonymous user restrictions.

## Instructions

### 1. Test User Isolation

**Verify users can only access their own data:**
```bash
# Test user isolation on specific tables
bash scripts/test-user-isolation.sh conversations messages profiles

# Test with specific user IDs
bash scripts/test-user-isolation.sh documents --user1 "uuid1" --user2 "uuid2"

# Generate detailed report
bash scripts/test-user-isolation.sh --all --report isolation-report.md
```

**What it tests:**
- User A cannot read User B's data
- User A cannot modify/delete User B's data
- User A can only insert data owned by themselves
- Null user_id values are properly rejected

### 2. Test Multi-Tenant Isolation

**Verify organization/team data separation:**
```bash
# Test organization isolation
bash scripts/test-multi-tenant-isolation.sh organizations projects documents

# Test with specific org IDs
bash scripts/test-multi-tenant-isolation.sh --org1 "org-uuid-1" --org2 "org-uuid-2"

# Test member access patterns
bash scripts/test-multi-tenant-isolation.sh --test-members
```

**What it tests:**
- Org A members cannot access Org B's data
- Users not in an org cannot access org data
- Removing user from org revokes access immediately
- Shared resources respect org boundaries

### 3. Test Role-Based Permissions

**Verify role-based access control:**
```bash
# Test RBAC policies
bash scripts/test-role-permissions.sh admin_panel sensitive_data

# Test specific role hierarchy
bash scripts/test-role-permissions.sh --roles "admin,editor,viewer"

# Test permission escalation prevention
bash scripts/test-role-permissions.sh --test-escalation
```

**What it tests:**
- Admin role has full access
- Editor role can read/write but not delete
- Viewer role has read-only access
- Users cannot escalate their own permissions
- Role changes take effect immediately

### 4. Test Anonymous Access Restrictions

**Verify anonymous users are properly restricted:**
```bash
# Test anonymous access on all public tables
bash scripts/test-anonymous-access.sh

# Test specific tables
bash scripts/test-anonymous-access.sh public_posts comments

# Test auth.uid() null handling
bash scripts/test-anonymous-access.sh --test-null-uid
```

**What it tests:**
- Anonymous users cannot access protected data
- Anonymous users can only access designated public data
- auth.uid() returns null correctly for anon users
- Policies handle null uid safely

### 5. Audit RLS Coverage

**Check all tables have proper RLS policies:**
```bash
# Audit entire database
bash scripts/audit-rls-coverage.sh

# Audit specific schema
bash scripts/audit-rls-coverage.sh --schema public

# Generate compliance report
bash scripts/audit-rls-coverage.sh --report compliance-report.md --format markdown
```

**What it checks:**
- All public schema tables have RLS enabled
- Each table has policies for all DML operations (SELECT, INSERT, UPDATE, DELETE)
- Policies target appropriate roles (authenticated, anon)
- No tables are accidentally exposed without policies
- Policy naming follows best practices

### 6. Run Complete Test Suite

**Execute all RLS tests:**
```bash
# Run all tests with default settings
bash scripts/run-all-rls-tests.sh

# Run with custom database URL
bash scripts/run-all-rls-tests.sh --db-url "postgresql://..."

# Run and generate comprehensive report
bash scripts/run-all-rls-tests.sh --report rls-test-results.json --verbose

# Run in CI/CD mode (exit 1 on any failure)
bash scripts/run-all-rls-tests.sh --ci --fail-fast
```

**Test sequence:**
1. Audit RLS coverage
2. Test user isolation
3. Test multi-tenant isolation
4. Test role permissions
5. Test anonymous access
6. Generate summary report

## Examples

**Example 1: Testing Chat Application Security**
```bash
# Test conversation isolation
bash scripts/test-user-isolation.sh conversations messages participants

# Output:
# ✓ User cannot read other user's conversations
# ✓ User cannot send messages to other user's conversations
# ✓ User cannot add participants to other user's conversations
# ✓ All isolation tests passed (12/12)
```

**Example 2: Multi-Tenant SaaS Security Audit**
```bash
# Full audit of multi-tenant application
bash scripts/test-multi-tenant-isolation.sh organizations projects documents embeddings

# Output:
# ✓ Org A users cannot access Org B projects
# ✓ Removed users lose access immediately
# ✓ Cross-org document access blocked
# ✓ Embeddings respect org boundaries
# ✓ All multi-tenant tests passed (24/24)
```

**Example 3: CI/CD Integration**
```bash
# In .github/workflows/security-tests.yml
- name: Run RLS Tests
  run: |
    bash scripts/run-all-rls-tests.sh \
      --ci \
      --fail-fast \
      --report rls-results.json

- name: Upload Test Report
  uses: actions/upload-artifact@v3
  with:
    name: rls-test-results
    path: rls-results.json
```

**Example 4: Pre-Production Security Check**
```bash
# Complete security validation before deploy
bash scripts/audit-rls-coverage.sh --report audit.md
bash scripts/run-all-rls-tests.sh --verbose --report tests.json

# Review both reports before deploying
cat audit.md
cat tests.json
```

## Requirements

### Prerequisites
- Supabase project with database access
- PostgreSQL client (`psql`) installed
- Node.js 18+ (for TypeScript test suite)
- Supabase CLI v1.11.4+ (for pgTAP tests)

### Environment Variables
Required in `.env` file:
```bash
# Database connection
SUPABASE_DB_URL="postgresql://postgres:[password]@[host]:5432/postgres"

# API keys for client testing
SUPABASE_URL="https://[project-ref].supabase.co"
SUPABASE_ANON_KEY="eyJ..."
SUPABASE_SERVICE_KEY="eyJ..."

# Test user credentials (optional, for client tests)
TEST_USER_1_EMAIL="test1@example.com"
TEST_USER_1_PASSWORD="testpass123"
TEST_USER_2_EMAIL="test2@example.com"
TEST_USER_2_PASSWORD="testpass456"
```

### Test Data Setup
Tests create and clean up their own data, but you can provide:
```bash
# Optional: Use existing test users
TEST_USER_1_ID="uuid-for-test-user-1"
TEST_USER_2_ID="uuid-for-test-user-2"

# Optional: Use existing test orgs
TEST_ORG_1_ID="uuid-for-test-org-1"
TEST_ORG_2_ID="uuid-for-test-org-2"
```

### Security Best Practices Tested
- ✓ RLS enabled on all public schema tables
- ✓ User isolation prevents cross-user data access
- ✓ Multi-tenant isolation prevents cross-org access
- ✓ Anonymous users properly restricted
- ✓ Role hierarchy enforced correctly
- ✓ auth.uid() null values handled safely
- ✓ Policies use indexed columns for performance
- ✓ WITH CHECK clauses prevent policy bypass
- ✓ Service key never exposed to clients

### Common Vulnerabilities Detected
- Missing RLS on public tables (data leak)
- Missing WITH CHECK clauses (INSERT/UPDATE bypass)
- Improper null handling (anonymous access leak)
- Missing role checks (privilege escalation)
- Unindexed policy columns (DoS via slow queries)
- Cross-tenant joins (org data leak)
- Missing policies for specific operations
- Overly permissive anonymous access

## Test Output Format

### Success Output
```
🔒 RLS Test Suite v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Test Summary
  Tables tested: 5
  Total tests: 48
  Passed: 48 ✓
  Failed: 0
  Duration: 12.3s

✅ All RLS policies working correctly!
```

### Failure Output
```
🔒 RLS Test Suite v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ SECURITY ISSUE DETECTED

Table: conversations
Test: User isolation - SELECT
Issue: User B could read User A's conversations
Expected: 0 rows
Actual: 5 rows

Recommendation: Add USING clause to SELECT policy:
  USING (auth.uid() = user_id)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Test Summary
  Total tests: 48
  Passed: 43 ✓
  Failed: 5 ❌

❌ Critical security issues found. Do not deploy.
```

---

**Integration Points:**
- Used by: `/supabase:test-rls` command
- Used by: `supabase-security-auditor` agent
- Complements: `rls-templates` skill (creates policies, this tests them)
- CI/CD: Run in GitHub Actions before deployment

**Best Practices:**
1. Run tests after every RLS policy change
2. Include in pre-commit hooks for critical tables
3. Run full suite weekly in CI/CD
4. Test with real user data patterns (anonymized)
5. Keep test users separate from production users
6. Document expected behavior for each policy
7. Update tests when adding new tables/policies
