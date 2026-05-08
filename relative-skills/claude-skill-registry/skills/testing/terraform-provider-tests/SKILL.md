---
name: terraform-provider-tests
description: Analyze and improve Terraform provider test coverage using terraform-plugin-testing v1.13.3+ patterns. Use when (1) analyzing test coverage gaps, (2) adding missing tests (drift detection, import, idempotency), (3) converting legacy patterns to modern state checks, (4) tracking optional field coverage, (5) verifying test quality, or (6) validating example accuracy. Supports automated coverage analysis, guided pattern improvements, and example testing.
---

# Terraform Provider Tests

Analyze test coverage and improve Terraform provider acceptance tests using modern patterns from terraform-plugin-testing v1.13.3+.

## Summary & Next Steps

**When invoked, I will:**

1. Run gap analysis: `python3 scripts/analyze_gap.py ./internal/provider/ --output ./ai_reports/tf_provider_tests_gap_$(date +%Y%m%d_%H%M%S).md`
2. Generate timestamped report in `./ai_reports/`
3. Provide **succinct summary** with:
   - Overall grade (A/B/C)
   - Top 3 findings
   - Recommended next action

**Priority levels:**

- **P1 (Critical)**: Missing drift/import tests, heavy legacy usage (>20 calls)
- **P2 (Important)**: Missing idempotency, moderate legacy (5-20 calls)
- **P3 (Cleanup)**: Light legacy (<5 calls)

**Communication style**: Be succinct. Provide summary + single recommended next step.

## Quick Start

### Common Usage Scenarios

**Analyze test modernization gaps**:

```bash
python3 scripts/analyze_gap.py ./internal/provider/ --output ./ai_reports/tf_provider_tests_gap_$(date +%Y%m%d_%H%M%S).md
```

**Analyze a specific test file**:
"Analyze resource_example_test.go for coverage gaps"

**Verify compilation after changes**:

```bash
./.claude/skills/terraform-provider-tests/verify_compilation.sh ./internal/provider/
```

**Validate all examples**:

```bash
export BCM_ENDPOINT="https://..." BCM_USERNAME="..." BCM_PASSWORD="..."
./.claude/skills/terraform-provider-tests/test-examples.sh
```

### Recommended Naming Convention

All gap analysis reports should use the `tf_provider_tests_*` naming pattern in the `./ai_reports/` directory:

| Report Type          | Filename Pattern                                          | Example                                                   |
| -------------------- | --------------------------------------------------------- | --------------------------------------------------------- |
| Initial gap analysis | `./ai_reports/tf_provider_tests_gap_YYYYMMDD_HHMMSS.md`   | `./ai_reports/tf_provider_tests_gap_20251123_225128.md`   |
| Final analysis       | `./ai_reports/tf_provider_tests_final_YYYYMMDD_HHMMSS.md` | `./ai_reports/tf_provider_tests_final_20251123_230145.md` |
| One-time analysis    | `./ai_reports/tf_provider_tests_gap.md`                   | `./ai_reports/tf_provider_tests_gap.md`                   |

**Timestamp format**: `$(date +%Y%m%d_%H%M%S)` generates `YYYYMMDD_HHMMSS`

## Workflow Decision Tree

