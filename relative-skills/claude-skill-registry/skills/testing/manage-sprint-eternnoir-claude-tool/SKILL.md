---
name: manage-sprint
description: Manage sprint/iteration lifecycle for Agile teams including planning, tracking, review, and retrospectives. Use when user mentions "sprint", "iteration", "user story", "backlog", "velocity", "scrum", "kanban board", or wants to track work in iterative cycles. Adapts to Scrum, Kanban, or custom Agile workflows.
---

# Manage Sprint Skill

## When to use this Skill

Activate when the user:
- Mentions creating, starting, or managing sprints/iterations
- Uses keywords: "sprint", "iteration", "user story", "backlog", "velocity", "scrum"
- Wants to track work items (stories, tasks, bugs)
- References sprint ceremonies (planning, review, retrospective)
- Needs to update sprint status or progress
- Talks about Kanban boards or workflow states

## Workflow

This Skill handles multiple sprint-related operations. The workflow adapts based on user intent and project methodology.

### Phase 1: Context Discovery & Intent Recognition

**Objective**: Understand project methodology and user's specific intent.

**Steps**:

1. **Locate and read RULE.md**:
   ```bash
   ls RULE.md
   Read RULE.md
   ```

2. **Extract methodology configuration**:
   ```markdown
   Key fields:
   - methodology: [scrum|kanban|waterfall|agile|hybrid]
   - sprint_length: [1_week|2_weeks|3_weeks|4_weeks] (if Scrum)
   - workflow_stages: [list] (if Kanban)
   - ceremonies: [list] (if Scrum)
   ```

3. **Understand directory structure**:
   - Scrum: `sprints/` directory with numbered sprints
   - Kanban: `board/` directory with workflow stages
   - Agile/Hybrid: `iterations/` or `work/` directory

4. **Detect user intent** from message:
   - **Create new sprint/iteration**: "start sprint", "create sprint", "new sprint"
   - **Update sprint status**: "sprint progress", "update sprint", "completed story"
   - **Add work items**: "add user story", "create task", "new card"
   - **Complete sprint**: "finish sprint", "sprint review", "close sprint"
   - **View sprint status**: "sprint status", "what's in this sprint", "show backlog"
   - **Move items**: "move to in-progress", "done with task"

5. **Route to appropriate sub-workflow**:
   - Intent: Create → Workflow A (Create Sprint)
   - Intent: Update → Workflow B (Update Sprint)
   - Intent: Add items → Workflow C (Add Work Items)
   - Intent: Complete → Workflow D (Complete Sprint)
   - Intent: Status → Workflow E (Report Status)
   - Intent: Move → Workflow F (Update Item Status)

**Example**:
```
Found RULE.md:
- Methodology: Scrum
- Sprint length: 2 weeks
- Ceremonies: planning, review, retrospective
- Current sprint detection needed

User intent: "Start sprint 5 for authentication features"
→ Route to Workflow A (Create Sprint)
```

### Workflow A: Create Sprint

**Objective**: Initialize a new sprint/iteration with goals and work items.

**Steps**:

1. **Determine sprint number**:
   ```bash
   # Check existing sprints
   ls -d sprints/sprint-*/
   # Determine next number
   ```

2. **Gather sprint details**:

   **Sprint goal**:
   ```
   What's the sprint goal?
   Example: "Complete user authentication and profile management"
   ```

   **Start date** (if not provided):
   ```
   Sprint start date? (Default: next Monday / today)
   ```

   **Calculate end date**:
   - Read `sprint_length` from RULE.md
   - Calculate: start_date + sprint_length

   **User stories/work items**:
   ```
   What user stories or tasks are in this sprint?

   You can provide:
   1. Full user story format: "As a [user], I want [goal] so that [benefit]"
   2. Simple task list: "Implement login, Add profile page, Write tests"
   3. Issue numbers (if integrated with tracker): "#123, #456, #789"
   4. "I'll add them later" - creates empty sprint
   ```

3. **Create sprint directory**:
   ```bash
   mkdir -p sprints/sprint-{number}
   ```

