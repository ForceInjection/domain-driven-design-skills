---
name: behavior-tree-composer
description: Generate executable py_trees behavior trees for robots based on natural language task descriptions. Always validates before returning to user.
---

## Core Capabilities

1. Generate syntactically correct py_trees behavior trees
2. Use domain-specific actions from action library
3. Validate generated BTs before returning to user
4. Iteratively refine based on validation feedback

---

## Workflow

### Step 1: Discover Available Actions

Invoke the `bt-action-discovery` skill (user-level skill in ~/.claude/skills/) to get available robot actions, parameters, and constraints from the project's action_library.

This returns:
- Primitive actions (GoToPose, SetPen, etc.)
- Composite actions (DrawShape, PatrolWaypoints, etc.)
- Workspace constraints
- Parameter ranges

---

### Step 2: Understand Task

- Parse natural language task description
- Identify required actions from discovered action library
- Plan behavior tree structure

---

### Step 3: Generate Behavior Tree

Create a Python file in `generated_bts/` with this exact structure:

```python
"""
[Description of what this BT does]
"""

import py_trees
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from py_trees_nodes.primitives import GoToPose, SetPen, PenUp, PenDown, MoveDistance, GetPose, CheckBounds
from py_trees_nodes.composites import DrawShape, PatrolWaypoints


def create_root() -> py_trees.behaviour.Behaviour:
    """
    Create the behavior tree root node.

    Returns:
        The root node of the behavior tree
    """

    # Build your tree here
    root = py_trees.composites.Sequence(name="MainTask", memory=True)

    # Add children actions...

    return root


if __name__ == '__main__':
    """Direct execution for testing."""
    print("Creating behavior tree...")
    root = create_root()
    print("Tree structure:")
    print(py_trees.display.unicode_tree(root, show_status=True))
```

**CRITICAL Requirements:**
- Function MUST be named `create_root()` (not `create_behavior_tree()`)
- Must return `py_trees.behaviour.Behaviour` object
- Save to `generated_bts/{descriptive_name}.py`
- Only import actions that are actually used

---

### Step 4: Validate Before Returning

**CRITICAL: Always validate before presenting BT to user**

Run validation orchestrator:
```bash
python validation/orchestrator.py generated_bts/{filename}.py
```

This runs all validation tiers and returns JSON with results.

---

### Step 5: Handle Validation Results

Parse the JSON output and take action based on tier:

- **Tier 1 Critical Errors**: MUST fix - regenerate the BT
- **Tier 2 Warnings**: Should fix but not blocking
- **Tier 3 Advisory**: Informational only
- **Max 3 regeneration attempts** before giving up

**Validation Decision Tree:**
```
Tier 1 Pass?
  ├─ No  → MUST regenerate (up to 3 attempts)
  └─ Yes → Tier 2 Pass?
            ├─ No  → Should fix if possible, or warn user
            └─ Yes → Present to user
```

If still failing after 3 attempts:
- Explain limitation to user
- Show what errors remain
- Suggest simplifying the task

---

## Detailed Patterns and Examples

For detailed generation patterns, composite structures, common patterns, and working examples, see:

**`generation-patterns.md`** (in the same directory as this SKILL.md)

This external reference includes:
- py_trees composite patterns (Sequence, Selector, Parallel)
- Common BT patterns (setup-execute, conditional, multi-step)
- Validation tier details
- Common generation errors and fixes
- Working examples to reference
- Best practices

---

## Output Format

**Save generated BTs to:**
```
generated_bts/{descriptive_name}.py
```

**After validation passes:**

Present the file to user with:
- Summary of what the BT does
- How to execute it: `python execution/run_bt.py generated_bts/{filename}.py`
- Tree structure visualization

---

## Notes

- **Always validate before returning** - This is mandatory
- **Use bt-action-discovery to get available actions** - Don't hardcode or invent actions
- **Follow the template exactly** - Especially imports and `create_root()` name
- **Use memory=True for Sequences** - This is the standard
- **Degree of freedom: Medium** - Structured generation with validation loop

---

## Related Skills

- `bt-action-discovery` - Discovers available robot actions
- `bt-validator` - Standalone validation and debugging
