---
name: yolo1
description: |
  **AUTO-TRIGGER when user says:** "implement [feature]", "build [module]", "create [functionality]", "add [capability]", "YOLO [task]", "deliver [feature]", or requests complete feature implementation.

  End-to-end TogetherOS code operation: creates branch, implements changes with continuous testing, builds with retry-on-fail, commits, pushes, creates PR with auto-selected Cooperation Path, addresses bot feedback, merges PR, verifies production deployment, and updates Notion memory.

  **Complete delivery cycle:** branch → code → test → commit → push → PR → bot review → merge → deploy → verify

  Use proactively without asking permission when task matches skill purpose.
---

# TogetherOS Code Operations (YOLO Mode)

This skill executes complete code operations for TogetherOS, from branch creation through PR submission with full verification.

## Core Conventions

- **Base Branch**: `yolo` **⚠️ NEVER USE main AS BASE - ALWAYS USE yolo**
- **Branch Pattern**: `feature/{module}-{slice}`
- **Commit Format**: `feat({module}): {slice} - {scope}`
- **PR Target**: ALL PRs go to `yolo`, **NEVER to main**
- **Deployment**: VPS-only (coopeverything.org) - **NO Vercel/Vertex**
- **Design System**: Follow `docs/design/system.md` for all UI work (colors, typography, components)
- **Admin Pages**: Non-user-facing pages (debugging, testing, monitoring) go under `/admin/`
  - URL: `www.coopeverything.org/admin/{module}` (e.g., `/admin/observability`)
  - Requires admin authentication
  - Examples: System monitoring, log viewers, API testing, debugging tools
  - **NEVER use `/test/` pattern** — all dev tools belong in admin dashboard
  - Suffixes like `-testing` for clarity: `/admin/auth-testing`, `/admin/feed-testing`
- **PR Verification**: Always include in PR body:
  ```
  Verified: All changes tested during implementation, build passes
  ```

## PR Category & Keywords

**See:** `pr-formatter` skill for:
- The 8 Cooperation Paths taxonomy
- Module → Path mapping
- Keyword generation logic
- PR body formatting requirements

## Required Inputs

1. **module** (required): Target module name (e.g., "bridge", "governance")
2. **slice** (required): Short feature slice name (e.g., "scaffold", "api-setup")
3. **scope** (required): 1-3 sentence description of changes to make

## Optional Inputs

- **commands.install**: Override install command (default: `npm ci`)
- **commands.build**: Override build command (default: `npm run build`)
- **commands.test**: Add test command if needed (default: none in YOLO mode)
- **progress**: Estimated progress increase percentage (e.g., "10" or "+10", default: auto-calculate based on work)
- **skip_progress**: Set to "true" to skip progress tracking (default: false)

## Workflow Steps

### 0. Session Memory (Start)

**Create Notion session page** to track this work:
```
Use Notion API: mcp__notion__API-post-page
Parent page ID: 296d133a-246e-80a6-a870-c0d163e9c826
Title format: "Nov 10, 25 14:30 - Session"
Initial content:
  - Repository: TogetherOS
  - Branch: yolo (or feature branch)
  - Module: {module}
  - Slice: {slice}
```

