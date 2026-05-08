---
name: WritingPlans
description: Creates comprehensive implementation plans with bite-sized tasks before touching code. USE WHEN user wants detailed implementation plan OR has spec/requirements for multi-step task OR needs to break down complex feature OR before starting significant coding work. Documents file paths, code examples, testing, and verification steps assuming engineer has minimal codebase context.
---

# WritingPlans

Write comprehensive implementation plans that break complex features into bite-sized, testable tasks.

## Overview

Create detailed implementation plans that:
- Break work into 2-5 minute tasks
- Specify exact file paths and line numbers
- Include complete code examples (not just descriptions)
- Provide test commands with expected output
- Follow DRY, YAGNI, TDD, and frequent commits
- Assume engineer is skilled but unfamiliar with codebase

**Announce at start:** "I'm using the WritingPlans skill to create a detailed implementation plan."

## Principles

### DRY (Don't Repeat Yourself)
- Avoid duplicating code across the codebase
- Extract common logic into reusable functions
- Use existing utilities and patterns

### YAGNI (You Aren't Gonna Need It)
- Only implement what's required for current use case
- Don't add features "just in case"
- Can always add more later

### TDD (Test-Driven Development)
- Write tests before implementation
- Verify tests fail first
- Write minimal code to pass tests
- Integrate with **TestDrivenDevelopment** skill

### Frequent Commits
- Commit after each completed task
- Small, focused commits
- Clear commit messages

## Bite-Sized Task Granularity

Each step is ONE action taking 2-5 minutes:

**Example task breakdown:**
1. Write the failing test ← step
2. Run it to verify it fails ← step
3. Implement minimal code to pass ← step
4. Run tests to verify they pass ← step
5. Commit the changes ← step

**Not this:**
1. "Implement user authentication" ← Too large
2. "Add tests and implementation" ← Multiple actions

## Plan Document Structure

### Header Template

Every plan MUST start with this header:

```markdown
# [Feature Name] Implementation Plan

**Status**: Draft | In Progress | Complete
**Created**: YYYY-MM-DD
**Goal**: [One sentence describing what this builds]
**Architecture**: [2-3 sentences about approach and key decisions]
**Tech Stack**: [Key technologies, libraries, tools used]

## Prerequisites

- [ ] [Any setup needed before starting]
- [ ] [Dependencies to install]
- [ ] [Documentation to review]

---
```

### Task Template

```markdown
### Task N: [Specific Component/Feature Name]

**Purpose**: [Why this task exists, what it accomplishes]

**Files:**
- Create: `exact/path/to/newfile.go`
- Modify: `exact/path/to/existing.go:123-145` (specify line ranges)
- Test: `tests/exact/path/to/test_file.go`
- Reference: `path/to/reference/pattern.go` (example to follow)

**Dependencies**: [What must be completed before this task]

---

#### Step 1: Write the failing test

```language
// Complete code, not pseudocode
func TestSpecificBehavior(t *testing.T) {
    input := "test input"
    result := FunctionUnderTest(input)
    expected := "expected output"
    if result != expected {
        t.Errorf("got %v, want %v", result, expected)
    }
}
```

**Why this test**: [Explain what behavior it verifies]

---

#### Step 2: Run test to verify it fails

**Command:**
```bash
go test ./path/to/package -v -run TestSpecificBehavior
```

**Expected output:**
```
FAIL: TestSpecificBehavior
    undefined: FunctionUnderTest
```

**If different**: [Troubleshooting guidance]

---

#### Step 3: Write minimal implementation

```language
// Complete implementation, not "add code here"
func FunctionUnderTest(input string) string {
    // Minimal code to pass test
    return "expected output"
}
```

**Implementation notes**: [Explain key decisions]

---

#### Step 4: Run test to verify it passes

**Command:**
```bash
go test ./path/to/package -v -run TestSpecificBehavior
```

**Expected output:**
```
PASS: TestSpecificBehavior (0.00s)
```

---

#### Step 5: Refactor (if needed)

**Optional improvements:**
- Extract common logic
- Improve naming
- Add documentation

**Run tests after each refactor**

---

#### Step 6: Commit

```bash
git add tests/path/to/test_file.go path/to/newfile.go
git commit -m "feat: add specific feature

