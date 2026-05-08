---
name: multi-agent-workflow
description: Manager session that launches worker Claude instances in parallel git worktrees for concurrent implementations. Observer subagents monitor workers and report results. Manager evaluates implementations and accepts the best one into the target branch.
---

# Multi-Agent Workflow

## Overview

This skill enables sophisticated parallel development workflows using multiple Claude instances working concurrently in separate git worktrees. The workflow consists of a manager session (current session), worker agents performing parallel implementations, and observer subagents monitoring progress and collecting results.

## Architecture

### Manager Session (Current Session)
- Orchestrates the entire workflow
- Distributes tasks to multiple worker agents
- Evaluates implementation results
- Selects and merges the best implementation

### Worker Agents (Git Worktrees)
- Execute in isolated git worktrees
- Implement the same task using different approaches
- Work independently and in parallel
- Each worker has its own branch

### Observer Subagent
- Monitors worker progress and status
- Collects implementation results
- Performs initial quality assessment
- Reports consolidated findings to manager

## When to Use This Skill

Use this skill when:
- Multiple implementation approaches should be explored simultaneously
- Complex tasks benefit from parallel A/B testing of different solutions
- You need to compare different algorithms or architectural patterns
- Time-sensitive development requires faster iteration through parallelization
- Exploring trade-offs between different technical approaches

## Workflow Steps

### 1. Task Distribution
The manager session:
- Receives implementation task from user
- Breaks down into parallelizable work units
- Sets up git worktrees for each worker
- Defines evaluation criteria

### 2. Parallel Execution
Worker agents:
- Receive specific implementation approach/variant
- Work in isolated git worktrees
- Implement, test, and commit independently
- Each uses different strategy or optimization

### 3. Monitoring & Collection
Observer subagent:
- Monitors all worker sessions
- Tracks completion status
- Collects implementation artifacts
- Runs preliminary quality checks (tests, lint, etc.)

### 4. Evaluation & Selection
Manager session:
- Reviews all implementations
- Compares based on criteria:
  - Code quality and maintainability
  - Performance metrics
  - Test coverage
  - Complexity and readability
  - Edge case handling
- Selects best implementation
- Merges into manager's target branch

## Usage Instructions

### Step 1: Initialize Multi-Agent Workflow

```
You (Manager): I need to implement [feature/fix] using multi-agent workflow.
Let's explore [N] different approaches:
1. Approach A: [description]
2. Approach B: [description]
3. Approach N: [description]

Evaluation criteria:
- [criterion 1]
- [criterion 2]
- [criterion N]
```

### Step 2: Set Up Worktrees

The manager uses the setup script to create git worktrees:

```bash
./.claude/skills/multi-agent-workflow/scripts/setup-worktrees.sh \
  --base-branch "claude/multi-agent-workflow-$(date +%s)" \
  --num-workers 3 \
  --task-id "feature-implementation"
```

This creates:
- `worktree-1/` with branch `worker-1/feature-implementation`
- `worktree-2/` with branch `worker-2/feature-implementation`
- `worktree-3/` with branch `worker-3/feature-implementation`

### Step 3: Launch Worker Agents

The manager launches worker Claude instances in each worktree using Task tool:

```
Send a single message with multiple Task tool calls:
- Task 1: Worker agent 1 - Implement using approach A
- Task 2: Worker agent 2 - Implement using approach B
- Task 3: Worker agent 3 - Implement using approach C
- Task 4: Observer agent - Monitor all workers and collect results
```

Each worker receives:
- Task description
- Specific implementation approach
- Evaluation criteria
- Worktree path to work in

### Step 4: Observer Monitoring

The observer subagent:
- Periodically checks worker progress
- Collects completed implementations
- Runs automated quality checks
- Compiles comparison report

### Step 5: Evaluation and Selection

Manager receives observer report containing:
- Implementation summaries
- Test results
- Performance metrics
- Code quality analysis

Manager evaluates and selects best implementation:
```bash
./.claude/skills/multi-agent-workflow/scripts/evaluate-results.sh \
  --worktrees "worktree-1 worktree-2 worktree-3" \
  --criteria "performance,maintainability,test-coverage" \
  --output "evaluation-report.md"
```

### Step 6: Accept Best Implementation

Manager merges selected implementation:
```bash
git checkout claude/multi-agent-workflow-[timestamp]
git merge --no-ff worker-2/feature-implementation
git worktree remove worktree-1 worktree-2 worktree-3
```

