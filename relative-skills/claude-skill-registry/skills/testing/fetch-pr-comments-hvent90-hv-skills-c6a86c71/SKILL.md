---
name: fetch-pr-comments
description: Fetch unresolved PR review comments and feedback on the current branch. Use when you need to address outstanding PR review items or see what feedback needs to be resolved. Optionally filter by a specific reviewer.
allowed-tools: Bash, Read, Write
---

# Fetch PR Comments

Fetches unresolved review threads and pending reviews from the current branch's pull request.

## Usage

Run the script from the repository root:

```bash
# Fetch all unresolved comments
./scripts/fetch-pr-comments.sh

# Fetch unresolved comments from a specific user
./scripts/fetch-pr-comments.sh username
```

## Output

Results are saved to `/tmp/delete-me/{timestamp}-{repo}-{branch}.json`.

Example output structure:

```json
{
  "pr_number": 123,
  "repo": "owner/repo",
  "branch": "feature/example",
  "fetched_at": "2025-12-17T12:00:00Z",
  "filter_user": null,
  "unresolved_threads": [
    {
      "path": "src/example.ts",
      "line": 42,
      "comments": [
        {
          "author": "reviewer",
          "body": "Consider using a more descriptive name",
          "created_at": "2025-12-16T10:30:00Z"
        }
      ]
    }
  ],
  "pending_reviews": [
    {
      "user": "reviewer",
      "state": "CHANGES_REQUESTED",
      "body": "A few items to address",
      "submitted_at": "2025-12-16T10:00:00Z"
    }
  ]
}
```

## What It Captures

- **Unresolved threads**: Inline code review comments that haven't been marked as resolved
- **Pending reviews**: Overall review submissions (APPROVED, CHANGES_REQUESTED, COMMENTED)

## Requirements

- GitHub CLI (`gh`) must be installed and authenticated
- Must be run from within a git repository
- Current branch must have an open pull request