- Add FunctionUnderTest with test
- Handles [specific case]"
```

**Commit message format**: Follow repository conventions

---
```

## Complete Example

```markdown
# User Authentication Implementation Plan

**Status**: Draft
**Created**: 2025-12-25
**Goal**: Add JWT-based authentication to API endpoints
**Architecture**: Middleware-based auth using JWT tokens with refresh token rotation. Secrets stored via agenix.
**Tech Stack**: Go 1.21, golang-jwt/jwt/v5, agenix for secrets

## Prerequisites

- [ ] Review existing middleware patterns in `services/common/middleware/`
- [ ] Read JWT token structure in `docs/auth.md`
- [ ] Ensure agenix secret for JWT signing key exists

---

### Task 1: JWT Token Generation

**Purpose**: Create function to generate access and refresh tokens

**Files:**
- Create: `services/auth/jwt.go`
- Test: `services/auth/jwt_test.go`
- Reference: `services/common/crypto/signing.go` (signing pattern)

**Dependencies**: None

---

#### Step 1: Write the failing test

```go
package auth

import (
    "testing"
    "time"
)

func TestGenerateTokenPair_ValidUser(t *testing.T) {
    userID := "user-123"
    tokens, err := GenerateTokenPair(userID)

    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }

    if tokens.AccessToken == "" {
        t.Error("access token is empty")
    }

    if tokens.RefreshToken == "" {
        t.Error("refresh token is empty")
    }

    if tokens.ExpiresIn <= 0 {
        t.Error("expiration time is invalid")
    }
}
```

**Why this test**: Verifies token pair generation for authenticated user

---

#### Step 2: Run test to verify it fails

**Command:**
```bash
go test ./services/auth -v -run TestGenerateTokenPair_ValidUser
```

**Expected output:**
```
FAIL: TestGenerateTokenPair_ValidUser
    undefined: GenerateTokenPair
```

---

#### Step 3: Write minimal implementation

```go
package auth

import (
    "time"

    "github.com/golang-jwt/jwt/v5"
)

type TokenPair struct {
    AccessToken  string
    RefreshToken string
    ExpiresIn    int64
}

func GenerateTokenPair(userID string) (*TokenPair, error) {
    // TODO: Load secret from agenix in future task
    secret := []byte("temp-secret-for-testing")

    // Access token (15 minutes)
    accessClaims := jwt.MapClaims{
        "sub": userID,
        "exp": time.Now().Add(15 * time.Minute).Unix(),
    }
    accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
    accessStr, err := accessToken.SignedString(secret)
    if err != nil {
        return nil, err
    }

    // Refresh token (7 days)
    refreshClaims := jwt.MapClaims{
        "sub": userID,
        "exp": time.Now().Add(7 * 24 * time.Hour).Unix(),
    }
    refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
    refreshStr, err := refreshToken.SignedString(secret)
    if err != nil {
        return nil, err
    }

    return &TokenPair{
        AccessToken:  accessStr,
        RefreshToken: refreshStr,
        ExpiresIn:    900, // 15 minutes in seconds
    }, nil
}
```

**Implementation notes**: Using temporary secret for testing; will integrate agenix in subsequent task

---

#### Step 4: Run test to verify it passes

**Command:**
```bash
go test ./services/auth -v -run TestGenerateTokenPair_ValidUser
```

**Expected output:**
```
PASS: TestGenerateTokenPair_ValidUser (0.01s)
```

---

#### Step 5: Commit

```bash
git add services/auth/jwt.go services/auth/jwt_test.go
git commit -m "feat: add JWT token pair generation

