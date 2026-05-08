---
name: shell-scripting-standards
description: Essential patterns for reliable shell scripts - portable shebangs, error handling, quoting rules, functions, testing with Bats, and ShellCheck integration.
---

# Shell Scripting Standards

Industry-standard shell scripting practices for writing reliable, maintainable, and secure bash scripts.

## Level 1: Quick Reference

### Portable Shebang

```bash
#!/usr/bin/env bash
# Finds bash in PATH - works across systems
# Never use #!/bin/bash (non-portable)
```

### Essential Error Handling

```bash
#!/usr/bin/env bash
set -euo pipefail
# -e: Exit on error | -u: Exit on undefined | -o pipefail: Exit on pipe failure

trap cleanup EXIT ERR
cleanup() {
  local exit_code=$?
  rm -f "$temp_file"
  exit "$exit_code"
}
```

### Variable Quoting Rules

```bash
# ALWAYS quote variables to prevent word splitting
echo "$variable"           # Correct
echo $variable             # Wrong - word splitting

# Arrays need different quoting
files=("file 1.txt" "file 2.txt")
for file in "${files[@]}"; do
  echo "$file"
done

# Command substitution
current_dir="$(pwd)"       # Modern (correct)
current_dir=`pwd`          # Deprecated (avoid)
```

### Function Pattern

```bash
function_name() {
  local param1="$1"
  local param2="${2:-default}"

  if [[ -z "$param1" ]]; then
    echo "Error: param1 required" >&2
    return 1
  fi

  echo "Result"
  return 0
}
```

### Argument Parsing

```bash
usage() {
  cat << USAGE
Usage: ${0##*/} [-v] [-o OUTPUT] FILE
Options:
  -v          Verbose mode
  -o OUTPUT   Output file
  -h          Show this help
USAGE
}

verbose=false
output=""

while getopts "vo:h" opt; do
  case "$opt" in
    v) verbose=true ;;
    o) output="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

file="${1:?Error: FILE required}"
```

### Logging Pattern

```bash
readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $*" >&2; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
```

### File Operations

```bash
# Safe file checks
[[ -f "$file" ]]        # File exists and is regular
[[ -d "$dir" ]]         # Directory exists
[[ -r "$file" ]]        # File is readable

# Safe temp files
temp_file=$(mktemp)
temp_dir=$(mktemp -d)

# Read file line by line
while IFS= read -r line; do
  echo "Line: $line"
done < "$file"
```

### Common Patterns

```bash
# Check if command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Retry logic
retry() {
  local max=3 attempt=1
  while ((attempt <= max)); do
    "$@" && return 0
    echo "Attempt $attempt failed" >&2
    ((attempt++)); sleep 2
  done
  return 1
}

# Confirm prompt
confirm() {
  read -rp "${1:-Are you sure?} [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]]
}
```

### ShellCheck Integration

```bash
# Install: apt-get install shellcheck | brew install shellcheck
shellcheck script.sh

# Disable specific warnings (sparingly)
# shellcheck disable=SC2086
echo $unquoted_on_purpose

# CI/CD integration
find . -name "*.sh" -exec shellcheck {} +
```

---

## Level 2: Implementation Guide

### Script Structure

```bash
#!/usr/bin/env bash
#
# Script Name: backup-manager.sh
# Description: Manages automated backups with rotation
# Version: 1.0.0
#

set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"

readonly EXIT_SUCCESS=0 EXIT_ERROR=1 EXIT_USAGE=2

main() {
  parse_arguments "$@"
  validate_dependencies
  perform_backup
  log_info "Backup completed successfully"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

### Error Handling and Cleanup

```bash
error_handler() {
  local line_no=$1 error_code=$2
  log_error "Error on line $line_no: exit code $error_code"
  cleanup
  exit "$error_code"
}

trap 'error_handler ${LINENO} $?' ERR

cleanup() {
  local exit_code=$?
  [[ -n "${temp_dir:-}" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -n "${lock_file:-}" && -f "$lock_file" ]] && rm -f "$lock_file"
  return "$exit_code"
}

trap cleanup EXIT INT TERM

# Lock file pattern (prevent concurrent runs)
acquire_lock() {
  local lock_file="$1" lock_fd=200
  eval "exec $lock_fd>\"$lock_file\""
  flock -n "$lock_fd" || { log_error "Another instance running"; exit 1; }
}
```

### Logging System

```bash
readonly LOG_LEVEL_DEBUG=0 LOG_LEVEL_INFO=1 LOG_LEVEL_WARN=2 LOG_LEVEL_ERROR=3
log_level=$LOG_LEVEL_INFO

log_message() {
  local level=$1 color=$2 prefix=$3; shift 3
  if ((level >= log_level)); then
    echo -e "${color}[${prefix}]${NC} $*" >&2
    [[ -w "$(dirname "${LOG_FILE:-/tmp/log}")" ]] && \
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${prefix}] $*" >> "${LOG_FILE:-/tmp/log}"
  fi
}

log_debug() { log_message $LOG_LEVEL_DEBUG "$BLUE" "DEBUG" "$@"; }
log_info()  { log_message $LOG_LEVEL_INFO "$GREEN" "INFO" "$@"; }
log_warn()  { log_message $LOG_LEVEL_WARN "$YELLOW" "WARN" "$@"; }
log_error() { log_message $LOG_LEVEL_ERROR "$RED" "ERROR" "$@"; }
```

### Input Validation

```bash
validate_file() {
  local file="$1" desc="${2:-File}"
  [[ -z "$file" ]] && { log_error "$desc path is empty"; return 1; }
  [[ ! -f "$file" ]] && { log_error "$desc does not exist: $file"; return 1; }
  [[ ! -r "$file" ]] && { log_error "$desc is not readable: $file"; return 1; }
  return 0
}

