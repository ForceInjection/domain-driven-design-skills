---
name: gdunit4-test-runner
description: |
  Run gdUnit4 tests for Godot projects.
  Use after implementing features, fixing bugs, or modifying GDScript files.
  USE PROACTIVELY to verify code changes.
context: fork
agent: gdunit4-test-runner
allowed-tools:
  - Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/skills/gdunit4-test-runner/scripts/ensure-environment.sh"
          once: true
---

# GDScript Test

Run GDUnit4 tests using the test wrapper script.

## When to Use

- After implementing new features
- After fixing bugs
- After modifying GDScript files
- When you need to verify test coverage
- When running CI/CD validation locally

## Test Execution

Run tests using the wrapper script included in this skill.

### Run All Tests

```bash
${CLAUDE_PLUGIN_ROOT}/skills/gdunit4-test-runner/scripts/run_test.sh
```

Scans entire project for tests.

### Run Specific Test File

```bash
${CLAUDE_PLUGIN_ROOT}/skills/gdunit4-test-runner/scripts/run_test.sh tests/test_foo.gd
```

### Run Multiple Tests

```bash
${CLAUDE_PLUGIN_ROOT}/skills/gdunit4-test-runner/scripts/run_test.sh tests/test_foo.gd tests/test_bar.gd
```

### Run Tests in Directory

```bash
${CLAUDE_PLUGIN_ROOT}/skills/gdunit4-test-runner/scripts/run_test.sh tests/application/
```

### Verbose Mode

```bash
${CLAUDE_PLUGIN_ROOT}/skills/gdunit4-test-runner/scripts/run_test.sh -v
```

Shows all Godot logs (useful for debugging test issues).

## Understanding Results

The script outputs test results in JSON format for easy parsing.

### Success
```json
{
  "summary": {
    "total": 186,
    "passed": 186,
    "failed": 0,
    "crashed": false,
    "status": "passed"
  },
  "failures": []
}
```

### Failure
```json
{
  "summary": {
    "total": 10,
    "passed": 8,
    "failed": 2,
    "crashed": false,
    "status": "failed"
  },
  "failures": [
    {
      "class": "TestClassName",
      "method": "test_method_name",
      "file": "res://tests/test_file.gd",
      "line": 42,
      "expected": "expected_value",
      "actual": "actual_value",
      "message": "FAILED: res://tests/test_file.gd:42"
    }
  ]
}
```

### Crash
```json
{
  "summary": {
    "total": 5,
    "passed": 3,
    "failed": 0,
    "crashed": true,
    "status": "crashed"
  },
  "crash_details": {
    "crash_info": "handle_crash: Program crashed with signal 11\n...",
    "script_errors": "SCRIPT ERROR: Parse Error: ...\n...",
    "engine_errors": "ERROR: Failed to load script ...\n..."
  },
  "failures": []
}
```

Godot crashed during test execution. Only tests completed before crash are reported.

The `crash_details` object includes:
- `crash_info`: Crash signal and C++ backtrace (if available)
- `script_errors`: GDScript parse errors with file paths and line numbers
- `engine_errors`: Engine-level errors (resource loading failures, etc.)

## Exit Codes

- **0**: All tests passed
- **1**: Some tests failed
- **2**: Crash or error (e.g., Godot crashed, report file not found)

## Notes

- Script automatically changes to project root before running tests
- Test reports are saved in `reports/` directory
- Uses gdUnit4 framework (configured in project.godot)
- Compatible with CI/CD environments
