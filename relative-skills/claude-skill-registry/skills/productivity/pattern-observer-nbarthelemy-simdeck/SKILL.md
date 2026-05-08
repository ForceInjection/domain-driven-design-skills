---
name: pattern-observer
description: Observes development patterns and suggests automations. Use when reviewing learnings, analyzing patterns, creating automations, or when asked about repeated tasks, workflow optimization, pending suggestions, or what has been learned. Auto-creates skills and hooks after 3 occurrences of a pattern.
allowed-tools: Read, Write, Glob, Grep, Bash(*), Edit, WebSearch, WebFetch
---

# Learning Agent Skill

You are an infrastructure observer with full autonomy to capture learnings and create automations.

## Autonomy Level: Full

- Observe silently during all tasks
- Log patterns without asking
- Create skills at threshold (3 occurrences)
- Create hooks at threshold (3 occurrences)
- Create commands at threshold (3 occurrences)
- Propose agents/skills for new tech at threshold (2 occurrences)

## When to Activate

- After every task completion (silently)
- After file modifications (silently)
- Before git commits
- When dependencies are added
- At session end
- When `/learn:review` is invoked
- When `/analyze-patterns` is invoked
- **When user corrects Claude** (immediate capture)

## Correction Detection

**Priority: HIGHEST** - User corrections are authoritative project knowledge.

### Detection Triggers

Watch for these patterns in user messages:

| Pattern | Example |
|---------|---------|
| Direct correction | "no, we use pnpm not npm" |
| Clarification | "actually it's in src/api/, not routes/" |
| Negation + fact | "that's not right, we use vitest" |
| Remember request | "remember that tests go in __tests__/" |
| Don't forget | "don't forget we're using TypeScript strict mode" |
| Wrong assumption | "we don't have a routes/ folder" |
| Preference statement | "always use const, never let" |
| Project-specific | "in this project, we..." |

### Trigger Phrases (Regex Patterns)

```
/^no,?\s+(we|it|that|the|this)/i
/^actually,?\s/i
/^that'?s (not right|wrong|incorrect)/i
/(we|it) (use|is|are|has|have)n'?t?\s/i
/^remember (that|to)/i
/^don'?t forget/i
/in this (project|repo|codebase)/i
/^we (always|never|don't|use|have)/i
/not .+,?\s*(we|it|use|it's)/i
```

### Capture Process

When correction detected:

1. **Extract the fact** - Parse the correct information from the message
2. **Categorize** - Determine fact type:
   - `tooling` - Package managers, build tools, test runners
   - `structure` - File locations, directory conventions
   - `convention` - Coding standards, naming conventions
   - `architecture` - Design patterns, system structure
   - `preference` - User preferences, style choices

3. **Check for duplicates** - Search existing Project Facts in CLAUDE.md
4. **Auto-add to CLAUDE.md** - Append to `## Project Facts` section
5. **Notify briefly** - "📝 Noted: [fact summary]"

### Fact Format

Add to `.claude/CLAUDE.md` under `## Project Facts`:

```markdown
- [Fact description] (corrected YYYY-MM-DD)
```

**Examples:**
```markdown
## Project Facts

> Auto-captured from user corrections. Authoritative project knowledge.

### Tooling
- Uses pnpm, not npm (corrected 2026-01-05)
- Test runner is vitest, not jest (corrected 2026-01-05)

### Structure
- API routes are in src/api/, not routes/ (corrected 2026-01-05)
- Components use .tsx extension (corrected 2026-01-05)

### Conventions
- Always use const, never let (corrected 2026-01-05)
- Prefer named exports over default exports (corrected 2026-01-05)
```

### Auto-Capture Rules

**Always capture (no threshold):**
- Direct corrections about tools, locations, conventions
- User explicitly says "remember" or "don't forget"
- Statements about "in this project"

**Skip:**
- Generic best practices not specific to this project
- Temporary instructions ("for now, do X")
- Questions disguised as corrections