**Note:** This is optional but recommended for continuity between sessions. If Notion API fails (UUID bug #5504), retry once then proceed without blocking.

### 1. Preparation & Clean State Verification
- Verify working directory is clean (no uncommitted changes):
  ```bash
  # Check for uncommitted changes
  git status --porcelain

  # If output is NOT empty, stop and report:
  # "Working directory has uncommitted changes. Please commit or stash before starting:"
  # [list the uncommitted files]
  ```
- **CRITICAL:** Do NOT proceed if working directory is dirty. Feature branches must start from clean state to avoid accidental file inclusion.
- Ensure repo is on `yolo` branch and up to date:
  ```bash
  git checkout yolo
  git fetch origin yolo
  git merge origin/yolo
  ```
- Verify merge succeeded with no conflicts
- Create feature branch: `feature/{module}-{slice}`
  ```bash
  git checkout -b feature/{module}-{slice}
  ```

### 2. Implementation (Test as You Go)
- Apply scoped edits described in the `scope` parameter
- **CRITICAL**: Test your work continuously during implementation:
  - Read files you create/modify to verify correctness
  - Check syntax and logic as you write
  - Verify imports and dependencies
  - Ensure type safety
- List each file touched with a brief reason
- Keep changes strictly within scope (no scope creep)

### 2.5. Admin Page Navigation Registration (If Creating Admin Pages)

**MANDATORY if you created any page under `/admin/*`:**

When you create a new admin page at `apps/web/app/admin/{page-name}/page.tsx`:

1. **Register in admin navigation** - Edit `apps/web/app/admin/page.tsx`:
   ```typescript
   // Find the appropriate section in the `sections` array and add:
   {
     title: 'Page Title',
     description: 'Brief description of what this admin page does',
     path: '/admin/page-name',
     status: 'active',  // or 'coming-soon' for placeholders
   }
   ```
2. **Section selection guide:**
   - System Configuration — settings, config
   - AI & Content — Bridge, forum tags, gamification, moderation
   - Users & Groups — members, groups management
   - Governance & Economy — proposals, SP/RP, treasury
   - Monitoring & Data — observability, logs, analytics
   - Development & Testing — design system, testing pages

3. **Verify** the page appears in admin dashboard navigation at `/admin` before proceeding

**Why this matters:** Admin pages created without navigation registration become orphaned and inaccessible. Users expect all admin functionality to be discoverable from `/admin`.

### 3. Dependency Installation
- Run install command (default: `npm ci`)
- Verify dependencies installed correctly

### 4. Build with Auto-Retry
- Run build command (default: `npm run build`)
- **If build fails:**
  1. Read error output carefully
  2. Identify the specific issue (type error, import error, syntax error, etc.)
  3. Fix the issue
  4. Re-run build
  5. Repeat until build succeeds
- **Never give up on build failures** - keep correcting until build passes

### 5. Optional Testing
- If `commands.test` is provided, run tests
- Fix any test failures using the same retry approach as builds

### 6. Validation (Optional but Recommended)
- If `scripts/validate.sh` exists, run it to get proof lines
- This runs linting and validation checks
- Outputs: `LINT=OK` and `VALIDATORS=GREEN`
- If validation fails, fix issues and retry
- These proof lines should be included in PR body

### 6.5. CSS/UX Validation (MANDATORY for UI Changes)

**IMPORTANT:** If this PR includes `.tsx` or `.css` files with UI components, run CSS validation BEFORE creating PR:

```bash
# Run CSS validation
./scripts/validate-css.sh

# Expected output: CSS=OK
# If CSS=FAILED: Fix issues and re-run
```

**What it checks:**
1. CSS syntax errors (via stylelint if installed)
2. Undefined CSS variables (missing `--var-name` definitions)
3. Responsive breakpoints (pages should have mobile styles)
4. Accessibility focus states (interactive elements need focus styles)
5. Tailwind class validity (catches common mistakes)

**When to skip:**
- Backend-only changes (API routes, database, scripts)
- Documentation-only changes
- Changes that don't modify UI components

**Integration with UX Designer Skill:**
For UI/theme/CSS work, ALWAYS follow the `ux-designer` verification workflow:
1. **Scope Discovery** - Find ALL affected files BEFORE editing
2. **TodoWrite Tracking** - Create item for each file
3. **Verification** - Re-grep to confirm zero remaining issues
4. **Visual Test** - Toggle themes to verify

**See:** `.claude/skills/ux-designer/SKILL.md` for verification workflow and CSS var reference

### 7. Security Check (P1 Alerts in Modified Files)
- **IMPORTANT:** Danger.js will automatically block merge if P1 alerts exist in modified files
- Check if any of YOUR modified files have open P1 (error severity) CodeQL alerts
- Run: `gh api repos/coopeverything/TogetherOS/code-scanning/alerts --jq '.[] | select(.state == "open" and .rule.severity == "error") | .most_recent_instance.location.path' | sort -u`
- Cross-reference with files modified in this PR (from `git diff --name-only yolo`)
- **If P1 alerts exist in modified files:**
  - MUST fix them before creating PR (Danger.js will block merge otherwise)
  - Common fixes: `JSON.stringify(userInput)` for log injection, parameterized queries for SQL injection
  - View alert details: https://github.com/coopeverything/TogetherOS/security/code-scanning
- **If P1 alerts only in unmodified files:** Informational only (won't block merge)
- Include security status in PR body: `SECURITY=OK (0 P1 alerts in modified files)` or `SECURITY=WARN (X P1 alerts exist, but not in modified files)`

### 8. Git Operations + Error Learning
- Commit with message: `feat({module}): {slice} - {scope}`
- **Invoke `error-learner` skill:**
  - Analyze session transcript for error patterns
  - Check `.claude/data/session-errors.json` for cross-session patterns
  - **If same-session pattern (2+ occurrences):**
    - Research root cause and best practice
    - Update knowledge files immediately (before push)
  - **If cross-session pattern detected:**
    - Promote stored error to "pattern" status
    - Update knowledge files immediately
  - **If one-off error:**
    - Store in session-errors.json for future tracking
- Push branch: `git push -u origin feature/{module}-{slice}`

### 9. Progress & Next Steps Update

**Use `status-tracker` skill** to:
- Calculate estimated progress increase based on work completed
- Update module's Next Steps using `scripts/update-module-next-steps.sh`
- Mark completed tasks as done
- Add any new tasks discovered during implementation
- Prepare progress marker for PR body (e.g., `progress:bridge=+10`)

### 10. PR Creation with Auto-Category & Progress

**Use `pr-formatter` skill** to:
- Auto-select Cooperation Path from module
- Generate 3-5 relevant keywords
- Format PR body with exact structure
- Include progress marker from step 8
- Create PR with `gh pr create --base yolo`

**Then monitor post-push and verify bot reviews:**
- Wait ~60 seconds for AI reviewers (Copilot/Codex) to complete analysis
- **CRITICAL: Check for Codex inline comments** (not just review body):
  ```bash
  # Method 1: Check inline code review comments (try multiple endpoints)

  # Endpoint 1: Pull request comments
  gh api repos/coopeverything/TogetherOS/pulls/<PR#>/comments \
    --jq '.[] | select(.user.login == "chatgpt-codex-connector") | {file: .path, line: .line, body: .body}'

  # Endpoint 2: Pull request reviews
  gh api repos/coopeverything/TogetherOS/pulls/<PR#>/reviews \
    --jq '.[] | select(.user.login == "chatgpt-codex-connector")'

  # Endpoint 3: Issue comments (general PR comments)
  gh api repos/coopeverything/TogetherOS/issues/<PR#>/comments \
    --jq '.[] | select(.user.login == "chatgpt-codex-connector")'

  # Method 2: ALWAYS verify on web UI (MANDATORY, not just fallback)
  gh pr view <PR#> --web
  # REQUIRED: Manually inspect "Files Changed" tab for inline comments
  # GitHub sometimes returns empty API results even when comments exist
  ```
- **Process for verification:**
  1. Run all API commands above
  2. Open web UI (mandatory verification step)
  3. Scroll through EVERY file in "Files Changed" tab
  4. Look for comment badges on line numbers
  5. Only after web UI verification can you confirm "no P1 issues"
- **Analyze Codex feedback priority**:
  - **P1 (Critical)**: MUST fix before merge - security issues, breaking changes, build artifacts
  - **P2 (Important)**: SHOULD fix before merge - code quality, best practices
  - **P3 (Nice-to-have)**: CAN defer - minor suggestions, stylistic preferences
- **Fix all P1 issues** before considering PR merge-ready
- **For each P1 issue**:
  1. Fix the code
  2. Commit with descriptive message (e.g., "fix: address Codex P1 - remove build artifact import")
  3. Push to update PR
  4. Wait for re-analysis
- Check for Copilot sub-PRs:
  ```bash
  gh pr list --author "app/copilot-swe-agent" --search "sub-pr-<PR#>"
  ```
- If sub-PR exists: Review changes, cherry-pick useful fixes, close sub-PR with explanation
- Verify all checks passing: `gh pr checks <PR#>`
- **Note:** Lint/smoke disabled on yolo branch, but test check must pass

Output PR URL and summary of bot feedback addressed

### 11. Merge PR When Ready

**After all checks pass and P1 issues resolved:**
```bash
# Verify PR is truly merge-ready
gh pr checks <PR#>  # All must be green
gh pr view <PR#> --json mergeable --jq '.mergeable'  # Must be "MERGEABLE"

# Verify no unresolved P1 Codex issues via web UI (mandatory check)
gh pr view <PR#> --web
# Manually confirm no P1 issues in Files Changed tab

# Merge PR
gh pr merge <PR#> --squash --delete-branch

# Capture merge commit SHA
MERGE_SHA=$(gh pr view <PR#> --json mergeCommit --jq '.mergeCommit.oid')
echo "Merged as commit: $MERGE_SHA"
```

**Do NOT stop at "ready to merge" - actually merge the PR when verified.**

### 12. Deployment Verification

**After merge, verify production deployment:**
```bash
# Get workflow run triggered by merge
WORKFLOW_RUN=$(gh run list --workflow=auto-deploy-production.yml --branch=yolo --limit 1 --json databaseId --jq '.[0].databaseId')

# Monitor deployment (wait up to 5 minutes)
gh run watch $WORKFLOW_RUN --exit-status

# Check deployment status
DEPLOY_STATUS=$(gh run view $WORKFLOW_RUN --json conclusion --jq '.conclusion')

if [ "$DEPLOY_STATUS" = "success" ]; then
  echo "✅ Deployment successful"
  echo "Changes live at: https://www.coopeverything.org"
else
  echo "❌ Deployment failed - see logs:"
  gh run view $WORKFLOW_RUN --log-failed
  # Report deployment failure to user for investigation
fi
```

### 12.5. Run Verification Tests (MANDATORY)

**Execute the MANDATORY Fix Verification Checklist from CLAUDE.md:**
1. Run `./scripts/verify-fix.sh` - must exit 0
2. Check production health: `curl https://coopeverything.org/api/health`
3. If validation fix: grep for exact error message across ALL layers
4. Monitor deployment workflow completion

**If ANY step fails → NOT delivered. Fix and re-deploy.**

**Output final delivery summary:**
```
✅ Feature delivered:
- PR #<num>: <title>
- Merged commit: <sha>
- Deployment: <SUCCESS|FAILED>
- Live URL: https://www.coopeverything.org/<relevant-path>
```

**Only after deployment verification is delivery complete.**

### 13. Update Module Documentation (CRITICAL - MANDATORY)

**⚠️ MSSP - Module Status Synchronization Protocol**

**This step is MANDATORY. Failure to update ALL THREE locations causes progress tracking drift.**

**CRITICAL: After successful deployment, update ALL THREE documentation locations:**

**Step 13.1: Calculate Progress Increase**

```bash
# Progress calculation guidelines:
# - Phase 1 complete (basic features): ~30-40%
# - Phase 2 complete (enhanced features): ~60-70%
# - Phase 3 complete (advanced features): ~90%
# - Full module complete: 100%
# - Calculate based on work completed in this PR
```

**Step 13.2: Update STATUS_v2.md (AUTHORITATIVE SOURCE)**

```bash
# 1. Edit docs/STATUS_v2.md
# 2. Find the module's table row
# 3. Update the progress marker: <!-- progress:module-name=Y -->
# 4. Update the description of what's complete
# Example:
#   | **Module** | Description | <!-- progress:module=85 --> 85% | Next | Notes |
```

**Step 13.3: Update Individual Module Spec**

```bash
# 1. Edit docs/modules/{module-name}.md
# 2. Find the progress line:
#    **Current Progress:** <!-- progress:module-name=X --> X%
# 3. Update to match STATUS_v2.md:
#    **Current Progress:** <!-- progress:module-name=Y --> Y%
# 4. Update visible "Progress: Y%" text at bottom of file if present
```

**Step 13.4: Update Modules INDEX (THE CRITICAL ONE)**

```bash
# 1. Edit docs/modules/INDEX.md
# 2. Find the module entry in the list
# 3. Update percentage and description to match STATUS_v2.md
# Examples:
#   BEFORE: "(50% complete — Phase 1 complete)"
#   AFTER:  "(85% complete — Phase 1-2 complete, production-verified)"
#
#   BEFORE: "(0% — spec only)"
#   AFTER:  "(35% — Phase 1 complete)"
```

**Step 13.4b: Sync ALL Modules in Shared Data File (VISIBLE TO USERS)**

```bash
# ⚠️ CRITICAL: Update the shared data file - single source for both UI pages!
# This file feeds BOTH /modules (public) AND /admin/modules (admin)

# 1. Read docs/STATUS_v2.md to get authoritative progress for ALL modules
# 2. Read apps/web/lib/data/modules-data.ts (SHARED DATA FILE)
# 3. Compare progress values for EVERY module
# 4. Update ANY module that has drifted (not just current task)
# 5. Update descriptions if they're significantly outdated

# Module mapping (STATUS_v2.md name → modules-data.ts title):
#   Observability → 'Observability & Monitoring'
#   Search & Tags → 'Search & Discovery'
#   Notifications & Inbox → 'Notifications & Inbox'
#   Governance → 'Governance & Proposals'
#   Forum → 'Forum & Deliberation'
#   Bridge → 'Bridge AI Assistant'
#   Onboarding ("Bridge") → 'Onboarding Experience'
#   etc.

# For each module in STATUS_v2.md:
#   - Extract progress from: <!-- progress:module-name=X -->
#   - Find matching entry in modules-data.ts modules array
#   - If progress differs, update the `progress:` value
#   - If status changed (e.g., now 100%), update `status:` to 'complete'

# UI Pages that consume this data:
#   - /modules (public) → apps/web/app/modules/page.tsx
#   - /admin/modules (admin) → apps/web/app/admin/modules/page.tsx
# Both import from: apps/web/lib/data/modules-data.ts
```

**Why sync via shared data file?**
- Prevents cumulative drift (multiple sessions can each miss updates)
- Single source of truth: STATUS_v2.md → modules-data.ts → UI pages
- Users always see accurate progress on BOTH /modules and /admin/modules
- Only ONE file to update, not two separate page files

**Step 13.5: Verify Synchronization (MANDATORY)**

```bash
# REQUIRED: Run the status check script BEFORE committing
# This validates STATUS_v2.md ↔ Module specs AND STATUS_v2.md ↔ INDEX.md
./scripts/check-module-status.sh

# Expected output: "✅ All module progress markers are synchronized!"
# If ANY discrepancies found:
# 1. Fix ALL issues (not just the module you worked on)
# 2. Re-run script to confirm
# 3. Only then proceed to commit

# DO NOT SKIP THIS STEP - it catches INDEX.md drift that causes visible progress inconsistencies
```

**Step 13.6: Commit Documentation Updates**

```bash
git add docs/modules/ docs/STATUS_v2.md apps/web/lib/data/modules-data.ts
git commit -m "docs(modules): update {module-name} progress to Y%

Updates all four locations (MSSP):
- STATUS_v2.md: {module} at Y% (was X%)
- docs/modules/{module-name}.md: Progress marker updated
- apps/web/lib/data/modules-data.ts: Shared data synced (feeds /modules + /admin/modules)
- docs/modules/INDEX.md: Entry updated to Y%

Phase X implementation complete:
- Component/feature 1
- Component/feature 2
- Component/feature 3

PR #<num> merged and deployed successfully.

Verified: ./scripts/check-module-status.sh shows all markers synchronized

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push documentation update
git pull origin yolo --rebase  # In case deployment created commits
git push origin yolo
```

**MANDATORY: Update ALL FOUR locations:**
1. ✅ **STATUS_v2.md** (authoritative source)
2. ✅ **Module spec file** (`docs/modules/{module-name}.md`)
3. ✅ **Modules INDEX** (`docs/modules/INDEX.md`)
4. ✅ **Shared modules data** (`apps/web/lib/data/modules-data.ts`) ← **FEEDS BOTH /modules AND /admin/modules**

**Verification:** Run `./scripts/check-module-status.sh {module-name}` before committing

### 14. Session Memory (Finalize)

**Update Notion session page** with final summary:
```
Use Notion API: mcp__notion__API-patch-block-children
Update session page created in Step 0

Add final blocks:
  - Accomplishments: What was delivered
  - PR: Link to merged PR
  - Deployment: Success/failure status
  - Files Changed: Count and key files
  - Duration: Session start to end time
  - Status: ✅ Completed

Update page title: "Nov 10, 25 14:30 - {module} {slice} implementation"
```

**Cleanup old sessions** (keep only 6 most recent):
```
Use Notion API: mcp__notion__API-post-search
Search for session pages, sort by last_edited_time
If count > 6: Archive oldest pages using mcp__notion__API-delete-a-block
```

**Note:** This is optional but recommended for session continuity. If it fails, don't block - report completion and move on.

## Safety Guidelines

1. **Never commit secrets** — Use environment variables or CI secrets
2. **Stay within scope** — No unrelated refactoring or feature creep
3. **Minimal diffs** — Change only what's necessary
4. **Test continuously** — Verify your work as you implement, not just at the end
5. **Fix all build errors** — Never open a PR with a failing build
6. **One concern per PR** — No bundling unrelated changes

## Example Usage

### Example 1: Bridge Scaffold
```
Use Skill: togetheros-code-ops
Inputs:
  module: bridge
  slice: scaffold
  scope: Create /bridge route, stub component in packages/ui, docs/modules/bridge/README.md
```

**Expected Behavior**:
- Branch: `feature/bridge-scaffold`
- Commit: `feat(bridge): scaffold - Create /bridge route, stub component in packages/ui, docs/modules/bridge/README.md`
- PR formatted via `pr-formatter` skill (auto-selected category & keywords)

### Example 2: Governance Integration
```
Use Skill: togetheros-code-ops
Inputs:
  module: governance
  slice: oss-integration
  scope: Integrate selected governance OSS with auth/DB and CI
```

**Expected Behavior**:
- Branch: `feature/governance-oss-integration`
- Commit: `feat(governance): oss-integration - Integrate selected governance OSS with auth/DB and CI`
- PR formatted via `pr-formatter` skill (auto-selected category & keywords)

## Testing Philosophy (YOLO Mode)

In YOLO mode, **you (Claude) are the primary quality gate**:
- No formal linting required before commit (you check code quality as you write)
- No separate test phase (you verify correctness during implementation)
- Build must pass (automated check for syntax/type correctness)
- Optional validation via `scripts/validate.sh` (recommended for proof lines)
- Continuous self-testing replaces traditional QA pipeline

**This means**: Read your code, check your logic, verify your types, and ensure correctness at every step. The build is your final verification that everything compiles correctly.

**About Validation Scripts**: While YOLO mode emphasizes self-testing, running `scripts/validate.sh` before committing provides proof lines (`LINT=OK`, `VALIDATORS=GREEN`) that CI checks look for. These checks are advisory-only and won't block merges, but including them shows good practice.

## Related Skills

- **pr-formatter**: PR creation, formatting, validation, AI feedback loop
- **status-tracker**: Progress tracking, next steps management, Notion memory
- **error-learner**: Session error analysis, cross-session pattern detection, KB updates
- **ux-designer**: UI/UX design system, themes, accessibility, responsive patterns
- **verify-fix**: See CLAUDE.md "MANDATORY Fix Verification Checklist" (always in context)

**See those skills for:**
- Keyword generation details → `pr-formatter`
- Progress estimation guide → `status-tracker`
- Module progress keys → `status-tracker`
- Notion memory updates → `status-tracker`
- PR verification checklist → `pr-formatter`
- Error pattern detection → `error-learner`
- Cross-session learning → `error-learner`
- Theme system (6 palettes) → `ux-designer`
- Fluid typography patterns → `ux-designer`
- Accessibility checklist → `ux-designer`
- CSS validation script → `scripts/validate-css.sh`
