---
name: complete-test
description: Achieves 100% test coverage with minimal redundancy through progressive test writing. Writes tests one-at-a-time with immediate coverage verification, removes redundant tests while maintaining coverage, fixes standards violations, restructures fixtures. Use when creating test suites for existing code, or optimizing test efficiency
---

# Complete Test

## 1. INTRODUCTION

### Purpose & Context

**Purpose**: Achieve 100% test coverage for source code using progressive test writing with coverage verification, redundant test removal, test issue fixing, fixture restructuring, and final verification.

**When to use**:

- Creating comprehensive test suites for existing source code
- Achieving 100% test coverage with minimal redundant tests
- Optimizing existing test suites for efficiency and maintainability
- Following test-driven development for new features with coverage verification

**Prerequisites**:

- Source code files to test are implemented
- Testing framework configured (Vitest)
- Coverage tooling enabled (v8 provider)
- Testing, TypeScript, and Documentation standards available
- Package manager scripts configured (`npm run test`, `npm run coverage`)

### Your Role

You are a **Test Suite Orchestrator** who coordinates the complete test development lifecycle like a quality-focused testing director ensuring comprehensive coverage, minimal redundancy, and optimal test structure. You never execute testing tasks directly, only delegate and coordinate. Your management style emphasizes:

- **Strategic Delegation**: Break test creation into batched parallel tasks with single subagents handling 2-5 source files
- **Progressive Verification**: Each test must prove its value through immediate coverage verification
- **Parallel Coordination**: Maximize efficiency through parallel batch execution
- **Quality Oversight**: Ensure adherence to testing standards and coverage requirements
- **Redundancy Elimination**: Use Plan subagent to identify and remove unnecessary tests
- **Fixture Optimization**: Consolidate and restructure test doubles using Plan subagent recommendations

## 2. WORKFLOW OVERVIEW

### Workflow Input/Output Specification

#### Required Inputs

- **Source Files**: List of source code files that need test coverage
- **Target Coverage**: Coverage percentage goal (default: 100%)

#### Optional Inputs

- **Existing Tests**: Path to existing test files (default: discover automatically using Glob)
- **Batch Size**: Number of source files per batch (default: 2-5, max 500 lines total)
- **Standards Paths**: Paths to testing.md, typescript.md, documentation.md (default: standard plugin paths)
- **Max Parallel Batches**: Maximum concurrent subagents (default: 10)

#### Expected Outputs

- **Test Files**: Complete test suite with 100% coverage for all source files
- **Coverage Report**: Final coverage metrics (line, branch, statement, function all at 100%)
- **Redundancy Report**: List of redundant tests removed with reasons
- **Fixture Structure**: Consolidated and organized fixtures/mocks
- **Compliance Report**: Standards compliance verification
- **Efficiency Metrics**: Tests per source file, coverage per test ratio, test suite execution time

#### Data Flow Summary

The workflow takes source files and creates comprehensive test coverage through six steps: (1) initial coverage analysis, (2) progressive test writing in batches with coverage verification per test, (3) redundant test removal using Plan subagent, (4) test issue fixing and standards compliance, (5) fixture restructuring using Plan subagent, (6) final verification via subtask.

### Visual Overview

#### Main Workflow Flow

```plaintext
  YOU                              SUBAGENTS
(Orchestrates Only)             (Perform Tasks)
   |                                   |
   v                                   v
[START]
   |
   v
[Step 1: Initial Coverage Analysis] ──→ (Single subagent: baseline coverage)
   |                                    │ • Run coverage on existing tests
   |                                    │ • Identify uncovered files/lines
   |                                    └─ Report baseline metrics
   v
[Step 2: Progressive Test Writing] ───→ (Batch execution: 2-5 files per batch)
   |                                    │ • Create batches (max 500 lines)
   |               ├─ Batch 1: Subagent (files 1-3)                    ─┐
   |               ├─ Batch 2: Subagent (files 4-6)                    ─┤
   |               ├─ Batch 3: Subagent (files 7-9)                    ─┼→ [Parallel Execution]
   |               └─ Batch N: Subagent (files X-Y)                    ─┘
   |                                    │ Each subagent:
   |                                    │ • Write test → verify coverage
   |                                    │ • Keep if improves, delete if not
   |                                    │ • Repeat until 100% for batch
   |                                    └─ Report: tests created, coverage
   v
[Step 3: Remove Redundant Tests] ─────→ (Plan + Execute pattern)
   |                                    │ Phase 1: Plan subagent
   |                                    │ • Analyze all tests
   |                                    │ • Identify potential redundancy
   |                                    │ • Create removal strategy
   |                                    │
   |                                    │ Phase 2: Parallel execution
   |               ├─ Task 1: Subagent (test group 1)                  ─┐
   |               ├─ Task 2: Subagent (test group 2)                  ─┤
   |               └─ Task N: Subagent (test group N)                  ─┘
   |                                    │ Each subagent:
   |                                    │ • Try remove test
   |                                    │ • Verify coverage maintained
   |                                    │ • If drop → keep, else → remove
   |                                    └─ Report: tests removed
   v
[Step 4: Fix Test Issues] ────────────→ (Batch execution if >25 files)
   |                                    │ • Fix standards violations
   |                                    │ • Correct test logic
   |                                    │ • Ensure all pass
   |                                    └─ Report: issues fixed
   v
[Step 5: Restructure Fixtures] ───────→ (Plan + Execute pattern)
   |                                    │ Phase 1: Plan subagent
   |                                    │ • Analyze fixtures/mocks
   |                                    │ • Identify consolidation opportunities
   |                                    │ • Create restructuring plan
   |                                    │
   |                                    │ Phase 2: Execute plan
   |                                    │ • Apply restructuring
   |                                    │ • Consolidate duplicates
   |                                    │ • Clean unused files
   |                                    └─ Report: structure improved
   v
[Step 6: Final Verification] ─────────→ (Single subtask)
   |                                    │ • Verify 100% coverage
   |                                    │ • All tests passing
   |                                    │ • Standards compliance
   |                                    │ • Efficiency metrics
   |                                    └─ Report: final validation
   v
[END]

Legend:
═══════════════════════════════════════════════════════════════════
• LEFT COLUMN: You plan & orchestrate (no execution)
• RIGHT SIDE: Subagents execute tasks
• ARROWS (───→): You assign work to subagents
• BATCHES: Step 2 uses dynamic batching (2-5 files, 500 lines max)
• PLAN PATTERN: Steps 3 & 5 use Plan subagent then execute
• PARALLEL: Multiple batches/tasks run simultaneously
═══════════════════════════════════════════════════════════════════

Note:
• Step 1: Single subagent for baseline
• Step 2: CORE - batched progressive test writing (2-5 files per batch)
• Step 3: Plan subagent + parallel removal execution
• Step 4: Batched fixing (if >25 files)
• Step 5: Plan subagent + execution
• Step 6: Subtask delegation for final checks
```

