---
name: task-decomposer
description: Decompose Linear todos into actionable, testifiable chunks with rationale, as-is/to-be analysis, expected outputs, and risk assessment for effective project management
license: Apache-2.0
---

# Task Decomposer

Transform high-level Linear tasks into structured, actionable subtasks with comprehensive analysis. Optimize for team efficiency, testability, and risk management.

## Overview

Break down complex tasks into:
- **Actionable subtasks** - Clear, specific work items
- **Testifiable chunks** - Each with validation criteria
- **Decomposition rationale** - Why this breakdown makes sense
- **As-is → To-be analysis** - Current vs. desired state
- **Expected outputs** - Concrete deliverables per subtask
- **Risk assessment** - Potential blockers and mitigation

## Basic Workflow

### 1. Analyze the Task

Understand the complete scope:
```
Input: "Implement user authentication system"
```

Run analysis:
```bash
python scripts/analyze_task.py "Implement user authentication system" --project backend
```

### 2. Generate Decomposition

Receive structured breakdown:
- Subtask list with estimates
- Dependency graph
- Testing criteria
- Risk matrix
- Linear-ready format

### 3. Review and Refine

Validate decomposition:
- Check for completeness
- Verify dependencies
- Assess estimates
- Confirm testability

### 4. Export to Linear

Create Linear issues:
```bash
python scripts/analyze_task.py "..." --export-linear --team-id TEAM123
```

## Decomposition Framework

### Core Principles

**Actionable:**
Each subtask should be:
- Specific and concrete
- Assignable to one person
- Completable in 1-4 hours
- Independently testable

**Testifiable:**
Every subtask includes:
- Acceptance criteria
- Test scenarios
- Verification steps
- Success metrics

**Structured:**
Organized by:
- Dependencies (what blocks what)
- Priority (critical path items)
- Complexity (risk assessment)
- Domain (frontend, backend, etc.)

### Analysis Components

#### 1. Decomposition Rationale

Explain the breakdown logic:

```markdown
## Rationale

**Why 5 subtasks?**
- Authentication flow has 3 distinct phases: capture, verify, persist
- Each phase requires separate testing
- Frontend and backend work can proceed in parallel
- Security review is critical path item

**Why this grouping?**
- Backend API development unblocks frontend work
- Database schema must exist before API implementation
- Security review happens after basic implementation
- Integration tests require all components complete
```

#### 2. As-Is → To-Be Analysis

Document current state and goal state:

```markdown
## State Analysis

**As-Is (Current State):**
- No user authentication
- Open API endpoints
- No session management
- No access control

**To-Be (Desired State):**
- JWT-based authentication
- Protected API endpoints
- Secure session handling
- Role-based access control
- Password reset flow
- Account lockout after failed attempts

**Gap Analysis:**
- Need database schema for users and sessions
- Need password hashing mechanism
- Need JWT generation and validation
- Need middleware for protected routes
- Need frontend login/registration forms
- Need security audit
```

#### 3. Expected Outputs

Define deliverables per subtask:

```markdown
## Subtask 1: Database Schema Design
**Outputs:**
- `schema/users.sql` - User table definition
- `schema/sessions.sql` - Session table definition
- Migration script with rollback
- Schema documentation

## Subtask 2: Password Hashing Service
**Outputs:**
- `services/auth/hasher.py` - Bcrypt implementation
- Unit tests (>90% coverage)
- API documentation
- Performance benchmarks

## Subtask 3: JWT Token Service
**Outputs:**
- `services/auth/jwt.py` - Token generation/validation
- Unit tests with mocked scenarios
- Token expiration handling
- Refresh token logic
```

#### 4. Risk Assessment

Identify and mitigate risks:

