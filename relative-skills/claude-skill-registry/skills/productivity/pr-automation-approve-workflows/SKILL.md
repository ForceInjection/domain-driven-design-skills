---
name: PR Automation - Approve Workflows
description: Approve pending GitHub Actions workflows and add /ok-to-test comments to PRs that need testing
---

# PR Automation - Approve Workflows

This skill automates the approval of pending GitHub Actions workflows and adds `/ok-to-test` comments to pull requests that require external contributor verification.

## When to Use This Skill

Use this skill when you need to:
- Approve multiple pending GitHub Actions workflows from external contributors
- Add `/ok-to-test` comments to PRs labeled with "needs-ok-to-test"
- Automate the PR review workflow for repositories with many external contributions

## Prerequisites

1. **GitHub CLI (`gh`) installed**
   - Check if installed: `which gh`
   - If not installed, user needs to install it: https://cli.github.com/

2. **GitHub authentication**
   - Must be authenticated with `gh auth login`
   - Must have write access to the repository

3. **Repository context**
   - Repository name in `owner/repo` format
   - Or current directory must be a git repository

## Implementation Steps

### Step 1: Determine Repository

If a repository argument is provided, use it. Otherwise, detect from the current directory:

```bash
# If no repo provided, detect from git remote
if [ -z "$repo" ]; then
  repo=$(git remote get-url origin | sed -E 's/.*github\.com[:/]([^/]+\/[^.]+)(\.git)?/\1/')
fi
```

### Step 2: Find PRs Needing /ok-to-test

Query all open PRs with the "needs-ok-to-test" label:

```bash
gh pr list --repo "$repo" --limit 100 --json number,title,labels --state open \
  --jq '.[] | select(.labels[]? | .name == "needs-ok-to-test") | {number: .number, title: .title}'
```

For each PR found:
1. Extract the PR number
2. Add a comment with `/ok-to-test`:
   ```bash
   gh pr comment $pr_number --repo "$repo" --body "/ok-to-test"
   ```
3. Track success/failure for final summary

### Step 3: Find Workflow Runs Needing Approval

Query GitHub Actions API for workflow runs that need approval. There are two scenarios:

**Scenario A: Completed runs with action_required (already timed out)**
These cannot be approved but should be reported:
```bash
gh api "repos/$repo/actions/runs?per_page=100" \
  --jq '.workflow_runs[] | select(.conclusion == "action_required") | {id: .id, name: .name, branch: .head_branch, created: .created_at}'
```

**Scenario B: Waiting runs (can be approved)**
These are the ones we can actually approve:
```bash
gh api "repos/$repo/actions/runs" \
  --jq '.workflow_runs[] | select(.status == "waiting") | {id: .id, name: .name, branch: .head_branch}'
```

### Step 4: Approve Workflow Runs

For each workflow run that needs approval (status == "waiting"):

```bash
gh api "repos/$repo/actions/runs/$run_id/approve" -X POST
```

Track which runs were successfully approved vs which failed.

### Step 5: Generate Summary Report

Create a summary report with:

1. **PRs that received /ok-to-test comments**:
   - PR number and title
   - Comment URL

2. **Workflow runs approved**:
   - Run ID
   - Workflow name
   - Branch name
   - Status (approved/failed)

3. **Action required runs (informational)**:
   - Runs that timed out and cannot be approved
   - Suggest that new commits will trigger new runs

## Error Handling

Handle the following error cases:

1. **No repository found**: If not provided and can't detect from git, prompt user for repository name

2. **GitHub API errors**:
   - 404: Resource not found (run may have been deleted)
   - 403: Permission denied (user lacks approval permissions)
   - Report errors but continue processing other items

3. **No PRs or workflows found**: Report that everything is up to date

4. **Rate limiting**: If GitHub API rate limit is hit, report and suggest trying again later

## Output Format

Provide a structured summary:

```
# PR Workflow Approval Summary

## PRs Marked as /ok-to-test (3)
- PR #116: CLID-473: subagent to generate weekly reports
- PR #105: Add claude interactive google service account creation
- PR #76: an olmv1 claude plugin for managing clusterextensions

## GitHub Actions Workflows Approved (2)
- Run 18977369749: Lint Plugins (branch: add_qa_assignee_query) ✓
- Run 18979766265: Lint Plugins (branch: gh2jira) ✓

## Timed Out Workflows (informational) (5)
These workflows timed out waiting for approval. New commits will trigger new runs.
- Run 18968492733: Lint Plugins (branch: raise_pr_debug_cluster)
- Run 18967558922: Lint Plugins (branch: ovn_analyzer)
...

## Status
✓ All pending approvals completed successfully
```

## Examples

### Example 1: Approve workflows for specific repository

```bash
# User invokes: /pr-automation:approve-workflows openshift-eng/ai-helpers

# Step 1: Set repo variable
repo="openshift-eng/ai-helpers"

# Step 2: Find PRs needing ok-to-test
prs=$(gh pr list --repo "$repo" --limit 100 --json number,title,labels --state open \
  --jq '.[] | select(.labels[]? | .name == "needs-ok-to-test")')

# Step 3: Comment on each PR
echo "$prs" | jq -r '.number' | while read pr; do
  gh pr comment $pr --repo "$repo" --body "/ok-to-test"
done

# Step 4: Find and approve waiting workflows
gh api "repos/$repo/actions/runs" \
  --jq '.workflow_runs[] | select(.status == "waiting") | .id' | \
  while read run_id; do
    gh api "repos/$repo/actions/runs/$run_id/approve" -X POST
  done
```

### Example 2: Approve workflows for current repository

```bash
# User invokes: /pr-automation:approve-workflows

# Detect repo from git remote
repo=$(git remote get-url origin | sed -E 's/.*github\.com[:/]([^/]+\/[^.]+)(\.git)?/\1/')

# Continue with same steps as Example 1...
```

## Notes

- The `/ok-to-test` command is specific to Prow CI and triggers Prow jobs, not GitHub Actions
- GitHub Actions workflows from external contributors require manual approval via the approve API
- Once a PR has the "ok-to-test" label, future commits may not require re-approval
- Workflow runs that have already timed out (action_required conclusion) cannot be approved retroactively
- Some repositories may use different label names - this skill assumes "needs-ok-to-test"
