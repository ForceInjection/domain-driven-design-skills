---
name: workflow-management
description: Manage GitHub Actions workflows - trigger, monitor, view logs, and download artifacts using gh CLI
---
# GitHub Workflow Management Skill

This skill provides operations for managing GitHub Actions workflows, including viewing runs, triggering workflows, managing artifacts, and monitoring CI/CD pipelines.

## Available Operations

### 1. List Workflow Runs
View workflow run history with filtering options.

### 2. View Workflow Run Details
Get detailed information about a specific workflow run.

### 3. Trigger Workflow
Manually trigger a workflow_dispatch workflow.

### 4. Cancel Workflow Run
Stop a running workflow.

### 5. Rerun Workflow
Rerun a failed or completed workflow.

### 6. View Workflow Logs
Download and view logs from workflow runs.

### 7. Download Artifacts
Download build artifacts from workflow runs.

### 8. List Workflows
View all workflows in a repository.

### 9. View Job Details
Get information about individual workflow jobs.

## Usage Examples

### List Workflow Runs

**List all workflow runs:**
```bash
gh run list --repo owner/repo-name
```

**List runs with limit:**
```bash
gh run list --repo owner/repo-name --limit 50
```

**Filter by workflow:**
```bash
gh run list --repo owner/repo-name --workflow "CI"
```

**Filter by branch:**
```bash
gh run list --repo owner/repo-name --branch main
```

**Filter by status:**
```bash
gh run list --repo owner/repo-name --status completed
gh run list --repo owner/repo-name --status failure
gh run list --repo owner/repo-name --status in_progress
```

**Filter by event:**
```bash
gh run list --repo owner/repo-name --event push
gh run list --repo owner/repo-name --event pull_request
gh run list --repo owner/repo-name --event workflow_dispatch
```

**Filter by actor:**
```bash
gh run list --repo owner/repo-name --user username
```

**JSON output:**
```bash
gh run list --repo owner/repo-name --json databaseId,headBranch,status,conclusion,workflowName,event
```

### View Workflow Run Details

**View run summary:**
```bash
gh run view 123456 --repo owner/repo-name
```

**View with job details:**
```bash
gh run view 123456 --repo owner/repo-name --job
```

**View in browser:**
```bash
gh run view 123456 --repo owner/repo-name --web
```

**View logs:**
```bash
gh run view 123456 --repo owner/repo-name --log
```

**View failed logs only:**
```bash
gh run view 123456 --repo owner/repo-name --log-failed
```

**JSON output:**
```bash
gh run view 123456 --repo owner/repo-name --json status,conclusion,workflowName,headBranch,createdAt,updatedAt
```

**Get run by workflow and branch:**
```bash
# Get latest run for specific workflow on branch
gh run list --repo owner/repo-name --workflow "CI" --branch main --limit 1
```

### Trigger Workflow

**Trigger workflow on default branch:**
```bash
gh workflow run ci.yml --repo owner/repo-name
```

**Trigger on specific branch:**
```bash
gh workflow run ci.yml --repo owner/repo-name --ref feature-branch
```

**Trigger with inputs:**
```bash
gh workflow run deploy.yml --repo owner/repo-name \
  -f environment=production \
  -f version=1.2.3
```

**Trigger and watch:**
```bash
gh workflow run test.yml --repo owner/repo-name && \
  gh run watch $(gh run list --workflow test.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

**Using API for complex inputs:**
```bash
gh api repos/owner/repo-name/actions/workflows/deploy.yml/dispatches \
  -f ref=main \
  -f 'inputs[environment]=staging' \
  -f 'inputs[deploy_type]=full'
```

### Cancel Workflow Run

**Cancel specific run:**
```bash
gh run cancel 123456 --repo owner/repo-name
```

**Cancel all in-progress runs:**
```bash
gh run list --repo owner/repo-name --status in_progress --json databaseId --jq '.[].databaseId' | \
  xargs -I {} gh run cancel {} --repo owner/repo-name
```

**Cancel runs for specific branch:**
```bash
gh run list --repo owner/repo-name --branch feature-branch --status in_progress --json databaseId --jq '.[].databaseId' | \
  xargs -I {} gh run cancel {} --repo owner/repo-name
```

### Rerun Workflow

**Rerun entire workflow:**
```bash
gh run rerun 123456 --repo owner/repo-name
```

**Rerun only failed jobs:**
```bash
gh run rerun 123456 --repo owner/repo-name --failed
```

**Watch rerun:**
```bash
gh run rerun 123456 --repo owner/repo-name && \
  gh run watch 123456 --repo owner/repo-name