```markdown
## Risks & Mitigation

### HIGH Risk
**Security vulnerabilities**
- Impact: System breach, data exposure
- Probability: Medium
- Mitigation: External security audit, penetration testing
- Owner: Security team

**Password storage weakness**
- Impact: Credential compromise
- Probability: Low (using bcrypt)
- Mitigation: Use industry-standard bcrypt, security review
- Owner: Backend lead

### MEDIUM Risk
**JWT secret management**
- Impact: Token forgery
- Probability: Medium
- Mitigation: Environment variables, secret rotation policy
- Owner: DevOps

**Performance degradation**
- Impact: Slow authentication
- Probability: Low
- Mitigation: Benchmark tests, caching strategy
- Owner: Backend team

### LOW Risk
**Browser compatibility**
- Impact: Some users can't authenticate
- Probability: Low (modern APIs)
- Mitigation: Test on major browsers, polyfills
- Owner: Frontend team
```

## Output Format

### Linear-Ready Subtasks

```markdown
# Task: Implement User Authentication System

## Subtasks

### 1. Design Database Schema for Authentication
**Priority:** P0 (Critical Path)
**Estimate:** 2 hours
**Labels:** backend, database, security
**Dependencies:** None

**Description:**
Create user and session tables with proper indexing and constraints.

**Acceptance Criteria:**
- [ ] Users table with email, password_hash, created_at
- [ ] Sessions table with token, user_id, expires_at
- [ ] Unique index on users.email
- [ ] Foreign key from sessions to users
- [ ] Migration script with rollback

**Testing:**
- [ ] Run migration on test database
- [ ] Verify constraints prevent duplicate emails
- [ ] Verify cascade deletion works
- [ ] Test rollback functionality

**Expected Output:**
- `migrations/001_create_auth_schema.sql`
- Schema documentation in `docs/database.md`

**Risks:**
- None (foundational task)

---

### 2. Implement Password Hashing Service
**Priority:** P0 (Critical Path)
**Estimate:** 3 hours
**Labels:** backend, security
**Dependencies:** #1 (database schema)

**Description:**
Create secure password hashing using bcrypt with configurable rounds.

**Acceptance Criteria:**
- [ ] Hash passwords with bcrypt (12 rounds minimum)
- [ ] Verify password against hash
- [ ] Handle encoding edge cases
- [ ] Unit tests >90% coverage

**Testing:**
- [ ] Test password hashing is deterministic
- [ ] Test verification accepts correct passwords
- [ ] Test verification rejects incorrect passwords
- [ ] Test edge cases (empty, very long, special chars)

**Expected Output:**
- `services/auth/hasher.py`
- `tests/test_hasher.py` (>90% coverage)
- API documentation

**Risks:**
- LOW: Bcrypt dependency issues (mitigation: pin version)

---

### 3. Implement JWT Token Service
**Priority:** P0 (Critical Path)
**Estimate:** 4 hours
**Labels:** backend, security
**Dependencies:** None (can parallel with #1-2)

**Description:**
Generate and validate JWT tokens with expiration and refresh logic.

**Acceptance Criteria:**
- [ ] Generate JWT with user_id payload
- [ ] Set expiration (configurable, default 1 hour)
- [ ] Validate token signature and expiration
- [ ] Generate refresh tokens (7 day expiration)
- [ ] Blacklist mechanism for logout

**Testing:**
- [ ] Test token generation includes correct claims
- [ ] Test expired tokens fail validation
- [ ] Test invalid signatures fail validation
- [ ] Test refresh token flow
- [ ] Test blacklist prevents token reuse

**Expected Output:**
- `services/auth/jwt.py`
- `tests/test_jwt.py`
- Environment variable documentation

**Risks:**
- MEDIUM: JWT secret management (mitigation: document env vars)

---

### 4. Build Authentication API Endpoints
**Priority:** P0 (Critical Path)
**Estimate:** 4 hours
**Labels:** backend, api
**Dependencies:** #1, #2, #3

**Description:**
Create /register, /login, /logout, /refresh endpoints with validation.

**Acceptance Criteria:**
- [ ] POST /register - Create user account
- [ ] POST /login - Authenticate and return JWT
- [ ] POST /logout - Invalidate token
- [ ] POST /refresh - Get new access token
- [ ] Input validation and error handling
- [ ] Rate limiting on auth endpoints

**Testing:**
- [ ] Test successful registration flow
- [ ] Test duplicate email rejection
- [ ] Test successful login flow
- [ ] Test invalid credentials rejection
- [ ] Test logout invalidates token
- [ ] Test refresh token flow

**Expected Output:**
- `routes/auth.py`
- `tests/test_auth_routes.py`
- API documentation (OpenAPI spec)

**Risks:**
- MEDIUM: Rate limiting complexity (mitigation: use existing middleware)

---

### 5. Create Frontend Login/Register Forms
**Priority:** P1 (Important)
**Estimate:** 4 hours
**Labels:** frontend, ui
**Dependencies:** #4 (API must exist)

**Description:**
Build React forms for authentication with validation and error handling.

**Acceptance Criteria:**
- [ ] Login form (email, password)
- [ ] Registration form (email, password, confirm)
- [ ] Client-side validation
- [ ] Error message display
- [ ] Loading states
- [ ] Success redirects

**Testing:**
- [ ] Test form validation (empty, invalid email, short password)
- [ ] Test successful login flow
- [ ] Test successful registration flow
- [ ] Test error message display
- [ ] Test loading states

**Expected Output:**
- `components/LoginForm.tsx`
- `components/RegisterForm.tsx`
- `tests/LoginForm.test.tsx`
- `tests/RegisterForm.test.tsx`

**Risks:**
- LOW: Browser compatibility (mitigation: test on major browsers)

---

### 6. Implement Protected Route Middleware
**Priority:** P0 (Critical Path)
**Estimate:** 2 hours
**Labels:** backend, security
**Dependencies:** #3 (JWT service)

**Description:**
Create middleware to protect endpoints requiring authentication.

**Acceptance Criteria:**
- [ ] Middleware extracts JWT from Authorization header
- [ ] Validates token and attaches user to request
- [ ] Returns 401 for missing/invalid tokens
- [ ] Handles token expiration gracefully

**Testing:**
- [ ] Test valid token allows access
- [ ] Test missing token returns 401
- [ ] Test invalid token returns 401
- [ ] Test expired token returns 401

**Expected Output:**
- `middleware/auth.py`
- `tests/test_auth_middleware.py`
- Usage documentation

**Risks:**
- None

---

### 7. Security Audit and Penetration Testing
**Priority:** P0 (Critical Path)
**Estimate:** 4 hours
**Labels:** security, review
**Dependencies:** #1-6 (all implementation complete)

**Description:**
Comprehensive security review and penetration testing of auth system.

**Acceptance Criteria:**
- [ ] SQL injection testing
- [ ] XSS testing
- [ ] CSRF testing
- [ ] Session fixation testing
- [ ] Brute force testing
- [ ] Token forgery testing
- [ ] Document findings and fixes

**Testing:**
- [ ] Automated security scan (OWASP ZAP)
- [ ] Manual penetration testing
- [ ] Fix all HIGH and MEDIUM findings
- [ ] Document LOW findings as known issues

**Expected Output:**
- Security audit report
- Fix commits for identified issues
- Security best practices documentation

**Risks:**
- HIGH: Vulnerabilities discovered (mitigation: allocate time for fixes)

---

### 8. Integration Testing
**Priority:** P1 (Important)
**Estimate:** 3 hours
**Labels:** testing, integration
**Dependencies:** #4, #5 (backend + frontend complete)

**Description:**
End-to-end integration tests covering complete auth flows.

**Acceptance Criteria:**
- [ ] Test complete registration → login → access protected resource
- [ ] Test logout → attempt access (should fail)
- [ ] Test token refresh flow
- [ ] Test error scenarios

**Testing:**
- [ ] E2E test: successful auth flow
- [ ] E2E test: failed login flow
- [ ] E2E test: token expiration handling
- [ ] E2E test: refresh token flow

**Expected Output:**
- `tests/integration/test_auth_flow.py`
- Test coverage report

**Risks:**
- MEDIUM: Test flakiness (mitigation: proper setup/teardown)
```

