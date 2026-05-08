---
name: accept-interfaces-return-structs
description: Core pattern for flexible, testable Go APIs
---

# Accept Interfaces, Return Structs

The fundamental Go interface design principle: functions should accept interfaces but return concrete types.

## The Pattern

**CORRECT** - Accept interface, return concrete
```go
type Storage interface {
    Save(data []byte) error
}

func NewProcessor(s Storage) *Processor {
    return &Processor{storage: s}
}

func (p *Processor) Process(input string) (*Result, error) {
    // Returns concrete *Result, accepts Storage interface
    return &Result{Value: input}, nil
}
```

**WRONG** - Return interface unnecessarily
```go
func NewProcessor(s *FileStorage) Storage {
    // Locks caller into interface, prevents direct method access
    return &Processor{storage: s}
}
```

## Why This Works

**Accepting interfaces:**
- Caller controls abstraction
- Easy to mock/test
- Flexible composition

**Returning concrete types:**
- No hidden behaviors
- All methods visible
- Can add methods without breaking compatibility

## When to Deviate

**Return interface when:**
```go
func NewLogger(env string) io.Writer {
    // Valid: stdlib interface, multiple implementations
    if env == "prod" {
        return &fileLogger{}
    }
    return &consoleLogger{}
}
```

Return interfaces only when:
- Using stdlib interfaces (io.Writer, io.Reader)
- Multiple implementations chosen at runtime
- Interface already well-established in ecosystem
