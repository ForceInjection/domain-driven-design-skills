---
name: testing-procedures
description: Testing procedures for Kalahari project. Use for running tests and analyzing results.
---

# Testing Procedures

## 1. Build Commands

### Windows
```bash
scripts/build_windows.bat Debug
```

### Linux
```bash
scripts/build_linux.sh
```

### NEVER
- Run cmake directly
- Use WSL for Windows builds

## 2. Test Execution

### Windows
```bash
./build-windows/bin/kalahari-tests.exe
```

### Linux
```bash
./build-linux/bin/kalahari-tests
```

## 3. Test Framework

- Framework: Catch2 v3
- Style: BDD (Behavior-Driven Development)
- Location: `tests/`

## 4. Result Interpretation

### Output format
```
[PASS] TestName
[FAIL] TestName - expected X, got Y
```

### Summary
```
===============================================
All tests passed (42 assertions in 15 test cases)
```
or
```
===============================================
test cases: 15 | 14 passed | 1 failed
assertions: 42 | 40 passed | 2 failed
```

## 5. What to Check

### After implementation
- [ ] All existing tests still pass?
- [ ] No regressions (previously passing tests)?
- [ ] New tests added for new functionality?

### Test coverage
- [ ] Core business logic tested?
- [ ] Edge cases covered?
- [ ] Error handling tested?

## 6. Manual Testing

### When needed
- UI changes (visual verification)
- User interaction flows
- Theme switching
- Panel resizing/docking

### Steps
1. Run application: `./build-windows/bin/kalahari.exe`
2. Test the specific feature
3. Verify visual appearance
4. Check responsiveness

## 7. Reporting Results

### Pass
```json
{
  "decision": "pass",
  "tests": "42/42 passed",
  "summary": "All tests pass"
}
```

### Fail
```json
{
  "decision": "fail",
  "tests": "40/42 passed",
  "failures": [
    "TestSettings::save - expected true, got false",
    "TestDocument::load - file not found"
  ],
  "summary": "2 tests failed"
}
```

## 8. Common Issues

### Build fails
1. Check CMake output for errors
2. Verify vcpkg dependencies
3. Check for missing includes

### Tests fail
1. Read failure message carefully
2. Check if test assumptions still valid
3. Verify test data/fixtures

### Flaky tests
1. Check for timing dependencies
2. Look for shared state between tests
3. Verify test isolation
