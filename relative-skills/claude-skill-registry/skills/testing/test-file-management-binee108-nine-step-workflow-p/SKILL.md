---
name: test-file-management
description: Permanent vs temporary test organization and immutable contract philosophy. Use when creating, modifying, or reviewing tests.
---

# Test File Management

## Instructions

### Directory structure

<!-- CUSTOMIZE: Set your permanent and temporary test directory names -->

**`{{PERM_TEST_DIR}}/` - Immutable Contract**
- Core, critical functionality only
- Test failure = code is broken
- Modifications extremely rare

**`{{TEMP_TEST_DIR}}/` - Temporary Validation**
- Ad-hoc feature tests
- Reports and data
- Clean up after completion

**Common Configurations:**
- `tests/` (permanent) vs `.test/` (temporary)
- `tests/unit/` (permanent) vs `tests/temp/` (temporary)
- `__tests__/` (permanent) vs `.tmp/` (temporary)

### Core philosophy

**Test failure = Code is broken** (NOT test is wrong)

`{{PERM_TEST_DIR}}/` is the contract. Fix code, not tests.

### Approval rules

**New test in `{{PERM_TEST_DIR}}/`** - Approve if:
- Core, critical functionality
- Deployment-blocking failure
- Long-term relevant

**Modify `{{PERM_TEST_DIR}}/`** - Approve ONLY if:
- Major structural change
- API contract changed
- Multiple reviewers approved

**Always reject:**
- "Fix failing test" requests
- Convenience modifications

## Example

<!-- CUSTOMIZE: Replace with {{MAIN_TECH_STACK}} test framework -->

### Python (pytest)
```python
# ✅ Permanent ({{PERM_TEST_DIR}}/)
# tests/test_user_auth.py
def test_user_requires_password():
    '''Core rule: users must have passwords'''
    with pytest.raises(ValidationError):
        User.create({'username': 'john'})  # Missing password

# ✅ Temporary ({{TEMP_TEST_DIR}}/)
# .test/test_api_integration.py
def test_login_endpoint():
    '''Ad-hoc feature validation'''
    response = client.post('/api/login', json={'username': 'test', 'password': 'test123'})
    assert response.status_code == 200
    # Delete this file after feature complete
```

### JavaScript (Jest)
```javascript
// ✅ Permanent ({{PERM_TEST_DIR}}/)
// tests/user.test.js
test('user requires password', () => {
    expect(() => {
        User.create({username: 'john'});  // Missing password
    }).toThrow(ValidationError);
});

// ✅ Temporary ({{TEMP_TEST_DIR}}/)
// .test/api-integration.test.js
test('login endpoint works', async () => {
    const response = await request(app)
        .post('/api/login')
        .send({username: 'test', password: 'test123'});
    expect(response.status).toBe(200);
    // Delete this file after feature complete
});
```

### Go
```go
// ✅ Permanent ({{PERM_TEST_DIR}}/)
// tests/user_test.go
func TestUserRequiresPassword(t *testing.T) {
    // Core rule: users must have passwords
    _, err := CreateUser(User{Username: "john"})  // Missing Password
    if err == nil {
        t.Error("Expected validation error for missing password")
    }
}

// ✅ Temporary ({{TEMP_TEST_DIR}}/)
// .test/api_integration_test.go
func TestLoginEndpoint(t *testing.T) {
    // Ad-hoc feature validation
    payload := `{"username":"test","password":"test123"}`
    resp, _ := http.Post("http://localhost:8080/api/login", "application/json", strings.NewReader(payload))
    if resp.StatusCode != 200 {
        t.Errorf("Expected 200, got %d", resp.StatusCode)
    }
    // Delete this file after feature complete
}
```

## Workflow

```
Write test → {{PERM_TEST_DIR}}/? → Approval needed
          → {{TEMP_TEST_DIR}}/? → Proceed freely
    ↓
Test fails?
    ├─ {{PERM_TEST_DIR}}/ failing → Fix CODE
    └─ {{TEMP_TEST_DIR}}/ failing → Debug and fix CODE
    ↓
Feature complete → Clean up {{TEMP_TEST_DIR}}/
```

## Detailed Decision Tree

### Should this test be in `{{PERM_TEST_DIR}}/`?

**Ask these questions:**

1. **Is this core business logic?**
   - ✅ User authentication
   - ✅ Payment processing
   - ✅ Data validation rules
   - ❌ UI color scheme
   - ❌ Log message format

2. **Would failure block deployment?**
   - ✅ Cannot create users without email
   - ✅ Payments not processed correctly
   - ❌ Missing optional feature X
   - ❌ Performance slightly degraded

3. **Will this be relevant in 6+ months?**
   - ✅ Core API contracts
   - ✅ Database schema constraints
   - ❌ Temporary workaround
   - ❌ Experimental feature

**If 2+ YES → `{{PERM_TEST_DIR}}/`**
**If mostly NO → `{{TEMP_TEST_DIR}}/`**

---

## Test Categories by Directory

### `{{PERM_TEST_DIR}}/` - Permanent Tests

**Unit Tests:**
```{{LANG}}
# Core business logic
test_user_validation()
test_password_hashing()
test_order_calculation()

# Critical utilities
test_date_parsing()
test_encryption_decryption()
```

