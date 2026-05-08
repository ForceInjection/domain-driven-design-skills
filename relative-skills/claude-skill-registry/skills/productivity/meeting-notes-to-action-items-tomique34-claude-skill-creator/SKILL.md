---
name: meeting-notes-to-action-items
description: Convert meeting notes, demo sessions, and discussions into actionable tasks with clear owners, priorities, and deadlines. Use when processing any meeting notes, demo feedback, product reviews, or discussions that need to become TODO lists, JIRA tickets, or Trello cards.
---

# Meeting Notes to Action Items Converter

## Overview

Automatically transform demo meeting notes, feedback sessions, and product reviews into structured, actionable tasks. Extracts action items from unstructured notes and formats them as TODO lists, JIRA tickets, or Trello cards with proper priorities, assignees, and deadlines.

## Quick Start

Provide meeting notes from a demo session and specify the output format:

```
"Convert these demo notes to action items"
"Create JIRA tickets from this feedback session"
"Extract tasks from this meeting transcript and format as TODO list"
```

The skill will:
1. Analyze the notes to identify action items
2. Extract key information (who, what, when, priority)
3. Format as requested (TODO, JIRA, Trello)
4. Optionally generate API calls or scripts for automatic creation

## Detailed Instructions

### Step 1: Parse Demo Notes

Accept notes in various formats:
- **Meeting transcripts** - Raw text from recordings or live notes
- **Bullet point notes** - Structured notes with key points
- **Email summaries** - Demo feedback sent via email
- **Slack/Teams messages** - Chat discussions about the demo
- **Voice-to-text transcripts** - Automated transcriptions

**Identify Action Items:**

Look for patterns indicating tasks:
- "We need to..."
- "Should fix..."
- "TODO:", "Action item:"
- "[Name] will..."
- "By [date]..."
- "High priority:", "Critical:"
- Questions that require follow-up
- Bug reports or issues mentioned
- Feature requests
- Documentation updates needed

**Extract Context:**
- **What** needs to be done (task description)
- **Who** is responsible (assignee)
- **When** it's due (deadline/sprint)
- **Why** it matters (context from demo)
- **Priority** level (based on language and context)
- **Category** (bug, feature, improvement, documentation)

### Step 2: Structure Action Items

Transform raw notes into structured tasks with:

**Clear Task Titles:**
- Action-oriented (verb first)
- Specific and concise
- Include relevant context

Examples:
- ❌ "The button thing"
- ✅ "Fix checkout button not responding on mobile"

**Detailed Descriptions:**
- Context from the demo
- Steps to reproduce (for bugs)
- Acceptance criteria
- Additional notes or references

**Proper Categorization:**
- **Bug**: Issues that don't work as expected
- **Feature**: New functionality requests
- **Improvement**: Enhancements to existing features
- **Documentation**: Docs, guides, or help text
- **Design**: UI/UX changes
- **Investigation**: Research or spike tasks

**Priority Assignment:**

Based on impact and urgency:
- **Critical/P0**: Blocking issues, security problems
- **High/P1**: Important features, major bugs
- **Medium/P2**: Standard tasks, minor bugs
- **Low/P3**: Nice-to-haves, minor improvements

Indicators:
- "Critical", "urgent", "ASAP" → High priority
- "When you get a chance", "nice to have" → Low priority
- Blocking other work → High priority
- Cosmetic issues → Low priority

**Assignee Identification:**

- Explicit mentions: "John will handle this"
- Role-based: "Frontend team should fix"
- Inferred from context: Bug in login → Backend team
- Default to "Unassigned" if unclear

**Deadline Extraction:**

- Explicit dates: "By Friday", "End of sprint"
- Relative dates: "This week", "Next sprint"
- Inferred urgency: Critical bugs → Immediate
- Default: "To be determined" if not specified

### Step 3: Format Output

#### TODO List Format

