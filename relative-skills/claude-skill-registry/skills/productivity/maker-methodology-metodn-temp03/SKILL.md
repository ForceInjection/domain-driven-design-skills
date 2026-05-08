---
name: maker-methodology
description: Apply MAKER (Massively Decomposed Agentic Processes) to solve long sequential tasks using task decomposition, multi-agent voting, and error correction. Use when facing complex multi-step problems, sequential planning, constraint satisfaction, or tasks requiring many consecutive decisions.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# MAKER Methodology

Solve million-step tasks with zero errors using Massively Decomposed Agentic Processes.

Based on: ["Solving a Million-Step LLM Task with Zero Errors"](https://arxiv.org/html/2511.09030v1)

## Core Principles

### 1. Maximal Agentic Decomposition (MAD)
Break complex tasks into **minimal single-step subtasks**, not monolithic solutions.

**Instead of**: "Generate entire solution"
**Do**: "Determine next single step" repeated N times

### 2. First-to-Ahead-by-k Voting
Use multiple independent agents voting on each step:
- Continue sampling until one option leads by **k votes**
- **k grows logarithmically** with task complexity: Θ(ln s)
- Prevents error propagation through consensus

### 3. Red-Flagging
Detect and discard unreliable responses:
- Check length (too short/long)
- Validate format
- Detect failure patterns
- Domain-specific validation

## When to Use MAKER

### ✅ Good Fit
- [ ] Task has **>10 sequential steps**
- [ ] Each step has **enumerable options**
- [ ] **State is trackable** between steps
- [ ] **Progress is measurable**
- [ ] Intermediate states are **verifiable**
- [ ] Single sophisticated approach struggles

### ❌ Poor Fit
- Creative/open-ended generation
- Requires holistic understanding
- Continuous optimization
- Tasks completing in <10 steps
- Highly parallel tasks (order doesn't matter)

## Task Types MAKER Excels At

1. **Constraint Satisfaction**: Sudoku, scheduling, resource allocation
2. **Sequential Planning**: Route planning, multi-step refactoring
3. **Code Generation**: Multi-file implementation, test generation
4. **Mathematical Reasoning**: Proof construction, equation solving
5. **Data Pipelines**: ETL workflows, data cleaning sequences

## Implementation Steps

### Step 1: Define Task Interface

Every MAKER task needs these components:

```python
class YourTask:
    def get_current_state(self) -> State:
        """Return current task state."""
        pass

    def get_possible_actions(self) -> List[Action]:
        """Return valid actions from current state."""
        pass

    def apply_action(self, action: Action) -> bool:
        """Apply action and update state. Return success."""
        pass

    def is_complete(self) -> bool:
        """Check if task is finished."""
        pass

    def get_progress(self) -> float:
        """Return completion percentage (0.0 to 1.0)."""
        pass

    def format_for_agent(self) -> str:
        """Format state for LLM consumption (minimal context)."""
        pass
```

### Step 2: Compute Voting Margin

```python
def compute_k(num_steps: int) -> int:
    """Voting margin grows logarithmically."""
    if num_steps <= 10:
        return 2
    elif num_steps <= 100:
        return 3
    elif num_steps <= 1000:
        return 4
    else:
        return max(3, int(math.log(num_steps)) + 1)
```

### Step 3: Create Minimal Agent Prompts

**Key**: Each agent sees ONLY what's needed for the current step.

```
You are solving {task_name}. This is step {step_num}/{expected_steps}.

Current state:
{minimal_state_representation}

What is the next action? Respond ONLY with the action in format: {expected_format}
Do not explain. Just give the action.
```

### Step 4: Implement Voting

```python
def vote_on_next_action(state, k=3, max_agents=50):
    votes = Counter()
    agents_sampled = 0

    while agents_sampled < max_agents:
        action = get_agent_vote(state)  # LiteLLM call

        if action and not should_red_flag(action):
            votes[action] += 1

            # Check for k-vote lead
            sorted_votes = votes.most_common()
            if sorted_votes:
                leader, leader_count = sorted_votes[0]
                second_count = sorted_votes[1][1] if len(sorted_votes) > 1 else 0

                if leader_count - second_count >= k:
                    return leader  # Consensus!

        agents_sampled += 1

    return votes.most_common(1)[0][0] if votes else None
```

### Step 5: Configure Red-Flagging

```python
def should_red_flag(response: str, context: dict) -> bool:
    # Length checks
    if len(response) > 200 or len(response) < 1:
        return True

    # Failure patterns
    if any(pattern in response.lower() for pattern in
           ["i cannot", "i don't know", "error", "invalid"]):
        return True

    # Format validation (task-specific)
    if not matches_expected_format(response):
        return True

    # Domain-specific checks
    return not domain_validator(response, context)
```

### Step 6: Execute MAKER Loop

```python
state = initialize_task()
k = compute_k(estimated_steps)

while not state.is_complete():
    # Vote on next action
    action = vote_on_next_action(state, k=k)

    if action is None:
        # No consensus - may need to backtrack or increase k
        handle_voting_failure()
        continue

    # Apply action
    success = state.apply_action(action)

    if not success:
        # Invalid action - this shouldn't happen with good voting
        handle_invalid_action()
        continue

# Verify final solution
verify_solution(state)
```

## Adaptation Patterns

### Pattern A: Constraint Satisfaction

**Example**: Solving Sudoku

```python
class SudokuTask:
    def get_possible_actions(self):
        # Return valid numbers for next empty cell
        cell = self.next_empty_cell()
        return [num for num in range(1, 10)
                if self.is_valid(cell, num)]

    def format_for_agent(self):
        return f"""
Grid state: {self.grid}
Next cell to fill: {self.next_cell}
Valid options: {self.get_possible_actions()}
Constraints: Row/Column/Box must have 1-9 exactly once
"""
```

**Agent Prompt**:
```
You are solving Sudoku. This is step {step}/{81}.

Current grid:
{grid_visualization}

Which number should go in cell ({row}, {col})?
Valid options: {valid_numbers}

Respond ONLY with the number (1-9). No explanation.
```

### Pattern B: Sequential Planning

**Example**: Multi-step code refactoring

```python
class CodeRefactorTask:
    def get_possible_actions(self):
        return [
            "rename_function(old_name, new_name)",
            "extract_method(lines, new_name)",
            "move_to_module(function, target)",
            "update_imports()"
        ]

    def format_for_agent(self):
        return f"""
Current file: {self.current_file}
Function to refactor: {self.target_function}
Available refactorings: {self.get_possible_actions()}
Tests passing: {self.test_status}
"""
```

**Agent Prompt**:
```
You are refactoring {project_name}. This is step {step}.

Current situation:
- File: {filename}
- Function: {function_name}
- Issue: {code_smell}

What refactoring should be applied next?
Options:
{numbered_options}

Respond ONLY with the option number. No explanation.
```

### Pattern C: Mathematical Reasoning

**Example**: Constructing a proof

```python
class ProofTask:
    def get_possible_actions(self):
        # Return applicable inference rules
        return [rule for rule in self.inference_rules
                if rule.can_apply(self.current_statement)]

    def format_for_agent(self):
        return f"""
Current statement: {self.current}
Goal statement: {self.goal}
Available axioms: {self.axioms}
Available rules: {self.get_possible_actions()}
"""
```

### Pattern D: Data Processing Pipeline

**Example**: ETL workflow

```python
class ETLTask:
    def get_possible_actions(self):
        return [
            "remove_duplicates(column)",
            "fill_missing(column, strategy)",
            "normalize(column, method)",
            "merge_tables(table1, table2, key)"
        ]

    def format_for_agent(self):
        return f"""
Data shape: {self.df.shape}
Missing values: {self.missing_summary()}
Data quality score: {self.quality_score()}
Next transformation options: {self.get_possible_actions()}
"""
```

## Red-Flagging by Task Type

### For Code Generation
- Check syntax validity
- Ensure imports are defined
- Verify function signatures match
- Flag overly long responses (likely hallucination)

### For Mathematical Reasoning
- Verify notation consistency
- Check logical structure
- Flag undefined symbols
- Ensure rule application is valid

### For Planning Tasks
- Verify preconditions are met
- Check action is in allowed set
- Flag circular dependencies
- Ensure resources are available

### For Constraint Satisfaction
- Verify constraints not violated
- Check value in domain
- Flag contradictions
- Ensure progress toward goal

## Cost Analysis

MAKER is cost-effective when:

```
(cheap_model_cost × avg_votes × num_steps) < (expensive_model_cost × num_steps)
```

**Key Insight**: Even with 10-50 votes per step, cheap models (gpt-4o-mini) are often cheaper than one expensive model (gpt-4, o1).

Example:
- GPT-4: $0.015/step
- MAKER (gpt-4o-mini, avg 5 votes): $0.00015/step
- **100× cheaper!**

## Implementation Checklist

When applying MAKER to your task:

- [ ] Define clear state representation
- [ ] Enumerate possible actions per state
- [ ] Create minimal agent prompts (only current step context)
- [ ] Implement state validation
- [ ] Configure red-flagging for your domain
- [ ] Compute appropriate k based on task length
- [ ] Set up progress tracking
- [ ] Implement final solution verification
- [ ] Estimate cost vs single-model approach
- [ ] Test with small instances first

## Debugging MAKER Implementations

### Issue: Agents don't converge (no consensus)

**Causes**:
- k too high for task complexity
- Ambiguous state representation
- Multiple valid solutions

**Solutions**:
- Reduce k or use adaptive k
- Add more context to agent prompts
- Add tie-breaking rules

### Issue: Agents converge to wrong answer

**Causes**:
- Insufficient red-flagging
- Misleading state representation
- Correlated errors (agents make same mistake)

**Solutions**:
- Tighten red-flagging criteria
- Clarify prompt formatting
- Increase temperature for diversity
- Add validation after each step

### Issue: Too slow / too expensive

**Causes**:
- k too high
- Too many agents per vote
- Expensive model selected

**Solutions**:
- Use cheaper model (gpt-4o-mini)
- Reduce k if possible
- Parallelize agent calls
- Cache repeated states

## Examples

### Example 1: Solving Towers of Hanoi (4 disks)

```python
from maker import MAKER, MAKERConfig
from towers_of_hanoi import GameState

# Configure
config = MAKERConfig(
    model="gpt-4o-mini",
    k=3,  # For 15 steps: k=3 is sufficient
    verbose=True
)

# Solve
maker = MAKER(config)
success, moves, stats = maker.solve_towers_of_hanoi(num_disks=4)

# Expected: 15 moves, zero errors
```

### Example 2: Code Refactoring

```python
class RefactorTask:
    def __init__(self, codebase, target_pattern):
        self.codebase = codebase
        self.target = target_pattern
        self.changes = []

    def get_possible_actions(self):
        # Find all instances needing refactoring
        instances = find_pattern(self.codebase, self.target)
        return [f"refactor_{i}" for i in instances]

config = MAKERConfig(
    model="gpt-4o-mini",
    k=compute_k(len(instances)),
    task_type="code_refactoring"
)

maker = MAKER(config, task=RefactorTask(codebase, pattern))
success, changes, stats = maker.solve()
```

## Key Takeaways

1. **Decompose maximally**: Smallest possible steps
2. **Minimize context**: Each agent sees only current step
3. **Vote for consensus**: Prevents error propagation
4. **Red-flag aggressively**: Catch errors early
5. **Scale logarithmically**: k grows as Θ(ln s)
6. **Use cheap models**: They work better with voting!

## Reference Implementation

See `MAKER_GENERALIZATION.md` for:
- Universal task interface
- Adaptation patterns for different domains
- Detailed cost analysis
- Real-world examples
- Troubleshooting guide

## Further Reading

- Paper: https://arxiv.org/html/2511.09030v1
- Implementation: See `maker.py` for working code
- Examples: See `test_maker.py` for different scenarios
