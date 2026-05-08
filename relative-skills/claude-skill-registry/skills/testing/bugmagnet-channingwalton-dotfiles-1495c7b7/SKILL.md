---
name: BugMagnet
description: Comprehensive Test Coverage and Bug Discovery Workflow (user)
---

# BugMagnet - Comprehensive Test Coverage and Bug Discovery Workflow

(from <https://github.com/gojko/bugmagnet-ai-assistant>)

Execute systematic test coverage analysis and implementation for a code module to discover edge cases and potential bugs.

## Usage

```
/bugmagnet <file-path>
```

Where `<file-path>` is the path to the implementation file to analyse.

Examples:

```
/bugmagnet lib/script/src/module-name.js
/bugmagnet src/main/java/com/example/Service.java
/bugmagnet src/calculator.py
/bugmagnet pkg/handler/processor.go
```

The language and testing framework will be auto-detected from the file extension and project structure.

## Workflow

At the end of each phase, pause and wait for user input or confirmation to proceed

### Phase 1: Initial Analysis

1. **Detect language and testing conventions**:
   - Determine language from file extension
   - Scan project to identify testing framework and conventions
   - Adapt all subsequent steps to use appropriate syntax and patterns for this language/framework

2. **Read the implementation file** to understand:
   - Public API (functions, methods, classes, interfaces)
   - Input parameters and their types
   - Internal state management
   - Dependencies and imported modules
   - Any referenced files in the same project (you may read these to understand context)

3. **Locate the test file**:
   - Search for corresponding test file using project conventions
   - If no test file exists, ask user if one should be created

4. **Check for code coverage tools**:
   - Look for coverage configuration in project (coverage config files, test scripts with coverage flags)
   - Common tools: coverage.py (Python), JaCoCo/Cobertura (Java), jest coverage/nyc/istanbul (JavaScript), SimpleCov (Ruby), go test -cover (Go)
   - If coverage tool exists, run it to get baseline coverage report
   - Note current coverage percentages and uncovered lines/branches
   - This will help identify gaps in Phase 2

5. **Read existing tests** to understand:
   - Current test coverage across different types:
     - **Statement coverage**: Which lines of code are executed
     - **Decision/branch coverage**: Which if/else branches are taken
     - **Condition coverage**: Each boolean sub-expression (true/false)
     - **Loop coverage**: Zero iterations, one iteration, multiple iterations, maximum iterations
     - **Expression evaluation coverage**: Short-circuit evaluation in complex expressions (&&, ||)
   - Testing patterns and assertion syntax used
   - Mock/stub strategies
   - Test organization (suite grouping, setup patterns)
   - Existing edge cases covered

6. **Check for project-specific testing guidelines**:
   - Look for README.md, README.txt, CONTRIBUTING.md, CONTRIBUTING.txt in project root
   - If found, scan for architecture-specific testing patterns (e.g., hexagonal architecture, frontend patterns, mocking strategies)
   - Adapt all subsequent testing to follow project conventions

7. **Ask user about additional context**:
   - "Are there any additional files I should review (e.g., requirements docs, roadmaps, design docs)?"
   - STOP and wait for an answer
   - If user provides file paths, read and analyze them

### Phase 2: Gap Analysis

8. **Evaluate missing test coverage** by analyzing what's currently tested vs what should be tested. Review the **Common Edge Case Checklist** (at end of document) and identify gaps in:
   - **Boundary conditions**: empty/null inputs, zero, extreme values, size limits
   - **Error paths**: invalid inputs, error messages, error propagation, error context preservation
   - **State transitions**: before/after changes, invalid transitions, reset behavior
   - **Complex interactions**: multiple features together, deep nesting, property conflicts and precedence
   - **Domain-specific edge cases**: names, emails, URLs, dates/times, currency, geographic data, file paths, security patterns
   - **Violated domain constraints**: implicit assumptions about uniqueness, mandatory fields, relationships, ordering, ranges, state, format, temporal ordering
   - **Multiple/related parameters**: same values, very close values, interdependencies
   - **Documentation/requirements**: any listed requirements or edge cases not tested

   **Refer to the detailed Common Edge Case Checklist** for comprehensive coverage categories based on parameter types.

9. **Categorize missing tests** by priority:
   - **High Priority**: Core functionality gaps, error handling, boundary conditions
   - **Medium Priority**: Complex interactions, multi-step scenarios, state management
   - **Low Priority**: Rare edge cases, performance-specific tests

10. **Present analysis to user**:

- List missing test categories with specific examples
- STOP and ask the user if all tests should be implemented, or if the user wants to skip some of them

11. **Clarify undecided behaviour**:

- For any identified gaps with unclear expected behaviour, prompt the user to explain or decide the expected behaviour so you can use it in the next phase

### Phase 3: Iterative Test Implementation

12. **Write tests one at a time**:

- Pick highest priority test from the list
- Add gap tests to existing test suites based on the flow or method they are testing
- Write a single test (or small group of 2-3 related tests)
- **Name test to describe the outcome, not the action**:
  - Format: "returns X when Y", "throws error when Z"
  - GOOD: "returns chunks without error when text contains newlines"
  - BAD: "handles newline characters"
- **CRITICAL: Ensure assertions match the test title**
  - If testing "allows creating objects with different properties", assert the actual property values
  - If testing "preserves order", check the actual order of elements
  - If testing "applies transformation X", verify the transformation result directly
  - Avoid indirect checks (e.g., checking length when you should check actual values)
- Use complete equality assertions with full expected values
- Avoid partial string matching for short strings - check whole output
- Follow arrange-act-assert structure clearly
- Run the test immediately

13. **Handle test failures**:

- If test fails, analyze the actual vs expected output
- Determine if:
  - **Test expectation is wrong**: Update test to match actual behavior
  - **Bug discovered**: Create skipped test with bug documentation
  - **Need more context**: Try 2 more variations with different approaches
- **When you discover something surprising**:
  - Explore the surrounding territory with additional tests
  - Bugs often cluster together - test similar scenarios
  - Try variations of the same input pattern
  - Test inverse/opposite operations

14. **Document bugs in skipped tests**:
    - Use framework's skip/ignore mechanism
    - Mark test name with "- BUG" suffix
    - Include comprehensive comment with:
      - Brief description of what's broken
      - Root cause analysis
      - Code location (file path and line number)
      - Current problematic code snippet
      - Proposed fix with code
      - Expected vs actual output
    - Keep the failing assertion in the test body

15. **When a bug is discovered**:
    - **Try to create a minimal reproduction test**
    - Isolate the bug to the smallest possible test case
    - If the bug seems to be in a dependency/nested component:
      - Create tests for that component (within the same project only)
      - Do NOT cross project boundaries to external dependencies
      - Write tests in the appropriate test file for that component
    - Ask yourself: "What's the simplest way to expose this bug?"
    - Document the minimal reproduction in the skipped test
    - DO NOT IMPLEMENT FIXES OR CHANGE THE IMPLEMENTATION FILE, ONLY WRITE TESTS

16. **Maximum 3 attempts per test**:
    - If can't get test passing in 3 tries, document and move on
    - Create skipped test with analysis
    - Continue with next test category

17. **Mark progress after each passing test**:
    - Confirm test passes
    - Move to next test in the list
    - Update user on progress

18. **Ask the user if they want to perform advanced coverage**:
    - STOP and ask the user for confirmation to proceed to additional tests in phase 4

### Phase 4: Advanced Coverage

**Use the Common Edge Case Checklist** (at end of document) as your comprehensive reference for this phase. The checklist provides detailed examples and specific test cases organized by category.

19. **Create a separate test suite inside the primary test file**:
    - Check if "exploratory tests", "edge cases" or "bugmagnet session" test suite exists
    - If yes, use it
    - If not, create a new one with the name "bugmagnet session <current date>"
    - Add all tests created in phase 4 there, not in the primary test sections

20. **Test complex interactions** (if applicable):
    - See checklist: **For Complex Interactions**
    - Multiple features used together, three-way interactions, property/option precedence and override behavior
    - State changes across multiple operations, deep nesting, property conflicts

21. **Test error handling comprehensively**:
    - See checklist: **For Error Conditions**
    - Invalid property values with specific error messages, error context preservation (line numbers, file names)
    - Multiple errors in sequence, errors don't crash or prevent subsequent operations
    - Edge case inputs that should trigger errors (invalid types, out of range, malformed data)

22. **Test numeric edge cases** (where applicable):
    - See checklist: **For Functions Taking Numbers**, **For Size/Length Boundaries**, **For Currency/Financial Numbers**
    - Zero (various representations and contexts), numbers close to zero, negative numbers, very large/small numbers
    - Special floating point values (NaN, Infinity), scientific notation, formatted numbers
    - 32/64-bit boundaries, powers of 2
    - Currency: varying decimal places by currency, locale-specific formatting, rounding rules

23. **Test date/time edge cases** (where applicable):
    - See checklist: **For Date/Time Values**
    - Leap seconds, leap years (including century boundaries), invalid dates
    - DST transitions (duplicate times, missing times, regional differences)
    - Time zones, 32-bit system limits (before 1970, after 2038)
    - Calendar vs duration arithmetic, date/time format parsing (multiple formats, ambiguous formats, locale-specific)
    - Timeouts (operation, network, response)
    - Time synchronization (clock differences, drift, skew)
    - Use of LocalDateTime (no timezone information) when the timezone matters (daylight savings for example)

24. **Test string edge cases** (where applicable):
    - See checklist: **For Functions Taking Strings**, **For Internationalized Text**
    - Empty, single character, very long strings (10000+ chars)
    - Whitespace-only, mixed whitespace, long leading/trailing spaces
    - Unicode: directional control characters, special characters (ß, Turkish İ/i), combining characters
    - Invalid combinations, invisible characters (zero-width), emoji complexity (skin tones, ZWJ sequences)
    - Homograph attacks, multiple representations (precomposed vs combining)
    - Case transformation edge cases, regional indicators (flag emoji)
    - Text size boundaries (127/128, 255/256 bytes, 32KB, 64KB)

25. **Test collection edge cases** (where applicable):
    - See checklist: **For Functions Taking Collections (Arrays/Lists)**, **For Functions Taking Objects/Structures/Maps**
    - Empty, single element, many elements (100+), duplicate elements
    - Nested structures (deep nesting 5+ levels), circular references
    - Objects with extra/missing properties, deeply nested objects

26. **Test state transition edge cases** (where applicable):
    - See checklist: **For Stateful Operations**
    - Repeating same action multiple times, sequential actions in reverse order
    - Sequential actions out of order/different order
    - Executing one action multiple times within a sequence

27. **Test domain-specific edge cases** (where applicable based on parameter types):
    - See checklist: **For Functions Taking Names**, **For Functions Taking Email Addresses**, **For Functions Taking URLs**, **For Functions Taking Geographic Data**, **For User Input with Security Implications**, **For File Paths and File System Operations**
    - **Names**: Single character, very long (35-64 chars), extremely long, punctuation, accents, non-Latin scripts, mononymic names, reserved words ("Null", "Test"), multiple middle names, fictional/brand names, name changes
    - **Email addresses**: Valid formats (subdomain, plus addressing, IP addresses), internationalized domains, invalid formats
    - **URLs**: With/without protocols, ports, paths, internationalized domains, invalid formats
    - **Geographic data**: Single-letter city names, very long place names (58+ chars), special characters, various postal code formats (3-10 digits), postal codes optional in some countries, format changes over time, regional differences
    - **Security**: SQL injection, XSS attempts, HTML injection, path traversal
    - **File paths**: Path length boundaries (260 Windows, 4096 Linux/Mac), special characters, reserved filenames, file existence, file system state (no space, read-only), file availability (locked, unavailable), file integrity (corrupted, empty), path separators

28. **Test violated domain constraints** (implicit assumptions):
    - See checklist: **For Violated Domain Constraints (Implicit Assumptions)**
    - Code often makes assumptions about data that aren't explicitly validated
    - **Uniqueness violations**: Duplicate IDs, usernames, keys where uniqueness assumed
    - **Mandatory field violations**: Required fields null/empty/missing, collections assumed non-empty
    - **Relationship violations**: 1:1 with multiple items, orphaned records, circular references, missing foreign keys
    - **Ordering violations**: Unordered data where order assumed, wrong order, reverse order
    - **Range/bounds violations**: Values outside expected range, wrong scale, wrong unit, negative where positive assumed
    - **State violations**: Operations in wrong state, invalid state transitions, multiple simultaneous states
    - **Format violations**: Data in unexpected format, wrong encoding, missing/extra structure
    - **Temporal violations**: End before start, creation after modification, future timestamps, expired dates for active items

### Phase 5: Summary and Documentation

29. **Provide comprehensive summary**:
    - Total tests added (by category)
    - Total passing/skipped tests
    - Key findings about behavior
    - List of discovered bugs with locations

30. **Document bugs separately**:
    - Create bug summary with:
      - Root cause analysis
      - Exact file and line numbers
      - Proposed fixes
      - Impact assessment
    - Include both expected and actual behavior

## Best Practices

### Test Writing Guidelines

- **Use descriptive test names**: Clear description of what behavior is tested
- **Test names describe outcomes, not actions**:
  - Format: "returns X when Y", "throws error when Z"
  - GOOD: "returns chunks without error when text contains newlines"
  - BAD: "handles newline characters"
- **Assertions must match the test title**:
  - BAD: Test titled "creates objects with different IDs" but only checks count/length
  - GOOD: Test titled "creates objects with different IDs" and actually verifies the IDs differ
  - BAD: Test titled "applies correct transformation" but only checks result is truthy
  - GOOD: Test titled "applies correct transformation" and checks the actual transformed values
  - **Always verify the specific property/behavior mentioned in the test name**
- **Specific value assertions over type checks**:
  - GOOD: `assert result.chunks equals ['First.', ' Second.']`
  - BAD: `assert result.chunks.length > 1`
  - GOOD: `assert result equals {chunks: ['text'], context: {line: 10}, properties: {}, error: null}`
  - BAD: `assert result has property 'chunks'`
  - Expect specific values, NOT just type checks or vague assertions
- **One assertion per concept**: Test one thing clearly
- **Full comparisons**: Use complete expected values, not partial matches
  - Exception: For large objects, match specific intention-revealing properties
  - Exception: For long strings, match intention-revealing substrings
- **Avoid magic values**: Use clear, readable test data
- **Group related tests**: Use nested test suites/groups
- **Test the happy path first**: Then add edge cases and error cases

### Test Structure Guidelines

- **Arrange-Act-Assert flow**: Clearly separate test setup, execution, and verification
- **Consistent naming**: Use clear names like `underTest`, `result`, `actual` for test subjects
- **Setup patterns**: Create test subject and wire mocks in setup blocks. Avoid unnecessary recreation
- **Grouping tests**: Group 3+ tests with common setup using nested test suites
- **Consolidate nested suites**: If 3+ nested suites share setup, create parent suite
- **Inline simple initialization**: For trivial setup, inline with assertion
- **Test order**: Test usual/happy path scenarios first, then edge cases, then error cases

### Bug Discovery Guidelines

- **Bugs cluster together**: When you find one bug, look for similar bugs nearby
  - If a function fails for one edge case, try related edge cases
  - If a property is handled incorrectly, check other similar properties
  - If behavior is wrong in one context, test it in related contexts
- **Create minimal reproductions**:
  - Strip away unnecessary setup
  - Use the simplest possible input that exposes the bug
  - Isolate to the smallest component that exhibits the problem
- **Test dependencies within the project**:
  - If bug seems to be in a helper/utility, test that directly
  - Create tests in the appropriate file for that component
  - Do NOT test external dependencies (npm packages, etc.)

### Bug Documentation

- **Always include expected vs actual**: Show what should happen
- **Provide code location**: File path and line number
- **Suggest a fix**: Don't just identify, propose solution
- **Explain root cause**: Help developers understand why
- **Mark test name with - BUG**: Makes it easy to find

### Running Tests

- **Run after each test**: Don't batch multiple untested changes
- **Run specific test file**: Run only the file being modified when possible
- **Fix failures immediately**: Don't accumulate broken tests
- **Maximum 3 attempts**: Move on if stuck

### Reading Project Files

- **You may read any files in the same project**: To understand implementation
- **Do not read external dependencies**: Stay within project boundaries
- **Read imported modules**: To understand behavior and contracts
- **Read configuration files**: To understand valid values and constraints

## Example Test Patterns

**Note:** These examples use JavaScript/Jest syntax for illustration. Treat them as pseudo-code and adapt to your language and testing framework's conventions.

### Basic Test (Good Assertions)

```javascript
// BAD: Test says "sets username" but only checks object exists
test('sets username correctly', () => {
    const user = createUser({username: 'alice'});
    expect(user).toBeDefined();
});

// GOOD: Actually checks the username
test('sets username correctly', () => {
    const user = createUser({username: 'alice'});
    expect(user.username).toEqual('alice');
});
```

### Testing Actual Values Not Just Counts

```javascript
// BAD: Test says "creates items with different IDs" but only checks count
test('creates items with different IDs', () => {
    const items = createMultipleItems(['a', 'b']);
    expect(items.length).toEqual(2);
});

// GOOD: Actually verifies the IDs are different
test('creates items with different IDs', () => {
    const items = createMultipleItems(['a', 'b']);
    expect(items[0].id).not.toEqual(items[1].id);
    expect(items[0].name).toEqual('a');
    expect(items[1].name).toEqual('b');
});
```

### Boundary Condition Test

```javascript
test('handles empty input correctly', () => {
    const result = moduleUnderTest.operation('');

    expect(result).toEqual(expectedOutputForEmptyString);
});

test('handles very long input', () => {
    const longString = 'x'.repeat(10000);
    const result = moduleUnderTest.operation(longString);

    expect(result.length).toBeGreaterThan(0);
    expect(result).not.toContain('error');
});
```

### Exploring Bug Clusters

```javascript
// You find this bug:
test.skip('fails to handle negative index - BUG', () => {
    const result = moduleUnderTest.getItemAt(-1);
    expect(result).toEqual(lastItem);
    // Actual: undefined
});

// Explore similar territory:
test('handles index zero', () => {
    const result = moduleUnderTest.getItemAt(0);
    expect(result).toEqual(firstItem);
});

test('handles index beyond array length', () => {
    const result = moduleUnderTest.getItemAt(1000);
    expect(result).toBeUndefined();
});

test('handles non-integer index', () => {
    const result = moduleUnderTest.getItemAt(1.5);
    expect(result).toEqual(secondItem); // or error?
});
```

### Minimal Bug Reproduction

```javascript
// Original complex test that exposed bug:
test.skip('complex scenario fails - BUG', () => {
    setup();
    operation1();
    operation2();
    const result = operation3();
    expect(result).toEqual(expected); // Fails
});

// Minimal reproduction:
test.skip('operation3 returns wrong value - BUG', () => {
    const result = operation3();
    expect(result).toEqual(expected); // Fails
    // Actual: wrongValue
    // Even without operation1 and operation2, this fails
});
```

### Numeric Edge Case Tests

```javascript
test('handles zero correctly', () => {
    const result = moduleUnderTest.calculate(0);
    expect(result).toEqual(0);
});

test('handles negative numbers', () => {
    const result = moduleUnderTest.calculate(-5);
    expect(result).toEqual(expectedNegativeResult);
});

test('handles very large numbers', () => {
    const result = moduleUnderTest.calculate(Number.MAX_SAFE_INTEGER);
    expect(result).toBeDefined();
});
```

### Collection Edge Cases

```javascript
test('handles empty array', () => {
    const result = moduleUnderTest.process([]);
    expect(result).toEqual([]);
});

test('handles single element', () => {
    const result = moduleUnderTest.process([item]);
    expect(result.length).toEqual(1);
    expect(result[0]).toEqual(expectedTransformedItem);
});

test('handles many elements', () => {
    const manyItems = Array(100).fill(null).map((_, i) => createItem(i));
    const result = moduleUnderTest.process(manyItems);
    expect(result.length).toEqual(100);
});
```

### Error Test

```javascript
test('reports error for invalid input', () => {
    moduleUnderTest.operation('invalid');

    const result = moduleUnderTest.getErrors();

    expect(result.errors.length).toEqual(1);
    expect(result.errors[0].message).toEqual('exact error message');
    expect(result.errors[0].context).toEqual({line: 10});
});
```

### Skipped Bug Test with Minimal Reproduction

```javascript
test.skip('feature returns wrong value - BUG', () => {
    /*
     * BUG: Feature produces wrong output
     *
     * ROOT CAUSE: Wrong parameter used in calculation at line 42
     *
     * CODE LOCATION: src/module.js:42
     *
     * MINIMAL REPRODUCTION: Just call feature() with no setup
     *
     * CURRENT CODE:
     *   return calculate(param1, value);
     *
     * PROPOSED FIX:
     *   return calculate(param2, value);
     *
     * EXPECTED: "correct output"
     * ACTUAL:   "wrong output"
     */

    const result = moduleUnderTest.feature();

    expect(result).toEqual('correct output');
    // Actual: 'wrong output'
});
```

## Output Format

### Progress Updates

- "Writing test 1/12: <category> - <specific test>"
- "Test passed: <test name>"
- "Test failed (attempt 2/3): <reason>"
- "Skipped test: <name> - Bug documented"
- "Exploring bug cluster: trying <related scenario>"

### Final Summary

```
## Test Coverage Summary

**Tests Added: X total**
- Category 1 (Y tests)
- Category 2 (Z tests)

**Final Count:**
- X passing tests
- Y skipped tests (bugs documented)
- Total: Z tests

**Bugs Discovered:**
1. Bug name - file.js:line
   - Root cause: ...
   - Fix: ...
   - Minimal reproduction: ...
```

## Common Edge Case Checklist

When analyzing a module, consider these common scenarios:

### For Functions Taking Numbers

- [ ] Zero (various representations: 0, 0.0, -0)
- [ ] Zero in context (false/missing, timers at zero, counters at zero, display with 0 items, contextual data mapping to 0)
- [ ] Numbers close to zero (0.0001, -0.0001)
- [ ] Negative numbers
- [ ] Very large numbers (approaching max values)
- [ ] Very small numbers (close to zero, min values)
- [ ] Special floating point values (if applicable: NaN, Infinity)
- [ ] Non-integer values where integers expected
- [ ] Numbers with lots of decimals vs numbers with no decimals
- [ ] Scientific notation (1E-16, 1E+10)
- [ ] Formatted numbers with separators: 1,000,000 or 1.000.000 (locale-dependent)
- [ ] 32-bit boundaries: -2147483648, 2147483647, 4294967295
- [ ] Powers of 2: 128, 256, 512, 1024, 2048

### For Size/Length Boundaries

- [ ] Common system limits: 127/128 bytes (ASCII boundary), 255/256 bytes (single-byte limit)
- [ ] Buffer boundaries: 32KB - 1, 32KB, 32KB + 1
- [ ] Buffer boundaries: 64KB - 1, 64KB, 64KB + 1
- [ ] Test at boundary-1, boundary, boundary+1 for relevant limits
- [ ] Test with and without whitespace to distinguish byte vs character limits

### For Currency/Financial Numbers

- [ ] Varying decimal places: 0 decimals (JPY), 2 decimals (USD), 3 decimals (KWD)
- [ ] Locale-specific formatting: 1,234.56 (US) vs 1 234,56 (France)
- [ ] Input variations: 5000, $5,000, $5 000, $5,000.00
- [ ] Rounding rules (banker's rounding, country-specific)
- [ ] Rounding accumulation errors
- [ ] Negative amounts (returns, refunds)

### For Date/Time Values

- [ ] Leap seconds (86,401 second days, e.g., 31 Dec 2016)
- [ ] Leap years: Feb 29, century boundaries (1900, 2000, 2100)
- [ ] Invalid dates: Feb 30/31, Apr 31, Sept 31, Nov 31
- [ ] Feb 29 in non-leap years (1900, 2001, 2100)
- [ ] Day 0, day 32, month 0, month 13
- [ ] DST transitions: duplicate times (fall back), missing times (spring forward)
- [ ] DST regional differences
- [ ] Time zone conversions
- [ ] 32-bit limits: before 1970-01-01, after 2038-02-07
- [ ] Invalid times masking as 1970-01-01 or 1969-12-31
- [ ] Calendar arithmetic: adding months/years across boundaries
- [ ] Duration arithmetic: 1 day vs 24 hours (DST effects)
- [ ] Date format parsing: multiple formats, locale differences (mm/dd vs dd/mm)
- [ ] Ambiguous formats: 01/02/2003 (Jan 2 or Feb 1?)
- [ ] Time formats: 12h am/pm vs 24h
- [ ] Ambiguous times: 12:00 (noon or midnight?)
- [ ] Timeouts: operation, network, response timeouts
- [ ] Time synchronization: clock differences between machines
- [ ] Clock drift and skew
- [ ] Dates and times expressed without timezone information used in calculations of duration

### For Functions Taking Strings

- [ ] Empty string
- [ ] Single character
- [ ] Very long strings (10000+ chars)
- [ ] Strings with whitespace characters (newlines, tabs, spaces)
- [ ] Whitespace-only strings (only spaces, only tabs, only newlines)
- [ ] Mixed whitespace (tabs and spaces, newlines and spaces)
- [ ] Strings with long leading or trailing spaces
- [ ] Null/nil values vs empty string (based on language)

### For Functions Taking Names (person names, usernames)

- [ ] Single character names
- [ ] Very long names (35+ characters, up to 64 per ICAO)
- [ ] Extremely long names (Wolfeschlegelsteinhausenbergerdorff, 58+ char Welsh names)
- [ ] Names with punctuation (apostrophes, hyphens, periods)
- [ ] Names with accents/diacritics
- [ ] Non-Latin scripts (if internationalization supported)
- [ ] Mononymic names (single name: "Teller", "They")
- [ ] System markers: FNU, LNU, XXX (and people actually named these)
- [ ] Reserved words: "Null", "Test", "Sample", "None", "Undefined"
- [ ] Common words as names: "Yellow Horse", "Znoneofthe"
- [ ] Multiple middle names (3+, test splitting/truncation)
- [ ] Fictional/brand names: "Superman Wheaton", "Facebook Jamal"
- [ ] Name changes (test update workflows)

### For Functions Taking Email Addresses

- [ ] Valid formats: subdomain, plus addressing, IP addresses
- [ ] Valid formats: dots and special characters in the first part
- [ ] Invalid formats: leading and trailing dots, multiple dots in a sequence
- [ ] Internationalized domains (if supported)
- [ ] Invalid formats: missing components, multiple @, dots in wrong places

### For Functions Taking URLs

- [ ] With/without protocols
- [ ] With ports and paths
- [ ] Internationalized domains
- [ ] Invalid: malformed, incomplete, with spaces

### For Functions Taking Geographic Data

- [ ] Single-letter city names (Y in France, A in Norway)
- [ ] Very long place names (58+ characters: Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch)
- [ ] Special characters (Scandinavian: AEroskoebing, Malmoe)
- [ ] Various postal code formats: 3-digit (Faroe), 4-digit (Austria), 5-digit (USA), 6 alphanumeric (UK/Canada), 10-digit (Iran)
- [ ] Postal codes optional (Fiji, UAE don't use)
- [ ] Postal code format changes (Singapore: 2-4-6 digits, Ireland added 2014)
- [ ] Regional postal code differences (China yes, Hong Kong no)
- [ ] Legacy data with old postal code formats

### For User Input with Security Implications

- [ ] SQL injection patterns
- [ ] XSS/script injection attempts
- [ ] HTML injection and malformed markup
- [ ] Path traversal attempts

### For File Paths and File System Operations

- [ ] Very long paths (>255 chars, test OS limits: 260 Windows, 4096 Linux/Mac)
- [ ] Long filenames (>255 chars)
- [ ] Special characters in filenames: * ? / \ | < > spaces, dots, etc.
- [ ] Unicode characters in filenames
- [ ] Leading/trailing spaces or dots
- [ ] Reserved filenames (CON, PRN, AUX, NUL on Windows)
- [ ] Current/parent directories (. and ..)
- [ ] Hidden files (.filename on Unix/Mac)
- [ ] File does not exist (test read/update/delete)
- [ ] File already exists (test create/copy)
- [ ] Directory when file expected (and vice versa)
- [ ] No disk space
- [ ] Minimal disk space (less than needed, just enough, slightly more)
- [ ] Read-only file system
- [ ] Write-protected files
- [ ] Locked files (by another process)
- [ ] Unavailable files (network drive disconnected)
- [ ] Remote files (network latency, timeouts)
- [ ] Corrupted files (invalid headers, truncated)
- [ ] Empty files (0 bytes)
- [ ] Symlinks and hard links
- [ ] Path separator variations (/, \, mixed, multiple //, trailing)

### For Internationalized Text

- [ ] Multiple character sets (Latin, Cyrillic, Arabic, Chinese, etc.)
- [ ] Right-to-left text (Hebrew U+05D0-U+05FF, Arabic U+0600-U+06FF)
- [ ] Homograph attacks: Cyrillic 'a' (U+0430) vs Latin 'a' (U+0061)
- [ ] Mixed scripts in single string (e.g., "paypal" mixing Cyrillic and Latin)
- [ ] Multiple representations: "cafe" precomposed (U+00E9) vs combining (U+0065+U+0301)
- [ ] Case transformation edge cases (eszett to SS, Turkish I/i, Greek Sigma variants)
- [ ] Combining characters and diacritics (U+0300-U+036F range)
- [ ] Zero-width characters (U+200B-U+200D, U+FEFF)
- [ ] Directional overrides (U+202D LTR, U+202E RTL)
- [ ] Emoji with modifiers (skin tones U+1F3FB-U+1F3FF, ZWJ sequences)
- [ ] Regional indicators (flag emoji): two characters, string length varies by encoding

### For Functions Taking Collections (Arrays/Lists)

- [ ] Empty collection
- [ ] Single element
- [ ] Many elements (100+)
- [ ] Duplicate elements (same value appears multiple times)
- [ ] Nested collections
- [ ] Collection with null/nil elements (if language allows)

### For Functions Taking Objects/Structures/Maps

- [ ] Empty object/structure
- [ ] Object with extra properties/fields
- [ ] Object with missing properties/fields
- [ ] Deeply nested objects
- [ ] Null/nil values vs empty objects (based on language)

### For Stateful Operations

- [ ] Operation before initialization
- [ ] Multiple consecutive operations
- [ ] Operation after reset/clear
- [ ] Concurrent operations (if applicable)
- [ ] Repeating same action multiple times (where previously always executed once)
- [ ] Executing sequential actions in reverse order
- [ ] Executing sequential actions out of order/different order
- [ ] Executing one action multiple times within a sequence

### For Error Conditions

- [ ] Invalid type (string instead of number)
- [ ] Out of range values
- [ ] Missing required parameters
- [ ] Malformed data structures
- [ ] Invalid property values with specific error messages
- [ ] Error context preservation (line numbers, file names, contextual info)
- [ ] Error propagation through call chains
- [ ] Multiple errors in sequence
- [ ] Errors don't crash or prevent subsequent operations

### For Complex Interactions

- [ ] Multiple features used together
- [ ] State changes across multiple operations
- [ ] Three-way interactions between different features
- [ ] Property/option precedence and override behavior
- [ ] Deep nesting of operations
- [ ] Property conflicts and precedence rules

### For Multiple/Related Parameters

- [ ] Same values for different parameters (e.g., same length strings, identical arrays, completely same values)
- [ ] Very close values (string one character shorter, numbers differing by 0.00001)
- [ ] Parameters with interdependencies

### For Documentation/Requirements

- [ ] Edge cases mentioned in documentation but not tested
- [ ] Requirements listed but not covered by tests
- [ ] Behavior specified in design docs but missing tests

### For Violated Domain Constraints (Implicit Assumptions)

- [ ] Duplicate values where uniqueness assumed (IDs, usernames, keys)
- [ ] Null/empty/missing where mandatory assumed
- [ ] Empty collections where non-empty assumed
- [ ] Multiple items in 1:1 relationship
- [ ] Missing parent/child in relationship
- [ ] Orphaned records (missing foreign key targets)
- [ ] Circular references
- [ ] Wrong order where specific order assumed
- [ ] Unordered data where stable sort assumed
- [ ] Values outside implicit range (age 200, negative prices)
- [ ] Wrong scale/unit/precision
- [ ] Operations in wrong state
- [ ] Invalid state transitions
- [ ] Multiple simultaneous states
- [ ] Wrong format/encoding
- [ ] End before start (dates, ranges)
- [ ] Creation after modification (temporal violations)
- [ ] Future timestamps for past events
- [ ] Expired dates for active items

## Notes

- This workflow discovers bugs through systematic testing
- Skipped tests serve as regression tests for when bugs are fixed
- Focus on behavior verification, not implementation details
- Tests should be maintainable and readable by other developers
- Always read referenced files in the project to understand full context
- Bugs often appear in clusters - when you find one, look for more nearby
- Make your assertions match what your test titles claim to test
