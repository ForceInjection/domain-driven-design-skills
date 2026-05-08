---
name: go-patterns
description: This skill should be used for Go idioms, error handling, goroutines, interfaces, and testing, golang, Go language, Go modules, Go concurrency
whenToUse: Go code, Go patterns, goroutines, Go testing, golang, .go files, Go modules, Go error handling, Go interfaces, Go concurrency
whenNotToUse: Non-Go code, CGo interop, Rust, other systems languages
seeAlso:
  - skill: testing-strategies
    when: Go test architecture
  - skill: api-design
    when: Go HTTP services
---

# Go Patterns

Idiomatic Go patterns for Go 1.21+.

## Error Handling

```go
if err != nil {
    return fmt.Errorf("failed to process %s: %w", id, err)
}
```

## Interfaces

Small interfaces (1-3 methods). Accept interfaces, return structs.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

## Table-Driven Tests

```go
tests := []struct{
    name string
    input, want int
}{
    {"positive", 2, 3},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        if got := Fn(tt.input); got != tt.want {
            t.Errorf("got %d, want %d", got, tt.want)
        }
    })
}
```

## Concurrency

Always propagate context for cancellation:

```go
func work(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    default:
        // do work
    }
}
```

## Defer for Cleanup

```go
f, err := os.Open(path)
if err != nil { return err }
defer f.Close()
```
