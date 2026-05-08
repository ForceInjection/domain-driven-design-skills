---
name: unix-goto-development
description: Expert guidance for unix-goto shell navigation tool development, including architecture, 9-step feature workflow, testing (100% coverage), performance optimization (<100ms targets), and Linear issue integration
---

# unix-goto Development Expert

Comprehensive development expertise for the unix-goto shell navigation system - a high-performance Unix navigation tool with natural language support, sub-100ms cached navigation, and 100% test coverage.

## When to Use This Skill

Use this skill when:
- Developing new features for unix-goto shell navigation system
- Implementing cache-based navigation optimizations
- Adding bookmarks, history, or navigation commands
- Following the standard 9-step feature addition workflow
- Integrating with Linear project management
- Writing comprehensive test suites (100% coverage required)
- Optimizing performance to meet <100ms targets
- Creating API documentation for shell modules
- Debugging navigation or cache issues

Do NOT use this skill for:
- General bash scripting (use generic bash skills)
- Non-navigation shell tools
- Projects without performance requirements
- Simple one-off shell scripts

## Project Overview

### unix-goto System Architecture

unix-goto is a high-performance Unix navigation system designed with five core principles:

1. **Simple** - ONE-line loading (`source goto.sh`), minimal configuration
2. **Fast** - Sub-100ms navigation performance
3. **Lean** - No bloat, no unnecessary dependencies
4. **Tested** - 100% test coverage for core features
5. **Documented** - Clear, comprehensive documentation

### Key Performance Metrics

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Cached navigation | <100ms | 26ms | ✅ Exceeded |
| Cache hit rate | >90% | 92-95% | ✅ Exceeded |
| Speedup ratio | 20-50x | 8x | ⏳ On track |
| Test coverage | 100% | 100% | ✅ Met |
| Cache build time | <5s | 3-5s | ✅ Met |

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface                         │
│  goto, bookmark, recent, back, goto list, goto benchmark   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Core Navigation                          │
│  goto-function.sh - Main routing and path resolution        │
└─────────────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│  Cache System    │ │  Bookmarks   │ │  History         │
│  cache-index.sh  │ │  bookmark-   │ │  history-        │
│                  │ │  command.sh  │ │  tracking.sh     │
│  O(1) lookup     │ │              │ │                  │
│  Auto-refresh    │ │  Add/Remove  │ │  Track visits    │
└──────────────────┘ └──────────────┘ └──────────────────┘
```

### Module Dependencies

**Critical Load Order** (dependencies must load before dependents):

```
goto.sh (loader)
  ├── history-tracking.sh (no dependencies)
  ├── back-command.sh (depends on: history-tracking.sh)
  ├── recent-command.sh (depends on: history-tracking.sh)
  ├── bookmark-command.sh (no dependencies)
  ├── cache-index.sh (no dependencies)
  ├── list-command.sh (depends on: bookmark-command.sh)
  ├── benchmark-command.sh (depends on: cache-index.sh)
  ├── benchmark-workspace.sh (no dependencies)
  └── goto-function.sh (depends on: all above)
```

## Core Knowledge

### The 9-Step Feature Addition Workflow

This is the STANDARD process for adding any feature to unix-goto. Follow ALL nine steps.

#### Step 1: Plan Your Feature

Before writing ANY code, answer these questions:

**Planning Questions:**
- What problem does this solve?
- What's the user interface (commands/flags)?
- What's the expected performance?
- What dependencies exist?
- What tests are needed?
- What documentation is required?

**Planning Template:**
```
Feature: [Name]
Problem: [User pain point]
Interface: [Commands/flags]
Performance: [Target metrics]
Dependencies: [Module dependencies]
Tests: [Test scenarios]
Docs: [API.md, README.md sections]
```

**Example - Recent Directories Feature (CET-77):**
```
Feature: Recent Directories Command
Problem: Users can't quickly revisit recently navigated directories
Interface: goto recent [n]
Performance: <10ms for history retrieval
Dependencies: history-tracking.sh
Tests:
  - List recent directories
  - Handle empty history
  - Limit to N entries
  - Navigate to recent directory by number
Docs: Add to API.md and README.md
```

#### Step 2: Create Module (if needed)

**Module Template:**
```bash
#!/bin/bash
# unix-goto - [Module purpose]
# https://github.com/manutej/unix-goto