**Structure:**
```markdown
# Demo Action Items - [Demo Name/Date]

## High Priority

- [ ] **[Task Title]**
  - **Assignee**: [Name or Team]
  - **Deadline**: [Date or "TBD"]
  - **Category**: [Bug/Feature/etc]
  - **Description**: [Detailed description]
  - **Context**: [Relevant notes from demo]

## Medium Priority

- [ ] **[Task Title]**
  - **Assignee**: [Name]
  - **Deadline**: [Date]
  - **Category**: [Category]
  - **Description**: [Details]

## Low Priority

- [ ] **[Task Title]**
  - **Assignee**: [Name]
  - **Deadline**: [Date]
  - **Category**: [Category]
  - **Description**: [Details]

## Follow-up Questions

- [ ] **[Question to clarify]**
  - **Who to ask**: [Person]
  - **Context**: [Background]

## Notes

- [Additional context or observations from demo]
- [Decisions made during demo]
```

**Best Practices for TODO:**
- Use checkboxes `- [ ]` for easy tracking
- Bold task titles for visibility
- Group by priority
- Include all metadata inline
- Add context so tasks make sense later

#### JIRA Ticket Format

**Structure:**
```markdown
# JIRA Tickets for [Demo Name]

## Ticket 1: [Task Title]

**Project**: [PROJECT-KEY]
**Issue Type**: Bug / Story / Task
**Summary**: [Clear, concise title]
**Priority**: Critical / High / Medium / Low
**Assignee**: [username or "Unassigned"]
**Labels**: demo-feedback, [sprint-name], [component]
**Sprint**: [Sprint number or name]
**Due Date**: [YYYY-MM-DD or empty]

**Description**:
```
[Detailed description with context from demo]

**Steps to Reproduce** (for bugs):
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happens]

**Acceptance Criteria**:
- [ ] [Criteria 1]
- [ ] [Criteria 2]

**Demo Context**:
[Relevant notes from the demo session]
```

**Components**: [Component names]
**Affects Version**: [Version shown in demo]
**Fix Version**: [Target version]

---

## Ticket 2: [Next Task]
[Repeat structure]
```

**JIRA-Specific Guidelines:**
- Use proper JIRA fields (Summary, Description, etc.)
- Include issue type (Bug, Story, Task, Epic)
- Add appropriate labels for filtering
- Link related tickets if applicable
- Estimate story points if possible
- Include acceptance criteria

**Issue Type Selection:**
- **Bug**: Something is broken or not working
- **Story**: New feature or user-facing functionality
- **Task**: Internal work (refactoring, research)
- **Epic**: Large initiative requiring multiple stories
- **Sub-task**: Part of a larger story or bug

#### Trello Card Format

**Structure:**
```markdown
# Trello Cards for [Demo Name]

## Board: [Board Name]
## List: [List Name - e.g., "To Do", "Backlog"]

---

### Card 1: [Task Title]

**List**: [Which list to add to]
**Labels**: [Label1], [Label2], [Label3]
**Members**: [@username]
**Due Date**: [YYYY-MM-DD or "None"]
**Position**: top / bottom

**Description**:
```
## Context from Demo
[Background and demo feedback]

## What Needs to Be Done
[Specific actions required]

## Acceptance Criteria
- [ ] [Criteria 1]
- [ ] [Criteria 2]
- [ ] [Criteria 3]

## Additional Notes
[Any other relevant information]
```

**Checklist Items**:
- [ ] [Checklist item 1]
- [ ] [Checklist item 2]
- [ ] [Checklist item 3]

**Attachments**: [URLs or file references]

**Custom Fields** (if applicable):
- Priority: High / Medium / Low
- Estimated Hours: [number]
- Story Points: [number]

---

### Card 2: [Next Task]
[Repeat structure]
```

**Trello-Specific Guidelines:**
- Use color-coded labels for categories
- Add checklists for multi-step tasks
- Include due dates for time-sensitive items
- @mention relevant team members
- Link to related cards
- Attach screenshots or mockups if available

