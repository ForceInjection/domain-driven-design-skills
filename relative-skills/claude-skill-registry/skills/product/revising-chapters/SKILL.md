---
name: "Revising chapters"
description: "Revises book chapters based on feedback. Use when user says 'revise chapter X', 'improve chapter [number]', 'rewrite the opening of chapter X', 'make chapter X more [adjective]', or provides feedback on a chapter."
---

# Revising Chapters

Makes targeted improvements to chapters based on user feedback.

## When to use this skill

- User says "revise chapter X"
- User provides feedback: "Chapter 3 needs more examples"
- User requests changes: "Make chapter 2 more conversational"
- User wants rewrites: "Rewrite the opening of chapter 5"
- User mentions length: "Expand chapter 4"

## What this skill does

1. Loads the current chapter
2. Reads outline for context (theme, purpose)
3. Reads voice-profile for consistency
4. Applies requested changes
5. Git commits with descriptive message

## Prerequisites

**Must exist:**
- The chapter file being revised
- `outline.md` (for theme/context)

**If chapter doesn't exist:**
```
I don't see /chapters/[number]-[title].md. 
Available chapters: [list existing chapter files]

Which chapter did you mean?
```

## Revision types

### Full rewrite
**Trigger:** "Revise chapter 3 based on this feedback: [notes]"

**Process:**
1. Read current chapter
2. Read all feedback/notes
3. Understand what needs to change
4. Rewrite chapter incorporating feedback
5. Maintain theme alignment and voice

### Targeted fix
**Trigger:** "Strengthen the opening of chapter 5"

**Process:**
1. Read current chapter
2. Focus only on specified section
3. Improve that section
4. Keep rest of chapter unchanged

### Tone adjustment
**Trigger:** "Make chapter 2 more conversational"

**Process:**
1. Read current chapter + voice-profile
2. Adjust formality/style throughout
3. Keep content/structure same
4. Make it match requested tone

### Content addition
**Trigger:** "Add more examples to chapter 4"

**Process:**
1. Read current chapter
2. Identify places needing examples
3. Add 2-3 concrete examples
4. Maintain flow and transitions

### Length adjustment
**Trigger:** "Expand chapter 6" or "Condense chapter 2"

**Process:**
1. Read current chapter
2. Expand: Add detail, examples, explanation
3. Condense: Remove redundancy, tighten prose
4. Maintain key points and theme alignment

## Process

### Step 1: Understand the request

Clarify if needed:
- **Vague:** "Revise chapter 3" → Ask: "What would you like me to change?"
- **Clear:** "Add statistics to support the claims in chapter 3" → Proceed

### Step 2: Load context

Read:
1. Current chapter file
2. `outline.md` (theme, chapter purpose)
3. `voice-profile.md` if exists
4. Adjacent chapters if needed for continuity

### Step 3: Apply changes

Make the requested changes while maintaining:
- Theme alignment
- Voice consistency
- Key points from outline
- Natural flow

If change would hurt theme alignment, flag it:
```
Note: Making chapter 4 entirely about [X] would weaken its connection to 
the theme of [Y]. Consider: [alternative approach]
```

### Step 4: Handle new research gaps

If revision introduces new gaps, mark them:
```
[RESEARCH: Need case study showing X | severity: MEDIUM]
```

### Step 5: Git commit

Commit message should describe what changed:

```bash
git add chapters/[number]-[title].md
git commit -m "Revision: Chapter [number] - [brief description]"
```

**Good commit messages:**
- `"Revision: Chapter 3 - Added examples and data"`
- `"Revision: Chapter 5 - Rewrote opening for stronger hook"`
- `"Revision: Chapter 2 - Made tone more conversational"`

**Bad commit messages:**
- `"Revision: Chapter 3"` (not specific)
- `"Updates"` (too vague)
- `"Fixed stuff"` (unhelpful)

## Examples

### Example 1: Feedback-based revision

**User:** "Revise chapter 2. The feedback from my editor is: needs more concrete examples, and the transition to section 3 is abrupt."

**Process:**
1. Read chapter 2
2. Identify where examples would help
3. Add 2-3 concrete examples
4. Smooth transition to section 3
5. Git commit: `"Revision: Chapter 2 - Added examples and improved transition"`

### Example 2: Tone adjustment

**User:** "Make chapter 4 more data-driven. Right now it's too anecdotal."

**Process:**
1. Read chapter 4
2. Identify anecdotal sections
3. Replace some stories with statistics/studies
4. Keep some anecdotes for balance
5. Git commit: `"Revision: Chapter 4 - Shifted to more data-driven approach"`

### Example 3: Length expansion

**User:** "Chapter 1 is only 800 words. Expand it to hit closer to 1,500."

**Process:**
1. Read chapter 1 + outline to see key points
2. Add depth: more explanation, examples, or setup
3. Don't pad - add substance
4. Check: does it feel natural or forced?
5. Git commit: `"Revision: Chapter 1 - Expanded with additional depth"`

### Example 4: Structural change

**User:** "Move the framework explanation from chapter 3 to chapter 2, and adjust both chapters accordingly."

**Process:**
This affects multiple chapters:
1. Extract framework section from chapter 3
2. Integrate into chapter 2 (find best placement)
3. Adjust chapter 3 to flow without that section
4. Update transitions in both
5. Git commit BOTH chapters:
```bash
git add chapters/02-*.md chapters/03-*.md
git commit -m "Revision: Chapters 2-3 - Moved framework explanation to chapter 2"
```

## Edge cases

**Requested change conflicts with theme:**
```
Making this change would weaken chapter [X]'s alignment with the theme.

Current theme: [statement]
Requested change: [description]
Conflict: [explanation]

Options:
1. Modify the change to maintain alignment: [suggestion]
2. Adjust the theme (requires reviewing all chapters)
3. Keep chapter as-is

What would you prefer?
```

**Revision requires information not available:**
```
To make this revision well, I'd need:
- [Specific info needed]
- [Other info needed]

Should I:
1. Make the revision with placeholder [RESEARCH: ...] markers
2. Wait until you provide this information
```

**Unclear which chapter:**
```
Which chapter should I revise?
Current chapters: [list from /chapters/ directory]
```

**Multiple conflicting feedback points:**
```
I see two pieces of feedback that conflict:
1. [Feedback A]
2. [Feedback B]

Which should take priority, or how should I balance them?
```

## Quality standards

Revised chapters should:
- ✓ Address the specific feedback/request
- ✓ Maintain theme alignment
- ✓ Match voice profile
- ✓ Keep key points from outline
- ✓ Have natural flow and transitions
- ✓ Not introduce new problems

## Collaboration with other skills

**After revising:**
- Use `check-theme-alignment` if revision was substantial
- Use `track-research-gaps` if new gaps were added
- Consider revising adjacent chapters if flow was affected

**Before revising:**
- User might have used `check-theme-alignment` to identify issues
- Revision addresses alignment problems flagged

## Files modified

- `/chapters/[number]-[title].md` - The revised chapter
- Sometimes multiple chapter files if structural changes

## Best practices

**Do:**
- Ask for clarification if request is vague
- Flag when changes would hurt alignment
- Make substantive improvements, not just word count padding
- Maintain consistency with voice profile
- Test whether revised section flows naturally

**Don't:**
- Make changes you're not asked to make
- Sacrifice theme alignment for other goals
- Add fluff to hit word counts
- Change voice significantly unless requested
- Revise more chapters than requested without asking
