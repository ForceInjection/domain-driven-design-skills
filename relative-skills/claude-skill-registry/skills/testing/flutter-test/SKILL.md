---
name: flutter-test
description: Run Flutter tests and analyze results. Use when implementing game logic, fixing bugs, or validating changes. Triggers on "run tests", "test this", "verify", "check if it works".
allowed-tools: Bash, Read, Grep, Glob
---

# Flutter Test Runner

## Instructions

1. Identify which tests to run:
   - If a specific file was modified, run tests for that file/module
   - If unsure, run all tests with `flutter test`
   - For a single test file: `flutter test test/path/to/test_file.dart`

2. Run the tests:
   ```bash
   flutter test --reporter=expanded
   ```

3. Analyze failures:
   - Read the error messages carefully
   - Identify the root cause (logic error, missing mock, incorrect expectation)
   - Suggest specific fixes

4. For coverage analysis:
   ```bash
   flutter test --coverage
   ```

## Examples

**Run all tests:**
```bash
flutter test
```

**Run specific test file:**
```bash
flutter test test/models/unit_test.dart
```

**Run tests matching a pattern:**
```bash
flutter test --name "combat"
```
