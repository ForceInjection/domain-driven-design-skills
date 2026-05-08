---
name: test-plan-generator
description: Generate intelligent, non-redundant test plans based on implementation changes. This skill should be used after implementing features to create comprehensive yet efficient test plans with proper coverage across unit, integration, API, and E2E tests without duplication.
---

# Test Plan Generator Skill

## Purpose

Analyze implementation changes and generate comprehensive, non-redundant test plans that provide appropriate coverage without over-testing. Works with any language, framework, or architecture by analyzing change patterns rather than specific technologies.

## When to Use This Skill

Use this skill when:

- Feature implementation is complete
- Need to generate test plan for changes
- Want to ensure proper test coverage
- Need to avoid redundant tests
- Want to balance thoroughness with efficiency
- Creating test plan for `test-executor` to run

## Test Plan Generation Workflow

### Phase 1: Analyze Changes

1. **Identify Changed Files**
   ```bash
   git diff main...HEAD --name-only
   # or
   git diff <base-branch>...HEAD --name-only
   ```

2. **Analyze Change Types**
   - New files vs modified files
   - Backend vs frontend vs database
   - API endpoints vs UI components
   - Configuration vs logic

3. **Read Implementation**
   - Understand what was implemented
   - Identify critical paths
   - Determine user-facing changes
   - Note performance-sensitive areas

### Phase 2: Determine Test Types Needed

Based on changes, identify which test types are appropriate:

#### API Endpoint Added/Modified → API Tests

**When:**
- New REST/GraphQL endpoints
- Modified endpoint behavior
- Changed request/response format

**Tests:**
- Request validation
- Response format
- Success scenarios
- Error scenarios (400, 401, 403, 404, 500)
- Edge cases

**Skip E2E if:** API is internal only (not user-facing)

#### UI Component Added/Modified → E2E Tests

**When:**
- New pages or components
- Modified user flows
- Changed UI behavior

**Tests:**
- User interaction flows
- Form submissions
- Navigation
- Visual feedback

**Skip API tests if:** E2E tests already cover backend through UI

#### Database Schema Changed → Migration Tests

**When:**
- New tables/columns
- Modified schema
- Data migrations

**Tests:**
- Migration up/down
- Data integrity
- Foreign key constraints
- Indexes applied

#### Business Logic Added → Unit Tests

**When:**
- Complex algorithms
- Validation logic
- Calculations
- Data transformations

**Tests:**
- Valid inputs
- Invalid inputs
- Edge cases
- Error handling

**Consider skipping if:** Logic is tested adequately by integration/E2E tests

#### Performance-Critical Code → Performance Tests

**When:**
- Database queries
- Large data processing
- API endpoints with latency requirements
- File operations

**Tests:**
- Response time under load
- Resource usage
- Scalability
- Throughput

### Phase 3: Avoid Redundant Tests

**Key Principle:** Don't test the same thing twice at different levels.

#### Example: Form Submission Feature

**Backend API:**
- Endpoint: `POST /api/forms`
- Logic: Validation, database insert, email notification

**Frontend:**
- Component: FormBuilder
- User flow: Fill form → Submit → Success message

**Test Strategy:**

✅ **Good (Non-Redundant):**
```markdown
## E2E Tests
- [ ] User can create form, fill details, and submit successfully
- [ ] User sees error message for invalid email
- [ ] User sees success confirmation after submission

## API Tests (only edge cases not covered by E2E)
- [ ] API returns 400 for malformed JSON
- [ ] API handles concurrent submissions correctly

## Unit Tests (complex logic not easily tested via E2E)
- [ ] SIRET validation algorithm works correctly
```

❌ **Bad (Redundant):**
```markdown
## E2E Tests
- [ ] User can submit form

## API Tests (redundant with E2E)
- [ ] POST /api/forms creates form in database
- [ ] POST /api/forms returns 200 on success
- [ ] POST /api/forms validates email format

## Unit Tests (redundant with E2E and API)
- [ ] FormController.Create method works
- [ ] Email validation works
```

**Redundancy:** E2E test already covers API behavior and validation through UI. No need for separate API tests unless testing edge cases not accessible via UI.

