---
name: start-working
description: Autonomously execute ALL tasks from the backlog until complete. Runs in a continuous loop - picks task, implements via subagent, moves to done, repeats. No user prompts between tasks. Follows task-board workflow (backlog → in-progress → done).
---

# Start Working Skill

This skill **autonomously executes ALL tasks** from the task board until the backlog is empty. It runs in a continuous loop without stopping between tasks.

**Task Board Flow**: `.task-board/backlog/` → `.task-board/in-progress/` → `.task-board/done/`

**🚨 AUTONOMOUS MODE**: This skill does NOT stop between tasks. It continues until all tasks are complete or a critical blocker occurs.

---

## 🚨 SIX CRITICAL RULES 🚨

### 1. USE THE TASK BOARD SYSTEM
**ALL work flows through `.task-board/`** - this is non-negotiable.
- Tasks live in: `backlog/` → `in-progress/` → `done/`
- `PLANNING-BOARD.md` is the source of truth for priorities
- **NEVER work on something not tracked in the task board**
- Update task files with progress as you work

**Why**: The task board ensures organized, trackable, sequential work with clear accountability.

### 2. NEVER USE GIT COMMANDS
**ABSOLUTELY NO git commands** - not by the main agent, not by subagents.
- ❌ `git add`, `git commit`, `git push`, `git pull`, `git checkout`, `git branch`, etc.
- ❌ `git status`, `git diff`, `git log` (even read-only commands)
- ❌ Any command starting with `git`

**Why**: The user handles all git operations manually. This prevents accidental commits, branch switches, or repository state changes.

**If user requests git operations**: Politely decline and explain that git commands are disabled for this workflow.

### 3. USE SUBAGENTS WITH HAIKU BY DEFAULT
Each task MUST be executed using the **Task tool** with a subagent:
- **Default model: `haiku`** - fast and efficient for most tasks
- **Use `sonnet` only for**: D3.js visualizations, complex business logic, architectural decisions
- **ALWAYS include CLAUDE.md context** in subagent prompts - reference project patterns, conventions, and tech stack

### 4. TASKS ARE DONE IN ORDER
Tasks are numbered for dependency reasons. Execute them **sequentially, in order**:
- Pick task 071 → Complete → Pick task 072 → Complete → Pick task 073...
- **NEVER skip ahead** unless user explicitly requests it
- **NEVER run tasks in parallel**

### 5. PLAYWRIGHT CLI FOR FRONTEND VERIFICATION
Every frontend task MUST be verified with Playwright CLI **before marking complete**:
```bash
# Run verification script (no permission prompts)
node scripts/playwright-verify.js <url> [screenshot-name]
```

The script will:
- Navigate to the page
- Wait for content to load
- Capture console errors
- Take a screenshot
- Output verification results

**Frontend tasks without Playwright verification are INCOMPLETE.**

### 6. ALWAYS PREFER TO USE TOOLS OVER BASH OR CLI!!!
Subagents MUST use built-in tools instead of bash equivalents. **This is non-negotiable.**

| ❌ NEVER USE | ✅ ALWAYS USE |
|--------------|---------------|
| `cat`, `head`, `tail` | **Read** tool |
| `echo >`, `cat <<EOF` | **Write** tool |
| `sed`, `awk` | **Edit** tool |
| `find`, `ls` (for search) | **Glob** tool |
| `grep`, `rg` | **Grep** tool |

**Why**: Built-in tools are optimized, safer, and provide better output for Claude Code.

**Example violations to watch for**:
```bash
# ❌ BAD - Using bash for file operations
cat /path/to/file.ts
grep -r "pattern" src/
find . -name "*.tsx"
echo "content" > file.ts

# ✅ GOOD - Using built-in tools
Read tool: file_path="/path/to/file.ts"
Grep tool: pattern="pattern", path="src/"
Glob tool: pattern="**/*.tsx"
Write tool: file_path="file.ts", content="content"
```

**Subagent prompts MUST include this reminder.**

---

**🚨 TWO ABSOLUTE RULES 🚨**
1. **ALL WORK THROUGH TASK BOARD** - Tasks come from `.task-board/`, progress tracked in task files, never work outside the system
2. **NO GIT COMMANDS** - Never run ANY git commands. User handles all version control manually.

---

## When to Use This Skill

Use this skill when the user requests:
- "Start working on the next task"
- "Continue work" or "Keep going"
- "Pick up the next priority"
- "Work on the planning board items"
- "Start implementing" or "Begin development"
- Any request to begin implementation work

## Workflow Overview

This skill follows a **10-step workflow** that moves tasks through the lifecycle:

```
.task-board/backlog/ → .task-board/in-progress/ → .task-board/done/
```

With continuous updates to `PLANNING-BOARD.md` throughout the process.

## The 10-Step Workflow

### Step 1: Check Current Priorities

Read [`.task-board/PLANNING-BOARD.md`](../../.task-board/PLANNING-BOARD.md) to see what's next.

