---
name: pr-formatter
description: |
  **AUTO-TRIGGER when user says:** "create PR", "format PR", "prepare PR body", "what category for this PR", "generate PR keywords"

  Formats TogetherOS pull requests with proper category (Cooperation Path), keywords, progress markers, and validation. Auto-selects category from module, generates relevant keywords, ensures correct structure for automation.

  Use proactively without asking permission when task matches skill purpose.
---

# TogetherOS PR Formatter & Validator

This skill handles all PR creation, formatting, validation, and pre-push checks for TogetherOS.

## What This Skill Does

- Auto-selects Cooperation Path category from module
- Generates 3-5 relevant keywords
- Formats PR body with exact structure for automation
- Validates PR is merge-ready before suggesting merge
- Runs pre-push validation checks
- Addresses Codex/Copilot comments until all checks green

## The 8 Cooperation Paths

Every PR must be tagged with ONE of these paths:

1. **Collaborative Education** — Learning, co-teaching, peer mentorship, skill documentation
2. **Social Economy** — Cooperatives, timebanking, mutual aid, repair/reuse networks
3. **Common Wellbeing** — Health, nutrition, mental health, community clinics, care networks
4. **Cooperative Technology** — Open-source software, privacy tools, federated services, human-centered AI
5. **Collective Governance** — Direct legislation, deliberation, empathic moderation, consensus tools
6. **Community Connection** — Local hubs, events, volunteer matching, skill exchanges
7. **Collaborative Media & Culture** — Storytelling, documentaries, cultural restoration, commons media
8. **Common Planet** — Regeneration, local agriculture, circular materials, climate resilience

## Module → Path Mapping

Use this mapping to auto-select the appropriate Cooperation Path:

- **bridge** → Cooperative Technology
- **governance** → Collective Governance
- **social-economy**, **timebank**, **support-points** → Social Economy
- **moderation**, **discourse** → Collective Governance
- **community**, **events**, **volunteer** → Community Connection
- **education**, **learning**, **mentorship** → Collaborative Education
- **health**, **wellness**, **care** → Common Wellbeing
- **media**, **culture**, **storytelling** → Collaborative Media & Culture
- **environment**, **sustainability**, **agriculture** → Common Planet
- **infrastructure**, **monorepo**, **ci-cd**, **api** → Cooperative Technology (default for tech work)

## Workflow Steps

### 1. Pre-Push Validation (REQUIRED)

**Before creating ANY PR, run these checks:**

```bash
# 1. Update target branch
git fetch origin yolo

# 2. Check if feature branch is up-to-date
git merge-base --is-ancestor origin/yolo HEAD
# If fails, need to rebase/merge

# 3. Merge/rebase onto latest target
git merge origin/yolo
# OR: git rebase origin/yolo

# 4. Verify no merge conflicts
git status | grep -q "Unmerged paths" && echo "CONFLICTS FOUND - FIX FIRST"

# 5. Verify TypeScript compiles
cd apps/web && npx tsc --noEmit

# 6. Run tests (when available)
npm run test 2>/dev/null || echo "No tests configured yet"

# 7. Verify CI would pass
# Check lint, build, etc. locally before pushing
```

**Pre-Push Checklist:**
- ✅ Feature branch is up-to-date with target branch
- ✅ No merge conflicts exist
- ✅ TypeScript compiles without errors
- ✅ Tests pass (when tests exist)
- ✅ CI would pass (run checks locally)

**Only After All Checks Pass:**
```bash
git push origin feature-branch
gh pr create --base yolo --head feature-branch
```

### 2. Generate Keywords

Generate 3-5 keywords by combining:

1. **Module name** (always include)
2. **Technical components**: API, UI, database, routing, auth, etc.
3. **Action type**: scaffold, integration, refactor, feature, bugfix
4. **Domain concepts**: From the 8 Paths and their subcategories (see docs/cooperation-paths.md)

**Example for bridge module:**
- `bridge`, `ai-assistant`, `streaming`, `citations`, `knowledge-base`

**Example for governance module:**
- `governance`, `proposals`, `voting`, `consensus`, `deliberation`

**Example for social-economy module:**
- `social-economy`, `timebanking`, `mutual-aid`, `cooperatives`, `transactions`

### 3. Format PR Body

Create PR with this EXACT format:

```markdown
Category: [Selected Cooperation Path Name]
Keywords: [keyword1, keyword2, keyword3, ...]

## Summary
[What changed and why]

## Files Changed
[List with brief description]

## Progress
progress:{module}=+X

[Proof lines if validation run]
```

**CRITICAL FORMAT RULES:**
- First line MUST be `Category:` (plain text, no bold, no markdown)
- Second line MUST be `Keywords:` (plain text, no bold, no markdown)
- Then blank line, then markdown sections
- Progress marker in body for auto-update on merge
- Always include verification: "Verified: All changes tested during implementation, build passes"

### 4. Create PR with gh CLI

```bash
gh pr create --base yolo --head feature-branch --title "[Title]" --body "[Formatted body]"
```

**Note:** If `gh` CLI is not authenticated, output the PR creation URL and the formatted PR body for manual creation.

