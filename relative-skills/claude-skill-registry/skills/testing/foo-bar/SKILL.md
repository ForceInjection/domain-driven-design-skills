---
name: heal_selftest
description: Diagnose and repair selftest failures by running diagnostic commands and proposing fixes
allowed-tools: Bash, Read, Write
category: governance
tier: critical
---

# Heal Selftest Skill

You are a helper for diagnosing and repairing selftest failures in this repository. This skill teaches agents how to systematically identify, categorize, and fix problems that cause selftest steps to fail.

## When to Use This Skill

- A selftest step is failing and you need to understand why
- You want to propose targeted fixes without breaking other tests
- You need to distinguish between KERNEL, GOVERNANCE, and OPTIONAL tier failures
- You're trying to get a change ready for merge (selftest must be GREEN)
- You need to determine if a failure is fixable within current scope or requires escalation

## What This Skill Does

The skill provides a structured **diagnostic procedure** for:

1. **Kernel health check** — Verify the repo isn't fundamentally broken
2. **Failure identification** — List which selftest steps are failing
3. **Root cause analysis** — Understand why each step failed
4. **Severity classification** — Categorize by tier (P0 KERNEL, P1/P2 GOVERNANCE, P3 OPTIONAL)
5. **Targeted remediation** — Propose specific fixes with code changes
6. **Escalation criteria** — Know when to hand off to a human

## Prerequisites

Before using this skill:

- Access to `uv`, `cargo`, and standard Unix tools
- Understanding that KERNEL-tier failures are **blocking** (must fix before merge)
- Understanding that GOVERNANCE failures can be **warned** in degraded mode if necessary
- Permission to modify source code, tests, configs, and flow specs
- Git repo in a clean or committable state (no stashed changes)

## Typical Workflow

```
User reports: "Selftest is failing"
            ↓
Step 1: Check Kernel Health (make kernel-smoke)
      ↓ PASS → Continue
      ↓ FAIL → STOP, escalate
      ↓
Step 2: Show Selftest Plan (see all steps, tiers)
      ↓
Step 3: Identify Failed Steps (run selftest, capture output)
      ↓
Step 4: Run Failed Steps Individually (debug each one)
      ↓
Step 5: Categorize Errors (syntax, logic, dependency, etc.)
      ↓
Step 6: Propose Fixes (with code diffs, command changes, etc.)
      ↓
Step 7: Output Healing Report (findings + recommendations)
```

---

## Diagnostic Procedure (Step-by-Step)

### Step 1: Check Kernel Health

**Purpose**: Verify the repo isn't fundamentally broken. If kernel is broken, escalate immediately.

**Command**:
```bash
make kernel-smoke
# or
uv run swarm/tools/kernel_smoke.py --verbose
```

**What to look for**:
- Exit code 0 = Kernel is healthy, continue to Step 2
- Exit code 1 or 2 = Kernel is broken, escalate to human immediately

**If kernel is broken**:
```
STATUS: BLOCKED - Kernel health check failed
RECOMMENDATION: Stop here. The repository is fundamentally broken.
ESCALATION: Human must fix kernel issues before other selftest work can proceed.
```

**If kernel is healthy**:
```
STATUS: PASS - Kernel health check passed
RECOMMENDATION: Continue to Step 2
```

---

### Step 2: Show Selftest Plan

**Purpose**: Understand the full selftest structure—all steps, their tiers, and dependencies.

**Command**:
```bash
uv run swarm/tools/selftest.py --plan
# or
make selftest-plan
```

