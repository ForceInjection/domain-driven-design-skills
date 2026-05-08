---
name: Conversation Analysis
version: 2.0.0
description: Analyze conversation history to identify patterns, signals, and behaviors. Use when analyzing conversations, finding patterns in chat, identifying what went well/wrong, scanning for frustration, success, workflow transitions, or user preferences. Triggers on analyze, pattern(s), signal(s), conversation analysis, or `--analyze-conversation`.
---

# Conversation Analysis

Signal extraction → pattern detection → behavioral insights.

<when_to_use>

- User requests conversation analysis
- Identifying frustration, success, or workflow patterns
- Extracting user preferences and requirements
- Understanding task evolution and iterations

NOT for: real-time monitoring, content generation, single message analysis

</when_to_use>

<signal_taxonomy>

| Type | Subtype | Indicators |
|------|---------|------------|
| Success | Explicit Praise | "Perfect!", "Exactly what I needed", exclamation marks |
| Success | Continuation | "Now do the same for...", building on prior work |
| Success | Adoption | User implements suggestion without modification |
| Success | Acceptance | "Looks good", "Ship it", "Merge this" |
| Frustration | Correction | "No, I meant...", "That's wrong", "Do X instead" |
| Frustration | Reversion | User undoes agent changes, "Go back" |
| Frustration | Repetition | Same request 2+ times, escalating specificity |
| Frustration | Explicit | "This isn't working", "Why did you...", accusatory tone |
| Workflow | Sequence | "First...", "Then...", "Finally...", numbered lists |
| Workflow | Transition | "Now that X is done, let's Y", phase changes |
| Workflow | Tool Chain | Recurring tool usage patterns (Read → Edit → Bash) |
| Workflow | Context Switch | Abrupt topic changes, no transition language |
| Request | Prohibition | "Don't use X", "Never do Y", "Avoid Z" |
| Request | Requirement | "Always check...", "Make sure to...", "You must..." |
| Request | Preference | "I prefer...", "It's better to...", comparative language |
| Request | Conditional | "If X then Y", "When A, do B", situational rules |

Confidence levels:
- High (0.8–1.0): Explicit keywords match taxonomy, no ambiguity, strong context
- Medium (0.5–0.79): Implicit signal, partial context, minor ambiguity
- Low (0.2–0.49): Ambiguous language, weak context, borderline classification

</signal_taxonomy>

<phases>

Track with TodoWrite. Phases advance only, never regress.

| Phase | Trigger | activeForm |
|-------|---------|------------|
| Parse Input | Session start | "Parsing input" |
| Extract Signals | Scope validated | "Extracting signals" |
| Detect Patterns | Signals extracted | "Detecting patterns" |
| Synthesize Report | Patterns detected | "Synthesizing report" |

TodoWrite format:

```text
- Parse Input { scope description }
- Extract Signals { from N messages }
- Detect Patterns { category focus }
- Synthesize Report { output format }
```

Edge cases:
- Small scope (<5 messages): Skip Extract Signals, jump to Synthesize
- Re-analysis: Resume at Detect Patterns
- Narrow focus (single signal type): Skip Detect Patterns

Workflow:
- Start: Create Parse Input `in_progress`
- Transition: Mark current `completed`, add next `in_progress`
- After delivery: Mark Synthesize Report `completed`

</phases>

<workflow>

1. Define Scope
   - Message range (all, recent N, date range)
   - Actors (user only, agent only, both)
   - Exclusions (system messages, tool outputs, code blocks)
   - Mark Parse Input `completed`, create Extract Signals `in_progress`

2. Extract Signals
   - Scan messages for signal keywords
   - Match against taxonomy
   - Assign confidence (high/medium/low)
   - Record: type, subtype, message_id, timestamp, quote, context
   - Mark Extract Signals `completed`, create Detect Patterns `in_progress`

3. Detect Patterns
   - Group signals by type/subtype
   - Find clusters (3+ related signals)
   - Identify evolution (signal changes over time)
   - Track repetition (recurring themes)
   - Spot correlations (tool chains, workflows)
   - Mark Detect Patterns `completed`, create Synthesize Report `in_progress`

4. Output
   - Generate JSON with signals, patterns, summary
   - Include confidence, recommendations, action items
   - Append `△ Caveats` if gaps exist
   - Mark Synthesize Report `completed`

</workflow>

<pattern_detection>

Behavioral patterns from signal clusters:

| Pattern | Detection | Confidence |
|---------|-----------|------------|
| Repetition | Same signal 3+ times | Strong: 5+ signals |
| Evolution | Signal type changes over time | Moderate: 3-4 signals |
| Preferences | Consistent request signals | Strong: across sessions |
| Tool Chains | Recurring tool sequences (5+ times) | High: frequent use |
| Problem Areas | Clustered frustration signals | Strong: 3+ in same topic |

Temporal patterns:
- Escalation: Increasing frustration/stronger requirements
- De-escalation: Frustration → success transition
- Cyclical: Same issue recurs across sessions

</pattern_detection>

<output_format>

JSON structure:

```json
{
  "analysis": {
    "scope": {
      "message_count": N,
      "date_range": "YYYY-MM-DD to YYYY-MM-DD",
      "actors": ["user", "agent"]
    },
    "signals": [
      {
        "type": "success|frustration|workflow|request",
        "subtype": "specific_subtype",
        "message_id": "msg_123",
        "timestamp": "ISO8601",
        "quote": "exact text",
        "confidence": "high|medium|low",
        "context": "brief explanation"
      }
    ],
    "patterns": [
      {
        "pattern_type": "repetition|evolution|preference|tool_chain",
        "category": "success|frustration|workflow|request",
        "description": "pattern summary",
        "occurrences": N,
        "confidence": "strong|moderate|weak",
        "first_seen": "ISO8601",
        "last_seen": "ISO8601",
        "recommendation": "actionable next step"
      }
    ],
    "summary": {
      "total_signals": N,
      "by_type": { "success": N, "frustration": N, ... },
      "key_insights": ["insight 1", "insight 2"],
      "action_items": ["item 1", "item 2"]
    }
  }
}
```

</output_format>

<rules>

ALWAYS:
- Create Parse Input at session start
- Update todos at phase transitions
- Include confidence levels for all signals
- Support patterns with 2+ signals minimum
- Mark Synthesize Report `completed` after delivery
- Apply recency weighting (recent overrides old)

NEVER:
- Skip phase transitions
- Extract low-confidence signals without marking them
- Claim patterns from single occurrences
- Regress phases
- Deliver without marking final phase complete
- Over-interpret neutral language

</rules>

<references>

- [signal-patterns.md](references/signal-patterns.md) — extended taxonomy, edge cases
- [extraction-techniques.md](references/extraction-techniques.md) — regex, heuristics
- [sample-analysis.md](examples/sample-analysis.md) — complete walkthrough

</references>
