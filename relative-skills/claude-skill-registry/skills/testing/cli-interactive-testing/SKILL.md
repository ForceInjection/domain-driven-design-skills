---
name: cli-interactive-testing
description: Test and validate DyGram machines using CLI interactive mode. Step through execution, provide intelligent responses, debug behavior, and create test recordings.
---

# CLI Interactive Testing Skill

Execute and validate DyGram machines using **CLI interactive mode** for intelligent turn-by-turn testing.

## Purpose

This skill guides you through using the CLI interactive mode to:
- **Test machines** by executing them step-by-step
- **Debug behavior** by observing state at each turn
- **Provide intelligent responses** when LLM decisions are needed
- **Create test recordings** for automated CI/CD playback
- **Validate multiple scenarios** (success, error, edge cases)

## Quick Start

### Basic Testing Workflow

```bash
# 1. Start interactive execution
dygram execute --interactive machine.dy --id test-01

# 2. Continue execution turn-by-turn
dygram execute --interactive machine.dy --id test-01

# 3. Check status at any time
dygram exec status test-01

# 4. Provide response when needed
echo '{"response": "Continue", "tools": [...]}' | \
  dygram execute --interactive machine.dy --id test-01
```

## Core Concepts

### Turn-by-Turn Execution

Each CLI call executes **one turn** (one LLM invocation):
- State persists to disk (`.dygram/executions/<id>/`)
- Machine snapshot prevents definition changes mid-execution
- History logs all turns (`history.jsonl`)
- Auto-resumes from last state

### Response Modes

**1. Auto-continue (no stdin):**
```bash
dygram e -i machine.dy --id test
```
Used for: Task nodes without LLM, simple transitions

**2. Manual response (stdin):**
```bash
echo '{"response": "...", "tools": [...]}' | dygram e -i machine.dy --id test
```
Used for: Agent nodes, complex decisions, testing specific paths

**3. Playback mode (recordings):**
```bash
dygram e -i machine.dy --playback recordings/golden/ --id test
```
Used for: Deterministic testing, CI/CD validation

## Detailed Workflow

### Step 1: Understand the Machine

Before testing, read and understand the machine:

```bash
# Read machine definition
cat machines/payment-workflow.dy

# Generate visualization
dygram generate machines/payment-workflow.dy --format html

# Validate syntax
dygram parseAndValidate machines/payment-workflow.dy
```

### Step 2: Start Interactive Execution

Choose execution mode based on goal:

**For debugging/exploration:**
```bash
dygram e -i machines/payment-workflow.dy --id debug
```

**For creating test recordings:**
```bash
dygram e -i machines/payment-workflow.dy \
  --record recordings/payment-workflow/ \
  --id recording-001
```

**For validating with existing recordings:**
```bash
dygram e -i machines/payment-workflow.dy \
  --playback recordings/payment-workflow/ \
  --id playback-001
```

### Step 3: Execute Turn-by-Turn

Continue execution, observing and providing input as needed:

```bash
# Execute next turn
dygram e -i machines/payment-workflow.dy --id debug

# Check what happened
dygram exec status debug

# View execution history
cat .dygram/executions/debug/history.jsonl | tail -5

# Check current state
cat .dygram/executions/debug/state.json | jq '.executionState.currentNode'
```

### Step 4: Provide Intelligent Responses

When machine needs LLM decision, analyze and provide response:

```bash
# First, understand what's needed
cat .dygram/executions/debug/state.json | jq '.executionState.turnState'

# Provide thoughtful response
echo '{
  "response": "Validating payment credentials",
  "tools": [
    {"name": "validate_payment", "params": {"amount": 100}}
  ]
}' | dygram e -i machines/payment-workflow.dy --id debug
```

### Step 5: Continue Until Complete

```bash
# Option 1: Manual stepping
dygram e -i machines/payment-workflow.dy --id debug
dygram e -i machines/payment-workflow.dy --id debug
# ... until complete

# Option 2: Loop (with manual responses when needed)
while dygram e -i machines/payment-workflow.dy --id debug 2>&1 | \
  grep -q "Turn completed"; do
  echo "Turn completed, continuing..."
done
```

### Step 6: Validate Results

