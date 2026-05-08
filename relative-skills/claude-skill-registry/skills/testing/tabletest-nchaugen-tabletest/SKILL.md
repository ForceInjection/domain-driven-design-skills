---
name: tabletest
description: Write effective TableTest-style tests for data-driven testing in JUnit using either Java or Kotlin. The table format makes tests more readable, maintainable, and collaborative - treating test data as first-class documentation of system behaviour. Use it when testing the same logic with multiple input/output combinations, when you have 2+ similar test methods differing only in data values, when business rules involve multiple cases/examples, or when adding new test cases should be as simple as adding a table row. Use standard JUnit @Test when testing a single scenario, when test logic differs significantly between cases, when complex setup/teardown varies per test, or when mocking behaviour differs per test case. 
---

# TableTest Skill

**IMPORTANT**: This skill should be used whenever converting multiple similar @Test methods to TableTest format, or when writing new TableTest-based tests. Always invoke this skill BEFORE attempting manual implementation.


## Installation

### Maven

Add this dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>io.github.nchaugen</groupId>
    <artifactId>tabletest-junit</artifactId>
    <version>0.5.8</version>
    <scope>test</scope>
</dependency>

Check https://central.sonatype.com/artifact/io.github.nchaugen/tabletest-junit for the latest version.

### Gradle

Add this to your build.gradle:

```groovy
testImplementation 'io.github.nchaugen:tabletest-junit:0.5.8'
```

Or in build.gradle.kts:

```kotlin
testImplementation("io.github.nchaugen:tabletest-junit:0.5.8")
```

### Import Statement

```java
import io.github.nchaugen.tabletest.junit.TableTest;
```

Note: The annotation is in the .junit package, not .annotations.

## When to Use TableTest

**Use TableTest when:**
- Testing the same logic with multiple input/output combinations
- You have 2+ similar test methods differing only in data values
- Business rules involve multiple cases/examples
- Tests would benefit from tabular documentation format
- Adding new test cases should be as simple as adding a table row

**Use standard JUnit @Test when:**
- Testing a single scenario
- Test logic differs significantly between cases
- Complex setup/teardown varies per test
- Mocking behaviour differs per test case

## Basic Structure

A TableTest annotation contains a table with:
1. Header row defining column names
2. Data rows with test values
3. Optional but recommended scenario column (leftmost) describing each row

```java
@TableTest("""
    Scenario          | Input | Expected
    Basic case        | 5     | 10
    Edge case at zero | 0     | 0
    Negative number   | -3    | -6
    """)
void testDoubling(int input, int expected) {
    assertEquals(expected, input * 2);
}
```

**Key rules:**
- One parameter per data column (scenario column excluded)
- Columns map to parameters by position, not name
- Each data row generates one test invocation
- Method must be non-private, non-static, return void

## Value Formats

### Single Values
```java
@TableTest("""
    Value             | Description
    simple            | No quotes needed
    "contains | pipe" | Quotes required for special chars
    ''                | Empty string
                      | Blank cell = null (except primitives)
    """)
```

**Quoting rules:**

Quote values when they contain or start with special characters:
- Contains: `|`, `"`, or `'`
- Starts with: `[` or `{` (prevents collection syntax interpretation)

**Examples:**
```
Unquoted OK      | Needs Quotes           | Reason
abc123           | "[1,2,3]"              | starts with [
hello world      | "{a,b,c}"              | starts with {
foo              | "a|b"                  | contains |
normal text      | "say \"hello\""        | contains "
Map.of(a, b)     | "[a:1,b:2]"            | starts with [
```

**Note:** Brackets and braces *inside* a string don't require quotes - only when they *start* the value. Escape sequence handling is a Java/Kotlin language concern, not a TableTest feature.

### Collection Values
TableTest has special syntax to express collection values.

Null value (blank cell) is only supported for single values. There is no built-in way to express null values inside collection values described below.

#### Lists
```java
@TableTest("""
    Numbers   | Sum
    []        | 0
    [1]       | 1
    [1, 2, 3] | 6
    """)
void testSum(List<Integer> numbers, int sum) {
    assertEquals(sum, numbers.stream().mapToInt(Integer::intValue).sum());
}
```

