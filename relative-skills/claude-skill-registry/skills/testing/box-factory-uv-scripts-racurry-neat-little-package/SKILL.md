---
name: box-factory-uv-scripts
description: UV-specific patterns for single-file Python scripts using inline metadata (PEP 723). Use when creating Python hooks, standalone utilities, or executable scripts in UV-managed projects.
---

# UV Scripts Skill

This skill documents UV-specific patterns for single-file Python scripts with inline dependency metadata. For general Python knowledge, Claude relies on base training.

## Fundamentals

**Single-file Python scripts with embedded dependencies** - UV scripts use PEP 723 inline metadata to declare dependencies directly in the file, enabling self-contained execution without separate requirements.txt or environment setup.

**Key principles:**

- **Self-contained:** All dependencies declared inline
- **Automatic isolation:** UV creates ephemeral environments on-demand
- **Executable:** Shebang pattern enables direct execution
- **Ideal for hooks:** Deterministic, fast, no external configuration

## Workflow Selection

| If you need to...                 | Go to...                                                                 |
| --------------------------------- | ------------------------------------------------------------------------ |
| Create a UV script from scratch   | [Inline Metadata Format](#inline-metadata-format-official-specification) |
| Make a script executable          | [Shebang Pattern](#shebang-pattern-for-executables-best-practice)        |
| Create a Claude Code hook script  | [Common Pattern](#common-pattern-claude-code-hook-script)                |
| Understand when to use UV scripts | [When to Use](#when-to-use-uv-scripts-best-practices)                    |
| Troubleshoot UV script failures   | [Critical Gotchas](#critical-gotchas-best-practices)                     |
| Validate before completion        | [Quality Checklist](#quality-checklist)                                  |

## Official Documentation

Fetch when you need current UV script syntax:

- **<https://docs.astral.sh/uv/guides/scripts/>** - Official UV scripts guide with current syntax

**Deep dive:** [Official Documentation](#official-documentation) - Current UV syntax. **Traverse when:** creating first UV script, syntax errors, need current PEP 723 specification. **Skip when:** familiar with inline metadata format.

## Inline Metadata Format (Official Specification)

Dependencies declared in TOML comment block at top of file:

```python
# /// script
# dependencies = [
#   "requests<3",
#   "rich",
# ]
# ///

import requests
import rich

# Your script logic here
```

**Critical requirement:** The `dependencies` field MUST be provided even if empty:

```python
# /// script
# dependencies = []
# ///
```

**Optional Python version requirement:**

```python
# /// script
# requires-python = ">=3.12"
# dependencies = ["requests<3"]
# ///
```

## Execution Pattern (Official Specification)

**Run with `uv run`:**

```bash
uv run script.py
```

UV automatically:

- Parses inline metadata
- Creates isolated environment
- Installs dependencies
- Executes script

**Important behavior:** When inline metadata exists, project dependencies are ignored (no need for `--no-project`).

## Shebang Pattern for Executables (Best Practice)

For standalone executable scripts (common for hooks):

```python
#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["rich"]
# ///

import rich

if __name__ == "__main__":
    rich.print("[green]Hello from UV script![/green]")
```

**Make executable:**

```bash
chmod +x script.py
./script.py  # Runs directly without `uv run` prefix
```

**Why this works:** Shebang enables PATH-based execution and simplifies hook scripts.

## When to Use UV Scripts (Best Practices)

**Use UV scripts for:**

- Claude Code hooks (deterministic execution, self-contained)
- Standalone utilities (formatting, linting, code generation)
- Shareable scripts (no separate environment setup needed)
- One-off automation tasks

**Example use case (hook script):**

```python
#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["ruff"]
# ///

import subprocess
import sys

result = subprocess.run(["ruff", "check", "."], capture_output=True)
sys.exit(result.returncode)
```

**Don't use UV scripts for:**

- Large applications (use proper UV projects instead)
- Scripts with many files (multi-file projects need project structure)
- Development requiring lockfile management (scripts don't auto-lock)

**Deep dive:** [When to Use UV Scripts](#when-to-use-uv-scripts-best-practices) - Decision framework for UV scripts vs projects. **Traverse when:** choosing between script and project structure, unsure if UV script fits use case. **Skip when:** clear hook or utility script use case.

## Critical Gotchas (Best Practices)

### Gotcha #1: Empty Dependencies Must Be Explicit

**Problem:** Omitting `dependencies` field causes UV to fail.

```python
# /// script
# requires-python = ">=3.11"
# ///
# ERROR: Missing required 'dependencies' field
```

**Solution:** Always include `dependencies`, even if empty:

```python
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
```

### Gotcha #2: Script Locking Requires Explicit Command

**Problem:** Unlike UV projects, scripts don't auto-generate lockfiles.

**Solution:** Explicitly lock if reproducibility needed:

```bash
uv lock --script script.py
```

This creates `script.lock` alongside `script.py`.

### Gotcha #3: Shebang Requires -S Flag

**Problem:** Standard shebang won't work with multi-word commands.

```python
#!/usr/bin/env uv run --script
# ERROR: env can't handle multiple arguments
```

**Solution:** Use `-S` flag:

```python
#!/usr/bin/env -S uv run --script
# SUCCESS: Splits arguments correctly
```

**Deep dive:** [Critical Gotchas](#critical-gotchas-best-practices) - Common failures with solutions. **Traverse when:** UV script fails, dependency errors, shebang not working, lockfile issues. **Skip when:** script runs successfully, familiar with UV patterns.

## Quality Checklist

Before finalizing a UV script:

**Format (official requirements):**

- Script starts with `# /// script` comment block
- `dependencies` field present (even if empty)
- Comment block closed with `# ///`
- No syntax errors in TOML metadata

**Best practices:**

- Shebang uses `-S` flag for executables
- Dependencies pinned appropriately (exact versions for reproducibility, ranges for flexibility)
- Script made executable with `chmod +x` if intended for direct execution
- Hook scripts return proper exit codes (0 = success, non-zero = failure)

## Common Pattern: Claude Code Hook Script

**Template for hook scripts:**

```python
#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "tool-name>=1.0.0",
# ]
# ///

import subprocess
import sys
import os

def main():
    """Hook logic here."""
    # Get file paths from environment
    file_paths = os.environ.get("CLAUDE_FILE_PATHS", "").split()

    if not file_paths:
        sys.exit(0)  # Nothing to process

    # Run tool
    result = subprocess.run(
        ["tool-name", *file_paths],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        sys.exit(2)  # Block operation

    sys.exit(0)  # Success

if __name__ == "__main__":
    main()
```

**Hook registration in hooks.json:**

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "./hooks/format_code.py"
        }
      ]
    }
  ]
}
```

## Python Script Naming Convention (Critical)

**Use underscores, not hyphens, in Python script names.**

```text
✅ format_code.py     (importable, testable)
✅ lint_on_write.py   (importable, testable)
❌ format-code.py     (cannot import - hyphen is minus operator)
❌ lint-on-write.py   (cannot import - hyphen is minus operator)
```

**Why this matters:** Hyphenated Python files require `importlib.util` workarounds for testing. Using underscores allows normal `import` statements and pytest discovery.

**Note:** Shell scripts (`.sh`) can use hyphens freely - this only affects Python files.

## Documentation References

**Official UV documentation:**

- <https://docs.astral.sh/uv/guides/scripts/> - Current syntax and features
- <https://peps.python.org/pep-0723/> - PEP 723 specification for inline metadata

**Related patterns:**

- Fetch box-factory:hook-design skill for hook lifecycle and execution patterns
- UV project documentation for multi-file Python projects