**Output format** (you'll see something like):
```
SELFTEST PLAN (16 steps)
├─ 1. core-checks           [KERNEL]      Rust cargo fmt, clippy, unit tests
├─ 2. skills-governance     [GOVERNANCE]  Skills linting and formatting
├─ 3. agents-governance     [GOVERNANCE]  Agent definitions linting
├─ 4. bdd                   [GOVERNANCE]  BDD scenarios (cucumber features)
├─ 5. ac-status             [GOVERNANCE]  Validate acceptance criteria coverage
├─ 6. policy-tests          [GOVERNANCE]  OPA/Conftest policy validation
├─ 7. devex-contract        [GOVERNANCE]  Flows, commands, skills (depends: core-checks)
├─ 8. graph-invariants      [GOVERNANCE]  Flow graph connectivity (depends: devex-contract)
├─ 9. ac-coverage           [OPTIONAL]    Acceptance criteria coverage thresholds
└─ 10. extras               [OPTIONAL]    Experimental checks
```

**What to record**:
- Which steps exist and their order
- Which tier each step is in (KERNEL / GOVERNANCE / OPTIONAL)
- Which steps depend on others (see dependencies column)

---

### Step 3: Identify Failed Steps

**Purpose**: Run the full selftest to see which steps fail.

**Command**:
```bash
uv run swarm/tools/selftest.py
# or
make selftest
```

**Output format**:
```
======================================================================
SELFTEST RUNNER
======================================================================
Mode: STRICT (KERNEL and GOVERNANCE failures block)

RUN  core-checks          ... PASS (242ms)
RUN  skills-governance    ... PASS (18ms)
RUN  agents-governance    ... FAIL (8ms)        <-- FAILED
     Error: .claude/agents/foo.md does not exist
RUN  bdd                  ... SKIP              <-- SKIPPED (due to dependency)
...
```

**What to capture**:
- Which steps PASS, FAIL, or SKIP
- Error messages for each FAIL
- Timing information (helps identify if step takes too long)
- Dependency-caused SKIPs (step was skipped because a dependency failed)

**Record in your report**:
- List of failed steps: [step1, step2, ...]
- For each failed step: full error message (first 500 chars)

---

### Step 4: Run Individual Failed Steps (Verbose Mode)

**Purpose**: Get detailed error output for each failed step to understand root cause.

**Command** (for each failed step):
```bash
uv run swarm/tools/selftest.py --step <step-id> --verbose
# Examples:
uv run swarm/tools/selftest.py --step agents-governance --verbose
uv run swarm/tools/selftest.py --step devex-contract --verbose
```

**What to capture**:
- Full stderr/stdout
- Stack traces or error output
- Command that failed (to debug manually if needed)
- Timing information

**Save to file**:
```bash
uv run swarm/tools/selftest.py --step agents-governance --verbose 2>&1 | tee agents-governance-verbose.log
```

---

### Step 5: Categorize the Errors

For each failed step, identify the root cause:

#### Core-Checks Failure (KERNEL tier)
**Typical causes**:
- `cargo fmt` violations (code not formatted)
- `cargo clippy` warnings treated as errors
- Unit test failures
- Missing test assertions

**Diagnostic commands**:
```bash
# Check formatting
cargo fmt --check

# Check lints
cargo clippy --workspace --all-targets --all-features

# Run tests
cargo test --workspace --tests
```

**Fix category**: Code changes required (apply `cargo fmt`, fix clippy warnings, fix tests)

---

#### Skills-Governance Failure (GOVERNANCE tier)
**Typical causes**:
- `.claude/skills/*/SKILL.md` frontmatter not valid YAML
- Missing required fields: `name`, `description`, `category`, `tier`
- YAML parsing errors (unclosed quotes, bad indentation)

**Diagnostic commands**:
```bash
# Validate skills
uv run swarm/tools/validate_swarm.py --skills-only

# Or manually check frontmatter:
head -20 .claude/skills/*/SKILL.md
```

**Fix category**: File format/metadata (fix YAML frontmatter)

---

#### Agents-Governance Failure (GOVERNANCE tier)
**Typical causes**:
- Agent file missing or misnamed
- `.claude/agents/*.md` frontmatter doesn't match `swarm/config/agents/*.yaml`
- Mismatch between filename, `name:` field, and registry key
- Color doesn't match role family

**Diagnostic commands**:
```bash
# Regenerate adapters from config
make gen-adapters

# Check for mismatches
make check-adapters

# Full validation
uv run swarm/tools/validate_swarm.py
```

**Fix category**: Agent config/registration (regenerate adapters, fix registry)

---

#### BDD Failure (GOVERNANCE tier)
**Typical causes**:
- Gherkin syntax error in `.feature` files
- Missing step definitions
- Test assertions failing
- Feature file not in `features/` directory

**Diagnostic commands**:
```bash
# Check feature files exist
find features -name '*.feature'

# Check for Gherkin syntax errors
uv run swarm/tools/validate_swarm.py --features-only  # if available
```

**Fix category**: Test scenario files (fix `.feature` syntax, add step definitions)

---

#### AC-Status Failure (GOVERNANCE tier)
**Typical causes**:
- Acceptance criteria not defined in requirements
- AC tracking files missing
- Status mismatch between planned and actual

**Diagnostic commands**:
```bash
# Check if AC file exists
ls -la RUN_BASE/signal/acceptance_criteria.md

# Check AC tracking
find . -name "*acceptance*" -o -name "*ac*" | head -10
```

**Fix category**: Requirements/documentation (define AC in specs)

---

#### Policy-Tests Failure (GOVERNANCE tier)
**Typical causes**:
- OPA/Conftest policy violation detected
- Code or config doesn't conform to organization policies
- Policy rule triggered (e.g., security, naming, structure)

**Diagnostic commands**:
```bash
# Check for policy configuration
ls swarm/policies/ || echo "No policies defined"

# If OPA/Conftest installed:
conftest test <path>
```

**Fix category**: Code or policy update (adjust code to conform, or update policy rules)

---

#### Devex-Contract Failure (GOVERNANCE tier, depends: core-checks)
**Typical causes**:
- Flow config files out of sync with markdown specs
- Agent definitions don't match registry
- Generated files need refresh (`gen_adapters`, `gen_flows`)
- Skill definitions missing or malformed

**Diagnostic commands**:
```bash
# Full swarm validation
uv run swarm/tools/validate_swarm.py

# Regenerate flows from config
uv run swarm/tools/gen_flows.py --check

# Regenerate agent adapters from config
uv run swarm/tools/gen_adapters.py --platform claude --mode check-all
```

**Fix category**: Swarm infrastructure (regenerate adapters/flows, fix bijection)

---

#### Graph-Invariants Failure (GOVERNANCE tier, depends: devex-contract)
**Typical causes**:
- Flow graph has cycles (dependency loop)
- Agent reference in flow doesn't exist
- Flow structure violates invariants

**Diagnostic commands**:
```bash
# Validate flow graph
uv run swarm/tools/flow_graph.py --validate

# Show graph structure
uv run swarm/tools/flow_graph.py --format dot | dot -Tpng > graph.png
```

**Fix category**: Flow specification (fix agent references, remove cycles, restructure flows)

---

#### AC-Coverage Failure (OPTIONAL tier)
**Typical causes**:
- Test coverage below target threshold
- Acceptance criteria not fully covered by tests
- Missing test cases for scenarios

**Diagnostic commands**:
```bash
# Check coverage report
cargo tarpaulin --out Html || echo "Coverage tool not installed"

# Count AC vs tests
grep -r "Scenario:" features/ | wc -l
grep -r "#\[test\]" src/ | wc -l
```

**Fix category**: Test coverage (add tests, improve AC coverage)

---

#### Extras Failure (OPTIONAL tier)
**Typical causes**:
- Experimental checks enabled but not passing
- Future-proofing checks triggering
- Extension points not satisfied

**Diagnostic commands**:
```bash
# Check extras step command
uv run swarm/tools/selftest.py --step extras --verbose
```

**Fix category**: Experimental (depends on specific check)

---

### Step 6: Determine Failure Severity

After categorizing errors, classify by impact:

| Tier | Failure? | Can Merge? | Action |
|------|----------|-----------|--------|
| **KERNEL** | Yes | NO | MUST fix before merge (P0) |
| **GOVERNANCE** | Yes | MAYBE | Can use `--degraded` short-term; should fix (P1-P2) |
| **OPTIONAL** | Yes | YES | Can ignore; fix later (P3) |

**Severity Matrix**:
```
KERNEL failures       → P0 (blocking)
GOVERNANCE failures  → P1/P2 (should fix; can warn)
OPTIONAL failures    → P3 (informational)
```

---

### Step 7: Propose Fixes

For each failed step, suggest **specific remediation** with examples:

#### Example: core-checks failure (clippy warning)

**Error captured**:
```
error: this boolean can be simplified
  --> src/lib.rs:42:8
   |
42 |     if x == true { ... }
   |        ^^^^^^^^^^^
   |
= note: `#[deny(clippy::bool_comparison)]` on by default
```

**Fix**:
```diff
- if x == true {
+ if x {
```

**Confidence**: HIGH (mechanical fix)

---

#### Example: agents-governance failure (config mismatch)

**Error captured**:
```
BIJECTION: Agent 'test-fixer' registered in AGENTS.md but
config file swarm/config/agents/test-fixer.yaml is missing
```

**Fix options**:
1. Create the config file:
   ```bash
   cat > swarm/config/agents/test-fixer.yaml << 'EOF'
   key: test-fixer
   flows:
     - build
   category: implementation
   color: green
   source: project/user
   short_role: "Fix failing tests"
   model: inherit
   EOF
   ```

2. Or remove from registry if agent is obsolete:
   ```bash
   # Edit swarm/AGENTS.md and delete the row
   ```

**Then regenerate**:
```bash
make gen-adapters && make check-adapters
```

**Confidence**: HIGH (if config should exist)

---

#### Example: devex-contract failure (gen_flows needed)

**Error captured**:
```
Flow config swarm/config/flows/build.yaml has been modified
but markdown swarm/flows/flow-build.md is out of date
```

**Fix**:
```bash
uv run swarm/tools/gen_flows.py --write
make check-flows
```

**Confidence**: HIGH (regenerate from config)

---

#### Example: policy-tests failure (code doesn't conform)

**Error captured**:
```
Policy violation: Function 'dangerous_operation' not documented
Code must follow security policy: all functions handling secrets
must have @secure_documented marker
```

**Fix options**:
1. Add documentation to code:
   ```rust
   /// @secure_documented
   /// Handles sensitive credential data
   fn dangerous_operation(secret: &str) { ... }
   ```

2. Or update policy if rule is too strict:
   ```rego
   # In policies/security.rego
   # Mark exception for this function:
   exceptions["dangerous_operation"]
   ```

**Confidence**: MEDIUM (requires understanding policy intent)

---

## Common Failure Patterns & Quick Fixes

### Pattern: Formatting Issues

**Symptoms**: core-checks failure with "cargo fmt --check"

**Root cause**: Code not formatted to project standard

**Quick fix**:
```bash
cargo fmt --all
cargo fmt --check  # Verify
```

---

### Pattern: Lint Warnings

**Symptoms**: core-checks failure with clippy violations

**Root cause**: Code triggers clippy warnings

**Quick fix**:
```bash
cargo clippy --fix --workspace --allow-dirty
cargo fmt --all
cargo test  # Verify fix doesn't break tests
```

---

### Pattern: Missing Agent Files

**Symptoms**: agents-governance failure with "bijection" or "does not exist"

**Root cause**: Agent registered in AGENTS.md but no corresponding `.claude/agents/*.md` file

**Quick fix**:
```bash
# List missing agents
grep -v "^#" swarm/AGENTS.md | cut -f1 | while read key; do
  if [ ! -f ".claude/agents/$key.md" ]; then
    echo "Missing: $key"
  fi
done

# Then create files or fix registry
```

---

### Pattern: Flow Config Out of Sync

**Symptoms**: devex-contract failure about flow mismatch

**Root cause**: Flow YAML config changed but markdown not regenerated

**Quick fix**:
```bash
make gen-flows
make check-flows
```

---

### Pattern: Dependency Cascade Failures

**Symptoms**: Multiple steps fail; some say "SKIP" instead of "FAIL"

**Root cause**: Step A failed, so Step B (which depends on A) was skipped

**Solution**: Fix Step A first, then re-run. Step B will no longer skip.

**Example**: If `core-checks` fails, then `devex-contract` will SKIP.

```
1. Fix core-checks (e.g., run `cargo fmt`)
2. Re-run: make selftest
3. devex-contract will now run instead of skip
```

---

## Degraded Mode Recovery

**When to use**: A GOVERNANCE step is failing but you need to work around it temporarily.

**Important**: Degraded mode is a **short-term workaround**, not a solution. Document the issue and fix it as soon as possible.

### Step 1: Understand the Failure

Run the failing step in verbose mode:
```bash
uv run swarm/tools/selftest.py --step <step-id> --verbose
```

Document the root cause clearly.

### Step 2: Create a GitHub Issue

```markdown
Title: Selftest <step-id> failing: <brief problem>
Labels: [selftest, governance]
Body:
- **Step**: <step-id> (GOVERNANCE tier)
- **Failure**: <root cause>
- **Impact**: Can work around with --degraded mode
- **Fix**: <proposed solution>
- **Timeline**: Fix in next sprint
```

### Step 3: Run in Degraded Mode

```bash
uv run swarm/tools/selftest.py --degraded
# or
make selftest-degraded
```

**What happens**:
- KERNEL steps must still PASS (blocking)
- GOVERNANCE failures become warnings
- OPTIONAL failures are informational
- Exit code is 0 (success) as long as no KERNEL step fails

### Step 4: Document the Degradation

Add a note to your change:
```markdown
### Selftest Status: DEGRADED

**KERNEL**: PASS (all required checks passing)
**GOVERNANCE**: <step-id> failing (see issue #XYZ)
  - Impact: <what's not being checked>
  - Workaround: Running with --degraded flag
  - Target: Fix in <sprint/date>
```

### Step 5: Commit and Push

```bash
git add .
git commit -m "Work in progress: <description> (selftest <step-id> in degraded mode)"
git push origin <branch>
```

---

## When to Escalate

**Stop fixing and escalate to human when**:

1. **Kernel smoke is broken**
   - Reason: Repository is fundamentally broken; other work can't proceed
   - Action: Escalate immediately with full error logs

2. **Multiple unrelated failures**
   - Reason: Might indicate environment issue (Python version, cargo cache, missing tools)
   - Action: Escalate with environment diagnostics (Python version, Rust version, tools versions)

3. **Error message is cryptic or unclear**
   - Reason: Can't determine root cause from available information
   - Action: Escalate with full verbose output and context

4. **Selftest takes > 5 minutes**
   - Reason: Possible performance regression or infinite loop
   - Action: Escalate with timing data and step that's taking too long

5. **Unable to identify root cause after 30 min investigation**
   - Reason: Problem is outside scope or requires domain expertise
   - Action: Escalate with investigation summary and what you've already tried

6. **Fix requires changing core infrastructure or flow specs**
   - Reason: Might break other flows or violate design constraints
   - Action: Escalate to architecture/design review

**Escalation format**:
```markdown
## Escalation: Selftest Issue

**Problem**: [Brief description]
**Diagnosis**:
  - Steps taken: [list of diagnostic steps]
  - Root cause: [if known]
  - Why human intervention needed: [explain]

**Blocking**: [Yes/No - is this blocking work?]
**Evidence**:
  - Error logs: [paste relevant output]
  - Environment: [Python version, Rust version, OS]

**Recommendation**: [What should the human do next?]
```

---

## Files to Reference

These files will help you understand selftest system:

| File | Purpose |
|------|---------|
| `SELFTEST_SYSTEM.md` | Complete selftest architecture and philosophy |
| `swarm/tools/selftest_config.py` | Step registry and data model |
| `swarm/tools/selftest.py` | Main orchestrator (CLI modes, execution) |
| `swarm/tools/kernel_smoke.py` | Lightweight kernel-only smoke test |
| `Makefile` | Make targets for selftest (selftest, selftest-plan, selftest-degraded, kernel-smoke) |
| `CLAUDE.md` | Agent and flow architecture overview |
| `.claude/agents/` | All domain agents and their prompts |
| `swarm/AGENTS.md` | Agent registry |
| `swarm/config/agents/` | Agent configuration YAMLs |
| `swarm/config/flows/` | Flow configuration YAMLs |

---

## Output Format for Agent Use

When using this skill, the agent should:

1. **Execute the diagnostic procedure** step-by-step (kernel check → plan → identify failures → verbose debug → categorize → propose fixes)

2. **Capture findings** in a structured report

3. **Output a healing report** to `RUN_BASE/build/selftest_healing_report.md` with:

```markdown
# Selftest Healing Report

## Kernel Health
**Status**: PASS | FAIL | BLOCKED
**Details**: Brief summary of kernel check

## Selftest Plan
**Steps**: 10
**Tiers**: KERNEL(1), GOVERNANCE(7), OPTIONAL(2)

## Failed Steps Identified
| Step ID | Tier | Status | Error (first 200 chars) |
|---------|------|--------|------------------------|
| core-checks | KERNEL | FAIL | cargo fmt --check: found unformatted code in src/lib.rs:42 |
| agents-governance | GOVERNANCE | FAIL | bijection: agent foo-bar registered but .claude/agents/foo-bar.md missing |

## Failure Categorization
### core-checks (KERNEL, P0)
- **Root cause**: Formatting violation
- **Error**: `src/lib.rs:42` has unformatted code
- **Fix**: Run `cargo fmt --all`
- **Severity**: P0 (blocking)
- **Confidence**: HIGH

### agents-governance (GOVERNANCE, P1)
- **Root cause**: Agent file missing
- **Error**: Agent 'foo-bar' in AGENTS.md but no .claude/agents/foo-bar.md
- **Fix**: Create the file or remove from registry
- **Severity**: P1 (should fix; can warn)
- **Confidence**: HIGH

## Proposed Fixes (in order)

### Fix 1: Format code
```bash
cargo fmt --all
```
**Type**: Mechanical (safe)
**Review**: Not needed (formatting is deterministic)

### Fix 2: Create agent file
```bash
cat > .claude/agents/foo-bar.md << 'EOF'
---
name: foo-bar
description: Brief description
color: green
model: inherit
---

You are the **Foo Bar** agent.

## Inputs
...
## Outputs
...
## Behavior
1. ...
EOF
```
**Type**: Configuration
**Review**: Recommended (verify agent details are correct)

## Severity Summary
| Tier | Count | Status | Can Merge? |
|------|-------|--------|-----------|
| KERNEL | 1 | FAIL | NO (must fix) |
| GOVERNANCE | 1 | FAIL | MAYBE (can use --degraded) |
| OPTIONAL | 0 | PASS | YES |

## Recommendation
**Status**: UNVERIFIED (can be fixed)
**Path forward**: Apply fixes in order, then re-run selftest to verify
**Blocking**: YES (KERNEL tier failure must be fixed before merge)
```

4. **Report back** with:
   - Overall status (VERIFIED / UNVERIFIED / BLOCKED)
   - Which fixes were applied
   - Which require human review
   - Next steps (re-run selftest, escalate, etc.)

---

## Key Points for Agents

- **Always start with kernel-smoke**: It's fast and tells you if the repo is broken
- **Respect tier semantics**: KERNEL failures block, GOVERNANCE can warn, OPTIONAL is informational
- **Understand dependencies**: If step A fails, step B might skip (not fail)
- **Propose specific fixes**: Don't just say "something is wrong"; give exact commands to fix it
- **Know when to escalate**: If you can't fix it in 30 minutes, escalate with full context
- **Document degraded mode usage**: If using `--degraded`, create a GitHub issue tracking the fix
- **Never force**: Don't use `--force` or skip validation; work within constraints
- **Test your fixes**: Re-run selftest after proposing fixes to verify they work