## Usage Examples

### Example 1: Simple Feature

Input:
```
"Add dark mode toggle to settings page"
```

Output:
```markdown
## Subtasks

1. **Design dark mode color palette** (1h)
   - Define colors for light/dark themes
   - Test contrast ratios (WCAG AA)
   - Expected: colors.ts with theme definitions

2. **Implement theme context** (2h)
   - React context for theme state
   - LocalStorage persistence
   - Expected: ThemeContext.tsx + tests

3. **Create toggle component** (2h)
   - Toggle UI in settings
   - Connect to theme context
   - Expected: DarkModeToggle.tsx + tests

4. **Apply theme to components** (3h)
   - Update all components to use theme colors
   - Test in both modes
   - Expected: Updated component styles

5. **Test cross-browser** (1h)
   - Test on Chrome, Firefox, Safari
   - Expected: Test report, bug fixes
```

### Example 2: Complex Refactor

Input:
```
"Refactor legacy payment processing to use new Stripe API"
```

Includes:
- As-is: Current payment flow (legacy API)
- To-be: New Stripe API integration
- Migration strategy
- Rollback plan
- Risk assessment (payment failures, data loss)
- Testing strategy (canary deployment)

See `references/decomposition-framework.md` for full example.

## Best Practices

### Subtask Sizing