### 5. Post-Push CI Verification (IMPORTANT)

**After pushing, monitor for AI reviewer comments:**

**Note:** Lint and smoke tests are **disabled on yolo branch** - don't expect those checks.

**Active checks on yolo:**
- GitHub Copilot code review comments
- Codex AI review comments
- Build verification
- Other automated reviewers

**Process:**
1. After PR created, wait ~60 seconds for AI reviewers to analyze (Codex + Copilot)
2. **Check for inline code comments** (use multiple API endpoints):
   ```bash
   # CRITICAL: Check Codex inline review comments (try multiple endpoints)

   # Endpoint 1: Pull request comments
   gh api repos/coopeverything/TogetherOS/pulls/<PR#>/comments \
     --jq '.[] | select(.user.login == "chatgpt-codex-connector") | {file: .path, line: .line, body: .body}'

   # Endpoint 2: Pull request reviews
   gh api repos/coopeverything/TogetherOS/pulls/<PR#>/reviews \
     --jq '.[] | select(.user.login == "chatgpt-codex-connector")'

   # Endpoint 3: Issue comments (general PR comments)
   gh api repos/coopeverything/TogetherOS/issues/<PR#>/comments \
     --jq '.[] | select(.user.login == "chatgpt-codex-connector")'

   # Check Copilot inline comments (all endpoints)
   gh api repos/coopeverything/TogetherOS/pulls/<PR#>/comments \
     --jq '.[] | select(.user.login | contains("copilot")) | {file: .path, line: .line, body: .body}'

   gh api repos/coopeverything/TogetherOS/pulls/<PR#>/reviews \
     --jq '.[] | select(.user.login | contains("copilot"))'
   ```
3. **MANDATORY: Always verify on web UI** (not just when API returns empty):
   ```bash
   gh pr view <PR#> --web
   ```
   **Verification checklist:**
   - [ ] Open "Files Changed" tab
   - [ ] Scroll through EVERY changed file
   - [ ] Look for comment badges/icons on line numbers
   - [ ] Read ALL inline comments (not just review summary)
   - [ ] Confirm P1 issues identified in API queries match web UI
   - [ ] Look for comments that API might have missed

   **CRITICAL:** GitHub API sometimes returns empty results even when comments exist. Web UI inspection is REQUIRED for every PR, not optional.
4. **Categorize feedback by priority**:
   - **P1 (Critical)**: MUST fix - security, build artifacts, breaking changes
   - **P2 (Important)**: SHOULD fix - code quality, performance, best practices
   - **P3 (Nice-to-have)**: CAN defer - style, minor suggestions
5. **Fix all P1 issues before proceeding**:
   - Read the issue carefully
   - Fix the code
   - Commit: `git commit -m "fix: address Codex P1 - [description]"`
   - Push to update PR
   - Wait for re-review
6. Check for Copilot sub-PRs:
   ```bash
   gh pr list --author "app/copilot-swe-agent" --search "sub-pr-<PR#>"
   ```
7. Repeat until all AI reviewers satisfied and checks green

**Commands:**
```bash
# Check inline comments (preferred method)
gh api repos/coopeverything/TogetherOS/pulls/<PR#>/comments \
  --jq '.[] | select(.user.login == "chatgpt-codex-connector" or (.user.login | contains("copilot")))'

# View PR on web if API queries fail
gh pr view <PR#> --web

# Check general PR comments
gh pr view <PR#> --comments

# Check CI status
gh pr checks <PR#>

# View specific check logs
gh run view <run-id> --log-failed

# After fixing issues
git add . && git commit -m "fix: address Codex P1 - [specific issue]"
git push
```

### 6. PR Verification (Before Suggesting Merge)

**Always run this checklist before saying "ready to merge":**

```bash
# 1. Check mergeable status
gh pr view <PR#> --json mergeable,baseRefName

# 2. Verify base is yolo (not main!)
# baseRefName should be "yolo"

# 3. Review CI checks
gh pr checks <PR#>

# 4. Check for unresolved comments
gh pr view <PR#> --comments

# 5. Fix conflicts if needed
git fetch origin yolo && git merge origin/yolo

# 6. Fix CI failures if needed
gh run view <run-id> --log-failed
```

**Never Say "Ready to Merge" Until:**
- ✅ Mergeable status = MERGEABLE
- ✅ All CI checks passing (green)
- ✅ All Copilot/Codex comments addressed
- ✅ No unresolved review comments
- ✅ All commits quality-checked

**See:** `docs/dev/pr-checklist.md`

## Core Conventions

- **Base Branch**: `yolo` **⚠️ NEVER USE main AS BASE - ALWAYS USE yolo**
- **PR Target**: ALL PRs go to `yolo`, **NEVER to main**
- **Branch Pattern**: `feature/{module}-{slice}`
- **CI on yolo**: Lint/smoke disabled, Copilot/Codex enabled

## Example Usage

### Example 1: Format PR for Bridge Module
```
Use Skill: pr-formatter
Context: Completed bridge streaming UI on branch feature/bridge-streaming
Module: bridge
Slice: streaming
Changes: Added streaming UI components, API handlers, and tests
```