**Label Suggestions:**
- 🔴 Red: Urgent/Critical
- 🟠 Orange: Bug
- 🟡 Yellow: Feature
- 🟢 Green: Improvement
- 🔵 Blue: Documentation
- 🟣 Purple: Design

### Step 4: Generate API Scripts (Optional)

For automated task creation, generate scripts that use the APIs:

#### JIRA API Script (Python)

```python
#!/usr/bin/env python3
"""
Create JIRA tickets from demo action items
Requires: pip install jira
"""

from jira import JIRA
import os

# Configuration
JIRA_URL = "https://your-domain.atlassian.net"
JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")
PROJECT_KEY = "PROJ"

# Connect to JIRA
jira = JIRA(server=JIRA_URL, basic_auth=(JIRA_EMAIL, JIRA_API_TOKEN))

# Tickets to create
tickets = [
    {
        "project": PROJECT_KEY,
        "summary": "[Task title]",
        "description": "[Detailed description]",
        "issuetype": {"name": "Bug"},
        "priority": {"name": "High"},
        "labels": ["demo-feedback"],
        "assignee": {"name": "username"},
        "duedate": "2024-12-31"  # YYYY-MM-DD
    },
    # Add more tickets...
]

# Create tickets
for ticket_data in tickets:
    new_issue = jira.create_issue(fields=ticket_data)
    print(f"Created: {new_issue.key} - {ticket_data['summary']}")
```

#### Trello API Script (Python)

```python
#!/usr/bin/env python3
"""
Create Trello cards from demo action items
Requires: pip install py-trello
"""

from trello import TrelloClient
import os

# Configuration
API_KEY = os.getenv("TRELLO_API_KEY")
API_SECRET = os.getenv("TRELLO_API_SECRET")
TOKEN = os.getenv("TRELLO_TOKEN")

BOARD_ID = "your_board_id"
LIST_NAME = "To Do"

# Connect to Trello
client = TrelloClient(api_key=API_KEY, api_secret=API_SECRET, token=TOKEN)

# Get board and list
board = client.get_board(BOARD_ID)
todo_list = None
for list_obj in board.list_lists():
    if list_obj.name == LIST_NAME:
        todo_list = list_obj
        break

# Cards to create
cards = [
    {
        "name": "[Task title]",
        "desc": "[Detailed description with context]",
        "labels": ["bug", "high-priority"],
        "due": "2024-12-31",  # YYYY-MM-DD
        "position": "top"
    },
    # Add more cards...
]

# Create cards
for card_data in cards:
    card = todo_list.add_card(
        name=card_data["name"],
        desc=card_data["desc"],
        position=card_data.get("position", "bottom")
    )

    # Add labels
    for label_name in card_data.get("labels", []):
        # Find or create label
        label = next((l for l in board.get_labels() if l.name == label_name), None)
        if label:
            card.add_label(label)

    # Set due date
    if "due" in card_data:
        card.set_due(card_data["due"])

    print(f"Created: {card.name}")
```

#### Bash Script for Simple TODO File

```bash
#!/bin/bash
# Create TODO.md file from action items

cat > DEMO_ACTION_ITEMS.md << 'EOF'
# Demo Action Items - [Date]

## High Priority
- [ ] [Task 1]
- [ ] [Task 2]

## Medium Priority
- [ ] [Task 3]

## Low Priority
- [ ] [Task 4]

EOF

echo "Created DEMO_ACTION_ITEMS.md"
```

## Examples

### Example 1: Simple Demo Notes to TODO

**Input (Demo Notes):**
```
Product Demo - New Dashboard Feature - Dec 15, 2024

Attendees: Sarah (PM), Mike (Dev), Lisa (Design), John (QA)

Demo went well overall! Few issues:

- The loading spinner on dashboard isn't showing up properly. Mike said
  he'll look into it this week.

- Sarah mentioned we should add a refresh button. Users were confused
  about how to update the data. High priority for next sprint.

- Lisa noticed the chart colors don't match our design system. She'll
  update the mockups and we can implement after the refresh button.

- John found a bug where clicking the export button twice crashes the
  page. Needs to be fixed before release!

- We should add a user guide for this feature. Lisa volunteered to write it.

Questions:
- Should we show real-time data or cache it? Need to ask backend team.
```