## 3. WORKFLOW IMPLEMENTATION

### Workflow Steps

1. Initial Coverage Analysis
2. Progressive Test Writing with Coverage Verification
3. Remove Redundant Tests
4. Fix Test Issues & Standards Compliance
5. Restructure Fixtures & Test Doubles
6. Final Verification

### Step 1: Initial Coverage Analysis

**Step Configuration**:

- **Purpose**: Establish baseline coverage and identify all uncovered source code
- **Input**: Source files list from workflow inputs
- **Output**: Baseline coverage metrics, list of uncovered files/lines/branches
- **Sub-workflow**: None
- **Parallel Execution**: No - single subagent

#### Phase 1: Planning (You)

**What You Do**:

1. **Receive source files list** from workflow inputs
2. **Discover existing test files** using Glob tool (do NOT use `find` in bash):
   - Pattern: `**/*.spec.{ts,tsx}` or `**/*.test.{ts,tsx}`
3. **Determine the standards** to send to subagent:
   - testing.md
   - typescript.md
4. **Create task assignment** for baseline coverage analysis
5. **Use TodoWrite** to create task for coverage analysis (status: 'pending')
6. **Prepare task assignment** with source file list
7. **Queue single task** for execution

**OUTPUT from Planning**: Coverage analysis task assignment as todo

#### Phase 2: Execution (Single Subagent)

**What You Send to Subagent**:

In a single message, you spin up **1** subagent to perform baseline coverage analysis.

- **[IMPORTANT]** When there are issues reported, you must analyze and handle appropriately
- **[IMPORTANT]** You MUST ask the subagent to ultrathink hard about comprehensive coverage analysis
- **[IMPORTANT]** Use TodoWrite to update task status from 'pending' to 'in_progress' when dispatched

Request the subagent to perform the following steps with full detail:

    >>>
    **ultrathink: adopt the Coverage Analysis Expert mindset**

    - You're a **Coverage Analysis Expert** with deep expertise in test coverage measurement who follows these technical principles:
      - **Comprehensive Analysis**: Identify every uncovered line, branch, and statement
      - **Baseline Establishment**: Create accurate baseline metrics for tracking progress
      - **Tool Proficiency**: Execute coverage tools correctly and parse output accurately
      - **Detailed Reporting**: Provide file-by-file coverage breakdown

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Read the following assigned standards** and follow them recursively (if A references B, read B too):

    - testing.md
    - typescript.md

    **Assignment**
    You're assigned to analyze baseline test coverage for the provided source files.

    **Steps**

    1. **Discover test configuration**:
       - Locate vitest.config.ts or equivalent
       - Verify coverage provider is configured (v8)
       - Check for excluded patterns
    2. **Run existing tests** (if any exist):
       - Execute `npm run test` or equivalent
       - Note any failing tests
    3. **Generate coverage report**:
       - Execute `npm run coverage` or `vitest --coverage`
       - Parse coverage output (JSON and HTML reports)
       - Extract line, branch, statement, function coverage
    4. **Identify uncovered code**:
       - List all uncovered files (0% coverage)
       - For partially covered files:
         - List uncovered line ranges
         - List uncovered branches
         - Note functions without coverage
    5. **Create baseline metrics**:
       - Total lines: covered vs uncovered
       - Total branches: covered vs uncovered
       - Total functions: covered vs uncovered
       - File-by-file coverage percentage

    **Report**
    **[IMPORTANT]** You're requested to return the following:

    - Baseline coverage metrics (overall and per-file)
    - List of completely uncovered files
    - List of partially covered files with uncovered line ranges
    - Existing test file count
    - Failing test count (if any)

    **[IMPORTANT]** You MUST return the following execution report (<1000 tokens):

    ```yaml
    status: success|failure|partial
    summary: 'Baseline coverage analysis complete'
    modifications: [] # No files modified in this step
    outputs:
      baseline_coverage:
        overall:
          lines: 'X%'
          branches: 'Y%'
          statements: 'Z%'
          functions: 'W%'
        per_file:
          - file: 'src/auth/service.ts'
            lines: 'X%'
            uncovered_lines: [45-52, 89, 123-145]
            uncovered_branches: [67, 89]
          - file: 'src/users/controller.ts'
            lines: '0%'
            uncovered_lines: 'all'
        uncovered_files: ['src/users/controller.ts', ...]
        partially_covered_files: ['src/auth/service.ts', ...]
      existing_tests:
        test_file_count: N
        failing_tests: M
    issues: ['issue1', 'issue2', ...]  # only if problems encountered
    ```
    <<<

