---
name: pr-creation
description: Use when creating pull requests to auto-generate PR descriptions from plan, execution context, and memory - handles pre-flight checks, description generation, and GitHub CLI integration
---

# PR Creation

Use this skill to create pull requests with auto-generated descriptions from plan, execution context, and memory.

## Pre-flight Checks

Run these checks BEFORE generating PR description:

### 1. Branch Check

```bash
# Get current branch
branch=$(git branch --show-current)

# Check if on main/master
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  ERROR: Cannot create PR from main/master branch
  Must be on feature branch
  exit 1
fi
```

**Error message:**

```markdown
❌ Cannot create PR from main/master branch.

You're currently on: ${branch}

Create a feature branch first:
  git checkout -b feature/${feature-name}

Or if work is already done:
  git checkout -b feature/${feature-name}
  (commits stay with you)
```

### 2. Uncommitted Changes Check

```bash
# Check for uncommitted changes
git status --short

# If output exists
if [[ -n $(git status --short) ]]; then
  WARN: Uncommitted changes found
  Offer to commit before PR
fi
```

**Warning message:**

```markdown
⚠️ You have uncommitted changes:

${git status --short output}

Options:
A) Commit changes now
B) Stash and create PR anyway
C) Cancel PR creation

Choose: (A/B/C)
```

If **A**: Run commit process, then continue
If **B**: Stash changes, continue (warn they're not in PR)
If **C**: Exit PR creation

### 3. Remote Tracking Check

```bash
# Check if branch has remote
git rev-parse --abbrev-ref --symbolic-full-name @{u}

# If fails (no remote tracking)
if [[ $? -ne 0 ]]; then
  INFO: No remote tracking branch
  Will push with -u flag
fi
```

### 4. GitHub CLI Check

```bash
# Check gh installed
which gh

# Check gh authenticated
gh auth status
```

**Error if missing:**

```markdown
❌ GitHub CLI (gh) not found or not authenticated.

Install:
  macOS: brew install gh
  Linux: sudo apt install gh

Authenticate:
  gh auth login
```

## PR Description Generation

Auto-generate from multiple sources:

### Source Priority

1. **Plan file:** `docs/plans/YYYY-MM-DD-<feature>.md`
2. **Complete memory:** `YYYY-MM-DD-<feature>-complete.md` (if exists)
3. **Git diff:** For files changed summary
4. **Commit messages:** For timeline context

### Template Structure

```markdown
## Summary

${extract-from-plan-overview}

## Implementation Details

${synthesize-from-plan-phases-and-execution}

### What Changed

${git-diff-stat-summary}

### Key Files

- \`${file-1}\`: ${purpose-from-plan}
- \`${file-2}\`: ${purpose-from-plan}

### Approach

${extract-from-plan-architecture-or-approach}

## Testing

${extract-from-plan-testing-strategy}

### Verification

${if-complete-memory-exists:}
- ✅ All unit tests passing
- ✅ Integration tests passing
- ✅ Manual verification completed

${else:}
- [ ] Unit tests: \`${test-command}\`
- [ ] Integration tests: \`${test-command}\`
- [ ] Manual verification: ${steps}

## Key Learnings

${if-complete-memory-exists:}
${extract-learnings-section}

${if-patterns-discovered:}
### Patterns Discovered
- ${pattern-1}

${if-gotchas:}
### Gotchas Encountered
- ${gotcha-1}

## References

- Implementation plan: \`docs/plans/${plan-file}\`
${if-tasks-exist:}
- Tasks completed: \`docs/plans/tasks/${feature}/\`
${if-research-exists:}
- Research: \`${research-memory-file}\`

---

🔥 Generated with [CrispyClaude](https://github.com/seanGSISG/crispy-claude)
```

### Extraction Logic

**Summary (from plan):**
```typescript
// Read plan file
const plan = readFile(`docs/plans/${planFile}`)

// Extract content under ## Overview or ## Goal
const summary = extractSection(plan, ['Overview', 'Goal'])

// Take first 2-3 sentences
return summary.split('.').slice(0, 3).join('.') + '.'
```

**What Changed (from git):**
```bash
# Get diff stat
git diff --stat main...HEAD

# Get major files (top 5 by lines changed)
git diff --numstat main...HEAD | sort -k1 -rn | head -5
```

**Approach (from plan):**
```typescript
// Extract from plan sections
const approach = extractSection(plan, [
  'Architecture',
  'Approach',
  'Implementation Approach',
  'Technical Approach'
])
```

**Testing (from plan):**
```typescript
// Extract testing sections
const testing = extractSection(plan, [
  'Testing Strategy',
  'Testing',
  'Verification',
  'Test Plan'
])

// Include make commands found in plan
const testCommands = extractCommands(plan, ['make test', 'pytest', 'npm test'])
```

**Key Learnings (from complete.md):**
```typescript
// If complete memory exists
const complete = readMemory(`${feature}-complete.md`)

// Extract learnings section
const learnings = extractSection(complete, [
  'Key Learnings',
  'Patterns Discovered',
  'Gotchas Encountered',
  'Trade-offs Made'
])
```

## Push and Create PR

### Push Branch

```bash
# Check if remote tracking exists
remote_tracking=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

if [[ -z "$remote_tracking" ]]; then
  # No remote tracking, push with -u
  git push -u origin $(git branch --show-current)
else
  # Remote tracking exists, regular push
  git push
fi
```

### Create PR with gh

```bash
# Create PR with generated description
gh pr create \
  --title "${PR_TITLE}" \
  --body "$(cat <<'EOF'
${GENERATED_DESCRIPTION}
EOF
)"
```

**PR Title Generation:**

```typescript
// Extract feature name from plan filename
// docs/plans/2025-11-20-user-authentication.md → "User Authentication"

const featureName = planFile
  .replace(/^\d{4}-\d{2}-\d{2}-/, '')  // Remove date
  .replace(/\.md$/, '')                 // Remove extension
  .replace(/-/g, ' ')                   // Hyphens to spaces
  .replace(/\b\w/g, c => c.toUpperCase()) // Title case

// PR title: "feat: ${featureName}"
const prTitle = `feat: ${featureName}`
```

### Success Output

```markdown
✅ Pull request created successfully!

**PR:** ${pr-url}
**Branch:** ${branch-name}
**Base:** main

**Description preview:**
${first-3-lines-of-description}

View PR: ${pr-url}
```

### Update Complete Memory

If complete.md exists, add PR link:

```typescript
// Read complete memory
const complete = readMemory(`${feature}-complete.md`)

// Add PR link section if not present
if (!complete.includes('## PR Created')) {
  const updated = complete + `\n\n## PR Created\n\nLink: ${prUrl}\nCreated: ${date}\n`

  // Write back to memory
  writeMemory(`${feature}-complete.md`, updated)
}
```

## Error Handling

**Push fails:**
```markdown
❌ Failed to push branch to remote.

