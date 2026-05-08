---
name: go-error-checking
description: Type-safe error inspection using errors.Is and errors.As
---

# Error Checking

## Pattern
Use `errors.Is` to check sentinel errors and `errors.As` to extract error types.

## errors.Is - Check Sentinel Errors
```go
// CORRECT
if errors.Is(err, user.ErrNotFound) {
    return http.StatusNotFound
}

// WRONG - breaks with wrapped errors
if err == user.ErrNotFound { }
```

## errors.As - Extract Error Types
```go
// CORRECT - extracts specific error type
var pathErr *fs.PathError
if errors.As(err, &pathErr) {
    log.Printf("failed path: %s", pathErr.Path)
    log.Printf("operation: %s", pathErr.Op)
}

// WRONG - only checks direct type
if pathErr, ok := err.(*fs.PathError); ok { }
```

## Complete Example
```go
func HandleError(err error) {
    // Check sentinel errors
    if errors.Is(err, user.ErrNotFound) {
        fmt.Println("User not found")
        return
    }

    // Extract custom error types
    var validationErr *ValidationError
    if errors.As(err, &validationErr) {
        fmt.Printf("Validation failed: %v\n", validationErr.Fields)
        return
    }

    // Extract standard library errors
    var pathErr *fs.PathError
    if errors.As(err, &pathErr) {
        fmt.Printf("File operation failed: %s\n", pathErr.Path)
        return
    }

    // Generic error
    fmt.Printf("Unknown error: %v\n", err)
}
```

## Key Differences
- `errors.Is`: Checks if error matches a sentinel value (works through wrapping)
- `errors.As`: Extracts error of specific type (works through wrapping)
- Never use `==` or type assertions for wrapped errors