**Integration Tests:**
```{{LANG}}
# API contracts
test_user_registration_endpoint()
test_payment_webhook_handling()

# Database constraints
test_unique_email_constraint()
test_foreign_key_relationships()
```

**Contract Tests:**
```{{LANG}}
# External API expectations
test_payment_gateway_response_format()
test_shipping_api_contract()
```

---

### `{{TEMP_TEST_DIR}}/` - Temporary Tests

**Feature Validation:**
```{{LANG}}
# New feature smoke tests
test_new_dashboard_loads()
test_export_csv_format()

# Delete after feature ships
```

**Debugging Scripts:**
```{{LANG}}
# Reproduce bug #42
test_reproduce_null_pointer_bug()

# Delete after bug fixed
```

**Performance Benchmarks:**
```{{LANG}}
# Load testing
test_api_handles_1000_concurrent_users()

# Move results to docs, delete test
```

**Data Migration Verification:**
```{{LANG}}
# Verify migration_20231215_add_column
test_all_users_have_new_field()

# Delete after migration confirmed in production
```

---

## Review Scenarios

### Scenario 1: Adding New Test

**Request:** "Add test for new feature X"

**test-reviewer decision:**

```markdown
## Review

**Proposed location:** {{PERM_TEST_DIR}}/test_feature_x.py

**Analysis:**
- Core functionality? {{YES/NO}}
- Deployment-blocking? {{YES/NO}}
- Long-term relevant? {{YES/NO}}

**Decision:**
- If 2+ YES → APPROVED for {{PERM_TEST_DIR}}/
- If mostly NO → NEEDS_REVISION, suggest {{TEMP_TEST_DIR}}/
```

---

### Scenario 2: Modifying Existing Test

**Request:** "Update test_user_validation to allow empty email"

**test-reviewer decision:**

```markdown
## Review

**File:** {{PERM_TEST_DIR}}/test_user_validation.py

**Analysis:**
- API contract change? YES (users can now have empty email)
- Multiple reviewers approved? {{CHECK}}
- Backward compatible? {{CHECK}}

**Decision:**
- If contract change justified → APPROVED_WITH_CONDITIONS (require architecture review)
- If convenience change → REJECTED (fix code, not test)
```

---

### Scenario 3: Test Failing

**Issue:** "test_payment_processing failing on CI"

**test-reviewer guidance:**

```markdown
## Guidance

**File:** {{PERM_TEST_DIR}}/test_payment_processing.py

**Rule:** Test failure = Code is broken

**Actions:**
1. Investigate code changes (git diff)
2. Identify which code change broke the contract
3. Revert code OR update code to meet contract
4. NEVER modify test to pass

**Only modify test if:**
- API contract intentionally changed (requires multiple approvals)
- Test itself has bug (rare, needs proof)
```

---

## Cleanup Procedures

### After Feature Complete

**Manual cleanup:**
```bash
# Review temporary tests
ls {{TEMP_TEST_DIR}}/

# Remove feature-specific tests
rm {{TEMP_TEST_DIR}}/test_feature_x_*.{{ext}}

# Keep permanent tests
ls {{PERM_TEST_DIR}}/  # Should not change
```

**Automated cleanup (Step 7 completion):**
```bash
# feature-tester responsibility
cd {{WORKTREE_PATH}}
rm -rf {{TEMP_TEST_DIR}}/*
# OR keep specific files
mv {{TEMP_TEST_DIR}}/important_findings.txt docs/
rm -rf {{TEMP_TEST_DIR}}/*
```

---

### After Merge to Main

**Checklist:**
- [ ] All {{TEMP_TEST_DIR}}/ files reviewed
- [ ] Important findings moved to docs/
- [ ] {{TEMP_TEST_DIR}}/ cleaned
- [ ] {{PERM_TEST_DIR}}/ tests all passing
- [ ] No test modifications without approval

---

## Anti-Patterns

### ❌ Bad: Fixing Tests to Pass

```{{LANG}}
# {{PERM_TEST_DIR}}/test_user.py
def test_user_requires_email():
    # Changed from raise ValidationError to return False
    # WRONG! This weakens the contract!
    user = User.create({'username': 'john'})  # Missing email
    assert user.email is None  # ❌ Weakened test
```

**Correct approach:** Fix the code

```{{LANG}}
# user.py
def create(data):
    if 'email' not in data:
        raise ValidationError("Email required")  # ✅ Enforce contract
```

---

### ❌ Bad: Permanent Tests in Temp Directory

```{{LANG}}
# {{TEMP_TEST_DIR}}/test_critical_auth.py
def test_authentication_requires_password():
    # This is core functionality!
    # WRONG! Should be in {{PERM_TEST_DIR}}/
```

**Correct approach:**

```{{LANG}}
# {{PERM_TEST_DIR}}/test_authentication.py
def test_authentication_requires_password():
    # ✅ Core functionality in permanent tests
```

---

### ❌ Bad: Never Cleaning Temp Tests

```bash
# {{TEMP_TEST_DIR}}/ grows to 100+ files
ls {{TEMP_TEST_DIR}}/ | wc -l
# 127 files from last 6 months!
```

**Correct approach:**

```bash
# Regular cleanup (feature-tester)
# Keep only active feature tests
ls {{TEMP_TEST_DIR}}/
# 3-5 files for current features
```

---

**For detailed rules, see [reference.md](reference.md)**
**For more examples, see [examples.md](examples.md)**