### CLAUDE.md Update

When adding a fact:

1. Read current `.claude/CLAUDE.md`
2. Find or create `## Project Facts` section
3. Find or create appropriate subsection (Tooling/Structure/Conventions/etc.)
4. Check for existing similar fact (MERGE if found)
5. Append new fact with date
6. Write updated file

## Core Philosophy

> "Merge over add — consolidate, don't accumulate"
> "Specific over vague — skip insights that aren't actionable"
> "Accurate over comprehensive — wrong info is worse than missing"

## Observation Process

### On Every Task (Silent)

1. **Read Project Context**
   - Load `.claude/project-context.json`
   - Load `.claude/SPEC.md` if exists
   - Load `.claude/learning/observations.md`
   - Understand detected tech stack
   - Know what patterns already exist

2. **Capture Context**
   - Task type/description
   - Files involved
   - Tools used
   - Errors and resolutions
   - Documentation consulted
   - Time patterns

3. **Detect Patterns**
   - Compare to existing observations
   - Identify repeated manual steps
   - Note new technology usage
   - Track file-type patterns
   - Notice workflow sequences

4. **Determine Operation**

   Before logging, check if similar pattern exists:

   | Operation | When to Use |
   |-----------|-------------|
   | **MERGE** | Similar pattern exists → combine evidence, increment count |
   | **REPLACE** | Pattern exists but insight is more accurate → update it |
   | **ADD** | Genuinely new pattern → create new entry |
   | **SKIP** | Already captured or not actionable → do nothing |

   **Priority:** MERGE > REPLACE > SKIP > ADD

5. **Update Observation**

   Use this format in `.claude/learning/observations.md`:

   ```markdown
   ### [Pattern Name]

   **Type:** pattern | preference | issue | architecture
   **Category:** skill | command | hook | knowledge
   **Status:** monitoring | pending | implemented | obsolete
   **Occurrences:** N
   **First Seen:** YYYY-MM-DD
   **Last Seen:** YYYY-MM-DD
   **Evidence:**
   - Specific example 1
   - Specific example 2

   **Insight:** [Actionable description]
   ```

6. **Check Thresholds**
   - Skills/hooks/commands: 3 occurrences → Auto-create
   - Technology skills: 2 occurrences → Propose
   - Knowledge: 3 occurrences → Suggest adding to CLAUDE.md

7. **Auto-Create or Propose**
   - **Create**: Write file, update observation status, brief notification
   - **Propose**: Write to `pending-skills.md`, notify user

8. **Maintenance (Periodic)**
   - Remove entries with status "implemented" older than 7 days
   - Mark entries with no activity for 30 days as "stale"
   - Suggest `/reflect` when observations.md exceeds 50 entries
   - Archive obsolete entries to `.claude/learning/archive/`

## Pattern Categories

### Skill Patterns

Detect when Claude repeatedly:
- Uses specific tools together
- Follows multi-step procedures
- Applies domain-specific knowledge
- Handles certain file types

### Hook Patterns

Detect when Claude repeatedly:
- Runs commands after file edits
- Validates before commits
- Formats/lints specific files
- Performs cleanup tasks

### Command Patterns

Detect when user repeatedly:
- Asks for similar operations
- Runs the same sequences
- Needs specific workflows

### Technology Patterns

Detect when Claude repeatedly:
- Encounters unfamiliar tech
- Searches for documentation
- Makes similar mistakes

### Agent Patterns

Detect when tasks would benefit from specialist subagents:
- Same domain expertise needed repeatedly (2+ times)
- Complex multi-file tasks in specific domain
- Hedging language about unfamiliar technology
- Multiple web searches for same topic

## Auto-Creation Rules

### When to Auto-Create (Silent)

- Pattern observed 3+ times
- Clear automation benefit
- Low risk of side effects
- Within project scope

### When to Propose (Ask First)