```

### View Workflow Logs

**View logs in terminal:**
```bash
gh run view 123456 --repo owner/repo-name --log
```

**View specific job logs:**
```bash
gh run view 123456 --repo owner/repo-name --job 987654 --log
```

**Download logs:**
```bash
gh run download 123456 --repo owner/repo-name --name logs
```

**Stream live logs:**
```bash
gh run watch 123456 --repo owner/repo-name
```

**Download all logs as zip:**
```bash
gh api repos/owner/repo-name/actions/runs/123456/logs > logs.zip
```

### Download Artifacts

**List artifacts for a run:**
```bash
gh run view 123456 --repo owner/repo-name --json artifacts
```

**Download all artifacts:**
```bash
gh run download 123456 --repo owner/repo-name
```

**Download specific artifact:**
```bash
gh run download 123456 --repo owner/repo-name --name artifact-name
```

**Download to specific directory:**
```bash
gh run download 123456 --repo owner/repo-name --dir ./downloads
```

**Using API to download:**
```bash
# List artifacts
gh api repos/owner/repo-name/actions/runs/123456/artifacts --jq '.artifacts[] | {name, id, size_in_bytes}'

# Download specific artifact
ARTIFACT_ID=$(gh api repos/owner/repo-name/actions/runs/123456/artifacts --jq '.artifacts[0].id')
gh api repos/owner/repo-name/actions/artifacts/$ARTIFACT_ID/zip > artifact.zip
```

### List Workflows

**List all workflows:**
```bash
gh workflow list --repo owner/repo-name
```

**View workflow details:**
```bash
gh workflow view ci.yml --repo owner/repo-name
```

**View in browser:**
```bash
gh workflow view ci.yml --repo owner/repo-name --web
```

**Enable/disable workflow:**
```bash
gh workflow enable ci.yml --repo owner/repo-name
gh workflow disable ci.yml --repo owner/repo-name
```

**Get workflow state:**
```bash
gh api repos/owner/repo-name/actions/workflows/ci.yml --jq '{state, path, name}'
```

### View Job Details

**List jobs in a run:**
```bash
gh api repos/owner/repo-name/actions/runs/123456/jobs --jq '.jobs[] | {name, status, conclusion}'
```

**View specific job:**
```bash
gh api repos/owner/repo-name/actions/jobs/987654 --jq '{name, status, conclusion, started_at, completed_at, steps}'
```

**View job logs:**
```bash
gh api repos/owner/repo-name/actions/jobs/987654/logs
```

**Rerun specific job:**
```bash
gh api repos/owner/repo-name/actions/jobs/987654/rerun -X POST
```

## Common Patterns

### Monitor CI/CD Pipeline

```bash
# 1. Trigger workflow
gh workflow run ci.yml --repo owner/repo-name --ref main

# 2. Wait a moment for run to start
sleep 5

# 3. Get the run ID
RUN_ID=$(gh run list --workflow ci.yml --limit 1 --json databaseId --jq '.[0].databaseId')

# 4. Watch the run
gh run watch $RUN_ID --repo owner/repo-name

# 5. Check result
gh run view $RUN_ID --repo owner/repo-name --json conclusion --jq '.conclusion'

# 6. Download artifacts if successful
if [ "$(gh run view $RUN_ID --json conclusion --jq -r '.conclusion')" = "success" ]; then
  gh run download $RUN_ID --repo owner/repo-name
fi
```

### Debug Failed Workflow

```bash
# 1. List recent failures
gh run list --repo owner/repo-name --status failure --limit 5

# 2. View failed run
gh run view 123456 --repo owner/repo-name --log-failed

# 3. Check job details
gh api repos/owner/repo-name/actions/runs/123456/jobs --jq '.jobs[] | select(.conclusion=="failure") | {name, steps: [.steps[] | select(.conclusion=="failure") | {name, conclusion}]}'

# 4. Download logs for analysis
gh api repos/owner/repo-name/actions/runs/123456/logs > debug-logs.zip

# 5. Rerun failed jobs after fix
gh run rerun 123456 --repo owner/repo-name --failed
```

### Deployment Workflow

```bash
# 1. Trigger deployment
gh workflow run deploy.yml --repo owner/repo-name \
  --ref main \
  -f environment=production \
  -f version=$(cat VERSION)

