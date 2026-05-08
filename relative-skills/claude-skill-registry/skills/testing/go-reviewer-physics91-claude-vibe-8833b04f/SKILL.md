---
name: go-reviewer
description: |
  WHEN: Go project review, error handling, goroutines, interfaces, testing
  WHAT: Error handling patterns + Concurrency safety + Interface design + Testing + Idiomatic Go
  WHEN NOT: Go API frameworks → go-api-reviewer, Rust → rust-reviewer
---

# Go Reviewer Skill

## Purpose
Reviews Go code for idiomatic patterns, error handling, concurrency, and best practices.

## When to Use
- Go project code review
- Error handling review
- Goroutine/channel review
- Interface design review
- Go testing patterns

## Project Detection
- `go.mod` in project root
- `.go` files
- `cmd/`, `internal/`, `pkg/` structure
- `*_test.go` test files

## Workflow

### Step 1: Analyze Project
```
**Go Version**: 1.21+
**Module**: github.com/org/project
**Structure**: Standard Go layout
**Testing**: go test / testify
**Linter**: golangci-lint
```

### Step 2: Select Review Areas
**AskUserQuestion:**
```
"Which areas to review?"
Options:
- Full Go review (recommended)
- Error handling patterns
- Concurrency and goroutines
- Interface design
- Testing and benchmarks
multiSelect: true
```

## Detection Rules

### Error Handling
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Ignored error | Always handle errors | CRITICAL |
| err != nil only | Add context with fmt.Errorf | MEDIUM |
| Panic for errors | Return error instead | HIGH |
| No error wrapping | Use %w for wrapping | MEDIUM |

```go
// BAD: Ignored error
data, _ := ioutil.ReadFile("config.json")

// GOOD: Handle error
data, err := os.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("reading config: %w", err)
}

// BAD: No context
if err != nil {
    return err
}

// GOOD: Add context
if err != nil {
    return fmt.Errorf("failed to process user %d: %w", userID, err)
}

// BAD: Panic for recoverable error
func GetUser(id int) *User {
    user, err := db.FindUser(id)
    if err != nil {
        panic(err)  // Don't panic!
    }
    return user
}

// GOOD: Return error
func GetUser(id int) (*User, error) {
    user, err := db.FindUser(id)
    if err != nil {
        return nil, fmt.Errorf("getting user %d: %w", id, err)
    }
    return user, nil
}
```

### Concurrency
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Data race potential | Use mutex or channels | CRITICAL |
| Goroutine leak | Ensure goroutines exit | HIGH |
| Unbuffered channel deadlock | Use buffered or select | HIGH |
| No context cancellation | Pass context.Context | MEDIUM |

```go
// BAD: Data race
type Counter struct {
    count int
}

func (c *Counter) Increment() {
    c.count++  // Race condition!
}

// GOOD: Mutex protection
type Counter struct {
    mu    sync.Mutex
    count int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

// BAD: Goroutine leak
func process(items []Item) {
    for _, item := range items {
        go processItem(item)  // No way to wait or cancel!
    }
}

// GOOD: WaitGroup and context
func process(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)

    for _, item := range items {
        item := item  // Capture loop variable
        g.Go(func() error {
            return processItem(ctx, item)
        })
    }

    return g.Wait()
}

// BAD: No timeout
resp, err := client.Do(req)

// GOOD: With context timeout
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()

req = req.WithContext(ctx)
resp, err := client.Do(req)
```

### Interface Design
| Check | Recommendation | Severity |
|-------|----------------|----------|
| Large interface | Keep interfaces small | MEDIUM |
| Interface in implementation | Define at consumer | MEDIUM |
| Concrete type in signature | Accept interfaces | MEDIUM |
| No interface for testing | Add interface for mocking | MEDIUM |

```go
// BAD: Large interface
type UserService interface {
    GetUser(id int) (*User, error)
    CreateUser(u *User) error
    UpdateUser(u *User) error
    DeleteUser(id int) error
    ListUsers() ([]*User, error)
    SearchUsers(query string) ([]*User, error)
    // ... 20 more methods
}

// GOOD: Small, focused interfaces
type UserGetter interface {
    GetUser(ctx context.Context, id int) (*User, error)
}

type UserCreator interface {
    CreateUser(ctx context.Context, u *User) error
}

// Consumer defines the interface it needs
type UserHandler struct {
    getter UserGetter  // Only what it needs
}

// BAD: Concrete type dependency
func ProcessFile(f *os.File) error {
    // Hard to test
}

// GOOD: Interface dependency
func ProcessFile(r io.Reader) error {
    // Easy to test with strings.Reader, bytes.Buffer, etc.
}
```

### Code Organization
| Check | Recommendation | Severity |
|-------|----------------|----------|
| No package structure | Use cmd/internal/pkg | MEDIUM |
| Exported unnecessary | Keep internal private | LOW |
| Package name mismatch | Match directory name | LOW |
| Circular import | Restructure packages | HIGH |

```
// GOOD: Standard Go project layout
project/
├── cmd/
│   └── server/
│       └── main.go
├── internal/           # Private packages
│   ├── service/
│   │   └── user.go
│   └── repository/
│       └── user.go
├── pkg/               # Public packages
│   └── client/
│       └── client.go
├── go.mod
└── go.sum
```

### Testing
| Check | Recommendation | Severity |
|-------|----------------|----------|
| No table-driven tests | Use test tables | MEDIUM |
| No test helpers | Extract common setup | LOW |
| No benchmarks | Add for hot paths | LOW |
| Mocking concrete types | Use interfaces | MEDIUM |

```go
// GOOD: Table-driven test
func TestParseSize(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int64
        wantErr bool
    }{
        {"bytes", "100", 100, false},
        {"kilobytes", "1KB", 1024, false},
        {"megabytes", "1MB", 1048576, false},
        {"invalid", "abc", 0, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseSize(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("ParseSize() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("ParseSize() = %v, want %v", got, tt.want)
            }
        })
    }
}

// GOOD: Benchmark
func BenchmarkParseSize(b *testing.B) {
    for i := 0; i < b.N; i++ {
        ParseSize("1MB")
    }
}
```

## Response Template
```
## Go Code Review Results

**Project**: [name]
**Go**: 1.22 | **Linter**: golangci-lint

### Error Handling
| Status | File | Issue |
|--------|------|-------|
| CRITICAL | service.go:45 | Ignored error from db.Query |

### Concurrency
| Status | File | Issue |
|--------|------|-------|
| HIGH | worker.go:23 | Potential goroutine leak |

### Interface Design
| Status | File | Issue |
|--------|------|-------|
| MEDIUM | handler.go:12 | Concrete type in function signature |

### Testing
| Status | File | Issue |
|--------|------|-------|
| MEDIUM | service_test.go | No table-driven tests |

### Recommended Actions
1. [ ] Handle all returned errors
2. [ ] Add context cancellation to goroutines
3. [ ] Define interfaces at consumer side
4. [ ] Convert tests to table-driven format
```

## Best Practices
1. **Errors**: Always handle, wrap with context
2. **Concurrency**: Use context, errgroup, proper sync
3. **Interfaces**: Small, defined at consumer
4. **Testing**: Table-driven, interfaces for mocking
5. **Linting**: Use golangci-lint

## Integration
- `go-api-reviewer`: API framework patterns
- `security-scanner`: Go security audit
- `perf-analyzer`: Go performance profiling
