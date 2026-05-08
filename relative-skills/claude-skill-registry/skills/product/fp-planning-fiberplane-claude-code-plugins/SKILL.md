---
name: FP Planning
description: This skill should be used when the user asks to "create a plan", "break down feature", "design implementation", "structure this work", "plan out", "decompose task", or "create roadmap". Provides plan creation and breakdown patterns for the FP CLI including issue hierarchy and dependency modeling.
---

# FP Planning Skill

**Plan creation and breakdown patterns for the FP CLI**

## Core Planning Concepts

### Plans as Issues

**Key insight**: In FP, plans are just elaborate issues. There's no separate "plan" entity.

A plan is an issue that:
- Has a comprehensive description (the plan document)
- Has child issues (the tasks/sub-tasks)
- May have dependencies between children
- Starts with status "todo" and transitions to "done" when all children are done

### Issue Hierarchy

```
Plan (Parent Issue)
├── Task 1 (Child Issue)
│   ├── Sub-task 1.1 (Grandchild)
│   └── Sub-task 1.2 (Grandchild)
├── Task 2 (Child Issue)
└── Task 3 (Child Issue)
```

You can nest as deep as needed, but 2-3 levels is typical:
- **Level 1**: Plan/Epic
- **Level 2**: Feature/Task
- **Level 3**: Sub-task/Implementation step

### Dependency Modeling

Issues can depend on other issues at any level:
- **Serial**: Task B depends on Task A (must be sequential)
- **Parallel**: Tasks A and B have no dependencies (can be concurrent)
- **Fan-out**: Tasks B and C both depend on Task A
- **Fan-in**: Task D depends on both B and C

Dependencies are directional: "FP-3 depends on FP-2" means FP-2 must complete before FP-3 can start.

## Planning Workflow

### Phase 1: Create the Plan Issue

Start with the top-level plan/epic:

```bash
fp issue create \
  --title "Add user authentication system" \
  --description "Implement OAuth2 authentication with GitHub provider.

Goals:
- Support GitHub OAuth login
- Store user sessions securely
- Provide middleware for protected routes
- Handle token refresh

Technical approach:
- Use Cloudflare D1 for session storage
- OAuth2 library for GitHub integration
- JWT tokens for session management

Success criteria:
- Users can log in with GitHub
- Sessions persist across requests
- Protected routes require authentication"
```

This creates FP-1 (or whatever the next ID is).

### Phase 2: Break Down Into Tasks

Identify major components/phases:

```bash
# Foundation: Data models
fp issue create \
  --title "Design and implement data models" \
  --parent FP-1 \
  --description "Create TypeScript schemas and database tables for User, Session, and Token models.

Details:
- User model: id, githubId, email, name, avatarUrl
- Session model: id, userId, token, expiresAt
- Token model: id, userId, accessToken, refreshToken, expiresAt

Files to modify:
- src/models/user.ts
- src/models/session.ts
- src/models/token.ts
- drizzle/schema.ts"
```

This creates FP-2 as a child of FP-1.

```bash
# OAuth integration
fp issue create \
  --title "Implement GitHub OAuth flow" \
  --parent FP-1 \
  --depends "FP-2" \
  --description "Set up OAuth2 flow with GitHub:
- Redirect to GitHub authorization
- Handle callback with authorization code
- Exchange code for access token
- Fetch user info from GitHub API

Files:
- src/auth/oauth.ts (new)
- src/routes/auth.ts (new)"
```

This creates FP-3 as a child of FP-1, dependent on FP-2.

```bash
# Session management
fp issue create \
  --title "Implement session management" \
  --parent FP-1 \
  --depends "FP-2,FP-3" \
  --description "Create session creation, validation, and cleanup logic.

Features:
- Create session on successful login
- Validate session on each request
- Refresh expired sessions
- Clean up old sessions (cron job)

Files:
- src/auth/session.ts (new)
- src/middleware/auth.ts (new)"
```

This creates FP-4, dependent on both FP-2 and FP-3.

