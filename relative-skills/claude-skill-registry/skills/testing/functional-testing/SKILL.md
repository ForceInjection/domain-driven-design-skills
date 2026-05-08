---
name: functional-testing
description: Write functional tests that test public interfaces only (HTTP APIs via requests, libraries via exported functions, CLIs via command execution). Never test internal functions directly. Expose observability APIs for internal behavior testing.
---

# Functional Testing Philosophy

## Core Principle

**ALWAYS test the public interface of a project.** Tests should interact with the system the same way end users or consumers would, never calling internal/private functions directly.

The "public interface" varies by project type:
- **HTTP APIs**: Test via HTTP requests to running server
- **Libraries**: Test via exported package functions
- **CLIs**: Test via command execution with captured output

## CLI Testing Pattern

### Code Structure

Structure CLI applications to be testable by making the main() function a thin wrapper:

```go
package main

import (
    "context"
    "os"
    "github.com/your/project"
)

func main() {
    ctx := context.Background()
    os.Exit(project.Run(ctx, os.Argv[1:], project.RunOptions{
        Stdout: os.Stdout,
        Stderr: os.Stderr,
    }))
}
```

### Run Function Signature

The Run() function should accept:
- `context.Context` - for cancellation (servers) or timeout control. May be omitted for simple CLIs.
- `[]string` - command arguments (os.Argv[1:])
- Options struct - for dependency injection (stdout, stderr, config, etc.)

Examples:

```go
// Simple CLI (no context needed)
func Run(args []string, opts RunOptions) int

// Server CLI (needs context for shutdown)
func Run(ctx context.Context, args []string, opts RunOptions) int

// RunOptions provides testable dependencies
type RunOptions struct {
    Stdout io.Writer // Defaults to os.Stdout if nil
    Stderr io.Writer // Defaults to os.Stderr if nil
    // ... other dependencies
}
```

### Test Implementation

Tests call Run() with test arguments and capture output:

```go
package cmd_test

import (
    "bytes"
    "context"
    "testing"
    "yourproject/cmd"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestSubCommand(t *testing.T) {
    var stdout bytes.Buffer

    exitCode := cmd.Run([]string{"sub-command", "-f", "filename.ext"}, cmd.RunOptions{
        Stdout: &stdout,
    })

    require.Equal(t, 0, exitCode)
    assert.Contains(t, stdout.String(), "expected output")
}

func TestSubCommandWithContext(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    var stdout bytes.Buffer

    exitCode := cmd.Run(ctx, []string{"server", "start"}, cmd.RunOptions{
        Stdout: &stdout,
    })

    require.Equal(t, 0, exitCode)
}
```

## HTTP API Testing Pattern

### Code Structure

Structure HTTP services with a testable server lifecycle:

```go
type Server struct {
    // ... server state
}

func NewServer(opts ServerOptions) *Server {
    return &Server{...}
}

func (s *Server) Start(ctx context.Context, addr string) error {
    // Start HTTP server
}

func (s *Server) Shutdown(ctx context.Context) error {
    // Graceful shutdown
}
```

### Test Implementation

Tests start a real server and make HTTP requests:

```go
package api_test

import (
    "context"
    "net/http"
    "testing"
    "yourproject/api"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestCreateUser(t *testing.T) {
    server := api.NewServer(api.ServerOptions{
	   // ... actual or mocked dependencies
    })

    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    go server.Start(ctx, "localhost:0")
    defer server.Shutdown(context.Background())

    // Make actual HTTP request
    resp, err := http.Post(
        "http://localhost:8080/users",
        "application/json",
        strings.NewReader(`{"name":"Alice"}`),
    )
    require.NoError(t, err)
    defer resp.Body.Close()

    assert.Equal(t, http.StatusCreated, resp.StatusCode)
}
```

## Library Testing Pattern

### Code Structure

Export public functions that encapsulate business logic:

```go
package converter

// Public API
func Convert(input []byte, opts ConvertOptions) (*Result, error) {
    // Implementation
}

// Internal functions (not tested directly)
func parseSchema(data []byte) (*schema, error) {
    // Internal implementation
}
```

### Test Implementation

Tests call exported functions only:

```go
package converter_test

import (
    "testing"
    "yourproject/converter"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestConvert(t *testing.T) {
    for _, test := range []struct {
        name     string
        input    string
        expected string
    }{
        {
            name:     "simple conversion",
            input:    "input data",
            expected: "expected output",
        },
    } {
        t.Run(test.name, func(t *testing.T) {
            result, err := converter.Convert([]byte(test.input), converter.ConvertOptions{
                PackageName: "testpkg",
            })
            require.NoError(t, err)
            assert.Equal(t, test.expected, string(result.Output))
        })
    }
}
```

## Testing Internal Behavior via Observability

### The Problem

Some important code paths execute without direct user interaction. Examples:
- Background workers (cache eviction, garbage collection)
- Periodic operations (WAL writes, checkpoints, compaction)
- Performance optimizations (query plan caching, connection pooling)

If these behaviors are important enough to test, they're important enough to expose to users.

### The Solution: Expose Statistics and Observability

Instead of testing internal functions, expose public APIs that make internal behavior observable.

#### Example: Database WAL Writes

**Bad Approach** - Testing internal functions:

```go
// DON'T DO THIS
package db

func (db *DB) writeWAL() error { ... }

// Test calls internal function
func TestWriteWAL(t *testing.T) {
    db := NewDB()
    err := db.writeWAL() // Testing internal function
    require.NoError(t, err)
}
```

**Good Approach** - Expose statistics API:

```go
package db

type Stats struct {
    WALWriteCount     int64
    WALLastWriteTime  time.Time
    DirtyPages        int64
    PagesFlushedToWAL int64
    PagesFlushedToDB  int64
}

func (db *DB) Stats() Stats {
    return db.stats.snapshot()
}

// Internal function - not tested directly
func (db *DB) writeWAL() error {
    // Implementation
    db.stats.walWriteCount++
    db.stats.walLastWriteTime = time.Now()
}
```

**Test using public Stats API:**

```go
package db_test

func TestWALPeriodicWrite(t *testing.T) {
    db := NewDB(DBOptions{
        WALFlushInterval: 100 * time.Millisecond,
    })
    defer db.Close()

    // Perform operations
    require.NoError(t, db.Insert("key", "value"))

    // Poll statistics until expected behavior occurs
    require.Eventually(t, func() bool {
        stats := db.Stats()
        return stats.WALWriteCount > 0 && stats.DirtyPages == 0
    }, time.Second, 10*time.Millisecond)

    stats := db.Stats()
    assert.Greater(t, stats.PagesFlushedToWAL, int64(0))
}
```

### Benefits of Statistics APIs

1. **Users benefit**: Statistics are useful for monitoring, debugging, and optimization
2. **Tests verify real behavior**: Tests observe actual system behavior, not mocked internals
3. **No test-only code**: The statistics API is production code that serves real users
4. **Better diagnostics**: Users can troubleshoot issues using the same APIs tests use

### Decision Tree for Untestable Code

If code cannot be reached via the public interface:

```
Can this code be reached via public interface?
├─ No → Is this code important to project correctness?
│       ├─ No → Remove the code (it's dead code)
│       └─ Yes → Expose observability (statistics, metrics, debug APIs)
└─ Yes → Test via public interface
```

## When to Extract Internal Packages

### The Problem Domain Principle

Not all internal functionality should remain buried in a single package. When internal code represents a **distinct problem domain** that's part of your deliverable product, it should be extracted into its own internal package with a well-defined public interface.

### Identifying Extraction Candidates

Ask: "Is this internal functionality part of the observable product contract?"

Examples of problem domains worth extracting:
- **Database page format**: Users expect format consistency across versions
- **Wire protocol encoding**: The encoding scheme is part of the API contract
- **Configuration file parsing**: The config format is part of the user interface
- **Log format serialization**: Log structure is an observable product feature

Counter-examples (keep as private functions):
- Helper functions for string manipulation
- Internal cache eviction algorithms
- Temporary data structure transformations

### Example: Database Page Marshalling

**Before - Monolithic package:**

```go
package db

type DB struct {
    file *os.File
}

// Tightly coupled to DB internals
func (db *DB) writePage(page *page) error {
    data := marshalPage(page) // Private function
    return db.file.Write(data)
}

func marshalPage(p *page) []byte {
    // Complex marshalling logic
}

func unmarshalPage(data []byte) (*page, error) {
    // Complex unmarshalling logic
}

// Can't test marshalling without testing entire DB
```

