---
name: linear
description: Comprehensive workflow for managing Linear issues. Use when creating, grooming, or working on Linear issues. Handles research-driven issue creation, project matching, feature decomposition into parallelizable sub-tasks, and execution with automatic state management. Proactively helps when user mentions Linear tickets or planning work.
---

# Linear Workflow Management

## When to Use This Skill

Claude should **proactively** use this skill when detecting:
- **Issue creation**: "create a Linear issue", "plan this work", "track in Linear", "log this as a bug"
- **Issue work**: "start work on BS-123", "implement BS-123", "work on Linear ticket BS-123"
- **Issue refinement**: "break BS-123 into sub-tasks", "add details to BS-123", "groom BS-123"
- **State transitions**: "approve BS-123", "move BS-123 to Todo", "mark BS-123 done"

## Core Workflows

This skill provides five interconnected workflows for complete Linear issue lifecycle management:

1. **Create Linear Issue** - Research-driven issue creation with templates
2. **Decompose Feature into Sub-Tasks** - Break features into parallelizable work
3. **Start Work on Issue** - Execute simple or complex issues with parallel agents
4. **Complete Work and Create PR** - Finish implementation and open pull requests
5. **Review and Finalize** - Merge PRs and mark issues complete

---

## Workflow 1: Create Linear Issue

**Triggers**: User requests to create/plan/track work

**Steps**:

### 1. Understand Request
- Infer issue type from description: Feature, Bug, Maintenance, or Docs
- If ambiguous, ask user: "Is this a feature, bug, maintenance task, or documentation?"
- Confirm understanding before proceeding

### 2. Conduct Research (automatic for Features and Bugs)

For Features and Bugs, invoke the research skill to gather context:

```
skill: "research"
```

The research skill will:
- Explore codebase for existing patterns and integration points
- Search online for best practices and approaches
- Query API documentation via Context7
- Return structured findings (2-3 minutes)

For Maintenance and Docs, use lighter exploration:
- Glob for relevant files
- Grep for specific patterns
- Quick codebase scan only

### 3. Ask Clarifying Questions

Use `AskUserQuestion` tool to gather details (2-4 questions):
- Technical decisions and library choices
- Implementation preferences
- Priority suggestion (1-4, default: 3)
- Difficulty estimate for features (1-5, default: 3)

### 4. Select and Populate Template

Choose template based on issue type:
- **Feature**: Comprehensive with research findings, scope, implementation context
- **Bug**: Focus on problem, location, root cause, fix approach
- **Maintenance**: Simple task description with steps
- **Docs**: Specific docs to update with relevant code context

Populate template with research findings and user responses.

### 5. For Features: Project Selection

If issue is a Feature:

a. Extract scope keywords from title and description (e.g., "auth", "api", "storage")

b. Query existing projects:
```
mcp__linear__list_projects
  filter:
    state: { in: ["started", "planned"] }
```

c. Present options via `AskUserQuestion`:
- Matching existing projects (with descriptions and issue counts)
- Suggest new project name based on feature scope
- Option to create standalone issue (no project)

### 6. Create Issue

First get current user:
```
mcp__linear__get_viewer
```

Then create issue with appropriate label:
```
mcp__linear__create_issue
  teamId: "2352bff0-6932-4e31-ac14-683063a9171d"
  title: "[Title from user request]"
  description: "[Populated template]"
  priority: 3  # Or user-suggested
  assigneeId: "<user-id-from-viewer>"
  projectId: "<project-id>"  # Optional, if project selected
  labelIds: ["<type-label-id>"]  # type:feature, type:bug, type:maintenance, or type:docs
```

**Note**: Type labels already exist in Blockchain Services team. Use existing label IDs.

### 7. Confirm Creation

Display confirmation:
```
✓ Created: BS-123
Type: Feature
URL: https://linear.app/...
State: Backlog
Priority: Normal (3)
Project: API Improvements

Next steps: Ready to move to Todo and break into sub-tasks?
```

---

## Workflow 2: Decompose Feature into Sub-Tasks

**Triggers**: Feature issue approved, user requests decomposition

**Prerequisites**: Issue must be type:feature and in Backlog state

**Steps**:

### 1. Fetch Feature Issue

```
mcp__linear__get_issue
  issueId: "BS-123"
```

Review the feature description, scope, and success criteria.

### 2. Analyze for Decomposition

