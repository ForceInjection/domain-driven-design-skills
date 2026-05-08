---
name: just-automation-practices
description: Best practices for using just command runner and task automation in development workflows.
---

# Just automation practices

## Purpose

Guide for using the just command runner for task automation, covering recipe design, variable handling, and cross-platform development.

## When to use

This skill activates when:

- Creating Justfiles
- Writing build/test automation
- Defining development workflows
- Setting up task dependencies
- Cross-platform automation

## Core concepts

### Basic recipe

```just
# Run tests
test:
    uv run pytest

# Run with arguments
test-file file:
    uv run pytest {{file}}

# Default recipe (runs when just called without arguments)
default: lint test
```

### Recipe with dependencies

```just
# Dependencies run first
build: lint test
    uv run python -m build

# Clean before build
clean-build: clean build
```

## Variables

### Setting variables

```just
# Simple variables
python := "uv run python"
pytest := "uv run pytest"

# Using variables
test:
    {{pytest}} tests/

# Environment variables
export PYTHONPATH := "src"

test:
    {{pytest}} tests/
```

### Built-in functions

```just
# Current directory
project_dir := justfile_directory()

# Parent directory
parent := parent_directory(justfile_directory())

# Environment with default
python := env_var_or_default("PYTHON", "python3")
```

## Arguments and parameters

### Positional arguments

```just
# Required argument
test file:
    uv run pytest {{file}}

# Optional with default
test file="tests/":
    uv run pytest {{file}}

# Variadic (all remaining args)
test *args:
    uv run pytest {{args}}
```

### Named parameters

```just
# Named with defaults
build target="release" output="dist":
    echo "Building {{target}} to {{output}}"
```

## Conditionals

```just
# Conditional execution
test:
    #!/usr/bin/env bash
    if [[ -f "tests/integration" ]]; then
        uv run pytest tests/integration
    fi

# Using just's if
python := if os() == "windows" { "python" } else { "python3" }
```

## Multi-line recipes

```just
# With shebang
setup:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting up environment..."
    uv sync
    echo "Done!"

# Default shell recipes
install:
    uv sync
    echo "Dependencies installed"
```

## Common patterns

### Development workflow

```just
# Install dependencies
install:
    uv sync

# Format code
format:
    uv run ruff format .

# Lint code
lint:
    uv run ruff check .
    uv run basedpyright

# Run tests
test *args:
    uv run pytest {{args}}

# Full check before commit
check: format lint test

# Clean artifacts
clean:
    rm -rf dist/ .pytest_cache/ .coverage htmlcov/
```

### Parameterized builds

```just
# Build with options
build target="release":
    #!/usr/bin/env bash
    case "{{target}}" in
        release)
            uv run python -m build
            ;;
        dev)
            uv pip install -e .
            ;;
        *)
            echo "Unknown target: {{target}}"
            exit 1
            ;;
    esac
```

### Environment management

```just
# Set environment for recipes
set dotenv-load := true

# Use .env file
test:
    uv run pytest

# Override environment
test-ci:
    CI=true uv run pytest
```

## Cross-platform

### OS detection

```just
# Different commands per OS
open_browser := if os() == "macos" {
    "open"
} else if os() == "windows" {
    "start"
} else {
    "xdg-open"
}

docs:
    {{open_browser}} docs/_build/html/index.html
```

### Path handling

```just
# Cross-platform paths
project_dir := justfile_directory()
src_dir := project_dir / "src"
tests_dir := project_dir / "tests"
```

## Organization

### List recipes

```bash
# Show available recipes
just --list

# Show recipe with description
just --show test
```

### Documentation

```just
# Recipe descriptions appear in --list
# Run all tests with coverage
test:
    uv run pytest --cov

# Format code using ruff
format:
    uv run ruff format .
```

### Grouping with aliases

```just
# Main recipe
test-all:
    uv run pytest

# Aliases for convenience
alias t := test-all
alias tests := test-all
```

## Checklist

- [ ] Default recipe defined
- [ ] Recipes have descriptions (comments)
- [ ] Variables used for repeated values
- [ ] Dependencies properly declared
- [ ] Cross-platform compatible (if needed)
- [ ] Error handling in complex recipes

---

**Additional resources:**

- [just documentation](https://just.systems/man/en/)