# Storage location
GOTO_MODULE_FILE="${GOTO_MODULE_FILE:-$HOME/.goto_module}"

# Main function
goto_module() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        list)
            # Implementation
            ;;
        add)
            # Implementation
            ;;
        --help|-h|help|"")
            echo "goto module - [Description]"
            echo ""
            echo "Usage:"
            echo "  goto module list     [Description]"
            echo "  goto module add      [Description]"
            ;;
        *)
            echo "Unknown command: $subcommand"
            return 1
            ;;
    esac
}
```

**Key Module Patterns:**

1. **Function Naming:**
   - Public functions: no prefix (`goto`, `bookmark`, `recent`)
   - Internal functions: double underscore (`__goto_navigate_to`, `__goto_cache_lookup`)
   - Variables: UPPERCASE for globals, lowercase for locals

2. **Environment Variables:**
   ```bash
   # Always provide defaults
   GOTO_INDEX_FILE="${GOTO_INDEX_FILE:-$HOME/.goto_index}"
   GOTO_CACHE_TTL="${GOTO_CACHE_TTL:-86400}"
   GOTO_SEARCH_DEPTH="${GOTO_SEARCH_DEPTH:-3}"
   ```

3. **Return Codes:**
   - `0` - Success
   - `1` - General error (not found, invalid input)
   - `2` - Multiple matches found (cache lookup only)

#### Step 3: Add to Loader

Edit `goto.sh` to load your module in the correct dependency order:

```bash
# Add to load sequence (respect dependencies)
source "$GOTO_LIB_DIR/history-tracking.sh"
source "$GOTO_LIB_DIR/module.sh"  # NEW - add after dependencies
source "$GOTO_LIB_DIR/back-command.sh"
```

**Dependency Rules:**
- Modules with no dependencies load first
- Modules depending on others load AFTER dependencies
- Main goto-function.sh loads LAST (depends on everything)

#### Step 4: Integrate with Main Function

Edit `lib/goto-function.sh` to route commands to your module:

```bash
goto() {
    case "$1" in
        module)  # NEW
            if command -v goto_module &> /dev/null; then
                shift
                goto_module "$@"
            else
                echo "⚠️  Module command not loaded"
            fi
            return
            ;;
    esac
}
```

#### Step 5: Add Tests (100% Coverage Required)

**Test File Template:**
```bash
#!/bin/bash
# Test suite for [feature] functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/module.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
pass() {
    echo "✓ PASS: $1"
    ((TESTS_PASSED++))
}

fail() {
    echo "✗ FAIL: $1"
    ((TESTS_FAILED++))
}

# Test 1: [Description]
test_feature() {
    # Arrange
    local input="test"

    # Act
    local result=$(function_under_test "$input")

    # Assert
    if [[ "$result" == "expected" ]]; then
        pass "Feature works"
    else
        fail "Feature failed: got '$result'"
    fi
}

# Run tests
test_feature

# Summary
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
```

**Test Categories (ALL Required):**

1. **Unit Tests** - Test individual functions
2. **Integration Tests** - Test module interaction
3. **Edge Cases** - Test boundary conditions
4. **Performance Tests** - Validate speed requirements

**Example from CET-77 (Recent Directories):**
```bash
# Unit test
test_get_recent_dirs() {
    result=$(__goto_recent_dirs 5)
    [ $? -eq 0 ] && pass "Get recent dirs" || fail "Get recent dirs failed"
}

# Integration test
test_goto_recent_navigation() {
    goto recent 1
    [ $? -eq 0 ] && pass "Navigate to recent dir" || fail "Navigation failed"
}

# Edge case
test_empty_history() {
    rm -f ~/.goto_history
    result=$(goto recent)
    [[ "$result" == *"No history"* ]] && pass "Empty history" || fail "Empty history check"
}

# Performance test
test_recent_speed() {
    start=$(date +%s%N)
    __goto_recent_dirs 10
    end=$(date +%s%N)
    duration=$(((end - start) / 1000000))
    [ $duration -lt 10 ] && pass "Recent dirs <10ms" || fail "Too slow: ${duration}ms"
}
```

#### Step 6: Document API

Add to `docs/API.md`:

```markdown
## Module API

