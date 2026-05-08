---
name: dart-flutter-mcp
description: |
  Provides Flutter and Dart development workflows using dart-mcp tools. Triggers when working with .dart files, pubspec.yaml, or when user mentions Flutter, widget, Riverpod, Freezed, or Dart development. MUST BE USED for Flutter project work involving dart_analyzer, dart_run_tests, hot_reload, or IDE MCP tools.
---

<objective>
Master the Dart/Flutter MCP (Model Context Protocol) server tools for efficient Flutter development. These tools provide direct integration with the Dart toolchain and running Flutter apps, enabling static analysis, testing, debugging, and live app inspection without leaving the conversation.
</objective>

<quick_start>
<common_workflows>
**Validate code quality:**
```
dart_analyzer → Check for errors/warnings
dart_format → Ensure consistent style
```

**Run tests:**
```
dart_analyzer → Catch compile errors first
dart_run_tests → Execute tests
```

**Debug running app:**
```
get_runtime_errors → Capture current errors
get_widget_tree → Inspect UI hierarchy
[make fix]
hot_reload → Apply changes
get_runtime_errors → Verify fix
```

**Understand an API:**
```
dart_resolve_symbol → Get signature and documentation
```
</common_workflows>
</quick_start>

<tool_categories>
<dart_tools>
**Static Analysis and Code Quality:**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `dart_analyzer` | Static analysis for errors, warnings, hints | After writing code, before running tests |
| `dart_format` | Apply consistent code formatting | After all code changes |
| `dart_fix` | Apply automated fixes for analyzer issues | When analyzer reports fixable issues |

**Testing:**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `dart_run_tests` | Execute Dart/Flutter tests | After writing tests, in TDD cycles |

**Symbol Resolution:**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `dart_resolve_symbol` | Get symbol documentation and signatures | Understanding APIs, checking method signatures |

**Package Discovery:**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `pub_dev_search` | Search pub.dev for packages | Finding packages for specific functionality |
</dart_tools>

<flutter_runtime_tools>
**Runtime Debugging (requires running app):**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `get_runtime_errors` | Fetch current runtime errors and stack traces | First step in debugging, verify fixes |
| `get_widget_tree` | Inspect widget hierarchy at runtime | Layout debugging, finding widget issues |
| `hot_reload` | Apply code changes without losing state | After making fixes, during development |
| `hot_restart` | Full restart preserving debug session | When hot reload fails or state is corrupted |

**Prerequisites:** App must be running in debug mode with Dart tooling daemon connected.
</flutter_runtime_tools>

<ide_tools>
**IDE Integration (mcp__ide__*):**

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `mcp__ide__getDiagnostics` | Get IDE diagnostics for a file | Check for issues in specific file |
| `mcp__ide__readFile` | Read file contents | Understanding existing code |
| `mcp__ide__writeFile` | Write/create files | Creating new files |
| `mcp__ide__getCurrentEditor` | Get active editor content | Context-aware operations |
| `mcp__ide__getOpenEditors` | Get currently open files | Understanding user context |
| `mcp__ide__searchInProject` | Search across project files | Finding patterns, usages |
| `mcp__ide__getProjectStructure` | Get project file tree | Understanding project layout |
</ide_tools>
</tool_categories>

<workflows>
<tdd_workflow>
**TDD Red-Green-Refactor with MCP Tools:**

```
1. Write failing test
2. dart_run_tests → Verify RED (test fails)
3. Write minimal implementation
4. dart_run_tests → Verify GREEN (test passes)
5. Refactor code
6. dart_run_tests → Verify still GREEN
7. dart_analyzer → Check for issues
8. dart_format → Apply consistent style
```

This cycle ensures tests drive implementation and code quality stays high.
</tdd_workflow>

<debug_workflow>
**Runtime Debugging Workflow:**

```
1. Verify app is connected:
   get_runtime_errors → If fails, app not connected

2. Gather evidence:
   get_runtime_errors → Capture current errors
   get_widget_tree → Inspect UI structure

3. Analyze error patterns:
   - RenderFlex overflow → Layout constraints issue
   - Null check operator → Null safety issue
   - setState after dispose → Lifecycle issue

4. Make targeted fix (use mcp__ide__readFile/writeFile)

5. Apply and verify:
   hot_reload → Apply changes
   get_runtime_errors → Should be empty or reduced

6. If hot_reload fails:
   dart_analyzer → Check for syntax errors
   hot_restart → Try full restart
```
</debug_workflow>

<code_quality_workflow>
**Pre-Commit Quality Check:**

```
1. dart_analyzer → Must show 0 errors, 0 warnings
2. dart_run_tests → All tests must pass
3. dart_format → Apply consistent formatting
4. dart_fix → Apply any remaining automated fixes
```
</code_quality_workflow>
</workflows>

<tool_details>
<dart_analyzer_detail>
**dart_analyzer**

Performs static analysis on Dart/Flutter code.

