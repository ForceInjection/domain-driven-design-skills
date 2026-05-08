---
name: go-errors
description: Go error handling patterns. Routes to specific patterns.
---

# Go Error Handling

## Route by Need
- Wrapping errors with context → see [wrapping/](wrapping/)
- Defining sentinel errors → see [sentinel/](sentinel/)
- Checking error types → see [checking/](checking/)

## Quick Check
- [ ] Never ignore errors (_ = fn())
- [ ] Wrap with context at boundaries
- [ ] Use errors.Is/As, not ==

## Common Pattern
```go
func ProcessFile(path string) error {
    f, err := os.Open(path)
    if err != nil {
        return fmt.Errorf("open %s: %w", path, err)
    }
    defer f.Close()

    if err := parse(f); err != nil {
        return fmt.Errorf("parse %s: %w", path, err)
    }
    return nil
}
```

## Resources
- [wrapping/](wrapping/) - Add context with fmt.Errorf %w
- [sentinel/](sentinel/) - Define package-level errors
- [checking/](checking/) - Type-safe error inspection
