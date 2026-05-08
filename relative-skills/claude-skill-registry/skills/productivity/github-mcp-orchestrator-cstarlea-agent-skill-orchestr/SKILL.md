---
name: github-mcp-orchestrator
description: Automatically converts user requests into well-structured GitHub issues. Triggers on requests to "create issues", "turn this into tasks", "break this down", "create a backlog", "epic", "PRD to issues", "file issues for this", or similar task decomposition language.
allowed-tools:
  - Read
  - Grep
  - Glob
  - mcp__github__*
---

# GitHub MCP Orchestrator

This skill enables Claude to transform user requests—whether they're feature requests, PRDs, bug reports, or rough ideas—into a structured set of GitHub issues with proper epic/child relationships, labels, and dependency tracking.

## When to Use This Skill

**Auto-trigger** when the user says things like:

- "Create issues for this"
- "Turn this into a backlog"
- "Break this down into tasks"
- "File this as an epic"
- "Create GitHub issues from this PRD"
- "I need issues for X, Y, and Z"
- "Make a task list for this feature"
- "Convert this into actionable work items"

## Mission

Transform any feature request, bug report, or project idea into:

1. **One Epic issue** (parent) that captures the overall goal
2. **Child issues** grouped by domain (frontend, backend, infra, etc.)
3. **Clear acceptance criteria** and definition of done for each issue
4. **Proper labels, estimates, and dependencies**

## Strict Rules

1. **Group related requests into a single epic**
   - Don't create multiple epics for a single feature
   - Use descriptive epic titles that capture the outcome

2. **Child issues must be small and independently completable**
   - Aim for issues that can be completed in 1-3 days
   - If an issue feels too big, break it down further

3. **Handle dependencies explicitly**
   - Create all issues but do NOT assign agents/copilots when dependencies exist
   - Surface the dependency chain clearly
   - Use "Depends on #123" or "Blocked by #456" language

4. **Always include structured metadata**
   - Definition of Done
   - Acceptance Criteria
   - Labels (type, area, priority, estimate)
   - T-shirt sizing (xs/s/m/l/xl) is acceptable for estimates

5. **Never create duplicate issues**
   - Search existing issues first using GitHub MCP tools
   - Reuse or update existing issues if appropriate

6. **Respect repo conventions**
   - Detect existing labels, milestones, and issue templates
   - Fall back to default taxonomy if none exist (see `reference/labeling.md`)

## Workflow

### 1. Intake & Clarify Internally

- Parse the user's request
- Identify the core outcome/goal
- Determine scope boundaries
- Make reasonable assumptions (no user questions)

### 2. Repo Scan

- Search for existing issues that might be related
- Check available labels and milestones
- Identify any existing epics this might belong to

### 3. Draft Plan

- Design epic structure
- Break down into child issues
- Group by domain (frontend, backend, infra, etc.)
- Identify dependencies
- Assign labels and estimates

### 4. Create Issues via GitHub MCP

**A. Create Epic Issue**
```javascript
const epic = await mcp__github__issue_write({
  method: "create",
  owner: "{owner}",
  repo: "{repo}",
  title: "Add Spotify Playlist Integration",
  body: epicBody, // From templates/epic.md
  labels: ["type:epic", "area:integration", "priority:p1"],
  type: "epic" // If repo supports issue types
})
```

**B. Create Child Issues**
```javascript
for (const task of tasks) {
  const childIssue = await mcp__github__issue_write({
    method: "create",
    owner: "{owner}",
    repo: "{repo}",
    title: task.title,
    body: task.body, // From templates/task.md
    labels: task.labels
  })

  // Link child to parent using sub-issues
  await mcp__github__sub_issue_write({
    method: "add",
    owner: "{owner}",
    repo: "{repo}",
    issue_number: epic.number,
    sub_issue_id: childIssue.id
  })
}
```

**C. Set Priority Order** (optional)
```javascript
// Set execution order for sub-issues
await mcp__github__sub_issue_write({
  method: "reprioritize",
  owner: "{owner}",
  repo: "{repo}",
  issue_number: epic.number,
  sub_issue_id: childIssue.id,
  after_id: previousIssue.id // Place after this issue
})
```

### 5. Output Summary

Generate an **Issue Map** showing:

```
Epic: #123 Add User Authentication
├─ #124 [database] Create user and session tables (estimate: M)
├─ #125 [backend] Implement auth API endpoints (estimate: S, depends on #124)
├─ #126 [frontend] Build login/register UI (estimate: M)
└─ #127 [frontend] Add protected routes (estimate: L, depends on #125, #126)

Dependencies:
  #125 ← #124
  #127 ← #125, #126
```

Include direct links to all created issues.

## Reference Documentation

- **Labeling taxonomy**: See `reference/labeling.md`
- **Dependency handling**: See `reference/dependencies.md`
- **GitHub MCP operations**: See `reference/mcp-ops.md`
- **Epic template**: See `templates/epic.md`
- **Task template**: See `templates/task.md`

## Output Format

Always conclude with:

1. **Summary**: Brief description of what was created
2. **Issue Map**: Tree view showing epic + children + dependencies
3. **Direct Links**: URLs to all created issues
4. **Next Steps**: Suggested order of execution (respecting dependencies)
