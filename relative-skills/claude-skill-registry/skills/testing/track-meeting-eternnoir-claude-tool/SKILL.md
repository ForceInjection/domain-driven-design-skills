---
name: track-meeting
description: Create and manage structured meeting notes with automatic action item extraction and governance integration. Use when user mentions "meeting notes", "record meeting", "create meeting", "會議記錄", "standup", "retrospective", "planning", or any meeting-related keywords.
---

# Track Meeting Skill

## When to use this Skill

Activate when the user:
- Mentions creating or recording meeting notes
- Uses keywords: "meeting", "standup", "retrospective", "planning", "review", "會議"
- Wants to document a team discussion
- Needs to track meeting action items
- References specific meeting types (daily standup, sprint planning, etc.)

## Workflow

### Phase 1: Context Discovery

**Objective**: Understand the project context and meeting format requirements.

**Steps**:

1. **Locate project RULE.md**:
   ```bash
   # Check current directory
   ls RULE.md
   # If not found, check parent directories
   ls ../RULE.md
   ls ../../RULE.md
   ```

2. **Read RULE.md** using `Read` tool:
   - Extract `methodology` field (determines meeting types)
   - Find `Document Templates > Meeting Notes Format` section
   - Note `file_naming_convention` pattern
   - Check `meetings/` directory structure
   - Read `Auto Workflows > When Claude creates meeting notes` section

3. **Determine meeting types available** based on methodology:
   - **Scrum**: daily-standups, sprint-planning, sprint-reviews, retrospectives, general
   - **Kanban**: board-reviews, planning, general
   - **Waterfall**: phase-reviews, status-updates, general
   - **Agile/Hybrid**: planning, reviews, general

4. **Check existing meetings directory**:
   ```bash
   ls -la meetings/
   ```
   Understand the current structure and recent meetings.

5. **Read meetings/README.md** if exists:
   - Understand current meeting index
   - Note recent meetings for context

**Example**:
```
Found RULE.md:
- Methodology: Scrum (2-week sprints)
- Meeting types: daily-standups, sprint-planning, sprint-reviews, retrospectives
- Format: Structured with YAML frontmatter
- Naming: Date-prefixed (YYYY-MM-DD_meeting-name.md)
- Directory: meetings/{type}/
```

### Phase 2: Gather Meeting Details

**Objective**: Collect all necessary information about the meeting.

**Steps**:

1. **Extract from user message** (if provided):
   - Meeting type (standup, planning, etc.)
   - Date (today if not specified)
   - Meeting title or topic

2. **Prompt for missing information**:

   **Meeting type** (if not clear):
   ```
   What type of meeting is this?
   [Present options based on RULE.md methodology]
   - Daily Standup
   - Sprint Planning
   - Sprint Review
   - Retrospective
   - General/Other
   ```

   **Meeting title** (if not provided):
   ```
   What's the meeting title?
   Example: "Sprint 5 Planning" or "Q4 Roadmap Discussion"
   ```

   **Date** (if not provided):
   ```
   Meeting date? (Press Enter for today: YYYY-MM-DD)
   ```

   **Attendees**:
   ```
   Who attended? (You can list names or reference team roles from RULE.md)
   Example: "@alice @bob @carol" or "Whole dev team"
   ```

   **Duration** (optional):
   ```
   How long was the meeting? (optional, in minutes)
   ```

3. **Prepare meeting metadata**:
   - Generate filename per RULE.md convention
   - Determine target directory (e.g., `meetings/sprint-planning/`)
   - Extract current date if not specified
   - Default duration if not provided

**Example**:
```
Gathered:
- Type: Sprint Planning
- Title: "Sprint 5 Planning"
- Date: 2025-11-13
- Attendees: Alice (PO), Bob (SM), Carol, David, Eve, Frank (devs)
- Duration: 90 minutes
- Filename: 2025-11-13_sprint-5-planning.md
- Target: meetings/sprint-planning/
```

### Phase 3: Create Meeting Structure

**Objective**: Generate the meeting note with proper template.

**Steps**:

1. **Read template from RULE.md**:
   Extract the exact format from `Document Templates > Meeting Notes Format`.

