---
name: goap-agent
description: Invoke for complex multi-step tasks requiring intelligent planning and multi-agent coordination. Use when tasks need decomposition, dependency mapping, parallel/sequential/swarm/iterative execution strategies, or coordination of multiple specialized agents with quality gates and dynamic optimization.
---

# GOAP Agent Skill: Goal-Oriented Action Planning

Enable intelligent planning and execution of complex multi-step tasks through systematic decomposition, dependency mapping, and coordinated multi-agent execution.

Always use the plans/ folder for all files.

## Quick Reference

- **[Execution Strategies](execution-strategies.md)** - Detailed guide on parallel, sequential, swarm, hybrid, and iterative execution patterns

## When to Use This Skill

Use this skill when facing:

- **Complex Multi-Step Tasks**: Tasks requiring 5+ distinct steps or multiple specialized capabilities
- **Cross-Domain Problems**: Issues spanning multiple areas (storage, API, testing, documentation)
- **Optimization Opportunities**: Tasks that could benefit from parallel or hybrid execution
- **Quality-Critical Work**: Projects requiring validation checkpoints and quality gates
- **Resource-Intensive Operations**: Large refactors, migrations, or architectural changes
- **Ambiguous Requirements**: Tasks needing structured analysis before execution

## Core GOAP Methodology

### The GOAP Planning Cycle

```
1. ANALYZE → Understand goals, constraints, resources
2. DECOMPOSE → Break into atomic tasks with dependencies
3. STRATEGIZE → Choose execution pattern (parallel/sequential/swarm/hybrid/iterative)
4. COORDINATE → Assign tasks to specialized agents
5. EXECUTE → Run with monitoring and quality gates
6. SYNTHESIZE → Aggregate results and validate success
```

## Phase 1: Task Analysis

### Initial Assessment

```markdown
## Task Analysis

**Primary Goal**: [Clear statement of what success looks like]

**Constraints**:
- Time: [Urgent / Normal / Flexible]
- Resources: [Available agents, tools, data]
- Dependencies: [External systems, prerequisites]

**Complexity Level**:
- Simple: Single agent, <3 steps
- Medium: 2-3 agents, some dependencies
- Complex: 4+ agents, mixed execution modes
- Very Complex: Multiple phases, many dependencies

**Quality Requirements**:
- Testing: [Unit / Integration / E2E]
- Standards: [AGENTS.md compliance, formatting, linting]
- Documentation: [API docs, examples, guides]
- Performance: [Speed, memory, scalability]
```

### Context Gathering

1. **Codebase Understanding**: Use Explore agent to understand relevant code
2. **Past Patterns**: Check if similar tasks have been done before
3. **Available Resources**: Identify available agents and their capabilities
4. **Current State**: Understand starting conditions and existing implementations

## Phase 2: Task Decomposition

Use the **task-decomposition** skill to break down the goal:

```markdown
## Task Decomposition: [Task Name]

### Main Goal
[Clear statement of primary objective]

### Sub-Goals
1. [Component 1] - Priority: P0
   - Success Criteria: [How to verify]
   - Dependencies: [Prerequisites]
   - Complexity: [Low/Medium/High]

2. [Component 2] - Priority: P1
   - Success Criteria: [How to verify]
   - Dependencies: [Component 1]
   - Complexity: [Low/Medium/High]

### Atomic Tasks
**Component 1: [Name]**
- Task 1.1: [Action] (Agent: type, Deps: none)
- Task 1.2: [Action] (Agent: type, Deps: 1.1)

### Dependency Graph
```
Task 1.1 → Task 1.2 → Task 2.1
                  ↘
Task 1.3 (parallel) → Task 2.2
```
```

### Key Decomposition Principles
- **Atomic**: Each task is indivisible and clear
- **Testable**: Can verify completion
- **Independent where possible**: Minimize dependencies
- **Assigned**: Each task maps to an agent capability

## Phase 3: Strategy Selection

Choose execution strategy based on task characteristics. See **[execution-strategies.md](execution-strategies.md)** for detailed guide.

### Quick Strategy Guide

| Strategy | When to Use | Speed | Complexity |
|----------|-------------|-------|------------|
| **Parallel** | Independent tasks, time-critical | Nx | High |
| **Sequential** | Dependent tasks, order matters | 1x | Low |
| **Swarm** | Many similar tasks | ~Nx | Medium |
| **Hybrid** | Mixed requirements | 2-4x | Very High |
| **Iterative** | Progressive refinement, convergence | Varies | Medium |

