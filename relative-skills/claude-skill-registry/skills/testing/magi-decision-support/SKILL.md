---
name: magi-decision-support
description: Multi-perspective decision support using three AI agents (Scientist, Mother, Realist). Use when facing difficult decisions, trade-offs, comparing alternatives, choosing between options, or when unsure which approach is best. Triggers on questions like "should I", "which is better", "pros and cons", "normalize vs denormalize", "microservices vs monolith", or any technical/architectural decision with multiple valid options.
---

# MAGI - Consensus-Based Decision Support System

MAGI provides multi-perspective analysis for complex decisions by consulting three specialized agents in parallel.

## When to Use This Skill

Automatically invoke MAGI when the user:

- Asks "should I..." or "which is better..."
- Faces trade-offs (performance vs maintainability, consistency vs availability, etc.)
- Compares multiple approaches or architectures
- Needs to choose between options with different pros/cons
- Expresses uncertainty about a technical decision
- Asks about normalization vs denormalization, microservices vs monolith, or similar architectural choices

## The Three Perspectives

| Agent         | Role      | Focus                                                             |
| ------------- | --------- | ----------------------------------------------------------------- |
| **MELCHIOR**  | Scientist | Technical accuracy, best practices, performance, scalability      |
| **BALTHASAR** | Mother    | Developer experience, team health, sustainability, ethics         |
| **CASPER**    | Realist   | Implementation feasibility, cost, timeline, practical constraints |

## How to Invoke

Use the `/magi` command with the decision question:

```
/magi Should we normalize this database table or keep it denormalized?
/magi ↑ Is this the right architectural approach?
/magi Microservices vs monolith for our scale?
```

Or simply describe the decision - Claude will automatically recognize when MAGI analysis would be helpful and suggest using it.

## Output Format

MAGI produces a structured analysis report:

1. **Individual Agent Analysis**: Each agent provides their perspective and verdict (APPROVE/REJECT/CONDITIONAL)
2. **Consensus**: UNANIMOUS APPROVAL, MAJORITY APPROVAL, SPLIT DECISION, or MAJORITY REJECTION
3. **Key Trade-offs**: Areas where perspectives differ
4. **Final Recommendation**: Synthesized recommendation with reasoning

## Best Practices

- Provide sufficient context (code, requirements, constraints) before invoking
- Use `↑` to reference previous messages or code blocks
- Consider all three verdicts, not just the majority
- Pay special attention to dissenting opinions - they often reveal blind spots