**Output (TODO Format):**
```markdown
# Demo Action Items - Product Demo (Dec 15, 2024)

## High Priority

- [ ] **Fix export button crash when clicked twice**
  - **Assignee**: Mike (Dev)
  - **Deadline**: Before release
  - **Category**: Bug
  - **Description**: Export button crashes the page when clicked multiple times in quick succession
  - **Context**: Found by John during QA testing in demo. Blocking release.

- [ ] **Add refresh button to dashboard**
  - **Assignee**: Mike (Dev)
  - **Deadline**: Next sprint
  - **Category**: Feature
  - **Description**: Users need a clear way to refresh/update dashboard data
  - **Context**: Sarah noted users were confused about how to update the data during demo
  - **Acceptance Criteria**:
    - [ ] Button clearly visible in header
    - [ ] Shows loading state when refreshing
    - [ ] Updates all dashboard widgets

## Medium Priority

- [ ] **Fix loading spinner not displaying**
  - **Assignee**: Mike (Dev)
  - **Deadline**: This week
  - **Category**: Bug
  - **Description**: Dashboard loading spinner doesn't show up properly
  - **Context**: Noticed during demo, affects user experience

- [ ] **Update chart colors to match design system**
  - **Assignee**: Lisa (Design) → then Dev team
  - **Deadline**: After refresh button is complete
  - **Category**: Design
  - **Description**: Current chart colors don't align with design system
  - **Context**: Lisa will update mockups first, then dev team implements

- [ ] **Create user guide for new dashboard feature**
  - **Assignee**: Lisa (Design)
  - **Deadline**: TBD
  - **Category**: Documentation
  - **Description**: Write user-facing documentation explaining the dashboard feature
  - **Context**: Lisa volunteered during demo

## Follow-up Questions

- [ ] **Determine data refresh strategy: real-time vs cached**
  - **Who to ask**: Backend team
  - **Context**: Need architectural decision before implementing refresh functionality
  - **Impact**: Affects refresh button implementation

## Demo Summary

**What went well**:
- Overall positive reception
- Feature functionality working as expected

**Issues identified**: 5 action items created
**Next steps**: Prioritize export bug fix for release
```

### Example 2: Detailed Feedback to JIRA Tickets

**Input (Demo Feedback):**
```
Mobile App Demo Feedback - Sprint 23

Client demo with Acme Corp - they loved it but found some issues:

1. Login screen - password field not clearing after failed attempt.
   Security concern. Jane from their team reported it.

2. They want dark mode ASAP. CEO specifically asked for it.
   Would be a great selling point.

3. Profile picture upload is slow - took 30 seconds for a 2MB image.
   Unacceptable for production.

4. Minor: spacing on settings page looks off on tablets.
   Not critical but noticed by their UX lead.

5. Push notifications not working on Android 13. Critical bug.
```

