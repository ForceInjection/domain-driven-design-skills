---
name: web-test
description: Execute tests from persistent test cases. Reads ./tests/ directory, runs cleanup, wallet setup (if Web3), executes tests, and generates report.
license: MIT
compatibility: Node.js 18+, Playwright (global)
metadata:
  author: AI Agent
  version: 2.0.0
allowed-tools: Bash Read Write Glob Grep Task Skill
---

# Web Test Execution

Execute tests from persistent test cases in `./tests/` directory.

## CRITICAL RULES - READ FIRST

### Rule 1: Wallet Setup Based on config.yaml

```
┌────────────────────────────────────────────────────────────────┐
│  IF config.yaml contains:                                      │
│                                                                │
│    web3:                                                       │
│      enabled: true                                             │
│                                                                │
│  THEN at TEST START (before any test cases):                   │
│                                                                │
│    1. skill web-test-wallet-setup    ← REQUIRED AT START!      │
│                                                                │
│  Wallet CONNECT is handled by test cases:                      │
│                                                                │
│    2. WALLET-001 test case          ← Is a TEST CASE           │
│       (uses web-test-wallet-connect internally)                │
│                                                                │
│  ❌ DO NOT skip wallet-setup for Web3 DApps                    │
│  ❌ DO NOT auto-run wallet-connect (it's a test case now)      │
│  ✅ Run wallet-setup ONCE at start if web3.enabled: true       │
│  ✅ Run WALLET-001 test when reached in execution_order        │
└────────────────────────────────────────────────────────────────┘
```

**Why this matters:**

- Wallet **setup** prepares the extension (download, import key)
- Wallet **connect** is now a testable feature (WALLET-001)
- Other tests depend on WALLET-001 via preconditions

### Rule 2: NEVER Skip Tests Due to Time Constraints

```
╔════════════════════════════════════════════════════════════════╗
║                    ⛔ CRITICAL RULE ⛔                          ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  This is AUTOMATED TESTING - user does NOT care about time!    ║
║  Run ALL tests, no matter how long it takes.                   ║
║                                                                ║
║  ❌ FORBIDDEN - These excuses are NOT allowed:                 ║
║     - "Time constraints"                                       ║
║     - "To save time"                                           ║
║     - "Already running too long"                               ║
║     - "Similar to another test"                                ║
║     - "Will test later"                                        ║
║     - "Not enough time"                                        ║
║                                                                ║
║  ✅ VALID reasons to skip a test:                              ║
║     - User requested specific tests (see Selective Execution)  ║
║       Example: "Run only SWAP-001" → skip other tests          ║
║     - User requested specific module/feature                   ║
║       Example: "Run wallet module" → skip non-wallet tests     ║
║     - Blocking dependency failed (depends_on test failed)      ║
║     - Feature does not exist in the project                    ║
║     - Test case is explicitly deprecated                       ║
║                                                                ║
║  ⚠️  IF YOU SKIP A TEST FOR "TIME CONSTRAINTS":                ║
║      → The test run is considered INCOMPLETE                   ║
║      → User will NOT accept the results                        ║
║      → You MUST re-run the skipped tests                       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**Why this matters:**

- **This is AUTOMATED testing** - the user does NOT care how long it takes
- Users explicitly want ALL test cases executed, regardless of time
- Every test case exists for a reason - skipping means missing bugs
- Skipping tests defeats the entire purpose of testing
- "Time constraints" is YOUR concern, not the user's - they want completeness
- If a test takes too long, WAIT for it - the user expects this
- If a test is truly unnecessary, the user will REMOVE it from the test suite

### Rule 3: Follow Execution Order

Always execute in this exact order:

1. Check for test cases
2. `web-test-cleanup` - Clean previous session
3. Read config.yaml
4. `web-test-wallet-setup` - **(if web3.enabled: true)** - Run ONCE at start
5. Execute test cases (including WALLET-001 which connects wallet)
6. `web-test-report` - Generate report
7. `web-test-cleanup --keep-data` - Final cleanup

**Note:** `web-test-wallet-connect` is no longer called directly by this skill.
It is invoked when executing WALLET-001 test case or as a precondition check.

### Rule 4: Timeout Rules - FAIL FAST

```
╔════════════════════════════════════════════════════════════════╗
║  TIMEOUT RULES - MAXIMUM 30 SECONDS FOR ANY OPERATION          ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  All operations MUST complete within 30 seconds:               ║
║                                                                ║
║  | Operation              | Timeout | On Timeout              ║
║  |------------------------|---------|-------------------------|
║  | Button click response  | 30s     | FAIL test               |
║  | Form submission        | 30s     | FAIL test               |
║  | Page navigation        | 30s     | FAIL test               |
║  | API request            | 30s     | FAIL test               |
║  | Wallet popup appear    | 30s     | FAIL test               |
║  | Element visibility     | 30s     | FAIL test               |
║                                                                ║
║  ❌ DO NOT use long wait times:                                ║
║     - wait: 10000  ← TOO LONG, use 3000 max                   ║
║     - wait: 5000   ← Consider reducing to 2000                ║
║                                                                ║
║  ✅ Recommended wait times:                                    ║
║     - After click: 1000-2000ms                                 ║
║     - After form submit: 2000-3000ms                           ║
║     - After page navigate: 2000-3000ms                         ║
║     - For API response: 3000ms (then check, retry if needed)   ║
║                                                                ║
║  ⚠️  If operation exceeds 30s → Mark test as FAILED           ║
║      Record: "Timeout: {operation} exceeded 30s"               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**Timeout Configuration:**

```yaml
# Global timeout settings (apply to all tests)
timeouts:
  action: 30000 # Max time for any single action (30s)
  page_load: 30000 # Max time for page to load (30s)
  api_request: 30000 # Max time for API response (30s)
  wallet_popup: 30000 # Max time for wallet popup (30s)

# Recommended wait times in test steps
wait_times:
  after_click: 1000 # 1 second
  after_type: 500 # 0.5 seconds
  after_submit: 2000 # 2 seconds
  after_navigate: 2000 # 2 seconds
  for_animation: 500 # 0.5 seconds
  for_api: 3000 # 3 seconds (then verify)
```

