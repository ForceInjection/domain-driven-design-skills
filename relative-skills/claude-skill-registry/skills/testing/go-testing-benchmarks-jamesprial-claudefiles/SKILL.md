---
name: go-testing-benchmarks
description: Benchmark patterns for performance testing
---

# Benchmarks

Measure function performance with benchmark tests.

## CORRECT

```go
func Benchmark_Fibonacci(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Fibonacci(10)
    }
}

func Benchmark_Fibonacci_Cases(b *testing.B) {
    cases := []struct {
        name string
        n    int
    }{
        {name: "small", n: 10},
        {name: "medium", n: 20},
        {name: "large", n: 30},
    }

    for _, bc := range cases {
        b.Run(bc.name, func(b *testing.B) {
            for i := 0; i < b.N; i++ {
                Fibonacci(bc.n)
            }
        })
    }
}

func Benchmark_StringConcat(b *testing.B) {
    b.ResetTimer()  // Exclude setup time
    for i := 0; i < b.N; i++ {
        _ = "hello" + "world"
    }
}
```

**Run benchmarks:**
```bash
go test -bench=. -benchmem
```

**Why:**
- b.N adjusted automatically for stable timing
- Sub-benchmarks compare variations
- b.ResetTimer() excludes setup
- -benchmem shows allocation stats

## WRONG

```go
func Benchmark_Fibonacci(b *testing.B) {
    Fibonacci(10)  // Missing loop
}

func Benchmark_NoReset(b *testing.B) {
    // Expensive setup
    data := generateLargeData()
    // Missing b.ResetTimer()
    for i := 0; i < b.N; i++ {
        Process(data)
    }
}
```

**Problems:**
- No b.N loop = invalid benchmark
- Setup time included in measurement
- Inaccurate performance results
