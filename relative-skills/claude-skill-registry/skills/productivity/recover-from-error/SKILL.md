---
name: recover-from-error
description: Diagnose task protocol errors and provide targeted recovery procedures
allowed-tools: Bash, Read, Write
---

# Recovery from Error Skill

**Purpose**: Diagnose errors during task protocol execution and provide step-by-step recovery procedures.

**Performance**: Reduces recovery time from 15+ minutes to 2-5 minutes through targeted diagnosis.

## When to Use This Skill

### Use recover-from-error When:

- Build failure occurs during VALIDATION
- Agent fails or times out during REQUIREMENTS/IMPLEMENTATION
- Session interrupted and needs to resume
- State corruption detected (lock file issues, worktree problems)
- Cannot transition to next state (prerequisites not met)

### Do NOT Use When:

- Normal protocol execution (no errors)
- User requests different approach (not an error)
- Task completed successfully

---

## Error Classification Decision Tree

**Step 1: Identify Error Category**

```
What type of error occurred?
    │
    ├─ Build/Test Failure ────────────► Section A: Build Recovery
    │
    ├─ Agent Incomplete ──────────────► Section B: Agent Recovery
    │
    ├─ Session Interrupted ───────────► Section C: Session Recovery
    │
    ├─ State Mismatch ────────────────► Section D: State Recovery
    │
    └─ Lock/Worktree Issue ───────────► Section E: Infrastructure Recovery
```

---

## Section A: Build Failure Recovery {#build-recovery}

### A1: Diagnose Build Failure Type

```bash
# Run build and capture output
./mvnw verify 2>&1 | tee /tmp/build-output.log

# Classify failure type
if grep -q "COMPILATION ERROR" /tmp/build-output.log; then
    echo "TYPE: Compilation Error → See A2"
elif grep -q "There are test failures" /tmp/build-output.log; then
    echo "TYPE: Test Failure → See A3"
elif grep -q "Checkstyle violations" /tmp/build-output.log; then
    echo "TYPE: Style Violation → See A4"
elif grep -q "PMD Failure" /tmp/build-output.log; then
    echo "TYPE: PMD Violation → See A4"
else
    echo "TYPE: Unknown → See A5"
fi
```

### A2: Compilation Error Recovery

**Quick Fixes (Main Agent Can Fix):**
- Missing imports: Add import statements
- Symbol not found (typo): Fix identifier names
- Module not exported: Update module-info.java

**Delegation Required (Re-invoke Agent):**
- Missing method implementations
- Type mismatches requiring design changes
- Interface contract violations

```bash
# Extract compilation errors
grep -A5 "COMPILATION ERROR" /tmp/build-output.log

# If simple fix (import/typo): Fix directly
# If complex (design issue): Re-invoke architect agent
```

### A3: Test Failure Recovery

```bash
# List failing tests
grep -E "Tests run:.*Failures: [1-9]" /tmp/build-output.log

# Get failure details
grep -B5 "FAILURE!" /tmp/build-output.log

# Decision:
# - Test logic wrong → Re-invoke tester agent
# - Implementation wrong → Re-invoke architect agent
# - Both → Re-invoke both agents
```

### A4: Style Violation Recovery

```bash
# Count violations
CHECKSTYLE_COUNT=$(grep -c "Checkstyle violation" /tmp/build-output.log || echo 0)
PMD_COUNT=$(grep -c "PMD violation" /tmp/build-output.log || echo 0)

echo "Checkstyle: $CHECKSTYLE_COUNT, PMD: $PMD_COUNT"

# Decision tree:
if [ $((CHECKSTYLE_COUNT + PMD_COUNT)) -le 5 ]; then
    echo "Small count - Main agent can fix directly"
else
    echo "Many violations - Re-invoke formatter agent"
fi
```

### A5: Unknown Build Failure

```bash
# Check for common issues
echo "=== Checking common causes ==="

# 1. Module resolution
grep -i "module" /tmp/build-output.log | grep -i "error"

# 2. Dependency issues
grep -i "dependency" /tmp/build-output.log | grep -i "error"

# 3. Resource issues
grep -i "resource" /tmp/build-output.log | grep -i "not found"

# If still unclear: Present full log to user
echo "Unclassified failure - manual investigation required"
cat /tmp/build-output.log | head -100
```

---

## Section B: Agent Recovery {#agent-recovery}

### B1: Diagnose Agent Status

