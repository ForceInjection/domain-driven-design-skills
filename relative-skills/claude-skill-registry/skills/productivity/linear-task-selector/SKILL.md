---
name: linear-task-selector
description: Fetch tasks from Linear backlog and handle user selection. Saves selected task context for use in feature/bug/plan workflows. Reduces context usage by consolidating Linear API interactions.
---

# Linear Task Selector

This skill handles fetching tasks from Linear and managing user selection for workflow, bugfix, and plan commands.

## When to Use

Use this skill when:
- Starting a workflow, bugfix, or plan command
- User needs to select a task from Linear backlog
- You need to fetch and display Linear issues for selection

## Instructions

### Step 1: Determine Project Name
- Check CLAUDE.md for the correct Linear project name
- Common projects: "SalesBot MVP", "Hokusai data pipeline", "Hokusai infrastructure"
- If unclear, ask the user which project to use

### Step 2: Fetch Linear Backlog
Run the Linear backlog tool with the appropriate project name:
```bash
npx tsx ~/.claude/tools/get-backlog.ts "PROJECT_NAME"
```

For bug-specific tasks, add "bug" filter:
```bash
npx tsx ~/.claude/tools/get-backlog.ts "PROJECT_NAME" "bug"
```

### Step 3: Present Tasks to User
- Number each task (1, 2, 3, etc.)
- Display: task number, title, labels, state
- Format as a clean numbered list
- Use `osascript -e 'beep'` to alert the user

Example output:
```
Select a task from Linear:

1. [HOK-123] Add user authentication
   Labels: feature, backend
   State: Backlog

2. [HOK-124] Fix payment processing bug
   Labels: bug, critical
   State: Backlog

Please select a task by entering its number:
```

### Step 4: Capture User Selection
- Wait for user to provide a number
- Extract the corresponding task details:
  - Task ID (e.g., HOK-123)
  - Task title
  - Task description
  - Labels
  - State

### Step 5: Save Context
1. Sanitize the task title to create a feature name:
   - Lowercase all characters
   - Replace spaces with hyphens
   - Remove special characters (keep only alphanumeric and hyphens)
   - Example: "Add User Authentication!" → `add-user-authentication`

2. Create the feature directory:
```bash
mkdir -p features/<feature-name>
```

3. Save the selected task context to `features/<feature-name>/selected-task.json`:
```json
{
  "taskId": "HOK-123",
  "title": "Add user authentication",
  "description": "Full task description from Linear",
  "labels": ["feature", "backend"],
  "state": "Backlog",
  "projectName": "SalesBot MVP",
  "workflowType": "feature",
  "featureName": "add-user-authentication",
  "contextPath": "features/add-user-authentication/selected-task.json",
  "selectedAt": "2025-01-11T10:30:00Z"
}
```

Set `workflowType` based on labels:
- Contains "bug": `"workflowType": "bugfix"`
- Large/epic task: `"workflowType": "plan"`
- Otherwise: `"workflowType": "feature"`

### Step 6: Return Summary
Return a concise summary to the user:
```
✓ Selected: [HOK-123] Add user authentication
  Type: feature
  Feature directory: features/add-user-authentication/
  Context saved to: features/add-user-authentication/selected-task.json
```

## Examples

### Example 1: Feature Selection
```
User: /workflow
Assistant uses linear-task-selector:
1. Checks CLAUDE.md → finds "SalesBot MVP" project
2. Runs: npx tsx ~/.claude/tools/get-backlog.ts "SalesBot MVP"
3. Displays 5 tasks with numbers
4. User selects: 3
5. Creates: features/implement-email-generation/
6. Saves task to features/implement-email-generation/selected-task.json
7. Returns: "✓ Selected: [HOK-125] Implement email generation"
```

### Example 2: Bug Selection
```
User: /bugfix
Assistant uses linear-task-selector:
1. Checks CLAUDE.md → finds "SalesBot MVP" project
2. Runs: npx tsx ~/.claude/tools/get-backlog.ts "SalesBot MVP" "bug"
3. Displays 3 bugs with numbers
4. User selects: 1
5. Creates: features/fix-contact-discovery-timeout/
6. Saves bug to features/fix-contact-discovery-timeout/selected-task.json with workflowType: "bugfix"
7. Returns: "✓ Selected: [HOK-130] Fix contact discovery timeout"
```

## Error Handling

### Linear API Issues
If the Linear API fails:
1. Check for `LINEAR_API_KEY` in environment
2. Verify network connectivity
3. Check Linear API status
4. Provide helpful error message to user

### No Tasks Found
If no tasks are returned:
1. Verify project name is correct
2. Check if tasks exist in Linear for that project
3. Suggest checking Linear directly
4. Ask user if they want to try a different project

### Invalid Selection
If user selects an invalid number:
1. Show error: "Please select a number between 1 and N"
2. Re-display the numbered list
3. Wait for valid selection

## Output

This skill outputs:
- `features/<feature-name>/selected-task.json`: Selected task context for downstream workflows
- `features/<feature-name>/`: Created feature directory for all workflow artifacts
- Console: Summary message confirming selection
- Side effect: Beep sound to alert user

Note: Using feature-specific paths prevents conflicts when multiple Claude sessions run concurrently.

## Integration

Next steps after this skill:
- **workflow**: Use task context to create feature branch and generate PRD
- **bugfix**: Use task context to create bugfix branch and generate investigation plan
- **plan**: Use task context to decompose epic into sub-issues
