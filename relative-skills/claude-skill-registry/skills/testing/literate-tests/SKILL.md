---
name: literate-tests
description: >
  This skill should be used when the user asks to "create literate tests",
  "generate markdown tests", "specification-as-tests", "TDD with markdown",
  "agent-driven testing", or mentions test suites where markdown IS the test format.
  NOT for pytest/jest/unittest. Creates .md test files with inline assertions
  and uses a bundled custom test runner.
license: MIT
metadata:
  author: Ian
  version: "2.3"
---

# Literate Test Suite Generator

Create a test suite for **[DOMAIN]** that an agent can run autonomously.

## What This Pattern Produces

> **CRITICAL:** This is NOT pytest/jest/unittest/etc. This creates a CUSTOM test format.

Generate **two artifacts**:

### 1. Markdown Test Files (`tests/<feature>.md`)

```markdown
# Feature Name

Prose explaining what this tests and why.

## Test Group

### Specific Behavior

\`\`\`py
result = do_thing("input")
result.value  # expect: 42
\`\`\`

### Error Case  

\`\`\`py
do_thing(None)  # error: [null-input]
\`\`\`
```

The markdown file IS the test. Code blocks contain executable code. Comments are assertions.

### 2. Test Runner (language-specific)

Copy the appropriate bundled runner for your language:

| Language | Runner | Copy Command |
|----------|--------|--------------|
| Python | `run_tests.py` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.py" tests/` |
| JavaScript | `run_tests.js` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.js" tests/` |
| TypeScript | `run_tests.ts` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.ts" tests/` |
| Bash/Shell | `run_tests.sh` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh" tests/` |
| PowerShell | `run_tests.ps1` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.ps1" tests/` |
| Rust | `run_tests.rs` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.rs" tests/` |
| C# | `RunTests.cs` | `cp "${CLAUDE_PLUGIN_ROOT}/scripts/RunTests.cs" tests/` |

All runners:
1. Parse markdown files for TOML frontmatter
2. Extract language-specific code blocks
3. Validate `# expect:` / `// expect:` and `# error:` / `// error:` assertions
4. Support matchers: `approx()`, `contains()`
5. Report pass/fail with colored output

**Do NOT use pytest, jest, xunit, or any standard test framework.**

---

## Why This Format

Tests are the oracle for agent-driven development:
1. Agent runs `python run_tests.py`
2. Sees which assertions fail
3. Fixes the code
4. Repeats until green

