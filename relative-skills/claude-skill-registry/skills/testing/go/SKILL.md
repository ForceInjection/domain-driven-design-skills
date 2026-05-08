---
name: Go
description: Go language coding standards, best practices, and testing patterns. Use when writing or reviewing Go code, implementing tests, or discussing Go language features.
---
# Go

- Use the latest Go language features within the version given in `go.mod`.

## Tests

Write table-style tests:

```go
func TestMyFunction(t *testing.T) {
  for _, tc := range []struct {
    name     string
    input    string
    expected string
  }{
    {
      name:     "case1",
      input:    "input1",
      expected: "expected1",
    },
    {
      name:     "case2",
      input:    "input2",
      expected: "expected2",
    },
  } {
    t.Run(tc.name, func(t *testing.T) {
      if result := MyFunction(tc.input); result != tc.expected {
        t.Errorf("expected %s, got %s", tc.expected, result)
      }
    })
  }
}
```

- Include a `name` field in test cases. Use space-delimited words.
- Never use test names to control test behavior.