### Phase 4: Generate Test Plan Document

Create `test-plan.md` with structure:

```markdown
# Test Plan: [Feature Name]

**Date:** [Date]
**Implementation:** [Branch/PR]

## Overview
[Brief description of what was implemented]

## Changed Files
- `path/to/file1.ts`
- `path/to/file2.cs`

## Test Strategy
[Explanation of test approach and coverage]

---

## E2E Tests (Priority: High)

- [ ] Test 1: [Description]
- [ ] Test 2: [Description]

---

## API Tests (Priority: Medium)

- [ ] Test 1: [Description]
- [ ] Test 2: [Description]

---

## Unit Tests (Priority: Low)

- [ ] Test 1: [Description]
- [ ] Test 2: [Description]

---

## Performance Tests (Optional)

- [ ] Test 1: [Description]

---

## Notes
[Any important testing considerations]
```

## Test Type Guidelines

### E2E (End-to-End) Tests

**Purpose:** Test complete user flows from UI to backend

**When to Include:**
- User-facing features
- Critical workflows
- Multi-step processes
- Integration between frontend and backend

**Example Tests:**
```markdown
- [ ] User can register, login, and access dashboard
- [ ] User can create form with all field types
- [ ] User can submit form and see confirmation
- [ ] Admin can view all submissions for a form
```

**How to Execute:** Browser automation (Playwright, Cypress, etc.)

### API Tests

**Purpose:** Test backend endpoints directly

**When to Include:**
- Endpoints not fully covered by E2E
- Edge cases difficult to test via UI
- Error scenarios (400, 401, 500)
- API-only features (webhooks, batch operations)

**Example Tests:**
```markdown
- [ ] POST /api/forms returns 400 for invalid JSON
- [ ] GET /api/forms?page=999 handles non-existent page
- [ ] PUT /api/forms/{id} returns 404 for non-existent form
- [ ] API rate limiting works (429 after 100 requests/min)
```

**How to Execute:** curl, httpie, or API test framework

### Unit Tests

**Purpose:** Test individual functions/methods in isolation

**When to Include:**
- Complex algorithms (validation, calculations)
- Business logic that's hard to test at higher levels
- Utility functions
- Edge cases in isolated functions

**Example Tests:**
```markdown
- [ ] ValidateSIRET returns true for valid SIRET
- [ ] ValidateSIRET returns false for invalid checksum
- [ ] CalculatePrice handles discount correctly
- [ ] ParseDate handles multiple date formats
```

**How to Execute:** Test framework (Jest, xUnit, pytest, etc.)

**Skip if:** Logic is adequately covered by integration or E2E tests

### Integration Tests

**Purpose:** Test interactions between components

**When to Include:**
- Database operations
- External API integrations
- Service-to-service communication
- File operations

**Example Tests:**
```markdown
- [ ] User creation persists to database correctly
- [ ] Email service integrates with Microsoft Graph API
- [ ] File upload saves file and creates database record
- [ ] Redis caching works with API queries
```

**How to Execute:** Test framework with real dependencies (or test doubles)

### Performance Tests

**Purpose:** Test speed, scalability, resource usage

**When to Include:**
- Performance-critical features
- Database queries on large datasets
- APIs with latency requirements
- Batch operations

**Example Tests:**
```markdown
- [ ] GET /api/submissions returns in <200ms with 10,000 records
- [ ] File upload handles 100MB files without timeout
- [ ] Dashboard loads in <1s with 50 forms
- [ ] API handles 100 concurrent requests without errors
```

**How to Execute:** Load testing tools (ab, wrk, k6, JMeter)

## Prioritization

### High Priority (Must Test)
- Critical user flows
- Data integrity
- Security features
- Core business logic

### Medium Priority (Should Test)
- Edge cases
- Error handling
- Non-critical features
- Performance benchmarks

### Low Priority (Nice to Test)
- UI polish
- Minor optimizations
- Rarely-used features

Mark priorities in test plan:

