---
name: propose-feature-test-plan
description: Create a test plan mapping EARS requirements and Critical Constraints to specific tests
---

# Propose Feature Test Plan Skill

Create a test plan that systematically maps requirements and constraints to concrete tests.

## Roles

**You (reading this file) are the orchestrator.**

| Role | Reads | Does |
|------|-------|------|
| Orchestrator (you) | SKILL.md, next-step.py output | Runs state machine, spawns subagents, writes outputs |
| State machine | progress.json, workspace files | Decides next action, validates gates |
| Subagent | Phase file (e.g., VERIFY.md) | Executes phase instructions |

⚠️ **You do NOT read files in `phases/`** — pass them to subagents via context_files. Subagents read their phase file and execute it.

## Orchestrator Loop

```python
import json

workspace = f"planning/test-plan-{feature_number}-{feature_name}"
bash(f"mkdir -p {workspace}", on_error="raise")

input_data = {"feature_number": feature_number, "feature_name": feature_name}
write("create", f"{workspace}/input.json", file_text=json.dumps(input_data))

while True:
    result = bash(f"python3 skills/propose-feature-test-plan/next-step.py {workspace}", on_error="raise")
    action = json.loads(result)
    
    if action["type"] == "done":
        summary = fs_read("Line", f"{workspace}/plan-summary.md", 1, 100)
        log(summary)
        break
    
    if action["type"] == "gate_failed":
        log(f"Gate failed: {action['reason']}")
        break
    
    if action["type"] == "spawn":
        r = spawn(
            action["prompt"],
            context_files=action["context_files"],
            context_data=action.get("context_data"),
            allow_tools=True
        )
        write("create", f"{workspace}/{action['output_file']}", file_text=r.response)
```

## Handling Exceptions

The state machine handles the happy path. When things go wrong, **exercise judgment**:

| Exception | Response |
|-----------|----------|
| Spawn times out | Assess: retry with longer timeout? Report partial progress? |
| Spawn returns error | Report failure to state machine, let it track retries |
| Empty/invalid response | Treat as failure, report to state machine |

**Don't silently advance past failures.** Either retry, fail explicitly, or document gaps.

## Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Read phase files yourself | Pass phase files via context_files to subagents |
| Decide what phase is next | State machine decides via next-step.py |
| Skip gates "because it looks done" | Always validate gates |
| Store state in your memory | State lives in progress.json |
| Silently advance past failures | Retry, fail, or document gaps |

## Phases

1. **VERIFY**: Check that concept.md, requirements.md, and design.md exist
2. **EXTRACT**: Pull all REQ-* and CC-* identifiers from documents
3. **PLAN**: Create test-plan.md mapping requirements/constraints to tests

## Inputs

Before starting, gather:
- Feature number (e.g., "0042")
- Feature name (e.g., "custom-settings")

## Outputs

- Test plan document at `$FOREST_ROOT/docs/features/NNNN-feature-name/test-plan.md`
- Summary in workspace showing coverage statistics

## When to Use

- Design document with Critical Constraints exists
- Ready to plan testing approach before implementation
- Need to document what tests will verify each requirement

## Prerequisites

- Feature concept exists in `$FOREST_ROOT/docs/features/NNNN-feature-name/concept.md`
- Requirements exist in `$FOREST_ROOT/docs/features/NNNN-feature-name/requirements.md`
- Design exists in `$FOREST_ROOT/docs/features/NNNN-feature-name/design.md` (contains Critical Constraints)

## Test Plan Structure

The generated test plan includes:

- **Overview**: Brief description of testing approach
- **Test Types**: Definitions of unit/integration/not-testable/out-of-scope
- **Requirements Coverage**: Table mapping each REQ-* to test type, name, and description
- **Critical Constraints Verification**: Table mapping each CC-* to verification approach
- **Integration Test Requirements**: Guidance for CLI testing (test actual commands, not internals)
- **Test Implementation Notes**: Specific guidance for implementing tests

## Test Type Guidelines

- **Unit**: Internal logic, algorithms, data transformations (mocks allowed)
- **Integration**: File I/O, network calls, CLI commands, external processes (NO mocks)
- **Not testable**: Cannot be automated (subjective quality, human judgment, infeasible setup)
- **Out of scope**: Requires authentication with external systems (cloud APIs, registries)

## CLI Testing Principle

For CLI programs, integration tests MUST:
- Exercise the actual CLI binary/commands users run
- NOT test internal APIs directly
- Do what the user/customer will actually do

## Validation

After completion, verify:

```bash
# Check file exists
ls $FOREST_ROOT/docs/features/NNNN-feature-name/test-plan.md

# Verify all requirements are covered
grep -c "REQ-" $FOREST_ROOT/docs/features/NNNN-feature-name/test-plan.md
grep -c "REQ-" $FOREST_ROOT/docs/features/NNNN-feature-name/requirements.md

# Verify all constraints are covered
grep -c "CC-" $FOREST_ROOT/docs/features/NNNN-feature-name/test-plan.md
grep -c "CC-" $FOREST_ROOT/docs/features/NNNN-feature-name/design.md
```

## Common Issues

**Missing coverage**: Every REQ-* and CC-* must appear in the test plan. Use validation grep commands to check.

**Wrong test type**: Unit tests should not touch filesystem/network. Integration tests should not use mocks.

**Testing internals instead of behavior**: For CLI tools, test the CLI commands users run, not internal functions.

**Vague descriptions**: Test descriptions should state what specific behavior is verified.

## Next Steps

After creating the test plan:
1. Review coverage with stakeholders
2. Proceed to `propose-implementation-plan` skill to plan implementation
3. Implementation plan should reference test-plan.md for test requirements
