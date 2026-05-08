---
name: phpunit-fixer
description: |
  Analyze existing PHPUnit test failure logs without running tests. Use when:
  - User says "fix the test failures" (after manually running tests)
  - User says "what tests are failing?"
  - User points to specific log file
  - Tests were run outside Claude's context
  Delegates to fixer agent (sonnet) to find logs, parse failures, and implement fixes.
  Does NOT execute tests - use phpunit-runner for that.
allowed-tools: Task
---

# PHPUnit Fixer Skill

This skill analyzes EXISTING PHPUnit test failure logs and implements fixes. It does NOT run tests.

## Agent Delegation Strategy

This skill delegates to the php-qa-ci_phpunit-fixer agent (sonnet model).

## Workflow

### When User Says: "Fix the test failures"

1. Launch fixer agent:
   ```
   Use Task tool:
     description: "Fix PHPUnit test failures"
     subagent_type: "php-qa-ci_phpunit-fixer"
     prompt: "Find and fix failures in most recent test log"
   ```

2. Receive fixer output with:
   - Errors found and grouped by pattern
   - Fixes applied
   - Files modified

3. If no log found:
   - Suggest using phpunit-runner skill to generate log first

### When User Provides Specific Log Path

1. Launch fixer agent with explicit log path:
   ```
   Use Task tool:
     description: "Fix test failures from log"
     subagent_type: "php-qa-ci_phpunit-fixer"
     prompt: "Fix failures in log: {user_provided_path}"
   ```

### Escalation Triggers

Launch opus model or ask human when:
- Fixer agent reports business logic questions (test vs code expectations)
- Same error pattern persists after 2 fix attempts
- User asks for explanation rather than fixes

## Fixer Agent Reference

The phpunit-fixer agent (sonnet model) handles:
- Auto-discovery of most recent JUnit XML log
- Error parsing and pattern grouping
- Fix implementation for common patterns
- Reporting which files were changed

See `.claude/agents/php-qa-ci_phpunit-fixer.md` for agent implementation details.

## When to Use This Skill vs phpunit-runner

- **Use phpunit-fixer** when:
  - Tests were already run manually
  - You have a specific log file to analyze
  - You only want to analyze/fix, not run tests

- **Use phpunit-runner** when:
  - You want to run tests AND fix failures
  - You want the full run→fix→run cycle
  - Tests haven't been run yet
