---
name: feature-workflow
description: Orchestrate complete or partial feature implementation workflow with configurable phases. This skill should be used to run the full workflow (specification → research → plan → implement → test → fix) or specific phases, coordinating between all feature-implementation skills automatically.
---

# Feature Workflow Orchestrator Skill

## Purpose

Orchestrate the complete feature implementation workflow or run specific phases, coordinating between `feature-specification`, `feature-research`, `implementation-planner`, `feature-implementer`, `test-executor`, and `test-fixer` skills. Manages state passing between phases and enables both autonomous and manual workflows.

**Support skill:** `workflow-challenger` can be invoked at any stage to challenge decisions, identify gaps, and verify coherence.

## IMPORTANT: User Interaction

**ALWAYS use the `AskUserQuestion` tool for workflow configuration questions.**

When starting a workflow or needing user decisions, use structured questions:

```
AskUserQuestion:
  questions:
    - question: "Do you need to clarify requirements first?"
      header: "Specification"
      options:
        - label: "Yes, start with CDC"
          description: "Requirements are unclear, need specification phase"
        - label: "No, requirements are clear"
          description: "Skip specification, go directly to research"
      multiSelect: false
    - question: "Should we create a POC during research?"
      header: "POC"
      options:
        - label: "If needed"
          description: "Create POC only if technical feasibility is uncertain"
        - label: "Always"
          description: "Always create POC for validation"
        - label: "Never"
          description: "Skip POC, documentation is sufficient"
      multiSelect: false
```

This ensures clear workflow configuration with explicit user choices.

## When to Use This Skill

Use this skill when:

- Want to run the complete feature workflow end-to-end
- Need to run specific phases (e.g., skip research, go straight to implementation)
- Want autonomous iteration through implementation-test-fix cycles
- Need to coordinate multiple skills systematically
- Want configurable workflow behavior (stop points, iteration limits)

## Workflow Phases

The feature implementation workflow consists of 6 phases:

```
Phase 0: Specification (feature-specification)
   ↓ CDC.md
Phase 1: Research (feature-research)
   ↓ findings.md
Phase 2: Planning (implementation-planner)
   ↓ Plan.md
Phase 3: Implementation (feature-implementer)
   ↓ code + test-plan.md
Phase 4: Testing (test-executor)
   ↓ test-failures.md (if failures)
Phase 5: Fixing (test-fixer)
   ↓
   └─→ If tests still fail, loop back to Phase 5
```

## Workflow Modes

### Mode 1: Full Workflow (Autonomous)

Execute all 6 phases automatically:

```
User: "Implement email notifications feature"

Orchestrator:
0. Specification → CDC.md (iterative clarification)
1. Research → findings.md
2. Plan → Plan.md
3. Implement → code + test-plan.md
4. Test → test-failures.md (if any)
5. Fix → iterate until tests pass
6. Complete!
```

**Use When:**
- Starting from scratch with unclear requirements
- Want complete hands-off implementation
- Need to clarify feature scope before research

### Mode 2: Partial Workflow

Execute specific phases:

**Example: Skip Research (already done)**
```
User: "I've done research. Here's findings.md. Implement the feature."

Orchestrator:
1. [Skip Phase 1]
2. Plan → Plan.md
3. Implement → code + test-plan.md
4. Test → test-failures.md (if any)
5. Fix → iterate until tests pass
```

**Example: Implementation-Test-Fix Only**
```
User: "Here's the implementation plan. Execute steps 1-3, then test."

Orchestrator:
1. [Skip Phases 1-2]
2. Implement steps 1-3
3. Test → test-failures.md (if any)
4. Fix → iterate until tests pass
```

**Use When:**
- Some phases already complete
- Want control over specific phases
- Iterating on existing work

### Mode 3: Single Phase

Execute one phase only:

```
User: "Just run the tests from test-plan.md"

Orchestrator:
1. [Run test-executor only]
2. Generate test-failures.md
3. Done (no auto-fix)
```

**Use When:**
- Manual workflow
- Need to inspect results between phases
- Debugging specific phase

### Mode 4: Manual Workflow (No Orchestrator)

User invokes each skill individually:

```
User: "Use feature-research to research email notifications"
→ [feature-research runs] → findings.md

User: "Now use implementation-planner to create a plan"
→ [implementation-planner runs] → Plan.md

User: "Implement Phase 1 of the plan"
→ [feature-implementer runs] → implementation

User: "Run the tests"
→ [test-executor runs] → test results
```