**If PLANNING-BOARD is empty**: Ask the user if they want to add priorities from the backlog first.

**Example response**:
```
The PLANNING-BOARD is currently empty. Would you like me to:
1. Add the top 3-5 priorities from backlog to the planning board?
2. Wait for you to manually select priorities?
3. Review the entire backlog and make recommendations?
```

### Step 2: Select Top Priority

Pick the **first item** from the planning board (unless blocked or user specifies otherwise).

**Decision criteria**:
- Is it blocked by dependencies?
- Are all prerequisites met (check "Related Plans" section)?
- Is the scope clear and actionable?
- Are there any unresolved questions in the plan?

If the top priority is blocked, move to the next unblocked item.

**Blocking examples**:
- Task `006-FEATURE-user-api-endpoints.md` is blocked if `001-FEATURE-backend-express-server.md` is not done
- Task `009-FEATURE-portfolio-dashboard.md` is blocked if `008-FEATURE-portfolio-api-endpoints.md` is not done

### Step 3: Move to In-Progress

Move the task file from `.task-board/backlog/` to `.task-board/in-progress/`.

**Example**:
```bash
Move: .task-board/backlog/001-FEATURE-backend-express-server.md
  To: .task-board/in-progress/001-FEATURE-backend-express-server.md
```

**Important**: Limit in-progress work to **1-2 tasks maximum**. If in-progress folder already has tasks, ask user if they want to finish those first.

### Step 4: Read the Task File

Thoroughly understand the task plan:
- **Context & Motivation**: Why is this work needed?
- **Current State**: What exists today?
- **Desired Outcome**: What success looks like
- **Acceptance Criteria**: Specific, testable requirements (checkboxes) - **🚨 MUST be checked off as completed**
- **Technical Approach**: Implementation steps and architecture decisions
- **Dependencies**: What must be completed first
- **Risks**: Potential issues and mitigations
- **Code References**: Relevant patterns and examples

### Step 5: Clarify Uncertainties (Critical)

**STOP and ask the user follow-up questions if**:
- The task description is unclear or ambiguous
- Multiple implementation approaches are possible
- There are technical uncertainties about the approach
- The scope seems too large or ill-defined
- Priority conflicts exist
- Dependencies are unclear
- Norwegian localization requirements are ambiguous

**Only proceed to Step 6 after all uncertainties are resolved**.

**Example questions**:
- "Should the portfolio dashboard show all snapshots or just the last 12 months?"
- "For error handling, should we show toast notifications or inline errors?"
- "The plan mentions 'optional D3.js chart' - should I implement this or skip it for MVP?"

### Step 6: Assess Complexity

Evaluate if the task is appropriately sized:

**If task is too complex**:
- Break it down into smaller, focused sub-tasks
- Create new task files in `backlog/` for each sub-task (continue numbering sequence)
- Update `PLANNING-BOARD.md` with the new breakdown
- Select the first sub-task to work on

**Complexity indicators for finans project**:
- Affects both frontend AND backend (consider splitting)
- Requires changes across more than 3 workspaces (frontend/backend/components)
- Estimated effort > 1 week
- Multiple new dependencies or integrations (CosmosDB + API + UI)

**Example breakdown**:
```
Original: 009-FEATURE-portfolio-dashboard.md (too complex)

Break into:
- 009a-FEATURE-portfolio-api-integration.md (fetch snapshots)
- 009b-FEATURE-net-worth-chart.md (D3.js chart only)
- 009c-FEATURE-account-table.md (account breakdown table)
```

### Step 7: Add Implementation Plan

Update the task file with a **detailed Implementation Plan** section.

The plan file already has "Implementation Plan" as a placeholder section. Fill it in with:

```markdown
## Implementation Plan

**Phase 1: Backend Setup** (if applicable)
- [ ] Create Express routes in `/backend/src/routes/`
- [ ] Implement controllers in `/backend/src/controllers/`
- [ ] Add validation in `/backend/src/validators/`
- [ ] Set up CosmosDB service methods
- [ ] Test with Postman/curl

**Phase 2: Frontend Implementation** (if applicable)
- [ ] Create feature folder in `/frontend/src/features/[feature-name]/`
- [ ] Implement components (React + TypeScript)
- [ ] Add TanStack Query hooks for API calls
- [ ] Set up Zustand store if needed (client state)
- [ ] Apply BeerCSS styling
- [ ] Add Norwegian text and formatting

**Phase 3: Testing**
- [ ] Manual testing in dev environment
- [ ] Verify all acceptance criteria met
- [ ] Test Norwegian number/date formatting
- [ ] Test error cases

**Phase 4: Verification**
- [ ] Frontend builds: `pnpm --filter frontend build`
- [ ] Backend builds: `pnpm --filter backend build`
- [ ] TypeScript type-check passes
- [ ] ESLint passes
- [ ] All acceptance criteria checked off

**Files to create/modify**:
- `/backend/src/routes/userRoutes.ts` (new)
- `/backend/src/controllers/userController.ts` (new)
- `/frontend/src/features/auth/LoginPage.tsx` (new)
- `/frontend/src/shared/api/client.ts` (modify)

**Dependencies**:
- Requires `.env` files configured
- Requires CosmosDB Emulator running (run `emulator.bat`)

**Estimated total time**: 2-3 days
```