```markdown
## E2E Tests (Priority: High)
- [ ] 🔴 User authentication flow
- [ ] 🔴 Form submission and data persistence

## API Tests (Priority: Medium)
- [ ] 🟡 Error handling for malformed requests
- [ ] 🟡 Pagination edge cases

## Unit Tests (Priority: Low)
- [ ] 🟢 Date formatting utility
- [ ] 🟢 String truncation helper
```

## Change Pattern Analysis

### Pattern 1: New CRUD API

**Changes:**
- New controller with Create, Read, Update, Delete endpoints
- New entity
- New database migration

**Tests Needed:**
```markdown
## E2E Tests
- [ ] Create resource via UI
- [ ] View resource in list
- [ ] Edit resource
- [ ] Delete resource

## API Tests (edge cases)
- [ ] POST validates required fields
- [ ] PUT returns 404 for non-existent resource
- [ ] DELETE is idempotent
```

### Pattern 2: Complex Validation Logic

**Changes:**
- New validation service with business rules

**Tests Needed:**
```markdown
## Unit Tests (thorough)
- [ ] Valid inputs pass validation
- [ ] Invalid inputs fail with correct errors
- [ ] Edge cases (boundary values, null, empty)

## Integration Tests
- [ ] Validation integrated into API correctly
```

Skip E2E if validation errors are covered by unit + integration tests.

### Pattern 3: UI-Only Changes

**Changes:**
- New React components
- CSS styling updates

**Tests Needed:**
```markdown
## E2E Tests (light)
- [ ] Component renders correctly
- [ ] User interactions work
- [ ] Responsive behavior

## Visual Regression (optional)
- [ ] Screenshot comparison tests
```

Skip API and unit tests (no backend changes).

### Pattern 4: Database Migration

**Changes:**
- Schema changes
- Data migration scripts

**Tests Needed:**
```markdown
## Migration Tests
- [ ] Migration applies successfully
- [ ] Migration rollback works
- [ ] Existing data remains intact
- [ ] New constraints are enforced

## Integration Tests
- [ ] API works with new schema
```

### Pattern 5: Performance Optimization

**Changes:**
- Query optimization
- Caching added
- Indexing added

**Tests Needed:**
```markdown
## Performance Tests
- [ ] Response time improved (before/after benchmark)
- [ ] Resource usage decreased
- [ ] Scalability improved

## Regression Tests
- [ ] Functionality unchanged (no bugs introduced)
```

## Generic Test Generation Algorithm

```python
def generate_test_plan(changes):
    tests = []

    # Analyze changes
    backend_changes = filter(is_backend, changes)
    frontend_changes = filter(is_frontend, changes)
    db_changes = filter(is_database, changes)

    # Determine E2E needs
    if frontend_changes or user_facing(backend_changes):
        tests.extend(generate_e2e_tests(changes))

    # Determine API needs
    if backend_changes and not fully_covered_by_e2e(backend_changes):
        tests.extend(generate_api_tests(backend_changes))

    # Determine unit test needs
    complex_logic = find_complex_logic(changes)
    if complex_logic:
        tests.extend(generate_unit_tests(complex_logic))

    # Determine integration test needs
    if db_changes or external_integrations(changes):
        tests.extend(generate_integration_tests(changes))

    # Determine performance test needs
    if is_performance_critical(changes):
        tests.extend(generate_performance_tests(changes))

    # Remove redundant tests
    tests = deduplicate(tests)

    return tests
```

## Tips for Effective Test Plans

1. **Analyze Changes First**: Understand what was implemented
2. **Think Coverage, Not Quantity**: More tests ≠ better
3. **Avoid Redundancy**: Test each thing once at the right level
4. **Prioritize**: Mark critical tests as high priority
5. **Be Specific**: "Test form submission" → "Test form submission with file upload"
6. **Consider Maintenance**: Don't create brittle tests
7. **Think User Perspective**: E2E tests should match real usage
8. **Document Rationale**: Explain test strategy in plan
9. **Balance Thoroughness**: Cover important cases, skip trivial ones
10. **Update as Needed**: Adjust plan based on test execution results

## Bundled Resources

- `scripts/analyze_changes.py` - Analyze git diff to determine test needs
- `references/test-strategies.md` - Test strategies by change type