### Rule 5: FIX TEST CASES DURING EXECUTION

```
╔════════════════════════════════════════════════════════════════╗
║          ✅ IMPROVE TEST CASES AS YOU RUN THEM                 ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Test cases from web-test-case-gen are NOT perfect!            ║
║  Human review may also miss issues.                            ║
║                                                                ║
║  WHEN TO MODIFY a test case during execution:                  ║
║                                                                ║
║  1. Step targets incorrect element                             ║
║     - click target selector doesn't match UI                   ║
║     - Selector points to wrong or non-existent element         ║
║                                                                ║
║  2. Steps are missing or in wrong order                        ║
║     - Need to add intermediate steps (e.g., close modal first) ║
║     - Steps should be reordered for correct flow               ║
║                                                                ║
║  3. Expected results are incorrect or incomplete               ║
║     - Expected text doesn't match actual UI text               ║
║     - Missing important verification points                    ║
║                                                                ║
║  4. Wait times are insufficient                                ║
║     - Page needs more time to load/update                      ║
║     - Animation takes longer than expected                     ║
║                                                                ║
║  5. Preconditions or dependencies are wrong                    ║
║     - Test should depend on another test                       ║
║     - Precondition is missing or incorrect                     ║
║                                                                ║
║  HOW TO MODIFY:                                                ║
║                                                                ║
║  1. Pause test execution                                       ║
║  2. Edit ./tests/test-cases.yaml directly                      ║
║  3. Resume/retry the test with fixed steps                     ║
║                                                                ║
║  ✅ ENCOURAGED actions:                                        ║
║     - Fix obvious typos or selector errors                     ║
║     - Add missing wait steps                                   ║
║     - Correct expected result descriptions                     ║
║     - Add missing intermediate steps                           ║
║                                                                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**Example: Fixing a test case mid-execution**

```
During TEST: SWAP-001

Problem detected:
  Step 3: click "Swap Now"
  Error: Button text is actually "Execute Swap" not "Swap Now"

Action taken:
  1. Edit ./tests/test-cases.yaml
  2. Change step target:
     - target: Swap Now button
     + target: Execute Swap button
  3. Retry SWAP-001 from step 3

Result: Test now passes ✅
```

### Rule 6: SEQUENTIAL EXECUTION ONLY - ONE TEST AT A TIME

```
╔════════════════════════════════════════════════════════════════╗
║            ⛔ CRITICAL: NO PARALLEL TEST EXECUTION ⛔           ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  1. Execute ONLY ONE test case at a time                       ║
║  2. WAIT for current test to FULLY COMPLETE before next        ║
║  3. NEVER run multiple tests in parallel                       ║
║                                                                ║
║  ❌ FORBIDDEN:                                                 ║
║     - Running 2+ tests simultaneously                          ║
║     - Starting next test before screenshots captured           ║
║     - Using parallel Task agents for different tests           ║
║                                                                ║
║  ✅ REQUIRED:                                                  ║
║     - Complete test → capture screenshots → record result      ║
║     - Only then start next test                                ║
║     - Respect depends_on order from test-cases.yaml            ║
║                                                                ║
║  WHY: Parallel tests cause:                                    ║
║     - Screenshot conflicts (wrong page captured)               ║
║     - Browser state corruption                                 ║
║     - Wallet popup handling failures                           ║
║     - Unpredictable test results                               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

## Prerequisites

**Test cases must exist in `./tests/` directory.**

If no test cases found, this skill will:

1. Prompt: "No test cases found. Run `skill web-test-case-gen` to generate them?"
2. Wait up to 2 minutes for user response
3. If timeout or user declines → Exit with failure

## Quick Start

```
Run the tests for this project
```

## Selective Test Execution

Users can request to run specific tests instead of all tests. **This is the ONLY valid reason to skip tests.**

### Execution Modes

| Mode                 | User Request Example                                 | What to Execute                 |
| -------------------- | ---------------------------------------------------- | ------------------------------- |
| **All Tests**        | "Run all tests"                                      | All tests in `execution_order`  |
| **By Module**        | "Run wallet module" / "Run swap module tests"        | Tests where `module` matches    |
| **By Feature**       | "Run Wallet tests" / "Test the swap feature"         | Tests where `feature` matches   |
| **By Priority/Type** | "Run negative tests" / "Run critical tests"          | Tests matching priority or type |
| **Single Test**      | "Run SWAP-001" / "Run the insufficient balance test" | Only the specified test         |

### Filter Logic

```
╔════════════════════════════════════════════════════════════════╗
║  SELECTIVE EXECUTION - HOW TO FILTER TESTS                     ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  1. Parse user request to determine filter:                    ║
║                                                                ║
║     "Run wallet module"     → filter by module: "wallet"       ║
║     "Run swap module tests" → filter by module: "swap"         ║
║     "Run swap tests"        → filter by feature: "Token Swap"  ║
║     "Run WALLET-001"        → filter by id: "WALLET-001"       ║
║     "Run critical tests"    → filter by priority: "critical"   ║
║     "Run negative tests"    → filter by type (from description)║
║                                                                ║
║  2. Build filtered execution list:                             ║
║                                                                ║
║     filtered_tests = []                                        ║
║     for test_id in execution_order:                            ║
║         test = find_test(test_id)                              ║
║         if matches_filter(test, user_filter):                  ║
║             filtered_tests.append(test_id)                     ║
║                                                                ║
║  3. IMPORTANT: Include dependencies!                           ║
║                                                                ║
║     If user requests "Run SWAP-001":                           ║
║       - SWAP-001 depends_on: [WALLET-001]                      ║
║       - Must run WALLET-001 first (as dependency)              ║
║       - Final list: [WALLET-001, SWAP-001]                     ║
║                                                                ║
║  4. Report what will be executed:                              ║
║                                                                ║
║     "Running 2 tests (1 requested + 1 dependency):             ║
║      - WALLET-001 (dependency of SWAP-001)                     ║
║      - SWAP-001 (requested)"                                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

### Filter by Module

Match tests where `test.module` equals the module ID:

```yaml
# User: "Run wallet module" or "Run wallet module tests"
# Matches tests with module: "wallet"
- id: WALLET-001
  module: wallet          # ✓ Match
