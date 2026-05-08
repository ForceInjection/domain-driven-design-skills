---
name: liaison-workflows
description: Task management and workflow patterns using liaison. Use when managing tasks, creating workflows, or working with task-driven automation.
license: MIT
metadata:
  author: liaison-toolkit
  version: "2.0"
---

# Liaison Workflows

Complete guide to task management and workflow automation using the Liaison CLI.

## When to use this skill

Use this skill when:
- Creating tasks with `liaison task create`
- Managing task status and lifecycle
- Working with task-driven workflows
- Setting up automatic workflow triggers
- Monitoring task completion and metrics

## Task Management

### Creating Tasks

Use `liaison task create` to create new tasks:

```bash
# Basic task
liaison task create "Fix security vulnerability"

# With description
liaison task create "Fix security vulnerability" --description "Patch XSS in login form"

# With priority
liaison task create "Fix security vulnerability" --priority critical

# With auto-trigger
liaison task create "Security audit required" --auto-trigger "security-response"

# With assignment
liaison task create "Review pull request" --assigned-to @username
```

### Task Status

Check task status with `liaison task list`:

```bash
# List all tasks
liaison task list

# Filter by status
liaison task list --status closed

# Filter by priority
liaison task list --priority critical

# Output as JSON
liaison task list --format json
```

### Updating Tasks

Update task status with `liaison task update`:

```bash
# Mark as in-progress
liaison task update TASK-ID --status in-progress

# Mark as completed
liaison task update TASK-ID --status closed

# Add assignee
liaison task update TASK-ID --assigned-to @username
```

## Workflow Triggers

### Priority-Based Auto-Triggers

Tasks automatically trigger workflows based on priority:

| Priority | Auto-Triggered Workflow |
|-----------|----------------------|
| critical | security-response |
| high | high-priority-response |
| medium | standard-workflow |
| low | backlog-workflow |

Example:
```bash
liaison task create "Critical security issue" --priority critical
# Automatically triggers security-response workflow
```

### Keyword-Based Auto-Triggers

Tasks can specify which workflow to trigger:

```bash
liaison task create "Update documentation" --auto-trigger "documentation-update"
```

**Available keywords:**
- `security` → security-response workflow
- `bug` → bug-fix workflow
- `production` → deployment workflow
- `documentation` → documentation-update workflow
- `testing` → qa-testing workflow

### Explicit Auto-Triggers

Force a specific workflow regardless of task content:

```bash
liaison task create "Custom task" --auto-trigger "custom-workflow"
```

## Task-Driven Workflow Integration

Liaison implements complete task-driven workflow automation:

### How It Works

1. **Task Created** → Event Emitted
2. **Agentic Workflow Manager** → Evaluates Triggers
3. **Matches Found** → Workflow Activated
4. **Subtasks Created** → Additional automation
5. **Task Completed** → Workflow Completes

### Closed-Loop System

The system creates a virtuous cycle where work generates more work:

```
User Task → Workflow → Subtasks → More Tasks → More Workflows → ...
```

This enables:
- **Self-Optimizing**: The system continuously improves itself
- **Scalable**: Add more workflows, system scales automatically
- **Reduced Manual Work**: Automation handles repetitive tasks
- **Faster Resolution**: Specialized workflows respond faster

### Workflow Types

Liaison supports multiple workflow types:

#### 1. Security Response
Triggered by critical priority tasks handling security issues.

**Auto-Created Subtasks:**
- Investigation task
- Patch development task
- Verification task
- Deployment task

#### 2. Bug Fix
Triggered by tasks containing "bug" or production keywords.

**Auto-Created Subtasks:**
- Reproduction task
- Fix development task
- Testing task
- Deployment task

#### 3. Documentation Update
Triggered by documentation tasks.

**Process:**
- Update API docs
- Generate changelog
- Create pull request

#### 4. High Priority Response
Triggered by high priority tasks.

**Process:**
- Acknowledge task
- Plan approach
- Execute within SLA
- Update status

#### 5. Standard Workflow
Triggered by medium priority tasks.

**Process:**
- Queue task
- Assign to available agent
- Monitor progress
- Complete and report

#### 6. Quality Assurance
Triggered by QA workflows.

**Process:**
- Run tests
- Review code
- Verify quality gates
- Report results

### Workflow Configuration

