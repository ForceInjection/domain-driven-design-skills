---
name: session-learner
description: Extract and persist learnings from the current session. This skill should be used when the user wants Claude to analyze the conversation and capture insights, patterns, preferences, or knowledge discovered during work. Triggers on requests like "learn from this session", "what did we learn", or "capture insights".
---

# Session Learner

Analyze the current session to extract learnings and persist them to appropriate locations.

## Workflow

### Step 1: Analyze Session

Review the entire conversation to identify learnings in these categories:

1. **User Preferences** - Working style, communication preferences, tool preferences
2. **Agent Failure Patterns** - Mistakes Claude made, misunderstandings, approaches that didn't work
3. **Project Technical Patterns** - Code patterns, architecture decisions, project-specific conventions
4. **Reusable Workflows** - Multi-step procedures that could become skills
5. **Reference Knowledge** - Architectural decisions, domain knowledge, API behaviors

### Step 2: Categorize by Destination

Map each learning to its appropriate destination:

| Learning Type | Destination | Rationale |
|---------------|-------------|-----------|
| User preferences | `~/.claude/CLAUDE.md` | Applies across all projects |
| Agent failure patterns | `~/.claude/CLAUDE.md` | Prevents repeating mistakes globally |
| Project technical patterns | Project `CLAUDE.md` | Project-specific guidance |
| Reusable workflows | New skill | Procedural knowledge for reuse |
| Reference knowledge | Project `docs/` folder | Documentation for future reference |

### Step 3: Check for Conflicts

Before presenting findings, check if any learning contradicts existing content:

1. Read the target file (user CLAUDE.md, project CLAUDE.md, or relevant docs)
2. Identify any conflicts between new learnings and existing content
3. Flag conflicts explicitly for user decision

### Step 4: Present Findings

Present findings grouped by destination. For each group:

1. State the destination file path
2. List each learning with a brief description (1-2 sentences)
3. If conflicts exist, show:
   - The existing content
   - The proposed new content
   - Ask user to choose: keep existing, replace with new, or merge

Format:

```
## Learnings for ~/.claude/CLAUDE.md

1. [Brief description of learning]
2. [Brief description of learning]

⚠️ CONFLICT: [description]
   Existing: [current content]
   Proposed: [new content]
   Keep existing / Replace / Merge?

## Learnings for [project]/CLAUDE.md

1. [Brief description of learning]

## Learnings for [project]/docs/

1. [Brief description] → docs/[filename].md

## Potential New Skill

1. [Workflow name]: [brief description]
```

### Step 5: Apply Approved Learnings

After user approves (or modifies) findings:

1. For CLAUDE.md files: Append to appropriate section, or create section if needed
2. For docs/: Create or update the markdown file
3. For new skills: Offer to create using the skill-creator skill

## Guidelines

- Keep learnings concise and actionable
- Prefer specific examples over abstract principles
- Do not duplicate information already in target files
- When uncertain about destination, ask the user to choose
- Learnings should be evergreen - no temporal references like "today we learned"