✅ **DO**: Keep subtasks 1-4 hours
```
Good: "Implement JWT validation middleware"
Good: "Create login form component"
Good: "Write integration tests for auth flow"
```

❌ **DON'T**: Create massive subtasks
```
Bad: "Implement entire authentication system"
Bad: "Build all frontend components"
Bad: "Do all testing"
```

### Dependency Management

✅ **DO**: Clearly identify blockers
```
"Subtask 4: Build API endpoints"
Dependencies: #1 (database), #2 (password hashing), #3 (JWT)
Can start: After all dependencies complete
```

❌ **DON'T**: Create circular dependencies
```
Bad: A depends on B, B depends on C, C depends on A
```

### Testing Criteria

✅ **DO**: Specific, testable acceptance criteria
```
- [ ] Users table has email column with UNIQUE constraint
- [ ] Password hash uses bcrypt with 12 rounds
- [ ] JWT tokens expire after 1 hour
```

❌ **DON'T**: Vague acceptance criteria
```
- [ ] Database works
- [ ] Passwords are secure
- [ ] Tokens are good
```

## Advanced Features

### Dependency Graph Generation

Visualize task relationships:
```bash
python scripts/analyze_task.py "..." --graph output.dot
dot -Tpng output.dot -o dependencies.png
```

### Estimation Calibration

Learn from actual vs. estimated:
```bash
python scripts/analyze_task.py "..." --calibrate team-history.json
```

### Risk Matrix

Generate risk heatmap:
```bash
python scripts/analyze_task.py "..." --risk-matrix risks.md
```

## Integration

### Linear API

Direct export to Linear:
```bash
# Export all subtasks as Linear issues
python scripts/analyze_task.py "..." --export-linear --team-id TEAM123

# Link to parent epic
python scripts/analyze_task.py "..." --export-linear --parent-id EPIC-456
```

### GitHub Issues

Export to GitHub:
```bash
python scripts/analyze_task.py "..." --export-github --repo owner/repo
```

### Slack Notifications

Notify team of decomposition:
```bash
python scripts/analyze_task.py "..." --notify-slack --channel #engineering
```

## Resources

- Decomposition framework: `references/decomposition-framework.md`
- Output templates: `references/output-templates.md`
- Analysis script: `scripts/analyze_task.py`
- Linear integration guide: `references/linear-integration.md`

## Quality Checklist

Before exporting subtasks:

- [ ] Each subtask is actionable and specific
- [ ] All subtasks have acceptance criteria
- [ ] Dependencies are clearly identified
- [ ] Estimates are realistic (1-4 hours each)
- [ ] Testing criteria are included
- [ ] Expected outputs are defined
- [ ] Risks are assessed
- [ ] Rationale is documented
- [ ] As-is → To-be analysis is complete
- [ ] No circular dependencies