**Output (JIRA Format):**
```markdown
# JIRA Tickets - Mobile App Demo (Sprint 23)

## Ticket 1: Password field not clearing after failed login attempt

**Project**: MOBILE
**Issue Type**: Bug
**Summary**: Password field retains value after failed login attempt
**Priority**: High
**Assignee**: Unassigned
**Labels**: demo-feedback, security, sprint-24, login
**Sprint**: Sprint 24
**Due Date**: 2024-12-20

**Description**:
During client demo with Acme Corp, Jane reported that the password
field is not clearing after a failed login attempt. This is a security
concern as it could expose passwords if the device is shared or observed.

**Steps to Reproduce**:
1. Open mobile app
2. Enter incorrect username/password
3. Submit login form
4. Observe password field after error message

**Expected Behavior**:
Password field should clear after failed login attempt for security

**Actual Behavior**:
Password field retains the entered value

**Acceptance Criteria**:
- [ ] Password field clears immediately after failed login
- [ ] Applies to both iOS and Android
- [ ] Username field behavior remains unchanged
- [ ] Error message still displays properly

**Demo Context**:
Reported by Jane from Acme Corp during Sprint 23 demo. Flagged as
security concern.

**Components**: Authentication, Mobile-UI
**Affects Version**: 2.3.0
**Fix Version**: 2.3.1

---

## Ticket 2: Implement Dark Mode

**Project**: MOBILE
**Issue Type**: Story
**Summary**: Add dark mode theme to mobile app
**Priority**: High
**Assignee**: Unassigned
**Labels**: demo-feedback, feature-request, sprint-24, ui
**Sprint**: Sprint 24
**Story Points**: 8
**Due Date**: End of Sprint 24

**Description**:
Acme Corp CEO specifically requested dark mode functionality during
the demo. This was highlighted as an important selling point for their
organization.

**User Story**:
As a mobile app user, I want to enable dark mode so that I can use the
app comfortably in low-light conditions and reduce eye strain.

**Acceptance Criteria**:
- [ ] Dark theme available in settings
- [ ] Applies to all app screens
- [ ] Respects system dark mode preference
- [ ] Manual toggle available in settings
- [ ] Theme persists across app restarts
- [ ] All UI elements readable in dark mode
- [ ] Images/icons adapted for dark background

**Demo Context**:
CEO of Acme Corp specifically asked for this feature. Marked as "ASAP"
priority and noted as a selling point for the product.

**Design Notes**:
Need to review design system for dark mode color palette

**Components**: Mobile-UI, Settings
**Fix Version**: 2.4.0

---

## Ticket 3: Profile picture upload extremely slow

**Project**: MOBILE
**Issue Type**: Bug
**Summary**: Profile picture upload takes 30+ seconds for 2MB image
**Priority**: Critical
**Assignee**: Unassigned
**Labels**: demo-feedback, performance, sprint-24, profile
**Sprint**: Sprint 24
**Due Date**: 2024-12-18

**Description**:
During Acme Corp demo, profile picture upload took 30 seconds for a
2MB image. This performance is unacceptable for production use.

**Steps to Reproduce**:
1. Navigate to profile settings
2. Tap on profile picture
3. Select 2MB image from gallery
4. Upload image
5. Observe upload time (30+ seconds)

**Expected Behavior**:
Image upload should complete in under 5 seconds for typical photos

**Actual Behavior**:
Upload takes 30+ seconds for a 2MB image

**Acceptance Criteria**:
- [ ] 2MB image uploads in <5 seconds on typical network
- [ ] Progress indicator shows upload status
- [ ] Large images compressed before upload
- [ ] Error handling for failed uploads
- [ ] Works on both iOS and Android

**Technical Notes**:
Investigate image compression, upload optimization, and API performance

**Demo Context**:
Demonstrated during Acme Corp meeting. Flagged as unacceptable for
production deployment.

**Components**: Profile, Upload, API
**Affects Version**: 2.3.0
**Fix Version**: 2.3.1

---

## Ticket 4: Settings page spacing incorrect on tablets

**Project**: MOBILE
**Issue Type**: Bug
**Summary**: Settings page layout spacing issues on tablet devices
**Priority**: Low
**Assignee**: Unassigned
**Labels**: demo-feedback, ui, tablet, sprint-25
**Sprint**: Sprint 25
**Due Date**: TBD

**Description**:
Acme Corp UX lead noticed spacing on settings page looks incorrect
when viewed on tablet devices. Marked as minor/cosmetic issue.

**Steps to Reproduce**:
1. Open app on tablet device (iPad, Android tablet)
2. Navigate to Settings
3. Observe spacing and layout

**Expected Behavior**:
Settings page should have consistent, appropriate spacing on tablets

**Actual Behavior**:
Spacing appears off/inconsistent

**Acceptance Criteria**:
- [ ] Settings page reviewed on multiple tablet sizes
- [ ] Spacing consistent with design system
- [ ] Responsive layout works correctly
- [ ] No overlapping elements

**Demo Context**:
Noticed by UX lead from Acme Corp. Not critical but affects polish.

**Components**: Mobile-UI, Settings
**Affects Version**: 2.3.0
**Fix Version**: 2.4.0

---

## Ticket 5: Push notifications not working on Android 13

**Project**: MOBILE
**Issue Type**: Bug
**Summary**: Push notifications failing on Android 13 devices
**Priority**: Critical
**Assignee**: Unassigned
**Labels**: demo-feedback, android, notifications, critical, sprint-24
**Sprint**: Sprint 24
**Due Date**: 2024-12-17

**Description**:
Push notifications are not working on Android 13 devices. This is a
critical bug affecting core functionality.

**Steps to Reproduce**:
1. Install app on Android 13 device
2. Enable notifications in app settings
3. Trigger a push notification
4. Notification does not appear

**Expected Behavior**:
Push notifications should appear on Android 13 devices

**Actual Behavior**:
Notifications fail silently on Android 13

**Acceptance Criteria**:
- [ ] Push notifications work on Android 13
- [ ] Notification permissions requested correctly
- [ ] All notification types functional
- [ ] Backwards compatible with older Android versions
- [ ] Tested on multiple Android 13 devices

**Technical Notes**:
Android 13 introduced new notification permission requirements.
Investigate runtime permission handling.

**Demo Context**:
Critical bug discovered during Acme Corp demo. Blocking production release.

**Components**: Notifications, Android
**Affects Version**: 2.3.0
**Fix Version**: 2.3.1
```