**Use When:**
- Want maximum control
- Learning the workflow
- Complex scenario requiring intervention

## Configuration

Workflow behavior is configurable via JSON or interactive prompts.

### Configuration Schema

```json
{
  "workflow": {
    "phases": ["specification", "research", "plan", "implement", "test", "fix"],
    "skip_phases": [],
    "stop_after": null,
    "auto_iterate": true,
    "max_iterations": 3,
    "parallel_implementation": false
  },
  "specification": {
    "output_file": "CDC.md",
    "require_approval": true,
    "max_question_iterations": 5
  },
  "research": {
    "create_poc": "if_needed",
    "output_file": "findings.md"
  },
  "planning": {
    "output_file": "Plan.md",
    "validate": true
  },
  "implementation": {
    "use_worktree": false,
    "worktree_name": null,
    "build_after_each_step": false,
    "test_after_each_step": false
  },
  "testing": {
    "test_plan_file": "test-plan.md",
    "failure_report_file": "test-failures.md",
    "stop_on_first_failure": false
  },
  "fixing": {
    "max_fix_iterations": 3,
    "auto_retest": true
  }
}
```

### Configuration Options

**Global Options:**

- **`phases`**: List of phases to run (default: all including specification)
- **`skip_phases`**: Phases to skip (e.g., `["specification"]` if requirements are clear)
- **`stop_after`**: Stop after specific phase (e.g., `"specification"` to get CDC only)
- **`auto_iterate`**: Automatically iterate fix→test loop (default: true)
- **`max_iterations`**: Max fix-test iterations before stopping (default: 3)
- **`parallel_implementation`**: Implement multiple steps in parallel worktrees (advanced)

**Specification Options:**

- **`output_file`**: CDC document filename (default: "CDC.md")
- **`require_approval`**: Require user approval before proceeding (default: true)
- **`max_question_iterations`**: Max questioning rounds (default: 5)

**Research Options:**

- **`create_poc`**: When to create POC ("always", "if_needed", "never")
- **`output_file`**: Findings document filename

**Planning Options:**

- **`output_file`**: Plan document filename
- **`validate`**: Run validate_plan.py after generation

**Implementation Options:**

- **`use_worktree`**: Create git worktree for implementation
- **`worktree_name`**: Worktree name (auto-generated if null)
- **`build_after_each_step`**: Build after each implementation step
- **`test_after_each_step`**: Run tests after each step (slower but catches issues early)

**Testing Options:**

- **`test_plan_file`**: Test plan filename
- **`failure_report_file`**: Failure report filename
- **`stop_on_first_failure`**: Stop testing on first failure (for debugging)

**Fixing Options:**

- **`max_fix_iterations`**: Max attempts to fix failing tests
- **`auto_retest`**: Automatically re-run tests after fixes

### Configuration Examples

**Example 1: Full Autonomous Workflow**
```json
{
  "workflow": {
    "phases": ["research", "plan", "implement", "test", "fix"],
    "auto_iterate": true,
    "max_iterations": 3
  }
}
```

**Example 2: Skip Research, Stop After Planning**
```json
{
  "workflow": {
    "phases": ["plan", "implement", "test", "fix"],
    "skip_phases": ["research"],
    "stop_after": "plan"
  }
}
```

**Example 3: Implementation Only (with Worktree)**
```json
{
  "workflow": {
    "phases": ["implement"],
    "skip_phases": ["research", "plan", "test", "fix"]
  },
  "implementation": {
    "use_worktree": true,
    "worktree_name": "feature/email-notifications",
    "build_after_each_step": true
  }
}
```

**Example 4: Test-Fix Loop Only**
```json
{
  "workflow": {
    "phases": ["test", "fix"],
    "auto_iterate": true,
    "max_iterations": 5
  },
  "testing": {
    "test_plan_file": "test-plan.md"
  }
}
```

## State Passing Between Phases

Each phase produces output used by the next:

```
Phase 0 (Specification):
  Output: CDC.md
  ↓
Phase 1 (Research):
  Input: CDC.md (optional, provides clear requirements)
  Output: findings.md
  ↓
Phase 2 (Planning):
  Input: findings.md
  Output: Plan.md
  ↓
Phase 3 (Implementation):
  Input: Plan.md
  Output: implemented code + test-plan.md
  ↓
Phase 4 (Testing):
  Input: test-plan.md
  Output: test-results + test-failures.md (if failures)
  ↓
Phase 5 (Fixing):
  Input: test-failures.md
  Output: fixes + re-run tests
  ↓
  If failures persist → loop back to Phase 5
  If all pass → Complete!
```

