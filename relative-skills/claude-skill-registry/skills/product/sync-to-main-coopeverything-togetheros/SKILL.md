---
name: sync-to-main
description: |
  **AUTO-TRIGGER when:**
  - Progress reaches 5% milestone (5%, 10%, 15%, 20%...)
  - User says "sync [module] to main"
  - User says "approve main sync"
  - User says "reconcile [module] with main"

  Manages two-phase sync from yolo to main: (1) WIP markers to prevent contributor conflicts, (2) code sync with CI reconciliation after production validation.

  Use proactively without asking permission when task matches skill purpose.
---

# sync-to-main

Maintains the main branch as a clean, CI-compliant branch for human contributors by selectively syncing production-validated code from yolo with proper quality gates.

## What This Skill Does

- **Phase 1 (Automatic)**: Creates WIP markers in main at 5% progress milestones to prevent contributor conflicts
- **Phase 2 (User-Initiated)**: Syncs code from yolo to main after user validates production
- Reconciles yolo's freestyle code with main's strict CI requirements (lint, build, validation)
- Maintains status synchronization between branches (STATUS_v2.md, progress-log.md)
- Prevents duplicate work hours by showing active development to contributors

## Core Conventions

### Branch Strategy
- **yolo**: Production branch with relaxed CI (lint/smoke disabled)
- **main**: Contributor branch with strict CI (all checks enabled)
- **Challenge**: Code written for yolo won't pass main's CI gates
- **Solution**: Two-phase sync with reconciliation step

### Content Sync Scope
**Include**:
- Application code (src/, lib/, components/, etc.)
- Shared knowledge (docs/knowledge/)
- Status tracking (STATUS_v2.md, progress-log.md)
- Configuration (package.json, tsconfig.json)

**Exclude**:
- AI automation (.claude/)
- Automation tooling (codex/)
- CI workflows (.github/workflows/ - main has different workflows)

### Progress Milestones
Triggers at: 5%, 10%, 15%, 20%, 25%, 30%, 35%, 40%, 45%, 50%, 55%, 60%, 65%, 70%, 75%, 80%, 85%, 90%, 95%, 100%

## Workflow Steps

### Phase 1: Create WIP Marker (Automatic)

**Triggered by**: `status-tracker` when module progress reaches 5% milestone

**Steps**:

1. **Checkout main branch**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Update STATUS_v2.md with WIP marker**

   Find the module's progress line and add 🔄 indicator:
   ```markdown
   - [Module] 🔄 XX% - In active development (yolo branch)
   ```

3. **Commit WIP marker**
   ```bash
   git add docs/STATUS_v2.md
   git commit -m "wip: [module] active on yolo (XX% complete)"
   git push origin main
   ```

4. **Return to yolo branch**
   ```bash
   git checkout yolo
   ```

5. **Notify user**
   ```
   WIP marker created in main for [module] (XX%).
   Contributors will see this module is in active development.
   Continue working on yolo. When ready to sync after production testing, say "sync [module] to main".
   ```

### Phase 2: Sync Code to Main (User-Initiated)

**Triggered by**: User approval after production validation

**Manual trigger phrases**:
- "sync [module] to main"
- "approve main sync"
- "reconcile [module] with main"

**Steps**:

#### 1. Preparation

```bash
# Ensure we're on yolo and up to date
git checkout yolo
git pull origin yolo

# Get latest main
git fetch origin main

# Identify commits to sync
git log origin/main..HEAD --oneline --grep="feat([module])" --grep="fix([module])"
```

#### 2. Checkout main and prepare sync

```bash
git checkout main
git pull origin main

# Create sync branch
git checkout -b sync/[module]-to-main
```

#### 3. Selective sync with cherry-pick

```bash
# Cherry-pick relevant commits from yolo
# (Claude identifies commits related to the module)
git cherry-pick [commit-hash-1]
git cherry-pick [commit-hash-2]
# ... continue for all module commits
```

**If conflicts occur**:
- Stop the process
- Notify user: "Merge conflicts detected in [files]. Please resolve manually."
- Provide instructions: `git status` to see conflicts
- Exit skill

#### 4. Reconcile with main's CI requirements

**Run auto-fixes**:
```bash
# Auto-fix lint issues
npm run lint -- --fix

# Verify TypeScript compiles
npm run build

# Run validation
scripts/validate.sh
```

**If auto-fix succeeds**:
- Commit fixes: `git commit -am "fix: lint/build reconciliation for main CI"`

**If auto-fix fails**:
- Show remaining errors to user
- Ask: "Auto-fix couldn't resolve all issues. Options:"
  1. "Claude should fix remaining issues" → Claude manually fixes each error
  2. "Create GitHub issues for manual review" → Log issues and skip for now
  3. "Stop sync" → Abort and return to yolo

#### 5. Sync status files from yolo

```bash
# Copy current status from yolo branch
git checkout yolo -- docs/STATUS_v2.md
git checkout yolo -- STATUS/progress-log.md

# Remove 🔄 WIP marker, keep progress percentage
# (Claude edits STATUS_v2.md to remove "In active development" marker)
```

#### 6. Final validation

```bash
# Ensure everything still builds
npm run build

# Verify validation passes
scripts/validate.sh
```

#### 7. Commit and push to main

```bash
git add .
git commit -m "sync: [module] from yolo (production-validated)

- Synced module code from yolo branch
- Reconciled with main CI requirements (lint/build)
- Updated status tracking to match yolo
- Production-validated at [URL]

From commits:
- [commit-hash-1]: [message]
- [commit-hash-2]: [message]
"

git push origin sync/[module]-to-main
```

#### 8. Create PR to main

