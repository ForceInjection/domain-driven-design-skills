---
name: bash-basics
description: Production-grade Bash fundamentals - syntax, variables, control flow, functions
sasmp_version: "1.3.0"
bonded_agent: 01-bash-fundamentals
bond_type: PRIMARY_BOND
version: "2.0.0"
difficulty: beginner
estimated_time: "4-6 hours"
---

# Bash Basics Skill

> Master the fundamentals of Bash shell scripting with production-ready patterns

## Learning Objectives

After completing this skill, you will be able to:
- [ ] Write syntactically correct Bash scripts
- [ ] Use variables with proper quoting and expansion
- [ ] Implement control flow structures (if, case, loops)
- [ ] Design reusable functions with error handling
- [ ] Apply the strict mode (`set -euo pipefail`)

## Prerequisites

- Basic command line familiarity
- Text editor (vim, nano, or IDE)
- Linux/macOS/WSL environment
- Bash 4.0+ installed

## Core Concepts

### 1. Script Structure
```bash
#!/usr/bin/env bash
# Script: example.sh
# Purpose: Demonstrate basic structure
# Usage: ./example.sh [options]

set -euo pipefail    # Strict mode
IFS=$'\n\t'          # Safe IFS

# Constants
readonly VERSION="1.0.0"

# Main logic
main() {
    echo "Hello, World!"
}

main "$@"
```

### 2. Variables
```bash
# Declaration
name="value"                    # String
declare -i count=0              # Integer
declare -r CONST="immutable"    # Readonly
declare -a array=("a" "b" "c")  # Array
declare -A map=([key]="val")    # Associative array

# Expansion
echo "${name}"                  # Basic
echo "${name:-default}"         # Default if unset
echo "${name:?error msg}"       # Error if unset
echo "${#name}"                 # Length
echo "${name^^}"                # Uppercase
echo "${name,,}"                # Lowercase
```

### 3. Control Structures
```bash
# Conditionals
if [[ -f "$file" ]]; then
    echo "File exists"
elif [[ -d "$file" ]]; then
    echo "Directory exists"
else
    echo "Not found"
fi

# Case statements
case "$option" in
    start) do_start ;;
    stop)  do_stop ;;
    *)     echo "Unknown" ;;
esac

# Loops
for item in "${array[@]}"; do
    echo "$item"
done

while read -r line; do
    process "$line"
done < file.txt
```

### 4. Functions
```bash
function greet() {
    local name="${1:?Name required}"
    echo "Hello, $name!"
}

# With return values
function add() {
    local a="${1:-0}"
    local b="${2:-0}"
    echo $((a + b))
}

result=$(add 5 3)
```

## Common Patterns

### Error Handling Pattern
```bash
die() {
    printf 'ERROR: %s\n' "$1" >&2
    exit "${2:-1}"
}

try_command() {
    if ! "$@"; then
        die "Command failed: $*"
    fi
}
```

### Argument Parsing Pattern
```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)  usage; exit 0 ;;
        -v|--verbose) VERBOSE=true; shift ;;
        --)         shift; break ;;
        -*)         die "Unknown option: $1" ;;
        *)          break ;;
    esac
done
```

## Anti-Patterns

| Don't | Do | Why |
|-------|-----|-----|
| `for f in $(ls)` | `for f in *` | Parsing ls breaks on spaces |
| `` result=`cmd` `` | `result=$(cmd)` | Backticks don't nest |
| `[ $var = x ]` | `[[ "$var" = x ]]` | Unquoted vars break |
| `cd dir; cmd` | `(cd dir && cmd)` | cd can fail silently |

## Practice Exercises

1. **Hello Script**: Write a script that greets by name
2. **File Counter**: Count files in a directory by extension
3. **Backup Script**: Create timestamped backups
4. **Config Parser**: Parse key=value config files

## Troubleshooting

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `unbound variable` | Using undefined var | Use `${var:-}` |
| `syntax error` | Missing quotes | Check bracket matching |
| `command not found` | PATH issue | Use full path |
| `permission denied` | Not executable | `chmod +x script` |

### Debug Techniques
```bash
# Enable trace
set -x

# Verbose PS4
export PS4='+(${BASH_SOURCE}:${LINENO}): '

# Shellcheck
shellcheck script.sh
```

## Resources

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
