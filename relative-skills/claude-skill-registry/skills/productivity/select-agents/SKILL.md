---
name: select-agents
description: Determine risk level and select appropriate stakeholder agents for a task
allowed-tools: Bash, Read, Glob
---

# Agent Selection Skill

**Purpose**: Classify task risk level and select the appropriate stakeholder agents during CLASSIFIED state.

**Performance**: Ensures correct agent selection, prevents over/under-staffing tasks.

## When to Use This Skill

### Use select-agents When:

- Entering CLASSIFIED state for a new task
- Uncertain which agents a task requires
- Task involves unfamiliar file types or domains
- Need to verify agent selection is appropriate

### Do NOT Use When:

- Already in IMPLEMENTATION (agents already selected)
- Task is pure research (no file modifications)
- Resuming existing task (agents already assigned)

---

## Quick Selection Guide

### By File Type

| Files Modified | Risk Level | Required Agents |
|---------------|------------|-----------------|
| `src/main/java/**` | HIGH | architect, formatter, engineer, tester, builder |
| `src/test/java/**` | MEDIUM | architect, engineer, tester |
| `pom.xml`, `build.gradle` | HIGH | architect, builder |
| `.github/**`, CI/CD | HIGH | architect, builder, security |
| `docs/**/*.md` | LOW | (none, or architect for technical docs) |
| `CLAUDE.md`, protocol docs | HIGH | architect, formatter |
| `checkstyle.xml`, style configs | HIGH | architect, formatter, builder |

### By Task Type

| Task Type | Required Agents |
|-----------|-----------------|
| New feature implementation | architect, formatter, engineer, tester, builder |
| Bug fix | architect, tester |
| Refactoring | architect, engineer |
| Performance optimization | architect, performance |
| Security enhancement | architect, security |
| Documentation only | (none) |
| Test additions | architect, tester |
| Style/formatting | architect, formatter, builder |

---

## Risk Classification Algorithm

### Step 1: Analyze Files to be Modified

```bash
# List files that will be modified
FILES_TO_MODIFY=(
    # Add file paths here
)

# Classify each file
HIGH_RISK=false
MEDIUM_RISK=false
LOW_RISK=true

for file in "${FILES_TO_MODIFY[@]}"; do
    case "$file" in
        src/main/java/*|src/*/main/java/*)
            HIGH_RISK=true
            ;;
        pom.xml|*/pom.xml|build.gradle)
            HIGH_RISK=true
            ;;
        .github/*|CLAUDE.md|**/task-protocol*.md)
            HIGH_RISK=true
            ;;
        checkstyle*.xml|pmd*.xml)
            HIGH_RISK=true
            ;;
        src/test/java/*|src/*/test/java/*)
            MEDIUM_RISK=true
            ;;
        docs/code-style/*|**/resources/*.properties)
            MEDIUM_RISK=true
            ;;
        *.md|*.txt|README*)
            # Already LOW_RISK
            ;;
    esac
done

if $HIGH_RISK; then
    RISK_LEVEL="HIGH"
elif $MEDIUM_RISK; then
    RISK_LEVEL="MEDIUM"
else
    RISK_LEVEL="LOW"
fi

echo "Risk Level: $RISK_LEVEL"
```

### Step 2: Check Escalation Triggers

```bash
TASK_DESCRIPTION="$TASK_DESCRIPTION"  # Set task description

# Keywords that force escalation to HIGH
ESCALATION_KEYWORDS="security|authentication|authorization|encryption|breaking|architecture|api|database|concurrent|performance"

if echo "$TASK_DESCRIPTION" | grep -qiE "$ESCALATION_KEYWORDS"; then
    echo "Escalation trigger detected - forcing HIGH risk"
    RISK_LEVEL="HIGH"
fi
```

### Step 3: Select Agents Based on Risk Level

