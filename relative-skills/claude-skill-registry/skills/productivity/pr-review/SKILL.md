---
name: pr-review
description: "Manage GitHub PR review comments - fetch, resolve, dismiss, and interact with PR review threads. Handles comment detection, fetching, resolution, and dismissal with reasons. Use when: (1) Working on a PR with review comments, (2) Need to fetch and review PR feedback, (3) Want to resolve comments after making fixes, (4) Need to dismiss comments that are not applicable, (5) Managing PR comment files, (6) When GitHub PR comments need to be processed, (7) When working with pull requests that have received feedback, (8) For PR workflow automation and comment organization, or (9) For GitHub API integration and PR management. Triggers: PR comments, review comments, fetch PR feedback, resolve comment, dismiss comment, PR review, pull request comments, handle review feedback, get PR comments, manage PR comments."
---

# PR Review

## Tools

- `bash skills/pr-review/scripts/pr-comments-fetch.sh [read|resolve|list] [PR_NUMBER] [--verbose]` - Fetch PR comments (read mode); start here for overview, then use `bash skills/pr-review/scripts/pr-comments-get.sh` per comment
- `bash skills/pr-review/scripts/pr-comments-detect.sh` - Auto-detect PR number
- `bash skills/pr-review/scripts/pr-comments-get.sh [PR_NUMBER] [INDEX_OR_ID]` - Get single comment with context
- `bash skills/pr-review/scripts/pr-comments-resolve.sh [PR_NUMBER] <COMMENT_ID>...` - Resolve comments
- `bash skills/pr-review/scripts/pr-comments-dismiss.sh [PR_NUMBER] <COMMENT_ID> <REASON>` - Dismiss comments
- `bash skills/pr-review/scripts/pr-comments-resolve.sh [PR_NUMBER] --interactive` - Interactive resolve mode
- `bash skills/pr-review/scripts/pr-comments-fetch.sh list` - List all open PRs
- `bash skills/pr-review/scripts/pr-comments-cleanup.sh [--all] [PR_NUMBER]` - Clean up comment files

## Workflow

### Fetching Comments

1. **Detect PR number** (optional): Run `bash skills/pr-review/scripts/pr-comments-detect.sh` to auto-detect the current PR
   - Tool checks git remote and current branch to find associated PR
   - Displays PR number if found

2. **Fetch all comments**: Run `bash skills/pr-review/scripts/pr-comments-fetch.sh [PR_NUMBER]` or `bash skills/pr-review/scripts/pr-comments-fetch.sh` (auto-detects)
   - Fetches all review comments from the PR
   - Saves to `.ada/data/pr-comments/pr-comments-{PR}-{SHA}.md` (unresolved only; overview only)
   - Saves full metadata to `.ada/data/pr-comments/pr-comments-{PR}-{SHA}.json`
   - If there are 2+ unresolved comments, do not read the full markdown file; use `bash skills/pr-review/scripts/pr-comments-get.sh` per comment.

3. **Get specific comment**: Run `bash skills/pr-review/scripts/pr-comments-get.sh [PR_NUMBER] [INDEX_OR_ID]`
   - Use 1-based index (e.g., `1` for first unresolved comment)
   - Or use comment ID (e.g., `2507094339`)
   - Shows comment with file context and code snippet

### Working Through Comments

- Start with `bash skills/pr-review/scripts/pr-comments-fetch.sh` for counts and metadata.
- If 2+ unresolved comments exist, do not read the full markdown file. Use `bash skills/pr-review/scripts/pr-comments-get.sh` for each comment.
- For each comment, decide fix vs dismiss, then use resolve/dismiss scripts with the comment ID.
- Validate the detected PR number against the current branch/commit before taking action.

### Resolving Comments

1. **Review comment**: Use `bash skills/pr-review/scripts/pr-comments-get.sh [PR_NUMBER] 1` to see the first unresolved comment
   - Review the file path, line number, and code context
   - Understand what change is requested

