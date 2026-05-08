---
name: gdUnit4 Test Runner
description: Run gdUnit4 tests for Godot projects. Use after implementing features, fixing bugs, or modifying GDScript files to verify correctness.
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

Run tests using the wrapper script included in this skill (`scripts/run_test.sh`).

### Run All Tests

```bash
scripts/run_test.sh
```

Scans entire project for tests.

### Run Specific Test File

```bash
scripts/run_test.sh tests/test_foo.gd
```

### Run Multiple Tests

```bash
scripts/run_test.sh tests/test_foo.gd tests/test_bar.gd
```

### Run Tests in Directory

```bash
scripts/run_test.sh tests/application/
```

### Verbose Mode

```bash
scripts/run_test.sh -v
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
  "failures": []
}
```

Godot crashed during test execution. Only tests completed before crash are reported.

## Exit Codes

- **0**: All tests passed
- **1**: Some tests failed
- **2**: Crash or error (e.g., Godot crashed, report file not found)

## Notes

- Script automatically changes to project root before running tests
- Test reports are saved in `reports/` directory
- Uses gdUnit4 framework (configured in project.godot)
- Compatible with CI/CD environments