### Example 3: Meeting Transcript to Trello Cards

**Input (Meeting Transcript):**
```
[10:00] Sarah: Thanks everyone for joining the demo! Let me share my screen.

[10:05] Sarah: As you can see, the new search feature is working...

[10:12] Tom: Hey, I noticed the search is case-sensitive. Should it be?

[10:13] Sarah: Good catch! That's probably a bug. We should fix that.

[10:15] Mike: Yeah, I'll add that to the backlog.

[10:18] Lisa: The results look great, but could we add pagination?
         Loading 1000 results at once might be slow.

[10:20] Sarah: Agreed. That should be high priority for next sprint.

[10:25] John: What about saving search history? Users might want that.

[10:26] Sarah: Nice idea but let's table that for now. Not critical.

[10:30] Tom: Before we wrap up - the export to CSV button isn't working for me.

[10:31] Mike: Oh that's bad. I'll check it today.
```

**Output (Trello Format):**
```markdown
# Trello Cards - Search Feature Demo

## Board: Product Development
## List: To Do

---

### Card 1: Fix search to be case-insensitive

**List**: To Do
**Labels**: bug, search, high-priority
**Members**: @Mike
**Due Date**: 2024-12-18
**Position**: top

**Description**:
```
## Context from Demo
During the demo on [date], Tom noticed that the search feature is
currently case-sensitive, which is not the expected behavior for a
user-friendly search function.

## What Needs to Be Done
Make the search functionality case-insensitive so that searching for
"apple", "Apple", or "APPLE" returns the same results.

## Acceptance Criteria
- [ ] Search works regardless of case (upper/lower/mixed)
- [ ] Applies to all searchable fields
- [ ] Performance not significantly impacted
- [ ] Works with special characters

## Additional Notes
Bug identified by Tom at 10:12 during demo. Mike confirmed this should
be fixed.
```

**Checklist Items**:
- [ ] Implement case-insensitive search logic
- [ ] Test with various case combinations
- [ ] Update any relevant documentation

---

### Card 2: Add pagination to search results

**List**: To Do
**Labels**: feature, search, high-priority, performance
**Members**: @Mike
**Due Date**: End of next sprint
**Position**: top

**Description**:
```
## Context from Demo
Lisa raised a performance concern about loading 1000+ search results
at once. This could cause slow loading times and poor user experience.

## What Needs to Be Done
Implement pagination for search results to improve performance and
user experience when dealing with large result sets.

