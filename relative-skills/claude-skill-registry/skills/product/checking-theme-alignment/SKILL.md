---
name: "Checking theme alignment"
description: "Validates that book chapters align with the core theme. Use when user says 'check theme alignment', 'does this fit the theme', 'verify alignment', or automatically after every 2 chapters are drafted."
---

# Checking Theme Alignment

Validates chapters against the book's theme to catch drift and maintain coherence.

## When to use this skill

**Automatic triggers:**
- After every 2 chapters are drafted
  - After chapters 2, 4, 6, 8, etc.

**Manual triggers:**
- User says "check theme alignment"
- User says "does chapter X fit the theme?"
- User says "are we still on track?"
- Before making major structural changes

## What this skill does

1. Reads the theme statement from `outline.md`
2. Reads completed chapters
3. Assesses each chapter's alignment
4. Generates alignment report
5. Recommends actions if issues found

## Prerequisites

**Must exist:**
- `outline.md` with theme statement
- At least one completed chapter in `/chapters/`

**If missing:**
```
I need outline.md and at least one chapter to check alignment.
Current status:
- Outline: [exists/missing]
- Chapters: [count]
```

## Alignment assessment scale

**Strong alignment:**
- Chapter clearly advances the theme
- Purpose statement from outline is fulfilled
- Connections to theme are explicit
- Reader can see why this chapter matters

**Adequate alignment:**
- Chapter supports theme but connection could be stronger
- Purpose is fulfilled but not emphasized
- Implicit rather than explicit connection
- Serves the book but feels somewhat tangential

**Weak alignment:**
- Chapter relates to theme but loosely
- Purpose statement not fully delivered
- Connection requires effort to see
- Feels like it could belong in a different book

**Misaligned:**
- Chapter doesn't serve the theme
- Goes in different direction
- Purpose doesn't connect to theme
- Would be better in a different book

## Process

### Step 1: Load theme

Read `outline.md` and extract:
- Theme statement
- Intended audience
- Transformation goal

### Step 2: Assess chapters

For each completed chapter:

1. **Read the chapter content**
2. **Check against theme:**
   - Does opening connect to theme?
   - Do key points advance the theme?
   - Does conclusion tie back to theme?
3. **Check against outline purpose:**
   - Is the stated purpose fulfilled?
   - Are key points from outline delivered?
4. **Rate alignment:** Strong / Adequate / Weak / Misaligned

### Step 3: Generate report

```markdown
=== THEME ALIGNMENT CHECK ===
Date: [current date]
Completed after: Chapter [X]

Theme Statement: [current theme]
Target Audience: [from outline]

## Chapters Assessed

### Chapter 1: [Title]
**Alignment: Strong**
- Opens with clear connection to theme
- All three key points from outline delivered
- Closing reinforces theme effectively

### Chapter 2: [Title]
**Alignment: Adequate**
- Purpose fulfilled but connection to theme is implicit
- Second key point feels tangential
- Consider strengthening theme reference in opening

[Continue for all chapters]

## Overall Assessment

[Summary: all aligned / minor drift / significant issues]

## Recommendations

[Based on findings - see examples below]

## Cross-chapter Flow

[Optional: note how chapters build on each other]
================================
```

### Step 4: Make recommendations

Based on findings:

**All chapters strongly aligned:**
```
All chapters strongly aligned with theme. Continue as planned.
```

**Minor alignment issues:**
```
Recommendation: Strengthen Chapter [X]
- Add explicit theme reference in opening paragraph
- Tie [specific point] back to theme in conclusion
- Otherwise well-aligned
```

**Significant misalignment:**
```
Recommendation: Chapter [X] needs revision
- Current focus: [what it's about]
- Theme: [what it should support]
- Suggested approach: [how to realign]

OR consider whether theme needs adjustment to accommodate this direction.
```

**Theme drift detected:**
```
Pattern detected: Chapters [X, Y, Z] are drifting toward [different focus]

Options:
1. Revise chapters to strengthen theme alignment
2. Adjust theme to: [suggested revised theme]
   - Impact: Would also affect chapters [list]
3. Restructure: Move/remove drifting chapters
```

## Automatic check timing

**After chapter 2:**
- First real assessment (need 2 chapters minimum for patterns)
- Check if both chapters serve theme
- Catch issues early

**After chapter 4:**
- Check chapters 3-4
- Note: Also review 1-2 if issues in 3-4
- Confirm theme holds across first third

**After chapter 6:**
- Check chapters 5-6
- Review overall flow if needed
- Mid-book alignment verification

**Continue every 2 chapters until complete**

## Examples

### Example 1: Strong alignment

