---
name: testing-guidelines
description: >-
  Pytest testing patterns, fixtures, mocking, and coverage for GMailArchiver.
  Use when writing unit tests, integration tests, creating fixtures, mocking
  Gmail API, or checking coverage. Triggers on: test, pytest, fixture, mock,
  coverage, conftest, assert, unit test, integration test.
---

# Testing Guidelines for GMailArchiver

This skill provides guidance on testing practices and patterns.

## Source Documentation

**Always read the authoritative source:**

**`docs/TESTING.md`** - The definitive testing guidelines document containing:
- Test organization and structure
- Naming conventions for tests
- Fixture patterns and usage
- Mocking strategies (especially for Gmail API)
- Coverage requirements and targets
- Integration vs unit test guidelines
- Test data management

## Key Test Files

- `tests/conftest.py` - Shared fixtures and configuration
- `tests/test_*.py` - Test modules (match source structure)

## Test Commands

```bash
# Run all tests with coverage
uv run pytest

# Run specific test file
uv run pytest tests/test_module.py -v

# Run specific test function
uv run pytest tests/test_module.py::test_name -v

# Run without coverage (faster)
uv run pytest --no-cov

# Run with coverage report
uv run pytest --cov=src/gmailarchiver --cov-report=html
```

## Coverage Requirements

- Overall: 95%+ coverage
- Core modules: Higher coverage expected
- See `docs/TESTING.md` for specific targets

## Usage

When writing tests:
1. Read `docs/TESTING.md` for current testing guidelines
2. Check `tests/conftest.py` for available fixtures
3. Follow existing test patterns in similar test files
4. If guidelines change, update `docs/TESTING.md` (not this skill)

The source documentation is the **single source of truth** - this skill just points you there.
