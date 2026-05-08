---
name: check-pr-review
description: Use gh-check-pr-review to fetch and address PR review comments. Use this skill when checking PR review feedback, viewing unresolved threads, or addressing reviewer comments.
---

# Check PR Review Comments

Fetch review comments for a PR and address any feedback.

## Usage

```bash
gh-check-pr-review <pr-number> [-R <owner/repo>] [--all] [--review N] [--full]
```

## Options

- `-R <owner/repo>`: Target repository (default: current repo)
- `-a, --all`: Include resolved comments (default: only unresolved)
- `-r, --review N`: Show details for review number N
- `-f, --full`: Show all details (original behavior)
- `-d, --open-details`: Expand `<details>` blocks (default: collapsed)

## Output Modes

### Default (Summary)

Shows compact overview of all reviews with thread counts:

- Review author, state, unresolved thread count
- Thread locations (file:line) with first line of comment

### --review N

Shows full details for a specific review:

- Review body
- All associated threads with diff context and full comments

### --full

Shows all reviews and threads with full details (legacy behavior).

## Workflow

1. Run without options to get summary
2. **Automatically** run `--review N` for each review that has unresolved comments (do NOT ask the user if they want to see details)
3. **Evaluate each comment** before making changes:
    - Consider whether the feedback should be addressed or not
    - If disagreeing with a comment, explain the reasoning to the user instead of making changes
    - Only proceed with code changes for feedback you agree with
4. Make necessary code changes based on the feedback
5. Re-run to verify all comments have been addressed

**Important**: After getting the summary, immediately proceed to fetch details for each review. Never ask the user "詳細を確認しますか?" or similar confirmation questions.