**State Files:**
- `CDC.md` - Specification document (Cahier Des Charges)
- `findings.md` - Research results
- `Plan.md` - Implementation plan
- `test-plan.md` - Test plan
- `test-failures.md` - Test failure report
- `test-fixes.md` - Fix documentation (optional)

## Orchestration Logic

### Phase 0: Specification

**Invocation:**
```
Use feature-specification skill:
  - Analyze project context
  - Iterative questioning with user
  - Be force of proposal
  - Generate CDC.md
```

**Validation:**
- Ensure CDC.md exists
- Check all sections are complete
- Check user approval obtained

**Next:** Proceed to Research (or skip to Planning if research not needed)

### Phase 1: Research

**Invocation:**
```
Use feature-research skill:
  - Read CDC.md for clear requirements
  - Interactive research with user
  - Consult MCP Deep Wiki
  - Create POC if needed
  - Generate findings.md
```

**Validation:**
- Ensure findings.md exists
- Check findings are comprehensive

**Next:** Proceed to Planning

### Phase 2: Planning

**Invocation:**
```
Use implementation-planner skill:
  - Read findings.md
  - Generate Plan.md with phases/steps
  - Identify dependencies and parallel work
  - Validate plan structure
```

**Validation:**
- Ensure Plan.md exists
- Run validate_plan.py (if configured)
- Check plan has phases and checkboxes

**Next:** Proceed to Implementation

### Phase 3: Implementation

**Invocation:**
```
Use feature-implementer skill:
  - Read Plan.md
  - For each step:
    - Implement code
    - Build and test
    - Update plan checkboxes
  - Generate test-plan.md
```

**Strategies:**

**Sequential Implementation:**
```
For each step in plan:
  1. Implement step
  2. Build
  3. Test (optional)
  4. Mark complete
  5. Next step
```

**Batch Implementation:**
```
Implement steps 1-5
Build once
Test once
Mark complete
```

**Configuration:**
- `build_after_each_step`: true/false
- `test_after_each_step`: true/false

**Validation:**
- Check code changes made
- Ensure test-plan.md generated
- Verify plan updated

**Next:** Proceed to Testing

### Phase 4: Testing

**Invocation:**
```
Use test-executor skill:
  - Read test-plan.md
  - Execute each test
  - Capture results
  - If failures: Generate test-failures.md
  - Update test-plan.md with results
```

**Validation:**
- Check tests were run
- Verify test-failures.md exists (if failures)

**Next:**
- If all tests pass → Complete!
- If tests fail → Proceed to Fixing

### Phase 5: Fixing

**Invocation:**
```
Use test-fixer skill:
  - Read test-failures.md
  - For each failure:
    - Diagnose root cause
    - Implement fix
    - Verify fix locally
  - Re-run tests via test-executor
```

**Iteration Loop:**
```
Iteration 1:
  Fix failures → Re-test
  → 5 failures remain

Iteration 2:
  Fix 5 failures → Re-test
  → 1 failure remains

Iteration 3:
  Fix 1 failure → Re-test
  → All pass! ✅
```

**Stop Conditions:**
- All tests pass → Complete!
- Max iterations reached → Stop and report
- User intervention requested → Pause

**Configuration:**
- `max_fix_iterations`: Stop after N attempts
- `auto_retest`: Automatically re-run tests after fixes

**Next:**
- If all pass → Complete!
- If failures and iterations remain → Retry Phase 5
- If max iterations → Stop and report

## Progress Tracking

Throughout workflow, track progress:

```
Feature Implementation: Email Notifications

Progress:
  [✅] Phase 1: Research (100%)
  [✅] Phase 2: Planning (100%)
  [✅] Phase 3: Implementation (100%)
  [⏳] Phase 4: Testing (in progress)
  [ ] Phase 5: Fixing

Current Status:
  Running E2E tests (5/10 complete)
```

Update after each phase completes.

## Error Handling

### Phase Failure

If a phase fails critically:

1. **Log Error:** Document what went wrong
2. **Pause Workflow:** Stop orchestration
3. **Report to User:** Provide error details
4. **Offer Options:**
   - Retry phase
   - Skip phase (if non-critical)
   - Abort workflow

