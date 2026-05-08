---
name: brokle-testing
description: Use this skill when writing, reviewing, or improving tests for the Brokle platform. This includes creating service tests, domain tests, integration tests, or understanding what to test versus what to skip based on the pragmatic testing philosophy.
---

# Brokle Testing Skill

Expert guidance for writing pragmatic, high-value tests following Brokle's testing philosophy.

## Testing Philosophy

**Core Principle**: Test Business Logic, Not Framework Behavior

### What We Test ✅

1. **Complex Business Logic**: Calculations, retry mechanisms, state machines
2. **Batch Operations**: Bulk processing, partial success/failure handling
3. **Multi-Step Orchestration**: Multiple repository calls, cross-service workflows
4. **Error Handling Patterns**: Domain error mapping, retry logic with backoff
5. **Analytics & Aggregations**: Time-based queries, statistical calculations

### What We Don't Test ❌

1. **Simple CRUD**: Basic Create/Read/Update/Delete with no business logic
2. **Field Validation**: Already tested in domain layer
3. **Trivial Constructors**: Simple object creation
4. **Framework Behavior**: ULID generation, time.Now(), errors.Is (stdlib)
5. **Static Definitions**: Constant strings, enum type checkers

## Coverage Guidelines

**Target Metrics**:
- Service Layer: ~1:1 test-to-code ratio (focus on business logic)
- Domain Layer: Minimal (only complex calculations)
- Handler Layer: Critical workflows only

**Acceptable Ratios**:
- ✅ 0.8:1 to 1.2:1 - Healthy coverage
- ⚠️ < 0.5:1 - Missing critical coverage
- ⚠️ > 2:1 - Testing too many trivial operations

## Service Layer Test Pattern

```go
// ============================================================================
// Mock Repositories (Full Interface Implementation)
// ============================================================================

type MockUserRepository struct {
    mock.Mock
}

func (m *MockUserRepository) Create(ctx context.Context, user *authDomain.User) error {
    args := m.Called(ctx, user)
    return args.Error(0)
}

func (m *MockUserRepository) GetByID(ctx context.Context, id ulid.ULID) (*authDomain.User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*authDomain.User), args.Error(1)
}

// Implement ALL interface methods (even if not used in test)

// ============================================================================
// HIGH-VALUE TESTS: Complex Business Logic
// ============================================================================

func TestUserService_CreateUser(t *testing.T) {
    tests := []struct {
        name        string
        input       *CreateUserRequest
        mockSetup   func(*MockUserRepository)
        expectedErr error
        checkResult func(*testing.T, *CreateUserResponse)
    }{
        {
            name: "success - valid user",
            input: &CreateUserRequest{
                Email: "test@example.com",
                Name:  "Test User",
            },
            mockSetup: func(repo *MockUserRepository) {
                // Expect email check (not found)
                repo.On("GetByEmail", mock.Anything, "test@example.com").
                    Return(nil, authDomain.ErrNotFound)

                // Expect user creation
                repo.On("Create", mock.Anything, mock.MatchedBy(func(user *authDomain.User) bool {
                    return user.Email == "test@example.com" && user.Name == "Test User"
                })).Return(nil)
            },
            expectedErr: nil,
            checkResult: func(t *testing.T, resp *CreateUserResponse) {
                assert.NotNil(t, resp)
                assert.NotEqual(t, ulid.ULID{}, resp.User.ID)
                assert.Equal(t, "test@example.com", resp.User.Email)
            },
        },
        {
            name: "error - user already exists",
            input: &CreateUserRequest{
                Email: "existing@example.com",
                Name:  "Existing User",
            },
            mockSetup: func(repo *MockUserRepository) {
                // Return existing user
                existingUser := &authDomain.User{
                    ID:    ulid.New(),
                    Email: "existing@example.com",
                }
                repo.On("GetByEmail", mock.Anything, "existing@example.com").
                    Return(existingUser, nil)

                // No create call expected
            },
            expectedErr: errors.New("conflict"),  // Check error message, not sentinel
            checkResult: nil,
        },
        {
            name: "error - repository failure",
            input: &CreateUserRequest{
                Email: "test@example.com",
                Name:  "Test User",
            },
            mockSetup: func(repo *MockUserRepository) {
                repo.On("GetByEmail", mock.Anything, "test@example.com").
                    Return(nil, authDomain.ErrNotFound)
                repo.On("Create", mock.Anything, mock.Anything).
                    Return(fmt.Errorf("database error"))
            },
            expectedErr: errors.New("internal"),  // Check error message, not sentinel
            checkResult: nil,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Setup mocks
            mockRepo := new(MockUserRepository)
            tt.mockSetup(mockRepo)

            // Create service
            service := NewUserService(mockRepo)

            // Execute
            result, err := service.CreateUser(context.Background(), tt.input)

            // Assert errors
            if tt.expectedErr != nil {
                assert.Error(t, err)
                assert.ErrorIs(t, err, tt.expectedErr)
            } else {
                assert.NoError(t, err)
            }

            // Assert results
            if tt.checkResult != nil {
                tt.checkResult(t, result)
            }

            // Verify all mock expectations were met
            mockRepo.AssertExpectations(t)
        })
    }
}
```

## Key Testing Patterns

### 1. Table-Driven Tests