## Example Scenarios

### Scenario 1: Algorithm Optimization
**Task**: Implement data processing pipeline
**Workers**:
- Worker 1: Stream processing approach
- Worker 2: Batch processing approach
- Worker 3: Hybrid approach
**Criteria**: Performance, memory usage, code simplicity

### Scenario 2: UI Component Design
**Task**: Create user authentication form
**Workers**:
- Worker 1: Material UI components
- Worker 2: Custom styled components
- Worker 3: Headless UI with Tailwind
**Criteria**: Accessibility, bundle size, maintainability

### Scenario 3: API Implementation
**Task**: Build REST API endpoint
**Workers**:
- Worker 1: Express with middleware pattern
- Worker 2: Fastify with schema validation
- Worker 3: Next.js API routes
**Criteria**: Performance, type safety, error handling

### Scenario 4: Bug Fix Exploration
**Task**: Fix complex race condition
**Workers**:
- Worker 1: Mutex locks approach
- Worker 2: Event queue approach
- Worker 3: Refactor to eliminate shared state
**Criteria**: Correctness, simplicity, performance impact

## Best Practices

### Task Design
1. **Clear Constraints**: Define exact scope and boundaries for each worker
2. **Distinct Approaches**: Ensure each worker uses meaningfully different strategy
3. **Measurable Criteria**: Set objective, quantifiable evaluation metrics
4. **Realistic Scope**: Size tasks appropriately for parallel completion (30min-2hrs)

### Worker Management
1. **Isolation**: Ensure workers don't interfere with each other
2. **Clear Prompts**: Provide specific implementation guidance to each worker
3. **Resource Limits**: Consider computational resources when setting worker count
4. **Status Updates**: Request periodic progress updates from workers

### Observer Configuration
1. **Monitoring Frequency**: Balance between responsiveness and overhead
2. **Quality Gates**: Define automated checks (tests pass, lint clean, etc.)
3. **Reporting Format**: Structure observer reports for easy comparison
4. **Early Termination**: Allow observer to flag critical failures early

### Evaluation Process
1. **Objective Metrics**: Prioritize quantifiable measurements
2. **Code Review**: Manually review final candidates
3. **Testing**: Run comprehensive test suites on all implementations
4. **Documentation**: Require workers to document their approach
5. **Hybrid Solutions**: Consider combining best aspects of multiple implementations

## Implementation Templates

### Worker Prompt Template
Located at: `.claude/skills/multi-agent-workflow/templates/worker-prompt.md`

### Observer Prompt Template
Located at: `.claude/skills/multi-agent-workflow/templates/observer-prompt.md`

## Scripts Reference

### setup-worktrees.sh
Creates git worktrees for parallel development.

**Usage**:
```bash
./scripts/setup-worktrees.sh --base-branch <name> --num-workers <n> --task-id <id>
```

### launch-worker.sh
Launches Claude worker instance in specified worktree.

**Usage**:
```bash
./scripts/launch-worker.sh --worktree <path> --task <description> --approach <strategy>
```

### evaluate-results.sh
Evaluates and compares worker implementations.

**Usage**:
```bash
./scripts/evaluate-results.sh --worktrees <paths> --criteria <metrics> --output <file>
```

## Troubleshooting

### Worker Conflicts
If workers modify the same files unexpectedly:
- Review task scope definitions
- Ensure worktrees are properly isolated
- Check that workers are using correct branches

### Observer Failures
If observer can't collect results:
- Verify worker completion status
- Check file paths and permissions
- Review observer monitoring configuration

### Evaluation Ambiguity
If no clear best implementation emerges:
- Refine evaluation criteria
- Consider hybrid approach combining strengths
- Run additional targeted comparisons
- Consult with user on priorities

## Tips

- Start with 2-3 workers for first multi-agent workflow
- Document evaluation criteria before launching workers
- Use observer to catch issues early rather than waiting for completion
- Consider running test suites as part of automated evaluation
- Keep implementation approaches distinct enough to yield meaningful comparison
- Archive all worker implementations for future reference, not just selected one

## Integration with Other Skills

- **parallel-explore**: Use before multi-agent-workflow to identify implementation approaches
- **code-review**: Apply to all worker implementations before final selection
- **testing**: Ensure each worker includes comprehensive test coverage