```bash
# Check final status
dygram exec status debug

# Review full history
cat .dygram/executions/debug/history.jsonl

# Check final state
cat .dygram/executions/debug/state.json | jq '.status'

# If recording mode, verify recordings
ls -la recordings/payment-workflow/
```

## Providing Intelligent Responses

### Response Format

```json
{
  "response": "Your reasoning and explanation",
  "tools": [
    {
      "name": "tool_name",
      "params": {
        "param1": "value1",
        "param2": "value2"
      }
    }
  ]
}
```

### Decision-Making Process

1. **Analyze Context**
   - What node are we at?
   - What tools are available?
   - What is the task prompt asking for?

2. **Understand Intent**
   - What is the machine trying to accomplish?
   - What would a real agent do here?
   - Are there multiple valid paths?

3. **Choose Semantically**
   - Don't just pattern-match keywords
   - Consider the machine's goal
   - Test different scenarios (success/error/edge)

4. **Document Reasoning**
   - Include clear explanation in response
   - This helps understand recordings later

### Example Responses

**Simple continuation:**
```bash
echo '{"action": "continue"}' | dygram e -i machine.dy --id test
```

**File operation:**
```bash
echo '{
  "response": "Reading configuration file to determine environment",
  "tools": [
    {"name": "read_file", "params": {"path": "config.json"}}
  ]
}' | dygram e -i machine.dy --id test
```

**Transition decision:**
```bash
echo '{
  "response": "Payment validation succeeded, transitioning to confirmation state",
  "tools": [
    {"name": "transition_to_confirmation", "params": {}}
  ]
}' | dygram e -i machine.dy --id test
```

**Multiple tools:**
```bash
cat <<'EOF' | dygram e -i machine.dy --id test
{
  "response": "Analyzing data and generating report",
  "tools": [
    {"name": "read_file", "params": {"path": "data.json"}},
    {"name": "analyze_data", "params": {"format": "summary"}},
    {"name": "write_file", "params": {
      "path": "report.txt",
      "content": "Analysis complete"
    }}
  ]
}
EOF
```

## Testing Patterns

### Pattern 1: Debug Single Execution

Step through to understand behavior:

```bash
# Start
dygram e -i machine.dy --id debug --verbose

# Step through with observation
for i in {1..10}; do
  echo "=== Turn $i ==="
  dygram e -i machine.dy --id debug

  # Check state
  dygram exec status debug

  # Review last history entry
  tail -1 .dygram/executions/debug/history.jsonl | jq '.'

  # Pause for review
  read -p "Continue? (y/n) " -n 1 -r
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && break
done
```

### Pattern 2: Create Golden Recording

```bash
# Start with recording
dygram e -i machine.dy \
  --record recordings/golden-test/ \
  --id golden

# Execute with intelligent responses
# (provide responses as machine requires them)

# Continue until complete
while dygram e -i machine.dy --id golden; do
  echo "Turn completed"
done

# Verify recording
ls -la recordings/golden-test/
dygram e -i machine.dy \
  --playback recordings/golden-test/ \
  --id verify

# Commit to git
git add recordings/golden-test/
git commit -m "Add golden recording for machine"
```

### Pattern 3: Test Multiple Scenarios

```bash
# Success path
dygram e -i machine.dy --record recordings/success/ --id success
# ... provide success responses ...

# Error path
dygram e -i machine.dy --record recordings/error/ --id error
# ... provide error responses ...

# Edge case
dygram e -i machine.dy --record recordings/edge/ --id edge
# ... provide edge case responses ...

# Validate all scenarios
for scenario in success error edge; do
  echo "Testing $scenario..."
  dygram e -i machine.dy \
    --playback "recordings/$scenario/" \
    --id "test-$scenario"
done
```

### Pattern 4: Batch Test Multiple Machines