- id: WALLET-DISCONNECT-001
  module: wallet          # ✓ Match
- id: SWAP-001
  module: swap            # ✗ No match

# Available modules are defined in config.yaml:
modules:
  - id: wallet
    name: Wallet
  - id: swap
    name: Token Swap
```

**Module vs Feature:**

- `module`: High-level grouping (e.g., "wallet", "swap", "rewards")
- `feature`: Specific functionality within a module (e.g., "Wallet Connection", "Wallet Disconnect")

Use module filtering when you want to run all tests related to a major functional area.

### Filter by Feature

Match tests where `test.feature` contains the keyword:

```yaml
# User: "Run wallet tests"
# Matches tests with feature containing "Wallet":
- id: WALLET-001
  feature: Wallet Connection # ✓ Match
- id: WALLET-DISCONNECT-001
  feature: Wallet Connection # ✓ Match
- id: SWAP-001
  feature: Token Swap # ✗ No match
```

### Filter by Test ID

Match exact test ID or partial match:

```yaml
# User: "Run SWAP-001"
# Exact match: only SWAP-001

# User: "Run SWAP tests"
# Partial match: SWAP-001, SWAP-002, SWAP-003, SWAP-FAIL-001
```

### Filter by Priority

Match tests where `test.priority` equals the keyword:

```yaml
# User: "Run critical tests"
# Matches: priority: critical

# User: "Run high priority tests"
# Matches: priority: high
```

### Filter by Type (Positive/Negative)

Determine from test description or naming:

```yaml
# User: "Run negative tests"
# Match tests where:
#   - description.notes contains "NEGATIVE test case"
#   - OR id contains "FAIL" or "DISCONNECT" or "ERROR"

# User: "Run positive tests" / "Run happy path tests"
# Match tests that are NOT negative tests
```

### Dependency Resolution

**CRITICAL:** When running filtered tests, always include required dependencies:

```
User requests: "Run SWAP-002"

SWAP-002:
  depends_on: [WALLET-001, SWAP-001]

Resolution:
  1. SWAP-002 needs WALLET-001 → add WALLET-001
  2. SWAP-002 needs SWAP-001 → add SWAP-001
  3. SWAP-001 needs WALLET-001 → already added

Final execution order: [WALLET-001, SWAP-001, SWAP-002]

Report to user:
  "Running 3 tests:
   - WALLET-001 (dependency)
   - SWAP-001 (dependency)
   - SWAP-002 (requested)"
```

### Example Prompts

| User Says                           | Filter Applied          | Tests Executed                                               |
| ----------------------------------- | ----------------------- | ------------------------------------------------------------ |
| "Run all tests"                     | None                    | All in execution_order                                       |
| "Run wallet module"                 | module = wallet         | All tests with module: wallet                                |
| "Run swap module tests"             | module = swap           | SWAP-001, SWAP-002, SWAP-003 + dependencies                  |
| "Run WALLET-001"                    | id = WALLET-001         | WALLET-001                                                   |
| "Run swap feature tests"            | feature contains "Swap" | SWAP-001, SWAP-002, SWAP-003 + dependencies                  |
| "Run critical tests only"           | priority = critical     | WALLET-001, SWAP-001, SWAP-002                               |
| "Run negative tests"                | type = negative         | SWAP-003, WALLET-DISCONNECT-\*, SWAP-FAIL-001 + dependencies |
| "Run the insufficient balance test" | name/id match           | SWAP-003 + WALLET-001 (dependency)                           |

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  web-test                                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Step 1: Check for test cases                                   │
│          ↓                                                      │
│          tests/config.yaml exists?                              │
│          tests/test-cases.yaml exists?                          │
│          ├─ NO  → Prompt user, wait 2 min, fail if no response  │
│          └─ YES → Continue                                      │
│          ↓                                                      │
│  Step 2: Use skill web-test-cleanup                             │
│          ↓                                                      │
│  Step 3: Read config.yaml                                       │
│          ↓                                                      │
│          Is Web3 DApp? (web3.enabled: true)                     │
│          ├─ YES → Step 4: Use skill web-test-wallet-setup       │
│          └─ NO  → Skip Step 4                                   │
│          ↓                                                      │
│  Step 5: Execute test cases                                     │
│          For each test in execution_order:                      │
│          - Check preconditions (e.g., WALLET-001 passed)        │
│          - If WALLET-001: uses web-test-wallet-connect          │
│          - Run test steps                                       │
│          - Record pass/fail                                     │
│          ↓                                                      │
│  Step 6: Use skill web-test-report                              │
│          ↓                                                      │
│  Step 7: Use skill web-test-cleanup --keep-data                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Instructions

### Step 1: Check for Test Cases

```bash
# Check if test files exist
ls -la ./tests/config.yaml ./tests/test-cases.yaml
```

**If files don't exist:**

```
No test cases found in ./tests/ directory.

Would you like to generate test cases first?
Run: skill web-test-case-gen

Waiting for response (2 minute timeout)...
```

If user doesn't respond within 2 minutes or says no, exit with:

```
Test execution cancelled. No test cases available.
To generate test cases, run: skill web-test-case-gen
```

### Step 2: Run Cleanup

```
Use skill web-test-cleanup
```

### Step 3: Parse Config and Load Test Cases

Read `./tests/config.yaml`:

```bash
cat ./tests/config.yaml
```

**config.yaml Structure:**

```yaml
project:
  name: MyDApp # Project name (for reports)
  url: http://localhost:3000 # Base URL for testing
  framework: React # Framework (informational)

