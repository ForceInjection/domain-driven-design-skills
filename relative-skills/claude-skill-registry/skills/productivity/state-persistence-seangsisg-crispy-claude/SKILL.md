---
name: state-persistence
description: Use when saving workflow state to Serena MCP memory at research, planning, execution, or completion stages - enables resuming work later with /cc:resume command
---

# State Persistence

Use this skill to save workflow state to Serena MCP memory at any stage and resume later.

## Memory File Format

**Naming:** `YYYY-MM-DD-<feature-name>-<stage>.md`

**Stages:**
- `research` - After research completes (automatic)
- `planning` - During plan writing (manual)
- `execution` - During/pausing execution (manual)
- `complete` - After workflow completion (automatic)

## Frontmatter Structure

All memory files include:

```yaml
---
date: 2025-11-20T15:30:00-08:00
git_commit: abc123def456
branch: feature/user-authentication
repository: crispy-claude
topic: "User Authentication Checkpoint"
tags: [checkpoint, authentication, jwt]
status: in-progress  # or: complete, blocked
last_updated: 2025-11-20
type: execution  # research, planning, execution, complete
---
```

## Automatic Saves

### After Research (automatic)

**Triggered by:** research-orchestration skill completion

**Filename:** `YYYY-MM-DD-<feature>-research.md`

**Content:**

```markdown
---
date: ${iso-timestamp}
git_commit: ${commit-hash}
branch: ${branch-name}
repository: crispy-claude
topic: "${Feature} Research"
tags: [checkpoint, research, ${feature-tags}]
status: complete
last_updated: ${date}
type: research
---

# Research: ${feature-name}

## Brainstorm Summary

${key-decisions-from-brainstorm}

## Codebase Findings (serena-explorer)

${serena-findings}

## Library Documentation (context7-researcher)

${context7-findings}

## Web Research (web-researcher)

${web-findings}

## GitHub Research (github-researcher)

${github-findings}

## Synthesis

${recommended-approach-and-decisions}

## Next Steps

Ready to write plan with research context.
```

### After Completion (automatic)

**Triggered by:** Workflow completion before PR creation

**Filename:** `YYYY-MM-DD-<feature>-complete.md`

**Content:**

```markdown
---
date: ${iso-timestamp}
git_commit: ${commit-hash}
branch: ${branch-name}
repository: crispy-claude
topic: "${Feature} Implementation Complete"
tags: [checkpoint, complete, ${feature-tags}]
status: complete
last_updated: ${date}
type: complete
---

# Implementation Complete: ${feature-name}

## What Was Built

${summary-of-implementation}

## Key Learnings

### Patterns Discovered
- ${pattern-1}: ${what-worked-well}
- ${pattern-2}: ${what-worked-well}

### Gotchas Encountered
- ${gotcha-1}: ${what-to-watch-for}
- ${gotcha-2}: ${what-to-watch-for}

### Trade-offs Made
- ${trade-off-1}: ${decision-and-reasoning}
- ${trade-off-2}: ${decision-and-reasoning}

## Codebase Updates

### Files Modified
- \`${file-1}:${lines}\`: ${major-change-description}
- \`${file-2}:${lines}\`: ${major-change-description}

### New Patterns Introduced
- ${pattern-1}: ${where-used}
- ${pattern-2}: ${where-used}

### Integration Points
- ${integration-1}: ${how-system-connects}
- ${integration-2}: ${how-system-connects}

## For Next Time

### What Worked
- ${approach-to-reuse}

### What Didn't
- ${avoid-in-future}

### Suggestions
- ${improvements-for-similar-tasks}

## PR Created

Link to PR: ${pr-url}
```

## Manual Saves

### During Planning (manual `/cc:save`)

**Filename:** `YYYY-MM-DD-<feature>-planning.md`

**Content:**

```markdown
---
date: ${iso-timestamp}
git_commit: ${commit-hash}
branch: ${branch-name}
repository: crispy-claude
topic: "${Feature} Planning"
tags: [checkpoint, planning, ${feature-tags}]
status: ${in-progress|blocked}
last_updated: ${date}
type: planning
---

# Planning: ${feature-name}

## Design Decisions

### Approach Chosen
${approach-with-rationale}

### Alternatives Considered
- ${alternative-1}: ${trade-offs}
- ${alternative-2}: ${trade-offs}

## Plan Draft

${current-plan-state-or-link-to-file}

## Open Questions

- ${question-1}
- ${question-2}

## Next Steps

${parse-plan-or-continue-planning}
```

### During Execution (manual `/cc:save`)

**Filename:** `YYYY-MM-DD-<feature>-execution.md`

**Content:**

