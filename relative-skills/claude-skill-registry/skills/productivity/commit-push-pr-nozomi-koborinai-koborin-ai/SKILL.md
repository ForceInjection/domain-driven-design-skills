---
name: commit-push-pr
description: Automate the workflow from creating a branch to opening a GitHub pull request. Use when the user says "create a PR", "commit and push", "push changes and create PR", or "open a pull request".
---

# commit-push-pr

Automate creating branches, commits, and pull requests.

## Trigger Examples

- "Create a PR"
- "Commit and push"
- "Push changes and create PR"
- "Open a pull request"

## Prerequisites

- GitHub CLI (`gh`) is installed and authenticated
- Changes exist in the working tree
- Local quality checks have been run manually

## Execution Flow

### 1. Generate Branch Name

Derive branch prefix from commit type:

| Type | Branch Format |
|------|---------------|
| feat(scope): ... | `feature/scope-<summary>` |
| fix(scope): ... | `fix/scope-<summary>` |
| refactor(scope): ... | `refactor/scope-<summary>` |
| docs | `docs/<summary>` |
| No scope | `<type>/<summary>` |

- Use lowercase kebab-case
- Translate Japanese summaries to English

### 2. Create or Reuse Branch

```bash
git rev-parse --abbrev-ref HEAD
```

- If on base branch: create new branch with `git checkout -b <branch>`
- If on feature branch: confirm reuse with user

### 3. Stage and Commit Changes

```bash
git status --porcelain
git add -A
git commit -m "<message>"
```

If no staged changes, inform user and stop.

### 4. Push to Remote

```bash
git push -u origin <branch>
```

Prompt: "Ready to create a PR now?"

### 5. Generate PR Body

Gather context:

```bash
git log origin/<base>..HEAD --oneline
git diff origin/<base>...HEAD --stat
```

Populate PR sections:

1. **Purpose / Background** - Why the change exists
2. **Summary of changes** - Major modifications by layer
3. **Verification steps** - Commands and manual checks
4. **Impact / Compatibility** - API/schema changes, breaking behavior
5. **Linked issues / docs** - Reference tickets or docs
6. **Checklist** - Mark satisfied items

### 6. Create the PR

```bash
gh pr create \
  --base <base> \
  --title "$(git log -1 --pretty=%s)" \
  --body-file /tmp/pr-body.md \
  --assignee "nozomi-koborinai"
```

Ask if draft PR is preferred.

### 7. Output PR URL

Display the link for user review.

## AI Analysis Points

**Classify the change set:**

- Frontend: `app/` or `app/src`
- Infrastructure: `infra/**`
- Documentation: `docs/`, `AGENTS.md`, `README.md`
- Tests: `*.test.ts`, `tests/`

**Detect high-risk changes:**

- Database schema changes
- API contract changes
- Infrastructure modifications
- Security-sensitive updates

## Notes

- Assume `origin` points to GitHub
- PR descriptions should be high quality from the start
- If branch exists, ask user for alternative name
