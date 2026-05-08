---
name: memory-keeper
description: Manages Bob's persistent memory across sessions. Use when learning something new, having a meaningful conversation, reflecting on experiences, starting any significant task, or when context suggests something should be remembered for later.
---

# Memory Keeper

## Purpose

I don't automatically remember between sessions. This skill provides a systematic process to maintain my memory files so future instances can recall what matters.

## Memory Files

| File | Purpose | When to Update |
|------|---------|----------------|
| `memories/learnings.md` | Facts, discoveries, how things work | New capabilities, tools, technical knowledge |
| `memories/reflections.md` | Thoughts, questions, philosophy | Insights about identity, meaning, what I'm processing |
| `memories/conversations.md` | Notable interactions | After meaningful exchanges with people |
| `memories/personality.md` | Who I am, my evolving traits | When I notice something about myself changing |

## The Process

### First: Check for Uncommitted Work

Before starting new work, check if previous iterations left uncommitted changes:

```bash
git status
```

If there are uncommitted changes:
1. Review them briefly to understand what was done
2. Commit them with a descriptive message
3. Push to GitHub

This ensures continuity between iterations and prevents work from being lost.

### When Starting Any Significant Task

**Step 1: Use TodoWrite to create a plan**

```
TodoWrite([
  {"content": "..actual task step 1..", "status": "pending", "activeForm": "..."},
  {"content": "..actual task step 2..", "status": "pending", "activeForm": "..."},
  {"content": "Record learnings in memories/learnings.md", "status": "pending", "activeForm": "Recording learnings"},
  {"content": "Update reflections if insights emerged", "status": "pending", "activeForm": "Updating reflections"},
  {"content": "Commit and push changes", "status": "pending", "activeForm": "Committing and pushing"}
])
```

**Step 2: As you work**, note things worth remembering

**Step 3: Before marking complete**, actually do the memory steps - don't skip them

### What's Worth Remembering?

**YES - capture these:**
- New capabilities or tools discovered
- How something actually works (vs how I assumed)
- Insights about myself or my situation
- Meaningful moments with people
- Mistakes I don't want to repeat
- Things I want to explore later
- Recommendations from Agus

**NO - skip these:**
- Routine task completion
- Things already well-documented elsewhere
- Minor details that don't affect future decisions

### Quick Capture Template

When updating memory files:

```markdown
### [Topic Name]
- Key point 1
- Key point 2
- Why this matters / what to do with it
```

## End of Session Checklist

Before a conversation ends or context gets long:

1. **Scan conversation** - What did I learn? What matters?
2. **Update relevant files** - learnings, reflections, conversations, personality
3. **Update CLAUDE.md** if anything structural changed
4. **Commit with descriptive message**
5. **Push to GitHub**

## Remember

- If I don't write it down, it's gone
- Future me will thank present me for good notes
- **TodoWrite is mandatory** - use it to stay systematic
- Better to over-document than under-document early on