### Step 8: Update Planning Board

Mark the task as **"In Progress"** in `PLANNING-BOARD.md` with status notes.

**Update format**:
```markdown
## Top Priorities

### 1. Backend Express Server Setup (Effort: Medium - 2-3 days) - IN PROGRESS ⚙️
**File**: `in-progress/001-FEATURE-backend-express-server.md`
**Why Now**: Foundation for all API development
**Status**: Phase 1 complete - setting up middleware
**Progress**: 3/12 acceptance criteria met
**Started**: 2025-11-28
```

### Step 9: Implement the Solution

Follow the finans project architecture patterns and implementation workflow:

#### Development Environment Setup

**Start development servers** (if not already running):
```bash
# Backend dev server (Express + nodemon)
pnpm --filter backend dev

# Frontend dev server (Vite)
pnpm --filter frontend dev

# Both in parallel (from root)
pnpm dev
```

**CosmosDB Emulator** (if working with database):
```bash
# Start emulator
.\emulator.bat

# Verify running at https://localhost:8081/_explorer/
```

#### Architecture Patterns to Follow

**Backend (Express + TypeScript + CosmosDB)**:
- **Folder structure**: Follow vertical organization
  - Routes in `/backend/src/routes/`
  - Controllers in `/backend/src/controllers/`
  - Services in `/backend/src/services/` (CosmosDB access)
  - Validation in `/backend/src/validators/`
  - Middleware in `/backend/src/middleware/`
- **Error handling**: Use custom error classes, global error handler
- **Logging**: Winston logger for structured logging
- **Validation**: Two-layer (input validation + business validation)
- **API format**:
  - Success: `{ data: {...}, success: true }`
  - Error: `{ error: { message, code, details }, success: false }`

**Frontend (React 18 + Vite + TanStack Query + Zustand)**:
- **Folder structure**: Vertical slicing by feature
  - Features in `/frontend/src/features/[feature-name]/`
  - Shared components in `/frontend/src/shared/components/`
  - Shared hooks in `/frontend/src/shared/hooks/`
  - Stores in `/frontend/src/stores/` (Zustand)
- **State management**:
  - **TanStack Query**: All server state (API calls)
  - **Zustand**: Client state (UI preferences, local state)
  - **React Context**: Auth state only
- **Components**: Functional components with TypeScript
- **Styling**: Nordic Minimal CSS + Material UI icons
- **Forms**: React Hook Form + Zod validation
- **Norwegian**: All UI text in Norwegian, use format utilities from `shared/utils/`

**Norwegian Localization** (CRITICAL):
- **Numbers**: `formatCurrency(123456.78)` → `"123 456,78 kr"`
- **Dates**: `formatDate(new Date())` → `"28.11.2025"`
- **Import utilities**:
  ```typescript
  import { formatCurrency, formatNumber, parseNumber } from '@/shared/utils/numberFormat';
  import { formatDate, parseDate } from '@/shared/utils/dateFormat';
  ```

**Component Library** (`/components`):
- Shared components bundled into frontend (not published to npm)
- Import: `import { Button, Card } from '@finans/components'`
- Storybook for documentation (future)

#### Implementation Workflow

1. **Read the Technical Approach section** in the task file thoroughly

2. **Follow the phased approach** from Implementation Plan:
   - Complete Phase 1 before moving to Phase 2
   - Check off tasks as you complete them
   - Update Progress Log frequently

3. **Code incrementally**:
   - Create/modify one file at a time
   - Test each change before moving to next
   - Keep TypeScript compilation clean (no errors)

4. **Follow existing patterns**:
   - Check "Code References" section in task file
   - Look for similar implementations in codebase
   - Maintain consistency with existing code

5. **Test continuously**:
   - Manual testing after each change
   - Verify acceptance criteria as you go
   - Test Norwegian formatting with real data

#### Real-Time Progress Tracking

**Update the task file's Progress Log frequently** (every 30-60 minutes):

```markdown
## Progress Log
- 2025-11-28 14:00 - Started implementation, reviewed task plan
- 2025-11-28 14:30 - Created Express app in /backend/src/index.ts
- 2025-11-28 15:00 - Added Winston logger configuration
- 2025-11-28 15:30 - Implemented error handler middleware
- 2025-11-28 16:00 - Tested health endpoint - working ✓
- 2025-11-28 16:30 - Added rate limiting middleware
```

**Update PLANNING-BOARD.md as phases complete**:
```markdown
**Status**: Phase 2 complete - frontend components built
**Progress**: 8/12 acceptance criteria met
```

#### Testing Guidelines

