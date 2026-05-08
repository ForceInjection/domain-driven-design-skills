---
name: task-management
description: Task decomposition, dependency analysis, and parallel execution orchestration. Use when breaking down features into tasks, analyzing task dependencies, planning parallel execution strategies, or coordinating multi-agent workflows. Covers dependency detection, execution grouping, resource conflict prevention, and performance optimization.
---

# Task Management Skill

## Purpose

Provide systematic approaches for decomposing complex features into executable tasks, analyzing dependencies, and orchestrating parallel execution for optimal performance.

**Key Capabilities**:
- Feature decomposition strategies
- Dependency graph analysis
- Parallel execution planning
- Resource conflict detection
- Performance optimization

---

## When to Use This Skill

Auto-activates when:
- Planning feature implementation (breaking down PRPs)
- Analyzing task dependencies (what depends on what)
- Orchestrating multi-agent execution (parallel vs sequential)
- Optimizing workflow performance (speedup calculations)
- Detecting resource conflicts (file access, shared state)

---

## Quick Start

### Feature Decomposition Checklist

- [ ] **Identify deliverables**: What files/features must exist?
- [ ] **Extract tasks**: One task per cohesive unit (1 file or tightly related files)
- [ ] **Detect dependencies**: Which tasks must complete before others?
- [ ] **Group by parallelism**: Which tasks can run simultaneously?
- [ ] **Assign domains**: Which expert handles each task?
- [ ] **Validate completeness**: Do tasks cover entire feature?

### Dependency Analysis Checklist

- [ ] **File-level**: Which files create vs. consume?
- [ ] **Data-level**: Which outputs feed into inputs?
- [ ] **Tool-level**: Which commands must run sequentially?
- [ ] **Domain-level**: Which expertise areas must coordinate?

### Parallel Execution Checklist

- [ ] **Independence check**: Tasks don't modify same files
- [ ] **Grouping**: Max 2-6 tasks per parallel group
- [ ] **Context preparation**: All contexts ready BEFORE invocation
- [ ] **Single response**: All Task() calls in ONE message
- [ ] **Performance validation**: Timing confirms parallelization

---

## Core Principles (5 Key Rules)

### 1. Single Responsibility Per Task

Each task should accomplish ONE cohesive goal:

```yaml
✅ GOOD - Focused tasks
Task 1: Create user model (src/models/user.py)
Task 2: Create user API endpoints (src/api/users.py)
Task 3: Create user tests (tests/test_users.py)

❌ BAD - Monolithic task
Task 1: Implement entire user system (10 files, mixed concerns)
```

**Why**: Parallel execution, clear validation, easier debugging

### 2. Explicit Dependency Tracking

Dependencies must be explicit, not assumed:

```yaml
✅ GOOD - Clear dependencies
Task 2: Create user API
DEPENDS_ON: [Task 1]  # Needs user model
FILES_CONSUMED: src/models/user.py

❌ BAD - Implicit dependencies
Task 2: Create user API
# Silently expects user model to exist
```

**Why**: Enables dependency-aware grouping, prevents failures

### 3. Parallel Groups Must Be Independent

Tasks in same group cannot conflict:

```python
✅ GOOD - Independent tasks
Group 1 (parallel):
  - Task 1: Create src/models/user.py
  - Task 2: Create src/models/post.py
  - Task 3: Create src/models/comment.py
# Different files, no conflicts

❌ BAD - Conflicting tasks
Group 1 (parallel):
  - Task 1: Create src/api/routes.py (lines 1-50)
  - Task 2: Modify src/api/routes.py (lines 51-100)
# Same file, race condition!
```

**Why**: File conflicts, race conditions, corrupted output

### 4. Context Preparation Before Invocation

Prepare ALL contexts BEFORE making any Task() calls:

```python
✅ GOOD - Parallel execution pattern
# 1. Prepare contexts
ctx1 = f"Task 1: Create {file1}..."
ctx2 = f"Task 2: Create {file2}..."
ctx3 = f"Task 3: Create {file3}..."

# 2. Invoke all in SAME response
Task(subagent_type="expert1", prompt=ctx1)
Task(subagent_type="expert2", prompt=ctx2)
Task(subagent_type="expert3", prompt=ctx3)
# Time = max(T1, T2, T3)

❌ BAD - Sequential invocation
for task in tasks:  # Loop = sequential!
    Task(subagent_type="expert", prompt=task)
# Time = T1 + T2 + T3 (3x slower)
```

**Why**: Parallel execution (3x speedup), efficiency

### 5. Validate Performance Gains

Measure actual speedup from parallelization:

```python
✅ GOOD - Performance validation
sequential_time = sum([5, 4, 5])  # 14 minutes
parallel_time = max([5, 4, 5])    # 5 minutes
speedup = (14 - 5) / 14 * 100     # 64% faster

if speedup < 50:
    print("WARNING: Expected 50%+ speedup, got {speedup}%")
```

**Why**: Confirms parallelization working, detects sequential execution bugs

---

## Common Patterns

### Pattern 1: Linear Dependency Chain

**Use Case**: Each task builds on previous (A → B → C → D)

**Strategy**: Sequential execution groups

```yaml
Group 1: Task A (foundation)
Group 2: Task B (depends on A)
Group 3: Task C (depends on B)
Group 4: Task D (depends on C)

# No parallelization possible
# Total time = TA + TB + TC + TD
```

### Pattern 2: Independent Parallel Tasks

**Use Case**: No dependencies between tasks (A, B, C independent)

**Strategy**: Single parallel group

```yaml
Group 1 (parallel):
  - Task A (src/models/user.py)
  - Task B (src/models/post.py)
  - Task C (src/models/comment.py)

# Time = max(TA, TB, TC) ≈ 33% of sequential
```

### Pattern 3: Parallel with Shared Dependency

**Use Case**: Multiple tasks depend on same foundation (A → B, A → C, A → D)

**Strategy**: Sequential foundation, parallel dependents

```yaml
Group 1: Task A (foundation - e.g., database schema)
Group 2 (parallel):  # All depend on A completing
  - Task B (user API)
  - Task C (post API)
  - Task D (comment API)

# Time = TA + max(TB, TC, TD)
```

### Pattern 4: Multi-Level Dependency Tree

**Use Case**: Complex dependency graph

**Strategy**: Topological sort + grouping

```yaml
Group 1: [A, B]          # No dependencies, run parallel
Group 2: [C]             # Depends on A
Group 3: [D, E]          # D depends on B, E depends on C
Group 4: [F]             # Depends on D and E

# Time = max(TA,TB) + TC + max(TD,TE) + TF
```

---

## Quick Reference

### Dependency Types

| Type | Example | Detection |
|------|---------|-----------|
| File Creation | Task 2 imports Task 1's file | Read file list |
| Data Flow | Task 2 uses Task 1's output | Read task descriptions |
| Tool Order | `terraform apply` after `terraform plan` | Domain knowledge |
| Domain Order | Backend before frontend (API first) | Architecture convention |

### Parallelization Limits

| Scenario | Max Parallel Tasks | Reason |
|----------|-------------------|--------|
| Optimal | 2-6 tasks | Claude API limits |
| File conflicts | 1 task per file | Race conditions |
| Shared state | 1 task | Data corruption |
| Complex coordination | 3 tasks | Diminishing returns |

### Performance Calculation