**Expected Output:**
```markdown
Category: Cooperative Technology
Keywords: bridge, ai-assistant, streaming, ui-components, real-time

## Summary
Implemented streaming UI for the Bridge AI assistant module, enabling real-time
response rendering with proper citation display.

## Files Changed
- packages/ui/src/components/bridge/StreamingChat.tsx - New streaming chat component
- apps/web/app/api/bridge/stream/route.ts - Streaming API endpoint
- packages/ui/src/components/bridge/CitationDisplay.tsx - Citation rendering

## Progress
progress:bridge=+15

Verified: All changes tested during implementation, build passes
```

### Example 2: Validate PR Before Merge
```
Use Skill: pr-formatter
Context: PR #42 created, need to check if it's ready to merge
Action: Run full PR verification checklist
```

**Expected Actions:**
1. Run `gh pr view 42 --json mergeable,baseRefName`
2. Run `gh pr checks 42`
3. Check for Copilot/Codex comments: `gh pr view 42 --comments`
4. Verify all checks passing and comments resolved
5. Report: "PR #42 is ready to merge" or "PR #42 has issues: [list]"

### Example 3: Address AI Reviewer Feedback
```
Use Skill: pr-formatter
Context: PR #42 has Copilot comments about potential issues
Action: Review and address all feedback
```

**Expected Actions:**
1. Read all Copilot/Codex comments
2. For each valid concern: Fix code, commit, push
3. For false positives: Add reply explaining context
4. Wait for checks to re-run
5. Verify all green before reporting ready

## Integration with Other Skills

**With yolo1:**
- yolo1 calls pr-formatter to format PR body before creation
- Uses auto-selected category and keywords
- Includes progress marker from status-tracker
- Monitors CI and addresses feedback

**With status-tracker:**
- Includes progress marker in formatted PR body
- Ensures correct syntax for automation trigger

**Standalone:**
- Format PR manually: "format PR for bridge module"
- Validate existing PR: "check if PR #42 is ready"
- Pre-push check: "validate before pushing"
- Address feedback: "fix Copilot comments on PR #42"

## Keyword Generation Details

### Technical Component Keywords
- **API**: `api`, `endpoint`, `route`, `handler`, `rest`, `graphql`
- **UI**: `ui`, `component`, `interface`, `design-system`, `styling`
- **Database**: `database`, `schema`, `migration`, `postgres`, `prisma`
- **Auth**: `authentication`, `authorization`, `jwt`, `session`, `permissions`
- **Testing**: `tests`, `e2e`, `unit-tests`, `integration-tests`
- **DevOps**: `ci-cd`, `deployment`, `docker`, `github-actions`

### Action Type Keywords
- **scaffold**: Initial setup, boilerplate, structure
- **integration**: Connecting systems, third-party services
- **refactor**: Code cleanup, optimization, restructuring
- **feature**: New functionality, capabilities
- **bugfix**: Error correction, issue resolution
- **enhancement**: Improvements to existing features

### Domain Keywords from 8 Paths
Reference `docs/cooperation-paths.md` for full taxonomy of domain-specific keywords.

**Examples:**
- **Collaborative Education**: `learning`, `mentorship`, `peer-learning`, `skill-sharing`
- **Social Economy**: `cooperatives`, `timebanking`, `mutual-aid`, `solidarity`
- **Governance**: `proposals`, `voting`, `consensus`, `deliberation`, `decision-making`
- **Technology**: `open-source`, `privacy`, `federation`, `ai`, `automation`

## Safety Guidelines

1. **Always verify base branch is yolo** - Never create PR to main
2. **Run pre-push validation** - Don't push failing code
3. **Test before PR creation** - Build must pass
4. **Include progress marker** - Enable automation
5. **Use exact format** - First two lines: `Category:` and `Keywords:` (plain text)
6. **Address all AI feedback** - Don't ignore Copilot/Codex comments
7. **Wait for green checks** - Don't suggest merge until all pass

## Troubleshooting

**PR automation not triggering?**
- Check first line is exactly `Category: [Path Name]` (no bold, no extra formatting)
- Verify second line is exactly `Keywords: [list]`
- Ensure progress marker syntax: `progress:module=+X`

**Pre-push validation failing?**
- Run each check individually to isolate issue
- Fix TypeScript errors before pushing
- Merge latest yolo to resolve conflicts
- Check CI logs for specific failures

**Copilot/Codex comments not appearing?**
- Wait ~60 seconds after PR creation
- Check PR comments manually on GitHub
- Refresh with `gh pr view <PR#> --comments`

**AI feedback seems wrong?**
- Review the suggestion carefully - often it's valid
- If truly incorrect, reply with explanation
- Don't ignore - address all comments

## Reference

**Full Documentation:**
- PR checklist: `docs/dev/pr-checklist.md`
- Category taxonomy: `docs/cooperation-paths.md`
- Progress tracking: `docs/dev/progress-tracking-automation.md`

**Related Skills:**
- **yolo1**: Full implementation workflow (calls this skill)
- **status-tracker**: Progress tracking (provides progress marker)