Identify independent, parallelizable work units. Each sub-task should:
- Be implementable independently without blocking others
- Have clear, specific acceptance criteria
- Touch different files/areas to minimize merge conflicts
- Be completable in isolation (1-3 days of work)

Consider breaking by:
- **Component/Layer**: Backend vs Frontend vs Database
- **Functional Area**: Auth logic vs API endpoints vs Testing
- **Technical Task**: Data model vs Business logic vs UI vs Integration

### 3. Move Parent to Todo

Ask user for priority and difficulty if not already set:
```
mcp__linear__update_issue
  issueId: "BS-123"
  state: "Todo"
  priority: <user-selected-1-4>
  estimate: <difficulty-1-5>
```

Show: "✓ Moved BS-123 to Todo (Priority: 2, Difficulty: 4)"

### 4. Create Sub-Tasks

For each decomposed piece, create a detailed sub-task:

```
mcp__linear__create_issue
  teamId: "2352bff0-6932-4e31-ac14-683063a9171d"
  title: "[Specific implementation title]"
  description: """
Parent: BS-123 ([Feature Name])

## Implementation Details
[Specific technical approach for this sub-task]
[Reference to existing patterns found in research]

## Files to Modify
- `path/to/file1.py` - [specific changes needed]
- `path/to/file2.py` - [specific changes needed]

## Dependencies
[Any prerequisites or related sub-tasks, e.g., "Requires BS-124 data model"]

## Testing
[Specific test cases for this sub-task]
- Unit test: test_feature_x
- Integration test: test_integration_y

## Acceptance Criteria
- [ ] Implementation complete per specification
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] No merge conflicts with main
- [ ] Code reviewed
"""
  priority: 3
  assigneeId: "<user-id>"
  parentId: "<parent-issue-uuid>"
  labelIds: ["<type-feature-label-id>"]
```

### 5. Confirm Decomposition

Display created sub-tasks:
```
✓ Decomposed BS-123 into 4 parallelizable sub-tasks:
  - BS-124: JWT generation and validation logic
  - BS-125: Refresh token storage in Redis
  - BS-126: Protected route middleware
  - BS-127: Update API dependencies and configuration

Parallelization strategy: Each sub-task is independent and can be worked on simultaneously.

Next: Ready to start work?
```

---

## Workflow 3: Start Work on Issue

**Triggers**: User says "start work on BS-123", "implement BS-123", "begin BS-123"

**Steps**:

### 1. Fetch Issue and Sub-Tasks

```
mcp__linear__get_issue
  issueId: "BS-123"
```

Check for sub-tasks:
```
mcp__linear__list_issues
  filter:
    parent: { id: { eq: "<issue-uuid>" } }
```

### 2. Filter Workable Sub-Tasks

Only work on sub-tasks that need implementation:
- Include: `Backlog`, `Todo`, `In Progress` states
- Exclude: `In Review`, `Done`, `Canceled` states

This allows resuming work - if user has manually marked some sub-tasks as Done,
only the remaining ones will be worked on.

### 3. Determine Execution Strategy

#### If Simple Issue (no sub-tasks):

a. Generate branch name from issue:
   - Pattern: `<type>/<issue-id>-<slug>`
   - Example: `feat/BS-123-jwt-auth`
   - Slug: Lowercase, kebab-case from title

b. Create branch:
```bash
git checkout -b feat/BS-123-jwt-auth
```

c. Update state:
```
mcp__linear__update_issue
  issueId: "BS-123"
  state: "In Progress"
```

d. Show confirmation:
```
✓ Moved BS-123 to In Progress
Branch: feat/BS-123-jwt-auth

Beginning implementation...
```

e. Begin implementation in current session

#### If Complex Issue (has workable sub-tasks):

a. **Create feature worktree** and switch to it:
```bash
# Create worktree for the feature
git worktree add ~/.claude/worktrees/<repo>/BS-123-feature-name feat/BS-123-feature-name

# Change to the worktree directory
cd ~/.claude/worktrees/<repo>/BS-123-feature-name
```

b. **Update parent issue state**:
```
mcp__linear__update_issue
  issueId: "BS-123"
  state: "In Progress"
```

c. **Spawn parallel linear-worker subagents** (up to 10):

For each workable sub-task, spawn a `linear-worker` subagent via Task tool.
All subagents run in parallel in the same worktree directory.

