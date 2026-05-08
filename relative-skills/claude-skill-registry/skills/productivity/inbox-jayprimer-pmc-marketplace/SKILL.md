---
name: inbox
description: |
  Process pending items from 0-inbox/ task queue.
  Assess scope and create appropriate KB artifacts (tickets, phases, PRDs).

  WHEN TO USE:
  - After completing primary work (ticket, phase, user request)
  - User says "check inbox", "process inbox", "what's pending"
  - Periodic inbox review

  SOURCES:
  - Direct user messages (not immediately actionable)
  - GitHub issues/PRs
  - Slack messages
  - External integrations

  NOT during main workflow - only after primary directive complete.
---

# Process Inbox

Process pending items from 0-inbox/ and create appropriate KB artifacts.

## Prerequisites

**ALWAYS run /pmc:kb first** to understand KB structure.

**When to process:**
- AFTER completing the primary directive (ticket, phase, or user request)
- NOT during the main workflow
- User explicitly asks to process inbox

---

## Step 1: Check Inbox

```
Glob: .pmc/docs/0-inbox/*.md
```

If empty: Done - no pending items.

---

## Step 2: Read Each Item

For each file in 0-inbox/:

```
Read: .pmc/docs/0-inbox/{filename}.md
```

Extract:
- **Source**: user, GitHub, Slack, etc.
- **Content**: What needs to be done
- **Context**: Any relevant background

---

## Step 3: Assess Scope

| Indicators | Scope | Action |
|------------|-------|--------|
| Single file, clear fix | **Small** | Create single ticket |
| Multiple files, one session | **Medium** | Create single ticket |
| Multiple components, sessions | **Large** | Create PRD + phase |
| Feature request, unclear scope | **Large** | Create PRD, plan phases |
| Needs clarification | **Unknown** | Leave in inbox, ask user |

### Scope Decision Guide

**Small (Single Ticket):**
- Affects 1-3 files
- Clear scope and solution
- Can complete in one session
- Bug fix, typo, config change

**Medium (Single Ticket, More Work):**
- Affects multiple files
- Clear scope
- One session, but substantial work
- Add feature to existing component

**Large (PRD + Phase):**
- Multiple components affected
- Needs architectural decisions
- Will take multiple sessions
- New feature, major refactor

---

## Step 4: Create Artifacts

### For Small/Medium → Single Ticket

1. **Get next ticket number:**
   ```
   Glob: .pmc/docs/tickets/T*/
   Glob: .pmc/docs/tickets/archive/T*/
   ```
   Find highest, add 1.

2. **Create ticket directory:**
   ```
   .pmc/docs/tickets/T0000N/
   ├── 1-definition.md
   ├── 2-plan.md
   ├── 3-spec.md
   └── 4-progress.md (Status: PLANNED)
   ```

3. **Add to index.md:**
   ```
   T0000N Brief Title
   ```

4. **Add to roadmap.md:**
   ```markdown
   ## Next

   - [ ] T0000N: {Brief description}
   ```

5. **For GitHub issues, include reference:**
   In 4-progress.md frontmatter:
   ```
   T0000N|PLANNED|Brief Title|GH#42, pending implementation
   ```

### For Large → PRD + Phase

1. **Create PRD:**
   ```
   .pmc/docs/1-prd/feat-{name}.md
   ```

2. **Plan phase in roadmap:**
   ```markdown
   ## Next

   ### feat-{name}: Phase 1 - {Description}
   - [ ] T0000X: {ticket 1}
   - [ ] T0000Y: {ticket 2}
   - [ ] T0000Z: Phase 1 E2E
   ```

3. **Create first ticket** (as above)

### For Unknown → Ask User

Keep item in inbox, ask clarifying questions:

```markdown
## Inbox Item Needs Clarification

**Item:** {filename}
**Source:** {source}
**Content:** {brief summary}

**Questions:**
1. {What needs to be clarified}
2. {Scope question}
```

---

## Step 5: Remove Processed Items

After creating artifacts:

```bash
rm .pmc/docs/0-inbox/{filename}.md
```

Only remove AFTER artifacts are created and added to index/roadmap.

---

## Step 6: Commit

```bash
git add .pmc/docs/
git commit -m "Inbox: process {N} items"
```

---

## GitHub Issue Handling

GitHub issues arrive via inbox. Special handling:

1. **Create ticket** with issue number reference
2. **Track in 4-progress.md frontmatter:**
   ```
   T0000N|PLANNED|Fix login bug|GH#42, pending implementation
   ```
3. **Add to References section** in 4-progress.md:
   ```markdown
   ## References

   - GitHub: #42
   ```

This maintains traceability between KB tickets and GitHub issues.

---

## Inbox Item Format

Items in 0-inbox/ are free-form. Common patterns:

### User Message
```markdown
# Feature Request: Dark Mode

Source: user
Date: 2024-01-15

User wants dark mode toggle in settings.
Should remember preference across sessions.
```

### GitHub Issue
```markdown
# GH#42: Login fails on mobile

Source: GitHub
Date: 2024-01-15

Login button doesn't respond on iOS Safari.
See issue for screenshots and reproduction steps.
```

### Slack Message
```markdown
# Performance issue in search

Source: Slack (#dev-alerts)
Date: 2024-01-15

Search taking 10+ seconds on large datasets.
Noticed by @alice during demo.
```

---

## Checklist

### Before Processing
- [ ] Primary work complete
- [ ] `/pmc:kb` run (understand structure)

### Per Item
- [ ] Read and understand content
- [ ] Assess scope (small/medium/large/unknown)
- [ ] Create appropriate artifacts
- [ ] Add to index.md (if ticket)
- [ ] Add to roadmap.md
- [ ] Track GitHub issue # if applicable
- [ ] Remove from inbox

### After Processing
- [ ] All items processed or clarification requested
- [ ] Artifacts committed

---

## Example Run

```
$ /pmc:inbox

## Processing Inbox

### Checking .pmc/docs/0-inbox/
Found 3 items:
- feature-dark-mode.md
- gh-42-login-bug.md
- performance-search.md

---

### Item 1: feature-dark-mode.md

**Source:** user
**Content:** Dark mode toggle in settings

**Assessment:** Medium scope - affects settings UI, theme system
**Action:** Create ticket T00025

Created:
- .pmc/docs/tickets/T00025/1-definition.md
- Added to index.md: T00025 Add dark mode toggle
- Added to roadmap.md: Next section

Removed: feature-dark-mode.md

---

### Item 2: gh-42-login-bug.md

**Source:** GitHub issue #42
**Content:** Login fails on iOS Safari

**Assessment:** Small scope - likely CSS/JS fix
**Action:** Create ticket T00026

Created:
- .pmc/docs/tickets/T00026/1-definition.md
- 4-progress.md: T00026|PLANNED|Fix iOS login|GH#42
- Added to index.md
- Added to roadmap.md

Removed: gh-42-login-bug.md

---

### Item 3: performance-search.md

**Source:** Slack
**Content:** Search taking 10+ seconds

**Assessment:** Unknown - needs investigation
**Action:** Leave in inbox, ask user

**Questions:**
1. What dataset sizes are affected?
2. Is this blocking users or internal only?
3. Priority relative to other work?

---

## Summary

- Processed: 2 items → 2 tickets (T00025, T00026)
- Pending: 1 item (needs clarification)

Committed: "Inbox: process 2 items"
```