The test file is both:
- **Documentation** humans can read (it's markdown!)
- **Executable specification** agents verify against

This pattern enabled Simon Willison to port an entire HTML5 parser in 4.5 hours—the agent ran 9,200 tests autonomously.

---

## File Structure

```
project/
├── src/
│   └── <module>.<ext>        # Code under test
└── tests/
    ├── <feature>.md          # Markdown test files
    └── run_tests.<ext>       # Language-specific runner (copied from skill)
```

---

## Markdown Test File Format

### Frontmatter (Required)

Must be the FIRST thing in the file:

```toml
# Test Configuration
module = "mypackage.validator"
import = ["validate", "normalize", "ValidationError"]
isolation = "per-block"
```

### Error Code Index (Required)

List ALL error codes at the top, before any tests:

```markdown
**Error codes:**
- `[empty-input]` — User provided empty string
- `[null-input]` — User provided null/None
- `[invalid-format]` — String doesn't match expected pattern
```

### Test Sections

Headers create test groups. Prose explains intent. Code blocks are tests:

```markdown
## Input Validation

Users paste data from spreadsheets which may contain invisible whitespace.
The validator normalizes input before checking length.

### Accepts Valid Input

\`\`\`py
validate("hello")  # expect: True
\`\`\`

### Rejects Empty String

Empty means "user submitted nothing" — distinct from whitespace-only:

\`\`\`py
validate("")  # error: [empty-input]
\`\`\`
```

---

## Assertion Syntax

### Value Assertions

```py
expression  # expect: <value>
```

The line before `# expect:` must be an **evaluable expression**, not a statement.

```py
# Setup lines run first
result = calculate(10)
# This line is evaluated and compared
result.value  # expect: 42
```

### Error Assertions

```py
statement  # error: [code]
statement  # error: "message substring"  
statement  # error: [code] "message substring"
```

### Matchers

For non-exact comparisons:

```py
pi_value()  # expect: approx(3.14159, tol=0.0001)
output      # expect: contains("success")
text        # expect: matches(/^Error: \d+/)
```

### CLI/Shell Tests

```sh
mycommand --bad-flag
# exit: 1
# stderr: contains("[invalid-flag]")
```

---

## Using the Bundled Runners

### Python Runner

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.py" tests/
python tests/run_tests.py
```

Code blocks: ` ```py ` or ` ```python `
Assertions: `# expect:`, `# error:`

### JavaScript Runner

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.js" tests/
node tests/run_tests.js
```

Code blocks: ` ```js ` or ` ```javascript `
Assertions: `// expect:`, `// error:`, `// throws:`

### TypeScript Runner

Requires: `npm install -D tsx`

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.ts" tests/
npx tsx tests/run_tests.ts
```

Code blocks: ` ```ts ` or ` ```typescript `
Assertions: `// expect:`, `// error:`, `// throws:`

### Bash Runner

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.sh" tests/
bash tests/run_tests.sh
```

Code blocks: ` ```sh ` or ` ```bash `
Assertions: `# exit:`, `# stdout:`, `# stderr:`

### PowerShell Runner

```powershell
cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.ps1" tests/
pwsh tests/run_tests.ps1
```

Code blocks: ` ```ps1 ` or ` ```powershell `
Assertions: `# exit:`, `# stdout:`, `# stderr:`, `# throws:`

### Rust Runner

Requires: `cargo install rust-script`

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/run_tests.rs" tests/
rust-script tests/run_tests.rs
```

Code blocks: ` ```rs ` or ` ```rust `
Assertions: `// expect:`, `// error:`, `// compiles`, `// compile_fails:`

### C# Runner

Requires: `dotnet tool install -g dotnet-script`

```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/RunTests.cs" tests/
dotnet script tests/RunTests.cs
```

Code blocks: ` ```cs ` or ` ```csharp `
Assertions: `// expect:`, `// error:`

---

## Error Identity (Critical)

Every error must have a **stable code** the runner can match:

| Language | How to Expose Code |
|----------|-------------------|
| Python | Exception with `.code` property |
| Rust | Error enum variant |
| CLI | `[code]` in stderr + exit code |
| C# | Exception type name |

Example Python exception:

```python
class ValidationError(Exception):
    def __init__(self, code: str, message: str):
        self.code = code
        super().__init__(message)

# Usage
raise ValidationError("empty-input", "Input cannot be empty")
```

The runner matches `# error: [empty-input]` against `exception.code`.

---

## Example: Complete Test File

```toml
# Test Configuration  
module = "temperature"
import = ["celsius_to_fahrenheit", "TemperatureError"]
isolation = "per-block"
```

# Temperature Conversion

Converts between Celsius and Fahrenheit with validation.

**Problem:** Users need temperature conversion, but invalid inputs (below 
absolute zero) must fail clearly—not return nonsense values.

**Error codes:**
- `[below-absolute-zero]` — Temperature violates laws of physics

---

## Celsius to Fahrenheit

Standard formula: `F = (C × 9/5) + 32`

### Converts Freezing Point

```py
celsius_to_fahrenheit(0)  # expect: 32.0
```

### Converts Boiling Point

```py  
celsius_to_fahrenheit(100)  # expect: 212.0
```

### Rejects Below Absolute Zero

-273.15°C is the physical limit. Below that is impossible:

```py
celsius_to_fahrenheit(-300)  # error: [below-absolute-zero]
```

---

## Checklist Before Generating

When asked to create literate tests:

- [ ] Identify target language and copy appropriate runner from `${CLAUDE_PLUGIN_ROOT}/scripts/`
- [ ] Create `.md` files in `tests/`, NOT language-specific test files
- [ ] Include TOML frontmatter at top of each test file
- [ ] Include error code index before tests
- [ ] Use correct assertion syntax for language (`#` for Python/Bash, `//` for Rust/C#)
- [ ] Prose explains WHY, not just WHAT
- [ ] One behavior per code block
- [ ] Test names are behavior descriptions

---

## Domain Spec Template

Fill in when generating:

- **What it does:** [DESCRIPTION]
- **What problem it solves:** [USER PAIN]
- **Language:** [LANGUAGE]
- **Code block tag:** [py/rs/sh/etc]
- **Comment prefix:** [#/////--]
- **Error codes:** [EXHAUSTIVE LIST]
- **Public API:** [FUNCTIONS TO TEST]
- **Happy paths:** [LIST]
- **Error cases:** [LIST + WHY]
- **Edge cases:** [LIST + WHY]