web3:
  enabled: true # true = Web3 DApp, false = regular web app
  wallet: metamask # Wallet type
  network: ethereum # Network name

generated:
  date: 2024-01-15T14:30:00Z
  by: web-test-case-gen

# Module definitions for organized test execution
modules:
  - id: wallet # Module identifier (used in commands)
    name: Wallet # Human-readable name
    description: Wallet connection and management tests
  - id: swap
    name: Token Swap
    description: Token swap functionality tests
  - id: rewards
    name: Rewards
    description: Rewards claiming and staking tests

features: # Features detected (informational)
  - name: Token Swap
    code: src/features/swap/

execution_order: # CRITICAL: Test execution order
  - WALLET-001 # Execute tests in THIS ORDER
  - SWAP-001
  - SWAP-002
```

**Fields to Extract from config.yaml:**
| Field | Usage |
|-------|-------|
| `project.url` | Base URL - prepend to relative URLs in steps |
| `web3.enabled` | If `true`, run `web-test-wallet-setup` before tests |
| `modules` | Array of module definitions - for filtering tests by module |
| `execution_order` | Array of test IDs - execute in this exact order |

---

Read `./tests/test-cases.yaml`:

```bash
cat ./tests/test-cases.yaml
```

**test-cases.yaml Structure:**

```yaml
test_cases:
  - id: WALLET-001 # Unique test ID (matches execution_order)
    name: Connect Wallet # Human-readable name
    module: wallet # Module this test belongs to (matches modules[].id in config.yaml)
    feature: Wallet Connection
    priority: critical # critical/high/medium/low
    web3: true # Requires wallet interaction
    wallet_popups: 1 # Expected number of wallet popups
    depends_on: [] # Test case dependencies (IDs only)
    preconditions: [] # Other requirements (not test IDs)
    description:
      purpose: | # Why this test exists
        Verify user can connect wallet...
      notes: # Important points to remember
        - Must run first
        - Check wallet address displayed
    uses_skill: web-test-wallet-connect # Optional: skill to use
    steps: # Actions to execute
      - action: navigate
        url: /
      - action: screenshot
        name: before-connect
      - action: click
        selector: text=Connect Wallet
      - action: wallet-approve
    expected: # What to verify after steps
      - Wallet address displayed in header
      - Connection modal closed
```

**Test Case Fields Reference:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier (e.g., WALLET-001) |
| `name` | string | Human-readable test name |
| `module` | string | Module ID this test belongs to (matches config.yaml modules[].id) |
| `feature` | string | Specific functionality name (e.g., "Wallet Connection", "Token Swap") |
| `depends_on` | array | Test IDs that must pass first |
| `preconditions` | array | Other requirements (NOT test IDs) |
| `description.purpose` | string | What this test verifies |
| `description.notes` | array | Important execution notes |
| `uses_skill` | string | Optional skill to invoke |
| `steps` | array | Actions to execute |
| `expected` | array | Expected outcomes to verify |

### Step 4: Wallet Setup (if Web3)

**Skip this step if `web3.enabled: false` or not set.**

```
Use skill web-test-wallet-setup
```

This sets up the wallet extension (download, import private key).
Wallet connection is handled by test case WALLET-001 during test execution.

### Step 5: Execute Test Cases

**⚠️ EXECUTE EVERY TEST - NO EXCEPTIONS FOR "TIME CONSTRAINTS" ⚠️**
**⚠️ ONE TEST AT A TIME - NO PARALLEL EXECUTION ⚠️**

For each test ID in `execution_order` (SEQUENTIALLY, ONE AT A TIME):

1. Find the test case in `test-cases.yaml`
2. Check `depends_on` - skip if any dependency failed
3. Check preconditions
4. Execute each step
5. Verify expected results
6. Record pass/fail
7. **WAIT for completion before next test**

```
┌─────────────────────────────────────────────────────────────────┐
│  DEPENDENCY CHECK BEFORE EACH TEST                              │
│                                                                 │
│  if test.depends_on is not empty:                               │
│      for each dep_id in test.depends_on:                        │
│          if results[dep_id] != PASS:                            │
│              SKIP this test                                     │
│              reason: "Dependency {dep_id} did not pass"         │
│                                                                 │
│  Example:                                                       │
│    SWAP-002 depends_on: [WALLET-001, SWAP-001]                  │
│    - If WALLET-001 failed → SKIP SWAP-002                       │
│    - If SWAP-001 failed → SKIP SWAP-002                         │
│    - If both passed → RUN SWAP-002                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────────┐
│  REMINDER: You MUST execute ALL tests in execution_order.       │
│                                                                 │
│  ❌ DO NOT skip any test because:                               │
│     - "Time constraints" / "To save time"                       │
│     - "Similar to previous test"                                │
│     - "Already tested enough"                                   │
│                                                                 │
│  ✅ Continue executing even if:                                 │
│     - Tests are taking a long time                              │
│     - You've already run many tests                             │
│     - Some tests seem redundant to you                          │
│                                                                 │
│  The user created these tests for a reason. Execute them ALL.   │
└─────────────────────────────────────────────────────────────────┘
```

**Executing Steps - Detailed Guide:**

```
╔════════════════════════════════════════════════════════════════╗
║  HOW TO EXECUTE EACH ACTION TYPE                               ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  For each step in test.steps array:                            ║
║                                                                ║
║  1. Read step.action to determine action type                  ║
║  2. Execute using test-helper.js or skill                      ║
║  3. Check for errors before proceeding to next step            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

