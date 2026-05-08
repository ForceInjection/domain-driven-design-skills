---
name: Retrospective Process
description: "This skill should be used when the user asks to 'run a retrospective', 'review this session', 'extract learnings', 'what did we learn', 'analyze our conversation', 'session review', or wants to reflect on work done during the conversation."
version: 1.0.0
---

# Retrospective Process

Guide for analyzing development sessions to extract learnings, identify patterns, and improve future work through structured reflection.

## Purpose

Retrospectives transform implicit session knowledge into explicit, reusable rules and knowledge entries. Extract value from:

- Mistakes made and their root causes
- Good decisions and why they worked
- Patterns discovered during implementation
- Debugging insights worth preserving
- Architectural decisions and rationale

## Analysis Framework

### Depth Levels

| Depth | Analysis Scope | Time | Use Case |
|-------|---------------|------|----------|
| `quick` | Major events only | ~2 min | Short sessions, obvious learnings |
| `deep` | Patterns + context | ~5 min | Standard sessions |
| `ultrathink` | Full reflection | ~10 min | Complex sessions, debugging-heavy |

### Analysis Categories

Analyze session events across five categories:

**1. Mistakes (M)**
- What went wrong?
- Root cause (not just symptom)
- Prevention strategy
- Rule candidate: YES/NO

**2. Good Decisions (G)**
- What worked well?
- Why it succeeded
- Pattern to replicate
- KG entry candidate: YES/NO

**3. Patterns (P)**
- Recurring code patterns
- Workflow patterns
- Tool usage patterns
- Worth codifying: YES/NO

**4. Debugging Insights (D)**
- Error resolution strategies
- Investigation techniques
- Tool combinations that worked
- Worth documenting: YES/NO

**5. Architectural Decisions (A)**
- Design choices made
- Trade-offs considered
- Rationale
- Add to decision log: YES/NO

## Session Analysis Process

### Step 1: Scan Session

Scan conversation for significant events:

```
Identify:
- Error messages and their resolutions
- Multiple attempts at same task
- Tool failures and recoveries
- User corrections or clarifications
- Successful implementations
- Refactoring or rework
```

### Step 2: Categorize Events

For each significant event, assign category (M/G/P/D/A) and assess:

```
Event: [Brief description]
Category: [M/G/P/D/A]
Impact: [High/Medium/Low]
Actionable: [Yes/No]
```

### Step 3: Extract Learnings

Transform events into structured learnings:

```markdown
## Learning: [Title]

**Category**: [M/G/P/D/A]
**Context**: [When this applies]
**Learning**: [What was learned]
**Action**: [Rule to add | KG entry | No action]
```

### Step 4: Generate Outputs

For each actionable learning:

**If Rule candidate:**
- Use concise-rule-writing skill for formatting
- Determine placement (CLAUDE.md vs .claude/rules/)
- Draft rule text (<50 words)

**If KG entry candidate:**
- Determine entry type (decision, pattern, convention)
- Draft entry content
- Identify related entries

## Output Format

Present findings grouped by action type:

```markdown
## Retrospective Results

### Session Summary
- Duration: [X messages/events analyzed]
- Key events: [Count by category]

### Rules to Add
| Rule | Placement | Rationale |
|------|-----------|-----------|
| [rule text] | [CLAUDE.md/.claude/rules/X.md] | [why] |

### Rules to Update
| Current | Proposed | File |
|---------|----------|------|
| [old] | [new] | [path] |

### Knowledge Graph Entries
| Type | Content | Tags |
|------|---------|------|
| [decision/pattern/convention] | [text] | [tags] |

### Skipped Items
- [Item] - [Reason: too specific/already covered/low impact]
```

## Quality Criteria

Evaluate each proposed change:

**Include if:**
- Applies to future sessions (not one-off)
- Prevents real problems (not theoretical)
- Can be stated in <50 words (concise)
- Not already covered by existing rules

**Exclude if:**
- Too specific to this task
- Already captured elsewhere
- Low probability of recurrence
- Would clutter rule set

## Integration Points

### With Knowledge Graph

Store retrospective results in KG:

```bash
# Add decision
/coconut-knowledge-graph:add "decision-name" --type decision --content "[text]"

# Add pattern
/coconut-knowledge-graph:add "pattern-name" --type convention --content "[text]"
```

### With Rules System

Create rules via:

```bash
# Add to rules
/coconut-rules:add-rule "[rule text]"
```

### History Tracking

Save retrospective summary to `.claude/retrospectives/YYYY-MM-DD.md`:

```markdown
# Retrospective: [Date]

## Session Focus
[What was worked on]

## Key Learnings
[Bullet points]

## Changes Made
- Rules: [list]
- KG entries: [list]

## Notes
[Additional context]
```

## Common Patterns

### Mistake → Rule Pipeline

```
Mistake detected
↓
Identify root cause (not symptom)
↓
Determine if preventable by rule
↓
Draft rule (<50 words)
↓
Place: Security/critical → CLAUDE.md
       Domain-specific → .claude/rules/[domain].md
```

### Decision → KG Pipeline

```
Decision made during session
↓
Document alternatives considered
↓
Record rationale
↓
Tag with relevant contexts
↓
Add to knowledge graph
```

## Commands Reference

| Command | Purpose |
|---------|---------|
| `/coconut-rules:retrospective` | Run full retrospective analysis |
| `/coconut-rules:retrospective --depth quick` | Quick analysis |
| `/coconut-rules:add-rule` | Add individual rule |
| `/coconut-knowledge-graph:add` | Add KG entry |

## Best Practices

- Run retrospective at natural breakpoints, not mid-task
- Focus on actionable learnings, skip theoretical improvements
- Prefer updating existing rules over creating new ones
- Keep rules concise - use concise-rule-writing skill
- Cross-reference related rules and KG entries
- Delete retrospective history older than 30 days unless significant