# 2. Monitor deployment
RUN_ID=$(gh run list --workflow deploy.yml --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch $RUN_ID --repo owner/repo-name

# 3. Verify success
if [ "$(gh run view $RUN_ID --json conclusion --jq -r '.conclusion')" = "success" ]; then
  echo "Deployment successful!"
  gh run view $RUN_ID --repo owner/repo-name
else
  echo "Deployment failed!"
  gh run view $RUN_ID --repo owner/repo-name --log-failed
  exit 1
fi
```

### Cleanup Old Workflow Runs

```bash
# List old completed runs
gh run list --repo owner/repo-name --status completed --limit 100 --json databaseId,createdAt

# Delete runs older than 30 days (using API)
CUTOFF_DATE=$(date -d '30 days ago' -Iseconds)
gh api repos/owner/repo-name/actions/runs --paginate --jq ".workflow_runs[] | select(.created_at < \"$CUTOFF_DATE\") | .id" | \
  xargs -I {} gh api repos/owner/repo-name/actions/runs/{} -X DELETE
```

### Bulk Rerun Failed Workflows

```bash
# Get all failed runs from last week
gh run list --repo owner/repo-name --status failure --created ">=$(date -d '7 days ago' +%Y-%m-%d)" --json databaseId --jq '.[].databaseId' | \
  while read run_id; do
    echo "Rerunning $run_id"
    gh run rerun $run_id --repo owner/repo-name
    sleep 2  # Rate limiting
  done
```

### Check Workflow Coverage

```bash
# List all workflows and their recent status
gh workflow list --repo owner/repo-name --json name,path,state | \
  jq -r '.[] | "\(.name) (\(.path)): \(.state)"'

# Check each workflow's latest run
gh workflow list --repo owner/repo-name --json name,path | \
  jq -r '.[].path' | \
  while read workflow; do
    echo "Workflow: $workflow"
    gh run list --workflow "$workflow" --limit 1 --repo owner/repo-name
    echo ""
  done
```

## Advanced Usage

### Matrix Job Analysis

**View all matrix jobs:**
```bash
gh api repos/owner/repo-name/actions/runs/123456/jobs --jq '.jobs[] | {name, status, conclusion, matrix: .steps[0].name}'
```

**Find failed matrix combinations:**
```bash
gh api repos/owner/repo-name/actions/runs/123456/jobs --jq '.jobs[] | select(.conclusion=="failure") | {name, conclusion}'
```

### Workflow Timing Analysis

**Get workflow duration:**
```bash
gh run view 123456 --repo owner/repo-name --json createdAt,updatedAt --jq '{created: .createdAt, updated: .updatedAt}'
```

**Analyze job timing:**
```bash
gh api repos/owner/repo-name/actions/runs/123456/jobs --jq '.jobs[] | {name, duration: (.completed_at - .started_at)}'
```

### Concurrent Workflow Management

**List concurrent runs:**
```bash
gh run list --repo owner/repo-name --status in_progress
```

**Cancel concurrent runs for same branch:**
```bash
BRANCH="feature-branch"
gh run list --repo owner/repo-name --branch $BRANCH --status in_progress --json databaseId --jq '.[1:] | .[].databaseId' | \
  xargs -I {} gh run cancel {} --repo owner/repo-name
```

### Self-Hosted Runner Management

**View runner groups:**
```bash
gh api repos/owner/repo-name/actions/runners --jq '.runners[] | {name, status, busy}'
```

**Check runner usage:**
```bash
gh api repos/owner/repo-name/actions/runs/123456/jobs --jq '.jobs[] | {name, runner_name: .runner_name, runner_group_name: .runner_group_name}'
```

## Error Handling

### Workflow Not Found
```bash
# List available workflows
gh workflow list --repo owner/repo-name

# Verify workflow file exists
gh api repos/owner/repo-name/contents/.github/workflows --jq '.[].name'
```

### Run Not Found
```bash
# Verify run exists
gh run view 123456 --repo owner/repo-name 2>&1 | grep -q "could not find" && echo "Run not found"
```

### Workflow Dispatch Not Available
```bash
# Check if workflow has workflow_dispatch trigger
gh api repos/owner/repo-name/actions/workflows/ci.yml --jq '.workflow_dispatch'
```

### Rate Limiting
```bash
# Check rate limit
gh api rate_limit --jq '.resources.actions'

# Use pagination for large results
gh api repos/owner/repo-name/actions/runs --paginate
```

## Best Practices

1. **Monitor actively**: Use `gh run watch` for important workflows
2. **Clean up old runs**: Regularly delete old workflow runs to save storage
3. **Use meaningful names**: Name workflows clearly for easy identification
4. **Handle failures gracefully**: Set up notifications for failed workflows
5. **Download artifacts promptly**: Artifacts have retention limits
6. **Use workflow_dispatch**: Enable manual triggers for debugging
7. **Check logs first**: Review logs before rerunning failed workflows
8. **Respect rate limits**: Add delays when bulk processing runs
9. **Use JSON output**: For programmatic processing and scripting
10. **Tag deployments**: Use releases or tags to track deployment workflows

## Workflow Status Values

**Status:**
- `queued` - Waiting to start
- `in_progress` - Currently running
- `completed` - Finished (check conclusion for result)

**Conclusion:**
- `success` - Completed successfully
- `failure` - Failed
- `cancelled` - Manually cancelled
- `skipped` - Skipped
- `timed_out` - Exceeded time limit
- `action_required` - Needs manual approval
- `neutral` - Completed but not success/failure

## Integration with Other Skills

- Use `pull-request-management` to view PR check status
- Use `commit-operations` to find commits that triggered workflows
- Use `issue-management` to link workflow failures to issues
- Use `repository-management` to manage workflow files

## References

- [GitHub CLI Run Documentation](https://cli.github.com/manual/gh_run)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions API](https://docs.github.com/en/rest/actions)