```python
# Sequential time
sequential = sum(task_durations)

# Parallel time
parallel = max(task_durations)

# Speedup percentage
speedup = (sequential - parallel) / sequential * 100

# Efficiency (ideal = 100% per core)
efficiency = speedup / num_parallel_tasks * 100
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern 1: Over-Granular Tasks

**Problem**: 50 micro-tasks for simple feature
**Issue**: Coordination overhead > execution time
**Fix**: Combine related changes into cohesive tasks

### ❌ Anti-Pattern 2: Mega-Tasks

**Problem**: One task creates 20 files
**Issue**: No parallelization, unclear validation
**Fix**: Decompose into single-responsibility tasks

### ❌ Anti-Pattern 3: Hidden Dependencies

**Problem**: Task silently expects file from previous task
**Issue**: Race conditions, failures in parallel execution
**Fix**: Explicit DEPENDS_ON declarations

### ❌ Anti-Pattern 4: Parallelizing Dependent Tasks

**Problem**: Running Task B before Task A completes (B depends on A)
**Issue**: Task B fails, wasted execution time
**Fix**: Dependency-aware grouping (sequential groups)

### ❌ Anti-Pattern 5: Sequential Invocation in Loop

**Problem**: `for task in tasks: Task(...)`
**Issue**: 3x slower than parallel (defeats purpose)
**Fix**: All Task() calls in single response

---

## Workflow Example

### Scenario: Implement User Authentication Feature

**Step 1: Decompose Feature**

```yaml
Deliverables:
  - User model with password hashing
  - Authentication API endpoints
  - JWT token management
  - Login/logout/refresh routes
  - Integration tests

Tasks:
  Task 1: Create User model (src/models/user.py)
  Task 2: Create auth service (src/services/auth.py)
  Task 3: Create JWT utilities (src/utils/jwt.py)
  Task 4: Create auth endpoints (src/api/auth.py)
  Task 5: Create tests (tests/test_auth.py)
```

**Step 2: Analyze Dependencies**

```yaml
Task 1 (User model):
  DEPENDS_ON: []
  CREATES: src/models/user.py

Task 2 (Auth service):
  DEPENDS_ON: [Task 1]  # Imports User model
  CREATES: src/services/auth.py

Task 3 (JWT utils):
  DEPENDS_ON: []  # Independent utility
  CREATES: src/utils/jwt.py

Task 4 (Auth endpoints):
  DEPENDS_ON: [Task 2, Task 3]  # Uses auth service + JWT
  CREATES: src/api/auth.py

Task 5 (Tests):
  DEPENDS_ON: [Task 4]  # Tests complete system
  CREATES: tests/test_auth.py
```

**Step 3: Group by Parallelism**

```yaml
Group 1 (parallel):
  - Task 1 (User model)
  - Task 3 (JWT utils)
# Independent tasks, different files

Group 2 (sequential):
  - Task 2 (Auth service - depends on Group 1)

Group 3 (sequential):
  - Task 4 (Auth endpoints - depends on Group 2)

Group 4 (sequential):
  - Task 5 (Tests - depends on Group 3)

# Time = max(T1,T3) + T2 + T4 + T5
# vs Sequential: T1 + T2 + T3 + T4 + T5
# Speedup: ~20% (limited by dependency chain)
```

**Step 4: Execute with Prepared Contexts**

```python
# Group 1 - Parallel execution
ctx1 = f"Create User model at src/models/user.py..."
ctx3 = f"Create JWT utilities at src/utils/jwt.py..."

Task(subagent_type="python-backend-expert", prompt=ctx1)
Task(subagent_type="python-backend-expert", prompt=ctx3)

# Groups 2-4 run sequentially after Group 1 completes
```

---

## Navigation Guide

| Need to... | Read this |
|------------|-----------|
| Analyze complex dependencies | [dependency-analysis.md](resources/dependency-analysis.md) |
| Optimize parallel execution | [parallel-execution.md](resources/parallel-execution.md) |

---

## Resource Files

### [dependency-analysis.md](resources/dependency-analysis.md)
Comprehensive dependency detection algorithms, graph analysis, conflict resolution strategies

### [parallel-execution.md](resources/parallel-execution.md)
Advanced parallelization patterns, performance benchmarking, optimization techniques

---

**Skill Status**: COMPLETE ✅
**Line Count**: 412 ✅
**Progressive Disclosure**: 2 resource files ✅
