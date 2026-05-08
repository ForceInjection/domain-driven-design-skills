---
name: "Tracking research gaps"
description: "Manages research gaps and needed information. Use when user says 'show research gaps', 'what research do I need', 'track research needs', or after drafting chapters that contain [RESEARCH: ...] markers."
---

# Tracking Research Gaps

Extracts, organizes, and tracks research needs throughout the book writing process.

## When to use this skill

**Manual triggers:**
- User says "show research gaps"
- User says "what research do I need?"
- User says "track research" or "update research gaps"

**Automatic trigger:**
- After drafting a chapter that contains `[RESEARCH: ...]` markers

## What this skill does

1. Scans chapter files for `[RESEARCH: ...]` markers
2. Extracts gap descriptions and severity
3. Updates or creates `research-gaps.md`
4. Organizes by priority (HIGH/MEDIUM/LOW)
5. Tracks which chapters need each piece of research

## Prerequisites

**Needs:**
- At least one chapter file in `/chapters/`

**If no chapters:**
```
No chapters have been drafted yet. 
Research gaps are tracked as you write - they'll appear when chapters 
contain [RESEARCH: ...] markers.
```

## Research marker format

Chapters should contain inline markers like:
```
[RESEARCH: description | severity: HIGH/MEDIUM/LOW]
```

**Examples:**
```
[RESEARCH: Need 2022-2024 statistics on remote work adoption | severity: HIGH]
[RESEARCH: Find case study of B2B company using this framework | severity: MEDIUM]
[RESEARCH: Verify this framework name and attribution | severity: LOW]
```

## Severity levels

**HIGH - Affects credibility:**
- Statistics or data claims without sources
- Factual statements that need verification
- Critical examples that don't exist yet
- Information that readers will question if missing

**MEDIUM - Strengthens but not critical:**
- Additional examples to support points
- Case studies to illustrate concepts
- Supporting data that reinforces arguments
- Contextual information that adds depth

**LOW - Nice-to-have polish:**
- Verification of names/attributions
- Optional additional sources
- Extra examples for variety
- Background details

## Process

### Step 1: Scan for markers

Read all chapter files in `/chapters/` directory:

```bash
grep -r "\[RESEARCH:" chapters/
```

Extract:
- Full description
- Severity level
- Which chapter contains it

### Step 2: Organize gaps

Group by severity, then by chapter.

### Step 3: Create or update research-gaps.md

```markdown
# Research Gaps

Last updated: [date]
Total gaps: [count] (High: [X], Medium: [Y], Low: [Z])

## High Priority
Critical gaps that significantly impact credibility or completeness.

### [Short descriptive title]
- **Details**: [Full description from marker]
- **Needed for**: Chapter [X]
- **Severity**: HIGH
- **Suggested direction**: [Where to look, what questions to answer]
- **Status**: open

[Repeat for all high priority gaps]

## Medium Priority
Gaps that would strengthen content but aren't critical.

### [Title]
- **Details**: [description]
- **Needed for**: Chapter [X], Chapter [Y]
- **Severity**: MEDIUM
- **Suggested direction**: [research direction]
- **Status**: open

[Repeat for all medium priority gaps]

## Low Priority
Nice-to-have additions or verifications.

### [Title]
- **Details**: [description]
- **Needed for**: Chapter [X]
- **Severity**: LOW
- **Suggested direction**: [direction]
- **Status**: open

[Repeat for all low priority gaps]

## Resolved
Completed research moved here for reference.

### [Title] - Resolved [date]
- **Details**: [original description]
- **Resolution**: [What was found/decided]
- **Applied to**: Chapter [X]
```

### Step 4: Add suggested directions

For each gap, suggest where to look:

**Statistics/data:**
```
Suggested direction: Check industry reports from Gartner, McKinsey, 
or academic studies on remote work trends. Look for 2022-2024 timeframe.
```

**Case studies:**
```
Suggested direction: Search business publications (HBR, Inc., Fast Company) 
or company blogs for implementation stories. Focus on B2B SaaS companies.
```

**Verification:**
```
Suggested direction: Check original source - likely from [author's name] 
work on [topic]. Verify spelling and publication.
```

**Examples:**
```
Suggested direction: Draw from user's experience, or interview colleagues 
who've faced this situation. Real examples beat hypotheticals.
```

### Step 5: Identify multi-chapter gaps

If same research appears in multiple chapters:
```
- **Needed for**: Chapter 3, Chapter 5, Chapter 7
```

This indicates important cross-cutting information.

### Step 6: Git commit

```bash
git add research-gaps.md
git commit -m "Update research gaps - [X] new gaps from Chapter [Y]"
```

## Examples

### Example 1: After drafting chapter with gaps

**Chapter 3 contains:**
```
Recent studies show [RESEARCH: Need data on manager time spent in meetings 
2022-2024 | severity: HIGH] that managers spend excessive time in meetings.

One company [RESEARCH: Find case study of company that reduced meeting 
time by 50% | severity: MEDIUM] successfully cut meeting time in half.
```