### `goto module`

[Description of what the module does]

**Signature:**
```bash
goto module <subcommand>
```

**Subcommands:**
- `list` - [Description]
- `add` - [Description]

**Performance:** [Target metrics]

**Examples:**
```bash
goto module list
goto module add value
```

**Return Codes:**
- 0 - Success
- 1 - Error

**Implementation:** `lib/module.sh`
```

**Example from CET-77:**
```markdown
## Recent Directories

### `goto recent [n]`

Display recently navigated directories in reverse chronological order.

**Signature:**
```bash
goto recent [n]
```

**Parameters:**
- `n` - Optional number of recent directories to display (default: all)

**Performance:** <10ms for history retrieval

**Examples:**
```bash
goto recent        # Show all recent directories
goto recent 5      # Show 5 most recent
```

**Implementation:** `lib/recent-command.sh`
```

#### Step 7: Update User Documentation

Add to `README.md`:

```markdown
### Module

[User-facing description]

```bash
goto module list    # [Description]
goto module add     # [Description]
```
```

#### Step 8: Performance Validation

Validate performance meets targets:

```bash
# Add benchmark if performance-critical
goto benchmark module 10

# Measure overhead
time goto_module list

# Expected: <100ms for navigation, <10ms for lookups
```

**Performance Targets:**
- Cached navigation: <100ms
- Bookmark lookup: <10ms
- Cache speedup: >20x
- Cache hit rate: >90%
- Cache build: <5s

#### Step 9: Linear Issue Update & Commit

**Update Linear Issue:**
- Add implementation comment
- Include test results
- Include performance metrics
- Link to commit
- Move to "Complete"

**Commit Format:**
```bash
git commit -m "feat: implement module feature (CET-XX)

[Detailed explanation]

Features:
- Feature 1
- Feature 2

Performance:
- Metric: value

Tests:
- X/X tests passing
- 100% coverage

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Commit Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `perf:` - Performance improvement
- `refactor:` - Code refactoring
- `test:` - Add or update tests
- `docs:` - Documentation only
- `chore:` - Build, dependencies, or tooling

**Example Commit from CET-85:**
```
feat: implement comprehensive benchmark suite (CET-85)

Implement complete benchmark framework with 5 benchmark tests, helpers,
workspace generation, and CSV results storage.

Features:
- 5 benchmark tests: cached vs uncached, multi-level paths, max depth,
  cache build performance, parallel navigation
- Benchmark helpers library with timing, stats, workspace management
- CSV results storage in ~/.goto_benchmarks/
- Performance target assertions (<100ms navigation)
- Comprehensive statistical analysis (min/max/mean/median/stddev)

Performance:
- Cached navigation: 26ms (target: <100ms) ✓
- Cache build: 3-5s (target: <5s) ✓
- Speedup ratio: 8x (target: >20x, in progress)

Tests:
- 5/5 benchmark tests passing
- All performance targets met for Phase 1

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Feature Checklist

Before submitting ANY feature:

- [ ] Implementation complete
- [ ] Loaded in `goto.sh`
- [ ] Integrated with main `goto` function
- [ ] Tests written and passing (100% coverage)
- [ ] API documented in `docs/API.md`
- [ ] User documentation updated in `README.md`
- [ ] Performance validated (if applicable)
- [ ] Linear issue updated with results
- [ ] Committed with proper message format

### Cache System Architecture

**Purpose:** O(1) folder lookup with automatic refresh

**Implementation:** `lib/cache-index.sh`

**Key Components:**
- `__goto_cache_build` - O(n) index building
- `__goto_cache_lookup` - O(1) hash table lookup
- `__goto_cache_is_valid` - TTL-based validation
- Auto-refresh on stale cache (24-hour TTL)

**Cache File Format:**
```
# unix-goto folder index cache
# Version: 1.0
# Built: 1697558122
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
unix-goto|/Users/manu/Documents/LUXOR/Git_Repos/unix-goto|8|1697558100
GAI-3101|/Users/manu/Documents/LUXOR/PROJECTS/GAI-3101|6|1697558050
```

**Performance:**
- Build time: O(n) - 3-5s for 1200+ folders
- Lookup time: O(1) - <100ms target, 26ms actual
- Storage: ~42KB for 487 folders

**Cache Lookup Return Codes:**
```bash
__goto_cache_lookup "folder"
# Returns:
#   0 - Single match found (path to stdout)
#   1 - Not found in cache
#   2 - Multiple matches found (all paths to stdout)
```

### Navigation Data Flow

```
User Input → goto "project"
    │
    ├─► Check special cases (list, index, benchmark, @bookmark)
    ├─► Check multi-level paths (contains /)
    ├─► Try cache lookup (O(1)) → Cache hit → Navigate
    ├─► Try direct folder match in search paths
    ├─► Recursive search (max depth 3)
    │   ├─► Single match → Navigate
    │   └─► Multiple matches → Show disambiguation
    └─► Natural language AI resolution (if spaces)