4. **Generate sprint document** based on RULE.md template:

   **For Scrum**:
   ```markdown
   ---
   sprint_number: {number}
   start_date: YYYY-MM-DD
   end_date: YYYY-MM-DD
   sprint_goal: "{goal}"
   status: planning
   team_capacity: {from RULE.md or ask}
   actual_velocity: null
   ---

   # Sprint {number}: {Goal}

   **Duration**: {start_date} to {end_date} ({X} weeks)
   **Status**: Planning → Active → Review → Completed
   **Team Capacity**: {Y} story points

   ## Sprint Goal

   {Detailed description of sprint goal}

   ## User Stories

   ### Planned Stories

   #### Story 1: {Title}
   **As a** {user type}
   **I want** {goal}
   **So that** {benefit}

   **Story Points**: {X}
   **Priority**: {High|Medium|Low}
   **Assignee**: @{name}
   **Status**: [ ] Not Started | [ ] In Progress | [X] Completed

   **Acceptance Criteria**:
   - [ ] Criterion 1
   - [ ] Criterion 2
   - [ ] Criterion 3

   **Tasks**:
   - [ ] Task 1
   - [ ] Task 2

   #### Story 2: ...

   [Repeat for each story]

   ## Sprint Backlog

   [Optional: List of all items with status]

   | Story | Points | Assignee | Status |
   |-------|--------|----------|--------|
   | Story 1 | 5 | @alice | In Progress |
   | Story 2 | 3 | @bob | Not Started |

   ## Daily Progress

   [Updated during sprint]

   ### {Date} Update
   - Completed: [items]
   - In Progress: [items]
   - Blocked: [items with reasons]

   ## Sprint Metrics

   - Total Story Points: {planned}
   - Completed Story Points: {actual} (updated daily)
   - Velocity: {completed/planned * 100}%
   - Burndown: [link to chart or manual tracking]

   ## Sprint Review

   [Added at sprint end]

   **Date**: {YYYY-MM-DD}
   **Attendees**: [list]

   ### Completed
   - [Story 1]: Demo notes
   - [Story 2]: Demo notes

   ### Not Completed
   - [Story X]: Reason, moved to backlog/next sprint

   ### Feedback
   - Stakeholder feedback notes

   ## Sprint Retrospective

   [Added after review]

   **Date**: {YYYY-MM-DD}

   ### What Went Well 🎉
   -

   ### What Could Be Improved 🔧
   -

   ### Action Items for Next Sprint
   - [ ] Action 1 - @owner
   - [ ] Action 2 - @owner

   ### Appreciation 💙
   -

   ---

   **Created**: {YYYY-MM-DD} by ProjectMaster
   **Last Updated**: {YYYY-MM-DD}
   ```

   **For Kanban**:
   ```markdown
   ---
   title: "{Goal/Theme}"
   created: YYYY-MM-DD
   status: active
   ---

   # {Goal/Theme}

   ## Active Cards

   ### Backlog

   #### Card: {Title}
   **Type**: {feature|bug|improvement|task}
   **Priority**: {high|medium|low}
   **Assignee**: @{name}
   **Created**: YYYY-MM-DD

   **Description**:
   {What needs to be done}

   **Acceptance Criteria**:
   - [ ] Criterion 1
   - [ ] Criterion 2

   ### In Progress
   [Cards being worked on]

   ### Review
   [Cards awaiting review]

   ### Done
   [Completed cards]

   ## Metrics

   - WIP Limit: {X} cards
   - Current WIP: {Y} cards
   - Cycle Time: Average {Z} days
   - Throughput: {N} cards/week

   ---

   **Created**: {YYYY-MM-DD} by ProjectMaster
   **Last Updated**: {YYYY-MM-DD}
   ```

5. **Write sprint file**:
   ```
   Use Write tool to create:
   sprints/sprint-{number}/sprint-plan.md
   ```

6. **Update governance**:
   - Update `sprints/README.md` with new sprint
   - Update project `README.md` current status
   - Update `milestones.yaml` if sprint contributes to milestone
   - Mark as current sprint if applicable

7. **Link to planning meeting** (if exists):
   - Check for recent sprint planning meeting
   - Add cross-reference in both documents

8. **Report creation**:
   ```
   ✅ Sprint {number} Created!

   📋 Sprint: {Goal}
   📅 Duration: {start} to {end} ({X} weeks)
   📊 Stories: {count} ({total} story points)
   👥 Team capacity: {Y} points

   📄 Document: sprints/sprint-{number}/sprint-plan.md

   User stories:
   1. {Story 1} - {points}sp - @{assignee}
   2. {Story 2} - {points}sp - @{assignee}
   ...

   🚀 Sprint is in "Planning" status

   💡 Next steps:
   - Finalize story estimates with team
   - Assign remaining stories
   - Mark sprint as "Active" when starting:
     "Activate sprint {number}"
   - Track daily progress:
     "Update sprint {number} progress"

   Ready to begin!
   ```

### Workflow B: Update Sprint

**Objective**: Update sprint progress, add daily notes, track completions.

**Steps**:

1. **Identify target sprint**:
   - If user specifies: "Update sprint 5"
   - If not specified: Find current/active sprint
   ```bash
   # Find active sprint
   grep -r "status: active" sprints/*/sprint-plan.md
   ```

2. **Read current sprint document**:
   ```
   Read sprints/sprint-{number}/sprint-plan.md
   ```

3. **Determine update type**:
   - **Status change**: "Activate sprint", "Complete sprint"
   - **Progress update**: "Add daily update", "Burndown update"
   - **Story completion**: "Mark story completed", "Close story"
   - **Add blocker**: "Story blocked", "Issue with story"

4. **Execute update**:

   **For status change**:
   ```yaml
   ---
   status: active  # or completed
   ---
   ```

   **For progress update**:
   Add to Daily Progress section:
   ```markdown
   ### {Today's Date} Update
   - Completed: Story 1 (5sp), Task A
   - In Progress: Story 2 (3sp), Story 3 (8sp)
   - Blocked: Story 4 - waiting for API access

   **Completed Story Points**: {cumulative}
   **Velocity**: {completed/total * 100}%
   ```

   **For story completion**:
   Update story status:
   ```markdown
   #### Story 1: User Login
   **Status**: [X] Completed  ← update from [ ] In Progress
   **Completed Date**: YYYY-MM-DD  ← add

   [Update Sprint Metrics accordingly]
   ```

   **For blocker**:
   Add to story and daily progress:
   ```markdown
   #### Story 4: OAuth Integration
   **Status**: [ ] Blocked
   **Blocked Since**: YYYY-MM-DD
   **Blocker**: Waiting for third-party API credentials
   **Owner of Resolution**: @alice
   ```

5. **Calculate metrics**:
   - Count completed stories
   - Sum completed story points
   - Calculate velocity percentage
   - Update burndown (if tracking)

6. **Update document** using Edit tool:
   ```
   Edit sprints/sprint-{number}/sprint-plan.md
   Replace old status/progress with new
   ```

7. **Update governance**:
   - Update `sprints/README.md` (current status)
   - Update project `README.md` (Recent Activity)
   - If story completed, check if milestone impacted

8. **Report update**:
   ```
   ✅ Sprint {number} Updated!

   📊 Progress:
   - Completed: {X}/{Y} stories ({A}/{B} points)
   - In Progress: {Z} stories
   - Blocked: {W} stories
   - Velocity: {percentage}%

   [If story completed:]
   🎉 Completed:
   - Story: {title} ({points}sp) by @{assignee}

   [If blocker added:]
   ⚠️ Blocker:
   - Story: {title}
   - Reason: {blocker description}
   - Owner: @{owner}

   📈 Sprint Health: {On Track|At Risk|Behind Schedule}

   📄 Updated: sprints/sprint-{number}/sprint-plan.md
   ```

### Workflow C: Add Work Items

**Objective**: Add user stories, tasks, or cards to sprint/backlog.

**Steps**:

1. **Determine target location**:
   - Active sprint: Add to current sprint backlog
   - Backlog: Add to general backlog
   - Specific sprint: Add to named sprint

2. **Gather work item details**:

   **Title**: Extract from user message or ask

   **Type**: Determine or ask:
   - User Story
   - Task
   - Bug
   - Technical Debt
   - Improvement

   **Description**: Get full details
   - For user stories: As a [user], I want [goal], so that [benefit]
   - For tasks: What needs to be done
   - For bugs: What's broken, steps to reproduce

   **Story points / Estimate**: Ask or default to TBD

   **Priority**: high | medium | low

   **Assignee**: @name or unassigned

3. **Format work item** per RULE.md template

4. **Add to sprint document**:
   ```
   Read current sprint document
   Edit to add new story under "User Stories" or "Backlog" section
   ```

5. **Update metrics**:
   - Increment total story count
   - Add story points to total
   - Recalculate capacity if needed

6. **Update governance**

7. **Report addition**:
   ```
   ✅ Work Item Added!

   📝 {Type}: {Title}
   📊 Estimate: {points}sp
   👤 Assignee: @{name}
   🎯 Priority: {priority}

   Added to: Sprint {number} / Backlog

   📄 Updated: sprints/sprint-{number}/sprint-plan.md
   ```

### Workflow D: Complete Sprint

**Objective**: Close sprint, conduct review/retro, archive sprint.

**Steps**:

1. **Identify sprint to complete**

2. **Check sprint status**:
   ```
   Read sprints/sprint-{number}/sprint-plan.md
   Extract:
   - Completed stories
   - Incomplete stories
   - Actual velocity
   ```