**Generated research-gaps.md:**
```markdown
# Research Gaps

Last updated: 2025-10-18
Total gaps: 2 (High: 1, Medium: 1, Low: 0)

## High Priority

### Manager meeting time statistics
- **Details**: Need data on manager time spent in meetings 2022-2024
- **Needed for**: Chapter 3
- **Severity**: HIGH
- **Suggested direction**: Check Harvard Business Review, Atlassian 
  research on meeting culture, or Microsoft Work Trend Index for recent 
  data on manager time allocation
- **Status**: open

## Medium Priority

### Meeting reduction case study
- **Details**: Find case study of company that reduced meeting time by 50%
- **Needed for**: Chapter 3
- **Severity**: MEDIUM
- **Suggested direction**: Search business publications for companies 
  that implemented meeting-free days or restructured meetings. Shopify's 
  2023 meeting reset might be relevant.
- **Status**: open
```

### Example 2: Showing gaps to user

**User:** "Show research gaps"

**Response:**
```
Current research gaps (5 total):

HIGH PRIORITY (2):
1. Manager meeting time statistics (Chapter 3)
   Need: 2022-2024 data on manager time in meetings
   
2. Remote work adoption rates (Chapter 1)
   Need: Statistics on remote work growth 2020-2024

MEDIUM PRIORITY (2):
3. Meeting reduction case study (Chapter 3)
4. Async communication tool comparison (Chapter 5)

LOW PRIORITY (1):
5. Verify Peter Drucker quote attribution (Chapter 2)

Full details in research-gaps.md
```

### Example 3: Marking gap as resolved

**User:** "Mark the meeting time statistics gap as resolved. I found data showing managers spend 23 hours/week in meetings according to a 2024 Harvard Business Review study."

**Response:**
Update research-gaps.md:
```markdown
## Resolved

### Manager meeting time statistics - Resolved 2025-10-18
- **Details**: Need data on manager time spent in meetings 2022-2024
- **Resolution**: Found HBR 2024 study: managers spend 23 hours/week 
  in meetings. Source: [citation details]
- **Applied to**: Chapter 3
```

Then:
```bash
git add research-gaps.md
git commit -m "Resolved: Manager meeting time statistics"
```

## User commands

**View gaps:**
- "Show research gaps"
- "What research do I need?"
- "List high priority gaps"

**Update gaps:**
- "Track research needs" (scan chapters)
- "Update research gaps" (re-scan)

**Mark resolved:**
- "Mark [gap description] as resolved"
- "This research addresses [gap]: [information]"

**Add manual gap:**
- "Add research gap: [description] for chapter X, severity [HIGH/MEDIUM/LOW]"

## Edge cases

**No research markers found:**
```
No [RESEARCH: ...] markers found in chapters. 
Either research needs haven't been flagged yet, or all necessary 
information is already available.
```

**Marker missing severity:**
```
Found marker without severity in Chapter [X]:
[RESEARCH: description]

Assuming MEDIUM severity. Please specify HIGH/MEDIUM/LOW in markers.
```

**Gap description is vague:**
Flag it:
```
Note: Gap in Chapter [X] is vague: "Need more information"
Consider being more specific about what information is needed.
```

**Duplicate gaps:**
If same gap appears in multiple chapters:
```
Note: This gap appears in Chapters [X, Y, Z]:
[description]

Consider this a cross-cutting research need - resolving it will benefit 
multiple chapters.
```

**User provides research but gap unclear:**
```
I can add this information, but which gap does it address?
Current gaps: [list]
```

## Quality standards

Good research tracking:
- ✓ Specific descriptions of what's needed
- ✓ Appropriate severity levels
- ✓ Actionable suggested directions
- ✓ Clear chapter references
- ✓ Status tracking (open/in progress/resolved)

Poor research tracking:
- ✗ Vague: "Need more info"
- ✗ Wrong severity: marking everything HIGH
- ✗ No direction: just lists gaps without guidance
- ✗ Missing chapter references
- ✗ Never marking things resolved

## Collaboration with other skills

**Before this skill:**
- `draft-chapter` creates chapters with research markers
- `revise-chapter` might add new gaps

**After this skill:**
- User conducts research
- `revise-chapter` incorporates findings and removes markers
- This skill re-scans to update gaps

## Files read

- `/chapters/*.md` - All chapter files (to find markers)

## Files created/modified

- `research-gaps.md` - Master research tracking file

## Best practices

**Do:**
- Be specific in gap descriptions
- Suggest where to look for information
- Prioritize honestly (not everything is HIGH)
- Update when gaps are resolved
- Track cross-cutting needs that affect multiple chapters

**Don't:**
- Leave gaps vague
- Over-prioritize (if everything is HIGH, nothing is)
- Let resolved gaps clutter the active list
- Forget to note which chapters need the research
- Block writing on gaps - draft first, research later

## Integration with writing workflow

**Typical flow:**
1. Draft chapter (markers added inline)
2. → Track research gaps (this skill)
3. User conducts research
4. Revise chapter (incorporate findings)
5. → Track research gaps (markers removed, gaps marked resolved)

**Research doesn't block writing:**
- Draft with gaps is better than no draft
- Gaps get addressed in revision
- Some gaps resolve themselves (you realize you don't need it)
- Priority helps focus on what truly matters
