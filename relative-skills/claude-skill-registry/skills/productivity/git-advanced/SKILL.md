---
name: git-advanced
description: Advanced git operations including safe rebases, tag management, cherry-picking, and release workflows. Activates for complex git tasks, merge conflicts, or VoiceLite release management.
---

# Git Advanced

Advanced git workflows for VoiceLite development and release management.

## When This Skill Activates

- Commands: "rebase", "cherry-pick", "force push", "delete tag", "move tag"
- Situations: "merge conflict", "detached HEAD", "undo commit", "squash commits"
- Release work: Tag management, hotfix branches, version control
- Mistakes: "Wrong commit", "committed to wrong branch", "need to undo"

## Safe Rebase Workflow

**NEVER rebase public branches (master, main)** - Only rebase feature branches before merging.

### Interactive Rebase for Clean History

```bash
# Scenario: Clean up last 3 commits before PR

# 1. ALWAYS create backup first
git branch backup-my-feature

# 2. Interactive rebase
git rebase -i HEAD~3

# Editor opens with:
# pick abc1234 Add feature X
# pick def5678 Fix typo
# pick ghi9012 Update docs

# Options:
# pick   = keep commit as-is
# reword = keep commit, change message
# edit   = keep commit, allow changes
# squash = combine with previous commit
# drop   = delete commit

# Example: Squash typo fix
# pick abc1234 Add feature X
# squash def5678 Fix typo
# pick ghi9012 Update docs

# 3. Save and close editor

# 4. If conflicts occur:
git status  # See conflicting files
# Fix conflicts manually
git add .
git rebase --continue

# 5. If things go wrong:
git rebase --abort  # Start over
git reset --hard backup-my-feature  # Restore backup
```

## Tag Management (Critical for VoiceLite Releases)

### Delete Tag (Local + Remote)

```bash
# Scenario: Tagged wrong commit for v1.0.97

# 1. Delete local tag
git tag -d v1.0.97

# 2. Delete remote tag on GitHub
git push origin :refs/tags/v1.0.97

# 3. Delete GitHub Release (stops Actions workflow)
gh release delete v1.0.97 --yes

# 4. Verify tag deleted
git tag | grep v1.0.97  # Should be empty
git ls-remote --tags origin | grep v1.0.97  # Should be empty
```

### Move Tag to Different Commit

```bash
# Scenario: Need to move v1.0.98 tag to include last-minute fix

# 1. Find correct commit hash
git log --oneline --graph --all | head -10
# Example: abc1234 is the correct commit

# 2. Delete old tag (local + remote)
git tag -d v1.0.98
git push origin :refs/tags/v1.0.98

# 3. Create new tag on correct commit
git tag v1.0.98 abc1234

# 4. Push new tag
git push origin v1.0.98

# 5. Verify
git show v1.0.98  # Shows correct commit
```

### Annotated Tags (Preferred for Releases)

```bash
# Create annotated tag (stores tagger, date, message)
git tag -a v1.0.99 -m "Release v1.0.99: Performance improvements"

# Push annotated tag
git push origin v1.0.99

# View tag details
git show v1.0.99
```

## Cherry-Pick Workflow

**Use case**: Apply specific fix from one branch to another

### Scenario: Backport Fix to Older Version

```bash
# Situation: Fixed critical bug in v1.0.97, need fix in v1.0.95 patch branch

# 1. Find commit hash of fix
git log --oneline --grep="fix transcription bug"
# Output: abc1234 fix: transcription timeout issue

# 2. Switch to target branch
git checkout v1.0.95-patch

# 3. Cherry-pick the fix
git cherry-pick abc1234

# 4. If conflicts occur:
git status  # See conflicting files
# Fix conflicts manually
git add .
git cherry-pick --continue

# 5. If you want to abort:
git cherry-pick --abort

# 6. Push to remote
git push origin v1.0.95-patch
```

### Cherry-Pick Multiple Commits

```bash
# Apply commits abc1234, def5678, ghi9012
git cherry-pick abc1234 def5678 ghi9012

# Or range of commits (exclusive of first)
git cherry-pick abc1234..ghi9012
```

## Undo Commit Strategies

### Just Committed - Want to Undo

```bash
# Scenario: Just ran "git commit", want to undo

# Option 1: Keep changes, undo commit
git reset --soft HEAD~1
# Files stay staged, commit undone

# Option 2: Unstage changes, undo commit
git reset HEAD~1
# Files unstaged, commit undone, changes preserved

# Option 3: DELETE changes (DANGEROUS!)
git reset --hard HEAD~1
# Everything gone, commit undone
```

### Already Pushed - Want to Undo

```bash
# Scenario: Pushed bad commit to feature branch

# Option 1: Revert (creates new commit undoing changes)
git revert abc1234
git push origin my-feature
# Safe, preserves history

# Option 2: Force push (DANGEROUS - only on feature branches!)
git reset --hard HEAD~1
git push --force origin my-feature
# Rewrites history, use with caution
```

### Committed to Wrong Branch

```bash
# Scenario: Committed to master instead of feature branch

# 1. Create branch with current commit
git branch feature-fix

# 2. Reset master to before your commit
git reset --hard origin/master

# 3. Switch to new branch
git checkout feature-fix

# 4. Your commit is now on correct branch!
```

