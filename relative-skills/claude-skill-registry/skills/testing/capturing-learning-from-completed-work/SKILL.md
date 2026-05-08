---
name: Capturing Learning from Completed Work
description: Systematic retrospective to capture decisions, lessons, and insights from completed work
when_to_use: when completing significant work, after debugging sessions, before moving to next task, when work took longer than expected, or when approaches were discarded
version: 1.0.0
languages: all
---

# Capturing Learning from Completed Work

## Overview

**Context is lost rapidly without systematic capture.** After completing work, engineers move to the next task and forget valuable lessons, discarded approaches, and subtle issues discovered. This skill provides a systematic retrospective workflow to capture learning while context is fresh.

## When to Use

Use this skill when:
- Completing significant features or complex bugfixes
- After debugging sessions (especially multi-hour sessions)
- Work took longer than expected
- Multiple approaches were tried and discarded
- Subtle bugs or non-obvious issues were discovered
- Before moving to next task (capture fresh context)
- Sprint/iteration retrospectives

**When NOT to use:**
- Trivial changes (typo fixes, formatting)
- Work that went exactly as expected with no learnings
- When learning is already documented elsewhere

## Critical Principle

**Exhaustion after completion is when capture matters most.**

The harder the work, the more valuable the lessons. "Too tired" means the learning is significant enough to warrant documentation.

## Common Rationalizations (And Why They're Wrong)

| Rationalization | Reality |
|----------------|---------|
| "I remember what happened" | Memory fades in days. Future you won't remember details. |
| "Too tired to write it up" | Most tired = most learning. 10 minutes now saves hours later. |
| "It's all in the commits" | Commits show WHAT changed, not WHY you chose this approach. |
| "Not worth documenting" | If you spent >30 min on it, someone else will too. Document it. |
| "It was too simple/small" | If it wasn't obvious to you at first, it won't be obvious to others. |
| "Anyone could figure this out" | You didn't know it before. Document for past-you. |
| "Nothing significant happened" | Every task teaches something. Capture incremental learning. |
| "User wants to move on" | User wants quality. Learning capture ensures it. |

**None of these are valid reasons to skip capturing learning.**

## What to Capture

**✅ MUST document:**
- [ ] Brief description of what was accomplished
- [ ] Key decisions made (and why)
- [ ] Approaches that were tried and discarded (and why they didn't work)
- [ ] Non-obvious issues discovered (and how they were solved)
- [ ] Time spent vs. initial estimate (if significantly different, why?)
- [ ] Things that worked well (worth repeating)
- [ ] Things that didn't work well (worth avoiding)
- [ ] Open questions or follow-up needed

**Common blind spots:**
- Discarded approaches (most valuable learning often comes from what DIDN'T work)
- Subtle issues (small bugs that took disproportionate time)
- Implicit knowledge (things you learned but didn't realize were non-obvious)

## Implementation

### Step 1: Review the Work

Before writing, review what was done:
- Check git diff to see all changes
- Review commit messages for key decisions
- List approaches tried (including failed ones)
- Note time spent and estimates

### Step 2: Capture in Structure

Create or update summary in appropriate location:

**For work tracking systems:**
- Use project's work directory structure
- Common: `docs/work/summary.md` or iteration-specific file

**For non-tracked work:**
- Add to CLAUDE.md under relevant section
- Or create dated file in `docs/learning/YYYY-MM-DD-topic.md`

**Minimal structure:**
```markdown
## [Work Item / Feature Name]

**What:** Brief description (1-2 sentences)

**Key Decisions:**
- Decision 1 (why)
- Decision 2 (why)

**What Didn't Work:**
- Approach X (why it failed, what we learned)
- Approach Y (why it failed)

**Issues Discovered:**
- Issue 1 (how solved)
- Issue 2 (how solved)

**Time Notes:**
Estimated X hours, took Y hours. [Explain if significant difference]

**Open Questions:**
- Question 1
- Question 2
```

### Step 3: Link to Implementation

Connect learning to codebase:
- Reference key files modified
- Link to commits or PRs
- Cross-reference to CLAUDE.md if patterns emerged

### Step 4: Make it Searchable

Ensure future discoverability:
- Use descriptive headings
- Include error messages if debugging
- Tag with relevant technology/pattern names

## Real-World Impact

**Without systematic capture:**
- Repeat same failed approaches (waste time)
- Forget subtle issues (encounter again later)
- Lose context on decisions (question past choices)
- Can't transfer knowledge to team
- Learning stays with individual

**With this workflow:**
- Failed approaches documented (others avoid same path)
- Subtle issues captured (searchable solutions)
- Decision rationale preserved (future maintenance easier)
- Knowledge shared across team
- Organization builds learning repository

## Integration with Commands/Agents

This skill can be invoked by:
- `/cipherpowers:summarise` command for retrospective capture
- Pre-merge checklist item
- Sprint/iteration retrospective workflows
- Code review requirements

Commands should provide context about where to save summaries and reference this skill for methodology.