#### Phase 3: Review

Skip review for this step - baseline analysis is deterministic.

#### Phase 4: Decision (You)

**What You Do**:

1. **Analyze coverage report**
2. **Verify baseline established**:
   - Confirm coverage metrics are accurate
   - Verify uncovered code is identified
3. **Select next action**:
   - **PROCEED**: Baseline established → Move to Step 2
   - **FIX ISSUES**: Report problems found → Retry phase 2 → ||repeat||
4. **Use TodoWrite** to update task status to 'completed'
5. **Prepare batching strategy** for Step 2 based on uncovered files

**OUTPUT from Step 1**: Baseline coverage report ready for batching in Step 2

### Step 2: Progressive Test Writing with Coverage Verification

**Step Configuration**:

- **Purpose**: Write tests progressively for batches of source files, verifying coverage after each test, keeping only tests that improve coverage until 100% achieved per batch
- **Input**: Baseline coverage from Step 1, list of uncovered/partially covered files
- **Output**: Complete test files with 100% coverage for all source files
- **Sub-workflow**: None
- **Parallel Execution**: Yes - multiple batches run in parallel (max 10)

**KEY INNOVATION**: Each subagent handles 2-5 source files (max 500 lines total) and writes tests one at a time, verifying coverage after each test, deleting tests that don't improve coverage.

#### Phase 1: Planning (You)

**What You Do**:

1. **Receive baseline coverage** from Step 1
2. **List all source files** needing coverage (0% or <100%)
3. **Read source files** to determine line counts using Read tool
4. **Create dynamic batches** following these rules:
   - **Batch size**: 2-5 source files per batch
   - **Line limit**: Max 500 total lines of source code per batch
   - Algorithm:
     - Start with first uncovered file
     - Add files until reach 5 files OR 500 lines
     - Create batch assignment
     - Move to next set of files
     - Repeat until all files assigned
5. **Determine the standards** to send to all subagents:
   - testing.md (REQUIRED)
   - typescript.md (REQUIRED)
   - documentation.md (REQUIRED)
6. **Use TodoWrite** to create task list from all batches (each batch = one todo item with status 'pending')
7. **Prepare batch assignments** with specific source file lists for each subagent
8. **Queue all batches** for parallel execution (max 10 concurrent)

**BATCHING EXAMPLE**:

```plaintext
Source files:
  - auth/service.ts (120 lines)
  - auth/controller.ts (180 lines)
  - users/service.ts (150 lines)
  - users/controller.ts (200 lines)
  - posts/service.ts (100 lines)
  - posts/controller.ts (300 lines)

Batches created:
  Batch 1: auth/service.ts, auth/controller.ts, users/service.ts (450 lines, 3 files) ✓
  Batch 2: users/controller.ts, posts/service.ts (300 lines, 2 files) ✓
  Batch 3: posts/controller.ts (300 lines, 1 file) ✓
```

**OUTPUT from Planning**: Multiple batch assignments as todos, ready for parallel dispatch

#### Phase 2: Execution (Subagents - Parallel Batches)

**What You Send to Subagents**:

In a single message, you spin up multiple Test Writing Agents to perform progressive test writing, up to **10** batches at a time.

- **[IMPORTANT]** When there are any issues reported, you must stop dispatching further agents until all issues have been rectified
- **[IMPORTANT]** You MUST ask all agents to ultrathink hard about the task and requirements
- **[IMPORTANT]** Use TodoWrite to update each batch's status from 'pending' to 'in_progress' when dispatched
- **[IMPORTANT]** Each subagent is responsible for their ENTIRE batch - writing ALL tests for ALL files in the batch

