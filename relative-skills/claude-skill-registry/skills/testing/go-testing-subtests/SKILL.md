---
name: go-testing-subtests
description: Subtest patterns with t.Run
---

# Subtests with t.Run

Use t.Run to group related tests and enable selective execution.

## CORRECT

```go
func Test_User_Validation(t *testing.T) {
    t.Run("valid email", func(t *testing.T) {
        user := User{Email: "test@example.com"}
        if err := user.Validate(); err != nil {
            t.Errorf("expected valid, got error: %v", err)
        }
    })

    t.Run("invalid email", func(t *testing.T) {
        user := User{Email: "invalid"}
        if err := user.Validate(); err == nil {
            t.Error("expected error, got nil")
        }
    })

    t.Run("empty email", func(t *testing.T) {
        user := User{Email: ""}
        if err := user.Validate(); err == nil {
            t.Error("expected error, got nil")
        }
    })
}
```

**Run specific subtest:**
```bash
go test -run Test_User_Validation/invalid_email
```

**Why:**
- Logical grouping of related tests
- Can run subtests individually
- Clean test output with hierarchy
- Failures don't stop other subtests

## WRONG

```go
func Test_User_ValidEmail(t *testing.T) { /* ... */ }
func Test_User_InvalidEmail(t *testing.T) { /* ... */ }
func Test_User_EmptyEmail(t *testing.T) { /* ... */ }
```

**Problems:**
- No grouping relationship
- Harder to run related tests together
- More verbose test names