**Returns:**
- Errors (compilation failures)
- Warnings (potential issues)
- Hints (suggestions)
- Lints (style violations)

**Best Practices:**
- Run BEFORE tests to catch compile errors early
- Run AFTER code changes to verify quality
- Fix ALL errors before proceeding
- Address warnings unless explicitly justified
- Target zero issues in production code

**Example Output:**
```
lib/src/auth/repository.dart:45:12
  ERROR: The argument type 'String' can't be assigned to parameter type 'int'

lib/src/widgets/profile.dart:23:5
  WARNING: Unused import 'package:flutter/foundation.dart'

Analysis complete. 1 error, 1 warning.
```
</dart_analyzer_detail>

<dart_run_tests_detail>
**dart_run_tests**

Executes Dart/Flutter tests with filtering and coverage.

**Options:**
- Filter by file: `path/to/test_file.dart`
- Filter by name: `--name "test description"`
- With coverage: `--coverage`
- Specific reporter: `--reporter expanded`

**Best Practices:**
- Run `dart_analyzer` first to catch compile errors
- Use specific test filters during development
- Run full suite before commits
- Check coverage for new code

**Interpreting Results:**
```
✓ should return user when authenticated
✓ should throw when token expired
✗ should handle network timeout
  Expected: Left<NetworkFailure>
  Actual: Right<User>

2 passed, 1 failed
```
</dart_run_tests_detail>

<dart_resolve_symbol_detail>
**dart_resolve_symbol**

Resolves symbols to their documentation and type signatures.

**Use Cases:**
- Understanding API methods before use
- Checking parameter types and return types
- Finding documentation for Flutter widgets
- Verifying method signatures

**Example:**
```
Query: "TaskEither.tryCatch"

Result:
TaskEither<L, R>.tryCatch(
  Future<R> Function() run,
  L Function(Object error, StackTrace stackTrace) onError,
)

Creates a TaskEither that runs the given function and catches any errors.
```

**Best Practices:**
- Use before implementing unfamiliar APIs
- Verify signatures match your usage
- Check for nullability in return types
</dart_resolve_symbol_detail>

<runtime_tools_detail>
**get_runtime_errors**

Fetches current runtime errors from a running Flutter app.

**Requires:** App running in debug mode with daemon connected.

**Returns:**
- Exception type and message
- Stack trace with file:line references
- Widget that threw (if applicable)

**Best Practices:**
- ALWAYS run first when debugging
- Re-run AFTER every fix attempt
- Empty result = no current errors

**Common Error Patterns:**
- `RenderFlex overflowed` → Layout constraints
- `Null check operator used on null value` → Null safety
- `setState() called after dispose()` → Lifecycle bug
- `type 'Null' is not a subtype` → Type mismatch

---

**get_widget_tree**

Inspects the widget hierarchy of a running Flutter app.

**Returns:**
- Widget tree structure
- Widget types and keys
- Constraints and sizes (if RenderObject attached)

**Use For:**
- Layout debugging
- Finding unexpected widgets
- Verifying widget structure

**Look For:**
- Unbounded constraints → Missing Expanded/Flexible
- Unexpected nesting → Widget composition issues
- Missing widgets → Conditional rendering bugs

---

**hot_reload**

Applies code changes to a running app without losing state.

**When It Works:**
- Method body changes
- Widget build changes
- Most code changes

**When It Fails:**
- Syntax errors in code
- Static field initializer changes
- Main function changes
- New dependencies added

**If Hot Reload Fails:**
1. Run `dart_analyzer` to check for errors
2. Fix any syntax/type errors
3. Try `hot_restart` for full restart
</runtime_tools_detail>
</tool_details>

<anti_patterns>
**Common Mistakes:**

- **Running tests before analyzer** → Wastes time on compile errors
- **Skipping get_runtime_errors** → Guessing at fixes without evidence
- **Ignoring analyzer warnings** → Technical debt accumulation
- **Hot reload with syntax errors** → Will always fail
- **Not verifying after fixes** → May introduce regressions

**Correct Order:**
```
dart_analyzer → dart_run_tests → dart_format
get_runtime_errors → [fix] → hot_reload → get_runtime_errors
```
</anti_patterns>

<success_criteria>
MCP tool usage is correct when:

- `dart_analyzer` shows 0 errors before running tests
- `dart_run_tests` executes without compile failures
- `get_runtime_errors` returns empty after fix verification
- `hot_reload` succeeds (no syntax errors in code)
- Code quality workflow runs in correct order
- Runtime debugging gathers evidence before making changes

**Uncertainty Handling:**
- NEVER guess at solutions when evidence is insufficient. If you cannot determine the answer with confidence, explicitly state: "I don't have enough information to confidently assess this."
</success_criteria>

<reference_guides>
For advanced patterns and detailed examples:

- **Runtime debugging patterns**: [references/runtime-debugging.md](references/runtime-debugging.md)
- **IDE tool integration**: [references/ide-tools.md](references/ide-tools.md)
</reference_guides>
