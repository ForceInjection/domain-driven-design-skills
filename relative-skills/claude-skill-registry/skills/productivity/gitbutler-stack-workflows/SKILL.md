---
name: GitButler Stack Workflows
version: 2.0.0
description: Create, navigate, and reorganize stacks in GitButler using virtual branches, anchor-based stacking, and post-hoc organization. Use for dependent branches, PR preparation, and reviewable feature breakdown.
---

# GitButler Stack Workflows

Dependent branches → anchor-based stacking → reviewable chunks.

<when_to_use>

- Sequential dependencies (e.g., refactor → API → frontend)
- Large features broken into reviewable chunks
- Granular code review (approve/merge early phases independently)
- Post-hoc stack organization after exploratory coding

NOT for: independent parallel features (use virtual branches), projects using Graphite stacking

</when_to_use>

<stack_vs_virtual>

## Stacked vs Virtual Branches

| Type | Use Case | Dependencies |
|------|----------|--------------|
| **Virtual** | Independent, unrelated work | None — parallel |
| **Stacked** | Sequential dependencies | Each builds on parent |

Stacked branches = virtual branches split into dependent sequence.
Default: Virtual branches are stacks of one.

</stack_vs_virtual>

<create>

## Creating Stacks

```bash
# Base branch (no anchor)
but branch new base-feature

# Stacked branch (--anchor specifies parent)
but branch new child-feature --anchor base-feature

# Third level
but branch new grandchild-feature --anchor child-feature
```

**Result:** `base-feature` ← `child-feature` ← `grandchild-feature`

**Short form:** `-a` instead of `--anchor`

```bash
but branch new child -a parent
```

</create>

<patterns>

## Stack Patterns

### Feature Dependency Stack

```bash
# Auth foundation
but branch new auth-core
but commit auth-core -m "feat: add authentication core"

# OAuth layer depends on auth core
but branch new auth-oauth --anchor auth-core
but commit auth-oauth -m "feat: add OAuth integration"

# Social login depends on OAuth
but branch new auth-social --anchor auth-oauth
but commit auth-social -m "feat: add social login"
```

### Refactoring Stack

```bash
# Extract utilities
but branch new refactor-extract-utils
but commit refactor-extract-utils -m "refactor: extract common utilities"

# Update consumers
but branch new refactor-use-utils --anchor refactor-extract-utils
but commit refactor-use-utils -m "refactor: use extracted utilities"

# Clean up
but branch new refactor-cleanup --anchor refactor-use-utils
but commit refactor-cleanup -m "refactor: remove deprecated code"
```

### Deep Stack (5 levels)

```bash
but branch new db-schema
but branch new data-access --anchor db-schema
but branch new business-logic --anchor data-access
but branch new api-endpoints --anchor business-logic
but branch new frontend-integration --anchor api-endpoints
```

</patterns>

<post_hoc>

## Post-Hoc Stack Organization

**Problem:** Created branches independently, now want to stack them.

**Solution:** Recreate with correct anchors:

```bash
# Current: three independent branches
# feature-a, feature-b, feature-c

# Stack feature-b on feature-a
but branch new feature-b-stacked --anchor feature-a
commit_sha=$(but log | grep "feature-b:" | head -1 | awk '{print $1}')
but rub $commit_sha feature-b-stacked
but branch delete feature-b --force

# Stack feature-c on feature-b-stacked
but branch new feature-c-stacked --anchor feature-b-stacked
commit_sha=$(but log | grep "feature-c:" | head -1 | awk '{print $1}')
but rub $commit_sha feature-c-stacked
but branch delete feature-c --force
```

</post_hoc>

<pr_workflow>

## PR Preparation for Stacks

**GitButler CLI lacks native PR submission.** Use GitHub CLI:

```bash
# Push branches
git push -u origin base-feature
git push -u origin dependent-feature

# Create PRs with correct base branches
gh pr create --base main --head base-feature \
  --title "feat: base feature" \
  --body "First in stack"

gh pr create --base base-feature --head dependent-feature \
  --title "feat: dependent feature" \
  --body "Depends on base-feature PR"
```

**GitHub Settings:**
- Enable automatic branch deletion after merge
- Use **Merge** strategy (recommended) — no force pushes needed
- Merge bottom-to-top (sequential order)

</pr_workflow>

<reorganize>

## Stack Reorganization

### Squashing Within Stack

```bash
newer_commit=$(but log | grep "newer" | awk '{print $1}')
older_commit=$(but log | grep "older" | awk '{print $1}')
but rub $newer_commit $older_commit
```

### Moving Commits Between Stack Levels

```bash
commit_sha=$(but log | grep "specific commit" | awk '{print $1}')
but rub $commit_sha correct-branch
```

### Splitting a Branch

```bash
# Original has multiple features
but branch new second-feature --anchor original-branch
commit_sha=$(but log | grep "second feature commit" | awk '{print $1}')
but rub $commit_sha second-feature
```

</reorganize>

<navigation>

## Stack Navigation

**Note:** Virtual branches don't need checkout — all branches active simultaneously.

```bash
# View full stack structure
but log

# Work on any branch directly (no checkout needed)
but commit base-feature -m "update base"
but commit dependent-feature -m "update dependent"

# JSON for programmatic analysis
but --json log | jq '.[] | .branchDetails[] | {name, baseCommit}'
```

</navigation>

<rules>

ALWAYS:
- Create stacks with `--anchor` from the start
- Merge stacks bottom-to-top (base first, dependents after)
- Snapshot before reorganizing: `but snapshot --message "Before stack reorganization"`
- Keep each level small (100-250 LOC) for reviewability
- Delete empty branches after reorganization

NEVER:
- Skip stack levels when merging
- Stack independent, unrelated features (use virtual branches)
- Create deep stacks (5+ levels) without good reason
- Forget anchor when creating dependent branches

</rules>

<troubleshooting>

## Common Issues

| Symptom | Cause | Solution |
|---------|-------|----------|
| Stack not showing in `but log` | Missing `--anchor` | Recreate with correct anchor |
| Commits in wrong stack level | Wrong branch targeted | `but rub <sha> correct-branch` |
| Can't merge middle of stack | Wrong order | Merge bottom-to-top only |

## Recovery

```bash
# Recreate branch with correct anchor
but branch new child-stacked --anchor parent
commit_sha=$(but log | grep "child:" | head -1 | awk '{print $1}')
but rub $commit_sha child-stacked
but branch delete child --force
```

</troubleshooting>

<best_practices>

## Best Practices

### Planning

- Start simple: 2-3 levels max initially
- Single responsibility per level
- Only stack when there's a real dependency

### Maintenance

- Run `but log` regularly to verify structure
- Commit to correct branches immediately
- Clean up empty branches

### Communication

- Clear commit messages explaining why stack level exists
- Descriptive names indicating stack relationship
- Share `but status` when coordinating

</best_practices>

<references>

- [version-control skill](../version-control/SKILL.md) — core GitButler workflows
- [complete-branch skill](../complete-branch/SKILL.md) — merging to main
- [multi-agent skill](../multi-agent/SKILL.md) — multi-agent coordination
- [GitButler Stacks Docs](https://docs.gitbutler.com/features/branch-management/stacked-branches)

</references>