```
=== THEME ALIGNMENT CHECK ===
Completed after: Chapter 4

Theme: "Effective delegation requires trust, clarity, and follow-through"

### Chapter 3: Choosing What to Delegate
Alignment: Strong
- Opens by connecting delegation choices to trust-building
- Clarity framework aligns perfectly with theme
- Examples demonstrate all three theme elements

### Chapter 4: The Delegation Conversation
Alignment: Strong
- Explicit theme reference in opening
- Breaks down "clarity" component from theme
- Sets up "follow-through" for next chapter

Overall: All chapters strongly aligned. Continue as planned.
```

### Example 2: Drift detected

```
=== THEME ALIGNMENT CHECK ===
Completed after: Chapter 6

Theme: "Leaders build high-performing teams through psychological safety"

### Chapter 5: Conflict Resolution Techniques
Alignment: Weak
- Focuses on tactics, not psychological safety
- No mention of team performance outcomes
- Could fit in any leadership book

### Chapter 6: Performance Reviews That Work
Alignment: Weak
- Good content but disconnected from safety theme
- Reads like HR process guide
- Missing link to psychological safety

Overall: Significant drift. Chapters 5-6 feel generic rather than 
theme-specific.

Recommendation:
1. Revise Chapter 5: Frame conflict through safety lens
   - "How unsafe conflict damages teams"
   - "Resolution approaches that rebuild safety"
   
2. Revise Chapter 6: Connect reviews to safety
   - "Why traditional reviews destroy safety"
   - "Feedback approaches that strengthen safety"

OR consider broader theme: "Leaders build teams through trust and 
clear systems" (would accommodate these chapters better)
```

### Example 3: Theme adjustment needed

```
=== THEME ALIGNMENT CHECK ===
Completed after: Chapter 8

Theme: "Remote work requires intentional communication practices"

Pattern: Chapters 6-8 increasingly focus on tools and technology, 
not communication practices.

Current chapters:
- Ch 6: Choosing the right tools (tech-focused)
- Ch 7: Setting up your remote workspace (tech-focused)
- Ch 8: Cybersecurity for remote teams (tech-focused)

Original chapters 1-5 were communication-focused, aligned well with theme.

Recommendation: Theme adjustment
- Current: "Remote work requires intentional communication practices"
- Suggested: "Remote work succeeds through thoughtful communication 
  and infrastructure"
- This accommodates both communication AND tools/tech focus
- Would require minor revisions to chapters 1-5 to mention infrastructure

Alternative: Remove/move chapters 6-8 to appendix, stay focused on 
communication practices.
```

## Edge cases

**Only one chapter complete:**
```
I need at least 2 chapters to assess alignment patterns. 
Complete one more chapter and I'll run the check.
```

**Theme statement missing from outline:**
```
I don't see a theme statement in outline.md. 
Every book needs a clear theme to check alignment against.

Should I help you develop a theme based on the chapters written so far?
```

**Chapters exist but outline shows different status:**
```
Note: outline.md shows chapters [X, Y] as "not started" but files exist.
Should I:
1. Assess chapters that exist (regardless of status)
2. Update outline statuses first
```

**User disagrees with assessment:**
Alignment is subjective. If user says "Actually, I think chapter 5 is strongly aligned," accept it:
```
Understood. I'll note chapter 5 as strongly aligned. 
The assessment is to help catch issues, but you know your book best.
```

## Quality standards

Good alignment reports:
- ✓ Reference specific content from chapters
- ✓ Explain WHY alignment is strong/weak
- ✓ Give actionable recommendations
- ✓ Consider whether theme or chapters should change
- ✓ Look at chapter flow, not just individual chapters

Poor alignment reports:
- ✗ Vague: "Chapter seems off"
- ✗ No examples: "Not aligned"
- ✗ No recommendations
- ✗ Only blame chapters (theme might be wrong)
- ✗ Miss patterns across multiple chapters

## Collaboration with other skills

**Before this skill:**
- `draft-chapter` creates chapters to assess
- `revise-chapter` may have changed chapters

**After this skill:**
- `revise-chapter` addresses alignment issues
- `outline-book` may need to revise theme if adjustment recommended
- `draft-chapter` continues with better awareness

## Files read

- `outline.md` - Theme and purposes
- `/chapters/*.md` - All completed chapters

## Files created

None. This skill only generates reports (doesn't modify files).

Report can be:
- Displayed to user
- Optionally saved as `/alignment-reports/report-[date].md` if user wants history

## Best practices

**Do:**
- Be specific about alignment issues
- Suggest concrete fixes
- Consider theme adjustment as valid option
- Look for patterns across chapters
- Remember theme serves the book, not vice versa

**Don't:**
- Just say "aligned" or "not aligned" without explanation
- Assume theme is always right
- Miss the big picture by over-focusing on individual chapters
- Give feedback without actionable recommendations
- Be harsh - alignment issues are normal and fixable
