---
name: "specimin-wrap"
description: "Squash commits and create a pull request after feature implementation is complete. Only invoke when user explicitly requests to wrap up, create a PR, prepare for review, or finish the feature."
allowed-tools:
  - run_terminal_cmd
  - read_file
---

# Feature Wrap-Up Command

Prepare completed work for code review: squash commits, generate PR description, create pull request.

# Stage 1: Validate Environment

**Actions**:
1. Check uncommitted changes: `git status`
2. Get current branch: `git rev-parse --abbrev-ref HEAD` → store as `CURRENT_BRANCH`
3. Detect main branch (try in order):
   ```bash
   git show-ref --verify --quiet refs/heads/main && echo "main" || \
   git show-ref --verify --quiet refs/heads/master && echo "master" || \
   echo "unknown"
   ```
   Store as `MAIN_BRANCH`. If "unknown", ask user: "What is your main branch name?"
4. Verify branch is not main: If `CURRENT_BRANCH == MAIN_BRANCH`, error and exit
5. Check initialization: Verify `.specimin/plans/{CURRENT_BRANCH}/` exists
6. Read feature context (for PR description generation):
   - `.specimin/plans/{CURRENT_BRANCH}/spec.md`
   - `.specimin/plans/{CURRENT_BRANCH}/plan.md`
   - `.specimin/plans/{CURRENT_BRANCH}/implementation.md`

**Context Extraction Goals** (from spec/plan):
- Feature objective (1-2 sentence summary)
- High-level changes by phase/component
- Acceptance criteria
- Testing approach

**Error Handling**:
- Uncommitted changes: `Warning: Uncommitted changes detected. Commit or stash before wrapping up.` → Exit
- On main branch: `Error: Cannot wrap up main branch. Switch to feature branch first.` → Exit
- Not initialized: `Error: Specimin not initialized. Run /init first.` → Exit
- No commits ahead: `Error: No commits to squash. Branch up to date with {MAIN_BRANCH}.` → Exit
- `gh` not installed: `Error: GitHub CLI not installed. Install: https://cli.github.com/` → Exit
- Not authenticated: `Error: Not authenticated with GitHub CLI. Run: gh auth login` → Exit

**Checkpoint**: Verify environment valid (no uncommitted changes, on feature branch, has commits to squash) before proceeding.

# Stage 2: Run Tests

**Actions**:
1. Detect test framework and run appropriate test command:
   - Python: `python3 -m pytest` or `pytest`
   - JavaScript/TypeScript: `npm test` or `yarn test`
   - Ruby: `bundle exec rspec` or `rake test`
   - Go: `go test ./...`
   - Rust: `cargo test`
   - Java: `mvn test` or `gradle test`
   - Other: Check for `Makefile` with test target, or ask user

2. Run tests and capture output

3. **Error Handling**:
   - Tests fail: Display failure summary and exit with message:
     ```
     ✗ Tests failed. Fix failing tests before wrapping up.

     {test failure summary}

     Run tests again after fixes and retry wrap.
     ```
   - Tests pass: Proceed to next stage
   - No tests found: Warn user but continue:
     ```
     ⚠ No tests detected. Consider adding tests before creating PR.
     Proceed anyway? (yes/no)
     ```

**Checkpoint**: Verify all tests pass before proceeding to review changes.

# Stage 3: Review Changes

Show user what will be squashed:

1. **Commit history**:
   ```bash
   git log {MAIN_BRANCH}..HEAD --oneline
   ```

2. **Change summary**:
   ```bash
   git diff {MAIN_BRANCH}...HEAD --stat
   ```

3. **Files changed**:
   ```bash
   git diff {MAIN_BRANCH}...HEAD --name-only
   ```

Present:
```
I'll squash these commits into one:

[commit history]

Files changed:
[file list]

Proceed with squash and PR creation? (yes/no)
```

Wait for confirmation. If "no", exit gracefully.

# Stage 4: Squash Commits

Once confirmed:

1. **Generate commit message**:
   - Use feature objective from spec.md
   - Summarize WHAT changed (not HOW)
   - 1-2 sentences max
   - Follow conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`

2. **Perform squash**:
   ```bash
   git reset --soft {MAIN_BRANCH}
   git commit -m "{COMMIT_MESSAGE}"
   ```

   **CRITICAL**: No `--author`, no `Co-Authored-By:`, no co-authoring metadata. User authorship only.

3. **Verify squash**:
   ```bash
   git log --oneline -1
   ```
   Confirm only one commit since main branch.

**Checkpoint**: Verify squash succeeded (single commit, correct message) before creating PR.

# Stage 5: Create Pull Request

1. **Generate PR title**:
   - Use commit message or feature name from spec
   - Under 72 characters
   - Clear and descriptive

2. **Generate PR description** (use template below with extracted context):

```markdown
## Summary

{1-2 sentence feature objective from spec.md}

## Changes

{Bulleted list of high-level changes from plan.md phases or implementation.md completed tasks}

## Testing

{Testing approach from plan.md, or manual test scenarios}

## Acceptance Criteria

{Criteria from spec.md}
```

3. **Create PR**:
   ```bash
   gh pr create --title "{PR_TITLE}" --body "$(cat <<'EOF'
   {PR_DESCRIPTION}
   EOF
   )"
   ```

4. **Display result**:
   ```
   ✓ Squashed {N} commits into 1 commit
   ✓ Created pull request: {PR_URL}

   Your feature is ready for review!
   ```

**No upstream remote**: `gh pr create` will prompt to push if needed.

# Complete Examples

## Example 1: Simple CRUD Feature

**Spec objective**: "Add user profile management allowing users to update their name and email"

**Commit message**:
```
feat: add user profile management with update functionality
```

**PR title**:
```
feat: add user profile management
```

**PR description**:
```markdown
## Summary

Add user profile management allowing users to update their name and email through a settings page.

## Changes

- Added User schema with name and email fields
- Implemented update_user/2 function with validation
- Created ProfileLive page with edit form
- Added integration tests for profile updates

## Testing

- Unit tests: Accounts.update_user/2 with valid/invalid inputs
- Integration tests: ProfileLive form submission and validation errors
- Manual: Navigate to /profile, update name/email, verify saved

## Acceptance Criteria

- [x] Users can view current profile information
- [x] Users can update name and email
- [x] Invalid emails show validation errors
- [x] Changes persist after page refresh
```

## Example 2: Complex Integration Feature

**Spec objective**: "Integrate Stripe payment processing with retry logic and webhook handling for subscription management"

**Commit message**:
```
feat: integrate Stripe payment processing with webhook support
```

**PR title**:
```
feat: integrate Stripe payment processing
```

**PR description**:
```markdown
## Summary

Integrate Stripe payment processing with automatic retry logic for failed charges and webhook handlers for subscription lifecycle events.

## Changes

- Added Stripe client module with exponential backoff retry logic
- Implemented payment processing functions (create_charge, refund_charge)
- Created webhook handler for subscription events (created, updated, canceled)
- Added Payment schema and database migrations
- Implemented error handling for network failures and invalid cards

## Testing

- Unit tests: StripeClient module with mocked HTTP responses
- Integration tests: Payment creation flow with test API keys
- Webhook tests: Event handling for all subscription states
- Manual: Create test charge in Stripe dashboard, verify webhook receipt

## Acceptance Criteria

- [x] Charges created successfully with valid cards
- [x] Network failures retry up to 3 times with backoff
- [x] Invalid cards return clear error messages
- [x] Webhooks update subscription status in database
- [x] Payment history visible to users
```

---

**Note**: This prompt optimized using research-backed principles: token efficiency (-30%), verification checkpoints (Reflexion 91%), consolidated examples (2-5 optimal), explicit context extraction (CGRAG 4x improvement), and minimal preamble (GPT-5-Codex guidance).

