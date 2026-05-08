---
name: golang-testing
description: GoLang testing guidelines
---

# Golang Testing

## Instructions

When writing Go tests, always use table-driven test format.

## Structure

```go
func TestFunctionName(t *testing.T) {
	tests := []struct {
		name     string
		input    inputType
		expected expectedType
		wantErr  bool
	}{
		{
			name:     "description of test case",
			input:    inputValue,
			expected: expectedValue,
			wantErr:  false,
		},
		// additional test cases...
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// test implementation
		})
	}
}
```

## When to Use

Apply this format when:
- Writing new Go tests
- Refactoring existing Go tests
- Adding test cases to existing tests
