---
name: sc-test
description: Execute tests with coverage analysis and automated quality reporting. Use when running unit tests, integration tests, e2e tests, analyzing coverage, or debugging test failures.
---

# Testing & QA Skill

Test execution with coverage analysis and quality reporting.

## Quick Start

```bash
# Run all tests
/sc:test

# Unit tests with coverage
/sc:test src/components --type unit --coverage

# Watch mode with auto-fix
/sc:test --watch --fix

# Web search for testing guidance
/sc:test --linkup --query "pytest asyncio best practices"
```

## Behavioral Flow

1. **Discover** - Categorize tests using runner patterns
2. **Configure** - Set up test environment and parameters
3. **Execute** - Run tests with real-time progress tracking
4. **Analyze** - Generate coverage reports and diagnostics
5. **Report** - Provide recommendations and quality metrics

## Flags

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--type` | string | all | unit, integration, e2e, all |
| `--coverage` | bool | false | Generate coverage report |
| `--watch` | bool | false | Continuous watch mode |
| `--fix` | bool | false | Auto-fix simple failures |
| `--linkup` | bool | false | Web search for guidance |
| `--query` | string | - | Search query for LinkUp |

## Personas Activated

- **qa-specialist** - Test analysis and quality assessment

## MCP Integration

- **Rube MCP** - LinkUp web search for testing best practices

## Evidence Requirements

This skill requires evidence. You MUST:
- Show test execution output and pass/fail counts
- Reference coverage metrics when `--coverage` used
- Provide actual error messages for failures

## Test Types

### Unit Tests (`--type unit`)
- Isolated component testing
- Mock dependencies
- Fast execution

### Integration Tests (`--type integration`)
- Component interaction testing
- Database/API integration
- Service dependencies

### E2E Tests (`--type e2e`)
- Full user flow testing
- Browser automation guidance
- Cross-platform validation

## Coverage Analysis

When `--coverage` is enabled:
- Line coverage metrics
- Branch coverage metrics
- Uncovered code identification
- Coverage trend comparison

## Examples

### Targeted Unit Tests
```
/sc:test src/utils --type unit --coverage
```

### Continuous Development
```
/sc:test --watch --fix
# Real-time feedback during development
```

### Integration Suite
```
/sc:test --type integration --coverage
```

### Web Research
```
/sc:test --linkup --query "vitest react testing library patterns"
```

## Tool Coordination

- **Bash** - Test runner execution
- **Glob** - Test file discovery
- **Grep** - Result parsing, failure analysis
- **Write** - Coverage reports, test summaries