```go
tests := []struct {
    name        string
    input       InputType
    mockSetup   func(*MockRepo)
    expectedErr error
    checkResult func(*testing.T, *Result)
}{
    {
        name: "success case",
        input: validInput,
        mockSetup: func(repo *MockRepo) {
            repo.On("Method", mock.Anything, mock.Anything).Return(nil)
        },
        expectedErr: nil,
        checkResult: func(t *testing.T, result *Result) {
            assert.NotNil(t, result)
        },
    },
}
```

### 2. Complete Mock Interface Implementation

```go
type MockUserRepository struct {
    mock.Mock
}

// Implement ALL methods from interface
func (m *MockUserRepository) Create(ctx context.Context, user *User) error {
    args := m.Called(ctx, user)
    return args.Error(0)
}

func (m *MockUserRepository) GetByID(ctx context.Context, id ulid.ULID) (*User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*User), args.Error(1)
}

// Implement all other methods even if unused
```

### 3. Mock Setup Functions

```go
mockSetup: func(userRepo *MockUserRepo, orgRepo *MockOrgRepo) {
    // Use mock.MatchedBy for complex validation
    userRepo.On("Create", mock.Anything, mock.MatchedBy(func(user *User) bool {
        return user.Email != "" && user.Name != ""
    })).Return(nil)

    // Multiple expectations in order
    orgRepo.On("GetByID", mock.Anything, orgID).Return(org, nil)
    orgRepo.On("Update", mock.Anything, mock.Anything).Return(nil)
}
```

### 4. Result Validation Functions

```go
checkResult: func(t *testing.T, result *CreateUserResponse) {
    assert.NotNil(t, result)
    assert.NotEqual(t, ulid.ULID{}, result.User.ID)
    assert.Equal(t, "test@example.com", result.User.Email)
    assert.NotNil(t, result.User.CreatedAt)
    assert.Equal(t, "active", result.User.Status)
}
```

### 5. Mock Expectation Verification

```go
// ALWAYS call AssertExpectations on all mocks
mockUserRepo.AssertExpectations(t)
mockOrgRepo.AssertExpectations(t)
mockPublisher.AssertExpectations(t)
```

## Domain Layer Tests

**Only test complex business logic**:

```go
// ✅ HIGH-VALUE: Business logic calculation
func TestSpan_CalculateLatency(t *testing.T) {
    startTime := time.Now()
    endTime := startTime.Add(150 * time.Millisecond)

    tests := []struct {
        name     string
        span      *Span
        expected *int
    }{
        {
            name: "with valid end time",
            span: &Span{
                StartTime: startTime,
                EndTime:   &endTime,
            },
            expected: func() *int { val := 150; return &val }(),
        },
        {
            name: "without end time",
            span: &Span{
                StartTime: startTime,
                EndTime:   nil,
            },
            expected: nil,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := tt.obs.CalculateLatency()
            if tt.expected == nil {
                assert.Nil(t, result)
            } else {
                assert.NotNil(t, result)
                assert.Equal(t, *tt.expected, *result)
            }
        })
    }
}
```

## Integration Tests

```go
func TestUserService_Integration(t *testing.T) {
    // Skip if not running integration tests
    if testing.Short() {
        t.Skip("Skipping integration test")
    }

    // Setup test database
    db := setupTestDB(t)
    defer cleanupTestDB(t, db)

    // Setup real dependencies
    userRepo := repository.NewUserRepository(db)
    service := services.NewUserService(userRepo)

    // Test complete workflow
    user := &CreateUserRequest{
        Email: "integration@test.com",
        Name:  "Integration Test",
    }

    result, err := service.CreateUser(context.Background(), user)
    require.NoError(t, err)
    require.NotEqual(t, ulid.ULID{}, result.User.ID)

    // Verify persistence
    retrieved, err := service.GetUser(context.Background(), result.User.ID)
    require.NoError(t, err)
    assert.Equal(t, result.User.Email, retrieved.User.Email)
}
```

## Running Tests

```bash
# All tests
make test

# Unit tests only (skip integration)
make test-unit

# Integration tests with real databases
make test-integration

# With coverage
make test-coverage

# Specific package
go test ./internal/core/services/observability -v

# Specific test
go test ./internal/core/services/observability -run TestUserService_Create -v

# With race detection
go test -race ./...

# Skip integration tests
go test -short ./...
```

## Test Quality Checklist

**Before Writing Tests**:
- [ ] Identify business logic (not CRUD)
- [ ] Check if complex enough to warrant testing
- [ ] Review similar tests in `internal/core/services/observability/*_test.go`
- [ ] Plan test scenarios (success, validation errors, repository errors)

**Test Implementation**:
- [ ] Table-driven test pattern
- [ ] Complete mock interface implementations
- [ ] Mock expectations verified with `AssertExpectations(t)`
- [ ] Result validation functions for complex assertions
- [ ] Clear test names describing scenarios
- [ ] ~1:1 test-to-code ratio for business logic

**What NOT to Test**:
- [ ] ❌ Simple CRUD operations
- [ ] ❌ Field validation (domain layer)
- [ ] ❌ Trivial constructors
- [ ] ❌ Framework behavior
- [ ] ❌ Static constants

## References

- `docs/TESTING.md` - Complete testing guide
- `internal/core/services/observability/*_test.go` - Reference implementations
- `prompts/testing.txt` - AI-assisted test generation
