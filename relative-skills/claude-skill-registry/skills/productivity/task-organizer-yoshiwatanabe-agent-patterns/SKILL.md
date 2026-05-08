---
name: task-organizer
description: Track and manage tasks, projects, and tags using a SQLite-backed task tracking system. Use for task creation, project planning, todo lists, and productivity workflows.
---

# Task Organizer Skill

## Overview

The Task Organizer provides comprehensive task management capabilities with projects, tags, priorities, and full-text search. This skill automatically activates when you mention tasks, todos, projects, productivity, planning, or task tracking.

## When This Skill Activates

Claude automatically uses this skill when:
- You mention creating, updating, or deleting tasks
- You ask about your task list, todos, or to-do items
- You want to create or manage projects
- You ask about task deadlines or overdue items
- You want to search or filter tasks
- You ask for productivity metrics or task statistics
- You mention organizing or prioritizing work

## Available Operations

### Task Management
- **Create tasks** with title, description, priority level, due dates, and project assignment
- **Update task** status (pending, in_progress, completed, blocked)
- **Update task** priority (low, medium, high)
- **Update task** details (title, description, due date)
- **Delete tasks** when no longer needed
- **Mark tasks** as complete
- **View task** details including all metadata and tags
- **List tasks** with pagination support

### Search and Filter
- **Search tasks** using full-text search (search across titles and descriptions)
- **Filter tasks** by status (pending, in_progress, completed, blocked)
- **Filter tasks** by priority (low, medium, high)
- **Filter tasks** by project
- **Filter tasks** by tags
- **Find overdue tasks** automatically

### Project Management
- **Create projects** to organize tasks
- **View all projects** and their details
- **List tasks by project** to see project progress
- **Update project** information (name, description)
- **Delete projects** when they're complete

### Tag System
- **Add tags** to tasks for categorization
- **Remove tags** from tasks
- **List all tags** to see available categories
- **Filter tasks** by tags to find related work

### Analytics
- **View task statistics** (total, completed, pending, high-priority)
- **Calculate completion rate** to track productivity
- **Get completion trends** across your tasks
- **Identify overdue tasks** that need attention
- **Track high-priority items** at a glance

## Example Workflows

### 1. Daily Review
```
User: "Show me today's pending tasks and any overdue items"
Skill activates: Lists pending tasks, identifies overdue items, displays summary
```

### 2. Create and Organize
```
User: "Create a task to review the authentication PR, mark it as high priority and add a code-review tag"
Skill activates: Creates task, sets priority, adds tag, returns confirmation
```

### 3. Project Planning
```
User: "Create a project called 'Website Redesign' and add tasks for: design mockups, frontend implementation, backend updates"
Skill activates: Creates project, creates tasks, associates them with project
```

### 4. Search and Filter
```
User: "Find all high-priority tasks related to authentication"
Skill activates: Searches for "authentication", filters by high priority, displays results
```

### 5. Analytics
```
User: "What's my task completion rate this week and what's overdue?"
Skill activates: Calculates stats, lists overdue items, shows productivity metrics
```

### 6. Status Update
```
User: "Mark the database migration task as completed"
Skill activates: Updates task status to completed, recalculates statistics
```

## Task Priority Levels

- **High**: Critical tasks that need immediate attention
- **Medium**: Important tasks that should be done soon (default)
- **Low**: Nice-to-have tasks that can wait

## Task Status Values

- **Pending**: Not yet started
- **In Progress**: Currently being worked on
- **Completed**: Finished and done
- **Blocked**: Unable to progress due to dependencies or blockers

## Best Practices

### Clear Task Titles
✅ "Implement user authentication for mobile app"
❌ "Do the auth thing"

### Meaningful Descriptions
- Include context about why the task exists
- Add any relevant links or references
- Note dependencies on other tasks

### Appropriate Prioritization
- Use **High** for critical path items and urgent fixes
- Use **Medium** for regular work (this is the default)
- Use **Low** for nice-to-have enhancements

### Consistent Tagging
- Create tags that make sense for your workflow
- Examples: `bug`, `feature`, `documentation`, `review`, `urgent`
- Use tags to filter and find related work quickly

### Regular Status Updates
- Keep task status accurate for better tracking
- Mark items complete as soon as they're done
- Update blocked items with reasons

### Due Dates
- Set realistic due dates to avoid constant overdue items
- Review overdue tasks regularly
- Adjust dates if priorities change

## Common Patterns

### Breaking Down Large Work
Instead of one huge task, break work into smaller pieces:
```
Project: "Q4 Product Launch"
├── Task: "Finalize requirements" (due Monday)
├── Task: "Implement features" (due Wednesday)
├── Task: "QA and testing" (due Friday)
└── Task: "Deploy to production" (due Saturday)
```

### Using Tags for Workflow
Organize by tags to enable quick filtering:
```
Tags: bug, feature, documentation, review, urgent, blocked
Filter: Show me all [bug] and [urgent] tasks
```

### Priority-Based Focusing
Focus on what matters most:
```
"Show me all high-priority tasks"
"What high-priority tasks are overdue?"
"Update the high-priority blocked task"
```

## Integration with Your Workflow

### With Code Reviews
- Create task: "Review PR #123 for authentication module"
- Tag it: `code-review`, `urgent`
- Set priority: `high`
- Due date: tomorrow

### With Project Planning
- Create project for each initiative
- Add tasks as you discover work
- Update status as team progresses
- Check completion rate for velocity tracking

### With Daily Standup
- Run daily review to see pending items
- Call out overdue tasks needing attention
- Share completion statistics

## Limitations

- Text-based interface (no graphical UI)
- Single user (no multi-user collaboration)
- SQLite backend (local storage only)
- No time tracking (only due dates)

## Tips for Effectiveness

1. **Create tasks immediately** when you think of work
2. **Review overdue items** daily
3. **Update status regularly** for accurate tracking
4. **Use tags consistently** for better filtering
5. **Set reasonable due dates** to maintain credibility
6. **Review completion metrics** weekly to track productivity

## Related Skills and Features

This skill pairs well with:
- Version control systems (Git) for code-related tasks
- Documentation tools for tracking writing work
- Time tracking for productivity analysis
- Calendar integration for deadline visibility

---

**Note**: This skill automatically uses the task-tracker MCP server. Make sure the MCP server is registered and running for full functionality.