| Action              | Parameters                      | How to Execute                                                                                  |
| ------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------- |
| `set-viewport`      | `width`, `height`, `isMobile`   | `node $SKILL_DIR/scripts/test-helper.js set-viewport [width] [height] --mobile --headed --keep-open` |
| `navigate`          | `url`                           | `node $SKILL_DIR/scripts/test-helper.js navigate [project.url + step.url] --headed --keep-open` |
| `screenshot` | `name`                          | `node $SKILL_DIR/scripts/test-helper.js screenshot [step.name].jpg --headed --keep-open` |
| `click`             | `selector`                      | `node $SKILL_DIR/scripts/test-helper.js click "[step.selector]" --headed --keep-open`           |
| `fill`              | `selector`, `value`             | `node $SKILL_DIR/scripts/test-helper.js fill "[step.selector]" "[step.value]" --headed --keep-open` |
| `wait`              | `ms`, `reason`                  | `node $SKILL_DIR/scripts/test-helper.js wait [step.ms] --headed --keep-open`                    |
| `wallet-approve`    | `note`                          | Use `skill web-test-wallet-sign` with approve action                                            |
| `wallet-reject`     | `note`                          | Use `skill web-test-wallet-sign` with reject action                                             |
| `set-network`       | `options` (--latency/--offline/--online) | `node $SKILL_DIR/scripts/test-helper.js set-network [step.options] --headed --keep-open`  |
| `mock-route`        | `pattern`, `options`            | `node $SKILL_DIR/scripts/test-helper.js mock-route "[step.pattern]" [step.options] --headed --keep-open` |
| `mock-api-error`    | `pattern`, `options`            | `node $SKILL_DIR/scripts/test-helper.js mock-api-error "[step.pattern]" [step.options] --headed --keep-open` |
| `mock-timeout`      | `pattern`                       | `node $SKILL_DIR/scripts/test-helper.js mock-timeout "[step.pattern]" --headed --keep-open`     |
| `throttle-network`  | `preset`                        | `node $SKILL_DIR/scripts/test-helper.js throttle-network [step.preset] --headed --keep-open`    |
| `clear-network`     | -                               | `node $SKILL_DIR/scripts/test-helper.js clear-network --headed --keep-open`                     |

**Handling `uses_skill` Field:**

When a test case has `uses_skill` field, invoke that skill instead of executing steps manually:

**Verifying Expected Results:**

After executing all steps, verify each item in `test.expected`:

### Automatic Wallet Sign Detection

After each `click` action in wallet mode, the system automatically detects MetaMask popups and handles them. Use the `walletAction` field to control the behavior:

| walletAction        | Behavior                                                       |
| ------------------- | -------------------------------------------------------------- |
| `approve` (default) | Auto-approve signatures and transactions (reject if gas error) |
| `reject`            | Reject the signature/transaction (for testing rejection flows) |
| `ignore`            | Don't wait for popup, skip detection                           |

**Example:**

```yaml
steps:
  # Auto-approve (default behavior)
  - action: click
    selector: "#sign-button"

  # Test rejection flow
  - action: click
    selector: "#sign-button"
    walletAction: reject

  # Skip popup detection for non-wallet clicks
  - action: click
    selector: "#regular-button"
    walletAction: ignore
```

### Step 6: Generate Report

```
Use skill web-test-report
```

### Step 7: Final Cleanup

```
Use skill web-test-cleanup --keep-data
```

## Test Helper Commands

**Location:** `scripts/test-helper.js`

### How to Call Scripts

```
╔════════════════════════════════════════════════════════════════╗
║  SCRIPT CALLING GUIDE                                          ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Step 1: Get the skill directory path                          ║
║                                                                ║
║    SKILL_DIR="/Users/duxiaofeng/code/agent-skills/web-test"    ║
║                                                                ║
║  Step 2: Call test-helper.js with command and options          ║
║                                                                ║
║    node $SKILL_DIR/scripts/test-helper.js <command> [args] [options]
║                                                                ║
║  IMPORTANT OPTIONS:                                            ║
║    --headed      Show browser window (required for vision)     ║
║    --keep-open   Keep browser open after command               ║
║    --wallet      Load MetaMask wallet extension                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**Full Command Examples:**

```bash
# Set skill directory
SKILL_DIR="/Users/duxiaofeng/code/agent-skills/web-test"

# Navigate to URL
node $SKILL_DIR/scripts/test-helper.js navigate "http://localhost:3000" --headed --keep-open

# Take screenshot for AI analysis
node $SKILL_DIR/scripts/test-helper.js screenshot before-test --headed --keep-open

# Click element using selector (text, css, or id)
node $SKILL_DIR/scripts/test-helper.js click "text=Submit" --headed --keep-open
node $SKILL_DIR/scripts/test-helper.js click "#submit-btn" --headed --keep-open

# Fill input field
node $SKILL_DIR/scripts/test-helper.js fill "#email" "test@example.com" --headed --keep-open

# Press key
node $SKILL_DIR/scripts/test-helper.js press-key Enter --headed --keep-open

# Wait for milliseconds
node $SKILL_DIR/scripts/test-helper.js wait 2000 --headed --keep-open

# Scroll page
node $SKILL_DIR/scripts/test-helper.js scroll down 500 --headed --keep-open

# Set mobile viewport
node $SKILL_DIR/scripts/test-helper.js set-viewport 375 667 --mobile --headed --keep-open

# With wallet extension (for Web3 DApps)
node $SKILL_DIR/scripts/test-helper.js navigate "http://localhost:3000" --headed --keep-open --wallet
```

**Output Format:**

All commands output JSON to stdout:
```json
{
  "success": true,
  "screenshot": "test-output/screenshots/before-test.jpg",
  "url": "http://localhost:3000",
  "instruction": "Use the Read tool to view this screenshot..."
}
```

### All Available Commands

---

#### Browser Lifecycle Commands

| Command | Args | Description |
|---------|------|-------------|
| `start` | - | Start browser session |
| `stop` | - | Stop browser session |
| `browser-open` | - | Open browser and keep it running (auto --headed) |
| `browser-close` | - | Close the browser explicitly |

```bash
# Open browser for manual inspection
node $SKILL_DIR/scripts/test-helper.js browser-open