**Example:**
```
❌ Phase 3 (Implementation) failed:
   Error: Build failed with 5 compilation errors

Options:
  1. View errors and fix manually
  2. Retry implementation
  3. Abort workflow
```

### Iteration Limit Reached

If max iterations reached in fixing phase:

```
⚠️ Max fix iterations (3) reached.
   2 tests still failing.

Options:
  1. Increase iteration limit and continue
  2. View remaining failures and fix manually
  3. Mark as partially complete
```

## Using the Orchestrator

### Interactive Mode (Recommended)

User provides feature request, orchestrator asks questions:

```
User: "Implement email notifications"

Orchestrator:
  Q1: "Do you need to clarify requirements first (specification phase)?"
  User: "Yes, requirements are not clear"

  Q2: "Start from research or have findings already?"
  User: "Start from research after specification"

  Q3: "Create POC if needed?"
  User: "Yes, if uncertain"

  Q4: "Use git worktree for implementation?"
  User: "No, use main worktree"

  Q5: "Auto-iterate on test failures?"
  User: "Yes, max 3 iterations"

Orchestrator: "Starting workflow with your preferences..."
[Executes phases starting from specification]
```

### Config File Mode

User provides workflow-config.json:

```bash
# Place config in .claude/workflow-config.json
# or specify path
feature-workflow --config .claude/workflow-config.json
```

Orchestrator reads config and executes accordingly.

### Command-Line Mode

Quick execution with flags:

```bash
# Full workflow
feature-workflow --full

# Skip research
feature-workflow --skip research

# Stop after planning
feature-workflow --stop-after plan

# Test and fix only
feature-workflow --phases test,fix --max-iterations 5
```

## Tips for Effective Orchestration

1. **Start Simple:** Use full workflow first to understand flow
2. **Iterate:** Run partial workflows as you learn
3. **Configure:** Adjust settings to match your needs
4. **Monitor:** Watch progress, intervene if needed
5. **Trust Process:** Let orchestrator handle coordination
6. **Manual Override:** Switch to manual mode if stuck
7. **Track State:** Verify state files are created correctly
8. **Incremental:** Run phases incrementally for complex features
9. **Parallel Work:** Use worktrees for parallel implementation (advanced)
10. **Document:** Keep workflow config for reusable patterns

## Integration with Individual Skills

Orchestrator is optional. Skills work standalone:

**Without Orchestrator (Manual):**
```
User invokes: feature-research
User invokes: implementation-planner
User invokes: feature-implementer
User invokes: test-executor
User invokes: test-fixer
```

**With Orchestrator (Automated):**
```
User invokes: feature-workflow (full)
  → Automatically orchestrates all 5 skills
```

**Hybrid (Selective Automation):**
```
User invokes: feature-research (manual)
User invokes: feature-workflow --skip research (automated from planning onwards)
```

## Critical Review with Challenger

The `workflow-challenger` skill can be invoked at any point to perform critical review:

### When to Use Challenger

- **After specification:** Verify CDC completeness before research
- **After research:** Challenge technical decisions and alternatives
- **After planning:** Verify plan coherence with requirements
- **Before implementation:** Catch missing details early
- **After test failures:** Understand root causes
- **Anytime:** When something feels incomplete or uncertain

### Challenger Integration

```
Phase 0: Specification → [Challenge CDC?] → Phase 1: Research
Phase 1: Research → [Challenge Findings?] → Phase 2: Planning
Phase 2: Planning → [Challenge Plan?] → Phase 3: Implementation
...
```

### Invocation Examples

```
User: "Challenge the CDC before we start research"
→ [workflow-challenger reviews CDC.md]
→ Produces challenge report with gaps and questions

User: "Something feels off about this plan, can you review it?"
→ [workflow-challenger analyzes Plan.md vs CDC.md vs codebase]
→ Identifies incoherences and missing elements
```

### What Challenger Analyzes

- **Documents:** CDC.md, findings.md, Plan.md, test-plan.md
- **Codebase:** Existing patterns, components, conventions
- **Project docs:** [DOC]-* folders, architecture documentation
- **Coherence:** Cross-document consistency

## Bundled Resources

- `scripts/orchestrate.py` - Main orchestration logic
- `references/workflow-config-schema.json` - Complete configuration schema
- `references/orchestration-examples.md` - Example workflows and configs
