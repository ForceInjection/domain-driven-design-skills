---
name: resolve-pr-feedback
description: Check a PR for unresolved automated review feedback (Copilot, CodeRabbit) and invoke the appropriate resolver skills. Use when the user says "resolve PR feedback", "check PR comments", "address review comments", or wants to handle all automated review feedback on a PR.
---

# Resolve PR Feedback

Meta-skill that checks a PR for unresolved automated review feedback and invokes the appropriate resolver skills.

## WHEN TO USE THIS SKILL

**USE THIS SKILL** when ANY of the following occur:

- User says "resolve PR feedback" / "check PR comments" / "address review comments"
- User wants to handle all automated review feedback on a PR
- After PR creation to ensure all automated reviewers are addressed
- As part of the SDLC workflow before finalizing a PR

## Supported Reviewers

| Reviewer | Author Pattern | Resolver Skill |
|----------|---------------|----------------|
| GitHub Copilot | `Copilot` | `fx-dev:copilot-feedback-resolver` |
| CodeRabbit | `coderabbitai[bot]` | `fx-dev:rabbit-feedback-resolver` |

## Prerequisites

**CRITICAL: Load the `fx-dev:github` skill FIRST** before running any GitHub API operations.

## Core Workflow

### 1. Determine PR Number

If not provided, get from current branch:

```bash
gh pr view --json number -q '.number'
```

### 2. Query All Unresolved Review Threads

**IMPORTANT:** Use inline values, NOT `$variable` syntax. The `$` character causes shell escaping issues.

```bash
# Replace OWNER, REPO, PR_NUMBER with actual values
gh api graphql -f query='
query {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 1) {
            nodes {
              author { login }
            }
          }
        }
      }
    }
  }
}'
```

### 3. Identify Unresolved Feedback by Source

Parse the response and categorize unresolved threads by author:

- **Copilot threads**: author login is `Copilot`
- **CodeRabbit threads**: author login contains `coderabbitai`

### 4. Invoke Appropriate Resolver Skills

**If Copilot threads exist:**
```
Skill tool: skill="fx-dev:copilot-feedback-resolver"
```

**If CodeRabbit threads exist:**
```
Skill tool: skill="fx-dev:rabbit-feedback-resolver"
```

**If both exist:** Invoke both skills sequentially (Copilot first, then CodeRabbit).

### 5. Verify All Resolved

After invoking resolver skills, re-query to confirm all threads are resolved:

```bash
# Replace OWNER, REPO, PR_NUMBER with actual values
gh api graphql -f query='
query {
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 1) {
            nodes {
              author { login }
            }
          }
        }
      }
    }
  }
}' | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length'
```

If unresolved threads remain, report which reviewers still have open feedback.

## Output Format

```
## PR #123 Feedback Summary

### Detection
- Copilot: 2 unresolved threads found
- CodeRabbit: 3 unresolved threads found

### Resolution
- Invoked fx-dev:copilot-feedback-resolver
- Invoked fx-dev:rabbit-feedback-resolver

### Final Status
- All automated review threads resolved
```

## Success Criteria

1. All unresolved automated review threads identified
2. Appropriate resolver skill(s) invoked
3. Final verification confirms all threads resolved
4. Summary output provided

## Error Handling

- If no PR found: Ask user for PR number
- If resolver skill fails: Report which reviewer's feedback remains unresolved
- If API errors: Retry with proper auth context