```bash
case "$RISK_LEVEL" in
    "HIGH")
        AGENTS=("architect")  # Always required

        # Add based on task type
        if echo "$TASK_DESCRIPTION" | grep -qi "implement\|feature\|add\|create"; then
            AGENTS+=("formatter" "engineer" "tester" "builder")
        fi
        if echo "$TASK_DESCRIPTION" | grep -qi "security\|auth"; then
            AGENTS+=("security")
        fi
        if echo "$TASK_DESCRIPTION" | grep -qi "performance\|optim\|speed\|memory"; then
            AGENTS+=("performance")
        fi
        if echo "$TASK_DESCRIPTION" | grep -qi "user\|interface\|ux\|ui"; then
            AGENTS+=("usability")
        fi
        ;;

    "MEDIUM")
        AGENTS=("architect" "engineer")

        if echo "$TASK_DESCRIPTION" | grep -qi "test"; then
            AGENTS+=("tester")
        fi
        if echo "$TASK_DESCRIPTION" | grep -qi "style\|format"; then
            AGENTS+=("formatter")
        fi
        ;;

    "LOW")
        AGENTS=()  # No agents for low-risk tasks
        ;;
esac

echo "Selected agents: ${AGENTS[*]}"
```

---

## Agent Selection Decision Tree

```
Task requires file modifications?
    │
    ├─ NO ──► RISK: LOW, AGENTS: none
    │
    └─ YES ──► Analyze file types
                │
                ├─ src/main/java/** ──► HIGH RISK
                │   └─ AGENTS: architect + formatter + engineer + tester + builder
                │
                ├─ pom.xml, build config ──► HIGH RISK
                │   └─ AGENTS: architect + builder
                │
                ├─ CI/CD, security files ──► HIGH RISK
                │   └─ AGENTS: architect + builder + security
                │
                ├─ src/test/java/** ──► MEDIUM RISK
                │   └─ AGENTS: architect + engineer + tester
                │
                ├─ Style/config files ──► MEDIUM RISK
                │   └─ AGENTS: architect + formatter
                │
                └─ Documentation only ──► LOW RISK
                    └─ AGENTS: none (or architect for technical docs)
```

---

## Agent Responsibilities Reference

### Core Agents

| Agent | Domain | Responsibilities |
|-------|--------|------------------|
| **architect** | Architecture | Design decisions, API contracts, dependencies, implementation strategy |
| **formatter** | Style | Code formatting, style compliance, documentation standards |
| **engineer** | Quality | Refactoring, best practices, code quality patterns |
| **tester** | Testing | Test strategy, test implementation, coverage analysis |
| **builder** | Build | Build configuration, CI/CD, automated validation |

### Specialist Agents

| Agent | Domain | When to Include |
|-------|--------|-----------------|
| **security** | Security | Auth, encryption, input validation, sensitive data |
| **performance** | Performance | Algorithms, database queries, memory/CPU optimization |
| **usability** | UX | User-facing features, interface design, documentation |

---

## Common Mistakes

### Over-Selection (Too Many Agents)

❌ **Wrong**: Including performance agent for simple CRUD operations
❌ **Wrong**: Including security agent for internal utility class
❌ **Wrong**: Including usability agent for backend-only changes

### Under-Selection (Missing Agents)

❌ **Wrong**: New feature without tester agent
❌ **Wrong**: API changes without architect agent
❌ **Wrong**: Style configuration changes without formatter agent

### Correct Selection Examples

**Task**: "Implement user authentication"
- ✅ architect (API design)
- ✅ security (auth handling)
- ✅ tester (auth test cases)
- ✅ formatter (code style)
- ✅ builder (build verification)

**Task**: "Fix typo in README"
- ✅ No agents needed (LOW risk)

**Task**: "Add unit tests for Calculator class"
- ✅ architect (test strategy)
- ✅ tester (test implementation)
- ❌ No formatter (not changing production code)

---

## Output Format

After selection, update task.json with selected agents:

```bash
TASK_NAME="$TASK_NAME"
AGENTS='["architect", "formatter", "engineer", "tester", "builder"]'
RISK_LEVEL="HIGH"

jq --argjson agents "$AGENTS" \
   --arg risk "$RISK_LEVEL" \
   '.required_agents = $agents | .risk_level = $risk' \
   /workspace/tasks/$TASK_NAME/task.json > /tmp/task.json.tmp

mv /tmp/task.json.tmp /workspace/tasks/$TASK_NAME/task.json
```

---

## Related Skills

- **state-transition**: Transition to CLASSIFIED state
- **gather-requirements**: Invoke agents for requirements gathering
- **task-init**: Initialize task with agent selection