```bash
# Frontend UI
fp issue create \
  --title "Add login UI components" \
  --parent FP-1 \
  --depends "FP-4" \
  --description "Create React components for authentication:
- Login button (redirects to OAuth)
- User profile dropdown
- Logout button

Files:
- app/components/LoginButton.tsx (new)
- app/components/UserProfile.tsx (new)
- app/components/LogoutButton.tsx (new)"
```

This creates FP-5, dependent on FP-4.

```bash
# Testing and docs
fp issue create \
  --title "Testing and documentation" \
  --parent FP-1 \
  --depends "FP-4,FP-5" \
  --description "Write tests and documentation:
- Unit tests for auth logic
- Integration tests for OAuth flow
- Update README with setup instructions
- Add environment variable documentation

Files:
- src/auth/__tests__/*.test.ts (new)
- README.md
- .env.example"
```

This creates FP-6, dependent on both FP-4 and FP-5.

### Phase 3: Visualize and Verify

```bash
fp tree
```

You should see:
```
FP-1 [todo] Add user authentication system
├── FP-2 [todo] Design and implement data models
├── FP-3 [todo] Implement GitHub OAuth flow
│   └── blocked by: FP-2
├── FP-4 [todo] Implement session management
│   └── blocked by: FP-2, FP-3
├── FP-5 [todo] Add login UI components
│   └── blocked by: FP-4
└── FP-6 [todo] Testing and documentation
    └── blocked by: FP-4, FP-5
```

### Phase 4: Iterate and Refine

Review the plan:
1. Are dependencies correct?
2. Are any tasks too large? (If so, break them down further)
3. Are descriptions clear enough?

```bash
# Add missing dependency
fp issue update --depends "FP-2,FP-4" FP-5

# Break down large task
fp issue create \
  --title "OAuth callback handler" \
  --parent FP-3 \
  --description "Handle OAuth callback and exchange code for token"

fp issue create \
  --title "GitHub user info fetcher" \
  --parent FP-3 \
  --description "Fetch user profile from GitHub API"

# Update descriptions
fp issue edit FP-2  # Opens in $EDITOR
```

## Planning Best Practices

### 1. Start Top-Down

Begin with the high-level goal, then decompose:
- **Level 1**: What is the overall feature/goal?
- **Level 2**: What are the major components?
- **Level 3**: What are the implementation steps?

### 2. Make Tasks Atomic

Each task should:
- Be completable in one work session (1-3 hours)
- Have a clear definition of "done"
- Produce testable output
- Touch a small, focused set of files

If a task feels too big, break it down further.

### 3. Identify Dependencies Early

Ask:
- Does this task need data structures from another task?
- Does this task need APIs/functions from another task?
- Can this task be done in parallel with others?

Model dependencies explicitly:
```bash
fp issue update --depends "FP-Y,FP-Z" FP-X
```

### 4. Write Clear Descriptions

Good descriptions include:
- **What**: Brief summary of the task
- **Why**: Context or rationale (if not obvious)
- **How**: Technical approach or key steps
- **Files**: Where the work happens
- **Definition of Done**: How to know it's complete

Example:
```markdown
Implement rate limiting middleware

Why: Protect API endpoints from abuse
How: Use Cloudflare's built-in rate limiting or token bucket algorithm
Files: src/middleware/ratelimit.ts
Done:
- Middleware blocks requests exceeding 100/minute
- Responds with 429 status code
- Tests verify rate limit enforcement
```

### 5. Plan for Testing and Docs

Always include tasks for:
- Unit tests
- Integration tests
- Documentation updates
- Configuration/environment setup

These often depend on implementation tasks being complete.

## Common Planning Patterns

For detailed patterns with examples, see **`references/patterns.md`**:
- Foundation → Implementation → Integration
- Vertical Slices
- Parallel Tracks
- Research → Implementation
- Incremental Feature Flags

## Updating Plans Mid-Execution

Plans often evolve as work progresses:

### Adding New Tasks

```bash
# Discovered new requirement
fp issue create \
  --title "Add token refresh logic" \
  --parent FP-1 \
  --depends "FP-3"

# Update dependent tasks
fp issue update --depends "FP-2,FP-3,FP-7" FP-4
```