2. **Fix the issue**: Make the necessary code changes
   - Edit the file at the specified location
   - Address the reviewer's concern

3. **Resolve comment**: Run `bash skills/pr-review/scripts/pr-comments-resolve.sh [PR_NUMBER] <COMMENT_ID>`
   - Can resolve multiple comments: `bash skills/pr-review/scripts/pr-comments-resolve.sh [PR_NUMBER] <ID1> <ID2>`
   - Marks comment as resolved on GitHub

4. **Interactive mode**: Use `bash skills/pr-review/scripts/pr-comments-resolve.sh [PR_NUMBER] --interactive` for guided resolution
   - Shows each unresolved comment
   - Prompts to resolve or skip

### Dismissing Comments

1. **Review comment**: Use `bash skills/pr-review/scripts/pr-comments-get.sh [PR_NUMBER] <COMMENT_ID>` to see the comment
   - Understand why the comment might not be applicable

2. **Dismiss with reason**: Run `bash skills/pr-review/scripts/pr-comments-dismiss.sh [PR_NUMBER] <COMMENT_ID> <REASON>`
   - Common reasons: `"not applicable"`, `"false positive"`, `"out of scope"`, `"bloat"`
   - Reason is recorded on GitHub

### Managing Comment Files

- **List PRs**: Use GitHub CLI directly: `gh pr list`
- **Cleanup**: Run `bash skills/pr-review/scripts/pr-comments-cleanup.sh [--all] [PR_NUMBER]` to remove old comment files
  - `--all` removes all PR comment files
  - Specify PR number to clean up specific PR files

## Examples

```bash
# Fetch comments (auto-detect or specify PR)
bash skills/pr-review/scripts/pr-comments-fetch.sh [PR_NUMBER]

# Work through unresolved comments one by one
bash skills/pr-review/scripts/pr-comments-get.sh [PR_NUMBER] 1
bash skills/pr-review/scripts/pr-comments-get.sh [PR_NUMBER] 1  # after resolve/dismiss, next unresolved becomes index 1

# Resolve comments (after fixing)
bash skills/pr-review/scripts/pr-comments-resolve.sh [PR_NUMBER] <COMMENT_ID>...

# Dismiss comment (short reason)
bash skills/pr-review/scripts/pr-comments-dismiss.sh [PR_NUMBER] <COMMENT_ID> <REASON>
```

## References

- [Documentation Guide](references/documentation-guide.md) - For documentation standards

## Output

PR comments are saved to `.ada/data/pr-comments/` directory:
- `pr-comments-{PR}-{SHA}.md` - Markdown (unresolved comments only)
- `pr-comments-{PR}-{SHA}.json` - Full metadata (all comments with resolved status)

### Integration with Other Skills

- Use after `bash skills/code-review/scripts/review-run.sh pr` to manage GitHub PR comments from CodeRabbit reviews
- Run `bash skills/code-quality/scripts/finalize.sh agent` after resolving comments to ensure fixes meet quality standards
- Use `bash skills/docs-check/scripts/check-docs.sh` if comments mention missing documentation

## Best Practices

- Fetch comments regularly to stay updated
- Use `bash skills/pr-review/scripts/pr-comments-detect.sh` to auto-detect PR number when possible
- Resolve comments after fixing issues
- Dismiss comments with clear reasons when not applicable
- Use cleanup command periodically to manage disk space
- Combine with `bash skills/code-review/scripts/review-run.sh pr` for complete PR workflow

## Anti-Patterns

- Reading the full markdown file when 2+ unresolved comments exist; use `bash skills/pr-review/scripts/pr-comments-get.sh` per comment instead.
- Resolving without confirming the issue in code; dismiss if it is stylistic or unclear.
- Dismissing without a clear, short reason.

## Dismissal Reasons

Common reasons for dismissing comments:
- `"not applicable"` - Comment doesn't apply to current context
- `"false positive"` - Comment is incorrect or misleading
- `"out of scope"` - Comment is outside the PR's scope
- `"bloat"` - Comment is unnecessary or redundant