**Starting a modernization project?**
→ Begin with [Gap Analysis](#phase-1-gap-analysis-automated)

**Have gap analysis report?**
→ Proceed to [Pattern Application](#phase-3-pattern-application-guided)

**Made code changes?**
→ Run [Verification](#phase-4-verification-automated)

**All changes complete?**
→ Complete [Testing](#phase-5-testing)

**Need to validate examples?**
→ Run [Example Testing](#phase-6-example-testing-automated)

## Phase 1: Gap Analysis (Automated)

**Tool**: `scripts/analyze_gap.py`

Automatically scan test files and generate comprehensive gap analysis report.

### Usage

```bash
python3 scripts/analyze_gap.py <test_directory> [--output report.md]
```

**Example** (recommended naming pattern):

```bash
python3 scripts/analyze_gap.py ./internal/provider/ --output ./ai_reports/tf_provider_tests_gap_$(date +%Y%m%d_%H%M%S).md
```

**Simple filename** (for one-time analysis):

```bash
python3 scripts/analyze_gap.py ./internal/provider/ --output ./ai_reports/tf_provider_tests_gap.md
```

### What It Detects

- ✅ Legacy `Check: resource.TestCheckResourceAttr()` patterns
- ✅ Missing drift detection tests
- ✅ Missing import tests
- ✅ Missing idempotency checks
- ✅ Modern pattern adoption statistics
- ✅ ID consistency tracking issues
- ✅ Prioritized recommendations

### Output

Markdown report with:

- Codebase statistics (line counts by file type, test-to-impl ratio)
- Executive summary with overall grade (A/B/C)
- File-by-file analysis with status
- Prioritized recommendations (High/Medium/Low)
- Modern pattern quick reference

**Review the report to understand**:

- Which files need the most work
- What patterns are missing
- Overall modernization progress

## Phase 2: Prioritization

Focus on high-impact changes first:

### Priority 1 (Critical) ⚠️

- Missing drift detection tests
- Missing import tests
- Heavy legacy usage (>20 calls per file)

### Priority 2 (Important) 📋

- Missing idempotency checks
- Moderate legacy usage (5-20 calls)
- Mixed patterns (legacy + modern)

### Priority 3 (Cleanup) 📝

- Light legacy usage (<5 calls)
- Documentation improvements

## Phase 3: Pattern Application (Guided)

For each file, apply patterns in this order:

### Step 1: Add Missing Tests

**Missing drift detection?**
→ See [references/pattern_templates.md → "Drift Detection Test"](#references)

**Missing import test?**
→ See [references/pattern_templates.md → "Import Test Step"](#references)

**Missing idempotency checks?**
→ See [references/pattern_templates.md → "Idempotency Verification"](#references)

### Step 2: Convert Legacy to Modern

Replace `Check: resource.ComposeAggregateTestCheckFunc()` with `ConfigStateChecks`.

**Before**:

```go
Check: resource.ComposeAggregateTestCheckFunc(
    resource.TestCheckResourceAttr("example_resource.test", "name", "expected"),
),
```

**After**:

```go
ConfigStateChecks: []statecheck.StateCheck{
    statecheck.ExpectKnownValue(
        "example_resource.test",
        tfjsonpath.New("name"),
        knownvalue.StringExact("expected"),
    ),
},
```

**Type mapping** → See [references/pattern_templates.md](#references)

### Step 3: Add Required Imports

```go
import (
    "github.com/hashicorp/terraform-plugin-testing/helper/resource"
    "github.com/hashicorp/terraform-plugin-testing/plancheck"
    "github.com/hashicorp/terraform-plugin-testing/statecheck"
    "github.com/hashicorp/terraform-plugin-testing/knownvalue"
    "github.com/hashicorp/terraform-plugin-testing/tfjsonpath"
    "github.com/hashicorp/terraform-plugin-testing/compare"
)
```

For drift tests, also add: `"context"`, `"encoding/json"`, `"time"`

## Phase 4: Verification (Automated)

**Tool**: `scripts/verify_compilation.sh`

Quick compilation check without running tests.

### Usage

```bash
./.claude/skills/terraform-provider-tests/scripts/verify_compilation.sh <test_directory>
```

**Example**:

```bash
./.claude/skills/terraform-provider-tests/scripts/verify_compilation.sh ./internal/provider/
```

### What It Validates

- ✅ Go syntax correctness
- ✅ No compilation errors
- ✅ Import completeness
- ✅ Statistics (file count, test count)

**If compilation fails**:

1. Review error messages
2. Check for missing imports
3. Verify block closures
4. Re-run after fixes

## Phase 5: Testing

### Quick Compile Check

```bash
go test -c ./internal/provider/ -o /tmp/provider_tests
```

### Parallel Test Execution (Recommended)

**Tool**: `scripts/run_tests_parallel.sh`

Run acceptance tests concurrently per file for faster execution.

**Usage**:

```bash
# Run all acceptance tests with 15 concurrent files
./.claude/skills/terraform-provider-tests/scripts/run_tests_parallel.sh

# Run only resource tests with higher concurrency
./.claude/skills/terraform-provider-tests/scripts/run_tests_parallel.sh --resources-only -c 8

# Run only data source tests
./.claude/skills/terraform-provider-tests/scripts/run_tests_parallel.sh --data-sources-only

# Run tests matching specific pattern
./.claude/skills/terraform-provider-tests/scripts/run_tests_parallel.sh -p "TestAccCMPartSoftwareImage"

# Run tests from specific file
./.claude/skills/terraform-provider-tests/scripts/run_tests_parallel.sh -f resource_cmpart_softwareimage_test.go

# Verbose output with detailed test logs
./.claude/skills/terraform-provider-tests/scripts/run_tests_parallel.sh --verbose
```

**Options**:

- `-d, --dir DIR` - Test directory (default: ./internal/provider)
- `-p, --pattern PATTERN` - Test pattern to match (default: TestAcc)
- `-c, --concurrency N` - Max concurrent test files (default: 4)
- `-t, --timeout DURATION` - Timeout per test file (default: 30m)
- `-f, --file FILE` - Run only tests from specific file
- `--resources-only` - Run only resource tests
- `--data-sources-only` - Run only data source tests
- `--verbose` - Show detailed test output
- `--no-color` - Disable colored output

**Benefits**:

- ⚡ Faster execution (4x-8x speedup with proper concurrency)
- 📊 Per-file progress tracking
- 🎯 Aggregated summary with pass/fail counts
- 🔍 Automatic failure highlighting

### Single Test (Sequential)

```bash
TF_ACC=1 go test -v -timeout 30m ./internal/provider/ -run "^TestAccResource_Specific$"
```

### Full Suite (Sequential)

```bash
TF_ACC=1 go test -v -timeout 120m ./internal/provider/
```

## Phase 6: Example Testing (Automated)

**Tool**: `scripts/test-examples.sh`

Validate all Terraform examples in the `examples/` directory by building the provider, executing examples, and cleaning up test resources.

### Usage

```bash
# Run all examples (requires BCM credentials)
export BCM_ENDPOINT="https://172.21.15.254:8081"
export BCM_USERNAME="root"
export BCM_PASSWORD="your-password"
./scripts/test-examples.sh

# Quick validation with existing provider build
SKIP_BUILD=true ./scripts/test-examples.sh

# Test only data sources (parallel, ~10s)
./scripts/test-examples.sh --data-sources-only

# Test only resources (sequential, ~19s)
./scripts/test-examples.sh --resources-only

# Debug a failing test
./scripts/test-examples.sh --verbose --no-cleanup

# Cleanup orphaned resources from failed tests
./scripts/test-examples.sh --cleanup-only
```

### What It Validates

- ✅ Examples compile and initialize successfully
- ✅ Provider configuration is correct
- ✅ Schema validation passes
- ✅ Plan generation works (all examples)
- ✅ Apply/destroy cycle succeeds (test-citest examples only)
- ✅ Resources are properly cleaned up

### Execution Strategy

**Data Sources** (parallel):

- Run up to 4 examples concurrently (configurable with `PARALLEL_LIMIT`)
- Fast validation (init → validate → plan)
- No actual resources created

**Resources** (sequential):

- Run one at a time (state-modifying operations)
- Full lifecycle testing for test-citest examples (init → validate → plan → apply → destroy)
- Plan-only validation for documentation examples

### Test Phases

1. **Environment validation** - Verify BCM credentials
2. **Provider build** - Compile provider binary (skippable with `SKIP_BUILD=true`)
3. **Example discovery** - Find all `.tf` files in `examples/data-sources/*/` and `examples/resources/*/`
4. **Example testing** - Execute terraform commands on each example
5. **Cleanup** - Remove test resources (citest-\* prefix) with retry logic

### Environment Variables

**Required**:

- `BCM_ENDPOINT` - BCM API endpoint
- `BCM_USERNAME` - BCM authentication username
- `BCM_PASSWORD` - BCM authentication password

**Optional**:

- `PROVIDER_VERSION` - Provider version (default: 0.1.0)
- `SKIP_BUILD` - Skip build phase (default: false)
- `PARALLEL_LIMIT` - Max parallel data source tests (default: 4)
- `CLEANUP_RETRIES` - Max cleanup retry attempts (default: 4)
- `VERBOSE` - Enable verbose logging (default: false)

### Exit Codes

- `0` - All tests passed, cleanup successful
- `1` - One or more tests failed
- `2` - Configuration error (missing env vars)
- `3` - Provider build failed
- `130` - Interrupted by user (Ctrl+C)

### Best Practices

**Example Naming**:

- Use `citest-` prefix for resources that need cleanup
- Examples in `test-citest/` directories undergo full apply/destroy
- Other examples are validated with plan-only

**Provider Configuration**:

- Examples should NOT include provider blocks
- Script automatically injects provider config with environment variables
- Use `insecure_skip_verify = true` for self-signed certs

**Resource Cleanup**:

- Script automatically cleans up resources with `citest-` prefix
- Uses exponential backoff retry for cleanup failures
- Run `--cleanup-only` to manually cleanup orphaned resources

### When to Use Example Testing

Run example testing when:

- Adding new examples to `examples/` directory
- Modifying provider schema or behavior
- Before releasing a new provider version
- Debugging example-specific issues
- Validating documentation accuracy

### Integration with CI/CD

Example testing complements acceptance tests:

**Acceptance Tests** (`make testacc`):

- Full CRUD operation validation
- Import and drift detection
- Comprehensive error handling
- Run on every commit

**Example Tests** (`./scripts/test-examples.sh`):

- Documentation accuracy validation
- End-user workflow verification
- Multi-example compatibility
- Run before releases

## Completion Criteria

A fully modernized test file has:

- ✅ Zero legacy `Check` blocks
- ✅ All state assertions use `statecheck.ExpectKnownValue()`
- ✅ Idempotency checks after Create and Update
- ✅ Import test with `ImportStateVerify`
- ✅ Drift detection test (resources only)
- ✅ ID consistency tracking with `CompareValue`
- ✅ All tests compile and pass
- ✅ All examples validate successfully

## ID Consistency Tracking

The analyzer detects inconsistent usage of the `.id` property across test steps.

### Why It Matters

Resource IDs should remain stable across:

- Initial creation
- Import operations
- Update operations

Inconsistent ID handling can indicate:

- Resource recreation instead of in-place updates
- Import state mismatches
- State management bugs

### What the Analyzer Detects

| Issue                   | Description                                                      | Severity |
| ----------------------- | ---------------------------------------------------------------- | -------- |
| Missing CompareValue    | Multiple test steps without ID consistency tracking              | High     |
| Partial ID tracking     | Some steps track ID, others don't                                | Medium   |
| Legacy ID checks        | Uses `TestCheckResourceAttr` for "id" instead of modern patterns | Medium   |
| No ID verification      | Resource tests that never verify ID                              | High     |
| Modern without tracking | Uses `ExpectKnownValue` for ID but no `CompareValue`             | Low      |

### Correct Pattern

```go
func TestAccResource_Complete(t *testing.T) {
    // Initialize ID tracker BEFORE Steps
    compareID := statecheck.CompareValue(compare.ValuesSame())

    resource.Test(t, resource.TestCase{
        Steps: []resource.TestStep{
            // Step 1: Create - track ID
            {
                Config: testAccResourceConfig(name),
                ConfigStateChecks: []statecheck.StateCheck{
                    compareID.AddStateValue("example_resource.test", tfjsonpath.New("id")),
                },
            },
            // Step 2: Import - track ID
            {
                ResourceName:      "example_resource.test",
                ImportState:       true,
                ImportStateVerify: true,
                ConfigStateChecks: []statecheck.StateCheck{
                    compareID.AddStateValue("example_resource.test", tfjsonpath.New("id")),
                },
            },
            // Step 3: Update - track ID
            {
                Config: testAccResourceConfig(name, "updated"),
                ConfigStateChecks: []statecheck.StateCheck{
                    compareID.AddStateValue("example_resource.test", tfjsonpath.New("id")),
                },
            },
        },
    })
}
```

### Common Anti-Patterns

**Anti-pattern 1: Legacy ID checks**

```go
// ❌ Bad - uses legacy pattern
Check: resource.ComposeAggregateTestCheckFunc(
    resource.TestCheckResourceAttrSet("example_resource.test", "id"),
),
```

**Anti-pattern 2: Inconsistent tracking**

```go
// ❌ Bad - only tracks ID in Create step, not Import/Update
Steps: []resource.TestStep{
    {
        Config: testAccConfig(name),
        ConfigStateChecks: []statecheck.StateCheck{
            compareID.AddStateValue("example_resource.test", tfjsonpath.New("id")), // ✅
        },
    },
    {
        ResourceName: "example_resource.test",
        ImportState:  true,
        // ❌ Missing: compareID.AddStateValue
    },
    {
        Config: testAccConfig(name, "updated"),
        // ❌ Missing: compareID.AddStateValue
    },
}
```

**Anti-pattern 3: No tracking at all**

```go
// ❌ Bad - multiple steps with no ID consistency tracking
compareID := statecheck.CompareValue(compare.ValuesSame()) // Declared but never used!
```

## Common Pitfalls

**Missing imports**
→ Add all required imports from Phase 3, Step 3

**Wrong knownvalue matcher**
→ Match types correctly: String→StringExact, Bool→Bool, Int64→Int64Exact

**Duplicate validation**
→ Remove `Check` block, keep only `ConfigStateChecks`

## References

This skill includes comprehensive reference documentation:

### references/workflow.md

Complete step-by-step modernization workflow with detailed guidance for each phase, common pitfalls, and completion criteria.

**When to read**: For detailed phase-by-phase instructions.

### references/pattern_templates.md

Ready-to-use code templates for all modern patterns:

- Legacy to modern conversion examples
- Idempotency verification
- Import test steps
- Drift detection tests (complete template)
- ID consistency tracking
- knownvalue type matchers
- Complete test examples

**When to read**: When applying specific patterns to code.

### references/hashicorp_official.md

Consolidated HashiCorp official documentation:

- TestCase and TestStep structure
- State checks (statecheck package)
- Plan checks (plancheck package)
- Value comparers (compare package)
- Import mode testing
- Official testing patterns

**When to read**: For authoritative information on terraform-plugin-testing features.

## Time Estimates

- **Simple file** (1-2 tests, <10 legacy checks): 15-30 minutes
- **Medium file** (3-5 tests, 10-30 legacy checks): 30-60 minutes
- **Complex file** (>5 tests, >30 legacy checks): 1-2 hours

**Total project** (7 resource + 7 data source files): 4-8 hours across multiple sessions.

## Hybrid Approach

This skill uses a **hybrid approach**:

**Automation** for:

- ✅ Gap analysis (find legacy patterns, missing tests)
- ✅ Compilation verification (syntax checking)

**Guided assistance** for:

- ✅ Code changes (apply patterns with context)
- ✅ Complex operations (drift tests, API integration)
- ✅ Decision making (prioritization, test design)

This balance maintains control while automating tedious tasks.
