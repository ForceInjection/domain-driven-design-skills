---
name: grey-haven-test-generation
description: "Comprehensive test suite generation with unit tests, integration tests, edge cases, and error handling. Use when generating tests for existing code, improving coverage, or creating systematic test suites. Triggers: 'generate tests', 'add tests', 'test coverage', 'write tests for', 'create test suite'."
# v2.0.43: Skills to auto-load for test generation subagents
skills:
  - grey-haven-code-style
  - grey-haven-testing-strategy
# v2.0.74: Restrict tools for test generation work
allowed-tools:
  - Read
  - Write
  - MultiEdit
  - Bash
  - Grep
  - Glob
  - TodoWrite
---

# Test Generation Skill

Comprehensive test suite generation with unit tests, integration tests, edge cases, and error handling.

## Description

Automated test generation analyzing code structure and generating thorough test coverage for existing implementations.

## What's Included

- **Examples**: Unit test generation, integration tests, edge cases
- **Reference**: Test patterns, coverage strategies
- **Templates**: Test suite templates for different frameworks

## Use When

- Need test coverage for existing code
- Improving low coverage areas
- Systematic test creation

## Related Agents

- `test-generator`

**Skill Version**: 1.0
