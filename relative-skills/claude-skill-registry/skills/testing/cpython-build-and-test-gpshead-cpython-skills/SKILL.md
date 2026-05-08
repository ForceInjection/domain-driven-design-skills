---
name: cpython-build-and-test
description: Use this skill when configuring, building, or rebuilding CPython from source, running tests, or debugging test failures. Covers ./configure with --with-pydebug, make commands, ccache for faster rebuilds, Argument Clinic regeneration (make clinic), unittest-based testing with python -m test (NOT pytest), --match filtering, code coverage collection, and platform-specific build paths (Linux vs macOS).
---

# Building and Testing CPython

## Building CPython

**ONLY build in a `build/` subdirectory** at repo root. Never build in the source tree.

### Setup and Configuration

```bash
# Build directory setup
REPO_ROOT=<path-to-cpython-git-repo>
BUILD_DIR=$REPO_ROOT/build
```

#### ccache Setup (Recommended)

ccache dramatically speeds up rebuilds by caching compilation results. Check if available:

```bash
which ccache
```

**If ccache is not installed**:
- macOS (Homebrew): Install directly with `brew install ccache` (no sudo required)
- Containerized/root environments: Install directly with `apt-get install -y ccache` or `dnf install -y ccache`
- Otherwise, ask the user for permission to install:
  - Debian/Ubuntu: `sudo apt-get install ccache`
  - Fedora/RHEL: `sudo dnf install ccache`

**Configure with ccache** (if available):
```bash
cd $BUILD_DIR && CC="ccache gcc" ../configure --with-pydebug
```

**Configure without ccache** (fallback):
```bash
cd $BUILD_DIR && ../configure --with-pydebug
```

#### Performance/Benchmarking Builds

When doing benchmarking or performance measurement of C code changes, **omit `--with-pydebug`** from configure:

```bash
cd $BUILD_DIR && CC="ccache gcc" ../configure  # No --with-pydebug
```

Debug builds have significant overhead that distorts performance measurements. However, **do not use `--enable-optimizations`** unless explicitly asked—it enables PGO (Profile-Guided Optimization) which is slow to compile. Non-PGO release builds are sufficient for the majority of performance comparison work.

```bash
# Build using all CPU cores (initial or incremental)
make -C $BUILD_DIR -j $(nproc)
```

**Platform notes**:
- Linux: `BUILT_PY=$BUILD_DIR/python`
- macOS: `BUILT_PY=$BUILD_DIR/python.exe` (note .exe extension)
- Windows: Ask user how to build (uses Visual Studio, different process)

### Argument Clinic

After editing `.c` files that change function signatures, docstrings, or argument specs:
```bash
make -C $BUILD_DIR clinic
```

**NEVER** edit files in `**/clinic/**` subdirectories - they're auto-generated.

### Verify Build

```bash
$BUILT_PY --version
$BUILT_PY -c "print('Hello from CPython!')"
```

### Build Troubleshooting

- **Missing dependencies**: Configure reports missing libraries
- **Stale build**: `make clean` in BUILD_DIR and rebuild
- **Clinic files out of sync**: `make -C $BUILD_DIR clinic`
- **Clean build**: `rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR && CC="ccache gcc" ../configure --with-pydebug && make -j $(nproc)` (omit `CC=...` if ccache unavailable)

## Running CPython Tests

**Critical rules:**
1. **NEVER use `pytest`** - CPython tests are `unittest` based
2. **Use `--match` not `-k`** for filtering - takes a glob pattern (this is not pytest!)

Prerequisite: `BUILT_PY=build/python` or `build/python.exe`

### Running Tests

```bash
# Single test module (recommended - proper discovery, parallel execution)
$BUILT_PY -m test test_zipfile -j $(nproc)

# Multiple modules
$BUILT_PY -m test test_csv test_json -j $(nproc)

# Direct execution (quick but may miss test packages)
$BUILT_PY Lib/test/test_csv.py

# Specific test by glob pattern (use --match, NOT -k!)
$BUILT_PY -m test test_zipfile --match "*large*" -j $(nproc)
$BUILT_PY -m test test_csv --match "TestDialect*"
$BUILT_PY -m test test_json --match "TestEncode.test_encode_string"

# Full test suite (ASK FIRST - takes significant time!)
make -C $BUILD_DIR test

# Useful flags: -v (verbose), -f (fail fast), --list-tests (show all), --help
```

**Test packages** (directories like `test_asyncio/`) require `load_tests()` in `__init__.py` to work with `python -m test`.

### Code Coverage

```bash
# Collect coverage (uses trace mechanism via libregrtest)
$BUILT_PY -m test --coverage test_csv test_json --coveragedir .claude/coverage/ -j $(nproc)

# Reports go to specified coveragedir
```

### Debugging

For interactive debugging (pdb/lldb/gdb) or testing REPL features: **Control a tmux session**.

Add `breakpoint()` in test code, then run with `-v` for verbose output.
