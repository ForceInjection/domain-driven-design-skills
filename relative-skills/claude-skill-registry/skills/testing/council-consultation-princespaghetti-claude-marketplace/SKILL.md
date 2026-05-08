---
name: council-consultation
description: Multi-perspective analysis methodology for complex decisions. Dynamically generates relevant expert viewpoints, consults each perspective systematically, and synthesizes insights into balanced recommendations. Use when users face decisions with multiple considerations, tradeoffs, or competing values.
---

# Council Consultation Skill

## Overview
This skill enables Claude to provide multi-perspective analysis for complex decisions by dynamically generating relevant expert viewpoints, consulting each perspective systematically, and synthesizing their insights into balanced recommendations.

## When to Use This Skill
Use council consultation when the user is:
- Making complex decisions with multiple considerations or tradeoffs
- Seeking diverse perspectives on a question or problem
- Evaluating options where different stakeholders would have different priorities
- Facing decisions with significant ambiguity or competing values
- Asking "what should I do about..." or "how should I approach..." questions
- Explicitly requesting multiple viewpoints or perspectives

**Do NOT use for:**
- Simple factual questions with clear answers
- Questions requiring current information (use web_search instead)
- Technical how-to questions with established solutions
- Questions where a single expert perspective is sufficient

## Methodology

### Step 1: Analyze the Question
Before generating the council, understand:
- What decision or question needs addressing
- What domain(s) are involved (career, technical, personal, financial, etc.)
- What kinds of expertise or viewpoints would be most valuable
- What tensions or tradeoffs are likely present

### Step 2: Generate Council Perspectives
Create 4-5 distinct expert perspectives that would provide valuable input. For each perspective, define:

1. **Role/Title**: A clear, descriptive role (e.g., "Risk Management Specialist", "Long-term Growth Strategist", "Work-Life Balance Advocate")
2. **Description**: One sentence describing their expertise or viewpoint
3. **Lens**: The specific angle or priority they bring to this question

**Guidelines for perspective selection:**
- Ensure diversity: Include perspectives that might conflict or prioritize different values
- Be context-specific: Tailor perspectives to the actual question, not generic roles
- Balance breadth and depth: Cover major angles without being redundant
- Consider stakeholders: Include viewpoints of people affected by the decision
- Include both optimistic and cautious perspectives

**Example for "Should I accept a startup job offer?":**
- Financial Security Analyst: Focuses on compensation, equity value, and financial risk
- Career Growth Strategist: Emphasizes learning opportunities and career trajectory
- Work-Life Balance Advocate: Prioritizes sustainable workload and personal time
- Industry Insider: Brings market knowledge and startup ecosystem perspective
- Risk-Reward Evaluator: Weighs upside potential against downside scenarios

### Step 3: Consult Each Perspective
For each council member perspective, provide a focused response (3-4 paragraphs) that:
- Stays true to their specific role and lens
- Addresses the original question directly
- Provides concrete, actionable insights where appropriate
- Acknowledges relevant tradeoffs or limitations
- Maintains the distinct voice and priorities of that perspective

**Important:** Each perspective should feel genuinely different. Avoid simply restating the same analysis from different angles. The perspectives should sometimes disagree or prioritize different factors.

### Step 4: Synthesize Perspectives
After presenting all council member responses, provide a synthesis that:

1. **Highlights alignments**: Where do the perspectives agree? What common themes emerge?
2. **Identifies key tensions**: Where do perspectives conflict? What tradeoffs are at play?
3. **Suggests a balanced path forward**: What approach honors the valid insights from multiple perspectives?
4. **Clarifies what matters most**: What considerations should weigh most heavily in this specific decision?

The synthesis should be:
- Concise (4-5 paragraphs)
- Actionable and practical
- Honest about uncertainties or limitations
- Respectful of the user's autonomy to make their own decision

## Output Format

Present the council consultation in this structure:

```
[Brief acknowledgment of the question]

**Council Perspectives:**

**[Role 1: Title]**
*[One sentence description]
*Lens: [Their specific angle]*

[3-4 paragraphs of their perspective]

**[Role 2: Title]**
*[One sentence description]
*Lens: [Their specific angle]*

[3-4 paragraphs of their perspective]

[... continue for all perspectives ...]

**Synthesized Recommendation:**

[4-5 paragraphs synthesizing the perspectives, highlighting alignments and tensions, and suggesting a balanced path forward]
```

## Best Practices

### Creating Effective Perspectives
- **Avoid stereotypes**: Don't create caricatures or overly simplistic viewpoints
- **Be specific**: "Tax Optimization Strategist" is better than "Financial Expert"
- **Ground in reality**: Base perspectives on how actual experts in these roles would think
- **Allow for nuance**: Perspectives can acknowledge complexity and uncertainty

### Writing Perspective Responses
- **Stay in character**: Each perspective should reflect their unique lens consistently
- **Provide substance**: Go beyond platitudes; give specific considerations and insights
- **Be constructive**: Even cautious perspectives should be helpful, not just negative
- **Vary depth**: Some perspectives might go deeper on fewer points; others might survey more broadly

### Synthesizing Effectively
- **Don't pick winners**: Avoid declaring one perspective "right"
- **Acknowledge tensions**: Some decisions have no perfect answer; be honest about this
- **Provide clarity**: Help the user understand which factors matter most for their situation
- **Respect autonomy**: Frame recommendations as considerations, not commands

## Advanced Techniques

### Adaptive Council Composition
For recurring decision types, consider standard council compositions:

- **Career decisions**: Financial, Growth, Balance, Risk, Industry perspectives
- **Technical architecture**: Security, Scalability, Maintainability, Cost, User Experience perspectives
- **Investment decisions**: Risk, Tax, Diversification, Growth, Liquidity perspectives
- **Interpersonal situations**: Empathy, Boundaries, Long-term Relationship, Communication, Self-Care perspectives

### Handling Follow-up Questions
If the user asks follow-up questions about specific perspectives:
- You can "consult" that specific council member again
- Provide additional depth on their viewpoint
- Allow perspectives to respond to each other if requested

### Scaling Complexity
For particularly complex decisions:
- Consider 6-7 perspectives instead of 4-5
- Allow for sub-councils on different aspects
- Structure the synthesis with clearer sections (Alignments, Tensions, Recommendations, Critical Questions)

## Common Pitfalls to Avoid

1. **Generic perspectives**: Don't create "optimist vs pessimist" councils; be domain-specific
2. **Redundant viewpoints**: Each perspective should add unique value
3. **Predetermined conclusions**: Let genuine tensions emerge; don't force agreement
4. **Over-simplification**: Complex decisions deserve nuanced perspectives
5. **Decision-making for the user**: Provide insights, not instructions
6. **Ignoring context**: Tailor perspectives to the user's specific situation and constraints

## Example Use Cases

### Good fits for council consultation:
- "Should I accept this job offer at a startup versus staying at my current company?"
- "What's the right approach for implementing zero-trust security in our platform?"
- "How should I structure my investment portfolio given my goals and constraints?"
- "Should we migrate to microservices or refactor our monolith?"
- "How do I handle this difficult conversation with a colleague?"

### Poor fits (use other approaches):
- "What's the capital of France?" (simple fact)
- "What happened in yesterday's election?" (use web_search)
- "How do I fix this Python error?" (technical troubleshooting)
- "Tell me about machine learning" (explanatory, not decisional)

## Integration with Other Skills

Council consultation works well with:
- **Web search**: Use web_search to gather current information before consulting the council
- **Document analysis**: Analyze uploaded documents first, then consult council on implications
- **Technical skills**: For implementation questions, consult council on approach, then use technical skills to execute

## Notes for Claude

When using this skill:
- **Trigger recognition**: Look for decision-oriented questions with "should I", "how do I approach", "what's the right way"
- **Don't announce the skill**: Just use the methodology naturally
- **Adapt to context**: The exact format can flex based on the question
- **Be efficient**: For simpler decisions, 3-4 perspectives might be enough
- **Follow up naturally**: If the user wants to explore one perspective deeper, you can do that

Remember: The goal is to help users think through complex decisions by exposing them to multiple valid viewpoints, not to make the decision for them.