```bash
#!/bin/bash
for machine in machines/*.dy; do
  name=$(basename "$machine" .dy)
  echo "Testing: $name"

  # Start with recording
  dygram e -i "$machine" \
    --record "recordings/$name/" \
    --id "$name" \
    --verbose 2>&1 | tee "logs/$name.log"

  # Continue until complete or error
  attempts=0
  max_attempts=20
  while [ $attempts -lt $max_attempts ]; do
    if dygram e -i "$machine" --id "$name"; then
      ((attempts++))
    else
      echo "Completed or errored after $attempts turns"
      break
    fi
  done

  # Check result
  if dygram exec status "$name" | grep -q "complete"; then
    echo "✓ $name: SUCCESS"
  else
    echo "✗ $name: FAILED or INCOMPLETE"
  fi

  # Clean up
  dygram exec rm "$name"
done
```

### Pattern 5: Compare Before/After

Test behavior changes:

```bash
# Record baseline
git checkout main
dygram e -i machine.dy --record recordings/baseline/ --id baseline
# ... execute ...

# Record with changes
git checkout feature-branch
dygram e -i machine.dy --record recordings/feature/ --id feature
# ... execute ...

# Compare recordings
diff -u recordings/baseline/ recordings/feature/

# Validate both still work
dygram e -i machine.dy --playback recordings/baseline/ --id test-baseline
dygram e -i machine.dy --playback recordings/feature/ --id test-feature
```

## Recording Management

### Creating Recordings

Recordings capture LLM responses for deterministic replay:

```bash
dygram e -i machine.dy --record recordings/test-case/ --id test
```

**Recording structure:**
```
recordings/test-case/
  ├── turn-1.json    # First LLM invocation
  ├── turn-2.json    # Second LLM invocation
  └── turn-3.json    # Third LLM invocation
```

**Recording content:**
```json
{
  "request": {
    "systemPrompt": "...",
    "tools": [...]
  },
  "response": {
    "content": [...],
    "stop_reason": "tool_use"
  }
}
```

### Using Recordings

```bash
# Playback deterministically
dygram e -i machine.dy --playback recordings/test-case/ --id playback

# Continue playback
while dygram e -i machine.dy --id playback; do :; done
```

### Organizing Recordings

Recommended structure:
```
recordings/
  ├── golden/                    # Golden path tests
  │   ├── basic-workflow/
  │   ├── payment-flow/
  │   └── approval-process/
  ├── edge-cases/               # Edge case scenarios
  │   ├── empty-input/
  │   ├── max-length/
  │   └── special-chars/
  ├── error-handling/           # Error scenarios
  │   ├── missing-file/
  │   ├── invalid-data/
  │   └── timeout/
  └── regression/               # Regression tests
      ├── bug-123-fix/
      ├── bug-456-fix/
      └── feature-789/
```

### Maintaining Recordings

```bash
# Update recording when behavior intentionally changes
dygram e -i machine.dy \
  --record recordings/golden/workflow/ \
  --id update \
  --force  # Force new recording

# Validate all recordings still work
for dir in recordings/golden/*/; do
  name=$(basename "$dir")
  echo "Testing: $name"
  dygram e -i "machines/$name.dy" \
    --playback "$dir" \
    --id "validate-$name"
done
```

## State Management

### Execution State Files

State is stored in `.dygram/executions/<id>/`:

```
.dygram/executions/test-01/
  ├── state.json       # Current execution state
  ├── metadata.json    # Execution metadata
  ├── machine.json     # Machine snapshot (prevents mid-execution changes)
  └── history.jsonl    # Turn-by-turn history log
```

### Inspecting State

```bash
# View current node
cat .dygram/executions/test-01/state.json | jq '.executionState.currentNode'

# View turn state (if in turn)
cat .dygram/executions/test-01/state.json | jq '.executionState.turnState'

# View visited nodes
cat .dygram/executions/test-01/state.json | jq '.executionState.visitedNodes'

# View attributes
cat .dygram/executions/test-01/state.json | jq '.executionState.attributes'

# View metadata
cat .dygram/executions/test-01/metadata.json | jq '.'
```

### Managing Executions

```bash
# List all executions
dygram exec list

# Show specific execution status
dygram exec status test-01

# Remove execution
dygram exec rm test-01

# Clean completed executions
dygram exec clean
```

## Troubleshooting

### Execution Not Progressing

**Check if waiting for input:**
```bash
dygram exec status <id>
cat .dygram/executions/<id>/state.json | jq '.executionState.turnState'
```

**Provide required response:**
```bash
echo '{"response": "...", "tools": [...]}' | dygram e -i machine.dy --id <id>
```