## Merge Conflict Resolution

### Standard Conflict Resolution

```bash
# After git merge or git pull with conflicts

# 1. Check which files have conflicts
git status
# Files under "both modified" have conflicts

# 2. Open conflicting file, look for:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> branch-name

# 3. Resolve conflict (keep one, both, or hybrid)

# 4. Mark as resolved
git add resolved-file.cs

# 5. Complete merge
git commit  # Or git merge --continue
```

### Abort Merge

```bash
# If conflicts too complex, start over
git merge --abort
```

### Use Specific Version

```bash
# Keep "ours" (current branch)
git checkout --ours path/to/file.cs
git add path/to/file.cs

# Keep "theirs" (merging branch)
git checkout --theirs path/to/file.cs
git add path/to/file.cs
```

## Stash Management

### Save Work in Progress

```bash
# Save uncommitted changes
git stash push -m "WIP: audio recording feature"

# Include untracked files
git stash push -u -m "WIP: with new files"

# List stashes
git stash list
# stash@{0}: WIP: audio recording feature
# stash@{1}: WIP: bug fix

# Apply stash (keeps in stash list)
git stash apply stash@{0}

# Pop stash (removes from stash list)
git stash pop

# Delete specific stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

## Branch Management

### Clean Up Old Branches

```bash
# List merged branches
git branch --merged master

# Delete merged local branch
git branch -d feature-old

# Delete unmerged branch (force)
git branch -D feature-abandoned

# Delete remote branch
git push origin --delete feature-old

# Prune deleted remote branches
git fetch --prune
```

### Rename Branch

```bash
# Rename current branch
git branch -m new-branch-name

# Rename specific branch
git branch -m old-name new-name

# Push renamed branch and delete old
git push origin new-name
git push origin --delete old-name
```

## Hotfix Workflow for VoiceLite

```bash
# Scenario: Critical bug in production v1.0.96, need hotfix

# 1. Create hotfix branch from tag
git checkout -b hotfix-1.0.97 v1.0.96

# 2. Fix the bug
# ... make changes ...
git add .
git commit -m "fix: critical transcription timeout"

# 3. Update version numbers
# VoiceLite.csproj, VoiceLiteSetup.iss, etc.

# 4. Commit version changes
git commit -am "release: v1.0.97"

# 5. Create tag
git tag v1.0.97

# 6. Push to remote (triggers GitHub Actions)
git push origin hotfix-1.0.97 --tags

# 7. Merge hotfix back to master
git checkout master
git merge hotfix-1.0.97
git push origin master

# 8. Delete hotfix branch
git branch -d hotfix-1.0.97
git push origin --delete hotfix-1.0.97
```

## Danger Zone (Use with Extreme Caution)

### Force Push Rules

**NEVER force push to**:
- ❌ master / main
- ❌ Shared branches
- ❌ Protected branches

**Safe to force push to**:
- ✅ Your own feature branches
- ✅ After explicit team agreement

```bash
# Safe force push
git push --force-with-lease origin my-feature
# Fails if remote has changes you don't have (safer than --force)

# Dangerous force push
git push --force origin my-feature
# Overwrites remote unconditionally (can lose others' work!)
```

### Rewrite History (DANGEROUS)

```bash
# Filter-branch to remove file from all history
git filter-branch --tree-filter 'rm -f secrets.txt' HEAD
# Then force push: git push --force origin master
# WARNING: Rewrites entire git history!
```

## Git Troubleshooting

### Detached HEAD State

```bash
# Symptom: "You are in 'detached HEAD' state"

# Create branch from current position
git checkout -b rescue-branch

# Or discard changes and return to branch
git checkout master
```

### "Your branch has diverged"

```bash
# Symptom: Local and remote have different histories

# Option 1: Rebase your changes on top of remote
git pull --rebase origin master

# Option 2: Merge remote changes
git pull origin master

# Option 3: Force push (if you're SURE local is correct)
git push --force-with-lease origin master
```

### Accidentally Committed Large File

```bash
# Remove from last commit
git rm --cached large-file.bin
git commit --amend --no-edit
git push --force-with-lease

# If already pushed multiple commits ago
# Use BFG Repo-Cleaner or git filter-branch
```

## Useful Git Aliases

```bash
# Add to ~/.gitconfig

[alias]
  # Shortcuts
  co = checkout
  br = branch
  ci = commit
  st = status

  # Logging
  lg = log --oneline --graph --all --decorate
  last = log -1 HEAD

  # Undo
  undo = reset --soft HEAD~1
  unstage = reset HEAD --

  # Cleanup
  cleanup = !git branch --merged | grep -v '*' | xargs -n 1 git branch -d
```

## VoiceLite Release Tag Convention

```
Format: v{MAJOR}.{MINOR}.{PATCH}

Examples:
v1.0.96 - Critical hotfix (model file missing)
v1.0.95 - Broken release
v1.0.88 - Q8_0 quantization performance update

Trigger: git tag v1.0.XX && git push --tags
Result: GitHub Actions builds installer, creates release
```
