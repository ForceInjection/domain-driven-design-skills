---
name: cui-java-unit-testing
description: CUI Java unit testing standards and patterns with JUnit 5, generators, and value object testing
allowed-tools: [Read, Edit, Write, Bash, Grep, Glob]
---

# CUI Java Unit Testing Skill

Standards and patterns for writing high-quality unit tests in CUI Java projects using JUnit 5, the CUI test generator framework, and value object contract testing.

## Workflow

### Step 1: Load Applicable Testing Standards

**CRITICAL**: Load current testing standards to use as enforcement criteria.

1. **Always load foundational testing standards**:
   ```
   Read: standards/testing-junit-core.md
   ```
   This provides core JUnit 5 patterns, AAA structure, assertion standards, and test organization that are always needed for testing.

2. **Conditional loading based on testing context**:

   **A. If project uses test data generators** (presence of `de.cuioss.test.generator` imports or `@EnableGeneratorController`):
   ```
   Read: standards/test-generator-framework.md
   ```
   Provides comprehensive generator standards including mandatory requirements, all parameterized testing annotations (@GeneratorsSource, @CompositeTypeGeneratorSource, etc.), seed restrictions, anti-patterns, and complete API reference.

   **B. If testing value objects** (classes with equals/hashCode/toString or annotated with @Value, @Data):
   ```
   Read: standards/testing-value-objects.md
   ```
   Provides comprehensive contract testing standards using `ShouldHandleObjectContracts<T>` interface and proper generator integration.

   **C. If testing HTTP clients or APIs** (testing code that makes HTTP requests):
   ```
   Read: standards/testing-mockwebserver.md
   ```
   Provides MockWebServer setup patterns, response mocking, request verification, retry logic testing, and HTTP status code handling.

   **D. If writing integration tests** (tests that interact with multiple components or external systems):
   ```
   Read: standards/integration-testing.md
   ```
   Covers Maven surefire/failsafe configuration, integration test naming conventions (*IT.java), profile setup, and CI/CD integration.

   **E. If testing applications that use Java Util Logging (JUL)** (testing code that uses `java.util.logging` or needs to assert log output):
   ```
   Read: standards/testing-juli-logger.md
   ```
   Provides patterns for configuring test loggers with `@EnableTestLogger`, asserting log statements with `LogAsserts`, and dynamically changing log levels in tests.

   **F. If focusing on test quality or reviewing existing tests** (improving test quality, eliminating AI-generated artifacts, or ensuring compliance):
   ```
   Read: standards/testing-quality-standards.md
   ```
   Provides quality best practices including AI-generated code detection, parameterized test guidelines, assertion message standards, SonarQube compliance, library migration guidelines, and coverage requirements.

3. **Extract key requirements from all loaded standards**

4. **Store in working memory** for use during task execution

### Step 2: Analyze Existing Tests (if applicable)

If working with existing tests:

1. **Identify current test structure**:
   - Check test class organization and naming
   - Review test method structure (AAA pattern compliance)
   - Examine assertion usage and messages
   - Identify parameterized test opportunities

2. **Assess CUI framework compliance**:
   - Verify `@EnableGeneratorController` usage where needed
   - Check for prohibited libraries (Mockito, Hamcrest, PowerMock)
   - Validate generator usage for all test data
   - Confirm value object contract testing where applicable

3. **Review test quality**:
   - Check assertion message quality (meaningful, concise)
   - Verify test independence and isolation
   - Assess test naming and @DisplayName usage
   - Identify potential test consolidation opportunities
   - Detect AI-generated code artifacts (see testing-quality-standards.md for indicators)

### Step 3: Write/Modify Tests According to Standards

When writing or modifying tests:

1. **Apply core JUnit 5 standards**:
   - Use AAA pattern (Arrange-Act-Assert)
   - Include meaningful assertion messages (20-60 characters)
   - Use @DisplayName for readable test descriptions
   - Follow test independence principles
   - Apply proper exception testing with assertThrows

2. **Use CUI test generator for all data** (if applicable):
   - Add @EnableGeneratorController to test classes
   - Replace manual data creation with Generators.* calls
   - Use @GeneratorsSource for parameterized tests (3+ similar variants)
   - Never commit @GeneratorSeed annotations (debugging only)
   - Combine generators for complex object creation

3. **Implement value object contract testing** (if applicable):
   - Apply ShouldHandleObjectContracts<T> interface
   - Implement getUnderTest() using generators
   - Verify equals/hashCode/toString contracts
   - Separate contract tests from business logic tests

4. **Configure HTTP mocking** (if applicable):
   - Use @EnableMockWebServer annotation
   - Enqueue mock responses before requests
   - Verify request headers, body, and parameters
   - Test various status codes and error scenarios
   - Combine with generators for comprehensive testing

5. **Set up integration tests** (if applicable):
   - Name tests with *IT.java or *ITCase.java suffix
   - Configure Maven failsafe plugin
   - Create integration-tests profile
   - Ensure proper test separation

### Step 4: Verify Test Quality

Before completing the task:

1. **Verify standards compliance**:
   - [ ] All tests follow AAA pattern
   - [ ] All assertions have meaningful messages
   - [ ] Test independence verified (tests don't depend on each other)
   - [ ] Proper @DisplayName usage
   - [ ] No prohibited libraries used

2. **Verify CUI framework usage** (if applicable):
   - [ ] @EnableGeneratorController present where needed
   - [ ] All test data uses Generators.* (no manual creation)
   - [ ] No @GeneratorSeed annotations committed
   - [ ] Value object contracts implemented correctly
   - [ ] MockWebServer setup follows patterns

3. **Run tests and verify success**:
   ```
   # Run unit tests
   Task:
     subagent_type: maven-builder
     description: Run unit tests
     prompt: |
       Execute unit tests only.

       Parameters:
       - command: clean test

       CRITICAL: Wait for tests to complete. Inspect results and fix any failures.

   # Run integration tests (if applicable)
   Task:
     subagent_type: maven-builder
     description: Run integration tests
     prompt: |
       Execute integration tests with the integration-tests profile.

       Parameters:
       - command: clean verify -Pintegration-tests

       CRITICAL: Wait for tests to complete. Inspect results and fix any failures.

   # Verify coverage
   Task:
     subagent_type: maven-builder
     description: Verify test coverage
     prompt: |
       Execute tests with coverage analysis using the coverage profile.

       Parameters:
       - command: clean verify -Pcoverage

       CRITICAL: Wait for build to complete. Inspect coverage results and ensure
       minimum 80% line/branch coverage is met. Address any coverage gaps.
   ```

4. **Check coverage requirements**:
   - Minimum 80% line coverage
   - Minimum 80% branch coverage
   - Critical paths have 100% coverage
   - All public APIs tested

### Step 5: Report Results

Provide summary of:

1. **Tests created/modified**: List test classes and methods
2. **Standards applied**: Which standards were followed
3. **Framework features used**: Generators, value object contracts, MockWebServer, etc.
4. **Coverage metrics**: Current coverage percentages
5. **Any deviations**: Document and justify any standard deviations

## Quality Verification

### Test Execution Checklist

- [ ] All new/modified tests pass
- [ ] Tests are independent (can run in any order)
- [ ] No flaky tests (consistent results)
- [ ] Fast execution (unit tests < 1 second each)
- [ ] Proper cleanup in @AfterEach if needed

### Code Quality Checklist

- [ ] No hardcoded test data (use generators)
- [ ] No prohibited testing libraries
- [ ] Assertion messages are meaningful and concise
- [ ] Test names clearly describe behavior
- [ ] No commented-out code
- [ ] No @GeneratorSeed annotations

### Coverage Verification

- [ ] Run coverage profile using maven-builder agent with -Pcoverage
- [ ] Coverage meets minimum requirements (80% line/branch)
- [ ] Critical paths have 100% coverage
- [ ] No coverage regressions from previous state

## Common Patterns and Examples

### Basic Unit Test Pattern

```java
@EnableGeneratorController
@DisplayName("Token Validator Tests")
class TokenValidatorTest {

    @Test
    @DisplayName("Should validate token with correct issuer")
    void shouldValidateTokenWithCorrectIssuer() {
        // Arrange
        String issuer = Generators.strings().next();
        Token token = createTokenWithIssuer(issuer);
        TokenValidator validator = new TokenValidator(issuer);

        // Act
        ValidationResult result = validator.validate(token);

        // Assert
        assertTrue(result.isValid(), "Token with correct issuer should be valid");
    }
}
```

### Value Object Contract Test Pattern

```java
@EnableGeneratorController
class UserDataTest implements ShouldHandleObjectContracts<UserData> {

    @Override
    public UserData getUnderTest() {
        return UserData.builder()
            .username(Generators.strings().next())
            .email(Generators.emailAddress().next())
            .age(Generators.integers(18, 100).next())
            .build();
    }
}
```

### Parameterized Test Pattern

```java
@EnableGeneratorController
class ParameterizedValidationTest {

    @ParameterizedTest
    @DisplayName("Should validate various email formats")
    @GeneratorsSource(generator = GeneratorType.DOMAIN_EMAIL, count = 5)
    void shouldValidateEmailFormats(String email) {
        assertTrue(validator.isValidEmail(email),
            "Generated email should be valid");
    }
}
```

### HTTP Testing Pattern

```java
@EnableMockWebServer
@EnableGeneratorController
class HttpClientTest {

    @InjectMockWebServer
    private MockWebServerHolder serverHolder;

    @Test
    @DisplayName("Should successfully fetch user data")
    void shouldFetchUserData() throws Exception {
        // Arrange
        String userName = Generators.strings().next();
        serverHolder.enqueue(new MockResponse()
            .setResponseCode(200)
            .setBody(String.format("{\"name\": \"%s\"}", userName)));

        // Act
        User user = client.getUser(serverHolder.getBaseUrl(), 1);

        // Assert
        assertNotNull(user, "Response should not be null");
        assertEquals(userName, user.getName(), "User name should match");
    }
}
```

## Error Handling

If encountering issues:

1. **Test failures**: Review assertion messages and debug failing tests
2. **Coverage gaps**: Identify untested code paths and add tests
3. **Framework errors**: Verify @EnableGeneratorController and dependencies
4. **Maven build issues**: Check surefire/failsafe configuration
5. **Integration test problems**: Verify profile configuration and naming conventions

## References

* Core Testing Standards: standards/testing-junit-core.md
* Value Object Testing: standards/testing-value-objects.md
* Generator Usage: standards/testing-generators.md
* MockWebServer Testing: standards/testing-mockwebserver.md
* Integration Testing: standards/integration-testing.md
* JULi Logger Testing: standards/testing-juli-logger.md