```

### Bookmark System Architecture

**Storage:** `~/.goto_bookmarks`

**Format:**
```
work|/Users/manu/work|1697558122
api|/Users/manu/code/api-server|1697558130
```

**Key Functions:**
- `__goto_bookmark_add` - Add with validation
- `__goto_bookmark_remove` - Remove by name
- `__goto_bookmark_get` - Retrieve path (O(1) grep)
- `__goto_bookmark_goto` - Navigate to bookmark

**Performance Target:** <10ms lookup time

**Usage:**
```bash
bookmark add work /path/to/work
bookmark remove work
goto @work
```

### History Tracking Architecture

**Storage:** `~/.goto_history`

**Format:**
```
1697558122|/Users/manu/work
1697558130|/Users/manu/Documents/LUXOR
```

**Key Functions:**
- `__goto_track` - Append with auto-trim (max 100 entries)
- `__goto_get_history` - Retrieve full history
- `__goto_recent_dirs` - Get unique directories in reverse chronological order
- `__goto_stack_push/pop` - Stack-based back navigation

**Example Usage:**
```bash
goto recent        # Show all recent directories
goto recent 5      # Show 5 most recent
back              # Go back to previous directory
```

## Examples

### Example 1: Adding a Recent Directories Feature (CET-77)

**Step 1: Plan**
```
Feature: Recent Directories Command
Problem: Users can't quickly revisit recently navigated directories
Interface: goto recent [n]
Performance: <10ms for history retrieval
Dependencies: history-tracking.sh
Tests: List recent, empty history, limit entries, navigate by number
Docs: API.md, README.md
```

**Step 2: Create Module** (`lib/recent-command.sh`)
```bash
#!/bin/bash
# unix-goto - Recent directories command
# https://github.com/manutej/unix-goto

# Get recent directories
__goto_recent_dirs() {
    local limit="${1:-}"

    if [ ! -f "$GOTO_HISTORY_FILE" ]; then
        return 1
    fi

    # Extract paths, reverse order, unique, limit
    local dirs=$(awk -F'|' '{print $2}' "$GOTO_HISTORY_FILE" | \
                 tac | \
                 awk '!seen[$0]++' | \
                 ${limit:+head -n "$limit"})

    echo "$dirs"
    return 0
}

# Recent command implementation
goto_recent() {
    local limit="${1:-}"

    local dirs=$(__goto_recent_dirs "$limit")

    if [ -z "$dirs" ]; then
        echo "No recent directories"
        return 1
    fi

    echo "$dirs"
    return 0
}
```

**Step 3: Add to Loader** (`goto.sh`)
```bash
source "$GOTO_LIB_DIR/history-tracking.sh"
source "$GOTO_LIB_DIR/recent-command.sh"  # NEW
```

**Step 4: Integrate** (`lib/goto-function.sh`)
```bash
goto() {
    case "$1" in
        recent)
            shift
            goto_recent "$@"
            return
            ;;
    esac
}
```

**Step 5: Add Tests** (`test-recent.sh`)
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/recent-command.sh"

TESTS_PASSED=0
TESTS_FAILED=0

pass() { echo "✓ PASS: $1"; ((TESTS_PASSED++)); }
fail() { echo "✗ FAIL: $1"; ((TESTS_FAILED++)); }

# Test 1: Get recent directories
test_get_recent() {
    result=$(__goto_recent_dirs)
    [ $? -eq 0 ] && pass "Get recent dirs" || fail "Failed"
}

# Test 2: Empty history
test_empty_history() {
    rm -f ~/.goto_history
    result=$(goto_recent)
    [[ "$result" == *"No recent"* ]] && pass "Empty history" || fail "Empty check"
}

# Test 3: Limit results
test_limit_results() {
    result=$(__goto_recent_dirs 5)
    count=$(echo "$result" | wc -l)
    [ $count -le 5 ] && pass "Limit to 5" || fail "Limit failed"
}

# Run tests
test_get_recent
test_empty_history
test_limit_results

echo ""
echo "Passed: $TESTS_PASSED, Failed: $TESTS_FAILED"
[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
```

