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

### Forms & Inputs
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

## Issue Documentation

Each issue needs:
- **id**: ISSUE-001
- **severity**: critical | high | medium | low | note
- **category**: bug | ux | accessibility | edge-case | visual
- **page**: /path/to/page
- **title**: Short description
- **description**: Detailed explanation
- **steps_to_reproduce**: Ordered list
- **expected**: What should happen
- **actual**: What actually happens
- **screenshot**: Path to evidence
- **suggested_test**: Playwright test code

## Severity Guidelines

- **Critical**: Crashes, data loss, security issue, flow blocker
- **High**: Feature broken, significant UX problem
- **Medium**: Edge case failures, minor UX issues
- **Low**: Polish issues, minor visual glitches
- **Note**: Observations, suggestions, not bugs

## Scope Control

- Only explore pages/states within defined scope
- Time-box analysis (2-5 minutes per waypoint)
- Don't attempt to fix issues during exploration

### When Stuck
1. Document with maximum detail
2. Take screenshot
3. Attempt one workaround (refresh, re-navigate)
4. If still blocked, mark waypoint as "blocked" and skip
5. Continue from next accessible waypoint

## Output

### report.md

Summary table with severity counts, then issues ordered by severity. Each issue includes description, steps, expected/actual, screenshot, and suggested Playwright test.

### metadata.json

```json
{
  "session_id": "{session-id}",
  "scope": "{DESCRIPTION}",
  "status": "complete",
  "waypoints_total": 5,
  "waypoints_completed": 5,
  "issues": { "critical": 0, "high": 1, "medium": 3, "low": 2, "note": 2 }
}
```

## Integration

**Feeds into:**
- `/plan-chat` - When issues need architectural discussion
- `/plan-breakdown` - When ready to create fix tasks directly

## Quality Checklist

- [ ] All waypoints visited or documented as blocked
- [ ] Each issue has severity, category, description
- [ ] Screenshots captured for visual issues
- [ ] Steps to reproduce provided
- [ ] Suggested Playwright tests included
- [ ] Summary statistics accurate