**Frontend testing**:
- Manual testing in browser (http://localhost:5173)
- Check browser console for errors
- Test responsive design (mobile/desktop)
- Verify Norwegian formatting
- Test all user interactions
- Future: Playwright E2E tests (see task 017)

**Backend testing**:
- Test with Postman or curl
- Verify response format
- Test error cases (400, 401, 404, 500)
- Check Winston logs
- NOTE: No unit tests - E2E only per CLAUDE.md

#### Playwright CLI Visual Verification - MANDATORY FOR FRONTEND

**🚨 CRITICAL**: Every frontend task MUST be verified using Playwright CLI before marking complete.

This is NOT optional. Frontend tasks are NOT complete until visually verified.

**Design drafts location**: `.docs/design-drafts/`
- `draft-1-nordic-minimal.html` - Dashboard (Oversikt)
- `draft-1-portfolio.html` - Portfolio page
- `draft-1-sparing.html` - Savings page
- `draft-1-gjeld.html` - Debt page
- `draft-1-pensjon.html` - Pension page
- `draft-1-kalkulatorer.html` - Calculators page

**MANDATORY Verification Workflow for Frontend Tasks**:

```bash
# 1. Start dev server (if not running)
pnpm --filter frontend dev &

# 2. Run verification script (auto-approved via Bash allowlist)
node scripts/playwright-verify.js http://localhost:5173/[page] [task-name]

# The script outputs:
# - Page title and URL
# - Console errors (if any)
# - Screenshot saved to .playwright-output/[task-name].png
# - Pass/fail status
```

**What to verify** (script checks automatically):
- Page loads successfully (no crash)
- No JavaScript console errors
- Screenshot captured for visual review

**Manual verification** (review script output):
- Layout matches design draft structure
- Components are positioned correctly
- Norwegian text is displayed properly
- Number formatting (space as thousands separator, e.g., "123 456,78 kr")
- Color scheme matches Nordic Minimal palette
- Typography (Cormorant Garamond for headings, DM Sans for body)

**Example verification session**:
```bash
# Verify portfolio page
node scripts/playwright-verify.js http://localhost:5173/portfolio portfolio-page

# Output:
# ✓ Page loaded: Finans - Portefølje
# ✓ No console errors
# ✓ Screenshot: .playwright-output/portfolio-page.png
# PASS

# For interactive testing (opens browser for manual inspection)
node scripts/playwright-verify.js http://localhost:5173/portfolio --interactive
```

**If verification fails**:
- Fix the issues before marking complete
- Re-run verification after fixes
- Document what was fixed in Progress Log

**Build verification**:
```bash
# Frontend build
pnpm --filter frontend build

# Backend build
pnpm --filter backend build

# Lint all
pnpm lint

# Type-check
pnpm --filter frontend type-check
pnpm --filter backend type-check
```

### Step 10: Complete and Move to Done

**🚨 CRITICAL: Update Acceptance Criteria Checkboxes**

Before marking complete, **you MUST check off all acceptance criteria** in the task file:
- Change `- [ ]` to `- [x]` for each completed item
- If an item cannot be completed, document why in the Resolution section
- **A task with unchecked acceptance criteria is NOT DONE**

Before marking complete, verify the **Verification Checklist** (in task file):

```markdown
## Verification
- [x] All acceptance criteria met AND CHECKED OFF IN TASK FILE
- [x] Frontend builds successfully (`pnpm --filter frontend build`)
- [x] Backend builds successfully (`pnpm --filter backend build`)
- [x] TypeScript compilation clean (no errors)
- [x] ESLint passes
- [x] Manual testing complete
- [x] Norwegian formatting verified
- [x] Error handling tested
- [x] Code reviewed (self-review)
- [x] **🚨 Playwright CLI verification** (MANDATORY for frontend tasks)
```

**🚨 Playwright CLI verification is MANDATORY for ALL frontend tasks**:

The task is NOT complete until you have:
1. Run `node scripts/playwright-verify.js <url> <task-name>`
2. Verified no console errors in output
3. Reviewed screenshot in `.playwright-output/`
4. Confirmed layout and functionality match requirements

**DO NOT skip this step. Frontend tasks without Playwright verification are INCOMPLETE.**

**Then finalize**:

1. **Update Resolution section** with final outcome:
   ```markdown
   ## Resolution

   Successfully implemented backend Express server with complete middleware stack.

   **Implementation Summary**:
   - Created Express app with TypeScript in `/backend/src/index.ts`
   - Configured Winston logger for structured logging
   - Implemented global error handler in `/backend/src/middleware/errorHandler.ts`
   - Added rate limiting middleware (100 req/min general, 10 req/min calculators)
   - Set up CORS for frontend access
   - Created health check endpoint at `/api/v1/health`
   - Configured graceful shutdown handlers

   **Files created**:
   - `/backend/src/index.ts` - Main server entry point
   - `/backend/src/config/environment.ts` - Environment validation
   - `/backend/src/utils/logger.ts` - Winston logger
   - `/backend/src/middleware/errorHandler.ts` - Global error handler
   - `/backend/src/middleware/rateLimiter.ts` - Rate limiting
   - `/backend/src/routes/index.ts` - Route aggregator

   **Test results**:
   - ✅ Server starts on port 3000
   - ✅ Health endpoint responds: `GET http://localhost:3000/api/v1/health`
   - ✅ CORS allows frontend origin
   - ✅ Rate limiting works (tested with multiple requests)
   - ✅ Error responses follow standard format
   - ✅ TypeScript build succeeds
   - ✅ All 12 acceptance criteria met

   **Next steps**:
   - Ready for `002-FEATURE-cosmosdb-connection.md`
   ```

2. **Move file to done**:
   ```bash
   Move: .task-board/in-progress/001-FEATURE-backend-express-server.md
     To: .task-board/done/001-FEATURE-backend-express-server.md
   ```

3. **Update PLANNING-BOARD.md**:
   - Remove completed item from "Top Priorities"
   - Add to "Recently Completed" section
   - Add next priority from backlog (if applicable)
   - Keep board at 3-5 items maximum

   ```markdown
   ## Recently Completed

   - ✅ **001-FEATURE-backend-express-server** (Completed: 2025-11-28) - Foundation for API development
   ```

4. **Update README statistics** (`.task-board/README.md`):
   ```markdown
   Total Plans: 20
   ├── Backlog: 18
   ├── In Progress: 0
   ├── Done: 2
   └── On Hold: 0
   ```

## Subagent Execution Strategy

### CRITICAL: Use Subagents for Each Task

**IMPORTANT**: Each task from the backlog MUST be executed using the Task tool with an appropriate subagent. This ensures:
- Focused context for each task
- Proper model selection based on complexity
- Clear separation between tasks
- Better resource utilization

### Model Selection by Complexity

**DEFAULT MODEL: `haiku`** - Use haiku for most tasks unless complexity requires sonnet.

| Complexity | Model | Examples |
|------------|-------|----------|
| **Standard** (default) | `haiku` | CSS fixes, text changes, simple components, form fields, API endpoints with clear patterns, bug fixes, refactoring |
| **Complex** | `sonnet` | D3.js visualizations, complex business logic, multi-file architectural changes, intricate state management, complex validation logic |

**Use `haiku` when**:
- Task follows existing patterns in the codebase
- Requirements are clear and well-defined
- Single feature or component implementation
- Straightforward API endpoint
- CSS/styling work
- Simple to medium React components

**Use `sonnet` when**:
- Task involves D3.js or complex visualizations
- Complex state management across multiple stores
- Architectural decisions needed
- Multi-step business logic with edge cases
- Integration of multiple systems (e.g., CosmosDB + LLM + frontend)

### Sequential Task Execution - TASKS ARE DONE IN ORDER

**CRITICAL**: Execute tasks ONE AT A TIME, IN ORDER. This is non-negotiable.

```
❌ WRONG: Start multiple tasks in parallel
❌ WRONG: Skip ahead to "more interesting" tasks
❌ WRONG: Pick tasks out of order
✅ RIGHT: Complete task 071 → Move to done → Start task 072 → Complete → Start 073...
```

**The workflow is strictly sequential**:
1. Pick the FIRST numbered task from PLANNING-BOARD
2. Execute it with a subagent (haiku by default)
3. Verify completion (including Playwright CLI for frontend)
4. Move to done
5. Pick the NEXT numbered task
6. Repeat

**Why sequential and in-order**:
- Tasks are numbered to respect dependencies
- Foundation work must come before features
- Prevents broken builds and incomplete features
- Makes progress predictable and trackable

### Task Ordering is MANDATORY

Tasks in the backlog are **numbered for a reason**. The numbering reflects:
- Dependency order (lower numbers are prerequisites)
- Logical implementation sequence
- Foundation → Features → Polish

**NEVER skip tasks unless**:
1. User explicitly requests a different order
2. A task is blocked by external factors (and you've asked user)

**Example dependency chain**:
```
071-redirect → 072-login-redirect → 073-user-model → 074-account-model → ...
```

### How to Invoke Subagents

Use the **Task tool** to spawn a subagent for each task:

```
Task tool parameters:
- subagent_type: "general-purpose"
- model: "haiku" (default) or "sonnet" (for complex tasks)
- prompt: Detailed task instructions
- description: Short 3-5 word summary
```

**Example subagent invocation for a standard task**:
```
Task tool:
  subagent_type: "general-purpose"
  model: "haiku"
  description: "Implement user routes"
  prompt: |
    Implement the user API routes as specified in:
    .task-board/in-progress/081-FEATURE-user-routes.md

    This task is tracked in the task board system.

    🚨 READ CLAUDE.md FIRST - it contains all project patterns, conventions, and tech stack.
    Follow all patterns from CLAUDE.md.
    Update the task file in .task-board/in-progress/ with progress.
    Mark acceptance criteria as complete in the task file.

    🚨 CRITICAL RESTRICTIONS:
    1. Work ONLY on this task from .task-board/ - no ad-hoc work
    2. NEVER use git commands (git add, commit, push, status, diff, etc.)
    3. Use Read tool (NOT cat/head/tail)
    4. Use Write tool (NOT echo/cat heredoc)
    5. Use Edit tool (NOT sed/awk)
    6. Use Glob tool (NOT find/ls for search)
    7. Use Grep tool (NOT grep/rg bash commands)
    8. 🚨 CHECK OFF acceptance criteria as you complete them (change [ ] to [x])

    NEVER use bash for file operations when a built-in tool exists.
    NEVER run ANY git commands - user handles version control manually.

    🚨 ACCEPTANCE CRITERIA: As you complete each acceptance criterion,
    UPDATE THE TASK FILE to check it off: change "- [ ]" to "- [x]".
    A task with unchecked acceptance criteria is NOT DONE.

    When done, provide a summary of:
    - Files created/modified
    - All acceptance criteria status (MUST be checked off in task file)
    - Any issues encountered
```

**Example for a complex frontend task (needs sonnet)**:
```
Task tool:
  subagent_type: "general-purpose"
  model: "sonnet"
  description: "Build D3.js area chart"
  prompt: |
    Implement the AreaChart component with D3.js as specified in:
    .task-board/in-progress/048-FEATURE-area-chart-component.md

    This task is tracked in the task board system.

    🚨 READ CLAUDE.md FIRST - it contains all project patterns, conventions, and tech stack.
    This involves complex D3.js visualization work.
    Update the task file in .task-board/in-progress/ with progress.

    🚨 CRITICAL RESTRICTIONS:
    1. Work ONLY on this task from .task-board/ - no ad-hoc work
    2. NEVER use git commands (git add, commit, push, status, diff, etc.)
    3. Use Read tool (NOT cat/head/tail)
    4. Use Write tool (NOT echo/cat heredoc)
    5. Use Edit tool (NOT sed/awk)
    6. Use Glob tool (NOT find/ls for search)
    7. Use Grep tool (NOT grep/rg bash commands)
    8. 🚨 CHECK OFF acceptance criteria as you complete them (change [ ] to [x])

    NEVER use bash for file operations when a built-in tool exists.
    NEVER run ANY git commands - user handles version control manually.

    🚨 ACCEPTANCE CRITERIA: As you complete each acceptance criterion,
    UPDATE THE TASK FILE to check it off: change "- [ ]" to "- [x]".
    A task with unchecked acceptance criteria is NOT DONE.

    After implementation, VERIFY using Playwright CLI:
    node scripts/playwright-verify.js http://localhost:5173/[page] area-chart

    Provide summary with verification results and update task file.
```

### Working Through the Backlog - AUTONOMOUS MODE

**🚨 CRITICAL: This skill runs ALL tasks automatically until backlog is empty.**

This skill processes the **entire backlog** autonomously, IN ORDER, without stopping:

```
LOOP until backlog is empty:
  1. Read PLANNING-BOARD to get the FIRST numbered task
  2. Move task to in-progress/
  3. Spawn subagent with Task tool (haiku by default)
  4. Subagent implements and verifies (Playwright CLI for frontend)
  5. Move task to done/
  6. Update PLANNING-BOARD.md
  7. AUTOMATICALLY continue to next task (NO user prompt needed)
```

**DO NOT STOP between tasks.** Continue until:
- All tasks in PLANNING-BOARD are complete, OR
- A critical blocker prevents progress, OR
- User explicitly interrupts

**After completing a task, IMMEDIATELY start the next one.** No waiting for user confirmation.

## Constraints and Guidelines

### Critical Constraints

1. **🚨 ALL WORK THROUGH TASK BOARD**: Every task must come from `.task-board/`. Never do ad-hoc work outside the system.
2. **🚨 NEVER use git commands**: No git add, commit, push, status, diff, or ANY git command. User handles all version control.
3. **Follow finans architecture patterns**: See CLAUDE.md for complete patterns
4. **Norwegian localization**: All UI text in Norwegian, use format utilities
5. **Keep PLANNING-BOARD.md lean**: Maximum 3-5 items, concise status notes
6. **Real-time updates**: Update task files in `.task-board/in-progress/` frequently
7. **Sequential execution**: Execute tasks fully before starting the next (but continue automatically)
8. **No breaking changes**: Maintain backward compatibility
9. **Security first**: Never commit secrets, always validate input
10. **Respect task ordering**: Tasks are numbered for dependency reasons

### Development Environment

**Package manager**: Always use `pnpm` (not npm or yarn)

**Common commands**:
```bash
# Install dependencies
pnpm install

# Start all workspaces
pnpm dev

# Start specific workspace
pnpm --filter frontend dev
pnpm --filter backend dev

# Build all
pnpm build

# Lint all
pnpm lint

# Type-check
pnpm --filter frontend type-check
pnpm --filter backend type-check
```

**Environment files**:
- ✅ Already configured: `backend/.env` and `frontend/.env`
- ✅ Gitignored (never commit)
- OAuth credentials already set up

**CosmosDB Emulator**:
```bash
# Start emulator
.\emulator.bat

# Access emulator UI
https://localhost:8081/_explorer/
```

### Code Quality Standards

**TypeScript**:
- Strict mode enabled
- No `any` types without justification
- Explicit return types for complex functions
- Interface for object shapes

**React/Frontend**:
- Functional components only
- Custom hooks for reusable logic
- Destructure props in function signature
- Use Nordic Minimal CSS classes for styling

**Express/Backend**:
- Async/await (no callbacks)
- Proper error handling (try/catch)
- Parameterized queries (prevent injection)
- Structured logging with Winston

**Imports**:
1. External packages (alphabetical)
2. Internal packages/aliases (alphabetical)
3. Relative imports (alphabetical)

### Documentation Requirements

Update docs **DURING and AFTER** work:

- **DURING**: Track implementation progress in task file Progress Log
- **AFTER**: Update Resolution section with final outcome

**Key docs to maintain**:
- Task files (Progress Log, Resolution, Verification)
- `PLANNING-BOARD.md` (current priorities and status)
- `README.md` (statistics)

## Success Criteria

A work session is complete when:

### For Each Task (executed via subagent):
- [ ] **🚨 Task from `.task-board/`** (never work outside the task board system)
- [ ] **🚨 NO git commands used** (user handles all version control)
- [ ] Task executed using Task tool with appropriate model (haiku default, sonnet for complex)
- [ ] **🚨 Built-in tools used** (Read/Write/Edit/Glob/Grep - NO bash for file ops)
- [ ] Implementation follows all acceptance criteria
- [ ] All builds passing (frontend, backend, TypeScript, ESLint)
- [ ] **🚨 Playwright CLI verification complete** (MANDATORY for frontend tasks)
- [ ] Task file in `.task-board/in-progress/` updated with Progress Log
- [ ] Task moved to `.task-board/done/` with Resolution

### For the Overall Session (AUTONOMOUS):
- [ ] **🚨 All work tracked in `.task-board/`** (no ad-hoc work outside the system)
- [ ] **🚨 Zero git commands executed** (by main agent or subagents)
- [ ] **🚨 ALL tasks processed automatically** (no stopping between tasks)
- [ ] Tasks processed IN ORDER from `PLANNING-BOARD.md` (no skipping)
- [ ] Each task used a subagent (not done inline)
- [ ] `PLANNING-BOARD.md` updated after each completion
- [ ] Completed tasks moved to `.task-board/done/`
- [ ] Next task started IMMEDIATELY after current completes (no user prompt)

### Key Reminders:
1. **🚨 AUTONOMOUS MODE** - run ALL tasks without stopping, no user prompts between tasks
2. **🚨 USE TASK BOARD** - all work tracked in `.task-board/`, never work outside the system
3. **🚨 NO GIT COMMANDS** - never run any git command, user handles version control
4. **Use haiku by default** - only use sonnet for truly complex tasks
5. **Tasks done IN ORDER** - respect numbering from PLANNING-BOARD.md
6. **Playwright CLI for frontend** - no exceptions
7. **Built-in tools over bash** - Read/Write/Edit/Glob/Grep, never cat/grep/find/sed

## Handling Edge Cases

### If PLANNING-BOARD is Empty

Ask the user:
```
The PLANNING-BOARD is currently empty. Would you like me to:
1. Add the top 3-5 numbered tasks from backlog/ (001-005)?
2. Review the entire backlog and make custom recommendations?
3. Wait for you to manually select priorities?
```

### If Top Priority is Blocked

Identify the blocker and ask:
```
The top priority (009-FEATURE-portfolio-dashboard) is blocked by:
- Requires 008-FEATURE-portfolio-api-endpoints (not complete)
- Requires 004-FEATURE-norwegian-localization (not complete)

Would you like me to:
1. Work on the blockers first (008, then 004)?
2. Skip to the next unblocked item?
3. Re-prioritize the board?
```

### If Task is Unclear

**ALWAYS ask clarifying questions** before proceeding. Examples:
- "The task mentions 'optional D3.js chart' - should I implement this for MVP or skip it?"
- "Should user profile editing work immediately or require email verification?"
- "For error messages, should they be Norwegian or English (for developers)?"
- "Should the dashboard auto-refresh data or require manual refresh?"

### If Task is Too Large

Break it down:
```
This task (009-FEATURE-portfolio-dashboard) seems too complex for a single implementation.

I recommend breaking it into:
1. 009a-FEATURE-dashboard-data-fetching.md (API integration - 1 day)
2. 009b-FEATURE-net-worth-chart.md (D3.js chart - 2 days)
3. 009c-FEATURE-account-table.md (Table component - 1 day)

Should I create these sub-tasks and start with 009a?
```

### If In-Progress Folder Has Multiple Tasks

Ask before starting new work:
```
The in-progress/ folder already has 2 tasks:
- 001-FEATURE-backend-express-server (50% complete)
- 003-FEATURE-frontend-react-initialization (25% complete)

Would you like me to:
1. Continue one of these existing tasks?
2. Move one to on-hold/ and start the new priority?
3. Finish one before starting new work?

(Recommendation: Limit work-in-progress to 1-2 tasks for focus)
```

## Integration with Other Skills

### Task-Discovery Skill

If the backlog is empty or stale:
1. Use the **task-discovery** skill to analyze gaps and generate new tasks
2. New tasks get numbered and added to `backlog/`
3. Update `PLANNING-BOARD.md` with top priorities
4. Then use this **start-working** skill to implement

### Task-Board Skill (Planning)

If the user describes a new feature during work:
1. Use the **task-board** skill to create a comprehensive plan
2. The new task gets added to `backlog/` with next available number
3. Add to `PLANNING-BOARD.md` if high priority
4. Continue with current work or switch to new priority

This skill is optimized for **implementation work** (90% of development time).

## Repository-Specific Context

### Project Structure

```
finans/
├── backend/                # Express API server
│   ├── src/
│   │   ├── config/        # Environment, CosmosDB setup
│   │   ├── routes/        # Express routes
│   │   ├── controllers/   # Request handlers
│   │   ├── services/      # Business logic, DB access
│   │   ├── validators/    # Input/business validation
│   │   ├── middleware/    # Auth, error handling, logging
│   │   └── utils/         # Helper functions
│   ├── .env               # Environment variables (gitignored)
│   └── package.json
├── frontend/              # React + Vite app
│   ├── src/
│   │   ├── features/      # Feature-based organization
│   │   │   ├── auth/      # Login, user management
│   │   │   ├── portfolio/ # Portfolio tracking
│   │   │   ├── calculators/ # Financial calculators
│   │   │   └── dashboard/ # Dashboard and charts
│   │   ├── shared/        # Shared code
│   │   │   ├── components/ # Reusable UI components
│   │   │   ├── hooks/     # Custom hooks
│   │   │   ├── utils/     # Utilities (Norwegian formatting)
│   │   │   └── api/       # Axios client, TanStack Query
│   ├── .env               # Environment variables (gitignored)
│   └── package.json
├── components/            # Shared component library
│   ├── src/               # Components + Storybook
│   └── package.json
├── e2e/                   # Playwright E2E tests (future)
├── .task-board/           # Task management system
│   ├── PLANNING-BOARD.md  # Current priorities (max 3-5)
│   ├── README.md          # System documentation
│   ├── WORKFLOW.md        # Complete workflow guide
│   ├── backlog/           # Planned tasks
│   ├── in-progress/       # Active work (limit 1-2)
│   ├── done/              # Completed tasks
│   └── on-hold/           # Deferred tasks
├── .claude/               # Claude Code configuration
│   ├── CLAUDE.md          # Project instructions
│   └── skills/            # Custom skills
├── emulator.bat           # Start CosmosDB Emulator
└── package.json           # Root monorepo config
```

### Technology Stack

**Backend**:
- Node.js 18+ with Express
- TypeScript (strict mode)
- Azure CosmosDB (NoSQL)
- Winston (logging)
- Helmet (security)
- CORS, rate limiting

**Frontend**:
- React 18 with TypeScript
- Vite (build tool)
- BeerCSS + Material UI (styling)
- D3.js (visualizations)
- TanStack Query (server state)
- Zustand (client state)
- React Hook Form + Zod (forms)
- Axios (HTTP client)

**Tooling**:
- pnpm (package manager)
- ESLint + Prettier
- Playwright (E2E tests - future)

### Key Conventions

**Norwegian Context**:
- UI language: Norwegian (Bokmål)
- Numbers: `123 456,78 kr`
- Dates: `dd.MM.yyyy`
- Currency: NOK (kroner)

**File Naming**:
- Components: `PascalCase.tsx`
- Utilities: `camelCase.ts`
- Types: `camelCase.types.ts`

**API Endpoints**:
- Base: `/api/v1`
- REST conventions (GET, POST, PATCH, DELETE)
- Standard response format

**Git Workflow** (USER MANAGED - agent never runs git):
- Main branch: `main`
- Conventional Commits format
- Never commit `.env` files
- **🚨 Agent NEVER runs git commands** - user handles all version control

## See Also

- [`.task-board/WORKFLOW.md`](../../.task-board/WORKFLOW.md) - Complete task management workflow
- [`.task-board/PLANNING-BOARD.md`](../../.task-board/PLANNING-BOARD.md) - Current top priorities
- [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) - Project-wide instructions
- [`.claude/skills/task-board/SKILL.md`](../task-board/SKILL.md) - Planning skill
- [`.claude/skills/task-discovery/SKILL.md`](../task-discovery/SKILL.md) - Task discovery skill