### Adjusting Dependencies

```bash
# Realized FP-5 doesn't need FP-4 after all
fp issue update --depends "FP-2" FP-5  # This replaces the entire dependency list

# To add a dependency (without removing existing), you need to include all:
fp issue show FP-5  # Check current dependencies
fp issue update --depends "FP-2,FP-4,FP-6" FP-5  # Include old + new
```

### Splitting Large Tasks

```bash
# FP-3 turned out to be too big
# Create sub-tasks
fp issue create --title "OAuth redirect handler" --parent FP-3
fp issue create --title "OAuth callback handler" --parent FP-3
fp issue create --title "User info fetcher" --parent FP-3

# Add comment to original
fp comment FP-3 "Broke down into sub-tasks: FP-10, FP-11, FP-12"

# Keep FP-3 as umbrella, or mark as Done when children are done
```

### Reordering Work

```bash
# Need to work on FP-5 before FP-4
# Update dependencies to reflect new order
fp issue update --depends "FP-2,FP-5" FP-4
fp issue update --depends "FP-2" FP-5

# Document why
fp comment FP-1 "Reordered plan: UI mockups (FP-5) before backend (FP-4) to get design feedback early"
```

## Collaborative Planning

### Human + Agent Planning

**Phase 1: Human creates outline**
```bash
# Human creates the plan issue with high-level goals
fp issue create --title "Add real-time notifications" --description "[detailed goals]"
```

**Phase 2: Agent elaborates**
The agent (you) can:
- Break down into technical tasks
- Add dependencies
- Identify files
- Suggest implementation approach

```bash
# Agent adds structured tasks
fp issue create --title "WebSocket connection handler" --parent FP-1
fp issue create --title "Notification data model" --parent FP-1
# ... etc
```

**Phase 3: Human reviews and adjusts**
```bash
# Human updates based on business constraints
fp issue update --depends "FP-2,FP-7" FP-3
fp comment FP-1 "Updated plan: need to integrate with existing notification system (FP-7)"
```

### Multi-Agent Planning

Multiple agents can contribute to planning:

```bash
# Agent 1 (swift-falcon): Creates foundation
fp issue create --title "Plan feature X" --parent FP-1

# Agent 2 (calm-otter): Adds backend tasks
fp issue create --title "Backend API" --parent FP-1
fp comment FP-1 "Added backend tasks (FP-10-FP-13)"

# Agent 3 (quick-lemur): Adds frontend tasks
fp issue create --title "UI components" --parent FP-1 --depends "FP-10"
fp comment FP-1 "Added frontend tasks (FP-14-FP-16)"
```

Track contributions via activity log:
```bash
fp log FP-1
```

## Plan Templates

For ready-to-use templates, see **`references/templates.md`**:
- Full-Stack Feature
- Bug Fix
- Refactoring
- Performance Optimization

## Anti-Patterns (Avoid These)

### ❌ Using markdown task lists instead of subissues
```markdown
# BAD: Task checkboxes in issue description
## Tasks
- [ ] Create apps/fp-vscode directory
- [ ] Set up package.json with extension manifest
- [ ] Configure esbuild to bundle extension
- [ ] Create extension.ts with activate/deactivate
```

This is wrong because:
- Checkboxes are not trackable by the FP system
- No dependencies can be modeled
- No status, assignee, or activity tracking
- Agents cannot pick up individual tasks

```bash
# GOOD: Create proper subissues
fp issue create --title "Create apps/fp-vscode directory" --parent FP-1
fp issue create --title "Set up package.json with extension manifest" --parent FP-1 --depends "FP-2"
fp issue create --title "Configure esbuild to bundle extension" --parent FP-1 --depends "FP-3"
fp issue create --title "Create extension.ts with activate/deactivate" --parent FP-1 --depends "FP-4"
```

**Rule: NEVER write `- [ ]` task lists in issue descriptions. Always create subissues with `--parent`.**