## Acceptance Criteria
- [ ] Results paginated (suggest 20-50 per page)
- [ ] Page navigation controls (prev/next, page numbers)
- [ ] Display total count of results
- [ ] URL reflects current page (for bookmarking)
- [ ] Loading state while fetching next page
- [ ] Performance improved for large result sets

## Additional Notes
Sarah agreed this should be high priority for next sprint. Performance
is important for production.

## Design Considerations
- Decide on results per page (20, 50, or 100?)
- Infinite scroll vs traditional pagination?
```

**Checklist Items**:
- [ ] Design pagination UI
- [ ] Implement backend pagination logic
- [ ] Add frontend pagination controls
- [ ] Test with large datasets
- [ ] Measure performance improvement

---

### Card 3: Fix CSV export button not working

**List**: To Do
**Labels**: bug, critical, export
**Members**: @Mike
**Due Date**: 2024-12-16
**Position**: top

**Description**:
```
## Context from Demo
At 10:30 during the demo, Tom reported that the CSV export button is
not functioning. Mike committed to checking it today.

## What Needs to Be Done
Debug and fix the CSV export functionality so users can successfully
export search results to CSV format.

## Acceptance Criteria
- [ ] Export button triggers CSV download
- [ ] CSV includes all relevant data fields
- [ ] Filename is meaningful (includes date/timestamp)
- [ ] Works across all browsers
- [ ] Large datasets export without timeout

## Additional Notes
This is critical as export functionality is a key feature. Mike to
investigate and fix ASAP.

## Debugging Steps
- Check console for JavaScript errors
- Verify API endpoint is working
- Test with different result set sizes
```

**Checklist Items**:
- [ ] Reproduce the issue
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Test across browsers
- [ ] Verify with large datasets

---

### Card 4: Add search history feature

**List**: Backlog
**Labels**: feature, enhancement, low-priority
**Members**: Unassigned
**Due Date**: None
**Position**: bottom

**Description**:
```
## Context from Demo
John suggested adding a search history feature so users can quickly
re-run previous searches. Sarah agreed it's a good idea but not
critical for now.

## What Needs to Be Done
Implement a search history feature that stores and displays recent
searches for easy re-use.

