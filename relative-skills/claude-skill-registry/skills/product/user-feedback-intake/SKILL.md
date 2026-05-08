---
name: user-feedback-intake
description: Process user feedback from Stellaris database into structured, actionable items. Use when reviewing bug reports and feature requests, or when user says "check feedback" or "process user requests".
allowed-tools: Read, Glob, Grep, Write, mcp__stellaris-admin__get_open_feedback, mcp__stellaris-admin__get_feedback_details, mcp__stellaris-admin__get_feedback_stats, mcp__stellaris-admin__update_feedback_status, mcp__stellaris-admin__respond_to_feedback
---

# User Feedback Intake Skill

## Purpose

This skill connects to the Stellaris production database via MCP tools and processes user feedback into structured, actionable items for the Product Manager.

**Use this skill when:**
- User asks to "check feedback" or "review user feedback"
- Processing bug reports and feature requests from Stellaris
- Preparing for backlog grooming or prioritization sessions
- User asks "what do users want?" or "what are users reporting?"

---

## MCP Database Access

### Fetching Feedback

Use the Stellaris Admin MCP server tools to fetch feedback:

**1. Get open feedback items:**
```
mcp__stellaris-admin__get_open_feedback
```

**Parameters:**
- `category` - Filter by type (default: "all"). Options: bug_report, feature_request, all
- `limit` - Max records to return (default: 50, max: 100)

**2. Get detailed information:**
```
mcp__stellaris-admin__get_feedback_details
```

**Parameters:**
- `feedback_id` - The feedback item ID

**3. Get summary statistics:**
```
mcp__stellaris-admin__get_feedback_stats
```

Returns counts by category, status, and recent trends.

**Database schema:**
- `id` - Unique feedback ID
- `user_id` - User who submitted (anonymized)
- `feedback_category` - bug_report | feature_request
- `feedback_type` - Specific type/subcategory
- `title` - User-provided title
- `description` - Detailed description
- `page_route` - Page where feedback was submitted (if applicable)
- `app_version` - Stellaris app version
- `status` - open | in_progress | planned | completed | resolved | closed
- `created_at` - Timestamp
- `updated_at` - Timestamp

---

## Categorization Logic

Use these rules to categorize feedback:

| Category | Type | Interpretation | Priority Baseline |
|----------|------|----------------|-------------------|
| `bug_report` | `problem` | Critical bug - something is broken | High |
| `bug_report` | `improvement` | Enhancement - works but could be better | Medium |
| `bug_report` | `slow` | Performance issue | Medium-High |
| `feature_request` | `new_feature` | New capability requested | Medium |
| `feature_request` | `behavior_change` | UX improvement | Medium |

**Note:** Priority baseline is a starting point. Product Manager applies RICE/ICE scoring for final prioritization.

---

## Output Format

Write intake records to `00 Inbox/feedback/intake-YYYY-MM-DD.md` with this structure:

```markdown
# Feedback Intake: [Date]

**Total items processed:** [count]
**Open items:** [count]
**Source:** Stellaris production database

---

## Item 1: [Feedback ID]

- **Type:** [Bug Report / Feature Request]
- **Subtype:** [problem/improvement/slow/new_feature/behavior_change]
- **User Need:** [underlying need, not just stated solution]
- **Description:** [user's description - verbatim]
- **Page:** [page_route if available, else "N/A"]
- **Impact:** [High/Medium/Low based on type and reach]
- **Related Plans:** [search existing plans for matches, else "None found"]
- **Next Step:** [Product Manager review / Technical PM scoping / Add to backlog / Duplicate of PLAN-XXX]

---

## Item 2: [Feedback ID]

[... repeat for each item ...]

---

## Summary

### High-Priority Items
[List items needing immediate attention]

### Patterns Detected
[Note any recurring themes across multiple feedback items]

### Recommended Next Steps
[Product Manager actions: prioritize, escalate, defer, etc.]
```

---

## Duplicate Detection

Before processing feedback, search for duplicates:

1. **Search existing plans:**
   ```bash
   grep -r "pronunciation" "00 Inbox/plans/"
   ```

2. **Search backlog:**
   ```bash
   grep -r "export PDF" "00 Inbox/backlog/"
   ```

3. **Search previous intake records:**
   ```bash
   grep -r "dark mode" "00 Inbox/feedback/"
   ```

If duplicate found, mark in intake record:
- **Related Plans:** PLAN-2025-015 (identical feature request)
- **Next Step:** Duplicate - close this feedback item

---

## User Need Extraction

**Critical:** Distinguish between stated solution and underlying need.

**Example:**

**User says (stated solution):** "Add a download button for lessons"

**Underlying need:** User wants to access lessons offline or save for later reference