#### Sets
```java
@TableTest("""
    Values       | Size
    {1, 2, 3}    | 3
    {1, 1, 2, 2} | 2
    {}           | 0
    """)
void testSetSize(Set<Integer> values, int size) {
    assertEquals(size, values.size());
}
```

#### Maps
```java
@TableTest("""
    Scores                   | Highest
    [Alice: 95, Bob: 87]     | 95
    [Charlie: 78, David: 92] | 92
    [:]                      | 0
    """)
void testHighestScore(Map<String, Integer> scores, int highest) {
    int max = scores.values().stream().mapToInt(Integer::intValue).max().orElse(0);
    assertEquals(highest, max);
}
```

#### Nested Structures
```java
@TableTest("""
    Student Grades                           | Highest
    [Alice: [95, 87, 92], Bob: [78, 85, 90]] | 95
    [Charlie: [98, 89], David: [45, 60, 70]] | 98
    """)
void testHighestGrade(Map<String, List<Integer>> grades, int highest) {
    // test implementation
}
```

## Value Conversion

TableTest automatically converts table values to parameter types.

### Built-in Conversion
Supports standard Java types via JUnit's implicit converters:
- Primitives and wrappers: `int`, `Integer`, `boolean`, etc.
- Temporal types: `LocalDate`, `LocalDateTime`, `Year`
- Common types: `String`, `Class`, `Enum`

```java
@TableTest("""
    Number | Date       | Class
    42     | 2025-01-20 | java.lang.String
    """)
void test(int number, LocalDate date, Class<?> clazz) {
    // TableTest handles conversion automatically
}
```

### Factory Methods for Custom Types
Create `public static` methods that accept one parameter and return the target type:

```java
@TableTest("""
    Date       | Days Until
    today      | 0
    tomorrow   | 1
    """)
void testDaysUntil(LocalDate date, int expected) {
    assertEquals(expected, ChronoUnit.DAYS.between(LocalDate.now(), date));
}

public static LocalDate parseLocalDate(String input) {
    return switch (input) {
        case "today" -> LocalDate.now();
        case "tomorrow" -> LocalDate.now().plusDays(1);
        default -> LocalDate.parse(input);
    };
}
```

**Factory method rules:**
- Must be `public static` in test class or `@FactorySources` class
- Must accept exactly one parameter
- Must return target type
- Only one factory method per return type per class
- TableTest searches: test class → outer classes (for @Nested) → @FactorySources classes (first match wins)

### Domain Object Conversion
Convert complex inputs to domain objects:

```java
@TableTest("""
    Purchase Dates                                   | Discount %
    [2025-01-01, 2025-01-05, 2025-01-10]             | 0
    [2025-01-01, 2025-01-03, 2025-01-05, 2025-01-07] | 5
    """)
void testFrequentTravellerDiscount(Purchases purchases, int expectedDiscount) {
    assertEquals(expectedDiscount, purchases.discountPercentage());
}

public static Purchases parsePurchases(List<LocalDate> dates) {
    return new Purchases(dates);
}
```

## Value Sets for Multiple Examples

Use set notation `{...}` to test multiple values with same expectation:

```java
@TableTest("""
    Scenario                    | Example Years      | Is Leap Year
    Not divisible by 4          | {2001, 2002, 2003} | false
    Divisible by 4              | {2004, 2008, 2012} | true
    Divisible by 100 not by 400 | {2100, 2200, 2300} | false
    Divisible by 400            | {2000, 2400, 2800} | true
    """)
void testLeapYears(Year year, boolean isLeapYear) {
    assertEquals(isLeapYear, year.isLeap());
}
```

**Value set behaviour:**
- Creates multiple test invocations (one per value in set)
- Scenario names augmented with actual value used
- Only expands when parameter type is NOT `Set<?>`
- Multiple sets in same row create cartesian product:

```java
@TableTest("""
    Scenario | a      | b      | Max sum
    Combined | {1, 2} | {3, 4} | 6
    """)
void testCartesianProduct(int a, int b, int maxSum) {
    // Creates 4 tests: (1,3), (1,4), (2,3), (2,4)
    assertTrue(a + b <= maxSum);
}
```

## Scenario Names