**Step 6: Document API** (`docs/API.md`)
```markdown
## Recent Directories

### `goto recent [n]`

Display recently navigated directories in reverse chronological order.

**Performance:** <10ms for history retrieval

**Examples:**
```bash
goto recent        # Show all recent directories
goto recent 5      # Show 5 most recent
```
```

**Step 7: Update README** (`README.md`)
```markdown
### Recent Directories

Quickly revisit recently navigated directories:

```bash
goto recent        # Show all recent directories
goto recent 5      # Show 5 most recent
```
```

**Step 8: Validate Performance**
```bash
time goto recent
# Expected: <10ms
```

**Step 9: Commit**
```bash
git commit -m "feat: implement recent directories command (CET-77)

Add goto recent command to display recently navigated directories.

Features:
- List all recent directories
- Limit to N most recent
- Unique directories only
- Reverse chronological order

Performance:
- History retrieval: <10ms ✓

Tests:
- 3/3 tests passing
- 100% coverage

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Example 2: Adding Benchmark Suite (CET-85)

**Complete benchmark implementation with helpers, workspace, and CSV storage.**

**Benchmark Structure** (`benchmarks/bench-cached-vs-uncached.sh`)
```bash
#!/bin/bash
# Benchmark: Cached vs Uncached Navigation Performance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/cache-index.sh"

main() {
    bench_header "Cached vs Uncached Navigation Performance"

    echo "Configuration:"
    echo "  Iterations: 10"
    echo "  Warmup: 3 runs"
    echo ""

    benchmark_cached_vs_uncached

    generate_summary
}

benchmark_cached_vs_uncached() {
    bench_section "Benchmark: Cached vs Uncached Lookup"

    # Setup workspace
    local workspace=$(bench_create_workspace "medium")

    # Phase 1: Uncached lookup
    echo "Phase 1: Uncached lookup (no cache)"
    echo "─────────────────────────────────"

    # Warmup
    bench_warmup "__goto_cache_lookup unix-goto" 3

    # Run benchmark
    local uncached_stats=$(bench_run "uncached" \
        "__goto_cache_lookup unix-goto" 10)

    IFS=',' read -r uc_min uc_max uc_mean uc_median uc_stddev <<< "$uncached_stats"

    bench_print_stats "$uncached_stats" "Uncached Results"

    # Phase 2: Cached lookup
    echo ""
    echo "Phase 2: Cached lookup (with cache)"
    echo "─────────────────────────────────"

    # Build cache
    __goto_cache_build

    # Warmup
    bench_warmup "__goto_cache_lookup unix-goto" 3

    # Run benchmark
    local cached_stats=$(bench_run "cached" \
        "__goto_cache_lookup unix-goto" 10)

    IFS=',' read -r c_min c_max c_mean c_median c_stddev <<< "$cached_stats"

    bench_print_stats "$cached_stats" "Cached Results"

    # Calculate speedup
    local speedup=$(bench_compare "$uc_mean" "$c_mean")

    echo ""
    echo "Speedup Analysis:"
    echo "  Speedup ratio:                               ${speedup}x"

    # Assert targets
    bench_assert_target "$c_mean" 100 "Cached navigation time"

    # Save results
    bench_save_result "cached_vs_uncached" "$uncached_stats" "uncached"
    bench_save_result "cached_vs_uncached" "$cached_stats" "cached"

    # Cleanup
    bench_cleanup_workspace "$workspace"
}

main
exit 0
```

**Benchmark Helpers** (`benchmarks/bench-helpers.sh`)
```bash
#!/bin/bash
# Benchmark helper functions

BENCH_RESULTS_DIR="${BENCH_RESULTS_DIR:-$HOME/.goto_benchmarks}"