```bash
gh pr create \
  --base main \
  --title "sync: [module] from yolo (production-validated)" \
  --body "## Summary
Syncing production-validated [module] code from yolo to main.

## Production Validation
- Tested on: coopeverything.org
- Status: User-approved
- Progress: [module] at XX%

## Changes Synced
[List of features/fixes included]

## CI Reconciliation
- Lint: Fixed
- Build: Passing
- Validation: Passing

## Status Update
- STATUS_v2.md: Updated to match yolo
- progress-log.md: Synced

From yolo commits:
$(git log origin/main..HEAD --oneline)
"
```

#### 9. Merge PR (if approved)

```bash
# After PR review/approval
gh pr merge --merge --delete-branch

# Return to yolo
git checkout yolo
```

#### 10. Notify user

```
✅ Synced [module] from yolo to main successfully!

PR: [PR URL]
Status: Merged to main
CI: All checks passing
Next: Contributors can now see and work with [module] on main branch
```

## Integration with Other Skills

### Called By
- **status-tracker**: Triggers Phase 1 (WIP marker) when progress hits 5% milestone

### Calls
- None (standalone skill for sync operations)

### Coordinates With
- **status-tracker**: Both update STATUS_v2.md (different markers)
- **yolo1**: Ensures work continues on yolo while main stays in sync

## Safety Guidelines

### Critical Rules
- ⚠️ **NEVER** directly merge yolo into main (causes automation pollution)
- ⚠️ **NEVER** sync .claude/ or codex/ directories to main
- ⚠️ **NEVER** overwrite main's .github/workflows/ (different CI configs)
- ⚠️ **ALWAYS** cherry-pick specific commits, never full merge
- ⚠️ **ALWAYS** run lint/build/validate before pushing to main

### Verification Checklist

Before pushing sync to main:
- [ ] TypeScript compiles (`npm run build`)
- [ ] Lint passes (`npm run lint`)
- [ ] Validation passes (`scripts/validate.sh`)
- [ ] No .claude/ or codex/ files included
- [ ] STATUS files updated correctly
- [ ] WIP marker removed from STATUS_v2.md
- [ ] Git history is clean (good commit messages)

### Rollback Plan

If sync breaks main:
```bash
git checkout main
git revert HEAD~1  # Revert last commit
git push origin main
```

## Example Usage

### Example 1: Automatic WIP Marker (Phase 1)

**Scenario**: status-tracker updates bridge module to 15%

**Trigger**: Automatic (called by status-tracker)

**Actions**:
1. Checkout main
2. Edit STATUS_v2.md: `- bridge 🔄 15% - In active development (yolo branch)`
3. Commit: `wip: bridge active on yolo (15% complete)`
4. Push to main
5. Return to yolo
6. Notify user: "WIP marker created for bridge at 15%"

### Example 2: User-Initiated Sync (Phase 2)

**User says**: "The bridge module is working great in production. Sync it to main."

**Trigger**: Manual (user approval after production testing)

**Actions**:
1. Identify bridge-related commits from yolo
2. Create sync/bridge-to-main branch
3. Cherry-pick commits
4. Run `npm run lint -- --fix`
5. Run `npm run build`
6. Fix any remaining lint issues
7. Sync STATUS_v2.md and progress-log.md from yolo
8. Remove 🔄 marker from bridge in STATUS_v2.md
9. Commit: `sync: bridge from yolo (production-validated)`
10. Create PR to main
11. Merge after review
12. Notify user with PR URL

### Example 3: Sync with Lint Failures

**User says**: "Sync auth module to main"

**Actions**:
1-3. [Standard prep and cherry-pick]
4. Run `npm run lint -- --fix` → Some errors remain
5. Show user:
   ```
   Auto-fix couldn't resolve:
   - src/auth/provider.ts:45 - unused variable 'config'
   - src/auth/hooks.ts:12 - missing return type

   Options:
   1. I can fix these manually
   2. Create GitHub issues for later
   3. Stop sync

   What would you like to do?
   ```
6. User chooses → Claude proceeds accordingly

## Troubleshooting

### Issue: Cherry-pick conflicts

**Symptom**: `git cherry-pick` shows conflicts

**Solution**:
```bash
git cherry-pick --abort
```
Notify user: "Conflicts detected. Manual resolution needed."

### Issue: Build fails after lint fixes

**Symptom**: `npm run build` fails after auto-fix

**Solution**:
- Review build errors
- Claude attempts to fix TypeScript errors
- If unfixable: notify user and create detailed issue

### Issue: WIP marker already exists

**Symptom**: Module already has 🔄 marker in STATUS_v2.md

**Solution**:
- Update percentage: `- [module] 🔄 XX% - In active development (yolo branch)`
- Don't create duplicate markers

### Issue: Status files diverge between branches

**Symptom**: main's STATUS_v2.md has different progress than yolo

**Solution**:
- During Phase 2 sync, ALWAYS overwrite main's status with yolo's
- yolo is source of truth for production status

## Reference

### Related Documentation
- DUAL_BRANCH_STRATEGY.md - Complete branch strategy
- BRANCH_CLEANUP_ANALYSIS.md - Current branch state
- docs/STATUS_v2.md - Progress dashboard
- STATUS/progress-log.md - Milestone history

### Related Skills
- status-tracker - Manages progress updates, calls sync-to-main Phase 1
- yolo1 - Feature implementation on yolo
- pr-formatter - PR formatting (not used by sync-to-main)

### Key Files Modified
- docs/STATUS_v2.md - Progress tracking with WIP markers
- STATUS/progress-log.md - Historical log
- Application code files - Synced from yolo to main