2. **Generate meeting document** following template:

   **For Structured format (most common)**:
   ```markdown
   ---
   title: [Meeting Title]
   type: [meeting-type]
   date: YYYY-MM-DD
   attendees:
     - Name 1
     - Name 2
   duration_minutes: [number]
   related_sprint: [sprint number or "N/A"]
   related_milestone: [milestone or "N/A"]
   ---

   # [Meeting Title]

   **Date**: YYYY-MM-DD
   **Type**: [Type]
   **Duration**: [X] minutes

   ## Attendees
   - Name 1
   - Name 2

   ## Agenda
   [To be filled or pre-populated if provided]

   ## Discussion
   [Meeting notes and key points]

   ## Action Items
   [Will be extracted or added]

   ## Decisions
   [Key decisions made during the meeting]

   ## Next Steps
   [What happens next]

   ---
   *Created by ProjectMaster track-meeting Skill*
   ```

   **For Simple format**:
   ```markdown
   # [Meeting Title]

   **Date**: YYYY-MM-DD
   **Attendees**: Names

   ## Notes
   [Content]

   ## Action Items
   - [ ] Item 1
   - [ ] Item 2

   ## Decisions
   [Decisions]
   ```

   **For Table format**:
   ```markdown
   # [Meeting Title]

   | Field | Value |
   |-------|-------|
   | Date | YYYY-MM-DD |
   | Type | [Type] |
   | Attendees | Names |
   | Duration | X mins |

   ## Discussion Points

   | Topic | Notes | Owner |
   |-------|-------|-------|
   | [Topic 1] | [Notes] | @name |

   ## Action Items

   | Task | Owner | Due Date | Status |
   |------|-------|----------|--------|
   | [Task] | @name | YYYY-MM-DD | [ ] |
   ```

3. **Determine content source**:

   **If user provides content directly**:
   - Fill template with provided information
   - Parse for action items
   - Extract decisions

   **If creating empty template**:
   - Leave sections as prompts
   - User will fill in later

   **If user provides partial information**:
   - Fill what's available
   - Mark sections for completion: `[To be filled]`

### Phase 4: Action Item Extraction

**Objective**: Automatically identify and format action items.

**Steps**:

1. **Scan user-provided content** for action items:
   - Lines starting with "TODO", "Action:", "[ ]", "-[ ]"
   - Phrases like "needs to", "should", "must", "will [do]"
   - @mentions indicating assignments
   - Date mentions indicating deadlines

2. **Extract action items**:
   ```
   Pattern detection:
   - "Bob will update the database schema" → @bob: Update database schema
   - "TODO: Review PR #123" → Review PR #123
   - "Alice needs to finalize designs by Friday" → @alice: Finalize designs - due: [next Friday]
   ```

3. **Format as task list**:
   ```markdown
   ## Action Items
   - [ ] [Task description] - @[owner] - due: YYYY-MM-DD
   - [ ] [Task description] - @[owner] - due: YYYY-MM-DD
   ```

   **If no owner specified**: Leave as `- [ ] [Task]`
   **If no due date**: Omit due date or use "TBD"

4. **Ask user to confirm/modify** action items:
   ```
   I've extracted these action items:
   1. @bob: Update database schema - due: 2025-11-20
   2. @alice: Finalize designs - due: 2025-11-15
   3. Review PR #123 - no owner assigned

   Are these correct? Any additions or changes?
   ```

5. **Update based on feedback**.

### Phase 5: Cross-Reference Linking

**Objective**: Link meeting to related project artifacts.

**Steps**:

1. **Identify related items** from meeting content:
   - Sprint numbers (e.g., "Sprint 5")
   - Milestone names
   - Issue numbers (#123)
   - Document references
   - Previous meeting references

2. **Check if items exist**:
   ```bash
   # For sprint reference
   ls sprints/sprint-05/
   # For milestone
   grep "milestone-name" milestones.yaml
   # For previous meetings
   ls meetings/*/YYYY-MM-DD*.md
   ```

3. **Add links to metadata**:
   ```yaml
   ---
   related_sprint: sprint-05
   related_milestone: beta-release
   related_issues: [123, 456]
   related_docs: [docs/architecture.md]
   related_meetings: [meetings/sprint-planning/2025-11-06_sprint-4-planning.md]
   ---
   ```

4. **Add links in content** (if appropriate):
   ```markdown
   ## Context
   This meeting is for [Sprint 5](../../sprints/sprint-05/sprint-plan.md) planning.

   Related to [Beta Release](../../milestones.yaml#beta-release) milestone.

   Follow-up from [previous retrospective](../retrospectives/2025-11-06_sprint-4-retro.md).
   ```

### Phase 6: Create and Save Meeting Note

**Objective**: Write the meeting note to the correct location.

**Steps**:

1. **Determine full file path**:
   ```
   meetings/[meeting-type]/[filename].md
   Example: meetings/sprint-planning/2025-11-13_sprint-5-planning.md
   ```

2. **Ensure target directory exists**:
   ```bash
   mkdir -p meetings/[meeting-type]
   ```

3. **Write file** using `Write` tool:
   - Use complete path
   - Include all generated content
   - Ensure proper formatting

4. **Verify creation**:
   ```bash
   ls -la meetings/[meeting-type]/[filename].md
   ```

**Example output**:
```
✅ Created: meetings/sprint-planning/2025-11-13_sprint-5-planning.md
```

### Phase 7: Governance Update

**Objective**: Maintain README.md indexes per governance protocol.

**Steps**:

1. **Update meetings/README.md**:

   Read current content:
   ```bash
   Read meetings/README.md
   ```

   Add new meeting to index:
   ```markdown
   ## Recent Meetings

   ### Sprint Planning
   - [2025-11-13: Sprint 5 Planning](sprint-planning/2025-11-13_sprint-5-planning.md) - Planned authentication features (Last updated: 2025-11-13)
   - [2025-10-30: Sprint 4 Planning](sprint-planning/2025-10-30_sprint-4-planning.md) - ... (Last updated: 2025-10-30)

   [Keep sorted by date, most recent first]
   ```

   Update last modified date:
   ```markdown
   ---
   Last updated: 2025-11-13
   ```

2. **Update meetings/[type]/README.md** (if exists):

   Add to category-specific index:
   ```markdown
   # Sprint Planning Meetings

   ## Meetings

   - [2025-11-13: Sprint 5 Planning](2025-11-13_sprint-5-planning.md) - Description
   - [Previous meetings...]

   ---
   Last updated: 2025-11-13
   ```

3. **Update project root README.md**:

   Add to Recent Activity:
   ```markdown
   ## Recent Activity

   - 2025-11-13: Sprint 5 Planning meeting notes added
   - [Previous activities...]
   ```

   Update last modified:
   ```markdown
   ---
   Last updated: 2025-11-13
   ```

4. **Execute custom workflows** from RULE.md:

   Read `Auto Workflows > When Claude creates meeting notes`:
   ```markdown
   ## When Claude creates meeting notes:
   1. Extract all action items with @mentions
   2. Update team member task lists
   3. Link to related user stories if mentioned
   4. Add to README.md meeting index
   5. [Custom step specific to this project]
   ```

   Execute each specified step.

### Phase 8: Report

**Objective**: Confirm completion and guide next steps.

**Report format**:

```
✅ Meeting Notes Created Successfully!

📄 File: meetings/[type]/[filename].md
📅 Date: YYYY-MM-DD
👥 Attendees: [count] people
⏱️  Duration: [X] minutes

📋 Action Items: [count]
[List action items with owners]

🔗 Linked to:
- Sprint [X]
- Milestone: [name]
- Issues: #[numbers]

📚 Updated governance:
✓ meetings/README.md
✓ meetings/[type]/README.md
✓ Project README.md

💡 Next steps:
- Review action items with team
- Track action item completion
- Link to sprint/milestone if not already done

[If action items with owners exist:]
Reminder to notify:
- @[owner1] about [task]
- @[owner2] about [task]

[If custom workflows were executed:]
🤖 Executed custom workflows from RULE.md:
- [Workflow description]
```

## Special Cases

### Case 1: Quick standup notes

If user provides brief standup update:

```
User: "Today's standup: Everyone on track, Bob blocked on API issue, Alice will help"
```

**Response**:
1. Detect it's a standup (keyword "standup")
2. Create minimal standup format:
   ```markdown
   ---
   title: Daily Standup
   type: standup
   date: 2025-11-13
   ---

   # Daily Standup - 2025-11-13

   ## Updates
   - Team on track
   - Bob: Blocked on API issue
   - Alice: Will assist Bob

   ## Action Items
   - [ ] Alice: Help Bob with API issue
   ```

3. Save with date-based filename: `2025-11-13_standup.md`
4. Update governance
5. Report: "Standup notes recorded. Alice assigned to help Bob."

### Case 2: Retrospective with structured feedback

For retrospectives, use special format:

```markdown
# Sprint [X] Retrospective

## What Went Well 🎉
- Item 1
- Item 2

## What Could Be Improved 🔧
- Item 1
- Item 2

## Action Items for Next Sprint
- [ ] Action 1 - @owner
- [ ] Action 2 - @owner

## Appreciation 💙
- Shoutout to @person for [accomplishment]

## Metrics
- Velocity: [X] points
- Completed: [X]/[Y] stories
- Sprint goal: [Met/Partially Met/Not Met]
```

### Case 3: Meeting notes from transcript

If user provides meeting transcript or long notes:

1. **Parse content** to extract:
   - Speakers and what they said
   - Key decisions
   - Action items (look for commitments, assignments)
   - Questions and answers

2. **Structure into sections**:
   - Discussion (organized by topic if possible)
   - Decisions (extract conclusions)
   - Action Items (extract commitments)

3. **Confirm with user**:
   "I've structured the transcript. Here are the key points and action items I extracted. Please review..."

### Case 4: Meeting series

If user is creating recurring meeting notes:

1. **Detect series** (e.g., "weekly standup", "daily standup"):
   - Check for existing notes with similar titles
   - Note pattern in governance

2. **Use consistent naming**:
   - Daily standups: `YYYY-MM-DD_standup.md`
   - Weekly meetings: `YYYY-MM-DD_weekly-sync.md`

3. **Link to previous**:
   ```markdown
   ## Previous Meeting
   [Last week's sync](2025-11-06_weekly-sync.md)

   ## Follow-up on Previous Action Items
   - [X] Item from last week - completed
   - [ ] Item from last week - in progress
   ```

### Case 5: Emergency or incident meetings

For urgent meetings about incidents:

1. **Use incident template** (if defined in RULE.md):
   ```markdown
   ---
   title: [Incident Title]
   type: incident
   severity: [high|critical]
   date: YYYY-MM-DD HH:MM
   ---

   # Incident: [Title]

   ## Timeline
   - HH:MM - Incident detected
   - HH:MM - Team notified
   - HH:MM - Root cause identified
   - HH:MM - Fix deployed
   - HH:MM - Incident resolved

   ## Impact
   [Description of impact]

   ## Root Cause
   [What caused the incident]

   ## Resolution
   [How it was fixed]

   ## Action Items
   - [ ] Prevent recurrence: [task]
   - [ ] Post-mortem: [task]
   ```

## Error Handling

### Error: RULE.md not found

**Response**:
```
⚠️ No RULE.md found in this directory or parent directories.

This appears to not be a ProjectMaster-initialized project.

Options:
1. Initialize project first: "Initialize a new project for [name]"
2. Create meeting note with default format (no governance)
3. Specify a different directory

What would you like to do?
```

If user chooses option 2, use default structured format.

### Error: meetings/ directory doesn't exist

**Response**:
```
⚠️ No meetings/ directory found.

I'll create it now with proper governance structure.
```

Then:
```bash
mkdir -p meetings/
echo "[README.md content]" > meetings/README.md
```

Proceed with meeting creation.

### Error: Invalid meeting type

If user specifies a meeting type not in RULE.md:

**Response**:
```
⚠️ Meeting type "[type]" not recognized for this project.

Available types based on your RULE.md:
- [type1]
- [type2]
- [type3]

Would you like to:
1. Use one of the available types
2. Create as "General" meeting
3. Add "[type]" to RULE.md as a new meeting type

Which option?
```

### Error: Filename conflict

If filename already exists:

**Response**:
```
⚠️ A meeting note already exists with this name:
meetings/[type]/[filename].md

Options:
1. Create with different name (e.g., append "-v2")
2. Update/append to existing note
3. Cancel creation

What would you like to do?
```

## Integration with Other Skills

### With manage-sprint Skill

If meeting is sprint-related (planning, review, retrospective):

1. **Check for current sprint**:
   ```bash
   ls sprints/current/
   ```

2. **Link meeting to sprint**:
   ```yaml
   related_sprint: sprint-05
   ```

3. **Update sprint documentation**:
   Add reference in `sprints/sprint-05/sprint-plan.md`:
   ```markdown
   ## Meetings
   - [Planning](../../meetings/sprint-planning/2025-11-13_sprint-5-planning.md)
   ```

### With track-milestone Skill

If meeting discusses milestone:

1. **Extract milestone mentions** from content
2. **Link in metadata**:
   ```yaml
   related_milestone: beta-release
   ```

3. **Update milestone notes**:
   If milestones.yaml supports notes:
   ```yaml
   notes: "Discussed in meeting: meetings/planning/2025-11-13_sprint-5-planning.md"
   ```

### With AkashicRecords Skills

If user wants to reference knowledge base articles in meeting:

1. **Detect article mentions** (URLs, document names)
2. **Use search-content** to locate articles
3. **Link in meeting notes**:
   ```markdown
   ## References
   - [Architecture Decision 001](../../decisions/001-database-choice.md)
   - [API Documentation](../../knowledge/api-docs.md)
   ```

## Best Practices

### 1. Always read RULE.md first

Meeting format varies by team. Read RULE.md before creating to ensure compliance.

### 2. Extract action items automatically

Look for tasks, assignments, and commitments. Parse them into structured format.

### 3. Link generously

Connect meetings to sprints, milestones, decisions, and other meetings. Rich linking improves navigability.

### 4. Maintain consistent naming

Follow RULE.md naming convention exactly. Consistency enables better searching and sorting.

### 5. Update governance immediately

Don't defer README.md updates. Do them as part of meeting creation.

### 6. Confirm action items with user

Automatic extraction may miss context. Always confirm extracted action items.

### 7. Use appropriate granularity

Daily standups: Brief, minimal format
Sprint planning: Detailed, comprehensive format
Retrospectives: Structured sections (what went well, what to improve)

### 8. Preserve formatting

If user provides formatted content, preserve structure while adding governance elements.

## Examples

### Example 1: Sprint Planning Meeting

```
User: I need to create notes for our sprint 5 planning meeting

Claude: I'll create sprint planning notes. Let me gather details...

Meeting title? (e.g., "Sprint 5 Planning")

User: Sprint 5 Planning

Claude: Great! Attendees?

User: Whole team - Alice (PO), Bob (SM), Carol, David, Eve, Frank (devs)

Claude: How long was the meeting?

User: About 90 minutes

Claude: Perfect! Any content to include, or should I create a template for you to fill?

User: Create template, but add that we're focusing on authentication features

Claude: Got it! Creating structured sprint planning notes...

✅ Created: meetings/sprint-planning/2025-11-13_sprint-5-planning.md

📄 Structured template with:
- Sprint goal: Authentication features
- Sections for user stories, estimates, assignments
- Action items section
- Links to Sprint 5 documentation

📚 Updated:
✓ meetings/README.md
✓ meetings/sprint-planning/README.md
✓ Project README.md
✓ sprints/sprint-05/sprint-plan.md (added planning meeting link)

You can now edit the file to add detailed notes, user stories, and estimates.
```

### Example 2: Quick Daily Standup

```
User: Today's standup: Carol finished user signup, David starting login, Eve blocked on OAuth config, Bob will help Eve

Claude: Recording daily standup...

✅ Created: meetings/daily-standups/2025-11-13_standup.md

📋 Summary:
- Carol: Completed user signup ✓
- David: Starting login feature
- Eve: Blocked on OAuth configuration
- Bob: Will assist Eve

Action Items:
- [ ] Bob: Help Eve with OAuth configuration

📚 Governance updated

💡 Reminder: Bob to assist Eve with OAuth blocker
```

### Example 3: Retrospective

```
User: Create retro notes for sprint 4

Claude: I'll create a Sprint 4 retrospective note. Let me use the retrospective template...

What went well in Sprint 4?

User: We delivered all planned features, team collaboration was great, no major bugs

Claude: What could be improved?

User: Estimations were off, needed better testing before review

Claude: Any specific action items for next sprint?

User: Allocate more time for testing, involve QA earlier, re-calibrate story points

Claude: Creating retrospective...

✅ Created: meetings/retrospectives/2025-11-13_sprint-4-retro.md

📊 Sprint 4 Retrospective:

🎉 What Went Well:
- Delivered all planned features
- Strong team collaboration
- No major bugs

🔧 What Could Be Improved:
- Estimation accuracy
- Testing workflow timing

📋 Action Items for Sprint 5:
- [ ] Allocate dedicated testing time in sprint planning
- [ ] Involve QA from story refinement stage
- [ ] Re-calibrate story point estimates based on Sprint 4 actuals

📚 Updated governance and linked to Sprint 4 documentation

💡 These action items will be tracked in Sprint 5 planning.
```

## Notes

- Meeting notes are the heartbeat of project communication. Rich, structured notes enable better async collaboration.
- Action item extraction is intelligent but not perfect. Always review and confirm.
- Cross-referencing meetings to sprints, milestones, and decisions creates a knowledge graph that's easy to navigate.
- The RULE.md-defined format ensures consistency across the team without imposing rigid templates.
- This Skill adapts to your team's actual workflow - Scrum, Kanban, Waterfall, or hybrid.

---

Effective meeting notes transform ephemeral discussions into persistent project knowledge. This Skill makes that transformation automatic.
