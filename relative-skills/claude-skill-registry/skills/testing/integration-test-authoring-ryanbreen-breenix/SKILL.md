---
name: integration-test-authoring
description: This skill should be used when creating new integration tests for Breenix kernel features. Use for writing shared QEMU tests with checkpoint signals, creating xtask test commands, adding test workflows, and following Breenix testing patterns.
---

# Integration Test Authoring for Breenix

Create integration tests for kernel features using Breenix testing patterns.

## Purpose

Breenix uses integration tests that run the actual kernel in QEMU and verify behavior through serial output. This skill provides patterns for creating robust tests.

## Breenix Testing Architecture

### Shared QEMU Pattern

Most tests use `tests/shared_qemu.rs` to share a single QEMU instance:

**Benefits**:
- All tests run in ~45 seconds (vs 10+ minutes for separate QEMU instances)
- Tests run in sequence in one kernel boot
- Shared setup and teardown

**Test Structure**:
```rust
#[test]
fn test_memory_allocation() {
    shared_qemu::run_test("memory", "✅ MEMORY TEST COMPLETE");
}
```

### Checkpoint Signals

Tests wait for specific strings in serial output:

**Common signals**:
- `🎯 KERNEL_POST_TESTS_COMPLETE 🎯` - All POST tests done
- `✅ [FEATURE] TEST COMPLETE` - Specific test done
- `USERSPACE OUTPUT:` - Userspace execution
- Custom markers for specific tests

## Creating a New Integration Test

### Step 1: Add Kernel-Side Test Code

**Location**: `kernel/src/` (appropriate module)

```rust
#[cfg(feature = "testing")]
pub fn test_my_feature() {
    use crate::serial::serial_println;

    serial_println!("=== Testing My Feature ===");

    // Test setup
    let result = setup_feature();
    assert!(result.is_ok(), "Setup failed");

    // Test operations
    let outcome = perform_operation();
    assert_eq!(outcome, expected_value);

    // Signal completion
    serial_println!("✅ MY_FEATURE TEST COMPLETE");
}
```

**Key points**:
- Guard with `#[cfg(feature = "testing")]`
- Use `serial_println!` for output
- Add clear start marker
- Add unique completion signal

### Step 2: Call from POST or main

**Option A: Add to POST (Power-On Self Test)**

`kernel/src/test_post.rs`:
```rust
#[cfg(feature = "testing")]
pub fn run_post_tests() {
    // ... existing tests ...

    crate::my_module::test_my_feature();

    serial_println!("🎯 KERNEL_POST_TESTS_COMPLETE 🎯");
}
```

**Option B: Create specialized test entry point**

For tests that need specific setup:
```rust
#[cfg(feature = "testing")]
pub fn run_specialized_tests() {
    crate::my_module::test_my_feature();
    serial_println!("🎯 SPECIALIZED_TESTS_COMPLETE 🎯");
}
```

### Step 3: Add Rust Integration Test

**Location**: `tests/test_my_feature.rs`

```rust
#![cfg(test)]

mod shared_qemu;

#[test]
fn test_my_feature() {
    shared_qemu::run_test(
        "my_feature",
        "✅ MY_FEATURE TEST COMPLETE"
    );
}
```

**For tests that need isolation**:
```rust
#[test]
#[ignore]  // Run separately: cargo test test_special -- --ignored
fn test_special_case() {
    // Custom QEMU setup for this test
}
```

### Step 4: (Optional) Add xtask Command

For complex or frequently-run tests, add to `xtask/src/main.rs`:

```rust
#[derive(StructOpt)]
enum Cmd {
    Ring3Smoke,
    Ring3Enosys,
    MyFeatureTest,  // New
}

fn my_feature_test() -> Result<()> {
    println!("Starting My Feature Test...");

    let serial_output_file = "target/xtask_my_feature_output.txt";
    let _ = fs::remove_file(serial_output_file);

    // Start QEMU
    let mut child = Command::new("cargo")
        .args(&[
            "run", "--release",
            "--features", "testing",
            "--bin", "qemu-uefi",
            "--",
            "-serial", &format!("file:{}", serial_output_file),
            "-display", "none",
        ])
        .spawn()?;

    // Monitor for signal
    let start = Instant::now();
    let timeout = Duration::from_secs(30);
    let mut found = false;

    while start.elapsed() < timeout {
        if let Ok(mut file) = fs::File::open(serial_output_file) {
            let mut contents = String::new();
            if file.read_to_string(&mut contents).is_ok() {
                if contents.contains("✅ MY_FEATURE TEST COMPLETE") {
                    found = true;
                    break;
                }
            }
        }
        thread::sleep(Duration::from_millis(100));
    }

    let _ = child.kill();
    let _ = child.wait();

    if found {
        println!("✅ My Feature test passed");
        Ok(())
    } else {
        bail!("❌ My Feature test failed");
    }
}
```

### Step 5: (Optional) Add CI Workflow

For features needing dedicated CI:

`.github/workflows/my-feature-test.yml`:
```yaml
name: My Feature Test

on:
  push:
    paths:
      - 'kernel/src/my_module/**'
      - 'tests/test_my_feature.rs'

jobs:
  my-feature:
    runs-on: ubuntu-latest
    timeout-minutes: 20

    steps:
      - uses: actions/checkout@v4

      - name: Install Rust
        uses: actions-rs/toolchain@v1
        with:
          toolchain: nightly-2025-06-24
          override: true
          target: x86_64-unknown-none
          components: rust-src, llvm-tools-preview

      - name: Cache cargo
        uses: actions/cache@v4
        with:
          path: |
            ~/.cargo/registry
            ~/.cargo/git
            target
          key: cargo-${{ runner.os }}-${{ hashFiles('**/Cargo.lock') }}

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y qemu-system-x86 ovmf nasm

      - name: Run test
        run: cargo test test_my_feature

      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: my-feature-logs
          path: logs/*.log
          retention-days: 7
```

## Test Patterns

### Pattern 1: Simple Feature Test

**Use when**: Testing a single subsystem or function

```rust
// Kernel side
#[cfg(feature = "testing")]
pub fn test_allocator() {
    serial_println!("=== Allocator Test ===");

    let ptr = allocate(1024);
    assert!(!ptr.is_null());

    deallocate(ptr, 1024);

    serial_println!("✅ ALLOCATOR TEST COMPLETE");
}

// Test side
#[test]
fn test_allocator() {
    shared_qemu::run_test("allocator", "✅ ALLOCATOR TEST COMPLETE");
}
```

### Pattern 2: Userspace Test

**Use when**: Testing userspace execution or syscalls

```rust
// Create userspace test program
// userspace/tests/my_test.rs

#![no_std]
#![no_main]

use libbreenix::{sys_write, sys_exit};

#[no_mangle]
pub extern "C" fn _start() -> ! {
    sys_write(1, b"My test output\n");
    sys_exit(0);
}

// Build with userspace/tests/build.sh

// Kernel side - load and execute
#[cfg(feature = "testing")]
pub fn test_userspace_my_feature() {
    let binary = include_bytes!("../../userspace/tests/my_test.elf");
    create_and_run_process("my_test", binary);
    // Process will print "My test output" via syscall
}

// Test side
#[test]
fn test_userspace_my_feature() {
    shared_qemu::run_test("userspace", "My test output");
}
```

### Pattern 3: Sequential Tests

**Use when**: Testing a workflow with multiple steps

```rust
#[cfg(feature = "testing")]
pub fn test_process_lifecycle() {
    serial_println!("=== Process Lifecycle Test ===");

    serial_println!("STEP 1: Creating process");
    let pid = create_process();
    assert!(pid > 0);
    serial_println!("✅ STEP 1 COMPLETE");

    serial_println!("STEP 2: Running process");
    run_process(pid);
    serial_println!("✅ STEP 2 COMPLETE");

    serial_println!("STEP 3: Terminating process");
    terminate_process(pid);
    serial_println!("✅ STEP 3 COMPLETE");

    serial_println!("✅ PROCESS_LIFECYCLE TEST COMPLETE");
}
```

### Pattern 4: Regression Test

**Use when**: Preventing a specific bug from returning

```rust
// Document the original issue
#[cfg(feature = "testing")]
pub fn test_page_fault_regression() {
    serial_println!("=== Page Fault Regression Test ===");
    serial_println!("Tests fix from DIRECT_EXECUTION_FIX.md");

    // Reproduce the scenario that used to fail
    let process = create_userspace_process();
    // This used to cause double fault at int 0x80
    process.trigger_syscall();

    serial_println!("✅ NO DOUBLE FAULT - Regression test passed");
}
```

## Best Practices

1. **Clear signals**: Use unique, greppable completion markers
2. **Descriptive names**: Test name should describe what's being tested
3. **Guard with feature flag**: All test code behind `#[cfg(feature = "testing")]`
4. **Serial output**: Use `serial_println!` for test communication
5. **Document purpose**: Comment explaining what the test verifies
6. **Handle failures**: Use assertions that provide useful error messages
7. **Cleanup**: Ensure resources are freed even if test fails
8. **Timeout appropriately**: Set realistic timeouts in xtask or CI

## Debugging Tests

### Test fails locally

```bash
# Run with visual output
BREENIX_VISUAL_TEST=1 cargo test test_my_feature

# Use quick debug for iteration
kernel-debug-loop/scripts/quick_debug.py \
  --signal "✅ MY_FEATURE TEST COMPLETE" \
  --timeout 15

# Check logs
grep "MY_FEATURE" logs/breenix_*.log
```

### Test fails in CI only

```bash
# Download CI artifacts
# Analyze with ci-failure-analysis
ci-failure-analysis/scripts/analyze_ci_failure.py \
  target/xtask_*_output.txt

# Check for environment differences
# - Timeout too short for CI
# - Missing dependencies
# - Timing-dependent behavior
```

## Summary

Integration test authoring requires:
- Kernel-side test code with checkpoint signals
- Rust integration test using shared QEMU
- Optional xtask command for complex tests
- Optional CI workflow for automated testing
- Clear completion signals
- Appropriate timeouts
- Comprehensive documentation

Follow existing test patterns in `tests/` for consistency.
