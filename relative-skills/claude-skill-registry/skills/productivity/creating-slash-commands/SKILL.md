---
name: Creating Slash Commands
description: Build custom slash commands in Claude Code with YAML frontmatter, permissions, and best practices. Use when creating automation workflows, project-specific commands, or standardizing repetitive tasks.
---

# Creating Slash Commands

## Overview

Slash commands automate workflows by encapsulating multi-step processes into reusable commands. They support YAML frontmatter for permissions, can integrate with CLI tools, and enable sophisticated decision logic.

## When to Use

- Automate repetitive multi-step workflows
- Standardize team processes (issue triage, PR reviews, etc.)
- Integrate external tools (GitHub CLI, git, custom scripts)
- Create project-specific automation patterns

## Process

1. **Create command file** in `.claude/commands/[name].md`
2. **Add YAML frontmatter** with permissions and description
3. **Write command prompt** with clear steps and decision logic
4. **Use $ARGUMENTS** variable for dynamic input
5. **Test command** with `/<command-name> [args]`

## Command Structure

### Basic Template

```markdown
# .claude/commands/my-command.md
---
allowed-tools: Bash(git:*),Read,Edit
description: Brief description of what this command does
---

Command instructions here. Use $ARGUMENTS to reference user input.

Steps:
1. First action
2. Second action
3. Final action
```

### YAML Frontmatter Fields

- `allowed-tools`: Restrict which tools the command can use
  - Examples: `Bash(gh:*)`, `Bash(git:*)`, `Read`, `Edit`, `Write`
  - Use wildcards: `Bash(pytest:*)` allows any pytest command
- `description`: One-line summary shown in command list

### Permission Patterns

```yaml
# Specific command only
allowed-tools: Bash(gh issue view:*)

# Multiple related commands
allowed-tools: Bash(gh issue view:*),Bash(gh issue comment:*)

# Tool categories
allowed-tools: Read,Edit,Grep,Glob

# Combined patterns
allowed-tools: Bash(git:*),Bash(gh:*),Read,Write
```

## Reference Example: Issue Triage Command

This project's `/plan-issue` demonstrates sophisticated automation:

```markdown
# .claude/commands/plan-issue.md
---
allowed-tools: Bash(gh issue view:*),Bash(gh issue comment:*)
description: Respond to a github issue with a plan of action
---

You are an expert software developer and project manager. Respond to GitHub issue $ARGUMENTS with a detailed plan. Steps:
1. Fetch issue: `gh issue view <issue-number>`
2. Analyze description and comments
3. Comment you're working on a plan: `gh issue comment <issue-number> --body "<your-comment>"`
4. Review codebase for context
5. Assess clarity: Need more info?
  - Yes: Comment clarifying questions, stop and wait
  - No: Proceed to step 6
6. Break down into smaller tasks
7. Comment detailed plan: `gh issue comment <issue-number> --body "<your-plan>"` with:
  - Issue summary
  - Resolution steps
  - Dependencies and considerations
```

**Key strengths:**
- Specific tool permissions (only issue view/comment)
- Multi-step workflow with decision branching
- GitHub CLI integration
- Context-aware (reads codebase before planning)
- Conditional logic (asks questions when unclear)

## Best Practices

### Permissions
- ✅ **Do**: Use specific tool permissions to limit scope
- ✅ **Do**: Use wildcards for command families (`Bash(git:*)`)
- ❌ **Don't**: Grant broad permissions without reason

### Command Design
- ✅ **Do**: Include decision logic for complex workflows
- ✅ **Do**: Read relevant context before taking action
- ✅ **Do**: Use CLI tool integration (gh, git, etc.)
- ❌ **Don't**: Assume context without verification
- ❌ **Don't**: Skip validation steps

### Structure
- ✅ **Do**: Number steps clearly
- ✅ **Do**: Use $ARGUMENTS for user input
- ✅ **Do**: Include clear success criteria
- ❌ **Don't**: Write vague instructions
- ❌ **Don't**: Omit error handling guidance

## Integration Patterns

### With Skills
Reference skill files in commands:

```markdown
---
description: Review code using TDD skill
---

1. Read skill: .claude/skills/testing/test-driven-development.md
2. Apply skill to files: $ARGUMENTS
3. Report findings
```

### With GitHub CLI
```markdown
---
allowed-tools: Bash(gh:*)
---

1. Fetch PR: `gh pr view $ARGUMENTS`
2. Get diff: `gh pr diff $ARGUMENTS`
3. Review and comment
```

### With Git
```markdown
---
allowed-tools: Bash(git:*)
---

1. Check status: `git status`
2. Stage changes: `git add $ARGUMENTS`
3. Commit with message
```

## Common Use Cases

### Workflow Automation
- Issue triage and planning
- PR review orchestration
- Release preparation
- Testing workflows

### Code Operations
- Batch refactoring
- Migration scripts
- Code generation
- Style enforcement

### Project Management
- Status reporting
- Documentation generation
- Dependency updates
- Configuration management

## Anti-patterns

- ❌ **Don't**: Create commands for single-step tasks
  - ✅ **Do**: Reserve commands for multi-step workflows

- ❌ **Don't**: Grant unlimited tool access
  - ✅ **Do**: Use specific allowed-tools restrictions

- ❌ **Don't**: Skip context gathering
  - ✅ **Do**: Read relevant files before action

- ❌ **Don't**: Write commands without decision logic
  - ✅ **Do**: Include conditional workflows for edge cases

- ❌ **Don't**: Ignore error scenarios
  - ✅ **Do**: Specify what to do when things fail

## Resources

- **Official Docs**: https://docs.claude.com/en/docs/claude-code/slash-commands
- **Settings Reference**: https://docs.claude.com/en/docs/claude-code/settings
- **Permissions Guide**: https://docs.claude.com/en/docs/claude-code/iam
