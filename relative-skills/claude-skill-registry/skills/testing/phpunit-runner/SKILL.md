---
name: phpunit-runner
description: |
  Run PHPUnit tests and fix failures using intelligent agent delegation. Use when user requests to:
  - Run tests (full suite, specific path, or single file)
  - Fix failing tests
  - Analyze test failures
  - Check test coverage
  Delegates to runner agent (haiku) for execution and fixer agent (sonnet) for fixes.
  Automatically cycles between run and fix until tests pass or human intervention needed.
allowed-tools: Task
---

# PHPUnit Runner Skill

This skill provides intelligent PHPUnit test execution and fixing through specialized agent delegation.

## Agent Delegation Strategy

This skill delegates to specialized agents via the Task tool:

1. **php-qa-ci_phpunit-runner agent (haiku model)** - Runs tests and parses results
2. **php-qa-ci_phpunit-fixer agent (sonnet model)** - Analyzes and fixes errors
3. **Escalation** - Uses opus model or asks human for stubborn issues

## Workflow

### When User Says: "Run tests"

1. Launch runner agent:
   ```
   Use Task tool:
     description: "Run PHPUnit test suite"
     subagent_type: "php-qa-ci_phpunit-runner"
     prompt: "Run PHPUnit tests and provide summary"
   ```

2. Receive runner output with log location

3. If failures detected:
   - Launch fixer agent:
     ```
     Use Task tool:
       description: "Fix PHPUnit test failures"
       subagent_type: "php-qa-ci_phpunit-fixer"
       prompt: "Fix test failures in log: {log_path}"
     ```

4. After fixes applied, re-run via runner agent

5. Repeat cycle until:
   - All tests pass → Success
   - Same errors persist 2+ times → Escalate to opus or human
   - User intervention needed → Ask user

### When User Says: "Fix the test failures"

1. Check if recent log exists in var/qa/phpunit_logs/

2. If log found:
   - Launch fixer agent directly with log path

3. If no log:
   - Launch runner agent first to generate log
   - Then launch fixer agent

### Escalation Triggers

Launch opus model or ask human when:
- Fixer agent reports "cannot fix" for same error 2+ times
- Business logic questions arise (test expectations vs code behavior)
- User explicitly requests explanation of failures

## Runner Agent Reference

The phpunit-runner agent (haiku model) handles:
- Runtime estimation (refuses full suite if >5min)
- Test execution with proper CI environment
- JUnit XML parsing
- Concise summary generation

See `.claude/agents/php-qa-ci_phpunit-runner.md` for agent implementation details.

## Fixer Agent Reference

The phpunit-fixer agent (sonnet model) handles:
- Log file discovery and parsing
- Error grouping by pattern
- Fix implementation
- Verification that fixes resolve issues

See `.claude/agents/php-qa-ci_phpunit-fixer.md` for agent implementation details.
