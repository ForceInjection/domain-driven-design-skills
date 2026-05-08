---
name: configuring-python-stack
description: Python stack configuration - uv, ruff, mypy, pytest with 96% coverage threshold
---

# Python Stack

## Standards Compliance

| Standard | Level | Status |
|----------|-------|--------|
| aug-just/justfile-interface | Baseline (Level 0) | ✓ Full |
| development-stack-standards | Level 2 | ✓ Complete |

**Dimensions:** 11/13 (Foundation + Quality Gates + Security)

## Toolchain

| Tool | Use |
|------|-----|
| **uv** | Package manager, venv, builds |
| **ruff** | Format + lint + import sort |
| **mypy** | Type checking (strict) |
| **pytest** | Testing framework |
| **pytest-cov** | Coverage (96% threshold) |
| **pytest-watcher** | Watch mode |
| **radon** | Complexity analysis |
| **pygount** | Lines of code |
| **pip-audit** | Security vulnerabilities |
| **pip-licenses** | License analysis |
| **cyclonedx-py** | SBOM generation |

## Stack Dimensions

| Dimension | Tool | Level |
|-----------|------|-------|
| Package manager | uv | 0 |
| Format | ruff | 0 |
| Lint | ruff | 0 |
| Typecheck | mypy | 0 |
| Test | pytest | 0 |
| Coverage | pytest-cov (96%) | 1 |
| Complexity | radon (≤10) | 1 |
| Test watch | pytest-watcher | 1 |
| LOC | pygount | 1 |
| Deps | uv pip list | 2 |
| Vulns | pip-audit | 2 |
| License | pip-licenses | 2 |
| SBOM | cyclonedx-py | 2 |

## Quick Reference

```bash
uv venv .venv && uv pip install -e ".[dev]"
uv run ruff format .
uv run ruff check --fix . --select C90 --complexity-max 10
uv run mypy src
uv run pytest -m "not integration" --durations=10
uv run pytest -m "not integration" --cov=src --cov-fail-under=96
```

## Docker Compatibility

Web services: Bind to `0.0.0.0` (not `127.0.0.1`)

```python
import os

host = os.getenv("HOST", "0.0.0.0")
port = int(os.getenv("PORT", "8000"))
```

## Standard Justfile Interface

**Implements:** aug-just/justfile-interface (Level 0 baseline)
**Requires:** aug-just plugin for justfile management

```just
set shell := ["bash", "-uc"]

# Show all available commands
default:
    @just --list

# Install dependencies and setup development environment
dev-install:
    uv venv .venv
    uv pip install -e ".[dev]"

# Format code (auto-fix)
format:
    uv run ruff format .

# Lint code (auto-fix, complexity threshold=10)
lint:
    uv run ruff check --fix . --select C90 --complexity-max 10

# Type check code
typecheck:
    uv run mypy src

# Run unit tests
test:
    uv run pytest -m "not integration" --durations=10

# Run tests in watch mode
test-watch:
    uv run pytest-watcher --now --clear . -m "not integration" -- --durations=10

# Run unit tests with coverage threshold (96%)
coverage:
    uv run pytest -m "not integration" --cov=src --cov-report=term-missing --cov-report=html --cov-fail-under=96 --durations=10

# Run integration tests with coverage report (no threshold)
integration-test:
    uv run pytest -m "integration" --cov=src --cov-report=term-missing --cov-report=html --durations=10

# Detailed complexity report for refactoring decisions
complexity:
    uv run radon cc src -a -nb

# Show N largest files by lines of code
loc N="20":
    @echo "📊 Top {{N}} largest files by LOC:"
    @uv run pygount --format=summary src/ | grep "\.py" | sort -k2 -rn | head -{{N}}

# Show outdated packages
deps:
    uv pip list --outdated

# Check for security vulnerabilities
vulns:
    uv run pip-audit

# Analyze licenses (flag GPL, etc.)
lic:
    uv run pip-licenses --summary

# Generate software bill of materials
sbom:
    uv run cyclonedx-py requirements requirements.txt -o sbom.json

# Build artifacts
build:
    uv run python -m build

# Run all quality checks (format, lint, typecheck, coverage - fastest first)
check-all: format lint typecheck coverage
    @echo "✅ All checks passed"

# Remove generated files and artifacts
clean:
    rm -rf .venv __pycache__ .pytest_cache .mypy_cache .coverage htmlcov dist build *.egg-info
    find . -type f -name "*.pyc" -delete
```

## pyproject.toml

```toml
[project]
name = "package-name"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8.0", "pytest-cov>=4.1", "pytest-watcher>=0.4",
    "mypy>=1.8", "ruff>=0.3", "radon>=6.0", "pygount>=3.1",
    "pip-audit", "pip-licenses", "cyclonedx-py", "build",
]

[tool.ruff]
line-length = 100
target-version = "py311"
select = ["E", "F", "I", "N", "UP", "B", "C90"]

[tool.ruff.mccabe]
max-complexity = 10

[tool.mypy]
strict = true
disallow_untyped_defs = true

[tool.coverage.report]
fail_under = 96

[tool.pytest.ini_options]
markers = [
    "integration: integration tests (deselect with '-m not integration')",
]
```

## Notes

- Mark integration tests: `@pytest.mark.integration`
- Unit tests (unmarked) run in check-all with 96% threshold
- `--durations=10` monitors test performance
- No docstring enforcement (no 'D' in ruff rules)
