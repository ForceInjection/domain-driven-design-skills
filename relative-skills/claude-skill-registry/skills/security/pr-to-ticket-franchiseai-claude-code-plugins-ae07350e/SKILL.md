---
name: pr-to-ticket
description: File Linear tickets from PR review feedback and notify the PR author. Use when asked to file a ticket from PR comments, create a ticket from PR feedback, ticket PR concerns, or create a Linear ticket from a PR review. Triggers on phrases like "file ticket from PR", "ticket the PR concerns", "linear ticket for PR", "create ticket from PR feedback", or "ticket this review".
---

# PR Comments to Linear Ticket

File Linear tickets from PR review feedback and notify the PR author.

## Overview

This skill automates the workflow of:
1. Analyzing PR comments and reviews to find actionable concerns
2. Creating a well-structured Linear ticket with full context
3. Commenting on the PR to notify the author with the ticket link

## Workflow

### Step 1: Gather PR Context

Get the current PR info:
```bash
gh pr view --json number,headRepository,author
gh repo view --json nameWithOwner
```

### Step 2: Fetch All Comments

Retrieve all comment sources:
```bash
# PR-level comments
gh api /repos/{owner}/{repo}/issues/{number}/comments

# Review comments (inline on code)
gh api /repos/{owner}/{repo}/pulls/{number}/comments

# Reviews with body text
gh api /repos/{owner}/{repo}/pulls/{number}/reviews
```

### Step 3: Analyze & Filter Comments

**Skip these:**
- Bot comments (Linear linkback `<!-- linear-linkback -->`, CI bots)
- Resolved review threads
- Simple approvals without feedback

**Identify actionable items:**
- Bug reports (keywords: "bug", "broken", "doesn't work", "error", ":bug:")
- UI/visual concerns (keywords: "visual", "design", "UI", "looks", "styling", "doesn't look")
- Performance issues (keywords: "slow", "performance", "optimize")
- UX concerns (keywords: "confusing", "UX", "user experience")
- Tech debt (keywords: "refactor", "cleanup", "tech debt", "TODO")

**Extract from comments:**
- Screenshots (markdown image syntax `![...](...)`  or `<img ...>`)
- Code snippets and diff hunks
- File paths and line numbers

**Detect parent ticket:**
- Look for Linear bot comment with linkback pattern
- Extract ticket ID (e.g., FSAI-2631) from the linked issue URL

### Step 4: Confirm with User

Present a summary of detected concerns using `AskUserQuestion`:

1. **Which concerns to include** - List each detected concern, let user confirm or adjust
2. **Which team to file under** - Suggest based on concern type (see heuristics below)
3. **Who to tag in PR comment** - Default to PR author, allow override

### Step 5: Create Linear Ticket

Use `mcp__linear__create_issue` with:

**Title:** Concise description of the concern(s)
- Example: "Improve Location Panel inline editing UI visual design"

**Team:** Based on concern type heuristics (see below)

**Description template:**
```markdown
## Context

Follow-up from PR #{number} ({pr_title}). {brief_context}

## Concerns to Address

### 1. {Concern Title}
{Concern description from review}

{Include any screenshots}

### 2. {Additional concerns if multiple}
...

## Next Steps
- {Suggested action items}

## Related
- PR: {pr_url}
- Parent ticket: {parent_ticket_id if detected}
```

**Links:** Attach the PR URL using the `links` parameter

### Step 6: Comment on PR

Notify the PR author:
```bash
gh pr comment {number} --body "@{pr_author} Filed ticket for the feedback: {linear_ticket_url}"
```

### Step 7: Report Summary

Tell the user what was created:
```
Created Linear ticket {TEAM-123}: {title}
URL: {linear_url}
Tagged @{author} in PR #{number}
```

## Team Selection Heuristics

| Concern Type | Keywords | Suggested Team |
|--------------|----------|----------------|
| UI/Visual | "visual", "design", "UI", "looks", "styling", "doesn't look right" | Design |
| UX | "confusing", "UX", "user experience", "hard to use" | Design |
| Bug | "bug", "broken", "doesn't work", "error", ":bug:" | Development |
| Performance | "slow", "performance", "optimize", "laggy" | Development |
| Tech Debt | "refactor", "cleanup", "tech debt" | Development |
| Default | (anything else) | Development |

## Guidelines

- **Always confirm before creating** - Show the user what will be filed
- **Preserve screenshots** - Copy image URLs directly into the ticket description
- **Link bidirectionally** - Include PR link in ticket, ticket link in PR comment
- **Be concise** - Ticket titles should be scannable, details go in description
- **Detect parent tickets** - Look for Linear bot comments to find related issues
- **Default to PR author for tagging** - They need to follow up on the feedback
- **One ticket per PR** - Unless user explicitly wants separate tickets for distinct concerns