```bash
TASK_NAME="${TASK_NAME}"  # Set task name
AGENTS=$(jq -r '.required_agents[]' "/workspace/tasks/$TASK_NAME/task.json")

echo "=== Agent Status Check ==="
for agent in $AGENTS; do
    STATUS_FILE="/workspace/tasks/$TASK_NAME/agents/$agent/status.json"
    if [ -f "$STATUS_FILE" ]; then
        STATUS=$(jq -r '.status' "$STATUS_FILE")
        DECISION=$(jq -r '.decision // "N/A"' "$STATUS_FILE")
        echo "$agent: status=$STATUS, decision=$DECISION"
    else
        echo "$agent: NO STATUS FILE (not invoked or failed early)"
    fi
done
```

### B2: Agent Missing Status File

**Cause**: Agent never started or crashed before creating status.json

**Recovery**:
```bash
# 1. Check if agent worktree exists
ls -la /workspace/tasks/$TASK_NAME/agents/$agent/code

# 2. If worktree exists but no status: Agent crashed mid-execution
#    → Re-invoke agent with same requirements

# 3. If no worktree: Agent was never invoked
#    → Create worktree and invoke agent
git worktree add /workspace/tasks/$TASK_NAME/agents/$agent/code -b $TASK_NAME-$agent
```

### B3: Agent Status = ERROR

```bash
agent="$AGENT_NAME"
ERROR_MSG=$(jq -r '.error_message // "Unknown"' "/workspace/tasks/$TASK_NAME/agents/$agent/status.json")
echo "Agent $agent ERROR: $ERROR_MSG"

# Common errors and fixes:
# - "Merge conflict" → Resolve conflicts in agent worktree, retry merge
# - "Build failed" → Fix build in agent worktree, retry
# - "Tool error" → Re-invoke with adjusted scope
# - "Timeout" → Check if work partial, resume or restart
```

### B4: Agent Status = WORKING (Stuck)

```bash
agent="$AGENT_NAME"
LAST_UPDATE=$(jq -r '.updated_at' "/workspace/tasks/$TASK_NAME/agents/$agent/status.json")
AGE_MINUTES=$(( ($(date +%s) - $(date -d "$LAST_UPDATE" +%s)) / 60 ))

if [ $AGE_MINUTES -gt 60 ]; then
    echo "Agent $agent stuck for $AGE_MINUTES minutes"

    # Check retry count
    RETRIES=$(jq -r '.retry_count // 0' "/workspace/tasks/$TASK_NAME/agents/$agent/status.json")
    if [ $RETRIES -ge 3 ]; then
        echo "Max retries exceeded - escalate to user"
    else
        echo "Re-invoking agent (retry $((RETRIES + 1))/3)"
        # Re-invoke via Task tool
    fi
fi
```

---

## Section C: Session Recovery {#session-recovery}

### C1: Detect Current Session State

```bash
SESSION_ID="${SESSION_ID}"
TASK_DIR=$(find /workspace/tasks -maxdepth 2 -name "task.json" -exec grep -l "$SESSION_ID" {} \; | head -1)

if [ -n "$TASK_DIR" ]; then
    TASK_NAME=$(dirname "$TASK_DIR" | xargs basename)
    CURRENT_STATE=$(jq -r '.state' "$TASK_DIR")
    echo "Active task: $TASK_NAME (State: $CURRENT_STATE)"
else
    echo "No active task for this session"
fi
```

### C2: Resume From State

Based on current state, resume appropriately:

| State | Resume Action |
|-------|---------------|
| INIT/CLASSIFIED | Safe to restart from beginning |
| REQUIREMENTS | Check agent reports, re-invoke incomplete agents |
| SYNTHESIS | Check if plan exists, present to user if complete |
| IMPLEMENTATION | Check agent status, resume incomplete agents |
| VALIDATION | Re-run build verification |
| AWAITING_USER_APPROVAL | Re-present changes for approval |
| COMPLETE | Proceed to CLEANUP |

```bash
case "$CURRENT_STATE" in
    "SYNTHESIS")
        # Check for approval flag
        if [ -f "/workspace/tasks/$TASK_NAME/user-approved-synthesis.flag" ]; then
            echo "Plan approved - proceed to IMPLEMENTATION"
        else
            echo "Re-present plan to user for approval"
        fi
        ;;
    "AWAITING_USER_APPROVAL")
        COMMIT=$(jq -r '.checkpoint.commit_sha' "/workspace/tasks/$TASK_NAME/task.json")
        echo "Re-present changes (commit $COMMIT) for user approval"
        ;;
    *)
        echo "Resume from $CURRENT_STATE state"
        ;;
esac
```