# High-precision timing
bench_time_ms() {
    local cmd="$*"
    local start=$(date +%s%N)
    eval "$cmd" > /dev/null 2>&1
    local end=$(date +%s%N)
    echo $(((end - start) / 1000000))
}

# Calculate statistics
bench_calculate_stats() {
    local values=("$@")
    local count=${#values[@]}

    # Sort values
    IFS=$'\n' sorted=($(sort -n <<<"${values[*]}"))

    # Min/Max
    local min=${sorted[0]}
    local max=${sorted[$((count-1))]}

    # Mean
    local sum=0
    for val in "${values[@]}"; do
        sum=$((sum + val))
    done
    local mean=$((sum / count))

    # Median
    local mid=$((count / 2))
    local median=${sorted[$mid]}

    # Standard deviation
    local variance=0
    for val in "${values[@]}"; do
        local diff=$((val - mean))
        variance=$((variance + diff * diff))
    done
    variance=$((variance / count))
    local stddev=$(echo "sqrt($variance)" | bc)

    echo "$min,$max,$mean,$median,$stddev"
}

# Print header
bench_header() {
    local title="$1"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    printf "║  %-62s  ║\n" "$title"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Print section
bench_section() {
    local title="$1"
    echo "$title"
    echo "─────────────────────────────────────────────────────────────────"
}

# Print statistics block
bench_print_stats() {
    local stats="$1"
    local label="$2"

    IFS=',' read -r min max mean median stddev <<< "$stats"

    echo ""
    echo "$label:"
    printf "  Min:                                             %dms\n" "$min"
    printf "  Max:                                             %dms\n" "$max"
    printf "  Mean:                                            %dms\n" "$mean"
    printf "  Median:                                          %dms\n" "$median"
    printf "  Std Dev:                                       %.2fms\n" "$stddev"
}

# Assert performance target
bench_assert_target() {
    local actual="$1"
    local target="$2"
    local label="$3"

    if [ "$actual" -lt "$target" ]; then
        echo "✓ $label meets target: ${actual}ms (target: <${target}ms)"
    else
        echo "✗ $label exceeds target: ${actual}ms (target: <${target}ms)"
    fi
}

# Initialize results directory
bench_init() {
    mkdir -p "$BENCH_RESULTS_DIR"
}

# Save benchmark result
bench_save_result() {
    bench_init

    local name="$1"
    local stats="$2"
    local metadata="${3:-}"

    local timestamp=$(date +%s)
    local results_file="$BENCH_RESULTS_DIR/results.csv"

    # Create header if file doesn't exist
    if [ ! -f "$results_file" ]; then
        echo "timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata" > "$results_file"
    fi

    # Append result
    echo "$timestamp,$name,$metadata,$stats" >> "$results_file"
}

# Create test workspace
bench_create_workspace() {
    local size="${1:-medium}"
    local workspace=$(mktemp -d)

    case "$size" in
        small)
            # 10 folders
            for i in {1..10}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        medium)
            # 50 folders
            for i in {1..50}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
        large)
            # 500 folders
            for i in {1..500}; do
                mkdir -p "$workspace/folder-$i"
            done
            ;;
    esac

    echo "$workspace"
}

# Cleanup workspace
bench_cleanup_workspace() {
    local workspace="$1"
    rm -rf "$workspace"
}

# Run benchmark iterations
bench_run() {
    local name="$1"
    local cmd="$2"
    local iterations="${3:-10}"

    local times=()

    for i in $(seq 1 $iterations); do
        local time=$(bench_time_ms "$cmd")
        times+=("$time")
        printf "  Run %2d: %dms\n" "$i" "$time"
    done

    bench_calculate_stats "${times[@]}"
}

# Warmup iterations
bench_warmup() {
    local cmd="$1"
    local iterations="${2:-3}"

    for i in $(seq 1 $iterations); do
        eval "$cmd" > /dev/null 2>&1
    done
}

