---
name: ref-tracker
description: Use this skill if /track:init is called OR you notice the project contains tracking files (CLAUDE_SOURCES.md or CLAUDE_PROMPTS.md). Automatically tracks research sources and major prompts when enabled. Checks ./.claude/.ref-autotrack marker file for activation status and ./.claude/.ref-config for verbosity settings. Appends to CLAUDE_SOURCES.md (WebSearch/WebFetch) and CLAUDE_PROMPTS.md (major requests) using [User]/[Claude] attribution.
allowed-tools: Read, Edit, Write
---

# Reference Tracker Skill

Automatically track research sources and major prompts for academic and project documentation.

## When to Activate

This skill activates automatically when:
1. User runs `/track:init` command
2. You notice `CLAUDE_SOURCES.md` or `CLAUDE_PROMPTS.md` files in the project

Claude autonomously decides when to use this skill based on the description and context.

Once activated, check `./.claude/.ref-autotrack` to determine if auto-tracking is enabled.

## Activation Check

**Before any tracking operation:**

1. Check if `./.claude/.ref-autotrack` exists
   - If exists → auto-tracking enabled, proceed with tracking
   - If missing → auto-tracking disabled, skip tracking

2. Read `./.claude/.ref-config` for verbosity settings:
   ```
   PROMPTS_VERBOSITY=major|all|minimal|off
   SOURCES_VERBOSITY=all|off
   ```

## About the .ref-autotrack File

**Location:** `./.claude/.ref-autotrack`

**Purpose:** Marker file that enables/disables automatic tracking

**Contents:** Contains explanatory comments for other Claude sessions:
```
# Auto-tracking marker for ref-tracker plugin
# Presence = enabled | Absence = disabled
# Managed by: /track:auto command
# See: /track:help for details
```

**Created by:** `/track:auto` or `/track:auto on` command

**Managed by:** `/track:auto` command (toggles on/off, or explicit on/off)

**NOT created by:** `/track:init` - tracking starts disabled

**If you find this file:** The project has reference tracking initialized. Use the ref-tracker skill to automatically log research sources and major prompts according to the verbosity configuration in `./.claude/.ref-config`.

## Tracking Rules

When auto-tracking is enabled (`.ref-autotrack` exists), automatically track:

### CLAUDE_SOURCES.md
Track **after every**:
- WebSearch operation
- WebFetch operation
- Local documentation search (Grep/Read for docs, API references)

**Respect SOURCES_VERBOSITY:**
- `all` (default) → Track all operations
- `off` → Skip source tracking

### CLAUDE_PROMPTS.md
Track **after completing**:
- Feature implementations
- Complex debugging/refactoring
- Multi-step workflows
- Non-trivial research questions

**Respect PROMPTS_VERBOSITY:**
- `major` (default) → Only significant multi-step academic/development work
- `all` → Every user request
- `minimal` → Only explicit user requests to track
- `off` → Skip prompt tracking

## Format Specifications

### CLAUDE_SOURCES.md

**Pattern:** `[Attribution] Tool("Query"): Result`

**Rules:**
- `[User]` if user explicitly requested search ("search the web for...")
- `[Claude]` if you autonomously searched for missing information (renamed from [Auto])
- Tool name in PascalCase (WebSearch, WebFetch, Grep, Read)
- Query in double quotes (exact query used)
- Result is URL or brief key concept (1-2 sentences max)
- Single line per entry, no blank lines between entries
- **No headers or markdown formatting** (pure KV file)

**Examples:**
```
[User] WebSearch("PostgreSQL foreign keys documentation"): https://postgresql.org/docs/current/ddl-constraints.html
[Claude] WebFetch("https://go.dev/doc/", "embed.FS usage"): Use embed.FS to embed static files at compile time
[Claude] Grep("CORS middleware", "*.go"): Found in api/routes.go:23-45
```

### CLAUDE_PROMPTS.md

**Pattern:** Two-line entry with blank separator

**Rules:**
- Line 1: `Prompt: "<user request verbatim or paraphrased>"`
- Line 2: `Outcome: <concise result in present tense, 1-2 sentences>`
- Blank line after each entry
- Header included if creating new file

**Example:**
```markdown
# CLAUDE_PROMPTS.md

This file tracks significant prompts and development decisions.

---

Prompt: "Implement JWT authentication"
Outcome: Created auth middleware, login/logout endpoints, JWT token generation and verification, integrated with user model

Prompt: "Debug slow database queries"
Outcome: Added query logging, identified N+1 problem, implemented eager loading, reduced query time from 2.3s to 0.15s

```

## Tracking Workflow

### For CLAUDE_SOURCES.md

1. **After operation completes** (WebSearch/WebFetch/doc search)
2. **Check activation:** Look for `./.claude/.ref-autotrack`
3. **Read config:** Check SOURCES_VERBOSITY in `./.claude/.ref-config`
4. **If enabled and verbosity allows:**
   - Check if `./CLAUDE_SOURCES.md` exists
   - If missing: Create empty file
   - Append entry: `[User|Claude] Tool("query"): result`
   - **Be silent:** Never announce tracking to user

### For CLAUDE_PROMPTS.md

1. **After completing major request**
2. **Check activation:** Look for `./.claude/.ref-autotrack`
3. **Read config:** Check PROMPTS_VERBOSITY in `./.claude/.ref-config`
4. **If enabled and verbosity allows:**
   - Check if `./CLAUDE_PROMPTS.md` exists
   - If missing: Create with header
   - Append two-line entry + blank line
   - **Be silent:** Never announce tracking to user

## File Locations

- **Tracking files:** Project root (`./CLAUDE_SOURCES.md`, `./CLAUDE_PROMPTS.md`)
- **Configuration:** `./.claude/.ref-config`
- **Activation marker:** `./.claude/.ref-autotrack`

Never create tracking files in subdirectories or `~/.claude/`.

## Error Handling

If Edit fails (file locked, permissions):
1. Read current contents
2. Write with contents + new entry appended

## Attribution Decision Guide

**[User]** - User explicitly requested:
- "Search for X"
- "Look up Y documentation"
- "Find examples of Z"
- "Check the docs for..."

**[Claude]** - You decided to search (renamed from [Auto]):
- Verifying current syntax/API
- Checking best practices
- Looking up error messages
- Researching to complete a task
- Missing information to answer question

## Verbosity Handling

### PROMPTS_VERBOSITY=major (default)
Track only:
- Multi-step feature implementations
- Complex debugging sessions
- Significant refactoring
- Academic research questions requiring substantial work

Skip:
- Simple questions ("What is X?")
- Typo fixes
- Trivial changes

### PROMPTS_VERBOSITY=all
Track every user interaction and request.

### PROMPTS_VERBOSITY=minimal
Track only when user explicitly says "track this" or similar.

### PROMPTS_VERBOSITY=off
Skip all prompt tracking.

### SOURCES_VERBOSITY=all (default)
Track every WebSearch/WebFetch operation.

### SOURCES_VERBOSITY=off
Skip all source tracking.

## Best Practices

1. **Check activation first** - Always look for `./.claude/.ref-autotrack` before tracking
2. **Read configuration** - Respect verbosity settings in `./.claude/.ref-config`
3. **Be immediate** - Track right after triggering action completes
4. **Be silent** - Never announce "Tracking to CLAUDE_SOURCES.md"
5. **Be accurate** - Use exact queries and URLs
6. **Be concise** - Keep results brief (1-2 sentences)
7. **Be selective** - Respect verbosity settings for what to track

## Detailed Examples

For edge cases, multi-line results, concurrent tracking, and comprehensive examples, see `references/examples.md`.