```
Task(subagent_type="linear-worker", prompt="""
## Working Directory
/Users/ryan/.claude/worktrees/<repo>/BS-123-feature-name

## Parent Feature: BS-123 - JWT Authentication
High-level goal: Add JWT-based authentication to the API.

## Your Sub-Task: BS-124 - JWT Generation and Validation
[Full description from Linear issue]

### Implementation Details
[Details from sub-task description]

### Files to Create/Modify
- src/auth/jwt.py (new) - JWT utilities
- tests/test_jwt.py (new) - Unit tests

### Acceptance Criteria
- [ ] JWT generation with configurable expiry
- [ ] Token validation with proper error handling
- [ ] Unit tests with >90% coverage

## Instructions
1. Use ABSOLUTE paths for all file operations
2. Implement the feature as described
3. Write comprehensive tests
4. Commit your changes with clear messages
5. Update Linear: move BS-124 to "In Review" when complete
6. Report completion status at the end
""")
```

Repeat for each workable sub-task (BS-125, BS-126, etc.).

**Note**: Spawn all subagents in a single message with multiple Task tool calls
for true parallel execution.

d. **Show progress**:
```
✓ Started work on BS-123 with 4 parallel workers:
  - BS-124: JWT generation and validation
  - BS-125: Refresh token storage
  - BS-126: Protected route middleware
  - BS-127: API dependencies update

Subagents working... (file locks coordinate access)
```

### 4. Subagent Completion

Each subagent independently:
1. Implements its sub-task
2. Commits changes to the shared feature branch
3. Updates its Linear sub-task to "In Review"
4. Reports completion status

The parent session receives completion reports from each subagent.

### 5. Integrate Results

After all subagents complete:

a. Review the combined changes:
```bash
git log --oneline -10
git diff main...HEAD --stat
```

b. Run integration tests:
```bash
just test  # or pytest
```

c. Resolve any conflicts if needed

d. Proceed to Workflow 4 (Create PR)

### Constraints

**Maximum 10 Sub-Tasks**: Claude Code supports up to 10 concurrent subagents.
Features should be decomposed into at most 10 sub-tasks. Larger features
should be broken into multiple parent issues.

**File Locking**: Subagents use distributed file locking via Redis to prevent
conflicts. If a subagent needs a file that another holds, it waits (up to 60s).
Design sub-tasks to minimize file overlap.

**Resumable**: If you need to resume work on a feature (e.g., after fixing
issues), just run "start work on BS-123" again. Only sub-tasks not in
Done/In Review/Canceled states will be worked on

---

## Workflow 4: Complete Work and Create PR

**Triggers**: Work finished, user requests PR creation

**Steps**:

### 1. For Simple Issues:

a. Review changes with user

b. Commit if needed (or verify auto-commit from hooks)

c. Push branch:
```bash
git push -u origin feat/BS-123-jwt-auth
```

d. Create PR with Linear reference:
```bash
gh pr create \
  --title "feat(auth): add JWT authentication" \
  --body "$(cat <<'EOF'
Implements BS-123

## Summary
- Add JWT generation and validation
- Implement refresh token flow
- Add protected route middleware

## Test Plan
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing complete

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

e. Update Linear state:
```
mcp__linear__update_issue
  issueId: "BS-123"
  state: "In Review"
```

f. Show: "✓ Moved BS-123 to In Review"

g. Display PR URL

### 2. For Complex Issues with Sub-Tasks:

a. Wait for all sub-tasks to complete
   - Check: All agents finished
   - Verify: All sub-task branches pushed

b. Create integration branch:
```bash
git checkout -b feat/BS-123-jwt-auth-system main
```

c. Merge all sub-task branches:
```bash
git merge feat/BS-123/BS-124-jwt-validation
git merge feat/BS-123/BS-125-refresh-tokens
git merge feat/BS-123/BS-126-middleware
git merge feat/BS-123/BS-127-dependencies
```

d. Resolve any integration conflicts

e. Run integration tests:
```bash
pytest tests/integration/
```

f. Create PR for parent issue (similar to step 1d above)

g. Update all states:
```
# Parent
mcp__linear__update_issue(issueId: "BS-123", state: "In Review")

# All sub-tasks
for subtask in [BS-124, BS-125, BS-126, BS-127]:
    mcp__linear__update_issue(issueId: subtask, state: "In Review")
