---
name: go-performance
description: Go performance optimization - profiling, benchmarks, memory management
sasmp_version: "1.3.0"
bonded_agent: 02-go-concurrency
bond_type: SECONDARY_BOND
---

# Go Performance Skill

Optimize Go application performance with profiling and best practices.

## Overview

Comprehensive performance optimization including CPU/memory profiling, benchmarking, and common optimization patterns.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| profile_type | string | yes | - | Type: "cpu", "memory", "goroutine", "block" |
| duration | string | no | "30s" | Profile duration |

## Core Topics

### pprof Setup
```go
import (
    "net/http"
    _ "net/http/pprof"
)

func main() {
    // Start pprof server
    go func() {
        http.ListenAndServe("localhost:6060", nil)
    }()

    // Your application
    runApp()
}
```

### CPU Profiling
```bash
# Collect 30s CPU profile
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# Interactive commands
(pprof) top 10          # Top 10 CPU consumers
(pprof) list funcName   # Source view
(pprof) web             # Open in browser
(pprof) svg > cpu.svg   # Export SVG
```

### Memory Profiling
```bash
# Heap profile
go tool pprof http://localhost:6060/debug/pprof/heap

# Allocs since start
go tool pprof http://localhost:6060/debug/pprof/allocs

(pprof) top --cum       # By cumulative allocations
(pprof) list funcName   # Where allocations happen
```

### Benchmarking
```go
func BenchmarkProcess(b *testing.B) {
    data := setupData()

    b.ResetTimer()
    b.ReportAllocs()

    for i := 0; i < b.N; i++ {
        Process(data)
    }
}

func BenchmarkProcess_Parallel(b *testing.B) {
    data := setupData()

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            Process(data)
        }
    })
}
```

```bash
# Run benchmarks
go test -bench=. -benchmem ./...

# Compare benchmarks
go test -bench=. -count=5 > old.txt
# make changes
go test -bench=. -count=5 > new.txt
benchstat old.txt new.txt
```

### Memory Optimization
```go
// Preallocate slices
func ProcessItems(items []Item) []Result {
    results := make([]Result, 0, len(items)) // Preallocate
    for _, item := range items {
        results = append(results, process(item))
    }
    return results
}

// Use sync.Pool for frequent allocations
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func GetBuffer() *bytes.Buffer {
    buf := bufferPool.Get().(*bytes.Buffer)
    buf.Reset()
    return buf
}

func PutBuffer(buf *bytes.Buffer) {
    bufferPool.Put(buf)
}
```

### Escape Analysis
```bash
# Check what escapes to heap
go build -gcflags="-m -m" ./...

# Common escapes
# - Returning pointers to local variables
# - Storing in interface{}
# - Closures capturing variables
```

### Optimization Patterns
```go
// String building - use strings.Builder
var b strings.Builder
for _, s := range parts {
    b.WriteString(s)
}
result := b.String()

// Avoid interface{} in hot paths
// Use generics or concrete types

// Reduce allocations in loops
buffer := make([]byte, 1024)
for {
    n, err := reader.Read(buffer)
    // reuse buffer
}
```

## Profiling Commands

```bash
# Goroutine profile (leak detection)
go tool pprof http://localhost:6060/debug/pprof/goroutine

# Block profile (contention)
go tool pprof http://localhost:6060/debug/pprof/block

# Mutex profile
go tool pprof http://localhost:6060/debug/pprof/mutex

# Trace (detailed execution)
curl -o trace.out http://localhost:6060/debug/pprof/trace?seconds=5
go tool trace trace.out
```

## Troubleshooting

### Failure Modes
| Symptom | Cause | Fix |
|---------|-------|-----|
| High CPU | Hot loop, GC | Profile, reduce allocs |
| High memory | Leak, no pooling | Heap profile, sync.Pool |
| Slow start | Large init | Lazy initialization |
| GC pauses | Many allocations | Reduce allocations |

## Usage

```
Skill("go-performance")
```