# Compare performance
bench_compare() {
    local baseline="$1"
    local optimized="$2"

    local speedup=$(echo "scale=2; $baseline / $optimized" | bc)
    echo "$speedup"
}
```

## Best Practices

### Code Style Standards

**Function Structure:**
```bash
function_name() {
    local param1="$1"
    local param2="${2:-default}"

    # Validate inputs
    if [ -z "$param1" ]; then
        echo "Error: param1 required"
        return 1
    fi

    # Main logic
    local result=$(process "$param1")

    # Return value
    echo "$result"
    return 0
}
```

**Error Handling:**
```bash
# Always check command success
if ! goto index rebuild; then
    echo "Failed to rebuild cache"
    return 1
fi

# Use meaningful error messages
if [ ! -d "$target_dir" ]; then
    echo "❌ Directory not found: $target_dir"
    return 1
fi
```

**Comments:**
```bash
# Good: Explain why, not what
# Cache lookup is O(1) because we use grep on indexed file

# Bad: Explain what (obvious from code)
# Set folder_name to first parameter
folder_name="$1"
```

### Data File Format Pattern

**Standard format:** Pipe-delimited with metadata header

```bash
# Module data file
# Version: 1.0
# Built: [timestamp]
# Format: field1|field2|field3
#---
value1|value2|value3
value1|value2|value3
```

### Performance Optimization Tips

**Cache System:**
- Use cache for all lookups
- Limit recursive search depth
- Avoid redundant filesystem operations
- Use `grep` for fast text matching

**Memory:**
- Cache file: <100KB for 500 folders
- Memory usage: Minimal (shell functions only)
- No persistent processes

### Debugging Tips

**Enable Bash Tracing:**
```bash
set -x
source goto.sh
goto test
set +x
```

**Check Function Existence:**
```bash
if declare -f __goto_cache_lookup > /dev/null; then
    echo "Function loaded"
fi
```

**Debug Cache Issues:**
```bash
# View cache file
cat ~/.goto_index

# Check cache age
stat -f %m ~/.goto_index

# Rebuild and observe
goto index rebuild
```

### Linear Workflow Integration

**Linear Project Details:**
- Team: Ceti-luxor
- Project: unix-goto - Shell Navigation Tool
- Project ID: 7232cafe-cb71-4310-856a-0d584e6f3df0

**Issue Lifecycle:**
```
Backlog → In Progress → Complete
```

**Standard Workflow:**

1. Pick an issue from Phase 3 backlog
2. Move to "In Progress" in Linear
3. Create feature branch: `feature/CET-XX-feature-name`
4. Implement following 9-step workflow
5. Test thoroughly (100% coverage)
6. Commit with proper format
7. Update Linear issue with results
8. Move to "Complete"

**Linear Issue Template:**
```markdown
## Problem
What problem does this solve?

## Solution
How will we solve it?

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests pass
- [ ] Performance targets met

## Performance Targets
- Metric 1: <target>
- Metric 2: <target>

## Dependencies
- Issue CET-XX (if applicable)
```

## Quick Reference

### Essential Commands

```bash
# Development
source goto.sh                 # Load all modules
goto index rebuild             # Rebuild cache
bash test-cache.sh             # Run cache tests
bash test-benchmark.sh         # Run benchmark tests
goto benchmark all             # Run all benchmarks

# Debugging
set -x; goto project; set +x   # Trace execution
declare -F | grep goto         # List functions
cat ~/.goto_index              # View cache

# Git workflow
git checkout -b feature/CET-XX # Create branch
git commit -m "feat: ..."      # Commit with proper format
git push origin feature/CET-XX # Push to remote

# Performance
time goto project              # Measure navigation
goto benchmark navigation      # Benchmark navigation
goto index status              # Check cache health
```

### File Locations

```
~/.goto_index         - Cache file
~/.goto_bookmarks     - Bookmarks file
~/.goto_history       - History file
~/.goto_stack         - Navigation stack
~/.goto_benchmarks/   - Benchmark results directory
```

### Performance Targets Summary

| Metric | Target | Current |
|--------|--------|---------|
| Cached navigation | <100ms | 26ms ✓ |
| Cache build | <5s | 3-5s ✓ |
| Cache hit rate | >90% | 92-95% ✓ |
| Speedup ratio | 20-50x | 8x ⚠ |
| Test coverage | 100% | 100% ✓ |

---

**Skill Version:** 1.0
**Last Updated:** October 2025
**Maintained By:** Manu Tej + Claude Code
**Source Repository:** https://github.com/manutej/unix-goto
