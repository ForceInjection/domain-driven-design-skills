---
name: makefile
description: Generate standard Makefile for Go projects with test, lint, clean, fmt, tidy, ci, and coverage targets following best practices
---

# Generate Standard Makefile

Generate a Makefile with standard targets for Go projects.

## Required Targets

1. **test**: Run `go test -v ./...` to execute all tests
2. **lint**: Run `golangci-lint run ./...` for linting
3. **clean**: Run `go clean` and remove coverage files (coverage.out, coverage.html)
4. **fmt**: Run `go fmt ./...` and verify no changes with `git diff --exit-code`
5. **tidy**: Run `go mod tidy` and verify no changes with `git diff --exit-code`
6. **ci**: Run all checks (tidy, fmt, lint, test) and display success message
7. **coverage**: Generate coverage report and HTML output

## Format Requirements

- Use `.PHONY` declaration for all targets
- Each command should use tab indentation
- The `ci` target should display a green success message: "EVERYTHING PASSED!"
- Coverage target should output the location of the HTML report

## Template

```makefile
.PHONY: test lint clean fmt tidy ci coverage

test:
	go test -v ./...

lint:
	golangci-lint run ./...

clean:
	go clean
	rm -f coverage.out coverage.html

fmt:
	go fmt ./... && git diff --exit-code

tidy:
	go mod tidy && git diff --exit-code

ci: tidy fmt lint test
	@echo
	@echo "\033[32mEVERYTHING PASSED!\033[0m"

coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"
```

Create this Makefile at the root of the project. If the project needs additional targets (like `proto` for protocol buffers), ask the user first.