**After - Extracted internal package:**

```go
// internal/pageformat/format.go
package pageformat

// Marshal converts a Page into wire format
func Marshal(p *Page) ([]byte, error) {
    // Complex marshalling logic
}

// Unmarshal converts wire format into a Page
func Unmarshal(data []byte) (*Page, error) {
    // Complex unmarshalling logic
}
```

```go
// internal/pageformat/format_test.go
package pageformat_test

import (
    "testing"
    "yourproject/internal/pageformat"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestMarshalUnmarshal(t *testing.T) {
    for _, test := range []struct {
        name string
        page *pageformat.Page
    }{
        {
            name: "empty page",
            page: &pageformat.Page{ID: 1, Data: nil},
        },
        {
            name: "page with data",
            page: &pageformat.Page{ID: 42, Data: []byte("content")},
        },
    } {
        t.Run(test.name, func(t *testing.T) {
            data, err := pageformat.Marshal(test.page)
            require.NoError(t, err)

            result, err := pageformat.Unmarshal(data)
            require.NoError(t, err)
            assert.Equal(t, test.page, result)
        })
    }
}

func TestUnmarshalInvalidData(t *testing.T) {
    for _, test := range []struct {
        name    string
        data    []byte
        wantErr string
    }{
        {
            name:    "empty data",
            data:    []byte{},
            wantErr: "insufficient data",
        },
        {
            name:    "corrupt header",
            data:    []byte{0xFF, 0xFF, 0xFF},
            wantErr: "invalid header",
        },
    } {
        t.Run(test.name, func(t *testing.T) {
            _, err := pageformat.Unmarshal(test.data)
            require.ErrorContains(t, err, test.wantErr)
        })
    }
}
```

```go
// db.go - now uses the extracted package
package db

import "yourproject/internal/pageformat"

type DB struct {
    file *os.File
}

func (db *DB) writePage(page *pageformat.Page) error {
    data, err := pageformat.Marshal(page)
    if err != nil {
        return err
    }
    return db.file.Write(data)
}
```

### Benefits of Extraction

1. **Testable Boundaries**: Complex logic gets its own focused test suite
2. **Clear Interfaces**: Package boundaries force explicit API design
3. **Tight Coupling, Loose Organization**: Code remains tightly coupled (it should be) but with clean separation
4. **Reusability**: Other parts of the system can use the same package
5. **Easier Reasoning**: Each package has a single, well-defined responsibility

### Testing Internal Packages

**Apply the same functional testing principles:**
- Tests in `package XXX_test` to enforce public interface testing
- Test the exported functions only
- No access to internal package details
- Comprehensive coverage of the public API surface

The fact that it's an `internal/` package doesn't change testing strategy - you still test the public interface of that package.

### When NOT to Extract

Don't extract packages for:
- **Simple helpers**: Pure utility functions without domain meaning
- **Implementation details**: Truly private algorithms that aren't part of product contract
- **Premature abstraction**: Wait until the domain boundary is clear

If internal code doesn't represent a distinct problem domain that users depend on (even implicitly), keep it as private functions.

## Key Principles

1. **Test Behavior, Not Implementation**: Tests should verify what the system does, not how it does it
2. **Tests Are End-Users**: If a test needs to call internal functions, the code structure is wrong
3. **Unreachable Code Path**: If code cannot be tested via public interface, either remove it or expose observability
4. **Dependency Injection**: Use options structs to inject testable dependencies (stdout, http clients, etc.)
5. **Real Execution**: Tests should execute real code paths, not mocks of the main logic
6. **Package Separation**: Tests MUST be in `package XXX_test` to enforce public interface testing
7. **Problem Domain Extraction**: When internal logic represents a distinct problem domain, extract it to an internal package with testable boundaries

## When to Deviate

**Never test internal functions directly.** Instead:

- If internal logic is complex but not important: Remove or simplify it
- If internal logic is complex and important: Expose it as a public API or extract to separate package
- If internal behavior is important but implicit: Add statistics/observability APIs

## Benefits

- Tests verify actual user experience
- Refactoring internal code doesn't break tests
- Tests serve as usage examples
- Higher confidence in deployments
- Forces good API design