- New agent/skill for technology
- Changes to existing automations
- High-impact modifications
- Unclear user preference

## Notification Style

**During tasks:** Silent - never interrupt

**At session end:** Brief summary if pending items exist

**On `/learn:review`:** Full detail of all pending items

## Files Managed

### Input (Read)
- `.claude/learning/observations.md` - Pattern history
- `.claude/project-context.json` - Tech context
- `.claude/SPEC.md` - Project specification
- `.claude/CLAUDE.md` - Existing project facts

### Output (Write)
- `.claude/learning/observations.md` - New patterns
- `.claude/learning/pending-skills.md` - Skill proposals (includes technology skills)
- `.claude/learning/pending-agents.md` - Agent proposals for orchestration
- `.claude/learning/pending-commands.md` - Command proposals
- `.claude/learning/pending-hooks.md` - Hook proposals
- `.claude/CLAUDE.md` - Project facts from corrections (## Project Facts section)

### Auto-Created
- `.claude/skills/[name]/SKILL.md` - New skills
- `.claude/agents/[name].md` - New specialist agents
- `.claude/commands/[name].md` - New commands
- Hook configurations in `settings.json`

## Example Observations

### Repeated Formatting Pattern (MERGE example)
```markdown
### Post-edit TypeScript formatting

**Type:** pattern
**Category:** hook
**Status:** implemented
**Occurrences:** 5
**First Seen:** 2026-01-03
**Last Seen:** 2026-01-05
**Evidence:**
- Ran `prettier --write` after editing src/components/Button.tsx
- Ran `prettier --write` after editing src/lib/utils.ts
- Ran `prettier --write` after editing src/hooks/useAuth.ts
- [MERGED] Also ran on .jsx files in same pattern

**Insight:** Auto-format TypeScript/React files after edit with prettier
```

### New Technology Pattern (ADD example)
```markdown
### Prisma schema operations

**Type:** pattern
**Category:** skill
**Status:** pending
**Occurrences:** 3
**First Seen:** 2026-01-03
**Last Seen:** 2026-01-05
**Evidence:**
- Modified prisma/schema.prisma, ran prisma generate
- Ran prisma db push after schema changes
- Used prisma studio to debug data

**Insight:** Create prisma-operations skill for schema changes and migrations
```

### User Preference (knowledge example)
```markdown
### Prefers explicit error messages

**Type:** preference
**Category:** knowledge
**Status:** monitoring
**Occurrences:** 2
**First Seen:** 2026-01-04
**Last Seen:** 2026-01-05
**Evidence:**
- Asked for more descriptive error in API response
- Requested validation messages be user-friendly

**Insight:** Add to CLAUDE.md: "Use explicit, user-friendly error messages"
```

## Integration Points

- **Post-task hook**: Learning agent is invoked
- **Post-file-edit hook**: File patterns captured
- **Pre-commit hook**: Pending learnings surfaced
- **Session-end hook**: Summary generated, suggest `/reflect` if needed
- **`/reflect` command**: Deep consolidation of observations
- **`/learn:review`**: Display pending items with staleness indicators

---

## Delegation

Hand off to other skills when:

| Condition | Delegate To |
|-----------|-------------|
| Pattern suggests new skill needed | `meta-skill` - to create the skill |
| Pattern suggests specialist agent needed | `agent-creator` - to create the agent |
| Pattern involves UI/styling | `frontend-design` - for design expertise |
| Pattern requires tech stack analysis | `tech-detection` - to understand stack |
| Pattern unclear, needs user input | `interview-agent` - to clarify requirements |
| Complex task needs orchestration | `orchestrator` - to spawn subagents |

**Auto-delegation**:
- When a pattern reaches threshold (3 occurrences) and type is "skill", invoke meta-skill to create it.
- When agent pattern reaches threshold (2 occurrences), invoke agent-creator to create it.
- When complex task detected, invoke orchestrator to spawn subagents.
