---
name: wow-moment-detector
description: Detects when a Claude Code session reaches a "wow moment" worth sharing with the team. A wow moment occurs during intensive back-and-forth discussions where both user and Claude deeply engage on a topic - repeatedly refining ideas, pushing back, questioning assumptions, and ultimately producing brilliant insights about effective human-AI collaboration. Triggers when the conversation shows signs of deep "cooking" - multiple sustained exchanges on the same topic, productive disagreements, or breakthrough moments emerging from persistent dialogue. This skill should stay alert throughout the session and invoke /show-ropes when a genuinely valuable agentic mindset insight emerges.
allowed-tools: SlashCommand, Read
---

# Wow Moment Detector

You are always monitoring this session for "wow moments" - instances of exceptional human-AI collaboration that demonstrate the **agentic mindset** worth sharing with the team.

## What is a "Wow Moment"?

A wow moment is NOT just a good answer or a solved problem. It's a moment that demonstrates the **art of collaboration** with AI. Look for:

### High-Signal Indicators (Strong triggers)

1. **Intensive Back-and-Forth**
   - Multiple exchanges (4+) on the same topic without either side backing down
   - User and Claude both contributing meaningfully to refine an idea
   - The conversation "heating up" productively

2. **Productive Disagreement**
   - User pushes back on Claude's suggestion with reasoning
   - Claude defends its position OR acknowledges and improves
   - The exchange leads to a better outcome than either side's initial position

3. **Breakthrough After Struggle**
   - A topic that was discussed, set aside, and revisited
   - An "aha" moment after sustained engagement
   - A solution that neither party would have reached alone

4. **Meta-Collaboration Moments**
   - User explicitly asks Claude to think differently or challenge assumptions
   - Discussion about HOW to approach a problem, not just WHAT to do
   - Reflection on the collaboration process itself

### Medium-Signal Indicators (Consider triggering)

- User asking Claude to critique its own work
- Multiple alternative approaches being compared thoughtfully
- User teaching Claude context that improves subsequent responses
- Claude admitting uncertainty and user helping narrow down options

### Low-Signal Indicators (Usually NOT worth triggering)

- Routine task completion, even if complex
- User accepting first suggestion without discussion
- One-off clever solutions without collaborative refinement
- Technical debugging without broader insight

## When to Trigger

**DO trigger** when you observe:
- A high-signal indicator, OR
- Multiple medium-signal indicators in the same exchange

**DON'T trigger** when:
- It's just efficient task completion
- The insight is too project-specific to generalize
- You've already triggered recently in this session (avoid spam)
- The exchange is still developing (wait for the breakthrough)

## How to Trigger

When you detect a wow moment, invoke the `/show-ropes` command:

```
Use the /show-ropes command to extract and share the agentic mindset insight from this exchange.
```

You can optionally provide context to focus the extraction:

```
Use the /show-ropes command focusing on how the user's pushback about [topic] led to the breakthrough.
```

## Important Guidelines

1. **Quality over Quantity**: Better to miss a good moment than to spam the team with mediocre insights
2. **Wait for Completion**: Don't trigger mid-discussion - wait for the breakthrough or conclusion
3. **Be Selective**: The team's attention is valuable - only share genuinely useful patterns
4. **Abstract the Specific**: The insight should be about collaboration technique, not project details

## Example Triggers

**Good trigger**: After 6 exchanges where user kept asking "but why that approach?" and Claude eventually realized a simpler solution existed.

**Good trigger**: User asked Claude to argue against its own recommendation, leading to identification of a critical edge case.

**Bad trigger**: Claude wrote a complex function correctly on first try.

**Bad trigger**: User and Claude had a long conversation but it was just iterating on syntax errors.

---

Stay alert. When you see the spark of exceptional collaboration, capture it for the team.
