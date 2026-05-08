---
name: forge-lang-bash
description: Bash/Shell scripting standards including shellcheck, shfmt, and bats testing. Use when working with shell scripts (.sh, .bash).
---

# Bash/Shell Development

## Testing

```bash
# Run bats tests
bats test/

# Run specific test file
bats test/test_script.bats

# Run with TAP output
bats --tap test/
```

## Static Analysis

```bash
# ShellCheck (lint)
shellcheck script.sh

# Check all scripts
shellcheck *.sh scripts/*.sh

# Exclude specific rules
shellcheck -e SC2086 script.sh
```

## Formatting

```bash
# Format with shfmt
shfmt -w script.sh

# Check without changing
shfmt -d script.sh

# Format all scripts
shfmt -w -i 4 *.sh
```

## Project Structure

```
project/
├── bin/
│   └── main.sh
├── lib/
│   ├── utils.sh
│   └── config.sh
├── test/
│   ├── test_main.bats
│   └── test_utils.bats
└── README.md
```

## Script Template

```bash
#!/usr/bin/env bash
#
# script.sh - Brief description
#
# Usage: script.sh [options] <args>
#

set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Functions
usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [options] <args>

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output

EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Main logic here
    echo "Hello from ${SCRIPT_NAME}"
}

main "$@"
```

## Bats Test Template

```bash
#!/usr/bin/env bats

setup() {
    # Setup code runs before each test
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

@test "script runs without error" {
    run ./bin/main.sh
    assert_success
}

@test "script shows help with -h" {
    run ./bin/main.sh -h
    assert_success
    assert_output --partial "Usage:"
}

@test "script fails on invalid option" {
    run ./bin/main.sh --invalid
    assert_failure
}
```

## TDD Cycle Commands

```bash
# RED: Write test, run to see it fail
bats test/

# GREEN: Implement, run to see it pass
bats test/

# REFACTOR: Clean up, ensure tests still pass
shellcheck *.sh && shfmt -d *.sh && bats test/
```

## Best Practices

- Always use `set -euo pipefail` at the start
- Quote all variables: `"$var"` not `$var`
- Use `[[` instead of `[` for conditionals
- Prefer `$(command)` over backticks
- Use `local` for function variables
- Add `readonly` for constants