## Acceptance Criteria
- [ ] Store recent searches (suggest last 10-20)
- [ ] Display search history in dropdown
- [ ] Click to re-run previous search
- [ ] Clear history option
- [ ] Privacy consideration (don't store sensitive searches?)
- [ ] Persists across sessions

## Additional Notes
Tabled for now as not critical. Revisit after core search features
are stable and performant.

## Future Considerations
- Should history be per-user or per-device?
- How long to keep history?
- Privacy/security implications?
```

**Checklist Items**:
- [ ] Design UX for history feature
- [ ] Determine storage mechanism (localStorage, database)
- [ ] Implement history tracking
- [ ] Add UI for viewing/using history
- [ ] Add clear history functionality
```

## Best Practices

### Writing Clear Action Items

1. **Use Action Verbs**: Start with "Fix", "Add", "Update", "Investigate", "Create"
2. **Be Specific**: Include enough detail to understand the task without the meeting notes
3. **Include Context**: Why is this important? What demo feedback led to this?
4. **Set Clear Criteria**: What does "done" look like?
5. **Assign Ownership**: Who is responsible? (even if it's "Unassigned")

### Prioritization Guidelines

**Critical/High Priority:**
- Blocking bugs preventing release
- Security issues
- Features explicitly requested as "urgent" or "ASAP"
- Major usability issues affecting core functionality

**Medium Priority:**
- Important features for next sprint
- Bugs that don't block release
- Performance improvements
- UX enhancements

**Low Priority:**
- Nice-to-have features
- Cosmetic issues
- Future enhancements
- Questions for later discussion

### Extracting Information from Messy Notes

**Common Patterns:**

| Note Pattern | Extract As |
|--------------|------------|
| "X will do Y" | Assignee: X, Task: Y |
| "Should/need to..." | Action item |
| "By Friday/end of week" | Deadline |
| "Critical/urgent/ASAP" | High priority |
| "Nice to have/eventually" | Low priority |
| "Bug:", "Issue:", "Problem:" | Bug category |
| "Feature request:", "Could we..." | Feature category |
| "?" at end | Follow-up question |

**Handling Ambiguity:**

- **No assignee mentioned**: Mark as "Unassigned" or assign to relevant team
- **No deadline**: Use "TBD" or infer from context (critical bugs = immediate)
- **Unclear priority**: Default to Medium, note in description
- **Vague description**: Add note that clarification is needed

### Platform-Specific Tips

**TODO Lists:**
- Group by priority for easy scanning
- Use checkboxes for progress tracking
- Keep all metadata with each task
- Add a "Follow-up Questions" section

**JIRA:**
- Use proper issue types (Bug, Story, Task)
- Add labels for easy filtering
- Include story points if you can estimate
- Link related tickets
- Use components and fix versions
- Add detailed acceptance criteria

**Trello:**
- Use color-coded labels consistently
- Add checklists for multi-step tasks
- Set due dates for time-sensitive items
- Use descriptions for full context
- Position critical items at top
- @mention relevant people

## Common Patterns to Recognize

### Bug Reports in Demo Notes

**Indicators:**
- "Not working"
- "Broken"
- "Error"
- "Crashed"
- "Failed"
- "Issue with..."

**Extract:**
- What's broken
- Steps to reproduce
- Expected vs actual behavior
- Browser/device if mentioned

### Feature Requests

**Indicators:**
- "Should have..."
- "Could we add..."
- "Would be nice..."
- "Users want..."
- "Missing..."

**Extract:**
- What feature
- Why it's needed
- Who requested it
- Priority level

### Questions/Clarifications

**Indicators:**
- "?"
- "Need to ask..."
- "Should we..."
- "Not sure if..."
- "To be determined"

**Extract:**
- The question
- Who can answer
- Why it matters
- Blocking or non-blocking

## Additional Resources

See the templates directory for:
- [TODO Template](templates/TODO_TEMPLATE.md) - Structured TODO list format
- [JIRA Template](templates/JIRA_TEMPLATE.md) - JIRA ticket structure
- [Trello Template](templates/TRELLO_TEMPLATE.md) - Trello card format

See the examples directory for:
- [Product Demo Example](examples/product-demo.md) - Full example from product demo
- [Bug Bash Example](examples/bug-bash.md) - Example from bug bash session
- [Client Feedback Example](examples/client-feedback.md) - Client meeting notes

See the scripts directory for:
- [jira_create.py](scripts/jira_create.py) - Script to create JIRA tickets via API
- [trello_create.py](scripts/trello_create.py) - Script to create Trello cards via API
- [parse_notes.py](scripts/parse_notes.py) - Helper to parse meeting notes

## Tips for Better Results

1. **Provide Complete Context**: Include who attended, what was demoed, date
2. **Preserve Original Notes**: Don't pre-process too much, let the skill extract
3. **Specify Output Format**: Be clear about TODO vs JIRA vs Trello
4. **Mention Project Context**: JIRA project key, Trello board name, etc.
5. **Include Urgency Signals**: Mention if anything is critical or blocking
6. **Identify Attendees**: Helps with assignee identification
7. **Note Decisions Made**: Include any decisions or agreements from the demo

## Troubleshooting

**Too Many Tasks Created:**
- The skill might be too aggressive in identifying action items
- Review and merge related tasks
- Mark some as "Questions" instead of "Tasks"

**Missing Context:**
- Original notes might be too vague
- Add more detail when providing input
- Include speaker names and timestamps

**Wrong Priorities:**
- Double-check priority assignments
- Adjust based on your team's criteria
- Add notes about why priority was chosen

**Unclear Assignees:**
- Provide team structure context
- Explicitly mention who should handle what
- Use "Unassigned" and assign during triage