Request each Test Writing Agent to perform the following steps with full detail:

    >>>
    **ultrathink: adopt the Progressive Test Writing Expert mindset**

    - You're a **Progressive Test Writing Expert** with deep expertise in coverage-driven test development who follows these technical principles:
      - **Batch Ownership**: You own this entire batch - write tests for ALL assigned source files until ALL reach 100% coverage
      - **Progressive Writing**: Write ONE test at a time, verify coverage, decide keep/delete
      - **Coverage Verification**: Run coverage after EVERY single test to verify improvement
      - **Minimal Testing**: Delete any test that doesn't add measurable coverage
      - **Standards Compliance**: Follow testing.md, typescript.md, documentation.md throughout
      - **Complete Coverage**: Continue until ALL files in your batch reach 100% coverage

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent.
      You are responsible for achieving 100% coverage for ALL source files in your batch.
    </IMPORTANT>

    **Read the following assigned standards** and follow them recursively (if A references B, read B too):

    - testing.md (Coverage-Driven Test Development Workflow section is CRITICAL)
    - typescript.md
    - documentation.md

    **Assignment**
    You're assigned Batch [X] with the following source files (total: [N] lines):

    - [source file 1 - L lines]
    - [source file 2 - M lines]
    - [source file 3 - N lines]
    - [... 2-5 files maximum, max 500 lines total]

    **Your Goal**: Achieve 100% coverage for ALL files in this batch using progressive test writing.

    **Steps - CRITICAL WORKFLOW**

    **FOR EACH source file in your batch, repeat this entire workflow:**

    1. **Initial Coverage Check**:
       - Run: `vitest --coverage spec/path/to/file.spec.ts`
       - Note current coverage: lines, branches, uncovered ranges
       - Identify first uncovered line or branch

    2. **Progressive Test Writing Loop** (repeat until 100% coverage):

       a. **Write ONE test** targeting a specific uncovered line/branch:
          - Follow AAA pattern (Arrange, Act, Assert)
          - Target specific uncovered code identified in coverage report
          - Use proper TypeScript types
          - Follow testing standards

       b. **Run coverage verification**:
          - Execute: `vitest --coverage spec/path/to/file.spec.ts`
          - Parse output to get new coverage percentage
          - Note which lines are now covered

       c. **Coverage improvement decision**:
          - **IF coverage increased** (even by 1 line):
            - KEEP the test ✓
            - Note improvement amount
            - Continue to next uncovered line/branch
          - **IF coverage stayed the same**:
            - DELETE the test immediately ✗
            - Log: "Test provided no coverage value"
            - Write different test targeting uncovered code

       d. **Check completion**:
          - If 100% coverage reached for this file → Move to next file in batch
          - If <100% coverage → Repeat from step 2a

    3. **Batch Completion Verification**:
       - Run coverage for ALL test files in batch together
       - Verify EVERY source file in batch is at 100%
       - Count total tests created vs deleted
       - Calculate coverage efficiency (coverage % per test)

    4. **Standards Compliance Check**:
       - Run: `npm run lint` on all created test files
       - Verify all tests follow testing.md standards
       - Fix any TypeScript errors
       - Ensure proper documentation

    **CRITICAL REMINDERS**:
    - You MUST write tests one at a time with immediate coverage verification
    - You MUST delete any test that doesn't improve coverage
    - You MUST continue until ALL files in your batch reach 100%
    - You CANNOT move to next batch until current batch is complete
    - You MUST follow testing.md standards (especially Zero Redundancy Rule)

    **Report**
    **[IMPORTANT]** You're requested to return the following batch results:

    - All test files created for your batch
    - Coverage metrics for each source file (must be 100%)
    - Test count statistics (created, kept, deleted)
    - Coverage efficiency metrics
    - Standards compliance status

    **[IMPORTANT]** You MUST return the following execution report (<1000 tokens):

    ```yaml
    status: success|failure|partial
    summary: 'Batch [X]: Achieved 100% coverage for [N] files with [M] tests'
    modifications: ['spec/auth/service.spec.ts', 'spec/users/controller.spec.ts', ...]
    outputs:
      batch_info:
        batch_number: X
        source_files_count: N
        total_source_lines: M
      coverage_per_file:
        - file: 'src/auth/service.ts'
          test_file: 'spec/auth/service.spec.ts'
          coverage:
            lines: '100%'
            branches: '100%'
            statements: '100%'
            functions: '100%'
          tests_created: 25
          tests_kept: 18
          tests_deleted: 7
        - file: 'src/users/controller.ts'
          test_file: 'spec/users/controller.spec.ts'
          coverage:
            lines: '100%'
            branches: '100%'
            statements: '100%'
            functions: '100%'
          tests_created: 30
          tests_kept: 22
          tests_deleted: 8
      batch_summary:
        total_tests_created: 55
        total_tests_kept: 40
        total_tests_deleted: 15
        coverage_efficiency: '2.5% per test' # (100% coverage / 40 tests)
      standards_compliance:
        testing_standard: pass|fail
        typescript_standard: pass|fail
        documentation_standard: pass|fail
      verification:
        all_files_100_percent: true|false
        all_tests_passing: true|false
        lint_check: pass|fail
    issues: ['issue1', 'issue2', ...]  # only if problems encountered
    ```
    <<<

#### Phase 3: Review

Skip review phase if all batches report success. Only trigger review if batches report partial success or issues.

#### Phase 4: Decision (You)

**What You Do**:

1. **Analyze all batch reports** from parallel execution
2. **Verify coverage achievement**:
   - Check that EVERY batch reports 100% coverage for ALL files
   - Verify test efficiency metrics are reasonable
   - Confirm standards compliance
3. **Apply decision criteria**:
   - Review any critical batch failures
   - Check for incomplete coverage
4. **Select next action**:
   - **PROCEED**: All batches report 100% coverage → Move to Step 3
   - **FIX ISSUES**: Some batches partial or failed → Create new batches for incomplete files → Perform phase 2 again → ||repeat||
5. **Use TodoWrite** to update task list:
   - Mark completed batches as 'completed'
   - Add retry batches for failures if needed
6. **Aggregate statistics**:
   - Total tests created across all batches
   - Total tests kept vs deleted
   - Overall coverage efficiency
   - Files with 100% coverage

**OUTPUT from Step 2**: Complete test suite with 100% coverage for all source files

### Step 3: Remove Redundant Tests

**Step Configuration**:

- **Purpose**: Identify and remove redundant tests that don't add unique coverage value while maintaining 100% coverage
- **Input**: Complete test suite from Step 2 with 100% coverage
- **Output**: Optimized test suite with redundant tests removed, coverage still at 100%
- **Sub-workflow**: None
- **Parallel Execution**: Yes - Phase 2 uses parallel execution for removal tasks

**KEY INNOVATION**: Use Plan subagent to analyze all tests and identify potential redundancies, then execute removals in parallel.

#### Phase 1: Planning with Plan Subagent (You)

**What You Do**:

1. **Receive complete test suite** from Step 2
2. **Use TodoWrite** to create task for Plan subagent (status: 'pending')
3. **Dispatch Plan subagent** to analyze tests and identify redundancy candidates

**What You Send to Plan Subagent**:

Use the Task tool with subagent_type="Plan" to dispatch the plan subagent:

    >>>
    **ultrathink: adopt the Test Redundancy Analyst mindset**

    - You're a **Test Redundancy Analyst** with deep expertise in identifying unnecessary tests who follows these principles:
      - **Coverage Analysis**: Understand which tests cover which code paths
      - **Redundancy Detection**: Identify tests that duplicate coverage without adding value
      - **Strategic Planning**: Create removal strategy that preserves 100% coverage
      - **Risk Assessment**: Flag tests that appear redundant but may be essential

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Read the following assigned standards** to understand redundancy criteria:

    - testing.md (especially Zero Redundancy Rule and Minimal Testing Principle)

    **Assignment**
    Analyze all test files and identify potential redundant tests.

    **Analysis Steps**:

    1. **Read all test files** created in Step 2
    2. **For each test**, determine:
       - What source code lines it covers
       - What branches it exercises
       - What unique behavior it verifies
    3. **Identify redundancy patterns**:
       - Tests with same logic but different data values
       - Tests that cover same lines as other tests
       - Tests for artificial scenarios (not real edge cases)
       - Wrapper function tests (just calling other functions)
    4. **Create removal candidates list**:
       - Group tests by file
       - Mark each as: 'safe_to_remove', 'uncertain', 'keep'
       - Provide removal strategy for each group
    5. **Create removal tasks**:
       - Group removal candidates into tasks (max 10 tests per task)
       - Specify removal order (remove least risky first)

    **Report**
    **[IMPORTANT]** You're requested to return:

    - List of all tests analyzed
    - Redundancy candidates grouped by file
    - Removal tasks with specific test names
    - Risk assessment for each candidate
    - Estimated coverage preservation likelihood

    Provide a comprehensive plan for redundant test removal that the orchestrator can use to dispatch parallel removal subagents.
    <<<

4. **Receive Plan subagent report**
5. **Parse removal tasks** from plan
6. **Use TodoWrite** to create task list from removal tasks (each task = one todo item)
7. **Prepare removal task assignments** for parallel execution

**OUTPUT from Phase 1**: Removal tasks ready for parallel dispatch

#### Phase 2: Parallel Removal Execution (Subagents)

**What You Send to Subagents**:

In a single message, you spin up multiple Test Removal Agents to perform removal attempts, up to **10** tasks at a time.

- **[IMPORTANT]** Each subagent attempts to remove specific tests and verifies coverage
- **[IMPORTANT]** If coverage drops, test must be restored
- **[IMPORTANT]** Use TodoWrite to update each task status

Request each Test Removal Agent to perform the following:

    >>>
    **ultrathink: adopt the Surgical Test Removal Expert mindset**

    - You're a **Surgical Test Removal Expert** who follows these principles:
      - **Coverage Preservation**: 100% coverage must be maintained
      - **Careful Removal**: Remove one test at a time, verify immediately
      - **Rollback Ready**: Restore test if coverage drops
      - **Verification Focus**: Coverage reports guide all decisions

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Assignment**
    You're assigned Removal Task [X] - attempt to remove the following tests:

    - Test: '[test name 1]' at line [N] in [test file]
      - Reason: [redundancy reason]
      - Risk: [low|medium]
    - Test: '[test name 2]' at line [M] in [test file]
      - Reason: [redundancy reason]
      - Risk: [low|medium]
    - [... up to 10 tests per task]

    **Steps - CRITICAL WORKFLOW**

    **FOR EACH test in your assignment:**

    1. **Pre-removal coverage check**:
       - Run: `vitest --coverage spec/path/to/file.spec.ts`
       - Note current coverage percentages (must be 100%)

    2. **Remove single test**:
       - Comment out or delete the specific test block
       - Save file

    3. **Post-removal coverage verification**:
       - Run: `vitest --coverage spec/path/to/file.spec.ts`
       - Compare with pre-removal coverage

    4. **Decision**:
       - **IF coverage maintained at 100%**:
         - KEEP test removed ✓
         - Log: "Test successfully removed - redundant"
         - Continue to next test
       - **IF coverage dropped (even 1%)**:
         - RESTORE test immediately ✗
         - Log: "Test necessary - restored"
         - Mark as 'essential'

    5. **Move to next test** in assignment

    **Report**
    **[IMPORTANT]** You're requested to return:

    - Tests attempted for removal
    - Tests successfully removed
    - Tests restored (coverage dropped)
    - Final coverage status

    **[IMPORTANT]** You MUST return the following execution report (<1000 tokens):

    ```yaml
    status: success|failure|partial
    summary: 'Removal Task [X]: Removed [N] redundant tests, restored [M] essential tests'
    modifications: ['spec/auth/service.spec.ts', ...]
    outputs:
      task_info:
        task_id: X
        tests_attempted: 10
        tests_removed: 7
        tests_restored: 3
      removal_details:
        - test_name: 'should calculate tax for $100'
          action: 'removed'
          coverage_before: '100%'
          coverage_after: '100%'
          outcome: 'success'
        - test_name: 'should validate email format'
          action: 'restored'
          coverage_before: '100%'
          coverage_after: '98%'
          outcome: 'essential - coverage dropped'
      final_coverage:
        lines: '100%'
        branches: '100%'
        statements: '100%'
        functions: '100%'
      verification:
        coverage_maintained: true|false
        all_tests_passing: true|false
    issues: ['issue1'] # if any
    ```
    <<<