### Decision Tree
```
Needs iterative refinement?
  ├─ Yes (until criteria met or converged) → ITERATIVE
  └─ No → Is time critical?
      ├─ Yes → Can tasks run in parallel?
      │   ├─ Yes → PARALLEL
      │   └─ No → SEQUENTIAL (prioritize critical path)
      └─ No → Are tasks similar?
          ├─ Yes (many similar) → SWARM
          ├─ No (mixed) → HYBRID
          └─ Simple linear → SEQUENTIAL
```

## Phase 4: Agent Assignment

### Agent Capability Matrix

| Agent Type | Capabilities | Best For |
|------------|--------------|----------|
| feature-implementer | Design, implement, test features | New functionality |
| debugger | Diagnose, fix runtime issues | Bug fixes, performance |
| test-runner | Execute tests, diagnose failures | Test validation |
| refactorer | Improve code quality, structure | Code improvements |
| code-reviewer | Review quality, compliance | Quality assurance |
| loop-agent | Iterative refinement, convergence detection | Progressive improvements |

### Assignment Principles
1. Match agent capabilities to task requirements
2. Balance workload across agents
3. Consider agent specialization
4. Plan for quality validation

## Phase 5: Execution Planning

### Create the Execution Plan

```markdown
## Execution Plan: [Task Name]

### Overview
- Strategy: [Parallel/Sequential/Swarm/Hybrid/Iterative]
- Total Tasks: [N]
- Estimated Duration: [Time]
- Quality Gates: [N checkpoints]

### Phase 1: [Phase Name]
**Tasks**:
- Task 1: [Description] (Agent: type)
- Task 2: [Description] (Agent: type)

**Quality Gate**: [Validation criteria]

### Phase 2: [Phase Name]
**Tasks**:
- Task 3: [Description] (Agent: type)

**Quality Gate**: [Validation criteria]

### Overall Success Criteria
- [ ] All tasks complete
- [ ] Quality gates passed
- [ ] Tests passing
- [ ] Documentation updated

### Contingency Plans
- If Phase 1 fails → [Recovery plan]
- If tests fail → [Diagnostic approach]
```

## Phase 6: Coordinated Execution

### Parallel Execution

```markdown
**Launching parallel agents:**
- Agent 1 (feature-implementer) → Task A
- Agent 2 (feature-implementer) → Task B
- Agent 3 (test-runner) → Task C

**Coordination**:
- All agents work simultaneously
- Monitor progress independently
- Aggregate results when all complete
```

### Sequential Execution

```markdown
**Launching sequential agents:**
Phase 1: Agent 1 (debugger) → Diagnose issue
  ↓ Quality Gate: Root cause identified
Phase 2: Agent 2 (refactorer) → Apply fix
  ↓ Quality Gate: Tests pass
Phase 3: Agent 3 (code-reviewer) → Validate
```

### Monitoring During Execution
- Track agent progress
- Monitor for failures
- Validate intermediate results
- Adjust plan if needed

## Phase 7: Result Synthesis

### Aggregate Results

```markdown
## Execution Summary: [Task Name]

### ✓ Completed Tasks
- [Task 1]: Success
- [Task 2]: Success

### 📦 Deliverables
- [File/Feature 1]
- [File/Feature 2]

### ✅ Quality Validation
- Tests: [Pass/Fail] ([coverage]%)
- Linting: [Pass/Fail]
- Standards: [Compliant]

### 📊 Performance Metrics
- Duration: [actual vs estimated]
- Efficiency: [parallel speedup if applicable]

### 💡 Recommendations
- [Improvement 1]
- [Improvement 2]

### 🎓 Lessons Learned
- [What worked well]
- [What to improve]
```

## Common GOAP Patterns

### Pattern 1: Research → Implement → Validate
```
Phase 1 (Sequential): Research
  - Explore agent → Understand codebase
  - Quality Gate: Architecture documented

Phase 2 (Parallel): Implement
  - feature-implementer (A) → Module 1
  - feature-implementer (B) → Module 2
  - Quality Gate: Implementations complete

Phase 3 (Sequential): Validate
  - test-runner → All tests
  - code-reviewer → Final review
  - Quality Gate: Ready for merge
```

### Pattern 2: Investigate → Diagnose → Fix → Verify
```
Phase 1: Investigate
  - debugger → Reproduce issue
  - Quality Gate: Issue reproduced

Phase 2: Diagnose
  - debugger → Root cause analysis
  - Quality Gate: Root cause identified

Phase 3: Fix
  - refactorer → Apply fix
  - Quality Gate: Fix implemented

Phase 4: Verify
  - test-runner → Regression tests
  - Quality Gate: Tests pass
```

