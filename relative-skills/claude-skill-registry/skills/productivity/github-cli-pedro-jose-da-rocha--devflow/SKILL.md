---
name: github-cli
description: Execute GitHub CLI (gh) commands to manage repositories, pull requests, issues, workflows, and more. Use when working with GitHub operations like creating PRs, listing issues, managing branches, checking workflow runs, or any gh command automation.
---

# GitHub CLI Automation

Use the GitHub CLI (gh) to automate GitHub repository operations efficiently.

## Prerequisites

- GitHub CLI must be installed: `gh --version`
- Authentication required: `gh auth status`

## Core Operations

### Repository Management

```bash
# View repository information
gh repo view

# Clone a repository
gh repo clone owner/repo

# Fork a repository
gh repo fork

# Create a new repository
gh repo create my-new-repo --public
```

### Pull Requests

```bash
# Create a pull request
gh pr create --title "Feature: Add new functionality" --body "Description"

# List pull requests
gh pr list --state open
gh pr list --author @me

# View PR details
gh pr view 123

# Check out a PR locally
gh pr checkout 123

# Merge a pull request
gh pr merge 123 --squash

# Review PR status
gh pr status
```

### Issues

```bash
# Create an issue
gh issue create --title "Bug: Something broke" --body "Description"

# List issues
gh issue list --state open
gh issue list --label bug --assignee @me

# View issue details
gh issue view 456

# Close an issue
gh issue close 456

# Reopen an issue
gh issue reopen 456
```

### Workflow Runs

```bash
# List workflow runs
gh run list --limit 10

# View specific run
gh run view 12345

# Watch a running workflow
gh run watch

# Rerun a failed workflow
gh run rerun 12345

# List workflow run logs
gh run view 12345 --log
```

### Branches

```bash
# List branches (via API)
gh api repos/:owner/:repo/branches

# Delete remote branch
gh api -X DELETE repos/:owner/:repo/git/refs/heads/branch-name
```

### Releases

```bash
# Create a release
gh release create v1.0.0 --title "Release 1.0.0" --notes "Release notes"

# List releases
gh release list

# Download release assets
gh release download v1.0.0
```

### Gists

```bash
# Create a gist
gh gist create file.txt --public

# List your gists
gh gist list

# View a gist
gh gist view <gist-id>
```

## Advanced Usage

### JSON Output for Parsing

Many commands support `--json` for structured output:

```bash
# Get PR data as JSON
gh pr list --json number,title,state,headRefName

# Get issue data as JSON
gh issue list --json number,title,labels,state

# Parse with jq
gh pr list --json number,title | jq '.[] | select(.title | contains("bug"))'
```

### API Access

Direct API access for advanced operations:

```bash
# Generic API call
gh api repos/:owner/:repo/branches

# With pagination
gh api repos/:owner/:repo/pulls --paginate

# POST request
gh api repos/:owner/:repo/issues -f title="New Issue" -f body="Description"
```

### Checking for Stale Branches

```bash
# List merged branches
git branch -r --merged main | grep -v 'main\|HEAD'

# Get PR information
gh pr list --state merged --json headRefName,mergedAt
```

## Best Practices

1. **Always check auth status first**: Run `gh auth status` before operations
2. **Use structured output**: Prefer `--json` when parsing results programmatically
3. **Check command success**: Verify exit codes and output before proceeding
4. **Use help**: Run `gh <command> --help` for detailed syntax
5. **Batch operations**: Combine commands with shell scripting for bulk operations

## Common Workflows

### Creating and Merging a PR

```bash
# Push your changes
git push origin feature-branch

# Create PR
gh pr create --title "Feature: Description" --body "Detailed description"

# Wait for CI/checks
gh pr checks

# Merge when ready
gh pr merge --squash
```

### Cleaning Up Merged Branches

```bash
# List merged PRs
gh pr list --state merged --json headRefName --limit 20

# Delete remote branches (carefully!)
# gh api -X DELETE repos/:owner/:repo/git/refs/heads/branch-name
```

### Release Management

```bash
# Tag and create release
git tag v1.0.0
git push --tags
gh release create v1.0.0 --generate-notes

# Or with custom notes
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes here"
```

## Error Handling

```bash
# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not installed"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "Not authenticated. Run: gh auth login"
    exit 1
fi
```

## Reference

- Official docs: https://cli.github.com/manual/
- All commands: `gh help`
- Command-specific help: `gh <command> --help`
