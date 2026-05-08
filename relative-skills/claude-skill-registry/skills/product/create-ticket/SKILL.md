---
name: create-ticket
description: Creates Jira tickets with proper formatting, acceptance criteria, and optionally sets up git branches and pull requests. Use when users want to create a new ticket, log a bug, request a feature, or when they mention "create ticket", "new ticket", "log issue", "file bug", or "create Jira".
license: MIT
metadata:
  author: IHKREDDY
  version: "1.0"
  category: development
compatibility: Requires Node.js 18+ and npm
---

# Create Ticket Skill

## When to Use This Skill

Use this skill when:
- Creating a new Jira ticket/issue
- Logging a bug or defect
- Creating a feature request
- Filing a task or story
- Users mention "create ticket", "new issue", "log bug", "file ticket"
- Users want to create a ticket AND start working on it

## Prerequisites

### 1. Install Dependencies

```bash
cd .github/skills && npm install
```

### 2. Configure Jira Credentials

Create a `.env` file in your project root:

```env
JIRA_URL=https://ihkreddy.atlassian.net
JIRA_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-api-token
JIRA_DEFAULT_PROJECT=SAM1
```

Get your API token from: https://id.atlassian.com/manage-profile/security/api-tokens

## Workflow Process

### 1. Create a Simple Ticket

```bash
npx ts-node --esm .github/skills/skills/create-ticket/scripts/create-ticket.ts \
  --summary "Add user authentication feature" \
  --type Story
```

### 2. Create a Detailed Ticket

```bash
npx ts-node --esm .github/skills/skills/create-ticket/scripts/create-ticket.ts \
  --summary "Implement password reset functionality" \
  --description "Users should be able to reset their password via email" \
  --type Story \
  --priority High \
  --labels "authentication,security" \
  --acceptance-criteria "User receives reset email within 5 minutes" \
  --acceptance-criteria "Reset link expires after 24 hours"
```

### 3. Create Ticket with Branch and PR

```bash
npx ts-node --esm .github/skills/skills/create-ticket/scripts/create-ticket.ts \
  --summary "Add flight search filters" \
  --type Story \
  --create-branch \
  --create-pr
```

## Script Options

| Option | Short | Required | Description |
|--------|-------|----------|-------------|
| `--summary` | `-s` | Yes | Ticket title/summary |
| `--project` | `-p` | No | Project key (default: SAM1) |
| `--type` | `-t` | No | Issue type: Story, Task, Bug, Epic |
| `--description` | `-d` | No | Detailed description |
| `--priority` | | No | Highest, High, Medium, Low, Lowest |
| `--labels` | | No | Comma-separated labels |
| `--acceptance-criteria` | `-ac` | No | Add criteria (repeatable) |
| `--create-branch` | | No | Create git branch |
| `--create-pr` | | No | Create pull request |

## Issue Type Guidelines

### Story
New features or user-facing functionality:
- "Add user profile page"
- "Implement flight search filters"

### Task
Technical work or internal tasks:
- "Update dependencies"
- "Configure CI/CD pipeline"

### Bug
Defects or issues:
- "Fix login timeout error"
- "Correct price calculation"

### Epic
Large features spanning multiple stories:
- "User Authentication System"
- "Flight Booking Module"

## Best Practices

### Writing Good Summaries
- Start with a verb: "Add", "Fix", "Update", "Implement"
- Be specific and concise
- Avoid vague terms

**Good:** "Add password reset via email"
**Bad:** "Fix login stuff"

### Writing Acceptance Criteria
Write testable criteria:
- "User sees confirmation message after booking"
- "API returns 400 for invalid input"
- "Page loads in under 2 seconds"
