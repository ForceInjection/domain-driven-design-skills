---
name: web-qa-exploration
description: Perform exploratory QA testing on web applications using Playwright. Navigate flows, analyze pages, find issues, and generate actionable reports with evidence.
---

# Web QA Exploration

Autonomous exploratory testing using Playwright to analyze web application flows, identify issues, and generate actionable reports.

## Core Principles

1. **Thoroughness over speed** - Analyze each page state fully
2. **Break things intentionally** - Try edge cases, unexpected inputs, unusual navigation
3. **Document everything** - When in doubt, capture it
4. **Stay focused** - Follow defined waypoints; don't wander
5. **Fail gracefully** - If stuck, document and move on

## Working Directory

```
/tmp/webqa/{session-id}/
  session.md          # Session context and scope
  report.md           # Human-readable findings
  report.json         # Machine-readable for automation
  screenshots/        # Visual evidence
  metadata.json       # Session info, status
```

All ephemeral. Output feeds into `/plan-chat` or `/plan-breakdown`.

## Workflow Phases

### Phase 1: Setup

1. Parse user's QA scope/description
2. Create session-id slug from description
3. Create `/tmp/webqa/{session-id}/` directory
4. Write initial `session.md` with scope
5. Launch Playwright browser (headed for visibility)
6. Configure video recording if available

### Phase 2: Flow Discovery

If user provides specific flow:
- Use defined waypoints

If open-ended exploration:
1. Start at base URL
2. Identify key user journeys
3. Propose waypoints to user
4. Get approval before deep exploration

### Phase 3: Waypoint Analysis

For each waypoint:

1. **Arrive** - Navigate to URL or trigger state
2. **Wait** - Ensure page fully loaded (network idle)
3. **Capture** - Screenshot + DOM snapshot
4. **Analyze** - Run analysis checklist
5. **Document** - Record issues with evidence
6. **Proceed** - Move to next waypoint

### Phase 4: Report Generation

1. Compile all issues into structured report
2. Generate `report.md` (human-readable)
3. Generate `report.json` (machine-readable)
4. Update `metadata.json` with final status

## Analysis Checklist

At each waypoint, systematically check:

### Visual & Layout
- Content fully visible (no overflow, cutoff)
- Proper spacing and alignment
- Images/icons load correctly
- No layout shifts after load

### Navigation & State
- **Back button** - Does it preserve state?
- **Refresh** - Does page recover?
- **Deep link** - Can URL be shared/bookmarked?

### Forms & Inputs (if present)
- **Empty submission** - Validation fires?
- **Boundary values** - Max length, min/max numbers
- **Special characters** - `<script>`, quotes, unicode
- **Whitespace** - Leading/trailing, only spaces
- **Tab order** - Keyboard navigation logical
- **Error messages** - Clear, positioned correctly

### Interactions
- **Double-click** - Rapid clicking on submit
- **Keyboard shortcuts** - Enter, Escape behavior
- **Focus states** - Visible indicators
- **Disabled states** - Buttons during submission

### Accessibility (basic)
- Heading structure (h1-h6 hierarchy)
- Form labels present
- Color contrast (visual check)
- Alt text on images

### Error Handling
- Network failure behavior
- Timeout handling
- Invalid URL parameters

## Issue Documentation Format

```yaml
id: ISSUE-001
severity: critical | high | medium | low | note
category: bug | ux | accessibility | edge-case | visual
page: /path/to/page
title: "Short description"
description: |
  Detailed explanation of the issue.
steps_to_reproduce:
  - Step 1
  - Step 2
expected: "What should happen"
actual: "What actually happens"
screenshot: "screenshots/issue-001.png"
suggested_test: |
  test('description', async ({ page }) => {
    // Playwright test code
  });
```

## Severity Guidelines

- **Critical**: Crashes, data loss, security issue, flow blocker
- **High**: Feature broken, significant UX problem
- **Medium**: Edge case failures, minor UX issues
- **Low**: Polish issues, minor visual glitches
- **Note**: Observations, suggestions, not bugs

## Report Output (`report.md`)

```markdown
# QA Exploration Report

**Scope**: {DESCRIPTION}
**Date**: {TIMESTAMP}
**Duration**: {TIME}
**Waypoints**: {VISITED}/{TOTAL} completed

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0     |
| High     | 1     |
| Medium   | 3     |
| Low      | 2     |
| Notes    | 2     |

---

## Issues

### {SEVERITY}-001: {TITLE}

**Severity**: {SEVERITY}
**Category**: {CATEGORY}
**Page**: {PATH}
**Screenshot**: ![](screenshots/issue-001.png)

#### Description
{DETAILED_DESCRIPTION}

#### Steps to Reproduce
1. {STEP}
2. {STEP}

#### Expected
{EXPECTED_BEHAVIOR}

#### Actual
{ACTUAL_BEHAVIOR}

#### Suggested Test
```typescript
{PLAYWRIGHT_TEST}
```

---

## Waypoint Summary

| Waypoint | Status | Issues | Time |
|----------|--------|--------|------|
| {NAME}   | {STATUS} | {COUNT} | {TIME} |

---

## Next Steps

{RECOMMENDATIONS_FOR_FOLLOW_UP}

**Continue with:**
- `/plan-chat` - Design fixes for critical/high issues
- `/plan-breakdown` - Create tasks directly from this report
```

## Metadata Output (`metadata.json`)

```json
{
  "session_id": "{session-id}",
  "scope": "{DESCRIPTION}",
  "status": "complete",
  "created": "YYYY-MM-DDTHH:MM:SSZ",
  "duration_seconds": 525,
  "waypoints_total": 5,
  "waypoints_completed": 5,
  "issues": {
    "critical": 0,
    "high": 1,
    "medium": 3,
    "low": 2,
    "note": 2
  }
}
```

## Scope Control

### Stay Focused
- Only explore pages/states within defined scope
- Time-box analysis (2-5 minutes per waypoint)
- Don't attempt to fix issues during exploration

### When Stuck
1. Document with maximum detail
2. Take screenshot
3. Attempt one workaround (refresh, re-navigate)
4. If still blocked, mark waypoint as "blocked" and skip
5. Continue from next accessible waypoint

## Integration Points

**Feeds into:**
- `/plan-chat` - When issues need architectural discussion
- `/plan-breakdown` - When ready to create fix tasks directly

**Session artifacts:**
- `session.md` - Context for planning commands
- `report.md` - Full findings for review
- `report.json` - Structured data for automation

## Quality Checks

Before marking session complete:
- [ ] All waypoints visited or documented as blocked
- [ ] Each issue has severity, category, description
- [ ] Screenshots captured for visual issues
- [ ] Steps to reproduce provided
- [ ] Suggested Playwright tests included
- [ ] Summary statistics accurate
- [ ] Next steps recommendations provided