---

## Section D: State Recovery {#state-recovery}

### D1: State Mismatch Detection

```bash
TASK_NAME="${TASK_NAME}"
LOCK_STATE=$(jq -r '.state' "/workspace/tasks/$TASK_NAME/task.json")

# Check what work actually exists
HAS_REQUIREMENTS=$(ls /workspace/tasks/$TASK_NAME/*-requirements.md 2>/dev/null | wc -l)
HAS_APPROVAL_FLAG=$(test -f "/workspace/tasks/$TASK_NAME/user-approved-synthesis.flag" && echo 1 || echo 0)
HAS_IMPL_COMMITS=$(git -C /workspace/tasks/$TASK_NAME/code log --oneline -10 | grep -c "\[.*\]" || echo 0)

echo "Lock state: $LOCK_STATE"
echo "Requirements reports: $HAS_REQUIREMENTS"
echo "Approval flag: $HAS_APPROVAL_FLAG"
echo "Implementation commits: $HAS_IMPL_COMMITS"

# Detect mismatches
if [ "$LOCK_STATE" = "INIT" ] && [ $HAS_REQUIREMENTS -gt 0 ]; then
    echo "MISMATCH: Lock says INIT but requirements exist"
fi
```

### D2: Fix State Mismatch

```bash
# Update lock state to match actual work
CORRECT_STATE="REQUIREMENTS"  # Determine correct state from evidence

jq --arg state "$CORRECT_STATE" \
   --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '.state = $state | .transition_log += [{"type": "recovery", "to": $state, "timestamp": $ts}]' \
   /workspace/tasks/$TASK_NAME/task.json > /tmp/task.json.tmp

mv /tmp/task.json.tmp /workspace/tasks/$TASK_NAME/task.json
echo "State corrected to: $CORRECT_STATE"
```

---

## Section E: Infrastructure Recovery {#infrastructure-recovery}

### E1: Lock File Issues

```bash
TASK_NAME="${TASK_NAME}"
LOCK_FILE="/workspace/tasks/$TASK_NAME/task.json"

# Check if lock file exists and is valid
if [ ! -f "$LOCK_FILE" ]; then
    echo "Lock file missing"
    # If worktree exists: May be crashed session
    # Ask user whether to clean up or recover
elif ! jq empty "$LOCK_FILE" 2>/dev/null; then
    echo "Lock file corrupted (invalid JSON)"
    # Backup and recreate
    cp "$LOCK_FILE" "${LOCK_FILE}.backup"
    echo "Backed up to ${LOCK_FILE}.backup"
fi
```

### E2: Worktree Issues

```bash
TASK_NAME="${TASK_NAME}"

# Check task worktree
if [ ! -d "/workspace/tasks/$TASK_NAME/code" ]; then
    echo "Task worktree missing - recreating"
    git worktree add /workspace/tasks/$TASK_NAME/code -b $TASK_NAME
fi

# Check agent worktrees
for agent in architect formatter tester; do
    if [ ! -d "/workspace/tasks/$TASK_NAME/agents/$agent/code" ]; then
        echo "Agent worktree missing: $agent - recreating"
        mkdir -p /workspace/tasks/$TASK_NAME/agents/$agent
        git worktree add /workspace/tasks/$TASK_NAME/agents/$agent/code -b $TASK_NAME-$agent
    fi
done
```

---

## Quick Reference: Error → Recovery

| Error | Section | Quick Action |
|-------|---------|--------------|
| Compilation error | A2 | Fix imports/typos or re-invoke architect |
| Test failure | A3 | Re-invoke tester or architect |
| Style violations | A4 | Fix directly (<5) or re-invoke formatter (>5) |
| Agent missing status | B2 | Re-invoke agent |
| Agent ERROR | B3 | Check error, fix, re-invoke |
| Agent stuck | B4 | Re-invoke (max 3 retries) |
| Session interrupted | C | Resume from detected state |
| State mismatch | D | Correct lock file state |
| Lock corrupted | E1 | Backup and recreate |
| Worktree missing | E2 | Recreate worktree |

---

## Related Skills

- **state-transition**: Safe state transitions with validation
- **reinvoke-agent-fixes**: Re-invoke agents for specific fixes
- **validate-style-complete**: Three-component style validation
- **build-test-report**: Run build and capture results
