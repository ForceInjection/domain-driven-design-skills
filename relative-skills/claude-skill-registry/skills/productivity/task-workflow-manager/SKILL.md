---
name: Task Workflow Manager
description: Complete task lifecycle management system with state-based workflow. Define, refine, implement, and review tasks with automated quality gates and intelligent discovery.
trigger: manual
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
  - TodoWrite
---

# Purpose

Manage complete task lifecycle from initial definition through implementation to review and completion. Provides state-based workflow with automated transitions, intelligent task discovery, quality gates, and framework-aware implementation patterns.

**Tip**: For smoother workflow without permission prompts, consider adding `["Read", "Write", "Edit", "Glob", "Bash", "TodoWrite"]` to `dangerouslySkipPermissions` in your project's `.claude/settings.json`.

## Variables

TASK_ID_PREFIX: TASK              # Project prefix for task IDs (TASK, BROOKLY, JIRA, etc.)
TASK_ID_START: 1                  # Starting number for new task sequences
TASK_ID_PADDING: 3                # Number of digits for task IDs (3 = 001, 006, 042)
TASK_DIR: ./tasks                 # Directory where task files are stored
TASK_FILE_FORMAT: {prefix}-{id} [{state}] ({category}): {slug}.md # Filename template

STATE_INITIAL: toRefine           # First state after task creation
STATE_READY: toImplement          # Requirements refined, ready for coding
STATE_REVIEW: toReview            # Implementation complete, needs review
STATE_COMPLETE: done              # Fully finished and approved

ENABLE_LINT: true                 # Run linting during implement/review workflows
ENABLE_TYPECHECK: true            # Run type checking validation
ENABLE_BUILD: true                # Run build verification
ENABLE_TESTS: true                # Run test suite execution
ENABLE_SECURITY_SCAN: false       # Run security vulnerability scanning

AUTO_DETECT_FRAMEWORK: true       # Automatically detect project framework
DEFAULT_FRAMEWORK: generic        # Fallback framework if detection fails
SUPPORTED_FRAMEWORKS: generic, nextjs, django, react, python # Currently supported

COMMIT_STYLE: conventional        # Commit message convention (conventional, angular, custom)

## Workflow

1. **Parse User Request**

   - Identify workflow command intent from user input
   - Commands: "define task", "refine task", "implement task", "review task"
   - Extract task identifier if provided (ID, keywords, category)
   - Example: "define task: add user authentication" → Intent: define, Description: "add user authentication"

2. **Determine Workflow Phase**

   - IF: "define" OR "create" OR "new task" → Route to Define workflow
   - IF: "refine" OR "clarify" OR "interview" → Route to Refine workflow
   - IF: "implement" OR "code" OR "build" → Route to Implement workflow
   - IF: "review" OR "check" OR "validate" → Route to Review workflow
   - Example: "refine task 006" → Phase: refine, Task ID: 006

3. **Detect Project Framework**

   - IF: AUTO_DETECT_FRAMEWORK is true → Scan for framework indicators
   - Check for: package.json (Node.js), requirements.txt (Python), go.mod (Go)
   - Analyze dependencies and config files to determine specific framework
   - Example: package.json with "next" dependency → Framework: nextjs

4. **Route to Cookbook**

   - Based on workflow phase and detected framework
   - Define workflow: cookbook/define.md (framework-agnostic)
   - Refine workflow: cookbook/refine.md (framework-agnostic)
   - Implement workflow: cookbook/implement/{framework}.md (e.g., generic.md, nextjs.md)
   - Review workflow: cookbook/review/{framework}.md (e.g., generic.md, nextjs.md)
   - Example: Phase=implement + Framework=nextjs → cookbook/implement/nextjs.md

5. **Execute Workflow**

   - Load appropriate cookbook workflow
   - Follow workflow steps with current Variables configuration
   - Use TASK_DIR, TASK_ID_PREFIX, and other Variables throughout
   - Apply quality gates if ENABLE_* variables are true
   - Example: Execute implement workflow using TASK-006, run lint+typecheck+build+test

6. **Report Results**

   - Summarize workflow execution
   - Show task state transitions (if applicable)
   - List files created/modified
   - Display next steps in workflow
   - Example: "Task TASK-006 transitioned from [toImplement] to [toReview]. Run review workflow next."

## Cookbook

### Define Task Workflow

- IF: User wants to create new task specification
- THEN: Read and execute: `.claude/skills/task-workflow/cookbook/define.md`
- EXAMPLES:
  - "define task: add user authentication"
  - "create new task for fixing navigation bug"
  - "new task: implement dark mode"

### Refine Task Workflow

- IF: User wants to clarify task requirements
- THEN: Read and execute: `.claude/skills/task-workflow/cookbook/refine.md`
- EXAMPLES:
  - "refine task 006"
  - "clarify requirements for TASK-006"
  - "interview me about the authentication task"

### Implement Task Workflow

- IF: User wants to implement task
- THEN: Detect framework, Read and execute: `.claude/skills/task-workflow/cookbook/implement/{framework}.md`
- Framework detection: generic (default), nextjs, django, react, python
- EXAMPLES:
  - "implement task 006" → cookbook/implement/generic.md (default)
  - "implement task 006" (in Next.js project) → cookbook/implement/nextjs.md
  - "build TASK-006" → framework-aware routing

### Review Task Workflow

- IF: User wants to review task
- THEN: Detect framework, Read and execute: `.claude/skills/task-workflow/cookbook/review/{framework}.md`
- Framework detection: generic (default), nextjs, django, react, python
- EXAMPLES:
  - "review task 006" → cookbook/review/generic.md (default)
  - "review task 006" (in Next.js project) → cookbook/review/nextjs.md
  - "validate TASK-006" → framework-aware routing
