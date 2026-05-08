---
name: JQL Query Builder
description: Build and optimize JQL (Jira Query Language) queries for searching issues. Use when the user needs to search Jira issues, filter by complex criteria, find specific bugs or features, or when they mention JQL, queries, or searching Jira.
allowed-tools: Bash
---

# JQL Query Builder

Expert assistance for constructing JQL (Jira Query Language) queries to search and filter Jira issues efficiently.

## When to Use This Skill

- User wants to search for specific issues
- User needs to filter issues by multiple criteria
- User mentions JQL or queries
- User wants to find bugs, features, or tasks matching certain conditions
- User needs help understanding JQL syntax

## JQL Basics

### Field Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equals | `status = "In Progress"` |
| `!=` | Not equals | `priority != Low` |
| `>`, `<` | Greater/less than | `created > -7d` |
| `>=`, `<=` | Greater/less or equal | `priority >= High` |
| `~` | Contains text | `summary ~ "login"` |
| `IN` | Matches any value | `status IN (Open, "In Progress")` |
| `NOT IN` | Doesn't match | `priority NOT IN (Low)` |
| `IS EMPTY` | Field is empty | `assignee IS EMPTY` |
| `IS NOT EMPTY` | Field has value | `dueDate IS NOT EMPTY` |

### Common Fields

- **project**: Project key (e.g., `project = PROJ`)
- **status**: Issue status (e.g., `status = "In Progress"`)
- **priority**: Priority level (e.g., `priority = High`)
- **assignee**: Assigned user (e.g., `assignee = currentUser()`)
- **reporter**: Who created it (e.g., `reporter = currentUser()`)
- **created**: Creation date (e.g., `created >= -30d`)
- **updated**: Last update (e.g., `updated > -7d`)
- **type**: Issue type (e.g., `type = Bug`)
- **labels**: Labels (e.g., `labels = urgent`)
- **summary**: Title text (e.g., `summary ~ "authentication"`)
- **description**: Description text (e.g., `description ~ "error"`)

### Date Functions

- `-1d`, `-7d`, `-30d`: Relative dates (days ago)
- `-1w`, `-4w`: Weeks ago
- `startOfDay()`, `endOfDay()`: Day boundaries
- `startOfWeek()`, `endOfWeek()`: Week boundaries

### User Functions

- `currentUser()`: The logged-in user
- `membersOf("group-name")`: Users in a group

### Logical Operators

- `AND`: Both conditions must be true
- `OR`: Either condition must be true
- `NOT`: Negate a condition

## Common Query Patterns

### My Open Issues
```jql
assignee = currentUser() AND status != Done
```

### Recently Updated Bugs
```jql
type = Bug AND updated >= -7d ORDER BY updated DESC
```

### High Priority Unassigned Issues
```jql
priority = High AND assignee IS EMPTY AND status != Done
```

### Issues Created This Sprint
```jql
project = PROJ AND created >= -14d AND type IN (Story, Task)
```

### Overdue Issues
```jql
dueDate < now() AND status != Done ORDER BY dueDate ASC
```

### Issues Mentioning Specific Feature
```jql
(summary ~ "authentication" OR description ~ "authentication") AND status != Done
```

### Team's Work This Week
```jql
assignee IN membersOf("dev-team") AND updated >= startOfWeek()
```

### Epics Without Stories
```jql
type = Epic AND issueFunction NOT IN linkedIssuesOf("type = Story")
```

## Building Complex Queries

### Step-by-Step Approach

1. **Start with project**:
   ```jql
   project = PROJ
   ```

2. **Add status filter**:
   ```jql
   project = PROJ AND status IN ("To Do", "In Progress")
   ```

3. **Add assignee**:
   ```jql
   project = PROJ AND status IN ("To Do", "In Progress") AND assignee = currentUser()
   ```

4. **Add time filter**:
   ```jql
   project = PROJ AND status IN ("To Do", "In Progress") AND assignee = currentUser() AND created >= -30d
   ```

5. **Add sorting**:
   ```jql
   project = PROJ AND status IN ("To Do", "In Progress") AND assignee = currentUser() AND created >= -30d ORDER BY priority DESC, updated DESC
   ```

## Optimization Tips

### Use Specific Fields
❌ **Slow**: `text ~ "bug"`
✅ **Fast**: `summary ~ "bug" OR description ~ "bug"`

### Limit Date Ranges
❌ **Slow**: `created <= now()`
✅ **Fast**: `created >= -90d`

### Use IN Instead of Multiple OR
❌ **Verbose**: `status = "To Do" OR status = "In Progress" OR status = "Review"`
✅ **Clean**: `status IN ("To Do", "In Progress", "Review")`

### Order Matters for AND
Put most restrictive conditions first:
```jql
assignee = currentUser() AND status != Done AND type = Bug
```

## Testing Queries

When I build a query for you, I'll:

1. **Explain the logic**: Break down what each part does
2. **Test it**: Use `/jira-search` to verify results
3. **Refine**: Adjust based on results
4. **Optimize**: Suggest improvements for performance

## Common Use Cases

### Sprint Planning
```jql
project = PROJ AND status = "To Do" AND sprint IS EMPTY ORDER BY priority DESC
```

### Bug Triage
```jql
type = Bug AND status = "To Do" AND priority IS EMPTY ORDER BY created DESC
```

### Release Readiness
```jql
fixVersion = "v2.0" AND status != Done
```

### Stale Issues
```jql
status = "In Progress" AND updated <= -30d
```

### Blocked Work
```jql
status = Blocked OR labels = blocked ORDER BY priority DESC
```

## Advanced Patterns

### Find Issues Without Estimates
```jql
project = PROJ AND "Story Points" IS EMPTY AND type IN (Story, Task)
```

### Parent Issues with Incomplete Subtasks
```jql
issueFunction IN parentsOf("status != Done")
```

### Issues Mentioned in Comments
```jql
comment ~ "needs review"
```

### Cross-Project Search
```jql
project IN (PROJ1, PROJ2, PROJ3) AND assignee = currentUser()
```

## How I'll Help

When you need a JQL query, I will:

1. **Understand your requirements**: What are you trying to find?
2. **Build the query**: Construct JQL step-by-step
3. **Explain each part**: Help you understand the syntax
4. **Test it**: Run the query using `/jira-search`
5. **Refine**: Adjust based on results
6. **Save for reuse**: Document the query for future use

## Example Interaction

**You**: "Find all high-priority bugs assigned to me that were updated in the last week"

**Me**: "I'll build a JQL query for that:

```jql
type = Bug AND priority = High AND assignee = currentUser() AND updated >= -7d ORDER BY updated DESC
```

Breaking it down:
- `type = Bug`: Only bugs
- `priority = High`: High priority only
- `assignee = currentUser()`: Assigned to you
- `updated >= -7d`: Updated in last 7 days
- `ORDER BY updated DESC`: Newest first

Let me search for these issues using `/jira-search`..."

## References

For more JQL details:
- Jira Query Language documentation: https://support.atlassian.com/jira-service-management-cloud/docs/use-advanced-search-with-jira-query-language-jql/
- JQL functions: https://support.atlassian.com/jira-software-cloud/docs/jql-functions/
- JQL operators: https://support.atlassian.com/jira-software-cloud/docs/jql-operators/