### ❌ Creating tasks without parent
```bash
# BAD: Orphan tasks
fp issue create --title "Add OAuth"
fp issue create --title "Add session logic"
# These are unconnected

# GOOD: Hierarchy
fp issue create --title "Authentication system"
fp issue create --title "Add OAuth" --parent FP-1
fp issue create --title "Add session logic" --parent FP-1 --depends "FP-2"
```

### ❌ Ignoring dependencies
```bash
# BAD: No dependencies specified
fp issue create --title "Frontend auth UI" --parent FP-1
fp issue create --title "Backend auth API" --parent FP-1
# Can UI be built before API? Probably not.

# GOOD: Explicit dependencies
fp issue create --title "Backend auth API" --parent FP-1
fp issue create --title "Frontend auth UI" --parent FP-1 --depends "FP-2"
```

### ❌ Vague descriptions
```bash
# BAD: Unclear task
fp issue create --title "Do the auth stuff" --parent FP-1

# GOOD: Specific task
fp issue create \
  --title "Implement GitHub OAuth callback handler" \
  --parent FP-1 \
  --description "Handle OAuth redirect, exchange code for token, create session"
```

### ❌ Monolithic tasks
```bash
# BAD: Huge task
fp issue create --title "Build entire authentication system" --parent FP-1
# This is not a task, it's the whole feature!

# GOOD: Decomposed
fp issue create --title "Authentication system"
fp issue create --title "OAuth integration" --parent FP-1
fp issue create --title "Session management" --parent FP-1
fp issue create --title "Auth middleware" --parent FP-1
# ... etc
```

## Quick Reference

### Planning Checklist
- [ ] Create parent/plan issue with clear goals
- [ ] Break down into atomic subissues with `--parent` (1-3 hours each)
- [ ] **Never use `- [ ]` task lists** - always create proper subissues
- [ ] Specify dependencies between tasks
- [ ] Write clear descriptions (what, why, how, done)
- [ ] Include testing and documentation tasks
- [ ] Visualize with `fp tree` to verify structure

### Task Creation Template
```bash
fp issue create \
  --title "[Clear, specific title]" \
  --parent "[Parent issue ID]" \
  --depends "[Comma-separated dependency IDs]" \
  --priority "[low|medium|high|critical]" \
  --description "
What: [What needs to be done]
Why: [Context or rationale]
How: [Technical approach]
Done: [Definition of done]
"
```

Priority is optional. Use it to indicate urgency:
- `critical` - Blocking other work or urgent fix
- `high` - Important, should be done soon
- `medium` - Normal priority
- `low` - Nice to have, can wait

### Dependency Analysis Questions
1. Does this task need data structures from another task?
2. Does this task need APIs/functions from another task?
3. Can this task be done in parallel with others?
4. What needs to be done before this can start?
5. What is blocked by this task?

## Integration with Workflow

Planning and workflow are two sides of the same process:

### Planning Phase
Use this skill to:
- Create issue hierarchy
- Model dependencies
- Write clear descriptions

### Execution Phase
Use the `fp-workflow` skill to:
- Find next actionable task (no blockers)
- Claim work
- Log progress
- Update status
- Hand off

### Feedback Loop
During execution, update the plan:
```bash
# Discovered new dependency
fp issue update --depends "FP-2,FP-4,FP-8" FP-5
fp comment FP-5 "Added dependency on FP-8: need shared utility functions"

# Task is too big - break it down
fp issue create --title "Subtask A" --parent FP-5
fp issue create --title "Subtask B" --parent FP-5
fp comment FP-5 "Broke down into FP-15, FP-16"
```

## Summary

Effective planning with FP:

1. **Start with the goal** - Create a parent issue with clear objectives
2. **Decompose hierarchically** - Break into manageable tasks
3. **Model dependencies** - Make execution order explicit
4. **Write clear descriptions** - What, why, how, and done
5. **Include testing and docs** - Plan for quality and knowledge sharing
6. **Iterate as you learn** - Update the plan based on implementation discoveries
7. **Visualize with `fp tree`** - Verify structure and dependencies

A good plan enables agents to:
- Understand the full scope
- Pick up work autonomously
- Work in parallel
- Track progress objectively
- Hand off seamlessly

Remember: Plans are living documents. Update them as you learn during implementation.