Always include scenario column for better documentation and clearer test failures. Use `@DisplayName` and `@Description` to customise test names and add descriptions to reports:

```java
@DisplayName("Transaction fee")
@Description("Transaction fee is calculated based on the amount, taking minimum threshold into account.")
@TableTest("""
    Scenario                | Amount | Fee
    Below minimum threshold | 50     | 0
    At minimum threshold    | 100    | 0
    Above minimum threshold | 150    | 5
    Large transaction       | 10000  | 50
    """)
void testTransactionFee(int amount, int expectedFee) {
    assertEquals(expectedFee, calculateFee(amount));
}
```

Scenario names appear in test reports, making failures immediately understandable.

## Expectation Column Naming Convention

Expectation columns (columns containing expected results) should end with a question mark to make test intent immediately clear:

- `Valid?` - for validation tests
- `Formatted?` - for formatter tests
- `Expected?` - for general expectations
- `Result?` - for computation results
- `Throws?` - for exception tests

```java
@TableTest("""
    Scenario          | Input      | Formatted?
    Normalize spaces  | "[1,2,3]"  | "[1, 2, 3]"
    Empty list        | "[]"       | "[]"
    """)
void testFormatter(String input, String formatted) {
    // test implementation
}
```

This convention is optional but recommended for clarity.

## Common Patterns

### Testing Business Rules
Express business logic as examples:

```java
@TableTest("""
    Scenario              | Age | Has Licence | Can Rent Car
    Too young             | 17  | true        | false
    Adult with licence    | 25  | true        | true
    Adult without licence | 30  | false       | false
    Senior with licence   | 70  | true        | true
    """)
void testCarRentalEligibility(int age, boolean hasLicence, boolean canRent) {
    assertEquals(canRent, isEligibleToRentCar(age, hasLicence));
}
```

### Testing Edge Cases and Boundaries
Group boundary conditions clearly:

```java
@TableTest("""
    Scenario      | Input | Valid
    Below minimum | -1    | false
    At minimum    | 0     | true
    Normal range  | 50    | true
    At maximum    | 100   | true
    Above maximum | 101   | false
    """)
void testValidRange(int input, boolean expectedValid) {
    assertEquals(expectedValid, isInRange(input, 0, 100));
}
```

### Testing Collections and Aggregations
```java
@TableTest("""
    Scenario          | Numbers       | Average
    Empty list        | []            | 0.0
    Single element    | [42]          | 42.0
    Multiple elements | [10, 20, 30]  | 20.0
    With negatives    | [-10, 10, 20] | 6.67
    """)
void testAverage(List<Integer> numbers, double expected) {
    assertEquals(expected, calculateAverage(numbers), 0.01);
}
```

### Testing Time-Based Logic
```java
@TableTest("""
    Scenario              | Purchase Date | Today      | Expired
    Purchased today       | 2025-01-15    | 2025-01-15 | false
    Purchased 29 days ago | 2024-12-17    | 2025-01-15 | false
    Purchased 30 days ago | 2024-12-16    | 2025-01-15 | true
    Purchased 60 days ago | 2024-11-16    | 2025-01-15 | true
    """)
void testExpiry(LocalDate purchaseDate, LocalDate today, boolean expired) {
    assertEquals(expired, isExpired(purchaseDate, today));
}
```

### Testing Exceptions
```java
@TableTest("""
    Scenario       | Input | Expected Exception
    Negative age   | -1    | java.lang.IllegalArgumentException
    Empty name     | ''    | java.lang.IllegalArgumentException
    """)
void testExceptions(String input, Class<? extends Throwable> expectedException) {
    assertThrows(expectedException, () -> validateInput(input));
}
```

### Testing Value Transformations

When testing formatters, converters, or transformers that operate on individual values, use a single-column table to minimize scaffolding. This approach simplifies test implementation by avoiding multi-column complexity when only testing single-value transformations:

```java
@TableTest("""
    Scenario                 | Input                   | Formatted?
    Normalize spacing        | "[1,2,3]"               | "[1, 2, 3]"
    Remove extra spaces      | "[ [] ]"                | "[[]]"
    Nested lists             | "[[1,2],[3,4]]"         | "[[1, 2], [3, 4]]"
    Empty collection         | "[]"                    | "[]"
    Normalize map spacing    | "[a:1,b:2]"             | "[a: 1, b: 2]"
    """)
void shouldFormatCollectionInCell(String input, String formatted) {
    var tableInput = "value\n" + input;
    var result = formatter.format(tableInput);
    var lines = result.split("\n");
    assertThat(lines[1]).isEqualTo(formatted);
}
```

**Key benefits:**
- Focuses on the transformation being tested (input → output)
- Eliminates unnecessary multi-column scaffolding
- Makes test data more readable and maintainable
- Simplifies test implementation (just extract second line)

**When to use:**
- Testing formatters (code formatters, string formatters, etc.)
- Testing converters (type converters, value transformers)
- Testing serialization/deserialization of individual values
- Any function that transforms a single input to a single output

## External Table Files

For large tables or reusable test data:

```java
@TableTest(resource = "/test-data/user-permissions.table")
void testUserPermissions(String role, String action, boolean allowed) {
    assertEquals(allowed, hasPermission(role, action));
}
```

File format identical to inline tables. Stored in `src/test/resources`.

## Comments and Blank Lines

```java
@TableTest("""
    Scenario        | Input | Output
    
    // Basic cases
    Zero            | 0     | 0
    Positive        | 5     | 25
    
    // Edge cases
    Negative        | -3    | 9
    
    // Temporarily disabled
    // Large number | 1000  | 1000000
    """)
```

Lines starting with `//` are ignored. Blank lines improve readability.

## Common Mistakes to Avoid

**Don't create one-row tables:**
```java
// Wrong - use standard @Test instead
@TableTest("""
    Input | Output
    5     | 10
    """)
void test(int input, int output) { }
```

**Don't mix different test logic:**
```java
// Wrong - different assertions per row need separate test methods
@TableTest("""
    Type   | Input | Output
    double | 5     | 10
    square | 5     | 25
    """)
void test(String type, int input, int output) {
    if (type.equals("double")) {
        assertEquals(output, input * 2);
    } else {
        assertEquals(output, input * input);
    }
}
```

**Remember parameter order matters:**
```java
// Parameters must match column order (excluding scenario)
@TableTest("""
    Scenario | A | B | Sum
    Example  | 1 | 2 | 3
    """)
void test(int b, int a, int sum) { // Wrong - parameters swapped
    assertEquals(sum, a + b);
}

void test(int a, int b, int sum) { // Correct
    assertEquals(sum, a + b);
}
```

**Quote special characters:**
Must quote strings with pipe or starting with bracket or curly bracket to avoid parse errors.
```java
@TableTest("""
    Value             | Valid
    simple            | true
    "contains | pipe" | true
    '[1, 2, 3]'       | true
    """)
```

## TableTest Consolidation Patterns
When multiple standard JUnit test methods follow the same structure but vary only in inputs/outputs, consolidate them into a TableTest:

**Good candidates for consolidation:**
- Multiple tests with identical setup and assertion logic
- Tests varying only in input data and expected outcomes
- Validation tests checking different scenarios

**Keep as separate @Test methods:**
- Edge cases with null/empty inputs
- Tests requiring complex setup (e.g., creating subdirectories)
- Tests with fundamentally different assertion logic

**TableTest best practices:**
- Use `List<String>` for file lists: `[file1.txt, file2.txt]`
- Use path notation for subdirectories: `[subdir/file.txt]`
- Include `@Scenario String _scenario` when using `@TempDir` (parameter shift issue)
- Create parent directories: `Files.createDirectories(filePath.getParent())`

Example:
```java
@TableTest("""
    Scenario          | Files                    | Expected
    Single file       | [file.txt]               | [file]
    Multiple files    | [a.txt, b.txt]           | [a, b]
    Subdirectory      | [dir/file.txt]           | []
    """)
void discovers_files(@Scenario String _scenario, List<String> files, List<String> expected,
                    @TempDir Path tempDir) throws IOException {
    for (String file : files) {
        Path path = tempDir.resolve(file);
        Files.createDirectories(path.getParent());
        Files.writeString(path, "content");
    }
    // assertions...
}
```