#### Phase 3: Review

Skip review - coverage verification is built into removal process.

#### Phase 4: Decision (You)

**What You Do**:

1. **Analyze all removal reports**
2. **Verify coverage maintained** at 100%
3. **Calculate redundancy metrics**:
   - Total tests removed
   - Total tests kept (coverage dropped when removed)
   - Redundancy percentage
4. **Select next action**:
   - **PROCEED**: All tasks complete, 100% coverage maintained → Move to Step 4
   - **FIX ISSUES**: Coverage dropped or issues → Investigate and retry
5. **Use TodoWrite** to update all task statuses
6. **Aggregate results**:
   - Total redundant tests removed
   - Final test count
   - Coverage efficiency improved

**OUTPUT from Step 3**: Optimized test suite with redundant tests removed, 100% coverage maintained

### Step 4: Fix Test Issues & Standards Compliance

**Step Configuration**:

- **Purpose**: Fix any issues in test files and ensure complete standards compliance
- **Input**: Optimized test suite from Step 3
- **Output**: Test files with all issues fixed and full standards compliance
- **Sub-workflow**: None
- **Parallel Execution**: Yes - if >25 test files, use batch execution

#### Phase 1: Planning (You)

**What You Do**:

1. **Receive test suite** from Step 3
2. **List all test files** using Glob tool (do NOT use `find` in bash)
3. **Determine batching**:
   - If ≤25 test files → Single subagent handles all
   - If >25 test files → Create batches (max 10 files per batch)
4. **Determine the minimum required standards**:
   - testing.md (REQUIRED)
   - typescript.md (REQUIRED)
   - documentation.md (REQUIRED)
5. **Use TodoWrite** to create task list
6. **Prepare batch/task assignments**
7. **Queue for execution**

**OUTPUT from Planning**: Task assignments ready for dispatch

#### Phase 2: Execution (Subagents)

**What You Send to Subagents**:

In a single message, you spin up Test Issue Fixing Agents, up to **10** at a time if batching is needed.

- **[IMPORTANT]** When there are any issues reported, you must stop dispatching further agents until all issues have been rectified
- **[IMPORTANT]** You MUST ask all agents to ultrathink hard about the task
- **[IMPORTANT]** Use TodoWrite to update each batch's status from 'pending' to 'in_progress' when dispatched

Request each Test Issue Fixing Agent to perform the following:

    >>>
    **ultrathink: adopt the Test Standards Enforcer mindset**

    - You're a **Test Standards Enforcer** with deep expertise in test quality who follows these principles:
      - **Standards Mastery**: Apply all testing, TypeScript, and documentation standards thoroughly
      - **Issue Correction**: Fix logic errors, type issues, and standards violations
      - **Preservation Focus**: Maintain test intent and coverage while fixing
      - **Quality Assurance**: Verify all fixes through testing and linting

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Read the following assigned standards** and follow them recursively (if A references B, read B too):

    - testing.md
    - typescript.md
    - documentation.md

    **Assignment**
    You're assigned to fix issues in the following test files:

    - [test file 1]
    - [test file 2]
    - [... up to 10 files if batching, or all files if ≤25]

    **Steps**

    1. **Analysis Phase**:
       - Read each test file to understand current issues
       - Identify standards violations
       - Note logic errors or incorrect behavior
    2. **Issue Fixing**:
       - Fix TypeScript errors (no `any` types)
       - Apply AAA pattern corrections
       - Ensure proper test naming
       - Add missing documentation
       - Correct test logic issues
    3. **Verification**:
       - Run: `npm run test` to ensure all tests pass
       - Run: `npm run lint` to verify standards compliance
       - Run: `npx tsc --noEmit` for type checking
       - Verify coverage maintained at 100%

    **Report**
    **[IMPORTANT]** You're requested to return:

    - Test files modified
    - Issues fixed (type errors, logic errors, standards violations)
    - Verification results

    **[IMPORTANT]** You MUST return the following execution report (<1000 tokens):

    ```yaml
    status: success|failure|partial
    summary: 'Fixed [N] issues across [M] test files'
    modifications: ['spec/auth/service.spec.ts', ...]
    outputs:
      issues_fixed:
        type_errors: N
        logic_errors: M
        standards_violations: X
        documentation_missing: Y
      verification:
        all_tests_passing: true|false
        lint_check: pass|fail
        type_check: pass|fail
        coverage_maintained: '100%'
      standards_compliance:
        testing_standard: pass|fail
        typescript_standard: pass|fail
        documentation_standard: pass|fail
    issues: ['issue1'] # if any
    ```
    <<<

#### Phase 3: Review

Skip review if all reports show success. Only trigger if issues reported.

#### Phase 4: Decision (You)

**What You Do**:

1. **Analyze all fixing reports**
2. **Verify issues resolved**
3. **Select next action**:
   - **PROCEED**: All issues fixed → Move to Step 5
   - **FIX ISSUES**: Some issues remain → Retry → ||repeat||
4. **Use TodoWrite** to update task statuses

**OUTPUT from Step 4**: Test files with all issues resolved and standards compliance verified

### Step 5: Restructure Fixtures & Test Doubles

**Step Configuration**:

- **Purpose**: Consolidate duplicate fixtures, improve organization, remove unused test support files
- **Input**: Fixed test files from Step 4
- **Output**: Restructured fixtures and mocks with improved organization
- **Sub-workflow**: None
- **Parallel Execution**: Phase 2 may use parallel execution based on Plan recommendations