Workflows are defined in configuration files. Create custom workflows:

```bash
# List available workflows
liaison workflow list

# Create new workflow
liaison workflow create "code-review" --trigger "task-created:tag=pull-request"
```

### Monitoring Workflows

Track workflow execution:

```bash
# Workflow status
liaison workflow status

# Execution history
liaison workflow history --limit 10
```

## Best Practices

### Task Creation

1. **Use Descriptive Titles**
   ```bash
   ✅ Good: "Security: Fix XSS in login form"
   ❌ Bad: "Fix security thing"
   ```

2. **Set Appropriate Priority**
   ```bash
   --priority critical   # Security, production outages
   --priority high      # Production bugs, performance issues
   --priority medium     # Feature requests, improvements
   --priority low        # Documentation, minor fixes
   ```

3. **Include Auto-Triggers Wisely**
   ```bash
   # Good - Use specific workflows
   liaison task create "Add authentication" --auto-trigger "security-response"
   
   # Avoid - Don't over-trigger on everything
   # liaison task create "Update docs" --no-auto-trigger
   ```

4. **Write Clear Descriptions**
   ```bash
   # Good
   "Implement OAuth2 authentication using JWT tokens"
   
   # Bad
   "Auth stuff"
   ```

### Workflow Management

1. **Define Clear Triggers**
   - Be specific about what activates a workflow
   - Use priority-based for critical issues
   - Use keyword matching for domain-specific workflows

2. **Keep Workflows Focused**
   - One workflow per purpose
   - Avoid overly complex multi-purpose workflows
   - Break complex workflows into smaller ones

3. **Monitor Workflow Performance**
   ```bash
   liaison workflow metrics
   liaison workflow history
   ```
`

4. **Handle Workflow Failures**
   - Always log failures
   - Create rollback procedures
   - Set up alerting for critical workflows

### Duplicate Prevention

Tasks automatically check for duplicates before creation:

```bash
# Default behavior (checks for 80% similarity)
liaison task create "New feature"

# Bypass check (only use for intentional duplicates)
liaison task create "Known duplicate" --force-create

# Disable check entirely (batch operations)
liaison task create --no-check-duplicates task1 task2 task3
```

## Common Patterns

### Security Issue Handling

```
User: "Found security issue"

Process:
1. liaison task create "Investigate XSS vulnerability" --priority critical
2. Automatically triggers: security-response workflow
3. Workflow creates: investigation, patch, verification tasks
4. Complete verification → patch deployed
```

### Feature Development

```
User: "Add user authentication"

Process:
1. liaison task create "Design auth system" --priority medium
2. liaison task create "Implement JWT tokens" --auto-trigger "development-workflow"
3. liaison task create "Write auth tests" --auto-trigger "qa-testing"
4. liaison task create "Deploy to staging" --auto-trigger "deployment-workflow"
5. Development workflow manages all subtasks automatically
```

### Documentation Updates

```
User: "Update API docs"

Process:
1. liaison task create "Review current docs" --priority low
2. Development workflow triggers automatically
3. Documentation workflow processes all changes
4. Generate changelog and create PR
```

## Integration with Other Skills

This skill works alongside other skills:

- **Git Automation** (.skills/git-automation/SKILL.md) - Version control for task tracking
- **Library Research** (.skills/library-research/SKILL.md) - Research for implementing new features
- **Bun Development** (.skills/bun-development/SKILL.md) - Using the right build tools

### Workflow Example

Combining skills for complex automation:

```
User: "Add new user onboarding feature"

Automation:
1. [Liaison Workflows] Creates tasks for design, implementation, testing
2. [Git Automation] Creates feature branch with proper naming
3. [Library Research] Researches existing auth libraries
4. [QA Testing] Validates all changes
5. [Deployment Workflow] Deploys to staging
6. Automatic triggers coordinate all workflows
```

## References

- [Task-Driven Workflow Order](../docs/workflows/task-driven-workflow-order.md)
- [Liaison CLI](../../README.md)
- [Workflow Commands](../../packages/liaison/src/commands/workflow.ts)
- [Task Commands](../../packages/liaison/src/commands/task.ts)

## Keywords

liaison, task, workflow, automation, task-driven, triggers, auto-trigger, subtasks, security, bug-fix, deployment, testing, qa, priorities, closed-loop
