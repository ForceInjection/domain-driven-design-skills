---
name: prioritize-story-nodes
description: Use when user says "prioritize stories", "what should I work on next", "find next story", "review approved stories", "plan next feature" - generates deterministic priority list via script, then semantically analyzes for missed dependencies and creates implementation plan for the best candidate.
---

# Prioritize Story Nodes

Analyze eligible stories to select the best candidate for implementation.

**Database:** `.claude/data/story-tree.db`
**Plans:** `.claude/data/plans/`
**Priority Lists:** `.claude/data/priority-lists/`

## Phase 1: Generate Draft Priority List (Deterministic)

Run the prioritization script to generate an initial list:

```bash
python3 .claude/scripts/prioritize_stories.py --format markdown
```

This script:
- Filters out blocked, on-hold, and disposed stories
- Calculates complexity scores based on keywords and content length
- Extracts dependencies (story IDs) and prerequisites (technical requirements)
- Outputs a sorted priority list to `.claude/data/priority-lists/`

**Read the generated file** before proceeding to Phase 2.

## Phase 2: Semantic Dependency Analysis

Review the draft priority list and **for each of the top 10 stories**:

1. **Read the full story node** from the database (description, notes, success_criteria)
2. **Semantically analyze** for dependencies the script may have missed:
   - Does this story reference functionality from another story?
   - Does success criteria imply another story must be complete first?
   - Are there implicit technical prerequisites not captured?

3. **If missed dependencies found**, update the story node:

```python
python3 -c "
import sqlite3
conn = sqlite3.connect('.claude/data/story-tree.db')
conn.execute('''
    UPDATE story_nodes
    SET notes = COALESCE(notes || '\n', '') || '[Dependency discovered: STORY_ID - REASON]',
        updated_at = datetime('now')
    WHERE id = 'TARGET_STORY_ID'
''')
conn.commit()
conn.close()
print('Updated story TARGET_STORY_ID with discovered dependency')
"
```

4. **If story should be blocked**, set hold_reason:

```python
python3 -c "
import sqlite3
conn = sqlite3.connect('.claude/data/story-tree.db')
conn.execute('''
    UPDATE story_nodes
    SET hold_reason = 'blocked',
        human_review = 1,
        notes = COALESCE(notes || '\n', '') || '[Blocked by: BLOCKER_ID - REASON]',
        updated_at = datetime('now')
    WHERE id = 'TARGET_STORY_ID'
''')
conn.commit()
conn.close()
print('Blocked story TARGET_STORY_ID')
"
```

## Phase 3: Select Best Candidate

After semantic analysis, select the **highest-priority unblocked story** considering:

1. Stage priority: `ready` > `planned` > `approved`
2. Lowest complexity score
3. No unmet dependencies
4. Deepest node depth (more specific = better scoped)

## Phase 4: Create Implementation Plan

**Filename:** `.claude/data/plans/YYYY-MM-DD-[story-id]-[slug].md`

Plan must include:
- Story Context (ID, title, ancestors)
- Implementation Overview
- Prerequisites checklist
- Implementation Tasks (with file paths)
- Testing Plan
- Rollback considerations

## Phase 5: Update Stage

After plan is created:

```python
python3 -c "
import sqlite3
conn = sqlite3.connect('.claude/data/story-tree.db')
conn.execute('''
    UPDATE story_nodes
    SET stage = 'planned',
        notes = COALESCE(notes || '\n', '') || 'Plan: .claude/data/plans/PLAN_FILENAME',
        updated_at = datetime('now')
    WHERE id = 'STORY_ID'
''')
conn.commit()
conn.close()
print('Story STORY_ID advanced to planned stage')
"
```

## Phase 6: Output Report

Summarize:
- Stories analyzed count
- Dependencies discovered (list any updates made)
- Selected story with rationale
- Plan file location
- Recommended next steps

## Key Rules

- **ALWAYS** run the deterministic script first (Phase 1)
- Plan file MUST exist before changing stage to `planned`
- Only mark stories as blocked if dependencies are truly unmet
- Document any dependency updates you make for transparency
- Ask for clarification only if: multiple tied scores, ambiguous blocking, or no eligible stories
