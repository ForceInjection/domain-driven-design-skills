---
name: GDScript Test
description: Run GDUnit4 tests for Godot projects. Use after implementing features, fixing bugs, or modifying GDScript files to verify correctness.
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

### Run All Tests

```bash
.claude/skills/gdscript-test-skill/scripts/run_test.sh
```

Runs all tests in `tests/` directory with suppressed Godot logs (only shows failures).

### Run Specific Test File

```bash
.claude/skills/gdscript-test-skill/scripts/run_test.sh tests/test_foo.gd
```

### Run Multiple Tests

```bash
.claude/skills/gdscript-test-skill/scripts/run_test.sh tests/test_foo.gd tests/test_bar.gd
```

### Run Tests in Directory

```bash
.claude/skills/gdscript-test-skill/scripts/run_test.sh tests/application/
```

### Verbose Mode

```bash
.claude/skills/gdscript-test-skill/scripts/run_test.sh -v
```

Shows all Godot logs (useful for debugging test issues).

## Understanding Results

### Success
```
=================================================
ALL TESTS PASSED (X tests)
=================================================
```

### Failure
```
=================================================
TEST FAILURES (X of Y tests failed)
=================================================

[1] TestClassName :: test_method_name
    File: tests/test_file.gd:42
    Expected: 'expected_value'
    Actual:   'actual_value'
```

## Exit Codes

- **0**: All tests passed
- **1**: Some tests failed
- **2**: Error (e.g., report file not found)

## Notes

- Script automatically changes to project root before running tests
- Test reports are saved in `reports/` directory
- Uses gdUnit4 framework (configured in project.godot)
- Compatible with CI/CD environments
