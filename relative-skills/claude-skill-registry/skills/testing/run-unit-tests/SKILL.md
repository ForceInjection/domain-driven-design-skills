---
name: run-unit-tests
description: Provides instructions to run the unit tests for project in a consistent and cost efficient way
---

# Run Unit Tests

We provide a wrapper script around Gradle that provides concise, token-efficient output for test execution. This is especially useful for AI agents running tests.

**Usage:**
```bash
# Run all tests in the project
./bin/run_tests.main.kts

# Run tests for a specific module
./bin/run_tests.main.kts -m persistence

# Run a specific test
./bin/run_tests.main.kts -t "MongoDBSaveGameRepositoryTest.should save and retrieve a save game"
```

**Output Behavior:**
- **Success (exit 0)**: Prints `✓ All tests passed successfully`
- **Compilation Error (exit 1)**: Shows full Gradle output with compilation error details
- **Test Failure (exit 1)**: Shows concise failure information:
    - Test class and method name
    - Failure message (truncated if too long)
    - Relevant stack trace lines (framework noise filtered out)

**Example Success:**
```
✓ All tests passed successfully
```

**Example Test Failure:**
```
✗ Build/tests failed

Failed Tests (1):

1. io.dungeons.persistence.mongodb.MongoDBSaveGameRepositoryTest.should save and retrieve a save game()
   Message: expected: <wrong-id> but was: <Id(value=a5638bd6-0aa8-474b-8b92-8bc859be044e)>
   Stack trace:
     org.opentest4j.AssertionFailedError: expected: <wrong-id> but was: <Id(value=a5638bd6...)>
     at kotlin.test.junit5.JUnit5Asserter.assertEquals(JUnitSupport.kt:32)
     at kotlin.test.AssertionsKt__AssertionsKt.assertEquals(Assertions.kt:63)
```

**Example Compilation Error:**
```
✗ Build/tests failed

Compilation error detected. Gradle output:

> Task :persistence:compileTestKotlin FAILED
e: file:///.../MongoDBSaveGameRepositoryTest.kt:14:18 Unresolved reference 'undefinedVariable'.

FAILURE: Build failed with an exception.
...
```