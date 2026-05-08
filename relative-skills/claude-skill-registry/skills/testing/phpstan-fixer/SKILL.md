---
name: phpstan-fixer
description: |
  Analyze existing PHPStan error logs without running analysis. Use when:
  - User says "fix the phpstan errors" (after manually running PHPStan)
  - User says "what phpstan errors do I have?"
  - User points to specific log file
  - PHPStan was run outside Claude's context
  Delegates to fixer agent (sonnet) to find logs, parse errors, and implement fixes.
  Does NOT execute PHPStan - use phpstan-runner for that.
allowed-tools: Task
---

# PHPStan Fixer Skill

This skill analyzes EXISTING PHPStan error logs and implements fixes. It does NOT run PHPStan.

## Agent Delegation Strategy

This skill delegates to the php-qa-ci_phpstan-fixer agent (sonnet model).

## Workflow

### When User Says: "Fix the PHPStan errors"

1. Launch fixer agent:
   ```
   Use Task tool:
     description: "Fix PHPStan errors"
     subagent_type: "php-qa-ci_phpstan-fixer"
     prompt: "Find and fix errors in most recent PHPStan log"
   ```

2. Receive fixer output with:
   - Errors found and grouped by pattern
   - Fixes applied
   - Files modified

3. If no log found:
   - Suggest using phpstan-runner skill to generate log first

### When User Provides Specific Log Path

1. Launch fixer agent with explicit log path:
   ```
   Use Task tool:
     description: "Fix PHPStan errors from log"
     subagent_type: "php-qa-ci_phpstan-fixer"
     prompt: "Fix errors in log: {user_provided_path}"
   ```

### Escalation Triggers

Launch opus model or ask human when:
- Fixer agent reports architecture questions (type hierarchies, design patterns)
- Same error pattern persists after 2 fix attempts
- User asks for explanation rather than fixes

## Fixer Agent Reference

The phpstan-fixer agent (sonnet model) handles:
- Auto-discovery of most recent PHPStan log
- Error parsing and pattern grouping
- Fix implementation for common PHPStan patterns
- Reporting which files were changed

See `.claude/agents/php-qa-ci_phpstan-fixer.md` for agent implementation details.

## When to Use This Skill vs phpstan-runner

- **Use phpstan-fixer** when:
  - PHPStan was already run manually
  - You have a specific log file to analyze
  - You only want to analyze/fix, not run analysis

- **Use phpstan-runner** when:
  - You want to run PHPStan AND fix errors
  - You want the full run→fix→run cycle
  - PHPStan hasn't been run yet