Error: ${error-message}

Common fixes:
- Check remote is configured: \`git remote -v\`
- Check authentication: \`git remote set-url origin git@github.com:user/repo.git\`
- Force push if rebased: \`git push --force-with-lease\`
```

**gh pr create fails:**
```markdown
❌ Failed to create pull request.

Error: ${error-message}

Common fixes:
- Re-authenticate: \`gh auth login\`
- Check permissions: Need write access to repository
- Check branch already has PR: \`gh pr list --head ${branch}\`

Manual PR creation:
1. Go to: https://github.com/${owner}/${repo}/compare/${branch}
2. Click "Create pull request"
3. Use this description:

${generated-description}
```

**Missing sources:**
```markdown
⚠️ Could not find implementation plan.

Searched:
- docs/plans/${date}-*.md
- Memory files

Creating PR with basic description from git history.
You may want to edit the PR description manually.
```

## Example Session

```bash
User: /cc:pr

# Pre-flight checks
✓ On feature branch: feature/user-authentication
✓ No uncommitted changes
✓ GitHub CLI authenticated

# Generating PR description...

Found sources:
- Plan: docs/plans/2025-11-20-user-authentication.md
- Memory: 2025-11-20-user-authentication-complete.md
- Git diff: 8 files changed, 450 insertions, 120 deletions

# Creating pull request...

Pushing branch to origin...
✓ Pushed feature/user-authentication

Creating PR...
✓ PR created: https://github.com/user/repo/pull/42

─────────────────────────────────

✅ Pull request created successfully!

**PR:** https://github.com/user/repo/pull/42
**Branch:** feature/user-authentication
**Base:** main

**Title:** feat: User Authentication

**Description preview:**
## Summary
Implement JWT-based user authentication with login/logout functionality...

View full PR: https://github.com/user/repo/pull/42
```