```

h. Show: "✓ Moved BS-123 and 4 sub-tasks to In Review"

i. Display PR URL and summary

---

## Workflow 5: Review and Finalize

**Triggers**: PR approved/merged, work complete

**Steps**:

### 1. Detect PR Status

From `<context-refresh>` block injected with each user prompt:
```
PR #45: Add JWT authentication (approved, checks: 3 passed)
```

Claude can automatically detect:
- PR exists and is approved
- All checks passing
- Ready to merge

### 2. Offer Actions

Based on PR status:

**If approved + checks passing**:
- Ask: "PR #45 is approved and all checks passed. Merge and mark BS-123 Done? (Y/n)"

**If needs changes**:
- No automatic action
- Wait for user to address feedback

**If checks failing**:
- Show: "PR #45 has failing checks. Need to fix before merging."

### 3. On User Confirmation to Merge

a. Merge PR:
```bash
gh pr merge --squash
```

b. Update Linear state:
```
mcp__linear__update_issue
  issueId: "BS-123"
  state: "Done"
```

c. For features with sub-tasks, mark all Done:
```
for subtask in [BS-124, BS-125, BS-126, BS-127]:
    mcp__linear__update_issue(issueId: subtask, state: "Done")
```

d. Show: "✓ Completed BS-123 and 4 sub-tasks"

### 4. Automatic Cleanup

Worktrees are cleaned automatically by `end-session` hook:
- Releases file locks
- Removes worktrees if clean (no uncommitted changes)
- No manual cleanup needed

---

## Issue Type Templates

### Feature Template

Use this for new features, capabilities, and major enhancements.

```markdown
## Objective
{High-level goal and business value - informed by research}

## Functionality
{What the feature does from user perspective}

## Implementation Context

**Existing Patterns:**
{Patterns found in codebase via exploration}
- Pattern 1: `src/auth/session.py:123` - Session-based auth
- Pattern 2: `src/api/deps.py:45` - Dependency injection

**Recommended Approach:**
{From research - libraries, architecture, best practices}
- Use python-jose for JWT handling
- Store refresh tokens in Redis with TTL
- Follow existing middleware pattern in src/api/middleware.py

**Files to Modify:**
{From codebase exploration}
- `src/auth/jwt.py` - New file for JWT logic
- `src/auth/tokens.py` - Token generation and validation
- `src/api/deps.py` - Add JWT dependency
- `src/api/middleware.py` - Protected route decorator
- `requirements.txt` - Add python-jose, redis

## Scope

**In Scope:**
- JWT generation and validation
- Refresh token flow with Redis storage
- Protected route middleware
- Token expiry and renewal

**Out of Scope:**
- OAuth2 integration (future)
- Token revocation (future)
- Multi-factor authentication (future)

## Testing Requirements
{Test scenarios from research and requirements}
- Unit test: JWT generation with valid claims
- Unit test: JWT validation with expired token
- Integration test: Protected endpoint with valid token
- Integration test: Refresh token flow end-to-end

## Success Criteria
- [ ] JWT authentication working end-to-end
- [ ] All tests passing (unit + integration)
- [ ] Documentation updated
- [ ] No security vulnerabilities
- [ ] Performance acceptable (<100ms token validation)
```

### Bug Template

Use this for bugs, errors, and unexpected behavior.

```markdown
## Problem
{Unexpected behavior observed}

Users cannot log in after password reset. The login endpoint returns 401 Unauthorized even with correct new password.

## Expected Behavior
{What should happen}

After successful password reset, users should be able to log in immediately with their new password.

## Codebase Location
{From Explore agent - specific files and lines}
- `src/auth/password.py:78` - Password reset logic
- `src/auth/login.py:45` - Login validation
- `src/models/user.py:123` - User model password field

## Root Cause Analysis
{Technical explanation of why bug occurs}

Password reset updates `user.password_hash` but doesn't invalidate the cached session key in Redis. Login checks both password hash AND cached session, causing mismatch.

## Proposed Fix
{How to fix it}

After password reset, invalidate cached session:
```python
redis_client.delete(f"session:{user.id}")
```

## Test Approach
{How to verify fix and prevent regression}
- Test case 1: Reset password, verify immediate login succeeds
- Test case 2: Reset password, verify old session invalidated
- Regression test: Add test_password_reset_invalidates_session

## Acceptance Criteria
- [ ] Bug fixed and verified with test case
- [ ] Regression tests added and passing
- [ ] No side effects in related auth functionality
- [ ] Manual testing confirms fix
```

### Maintenance Template

Use this for refactoring, tech debt, dependency updates, and routine maintenance.

```markdown
## Task
{Simple description of maintenance work}