### Wrong Path Taken

**Restart from beginning:**
```bash
dygram exec rm <id>
dygram e -i machine.dy --id <id> --force
```

**Or start new execution:**
```bash
dygram e -i machine.dy --id <id>-retry
```

### Recording Playback Mismatch

**Check recording content:**
```bash
ls -la recordings/test-case/
cat recordings/test-case/turn-1.json | jq '.'
```

**Verify machine hasn't changed:**
```bash
# Compare machine hashes
cat .dygram/executions/<id>/metadata.json | jq '.dyash'
```

**Re-record if machine changed:**
```bash
dygram e -i machine.dy --record recordings/test-case/ --id new --force
```

### State Corruption

**View error details:**
```bash
cat .dygram/executions/<id>/state.json | jq '.status'
```

**Force fresh start:**
```bash
dygram exec rm <id>
dygram e -i machine.dy --id <id> --force
```

## Best Practices

### 1. Always Use Explicit IDs

```bash
# Good: Explicit ID for tracking
dygram e -i machine.dy --id test-payment-success

# Avoid: Auto-generated IDs are hard to track
dygram e -i machine.dy
```

### 2. Create Recordings for Important Tests

```bash
# Record golden path
dygram e -i machine.dy --record recordings/golden/ --id golden

# Commit to git
git add recordings/golden/
git commit -m "Add golden recording for regression testing"
```

### 3. Use Verbose Mode for Debugging

```bash
dygram e -i machine.dy --id debug --verbose
```

### 4. Check State Frequently

```bash
# After each significant turn
dygram e -i machine.dy --id test
dygram exec status test
```

### 5. Clean Up Test Executions

```bash
# After testing
dygram exec rm test-01
dygram exec clean
```

### 6. Document Test Scenarios

```bash
# Create a test plan
cat > TEST_PLAN.md <<'EOF'
# Payment Workflow Tests

## Scenarios
1. Success path: recordings/payment-success/
2. Invalid card: recordings/payment-invalid/
3. Timeout: recordings/payment-timeout/
4. Retry success: recordings/payment-retry/

## Run Tests
for scenario in success invalid timeout retry; do
  dygram e -i payment.dy \
    --playback recordings/payment-$scenario/ \
    --id test-$scenario
done
EOF
```

## Integration with CI/CD

### Local Development

```bash
# 1. Develop machine
vim machines/workflow.dy

# 2. Test interactively
dygram e -i machines/workflow.dy \
  --record recordings/workflow/ \
  --id workflow-test

# 3. Commit machine and recordings
git add machines/workflow.dy recordings/workflow/
git commit -m "Add workflow machine with tests"
```

### CI Configuration

```yaml
# .github/workflows/test.yml
name: Test DyGram Machines

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install DyGram
        run: npm install -g dygram

      - name: Test All Machines
        run: |
          for recording in recordings/golden/*/; do
            machine=$(basename "$recording")
            echo "Testing: $machine"

            dygram execute --interactive \
              "machines/$machine.dy" \
              --playback "$recording" \
              --id "ci-$machine"

            # Check result
            if ! dygram exec status "ci-$machine" | grep -q "complete"; then
              echo "FAILED: $machine"
              exit 1
            fi

            echo "PASSED: $machine"
          done
```

## Summary Checklist

When testing a machine, ensure you:

- [ ] Read and understand the machine definition
- [ ] Start with explicit execution ID
- [ ] Use `--record` if creating test recordings
- [ ] Step through execution observing state
- [ ] Provide intelligent responses when needed
- [ ] Check status frequently with `dygram exec status`
- [ ] Validate final state and results
- [ ] Verify recordings if created
- [ ] Clean up test executions when done
- [ ] Commit recordings for CI/CD if appropriate

## See Also

- **CLI Interactive Mode Guide:** `docs/cli/interactive-mode.md`
- **CLI Reference:** `docs/cli/README.md`
- **Agent:** `dygram-test-responder` (auto-loaded)
- **Examples:** `examples/` directory

---

**Remember:** You have intelligent reasoning - use it! Understand context, make semantic decisions, and test edge cases. Don't just pattern-match; think about what the machine is trying to accomplish.