# Close browser when done
node $SKILL_DIR/scripts/test-helper.js browser-close
```

---

#### Navigation Commands

| Command | Args | Description |
|---------|------|-------------|
| `navigate` | `<url>` | Navigate to URL |
| `screenshot` | `[name]` | Take screenshot |
| `content` | - | Get page HTML content (saves to test-output/page-content.html) |

```bash
# Navigate to URL
node $SKILL_DIR/scripts/test-helper.js navigate "http://localhost:3000" --headed --keep-open

# Take screenshot
node $SKILL_DIR/scripts/test-helper.js screenshot home --headed --keep-open
```

---

#### Element Interaction Commands (Selector-based)

| Command | Args | Description |
|---------|------|-------------|
| `click` | `<selector>` | Click element by CSS selector |
| `fill` | `<selector> <value>` | Fill input field |
| `select` | `<selector> <value>` | Select dropdown option |
| `check` | `<selector>` | Check checkbox |
| `uncheck` | `<selector>` | Uncheck checkbox |
| `hover` | `<selector>` | Hover over element |
| `press` | `<selector> <key>` | Press key on element |
| `text` | `<selector>` | Get element text content |

```bash
# Click button by selector
node $SKILL_DIR/scripts/test-helper.js click "#submit-btn" --headed --keep-open

# Fill input field
node $SKILL_DIR/scripts/test-helper.js fill "#email" "test@example.com" --headed --keep-open

# Select dropdown option
node $SKILL_DIR/scripts/test-helper.js select "#country" "US" --headed --keep-open

# Check/uncheck checkbox
node $SKILL_DIR/scripts/test-helper.js check "#agree-terms" --headed --keep-open
node $SKILL_DIR/scripts/test-helper.js uncheck "#newsletter" --headed --keep-open

# Hover over element
node $SKILL_DIR/scripts/test-helper.js hover "#dropdown-menu" --headed --keep-open

# Press key on element
node $SKILL_DIR/scripts/test-helper.js press "#search-input" Enter --headed --keep-open

# Get element text
node $SKILL_DIR/scripts/test-helper.js text "#balance" --headed --keep-open
```

---

#### Utility Commands

| Command | Args | Description |
|---------|------|-------------|
| `screenshot` | `[name]` | Take screenshot |
| `press-key` | `<key>` | Press keyboard key globally (Enter, Tab, Escape, etc.) |
| `scroll` | `<dir> [amount]` | Scroll page (dir: up/down/left/right) |
| `wait-stable` | `[ms]` | Wait for page to stabilize (network idle) |
| `get-page-info` | - | Get page info and screenshot |

**NOTE:** Use `click`, `fill`, `hover` commands with text/css/id selectors for element interactions.

```bash
# Take screenshot
node $SKILL_DIR/scripts/test-helper.js screenshot before-click --headed --keep-open

# Press keyboard key
node $SKILL_DIR/scripts/test-helper.js press-key Enter --headed --keep-open
node $SKILL_DIR/scripts/test-helper.js press-key Tab --headed --keep-open
node $SKILL_DIR/scripts/test-helper.js press-key Escape --headed --keep-open

# Scroll page
node $SKILL_DIR/scripts/test-helper.js scroll down 500 --headed --keep-open
node $SKILL_DIR/scripts/test-helper.js scroll up 300 --headed --keep-open

# Wait for page stability
node $SKILL_DIR/scripts/test-helper.js wait-stable 5000 --headed --keep-open

# Get full page info for AI
node $SKILL_DIR/scripts/test-helper.js get-page-info --headed --keep-open
```

---

#### Utility Commands

| Command | Args | Description |
|---------|------|-------------|
| `wait` | `<ms>` | Wait milliseconds |
| `wait-for` | `<selector>` | Wait for element to appear |
| `evaluate` | `<js>` | Evaluate JavaScript in page |
| `list-elements` | - | List all interactive elements (saves to test-output/elements.json) |

```bash
# Wait 2 seconds
node $SKILL_DIR/scripts/test-helper.js wait 2000 --headed --keep-open

# Wait for element to appear
node $SKILL_DIR/scripts/test-helper.js wait-for "#loading-complete" --headed --keep-open

# Evaluate JavaScript
node $SKILL_DIR/scripts/test-helper.js evaluate "document.title" --headed --keep-open

# List all interactive elements on page
node $SKILL_DIR/scripts/test-helper.js list-elements --headed --keep-open
```

---

#### Login Detection Commands

| Command | Args | Description |
|---------|------|-------------|
| `detect-login-required` | - | Detect if login/auth is required |
| `wait-for-login` | - | Wait for manual login (auto switches to headed mode) |

```bash
# Check if login is required
node $SKILL_DIR/scripts/test-helper.js detect-login-required --headed --keep-open

# Wait for user to manually login (5 min timeout by default)
node $SKILL_DIR/scripts/test-helper.js wait-for-login --timeout 300000 --keep-open
```

---

#### Dev Server Commands

| Command | Args | Description |
|---------|------|-------------|
| `dev-server-start` | `[dir] [port]` | Start dev server for project |
| `dev-server-stop` | - | Stop the running dev server |
| `dev-server-status` | - | Check dev server status |

```bash
# Start dev server (auto-detects framework)
node $SKILL_DIR/scripts/test-helper.js dev-server-start . 3000

# Check dev server status
node $SKILL_DIR/scripts/test-helper.js dev-server-status

# Stop dev server
node $SKILL_DIR/scripts/test-helper.js dev-server-stop
```

---

#### Network Emulation Commands

Use these commands to test how your application handles various network conditions.

| Command | Args/Options | Description |
|---------|--------------|-------------|
| `set-network` | `--latency <ms>` | Add delay to all network requests |
| `set-network` | `--offline` | Simulate offline mode (all requests fail) |
| `set-network` | `--online` | Restore online mode |
| `mock-route` | `<pattern> --status <code> [--body <text>] [--json <json>] [--delay <ms>]` | Mock API response |
| `mock-api-error` | `<pattern> --status <code> [--message <text>]` | Mock API error response |
| `mock-timeout` | `<pattern> [--after <ms>]` | Make request hang/timeout |
| `throttle-network` | `<preset>` | Throttle network (slow-3g, fast-3g, regular-4g, offline, none) |
| `clear-network` | `[pattern]` | Clear all or specific network mocks |
| `network-status` | - | Show current network emulation status |

**Pattern Matching:**

| Pattern | Matches |
|---------|---------|
| `**/api/users` | `/api/users`, `https://example.com/api/users` |
| `**/api/*` | `/api/users`, `/api/posts`, `/api/data` |
| `**/*.json` | All .json files |
| `**/api/**` | `/api/v1/users/123` (multi-level paths) |

