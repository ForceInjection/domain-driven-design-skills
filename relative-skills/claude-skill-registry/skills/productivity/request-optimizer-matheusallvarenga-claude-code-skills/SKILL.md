---
name: request-optimizer
description: This skill analyzes incoming requests to optimize context usage, decompose tasks efficiently, and recommend the best execution strategy. It runs automatically to evaluate request specificity, identify necessary explorations, suggest subtask decomposition, recommend appropriate models, and coordinate MCP/Agent/Skill activations with user approval before execution.
---

# Request Optimizer Skill (POC)

## Purpose

To intercept and intelligently analyze every user request, providing strategic recommendations before execution. This skill acts as an intelligent intermediary that evaluates context efficiency, task complexity, and execution strategy.

## When to Use

This skill should be used automatically on every request to:
- Analyze request specificity and clarity
- Determine if exploration is needed
- Identify opportunities for task decomposition
- Recommend optimal model (Haiku/Sonnet/Opus)
- Suggest coordination of MCPs, Agents, or other Skills
- Present a complete strategy for user approval before execution

## How This Skill Works

### Analysis Phase

When a request is received, immediately perform these analyses using `references/analysis-framework.md`:

1. **Specificity Analysis** - How specific/vague is the request?
2. **Exploration Detection** - Does this need codebase/system exploration?
3. **Subtask Identification** - Should this be decomposed into multiple tasks?
4. **Tool Coordination** - What MCPs, Agents, or Skills might be needed?
5. **Model Recommendation** - Which model is optimal? (Haiku for simple, Sonnet for normal, Opus for complex)

### Recommendation Phase

Based on analyses, compile findings into a structured recommendation:

```
## Analysis Results
- **Specificity**: [Assessment]
- **Exploration Needed**: [Yes/No + Why]
- **Suggested Subtasks**: [If applicable]
- **Recommended Tools**: [MCPs/Agents/Skills to coordinate]
- **Optimal Model**: [Haiku/Sonnet/Opus + reasoning]

## Recommended Strategy
[Clear, actionable workflow]

## Next Steps
Ready to execute? (Yes/No/Adjust)
```

### Execution Phase (After Approval)

If user approves:
- Execute the recommended strategy
- When recommending MCP/Agent invocation, first present what will be done
- Ask approval again before invoking heavy tools
- Report results back to user
- Ask if additional steps needed or if optimization complete

## Decision Framework

Reference `references/decision-tree.md` to determine:
- **When to invoke vs. recommend**: Only recommend MCPs/Agents without heavy computation
- **How to weight factors**: Specificity + Complexity + Context Size
- **When to defer to user decision**: Complex tradeoffs

## Important Constraints

- Always get approval before executing heavy operations
- Start with analysis/recommendations, not execution
- Be concise in analysis reporting
- Preserve context by using `/clear` recommendations when appropriate
- Default to recommending Haiku for simple tasks to preserve token budget
