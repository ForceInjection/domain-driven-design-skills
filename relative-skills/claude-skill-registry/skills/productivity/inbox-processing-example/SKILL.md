---
name: inbox-processing-example
description: EXAMPLE - Workflow for processing large Things3 inboxes using LLM-driven confidence matching and intelligent automation. This is a genericized example - create your own version in inbox-processing/ for personal use.
---

# Inbox Processing Example

**NOTE**: This is an example skill showing how to build an inbox processing workflow. The actual `inbox-processing` skill is gitignored as it contains personal workflow patterns. Copy this to `.claude/skills/inbox-processing/` and customize for your needs.

## Overview

Process large Things3 inboxes (100+ items) efficiently through batch analysis, confidence-based automation, and intelligent user interaction.

**Prerequisites:**
- Load `things3-productivity` skill for MCP tool patterns
- Configure `private-prefs/personal-taxonomy.json` with your work areas and tags
- Create `temp/inbox-processing/` folder for session state

**When to use**: Inbox has 100+ items requiring organization.

## Personal Organization Integration

The skill uses LLM-driven analysis with context from `personal-taxonomy.json`:
- **Work identification**: Your configured work tags and areas
- **Priority system**: Your 1-9 priority scale
- **Project patterns**: Your existing projects and content patterns
- **Semantic matching**: Based on meaning, not just keywords

## Core Workflow: Batch Processing

### Phase 1: Initialize & Analyze

**Step 1: Setup Session**
Create `temp/inbox-processing/` with tracking files:
```
session.md                    # Batch progress, statistics
match_results.json            # Decisions with confidence scores
pending_decisions.json        # Items awaiting approval
high_confidence_actions.json  # Auto-apply candidates (≥90%)
execution_log.md              # Complete action history
```

**Step 2: Load Inbox Batch**
```python
# First batch: 50 items, subsequent: 50-100 items
read_tasks(when="inbox", limit=50, include_notes=True)
```

**Step 3: Load System Inventory**
Cache once per session:
```python
list_areas()    # All areas with IDs and tags
list_projects() # All projects with metadata
list_tags()     # All tags including hierarchy
```

### Phase 2: Confidence-Based Analysis

**Step 4: Analyze Each Item**
For each inbox item, determine:
- **Area assignment** (90%+ confidence threshold)
- **Project assignment** (85%+ confidence threshold)
- **Tag additions** (based on content and context)
- **Reference detection** (notes without actionable tasks)

**Confidence Levels:**
- **90-100%**: Auto-apply safe (e.g., "Work: Fix bug" → area="Work")
- **80-89%**: Present for batch approval
- **Below 80%**: Skip, handle manually

### Phase 3: User Interaction

**Step 5: Present High-Confidence Batch**
Group by action type:

```markdown
### Area: Work (25 items, 90-100% confidence)

Auto-assign these 25 items to area="Work"?
- "Work: Fix login bug" (100%)
- "Dashboard review" (95%)
...

[Approve] [Review individually] [Skip]
```

**Step 6: Handle Medium-Confidence Items**
Present individually for 80-89% confidence:
```markdown
1. "Design review notes" (85%) → area="Work"?
   Notes: Contains work-related keywords
   [Yes] [No] [Different area]
```

### Phase 4: Execution

**Step 7: Execute Approved Actions**
Batch operations by type:
```python
# Set areas
edit_task(task_uuid="...", area="Work")

# Add tags
add_tags(task_uuids=[...], tags=["urgent"])

# Create projects
create_project(name="Q4 Roadmap", area="Work")
```

**Step 8: Handle Reference Items**
Items with notes but no actionable task:
```python
# Suggest migration to Notion
migrate_inbox_to_notion(block_id="your-block-id")
```

### Phase 5: Completion

**Step 9: Update Statistics**
Track in `session.md`:
```
Batch 1: 50 items processed
- 25 auto-assigned to areas
- 10 tagged
- 5 moved to projects
- 10 pending review

Remaining: 96 items
```

**Step 10: Next Batch**
If inbox > 0, repeat from Step 2 with larger batch size (up to 100).

## Pattern Learning

The skill improves through use:
- **Successful matches** reinforce confidence thresholds
- **User corrections** inform future suggestions
- **Project creation patterns** learned from history
- **Tag combinations** tracked for consistency

## Example Confidence Scoring

```markdown
### High Confidence (90-100%)

"Work: Fix dashboard bug" → area="Work"
- Explicit area mention (100%)
- Work tag keyword present
- Matches existing area pattern

### Medium Confidence (80-89%)

"Review team notes" → area="Work"?
- Work context implied (85%)
- No explicit area mention
- Could be personal or work

### Low Confidence (<80%)

"Call mom" → ???
- No clear work/personal indicators
- No matching patterns
- Requires manual classification
```

## Customization Guide

To create your own inbox processing skill:

1. **Copy this example:**
   ```bash
   cp -r .claude/skills/inbox-processing.example .claude/skills/inbox-processing
   ```

2. **Update references:**
   - Replace "Work" with your actual work area names
   - Add your specific project patterns
   - Customize confidence thresholds

3. **Configure personal-taxonomy.json:**
   ```json
   {
     "things3": {
       "work_classification": {
         "work_tag": "YOUR_WORK_TAG",
         "work_areas": ["Your Work Area"]
       }
     }
   }
   ```

4. **Test with small batches:**
   - Start with 10-20 items
   - Adjust confidence thresholds
   - Build pattern database

## Tips

- **Start conservative**: Use higher confidence thresholds (95%+) initially
- **Batch approvals**: Group similar actions for efficiency
- **Reference items**: Migrate notes to Notion early to reduce inbox clutter
- **Project discovery**: Use `list_projects=True` to avoid creating duplicates
- **Session breaks**: Process in 30-minute focused sessions

## Integration with Other Skills

- **things3-productivity**: Tool usage patterns and query strategies
- **notion-workflows**: Reference item migration patterns
- **productivity-integration**: Cross-system automation
