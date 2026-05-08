---
name: listing-branches
description: Use when user wants to inventory autonomy branches with custom sorting, grouping, or filtering
---

# Listing Branches

## Overview

Display inventory of all autonomy branches with user-specified sorting, grouping, and information display using computational analysis.

**Core principle:** Use branch-analyzer agent with Python scripts for precise analysis. Never "eyeball it".

## When to Use

Use this skill when:
- User runs `/list-branches` command
- User wants to see all autonomy branches
- User wants custom sorting or grouping of branches
- User wants to filter branches by criteria

**DO NOT use for:**
- Analyzing single branch (use analyzing-branch-status instead)
- Comparing two branches (use comparing-branches instead)
- General iteration review on current branch (use reviewing-progress instead)

## Quick Reference

| Step | Action | Tool |
|------|--------|------|
| 1. Parse query | Extract sorting/grouping/filter requirements | Manual |
| 2. Dispatch agent | Send query to branch-analyzer | Task |
| 3. Format results | Present markdown table to user | Direct output |

## Process

### Step 1: Parse User Query

Extract requirements from user's query (if provided):

**Default (no query):**
- Sort by: most recent update (git log date)
- Grouping: none (flat list)
- Show: branch name, latest iteration, last update, status

**Parse user query for:**
- **Sorting:** "sort by [criterion]" → most recent, alphabetical, iteration count, status
- **Grouping:** "group by [field]" → status, date range, metric value
- **Filtering:** "show only [criteria]" → active, blocked, updated since date
- **Information:** "with [fields]" → metrics, blockers, next steps

**Example queries:**
```
"sort by most recent, show only active"
  → Sort: recency, Filter: status=active, Show: default fields

"group by status, show metrics"
  → Group: status, Sort: recency within groups, Show: + metrics

"show branches updated in last 30 days"
  → Filter: date > (today - 30 days), Sort: recency, Show: default
```

### Step 2: Dispatch Branch-Analyzer Agent

Dispatch the `branch-analyzer` agent with detailed instructions:

```bash
Task tool with subagent_type: "autonomy:branch-analyzer"
Model: haiku
Prompt: "List all autonomy branches and analyze their status.

User query: [user's query or 'default: sort by most recent']

Requirements:
- Find all branches matching 'autonomy/*'
- For each branch, find most recent journal commit (starts with 'journal: ')
- Parse commit message for: status, metrics, blockers, next steps
- [Apply sorting: {criterion}]
- [Apply grouping: {field}]
- [Apply filtering: {criteria}]
- Generate Python script to process data
- Output markdown table with columns: [requested fields]

Use computational methods (Python scripts), do not eyeball the analysis."
```

**Agent will:**
1. Run `git branch -a | grep 'autonomy/'` to list all autonomy branches
2. For each branch, find most recent journal commit
3. Parse commit message metadata (Status, Metrics, Blockers, Next)
4. Generate Python script to sort/group/filter
5. Execute Python script
6. Return formatted markdown table

### Step 3: Present Results

Display agent's output to user.

**Example output format:**
```markdown
# Autonomy Branches

Showing 3 branches (sorted by most recent update)

| Branch | Latest Iteration | Last Updated | Status | Metrics | Next |
|--------|------------------|--------------|--------|---------|------|
| experiment-a | 0028 | 2026-01-02 | blocked | MRR: $62k (+12%) | Resolve Stripe API integration |
| experiment-b | 0015 | 2025-12-28 | active | Build: 3.2min (-40%) | Implement checkout flow |
| initial-strategy | 0042 | 2025-12-15 | concluded | Churn: 8% (from 13%) | Goal achieved |
```

**If no autonomy branches found:**
```markdown
No autonomy branches found.

To create your first autonomy branch:
1. Run `/create-goal` to set up an open-ended goal
2. Run `/fork-iteration <strategy-name>` to create autonomy branch
3. Run `/start-iteration` to begin work
```

## Important Notes

### Only Autonomy Branches

This skill ONLY operates on `autonomy/*` branches:
- Filters for branches with `autonomy/` prefix
- Will not show non-autonomy branches (e.g., `main`, `develop`)
- For general iteration review, user should use `/review-progress`

### Computational Analysis Required

**DO NOT:**
- Manually count or sort branches
- "Eyeball" which branches are active
- Guess at groupings or filters

**DO:**
- Dispatch branch-analyzer agent
- Let agent generate Python scripts
- Use computational methods for precision

### Flexible Query Parsing

User queries are free-text and flexible:
- Don't require exact syntax
- Interpret intent from natural language
- Ask via AskUserQuestion if query is ambiguous
- Default to sensible behavior if unclear

### No Branch Checkout Required

All analysis happens via git commands:
- Never checkout branches
- Read commit messages via `git log <branch>`
- Branch-analyzer uses read-only operations

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "I'll manually list branches from git branch output" | NO. Dispatch branch-analyzer agent for computational analysis. |
| "Only 3 branches, I can eyeball the sorting" | NO. Always use Python scripts for precision. |
| "User query is unclear, I'll guess" | NO. Use AskUserQuestion to clarify if ambiguous. |
| "I'll check out each branch to read journals" | NO. Use git log to read commit messages without checkout. |
| "Non-autonomy branch appeared, I'll include it" | NO. Only autonomy/* branches. Strict filtering. |

## After Listing

Once branches are listed:
- Results displayed to user
- No files created or modified
- User can drill into specific branch with `/branch-status <branch-name>`
- User can fork from any listed iteration with `/fork-iteration <iteration> <strategy-name>`