**Examples:**

```bash
SKILL_DIR="/Users/duxiaofeng/code/agent-skills/web-test"

# ============================================
# LATENCY SIMULATION
# ============================================

# Add 3 second delay to all requests
node $SKILL_DIR/scripts/test-helper.js set-network --latency 3000 --headed --keep-open

# Navigate and observe loading behavior
node $SKILL_DIR/scripts/test-helper.js navigate "http://localhost:3000" --headed --keep-open

# Remove latency
node $SKILL_DIR/scripts/test-helper.js set-network --latency 0 --headed --keep-open

# ============================================
# OFFLINE MODE
# ============================================

# Simulate offline mode
node $SKILL_DIR/scripts/test-helper.js set-network --offline --headed --keep-open

# Try to navigate (will fail, test error handling)
node $SKILL_DIR/scripts/test-helper.js navigate "http://localhost:3000/dashboard" --headed --keep-open

# Restore online mode
node $SKILL_DIR/scripts/test-helper.js set-network --online --headed --keep-open

# ============================================
# API MOCKING
# ============================================

# Mock API to return custom response
node $SKILL_DIR/scripts/test-helper.js mock-route "**/api/users" --status 200 --json '{"users":[]}' --headed --keep-open

# Mock API to return 500 error
node $SKILL_DIR/scripts/test-helper.js mock-api-error "**/api/data" --status 500 --message "Database connection failed" --headed --keep-open

# Mock API with delayed response
node $SKILL_DIR/scripts/test-helper.js mock-route "**/api/slow" --status 200 --body "OK" --delay 5000 --headed --keep-open

# ============================================
# TIMEOUT SIMULATION
# ============================================

# Make request hang forever (tests app timeout handling)
node $SKILL_DIR/scripts/test-helper.js mock-timeout "**/api/data" --headed --keep-open

# Make request hang for 10s then timeout
node $SKILL_DIR/scripts/test-helper.js mock-timeout "**/api/data" --after 10000 --headed --keep-open

# ============================================
# NETWORK THROTTLING (3G/4G Simulation)
# ============================================

# Simulate slow 3G network (2s latency, ~50kb/s download)
node $SKILL_DIR/scripts/test-helper.js throttle-network slow-3g --headed --keep-open

# Simulate fast 3G network (560ms latency, ~1.5Mb/s download)
node $SKILL_DIR/scripts/test-helper.js throttle-network fast-3g --headed --keep-open

# Simulate regular 4G network (170ms latency, ~4Mb/s download)
node $SKILL_DIR/scripts/test-helper.js throttle-network regular-4g --headed --keep-open

# Remove throttling
node $SKILL_DIR/scripts/test-helper.js throttle-network none --headed --keep-open

# ============================================
# CLEANUP
# ============================================

# Clear all network mocks and restore normal behavior
node $SKILL_DIR/scripts/test-helper.js clear-network --headed --keep-open

# Clear specific route mock
node $SKILL_DIR/scripts/test-helper.js clear-network "**/api/data" --headed --keep-open

# Check current network emulation status
node $SKILL_DIR/scripts/test-helper.js network-status --headed --keep-open
```

**How Network Mocking Works:**

```
╔════════════════════════════════════════════════════════════════╗
║  NETWORK INTERCEPTION MECHANISM                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Browser sends request                                         ║
║       │                                                        ║
║       ▼                                                        ║
║  ┌─────────────────────────────┐                               ║
║  │ Playwright Route Interceptor │                              ║
║  │ (checks if pattern matches)  │                              ║
║  └─────────────────────────────┘                               ║
║       │                                                        ║
║       ├── Pattern matches?                                     ║
║       │   │                                                    ║
║       │   ├── YES → Execute mock handler                       ║
║       │   │         - mock-route: return fake response         ║
║       │   │         - mock-api-error: return error response    ║
║       │   │         - mock-timeout: never respond              ║
║       │   │         - set-network --latency: delay then pass   ║
║       │   │                                                    ║
║       │   └── NO → Continue to real server                     ║
║       │                                                        ║
║  Real server NEVER receives intercepted requests!              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

**Test Case Example with Network Mocking:**

```yaml
# Test API error handling
- id: NET-ERROR-001
  name: API 500 Error Handling
  type: network
  module: api
  feature: Error Handling
  priority: high
  steps:
    # Mock API to return 500 error
    - action: mock-api-error
      pattern: "**/api/data"
      options: "--status 500"
    # Navigate to page that calls this API
    - action: navigate
      url: /dashboard
    # Take screenshot of error state
    - action: screenshot
      name: api-error-state
    # Clean up mock
    - action: clear-network
  expected:
    - User-friendly error message displayed
    - Retry button available
    - No raw error or stack trace shown

# Test slow network handling
- id: NET-SLOW-001
  name: Slow Network Loading States
  type: network
  module: api
  feature: Loading States
  priority: medium
  steps:
    # Add 3s latency
    - action: set-network
      options: "--latency 3000"
    # Navigate and observe loading
    - action: navigate
      url: /
    - action: screenshot
      name: loading-state
    # Wait for content
    - action: wait
      ms: 4000
    - action: screenshot
      name: loaded-state
    # Clean up
    - action: clear-network
  expected:
    - Loading indicator shown during wait
    - Content loads successfully after delay
