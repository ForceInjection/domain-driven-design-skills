---
name: linear-project-management
description: Skill for Linear project management tasks including creating projects, creating issues, and reviewing project structures. Use when working with Linear project setup, issue creation, project planning, or any Linear organizational tasks.
---

# Linear Project Management Skill

When this skill is activated, you MUST follow these steps:

1. **Load Linear Conventions**: Use the Read tool to read `.claude/rules/linear/README.md` from the user's project directory.

2. **Follow Loaded Rules**: The README.md file contains all necessary guidance for Linear project management tasks. Follow the instructions and conventions defined there.

## 🚨 MANDATORY CHECKPOINT - Linear Project Creation

**BEFORE creating any Linear project**, you MUST follow this workflow:

1. **Draft the project description** following all conventions (branch, purpose, scope, etc.)
2. **STOP** - Do not create the project yet
3. **Invoke the reviewer** using the Task tool:
   ```
   subagent_type: "project-roles:linear-project-description-reviewer"
   prompt: "Review this Linear project description: [paste description]"
   ```
4. **Address all feedback** from the reviewer
5. **ONLY THEN** create the project using `mcp__linear-server__create_project`

❌ WRONG: Draft description → Immediately create project
✅ RIGHT: Draft description → Get reviewed → Address feedback → Create project

**You do NOT have discretion to skip review.** This ensures every project provides comprehensive context for agents working on its issues.

## When This Skill Activates

This skill activates for:
- Creating new Linear projects
- Creating Linear issues
- Reviewing Linear project structures
- Planning or organizing work in Linear
- Any task involving Linear project management conventions

## Implementation Pattern

Always start by reading the conventions:

```
1. Read .claude/rules/linear/README.md
2. Follow the guidance provided in that file
3. Apply the conventions to your current task
```

The conventions file is the single source of truth for how Linear project management should be handled in this project.