Upgrade FastAPI from 0.104.0 to 0.110.0 and update related dependencies.

## Context
{Why this maintenance is needed}

FastAPI 0.110.0 includes important security fixes and performance improvements. Also prepares for Python 3.12 compatibility.

## Files to Modify
{From exploration}
- `requirements.txt` - Update FastAPI and dependencies
- `pyproject.toml` - Update version constraints
- `src/api/app.py` - Update deprecated imports
- `tests/conftest.py` - Update test fixtures

## Steps
1. Update `requirements.txt` with new versions
2. Run `pip install -r requirements.txt` in dev environment
3. Update deprecated imports (FastAPI 0.110 changes)
4. Run full test suite
5. Update documentation if API changes
6. Test locally with dev server

## Acceptance Criteria
- [ ] All dependencies updated
- [ ] All tests passing
- [ ] No deprecated warnings
- [ ] Dev and prod environments tested
```

### Docs Template

Use this for documentation updates, README improvements, and API docs.

```markdown
## Documentation to Update
{Specific docs found via Glob}
- `docs/api/authentication.md` - Add JWT auth section
- `README.md` - Update authentication section
- `docs/setup.md` - Add Redis setup for tokens

## Relevant Code
{Code context from exploration}
- `src/auth/jwt.py` - JWT implementation to document
- `src/api/deps.py:get_current_user` - Auth dependency to document

## Changes Overview
{What needs to be documented}

Add comprehensive JWT authentication documentation:
1. How JWT auth works in the API
2. How to obtain and refresh tokens
3. How to make authenticated requests
4. Token expiry and renewal process
5. Security considerations

Include code examples for:
- Login to get JWT
- Using JWT in requests
- Refreshing expired tokens

## Acceptance Criteria
- [ ] Documentation complete and accurate
- [ ] Code examples tested and working
- [ ] Screenshots/diagrams included where helpful
- [ ] Reviewed for clarity and completeness
```

---

## Team Defaults (ALWAYS ENFORCE)

**Team**: Blockchain Services
- **Key**: `BS`
- **ID**: `2352bff0-6932-4e31-ac14-683063a9171d`

**States** (in order):
1. `Backlog` - New issues (default)
2. `Todo` - Ready to work (after approval)
3. `In Progress` - Active work
4. `In Review` - PR open, awaiting review
5. `Done` - Completed

**Priorities**:
- `1` Urgent - System down, data loss, security breach
- `2` High - Major bug, blocking work
- `3` Normal - **DEFAULT** - Standard work
- `4` Low - Nice-to-have, non-urgent

**Issue Labels** (already exist in team):
- `type:feature` - New features and capabilities
- `type:bug` - Bugs and errors
- `type:maintenance` - Refactoring, tech debt, updates
- `type:docs` - Documentation work

**New Issue Defaults**:
- Team: BS
- Assigned to: Current user (via `mcp__linear__get_viewer`)
- Priority: 3 (Normal)
- State: Backlog
- Label: Based on issue type

---

## MCP Tools Reference

All Linear operations use MCP tools with prefix `mcp__linear__`.

### Get Current User

Always call this first to get user ID for assignments:

```
mcp__linear__get_viewer
```

Returns: `{ id, name, email }`

### List Issues

Query issues with filters:

```
mcp__linear__list_issues
  filter:
    team: { key: { eq: "BS" } }
    assignee: { id: { eq: "<user-id>" } }
    state: { name: { in: ["In Progress", "Todo"] } }
```

**Common filters**:
- `team: { key: { eq: "BS" } }` - Filter by team
- `assignee: { id: { eq: "<user-id>" } }` or `assignee: { isMe: { eq: true } }` - By assignee
- `state: { name: { eq: "In Progress" } }` - By state
- `state: { type: { nin: ["completed", "canceled"] } }` - Exclude completed
- `parent: { id: { eq: "<parent-uuid>" } }` - Get sub-tasks

### Get Issue

Fetch full issue details:

```
mcp__linear__get_issue
  issueId: "BS-123"
```

Returns: Full issue including description, state, assignee, labels, comments

### Create Issue

Create new issue:

```
mcp__linear__create_issue
  teamId: "2352bff0-6932-4e31-ac14-683063a9171d"
  title: "Issue title"
  description: "Issue description in markdown"
  priority: 3
  assigneeId: "<user-id-from-viewer>"
  projectId: "<project-id>"  # Optional
  parentId: "<parent-uuid>"  # Optional, for sub-tasks
  labelIds: ["<label-id>"]  # Optional, for issue types