3. **Gather review information**:

   **Sprint Review**:
   ```
   Sprint {number} review:

   What was demoed to stakeholders?
   [For each completed story]

   Any feedback from stakeholders?
   ```

4. **Gather retrospective information**:

   **Sprint Retrospective**:
   ```
   Sprint {number} retrospective:

   What went well?
   What could be improved?
   Action items for next sprint?
   Any appreciations for team members?
   ```

5. **Update sprint document**:
   ```
   Edit sprints/sprint-{number}/sprint-plan.md
   - Update status: completed
   - Add Sprint Review section with notes
   - Add Sprint Retrospective section with feedback
   - Finalize metrics (actual velocity)
   ```

6. **Handle incomplete stories**:
   ```
   ⚠️ Incomplete Stories:
   - Story X: {title}
   - Story Y: {title}

   What should we do with these?
   1. Move to next sprint
   2. Move to backlog
   3. Archive (not needed anymore)
   ```

   Update accordingly.

7. **Calculate final metrics**:
   ```yaml
   actual_velocity: {completed_points}
   completion_rate: {completed_stories / total_stories * 100}%
   ```

8. **Update team velocity**:
   - If RULE.md tracks velocity, update average
   - Use for future sprint planning

9. **Archive sprint** (if RULE.md specifies):
   ```bash
   mkdir -p sprints/archived/
   mv sprints/sprint-{number} sprints/archived/sprint-{number}
   ```
   Or keep in place and just mark completed.

10. **Update governance**:
    - Update `sprints/README.md` (move to completed section)
    - Update project `README.md` (add to Recent Activity)
    - Update `milestones.yaml` if milestone reached
    - Link to sprint review/retro meetings if created separately

11. **Report completion**:
    ```
    ✅ Sprint {number} Completed!

    📊 Final Metrics:
    - Completed: {X}/{Y} stories
    - Story Points: {A}/{B} points delivered
    - Velocity: {percentage}%
    - Duration: {start} to {end}

    🎉 Achievements:
    - [Key deliverables]

    🔧 Improvements for Next Sprint:
    - [Action items from retro]

    📈 Team Velocity: {average over last 3 sprints}

    [If incomplete stories:]
    📦 Incomplete Stories:
    - {Story titles} → Moved to {backlog/next sprint}

    📄 Sprint Report: sprints/sprint-{number}/sprint-plan.md

    💡 Ready to plan Sprint {number + 1}?
    Say: "Start sprint {number + 1} for {theme}"
    ```

### Workflow E: Report Status

**Objective**: Show current sprint/work status.

**Steps**:

1. **Find current sprint**:
   ```bash
   grep -r "status: active" sprints/*/sprint-plan.md
   ```

2. **Read sprint document**

3. **Extract key information**:
   - Sprint number and goal
   - Start and end dates
   - Days remaining
   - Story completion status
   - Current velocity
   - Blockers

4. **Format status report**:
   ```
   📊 Current Sprint Status

   **Sprint {number}**: {Goal}
   **Duration**: {start} to {end} ({days_remaining} days left)
   **Status**: {Active|On Track|At Risk|Behind}

   📈 Progress:
   - Completed: {X}/{Y} stories ({A}/{B} points)
   - In Progress: {Z} stories
   - Not Started: {W} stories
   - Velocity: {percentage}% ({status vs planned})

   ✅ Completed:
   - {Story titles}

   🔄 In Progress:
   - {Story titles with assignees}

   ⚠️ Blockers:
   - {Blocker descriptions}

   📅 Upcoming:
   - {Next items to start}

   💡 Sprint Health: {Assessment}
   {If at risk: Recommendations}

   📄 Full details: sprints/sprint-{number}/sprint-plan.md
   ```

5. **Include Kanban status if applicable**:
   ```
   📋 Kanban Board Status

   **Backlog**: {X} cards
   **In Progress**: {Y} cards (WIP Limit: {Z})
   **Review**: {W} cards
   **Done**: {V} cards this week

   📊 Metrics:
   - Avg Cycle Time: {N} days
   - Throughput: {M} cards/week
   - WIP Status: {Under|At|Over} limit

   ⚠️ Attention Needed:
   - {Cards over WIP limit or stuck}
   ```

### Workflow F: Update Item Status

**Objective**: Move work items between states (Kanban) or update status (Scrum).

**Steps**:

1. **Identify work item**:
   - By title/description from user message
   - By searching sprint/board documents

2. **Determine target status**:
   - Scrum: Not Started → In Progress → Completed
   - Kanban: Backlog → In Progress → Review → Done