**In intake record, write:**
- **User Need:** Access lessons without internet connection (offline learning)
- **Description:** "Add a download button for lessons" [user's words]
- **Next Step:** Technical PM scoping - evaluate offline lesson access options

**Why this matters:** The solution might be different (offline mode, PDF export, bookmarking) depending on technical constraints and other user needs.

---

## Workflow

### Step 1: Fetch Feedback
Use MCP tool to get open feedback:
```
Call: mcp__stellaris-admin__get_open_feedback
Parameters: {category: "all", limit: 50}
```

### Step 2: Parse Results
- MCP tool returns JSON data
- Group by feedback_category and feedback_type
- Sort by created_at (newest first)

### Step 3: Categorize & Analyze
For each feedback item:
1. Determine priority baseline (see categorization logic)
2. Extract underlying user need (not just stated solution)
3. Search for duplicates in plans/backlog/feedback
4. Assess impact (number of users affected, severity)

### Step 4: Write Intake Record
- Create `00 Inbox/feedback/intake-YYYY-MM-DD.md`
- Use structured format above
- Include summary with patterns and next steps

### Step 5: Notify Product Manager
After intake complete, summarize findings:
- Total items processed
- High-priority items needing immediate action
- Patterns detected (multiple users reporting same issue)
- Recommended next steps

### Optional: Respond to Users
When appropriate, use MCP tools to respond to users:

**Triage without user contact:**
```
Call: mcp__stellaris-admin__update_feedback_status
Parameters: {feedback_id: "xxx", status: "planned", internal_notes: "Added to backlog"}
```

**Send response to user:**
```
Call: mcp__stellaris-admin__respond_to_feedback
Parameters: {
  feedback_id: "xxx",
  response_message: "Thanks for your suggestion! We're planning to add this feature.",
  new_status: "planned"
}
```

**IMPORTANT - Child-Appropriate Responses:**
Stellaris is for kids. All responses must be:
- Encouraging and supportive
- Clear and concise (max 500 chars)
- Age-appropriate vocabulary
- Honest about what can/cannot be done
- Never request personal information

---

## Example Invocation

```
User: "Check the latest feedback from Stellaris"

You (skill execution):
1. Call mcp__stellaris-admin__get_open_feedback to fetch open feedback
2. Parse JSON results (e.g., 12 items returned)
3. Categorize each item
4. Search for duplicates
5. Extract underlying user needs
6. Write intake record to 00 Inbox/feedback/intake-2025-12-31.md
7. Return summary:

   "Processed 12 open feedback items from Stellaris.

   High-priority items (3):
   - Bug #142: Audio playback fails on iOS Safari
   - Feature #156: Offline lesson access
   - Performance #189: Slow page load on lesson library

   Patterns detected:
   - Mobile audio issues (3 separate reports)
   - Offline/download requests (recurring theme)

   Recommended next steps:
   - Escalate audio bug to engineering (critical)
   - Add offline access to backlog for prioritization
   - Performance issue needs Technical PM scoping

   Full intake record: 00 Inbox/feedback/intake-2025-12-31.md"
```

---

## Security Considerations

- **MCP tools are safe:** Read operations are read-only, write operations require explicit feedback_id
- **COPPA compliance:** Stellaris serves children under 13. All user interactions must be child-appropriate.
- **Response validation:** respond_to_feedback creates user-visible notifications. Use carefully.
- **No PII exposure:** Feedback is user-submitted public data (no sensitive personal info)
- **Authentication:** MCP server uses SSH authentication to production server

---

## Troubleshooting

### MCP Server Not Available
Check if MCP server is configured in .mcp.json:
```bash
cat .mcp.json | grep stellaris-admin
```

### MCP Tools Not Found
Verify tools are available:
- mcp__stellaris-admin__get_open_feedback
- mcp__stellaris-admin__get_feedback_details
- mcp__stellaris-admin__get_feedback_stats
- mcp__stellaris-admin__update_feedback_status
- mcp__stellaris-admin__respond_to_feedback

### Empty Results
Use get_feedback_stats to check if database has data:
```
Call: mcp__stellaris-admin__get_feedback_stats
```

---

## Important Notes

- **Read operations are safe** - get_open_feedback and get_feedback_details are read-only
- **Write operations require care** - respond_to_feedback creates user-visible notifications
- **Feedback directory auto-created** - If `00 Inbox/feedback/` doesn't exist, create it
- **One intake per day** - Use date-based filenames to avoid overwrites
- **Product Manager owns next steps** - Skill only processes and structures data
- **Duplicate detection is critical** - Avoid redundant work on already-planned features
- **Child-appropriate responses** - All user communication must be suitable for children

---

**Remember:** You are processing raw user feedback into actionable insights. Extract the underlying need, detect patterns, and provide clear next steps for the Product Manager. When responding to users, use encouraging, age-appropriate language.