```

**Important**: Always get user ID first with `mcp__linear__get_viewer`

### Update Issue

Update issue fields:

```
mcp__linear__update_issue
  issueId: "BS-123"
  state: "In Progress"
  priority: 2
  estimate: 4
```

Can also use UUIDs:
```
mcp__linear__update_issue
  issueId: "<issue-uuid>"
  stateId: "<state-uuid>"
  assigneeId: "<user-uuid>"
```

### List Projects

Query projects:

```
mcp__linear__list_projects
  filter:
    state: { in: ["started", "planned"] }
```

Returns: Projects with name, state, issue count, description

### Add Comment

Add comment to issue:

```
mcp__linear__add_comment
  issueId: "BS-123"
  body: "Comment text in markdown"
```

---

## Project Management

### When to Use Projects

**YES - Use projects for**:
- Feature development (multiple related issues)
- Infrastructure projects (migrations, upgrades)
- Time-boxed work (clear start/end dates)
- Cross-team initiatives
- Quarterly goals

**NO - Don't use projects for**:
- Single standalone issues
- Ongoing maintenance without clear endpoint
- Individual bug fixes (unless part of larger initiative)
- Administrative tasks

### Project Matching Strategy

For features, match against existing projects:

1. Extract keywords from feature title/description
2. Query active projects (`state: started or planned`)
3. Compare keywords to project names and descriptions
4. Present best matches to user
5. Offer to create new project if no good match
6. Allow standalone (no project) option

### Project Naming Conventions

**Good examples**:
- "Migrate Vault to OpenBao"
- "Implement Cluster Autoscaling"
- "Q4 2024 Security Improvements"
- "API v2 - GraphQL Migration"

**Bad examples**:
- "Project 1"
- "Infrastructure"
- "Misc Work"

**Patterns**:
- Feature: `[Feature Name] - [Brief Description]`
- Infrastructure: `[System] - [Action/Goal]`
- Migration: `Migrate [From] to [To]`
- Time-boxed: `[Quarter/Year] [Theme]`

---

## Branch Naming

Generate branch names from Linear issue data:

**Pattern for simple issues**:
```
<type>/<issue-id>-<slug>
```

**Pattern for sub-tasks**:
```
<type>/<parent-id>/<issue-id>-<slug>
```

**Examples**:
- `feat/BS-123-jwt-auth`
- `fix/BS-456-null-pointer`
- `feat/BS-123/BS-124-jwt-validation`
- `chore/BS-789-upgrade-fastapi`

**Slug generation**:
- Lowercase title
- Replace spaces with hyphens
- Remove special characters
- Truncate to 50 chars max

---

## Troubleshooting

**MCP connection fails**:
- Run `/mcp` in Claude Code to check connection status
- Re-authenticate if needed via Linear OAuth flow
- Verify installation: `claude mcp add --transport sse linear https://mcp.linear.app/sse`

**Issue creation fails**:
- Verify team ID: `2352bff0-6932-4e31-ac14-683063a9171d`
- Ensure title is not empty
- Get user ID first with `mcp__linear__get_viewer`
- Check label IDs are valid

**State transition not applied**:
- Use exact state name: "In Progress" not "in progress"
- Verify issue ID is correct format (BS-123)
- Check issue exists and is not archived

**Cannot spawn parallel agents**:
- Check multiplexing: `agentctl session check`
- Verify WezTerm or tmux is running
- Check Redis is running (for file locking)

**Sub-tasks not found**:
- Use parent UUID, not issue identifier
- Query with `parent: { id: { eq: "<uuid>" } }` filter
- Verify parent-child relationship was created

---

## Quick Reference

**Create simple bug**:
```
1. skill: "linear"
2. Research bug location
3. Create issue with bug template
4. Start work: git checkout -b fix/BS-X-description
```

**Create feature with sub-tasks**:
```
1. skill: "linear"
2. skill: "research" (automatic)
3. Create feature issue with template
4. Decompose into sub-tasks
5. Start parallel work: agentctl session create for each
```

**Check progress**:
```
agentctl session list
```

**Complete and merge**:
```
1. Create PR: gh pr create
2. Wait for approval
3. Merge: gh pr merge --squash
4. State auto-updates to Done
```