- Generate access token (15 min expiry)
- Generate refresh token (7 day expiry)
- Using temporary secret (agenix integration pending)"
```

---

### Task 2: Agenix Secret Integration

[Continue with next task...]

---
```

## Plan Storage Location

**Save all plans to:**
```bash
docs/plans/YYYY-MM-DD-<feature-name>.md
```

**Example:**
```bash
docs/plans/2025-12-25-jwt-authentication.md
```

**After writing plan:**
```bash
git add docs/plans/2025-12-25-jwt-authentication.md
git commit -m "docs: add JWT authentication implementation plan"
```

## What to Include in Plans

### ✅ Do Include

- **Exact file paths** with line numbers for modifications
- **Complete code** in examples (not "add validation here")
- **Exact commands** to run with expected output
- **Why decisions were made** (architecture choices)
- **References** to existing patterns in codebase
- **Verification steps** for each task
- **Troubleshooting** guidance for common issues
- **Dependencies** between tasks

### ❌ Don't Include

- Vague instructions like "add error handling"
- Pseudocode or incomplete examples
- Assumptions about what engineer knows
- Commands without expected output
- Tasks larger than 5 minutes
- Implementation details without tests

## Integration with Other Skills

**Before WritingPlans:**
- Use **Brainstorming** skill to clarify design and requirements
- Ensure architecture decisions are made
- Identify all components needed

**While WritingPlans:**
- Reference **TestDrivenDevelopment** for test-first approach
- Check existing code patterns with **Grep** and **Read**
- Reference **CORE** principles for technology choices

**After WritingPlans:**
- Plan is ready for implementation
- Can be executed task-by-task
- Each task should take 2-5 minutes
- Progress can be tracked with **TodoWrite**

## Examples

**Example 1: Feature implementation plan**
```
User: "I need a detailed plan for adding caching to the API"

→ Invoke WritingPlans skill
→ Announce: "I'm using the WritingPlans skill to create a detailed implementation plan"
→ Review existing API structure
→ Check for caching patterns in codebase
→ Break down into tasks:
  1. Add cache configuration
  2. Implement cache middleware
  3. Add cache key generation
  4. Implement cache invalidation
  5. Add metrics for cache hits/misses
→ Write complete plan with code examples
→ Save to docs/plans/2025-12-25-api-caching.md
→ Commit plan document
→ Ready for implementation
```

**Example 2: Bug fix with test coverage**
```
User: "Create a plan to fix the authentication bug and add comprehensive tests"

→ Invoke WritingPlans skill
→ Review bug report and reproduction steps
→ Identify root cause
→ Break down into tasks:
  1. Write test reproducing bug
  2. Verify test fails
  3. Fix bug with minimal change
  4. Add edge case tests
  5. Add integration tests
→ Write plan with exact code and commands
→ Save to docs/plans/2025-12-25-auth-bug-fix.md
→ Ready for systematic implementation
```

**Example 3: Refactoring plan**
```
User: "Plan out refactoring the database layer to use a repository pattern"

→ Invoke WritingPlans skill
→ Analyze current database usage
→ Design repository interfaces
→ Break down into tasks:
  1. Define repository interfaces
  2. Implement user repository
  3. Migrate user service to use repository
  4. Add repository tests
  5. Repeat for each entity
→ Each task includes before/after code
→ Includes migration strategy (incremental)
→ Save plan with 20+ small tasks
→ Can be implemented incrementally
```

## Common Pitfalls

**Don't:**
- Write plans with vague tasks
- Skip exact file paths
- Provide incomplete code examples
- Forget test verification steps
- Make tasks too large (>5 minutes)
- Assume engineer knows codebase patterns

**Do:**
- Break work into bite-sized pieces
- Include complete, runnable code
- Specify expected output for commands
- Reference existing patterns
- Follow repository conventions
- Make each task independently committable