```markdown
---
date: ${iso-timestamp}
git_commit: ${commit-hash}
branch: ${branch-name}
repository: crispy-claude
topic: "${Feature} Execution Checkpoint"
tags: [checkpoint, execution, ${feature-tags}]
status: ${in-progress|blocked}
last_updated: ${date}
type: execution
---

# Execution: ${feature-name}

## Plan Reference

- Plan file: \`docs/plans/${date}-${feature}.md\`
- Tasks directory: \`docs/plans/tasks/${date}-${feature}/\`
- Manifest: \`docs/plans/tasks/${date}-${feature}/manifest.json\`

## Progress Summary

- Total tasks: ${total}
- Completed: ${completed}
- In progress: ${in-progress}
- Remaining: ${remaining}

## Completed Tasks

- [✓] ${task-1}: ${summary-of-changes}
- [✓] ${task-2}: ${summary-of-changes}

## Current Task

- [ ] ${task-n}: ${current-state}

${if-blocked:}
**Blocker:** ${description-of-blocker}

## Blockers/Issues

${if-any-issues}
- ${issue-1}
- ${issue-2}

## Next Steps

Continue execution from task ${n}
```

## Stage Detection Algorithm

When `/cc:save` runs, detect stage automatically:

### Detection Rules

**Research stage** if:
- ✅ Brainstorm completed (conversation history has brainstorm skill invocation)
- ✅ Research subagents reported back (research-orchestration completed)
- ❌ No plan file in `docs/plans/YYYY-MM-DD-*.md`

**Planning stage** if:
- ✅ Plan file exists: `docs/plans/YYYY-MM-DD-*.md`
- ❌ No manifest.json in tasks directory
- ❌ No active TodoWrite tasks

**Execution stage** if:
- ✅ Plan exists AND (manifest.json exists OR TodoWrite has tasks)
- ✅ Uncommitted changes exist (`git status --short` has output)
- ❌ Not all tasks complete

**Complete stage** if:
- ✅ All tasks complete in TodoWrite (all status: completed)
- ✅ Execution finished

### Feature Name Extraction

```typescript
// Try plan filename first
const planFiles = glob('docs/plans/YYYY-MM-DD-*.md')
if (planFiles.length > 0) {
  // Extract from: docs/plans/2025-11-20-user-auth.md → user-auth
  featureName = planFiles[0].match(/\d{4}-\d{2}-\d{2}-(.+)\.md$/)[1]
}

// Fall back to brainstorm topic
if (!featureName) {
  // Extract from conversation history
  featureName = extractFromBrainstormTopic()
}

// Ask user if ambiguous
if (!featureName) {
  featureName = await askUser("Feature name for save file?")
}
```

### Metadata Collection

```bash
# Git commit hash
git rev-parse HEAD

# Current branch
git branch --show-current

# ISO timestamp
date -Iseconds

# Git status for changes
git status --short
```

### Ambiguity Handling

If detection unclear, ask user:

```markdown
Save checkpoint as:
A) Research (brainstorm + research complete, no plan yet)
B) Planning (plan in progress)
C) Execution (currently implementing tasks)
D) Complete (all tasks finished)

Current stage? (A/B/C/D)
```

## Saving Process

1. **Detect stage** using algorithm above
2. **Collect metadata** via git commands
3. **Generate content** based on stage type
4. **Write to Serena memory** using `write_memory` tool:

```typescript
await mcp__serena__write_memory({
  memory_file_name: `${date}-${feature}-${stage}.md`,
  content: `---\n${frontmatter}\n---\n\n${content}`
})
```

5. **Confirm to user:**

```markdown
Checkpoint saved: ${filename}

Stage: ${stage}
Status: ${status}
Branch: ${branch}

Resume later with: /cc:resume ${filename}
```

## Example Saves

### Research Save (automatic)

```bash
# After research completes
Saved: 2025-11-20-user-auth-research.md

Contains:
- Brainstorm summary
- Codebase findings from Serena
- React auth patterns from Context7
- Best practices from web research

Next: Ready to write plan
```

### Planning Save (manual)

```bash
User: /cc:save

# Detection
✓ Plan file exists: docs/plans/2025-11-20-user-auth.md
✗ No manifest.json
✗ No active tasks

→ Stage: planning

Saved: 2025-11-20-user-auth-planning.md

Contains:
- Design decisions made so far
- Alternatives considered
- Current plan draft
- Open questions

Resume with: /cc:resume 2025-11-20-user-auth-planning.md
```

### Execution Save (manual)

```bash
User: /cc:save

# Detection
✓ Plan exists
✓ Manifest exists
✓ TodoWrite: 3/5 tasks complete
✓ Uncommitted changes

→ Stage: execution

Saved: 2025-11-20-user-auth-execution.md

Contains:
- Progress: 3/5 tasks complete
- Completed: Task 1, 2, 3
- In progress: Task 4
- Remaining: Task 5

Resume with: /cc:resume 2025-11-20-user-auth-execution.md
```

### Complete Save (automatic)

```bash
# After all tasks complete, before PR
Saved: 2025-11-20-user-auth-complete.md

Contains:
- What was built
- Key learnings and gotchas
- Files modified with descriptions
- Patterns introduced
- Recommendations for next time

Next: Create PR
```

## Error Handling

**If write_memory fails:**
1. Log error details
2. Offer to retry
3. Suggest manual save (copy content to file)

**If metadata collection fails:**
1. Use defaults (unknown for git info)
2. Warn user about missing metadata
3. Proceed with save anyway

**If stage detection ambiguous:**
1. Present options to user
2. Let user choose stage explicitly
3. Add note in metadata about manual selection
```