### Pattern 3: Audit → Improve → Validate
```
Phase 1: Audit
  - code-reviewer → Quality audit
  - Quality Gate: Issues identified

Phase 2 (Swarm): Improve
  - Multiple refactorer agents
  - Work queue: [issue list]
  - Quality Gate: All issues addressed

Phase 3: Validate
  - test-runner → Full test suite
  - code-reviewer → Final check
  - Quality Gate: Quality targets met
```

## Error Handling & Recovery

### Agent Failure Recovery
```markdown
**If agent fails:**
1. Log failure reason
2. Check quality gate status
3. Options:
   - Retry same agent (transient error)
   - Assign to different agent (agent issue)
   - Modify task (requirements issue)
   - Escalate to user (blocking issue)
```

### Quality Gate Failure
```markdown
**If quality gate fails:**
1. Identify failing criteria
2. Diagnose root cause
3. Options:
   - Re-run previous phase with fixes
   - Adjust quality criteria (if appropriate)
   - Change strategy (e.g., parallel → sequential for debugging)
```

### Blocked Dependencies
```markdown
**If dependency blocks progress:**
1. Identify blocking task
2. Prioritize unblocking
3. Options:
   - Execute dependency first (re-order)
   - Remove dependency (refactor plan)
   - Parallel work on independent tasks
```

## Best Practices

### DO:
✓ Break tasks into atomic, testable units
✓ Define clear quality gates between phases
✓ Match agent capabilities to task requirements
✓ Monitor progress and validate incrementally
✓ Document decisions and rationale
✓ Learn from execution for future planning
✓ Use parallel execution where safe
✓ Validate dependencies before execution

### DON'T:
✗ Create monolithic tasks (break them down)
✗ Skip quality gates (leads to cascading failures)
✗ Assume tasks are independent (verify carefully)
✗ Ignore agent failures (address immediately)
✗ Over-complicate simple tasks (use sequential)
✗ Under-estimate coordination overhead
✗ Forget to aggregate and synthesize results

## Integration with Other Skills

- **task-decomposition**: Use for Phase 2 (breaking down complex goals)
- **agent-coordination**: Use for Phase 6 (coordinating multiple agents)
- **parallel-execution**: Use for parallel strategy implementation
- **loop-agent**: Use for iterative refinement strategy implementation
- All specialized agents (feature-implementer, debugger, test-runner, etc.)

## Quick Example

```markdown
Task: Implement authentication system

## GOAP Plan

### Phase 1: Analysis (Sequential)
- goap-agent → Define requirements
- Quality Gate: Requirements clear

### Phase 2: Implementation (Parallel)
- Agent A → User model + database
- Agent B → Auth middleware
- Agent C → API endpoints
- Quality Gate: All components implemented

### Phase 3: Integration (Sequential)
- feature-implementer → Wire components together
- test-runner → Integration tests
- Quality Gate: Tests pass

### Phase 4: Validation (Sequential)
- code-reviewer → Security review
- Quality Gate: Approved for deployment
```

## Success Metrics

### Planning Quality
- Clear decomposition with measurable tasks
- Realistic time estimates
- Appropriate strategy selection
- Well-defined quality gates

### Execution Quality
- Tasks completed as planned
- Quality gates passed
- Minimal re-work required
- Efficient resource utilization

### Learning
- Document what worked well
- Identify improvement areas
- Update patterns for future use
- Share knowledge with team

## Advanced Topics

### Dynamic Re-Planning
If during execution:
- Dependencies change
- Requirements clarified
- Blockers discovered
- Performance issues found

Then:
1. Pause execution
2. Re-analyze with new information
3. Adjust plan (tasks, dependencies, strategy)
4. Resume with updated plan

### Optimization Techniques
- **Critical path optimization**: Parallelize non-critical-path tasks
- **Resource pooling**: Share agents across similar tasks
- **Incremental delivery**: Complete and validate phases incrementally
- **Adaptive strategy**: Switch strategies based on progress

## Summary

GOAP enables systematic planning and execution of complex tasks through:
1. **Structured Analysis**: Understand goals, constraints, and context
2. **Intelligent Decomposition**: Break into atomic, testable tasks
3. **Strategic Execution**: Choose optimal execution pattern
4. **Quality Assurance**: Validate at checkpoints
5. **Coordinated Agents**: Leverage specialized capabilities
6. **Continuous Learning**: Improve from each execution

Use GOAP when facing complex, multi-step challenges requiring coordination, optimization, and quality assurance.