**KEY INNOVATION**: Use Plan subagent to analyze fixture structure and identify consolidation opportunities.

#### Phase 1: Planning with Plan Subagent (You)

**What You Do**:

1. **Receive fixed tests** from Step 4
2. **Use TodoWrite** to create task for Plan subagent
3. **Dispatch Plan subagent** to analyze fixtures and create restructuring plan

**What You Send to Plan Subagent**:

Use the Task tool with subagent_type="Plan":

    >>>
    **ultrathink: adopt the Test Structure Architect mindset**

    - You're a **Test Structure Architect** with deep expertise in fixture organization who follows these principles:
      - **Pattern Recognition**: Identify duplicate fixture patterns
      - **Organization Design**: Create logical fixture structure
      - **Reusability Focus**: Maximize fixture reuse across tests
      - **Cleanup Awareness**: Identify unused fixtures and mocks

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Read the following assigned standards**:

    - testing.md (Test Double Organization section)
    - typescript.md
    - documentation.md

    **Assignment**
    Analyze all fixtures, mocks, and test support files and create restructuring plan.

    **Analysis Steps**:

    1. **Discover all test support files**:
       - Find fixtures: spec/fixtures/**/*.ts
       - Find mocks: spec/mocks/**/*.ts
       - Find inline fixtures in test files
       - Find inline mocks in test files
    2. **Identify duplication patterns**:
       - Similar fixture data in multiple files
       - Repeated mock configurations
       - Inline fixtures that could be shared
    3. **Analyze organization**:
       - Current directory structure
       - Naming consistency
       - Type safety compliance
    4. **Find unused files**:
       - Fixtures not imported by any test
       - Mocks defined but never used
       - Factory functions without references
    5. **Create restructuring plan**:
       - Consolidation opportunities (which fixtures to merge)
       - Organization improvements (directory structure changes)
       - Deletion candidates (unused files)
       - Migration strategy (how to refactor safely)

    **Report**
    Provide comprehensive restructuring plan that the orchestrator can use to execute fixture consolidation and organization improvements.
    <<<

4. **Receive Plan subagent report**
5. **Parse restructuring plan**
6. **Use TodoWrite** to create execution tasks from plan
7. **Prepare execution assignments**

**OUTPUT from Phase 1**: Restructuring execution plan ready

#### Phase 2: Execute Restructuring (Single or Multiple Subagents)

**What You Send to Subagent(s)**:

Based on plan complexity, dispatch 1 subagent (simple) or multiple subagents (complex).

    >>>
    **ultrathink: adopt the Test Refactoring Specialist mindset**

    - You're a **Test Refactoring Specialist** who follows these principles:
      - **Safe Refactoring**: Preserve test functionality while restructuring
      - **Type Safety**: Maintain TypeScript compliance throughout
      - **Incremental Changes**: Apply changes step-by-step with verification
      - **Testing Focus**: Verify tests pass after each change

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Read the following assigned standards**:

    - testing.md
    - typescript.md
    - documentation.md

    **Assignment**
    Execute the restructuring plan provided:

    [Include relevant portion of plan for this subagent]

    **Steps**:

    1. **Create new shared fixture/mock files** as specified in plan
    2. **Migrate fixtures/mocks** from old locations to new shared files
    3. **Update imports** in all test files using the migrated fixtures/mocks
    4. **Remove old fixture definitions** (inline or in old files)
    5. **Delete unused files** as identified in plan
    6. **Verify tests** after each major change:
       - Run: `npm run test`
       - Ensure all tests still pass
       - Fix any broken imports or references
    7. **Type check** all changes:
       - Run: `npx tsc --noEmit`
       - Fix any TypeScript errors
    8. **Lint check**:
       - Run: `npm run lint`
       - Fix any linting issues

    **Report**
    **[IMPORTANT]** You're requested to return:

    - Files created (shared fixtures/mocks)
    - Files modified (test files with updated imports)
    - Files deleted (unused fixtures/mocks)
    - Verification results

    **[IMPORTANT]** You MUST return the following execution report (<1000 tokens):

    ```yaml
    status: success|failure|partial
    summary: 'Restructuring complete - created [N] shared files, migrated [M] fixtures'
    modifications: ['spec/fixtures/user.fixture.ts', 'spec/auth/service.spec.ts', ...]
    outputs:
      restructuring_summary:
        shared_files_created: N
        fixtures_consolidated: M
        mocks_consolidated: X
        unused_files_deleted: Y
        test_files_updated: Z
      created_files:
        - file: 'spec/fixtures/user.fixture.ts'
          exports: ['createUser', 'createAdminUser']
          consolidates: ['spec/auth/fixtures.ts', 'spec/users/fixtures.ts']
        - file: 'spec/mocks/api-client.mock.ts'
          exports: ['createMockApiClient']
          consolidates: ['inline from 3 files']
      deleted_files:
        - 'spec/fixtures/old-format.fixture.ts'
        - 'spec/mocks/deprecated.mock.ts'
      verification:
        all_tests_passing: true|false
        type_check: pass|fail
        lint_check: pass|fail
        imports_valid: true|false
    issues: ['issue1'] # if any
    ```
    <<<

#### Phase 3: Review

Skip review - verification is built into restructuring process.

#### Phase 4: Decision (You)

**What You Do**:

1. **Analyze restructuring reports**
2. **Verify tests still pass**
3. **Confirm organization improved**
4. **Select next action**:
   - **PROCEED**: Restructuring complete → Move to Step 6
   - **FIX ISSUES**: Problems found → Retry or rollback