```

---

#### Viewport Control

| Command | Args | Description |
|---------|------|-------------|
| `set-viewport` | `<width> <height> [--mobile]` | Set viewport size for mobile testing |

**Mobile viewport sizes:**

| Device       | Width | Height | Command                                  |
| ------------ | ----- | ------ | ---------------------------------------- |
| iPhone SE    | 375   | 667    | `set-viewport 375 667 --mobile`          |
| iPhone 12    | 390   | 844    | `set-viewport 390 844 --mobile`          |
| iPhone 14 Pro| 393   | 852    | `set-viewport 393 852 --mobile`          |
| Pixel 5      | 393   | 851    | `set-viewport 393 851 --mobile`          |
| Samsung S20  | 360   | 800    | `set-viewport 360 800 --mobile`          |

---

### Common Options

| Option | Description |
|--------|-------------|
| `--headed` | Show browser window (required for vision commands) |
| `--headless` | Run headless (default) |
| `--keep-open` | Keep browser open after command |
| `--wallet` | Load MetaMask wallet extension |
| `--screenshot <name>` | Take screenshot after action |
| `--wait <ms>` | Wait after action |
| `--timeout <ms>` | Action timeout (default: 10000) |
| `--mobile` | Use mobile viewport |

## Example Test Execution

**tests/config.yaml:**

```yaml
project:
  name: MyDApp
  url: http://localhost:3000

web3:
  enabled: true

execution_order:
  - WALLET-001 # Connect wallet (uses web-test-wallet-connect)
  - SWAP-001 # depends_on: [WALLET-001]
  - SWAP-002 # depends_on: [WALLET-001, SWAP-001]
```

**Execution flow (SEQUENTIAL - ONE AT A TIME):**

```
1. ✓ Found tests/config.yaml
2. ✓ Found tests/test-cases.yaml
3. Running web-test-cleanup...
4. Web3 DApp detected (web3.enabled: true)
   - Running web-test-wallet-setup... (ONCE at start)
   - Wallet extension ready
5. Executing test cases (SEQUENTIAL - ONE AT A TIME):

   ┌──────────────────────────────────────────────────────────────┐
   │  TEST 1/3: WALLET-001                                        │
   │  depends_on: [] (no dependencies)                            │
   └──────────────────────────────────────────────────────────────┘
   ├─ [This test uses web-test-wallet-connect skill]
   ├─ navigate /
   ├─ screenshot before-connect.jpg
   ├─ click "text=Connect Wallet"
   ├─ click "text=MetaMask"
   ├─ wallet-approve
   ├─ screenshot after-connect.jpg
   └─ ✅ PASS - Wallet address displayed

   ⏳ WAITING for WALLET-001 to complete before next test...
   ✓ WALLET-001 completed. Starting next test.

   ┌──────────────────────────────────────────────────────────────┐
   │  TEST 2/3: SWAP-001                                          │
   │  depends_on: [WALLET-001] → checking...                      │
   │  ✓ WALLET-001 passed - proceeding                            │
   └──────────────────────────────────────────────────────────────┘
   ├─ navigate /swap
   ├─ [execute steps...]
   └─ ✅ PASS - Swap successful

   ⏳ WAITING for SWAP-001 to complete before next test...
   ✓ SWAP-001 completed. Starting next test.

   ┌──────────────────────────────────────────────────────────────┐
   │  TEST 3/3: SWAP-002                                          │
   │  depends_on: [WALLET-001, SWAP-001] → checking...            │
   │  ✓ WALLET-001 passed                                         │
   │  ✓ SWAP-001 passed - proceeding                              │
   └──────────────────────────────────────────────────────────────┘
   ├─ navigate /swap
   ├─ [execute steps...]
   └─ ✅ PASS - ERC20 swap successful

6. Generating report...
7. Final cleanup (keeping data)...

Test Results:
✅ WALLET-001: Connect Wallet - PASS
✅ SWAP-001: Swap Native Token - PASS
✅ SWAP-002: Swap ERC20 Token - PASS

3/3 tests passed (100%)
```

## Data Storage

All test artifacts in project directory:

```
<project-root>/
├── tests/                # Test case definitions ONLY (YAML/MD files)
│   ├── config.yaml       # ← NO screenshots here!
│   ├── test-cases.yaml
│   └── README.md
└── test-output/          # Runtime artifacts (screenshots, logs, etc.)
    ├── screenshots/      # ← ALL screenshots go here
    ├── chrome-profile/   # Browser state
    ├── console-logs.txt  # Browser console
    └── test-report-YYYYMMDD-HHMMSS.md  # Timestamped report (new file each run)
```

**IMPORTANT:** Never save screenshots to `tests/`. Screenshots always go to `test-output/screenshots/`.

## Related Skills

| Skill                   | Usage                                             |
| ----------------------- | ------------------------------------------------- |
| web-test-case-gen       | Generates test cases (run first if no tests/)     |
| web-test-cleanup        | Called at start and end                           |
| web-test-wallet-setup   | Called ONCE at start if `web3.enabled: true`      |
| web-test-wallet-connect | Called by WALLET-001 test case or as precondition |
| web-test-report         | Called after test execution                       |

## Error Handling

| Scenario             | Action                                         |
| -------------------- | ---------------------------------------------- |
| No tests/ directory  | Prompt user, wait 2 min, fail if no response   |
| Test case fails      | Record failure, **continue to next test**      |
| Wallet popup timeout | Mark test as failed, **continue to next test** |
| Page load timeout    | Mark test as failed, **continue to next test** |
| Test takes long time | **WAIT for it** - do NOT skip                  |

**⚠️ IMPORTANT: Errors are NOT a reason to skip remaining tests!**

When a test fails or times out:

1. Record the failure with details
2. Take a screenshot if possible
3. **Continue to the next test** - do NOT stop or skip remaining tests
4. **NEVER use "time constraints" as a reason** - this is invalid

## Notes

- Test cases are read from `./tests/` in the project being tested
- Always use `--headed --keep-open` for interactive testing
- Use text/css/id selectors for stable element interactions
- For Web3 testing, wallet skills handle all wallet interactions
