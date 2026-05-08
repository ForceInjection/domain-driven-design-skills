---
name: go-testing-table
description: Table-driven test patterns for Go
---

# Table-Driven Tests

Use when you have 2+ test cases for the same function.

## CORRECT

```go
func Test_Add_Cases(t *testing.T) {
    tests := []struct {
        name string
        a    int
        b    int
        want int
    }{
        {name: "positive numbers", a: 2, b: 3, want: 5},
        {name: "negative numbers", a: -1, b: -2, want: -3},
        {name: "zero", a: 0, b: 0, want: 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

**Why:**
- Single loop handles all cases
- Easy to add new cases
- Named cases for clear failure messages
- Each case runs as subtest

## WRONG

```go
func Test_Add(t *testing.T) {
    if Add(2, 3) != 5 {
        t.Error("2 + 3 failed")
    }
    if Add(-1, -2) != -3 {
        t.Error("-1 + -2 failed")
    }
    if Add(0, 0) != 0 {
        t.Error("0 + 0 failed")
    }
}
```

**Problems:**
- Repetitive code
- First failure stops remaining tests
- Hard to add new cases
- No case names in output