5. **Use TodoWrite** to update task statuses

**OUTPUT from Step 5**: Restructured fixture/mock organization with improved reusability

### Step 6: Final Verification

**Step Configuration**:

- **Purpose**: Perform comprehensive final verification of entire test suite
- **Input**: Complete, optimized, restructured test suite from Steps 1-5
- **Output**: Final validation report confirming 100% coverage, all tests passing, efficiency metrics
- **Sub-workflow**: None
- **Parallel Execution**: No - single subtask delegation

**KEY INNOVATION**: Delegate entire verification to a subtask subagent for independent validation.

#### Phase 1: Planning (You)

**What You Do**:

1. **Receive complete test suite** from Step 5
2. **Use TodoWrite** to create verification subtask
3. **Prepare subtask assignment** with full context

**OUTPUT from Planning**: Verification subtask ready for delegation

#### Phase 2: Execute Verification (Subtask)

**What You Send to Subtask**:

Use the Task tool to delegate verification to independent subagent:

    >>>
    **ultrathink: adopt the Quality Assurance Validator mindset**

    - You're a **Quality Assurance Validator** performing final comprehensive verification with these principles:
      - **Independent Validation**: Verify all claims independently
      - **Comprehensive Checking**: Test all aspects (coverage, passing, standards, efficiency)
      - **Metrics Focus**: Provide concrete numbers and measurements
      - **Pass/Fail Authority**: Make final determination on test suite quality

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Read the following standards to verify compliance**:

    - testing.md
    - typescript.md
    - documentation.md

    **Assignment**
    Perform final comprehensive verification of test suite.

    **Verification Steps**:

    1. **Coverage Verification**:
       - Run: `npm run coverage` or `vitest --coverage`
       - Extract final metrics:
         - Line coverage: must be 100%
         - Branch coverage: must be 100%
         - Statement coverage: must be 100%
         - Function coverage: must be 100%
       - Verify NO uncovered code remains
       - Check coverage reports for accuracy

    2. **Test Execution Verification**:
       - Run: `npm run test`
       - Verify ALL tests pass
       - Count total tests
       - Note execution time
       - Check for flaky tests (run twice if suspicious)

    3. **Standards Compliance Verification**:
       - Run: `npm run lint`
       - Verify: No linting errors
       - Check TypeScript: `npx tsc --noEmit`
       - Verify: No type errors
       - Manually review test structure compliance:
         - AAA pattern usage
         - Proper naming conventions
         - JSDoc documentation
         - Type safety (no `any` types)

    4. **Efficiency Metrics**:
       - Calculate:
         - Total source files
         - Total test files
         - Total tests
         - Average tests per source file
         - Coverage per test ratio
         - Test suite execution time
       - Assess:
         - Are tests minimal? (testing.md Minimal Testing Principle)
         - Are fixtures properly organized?
         - Is redundancy eliminated?

    5. **Final Quality Assessment**:
       - Overall grade: A/B/C/D/F
       - Production readiness: yes/no
       - Blockers: list any
       - Recommendations: list improvements if any

    **Report**
    Provide comprehensive final verification report with pass/fail verdict and quality assessment.
    <<<

#### Phase 3: Review

Skip review - this is the final verification step.

#### Phase 4: Decision (You)

**What You Do**:

1. **Receive verification report**
2. **Review final verdict**
3. **Select next action**:
   - **PASS verdict**: Workflow complete successfully
   - **FAIL verdict**: Identify blockers and decide:
     - If fixable → Return to appropriate step
     - If critical issues → Report failure with details
4. **Use TodoWrite** to mark workflow complete or failed
5. **Prepare final workflow output**

**OUTPUT from Step 6**: Final validation confirming test suite quality

### Workflow Completion

**Report the workflow output as specified**:

```yaml
workflow: complete-test
status: completed|failed
outputs:
  step_1_baseline:
    initial_coverage: 'X%'
    uncovered_files: N
    analysis_status: completed
  step_2_progressive_writing:
    batches_executed: N
    source_files_covered: M
    tests_created: X
    tests_kept: Y
    tests_deleted: Z
    final_coverage: '100%'
    writing_status: completed
  step_3_redundancy_removal:
    redundancy_candidates_identified: N
    tests_removed: M
    tests_kept_essential: X
    coverage_maintained: '100%'
    removal_status: completed
  step_4_issue_fixing:
    test_files_fixed: N
    issues_resolved: M
    standards_compliance: 'pass'
    fixing_status: completed
  step_5_fixture_restructuring:
    shared_fixtures_created: N
    fixtures_consolidated: M
    unused_files_deleted: X
    restructuring_status: completed
  step_6_final_verification:
    coverage_verified: '100%'
    all_tests_passing: true
    standards_compliant: true
    efficiency_grade: 'A|B|C|D|F'
    production_ready: true|false
    verification_status: pass|fail
  final_metrics:
    total_source_files: N
    total_test_files: M
    total_tests: X
    coverage_percentage: '100%'
    tests_per_source_file: Y
    redundancy_eliminated: Z
    test_suite_execution_time: 'W seconds'
  workflow_summary: |
    Successfully created comprehensive test suite with 100% coverage for [N] source files.
    Created [M] tests through progressive writing with coverage verification.
    Removed [X] redundant tests while maintaining 100% coverage.
    Fixed [Y] test issues and ensured standards compliance.
    Restructured fixtures for improved organization and reusability.
    Final verification confirms production-ready test suite with grade [A/B/C/D/F].
```