validate_directory() {
  local dir="$1" desc="${2:-Directory}" writable="${3:-false}"
  [[ -z "$dir" ]] && { log_error "$desc path is empty"; return 1; }
  [[ ! -d "$dir" ]] && { log_error "$desc does not exist: $dir"; return 1; }
  [[ "$writable" == "true" && ! -w "$dir" ]] && { log_error "$desc not writable: $dir"; return 1; }
  return 0
}

validate_number() {
  local val="$1" desc="${2:-Value}" min="${3:-}" max="${4:-}"
  [[ ! "$val" =~ ^[0-9]+$ ]] && { log_error "$desc must be a number: $val"; return 1; }
  [[ -n "$min" && "$val" -lt "$min" ]] && { log_error "$desc must be >= $min"; return 1; }
  [[ -n "$max" && "$val" -gt "$max" ]] && { log_error "$desc must be <= $max"; return 1; }
  return 0
}
```

### Dependency Management

```bash
validate_dependencies() {
  local missing=() required=(rsync gzip tar date mktemp)
  for cmd in "${required[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if ((${#missing[@]} > 0)); then
    log_error "Missing required commands: ${missing[*]}"
    exit 1
  fi
}

check_optional_tool() {
  local tool="$1" fallback="$2"
  command -v "$tool" >/dev/null 2>&1 && echo "$tool" || echo "$fallback"
}
```

### Testing with Bats

```bash
# test-script.bats
#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  source ./script.sh
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "validate_file succeeds for existing file" {
  touch "$TEST_DIR/test.txt"
  run validate_file "$TEST_DIR/test.txt"
  [ "$status" -eq 0 ]
}

@test "validate_file fails for missing file" {
  run validate_file "$TEST_DIR/missing.txt"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "does not exist" ]]
}
```

### Security Best Practices

```bash
# 1. Never eval user input
case "$user_input" in
  start) start_service ;;
  stop) stop_service ;;
  *) log_error "Invalid command" ;;
esac

# 2. Sanitize paths
sanitize_path() {
  local path allowed_dir="/home/user/allowed"
  path="$(realpath -m "$1")"
  [[ "$path" != "$allowed_dir"* ]] && { log_error "Path outside allowed"; return 1; }
  echo "$path"
}

# 3. Secure temporary files
temp_file="$(mktemp)" && chmod 600 "$temp_file"

# 4. Avoid command injection - use arrays
local -a files
mapfile -t files < <(find . -name "${pattern}*.txt")

# 5. Validate environment
[[ "$PATH" =~ (^|:)\.(:|$) ]] && { log_error "PATH contains ."; return 1; }

# 6. Secure password handling
read_password() {
  read -rsp "Enter password: " password; echo >&2
  some_command <<< "$password"
  unset password
}
```

### Performance Optimization

```bash
# Use built-ins instead of external commands
echo "${file%/*}"           # Fast (built-in)
dirname "$file"             # Slow (spawns process)

# Avoid unnecessary subshells
count=$(wc -l < file.txt)   # Fast
count=$(cat file.txt | wc -l) # Slow

# Use bash built-ins for string operations
result="${item^^}"          # Uppercase (Bash 4+)

# Batch operations
cp *.txt /dest/             # Single operation
```

### Cross-Platform Compatibility

```bash
detect_os() {
  case "$(uname -s)" in
    Linux*)   echo "linux" ;;
    Darwin*)  echo "macos" ;;
    CYGWIN*|MINGW*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

portable_sed() {
  [[ "$(detect_os)" == "macos" ]] && sed -i '' "$@" || sed -i "$@"
}
```

### Quick ShellCheck Reference

| Code | Issue | Fix |
|------|-------|-----|
| SC2086 | Unquoted variable | `echo "$var"` |
| SC2006 | Backticks deprecated | `$(cmd)` |
| SC2155 | Declare and assign separately | `local var; var=$(cmd)` |
| SC2034 | Unused variable | Prefix with `_` |
| SC2064 | Unquoted trap | `trap 'cleanup' EXIT` |

---

## Level 3: Deep Dive Resources

### Documentation & Guides

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [Bash FAQ](https://mywiki.wooledge.org/BashFAQ)

### Testing Frameworks

- [Bats-core](https://github.com/bats-core/bats-core) - TAP-compliant testing
- [shUnit2](https://github.com/kward/shunit2) - xUnit-style framework
- [ShellSpec](https://shellspec.info/) - BDD-style testing

### Static Analysis

- [ShellCheck](https://github.com/koalaman/shellcheck) - 300+ checks
- [shfmt](https://github.com/mvdan/sh) - Shell formatter

### Extended Reference

See [REFERENCE.md](./REFERENCE.md) for:

- Complete script templates
- Advanced argument parsing with long options
- JSON parsing with jq
- API request patterns with curl
- Configuration management
- Signal handling
- Process management
- Debugging techniques

### Bundled Resources

1. `config/.shellcheckrc` - ShellCheck configuration
2. `templates/script-template.sh` - Production script template
3. `templates/library.sh` - Reusable function library
4. `templates/test-template.bats` - Bats testing template
5. `scripts/install-shell-tools.sh` - Automated tooling setup
6. `resources/shell-best-practices.md` - Comprehensive reference

### Quick Wins

1. Add shebang: `#!/usr/bin/env bash`
2. Add error handling: `set -euo pipefail`
3. Add cleanup trap: `trap cleanup EXIT`
4. Quote all variables: `"$var"` not `$var`
5. Use `[[` instead of `[` for tests
6. Replace backticks with `$()`
7. Run ShellCheck and fix warnings

---

*Last Updated: 2025-12-30*
*Skill Version: 2.0.0*