3. **Update item**:
   ```
   Edit sprint/board document
   Change status field
   Add timestamp
   ```

4. **Check constraints**:
   - Kanban: WIP limits
   - Scrum: Sprint capacity

5. **Update governance** and report

## Special Cases

### Case 1: Estimating stories during planning

When creating sprint, offer estimation help:

```
Would you like help estimating these stories?

I can use:
- Historical velocity (if available)
- Story complexity analysis
- Planning poker format (async)
- T-shirt sizing (S/M/L/XL)

Or you can provide estimates directly.
```

### Case 2: Mid-sprint scope change

If user wants to add stories mid-sprint:

```
⚠️ Sprint {number} is already active.

Adding stories mid-sprint impacts velocity tracking.

Options:
1. Add to current sprint (increases scope)
2. Add to backlog for next sprint
3. Replace an incomplete story (scope swap)

Recommended: Option 2 (maintain sprint integrity)

What would you like to do?
```

### Case 3: Velocity calculation

Track velocity over sprints:

```markdown
## Team Velocity History

- Sprint 5: 42 points (target: 45) - 93%
- Sprint 4: 38 points (target: 40) - 95%
- Sprint 3: 45 points (target: 45) - 100%

**Average Velocity**: 42 points/sprint
**Recommendation for Sprint 6**: Target 40-45 points
```

### Case 4: Sprint extensions

If user wants to extend sprint:

```
⚠️ Sprint {number} end date is {date}.

Extending sprints disrupts team rhythm and ceremonies.

Options:
1. Extend by {X} days (not recommended)
2. Move incomplete stories to next sprint
3. Reduce scope to meet original deadline

Recommended: Option 2 or 3 (maintain cadence)

What would you like to do?
```

### Case 5: Cross-sprint dependencies

If stories have dependencies across sprints:

```markdown
#### Story: Advanced Search
**Dependencies**:
- Sprint 4: Basic Search (prerequisite)
- Sprint 6: Search Analytics (dependent)

**Dependency Status**:
- ✅ Basic Search completed
- ⏳ Waiting for this story to start Search Analytics
```

## Error Handling

### Error: No RULE.md found

```
⚠️ No RULE.md found.

Sprint management requires project initialization.

Options:
1. Initialize project: "Initialize a new project"
2. Create sprint with defaults (Scrum, 2-week)
3. Cancel

What would you like to do?
```

### Error: Methodology doesn't support sprints

If RULE.md shows Waterfall:

```
⚠️ This project uses Waterfall methodology.

Sprints are not typically used in Waterfall.

Options:
1. Create phase-based tracking instead
2. Switch to Agile methodology (edit RULE.md)
3. Create sprint anyway (hybrid approach)

What would you like to do?
```

### Error: Sprint number conflict

```
⚠️ Sprint {number} already exists.

Options:
1. Update existing sprint
2. Create sprint {number + 1}
3. Cancel

What would you like to do?
```

## Integration with Other Skills

### With track-meeting Skill

Sprint ceremonies create meetings:
- Sprint planning → Meeting note
- Sprint review → Meeting note
- Sprint retrospective → Meeting note

Cross-link both documents.

### With track-milestone Skill

Sprints contribute to milestones:
- Link sprint to milestone in metadata
- Update milestone progress when sprint completes
- Show milestone context in sprint document

### With AkashicRecords

Technical decisions made during sprint:
- Link decision records to sprint stories
- Reference knowledge base articles in stories
- Update documentation as part of story completion

## Best Practices

### 1. Read RULE.md methodology first

Sprint format varies by methodology. Always check RULE.md before creating.

### 2. Track velocity consistently

Maintain velocity history for better sprint planning.

### 3. Link ceremonies to sprints

Connect planning, review, and retro meetings to sprint documents.

### 4. Update progress regularly

Daily updates keep team aligned and sprint health visible.

### 5. Respect WIP limits (Kanban)

Enforce WIP limits when moving cards.

### 6. Handle incomplete stories

Don't let incomplete stories disappear - explicitly decide their fate.

### 7. Celebrate completions

Acknowledge team achievements in sprint reports.

### 8. Learn from retrospectives

Convert retro action items into next sprint improvements.

## Notes

- This Skill adapts to your methodology - Scrum, Kanban, or hybrid.
- Velocity tracking helps teams improve estimation over time.
- Sprint documents become project history - rich, searchable, valuable.
- Cross-referencing sprints, meetings, and milestones creates cohesive project narrative.
- The Skill enforces best practices (like WIP limits) while remaining flexible.

---

Effective sprint management turns agile theory into practice. This Skill makes that management systematic and sustainable.
