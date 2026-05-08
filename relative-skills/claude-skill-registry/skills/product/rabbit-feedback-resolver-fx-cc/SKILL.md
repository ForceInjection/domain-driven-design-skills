---
name: rabbit-feedback-resolver
description: Process and resolve CodeRabbit automated PR review comments. Use when the user says "check rabbit review", "handle coderabbit comments", "resolve rabbit feedback", or mentions CodeRabbit PR comments. Also use after PR creation when CodeRabbit has left automated review comments.
---

# CodeRabbit Feedback Resolver

Process and resolve CodeRabbit's automated PR review comments systematically.

## PR Comments Prohibition (CRITICAL)

**NEVER leave new comments directly on GitHub PRs.** This is strictly forbidden:

- `gh pr review --comment` - FORBIDDEN
- `gh pr comment` - FORBIDDEN
- Any GraphQL mutation that creates new reviews or PR-level comments - FORBIDDEN

**Permitted operations:**
- Reply to EXISTING CodeRabbit threads using `addPullRequestReviewThreadReply`
- Resolve CodeRabbit threads using `resolveReviewThread`

## WHEN TO USE THIS SKILL

**USE THIS SKILL PROACTIVELY** when ANY of the following occur:

- User says "check rabbit review" / "handle coderabbit comments" / "resolve rabbit feedback"
- User mentions "coderabbit" or "rabbit" and "PR" or "comments" in the same context
- After PR creation when CodeRabbit has reviewed the PR
- As part of the PR workflow after `pr-reviewer` agent completes
- When PR checks show CodeRabbit has left review comments

## CodeRabbit Comment Structure

CodeRabbit comments follow a structured markdown format:

```
_🧹 Nitpick_ | _🔵 Trivial_    <- Severity indicator (optional)

[Main feedback text]

<details>
<summary>💡 Optional suggestion</summary>
[Expanded suggestion content]
</details>

<details>
<summary>📝 Committable suggestion</summary>
[Code block with suggested changes]
</details>

<details>
<summary>🤖 Prompt for AI Agents</summary>
[Explicit instructions for AI to follow]
</details>
```

**Key elements to extract:**
- **Severity**: `_🧹 Nitpick_` or `_🔵 Trivial_` = auto-resolvable
- **Prompt for AI Agents**: Explicit instructions - USE THESE DIRECTLY
- **Committable suggestion**: Ready-to-apply code changes

## Prerequisites

**CRITICAL: Load the `fx-dev:github` skill FIRST** before running any GitHub API operations. This skill provides essential patterns and error handling for `gh` CLI commands.

## Core Workflow

### 0. Verify CodeRabbit Configuration (First Run Only)

**Before processing feedback, ensure CodeRabbit is configured to read `.github/copilot-instructions.md`.**

CodeRabbit's `knowledge_base.code_guidelines` feature reads instruction files to understand project conventions. By default, it includes `.github/copilot-instructions.md`, but this may be disabled or overridden.

#### Check Configuration

```bash
# Check if .coderabbit.yaml exists
if [ -f ".coderabbit.yaml" ]; then
  cat .coderabbit.yaml
else
  echo "No .coderabbit.yaml found - using defaults"
fi
```

#### Configuration States

| State | Action |
|-------|--------|
| No `.coderabbit.yaml` exists | Defaults apply - `.github/copilot-instructions.md` IS read automatically |
| Config exists with `knowledge_base.code_guidelines.enabled: false` | **Update** to `enabled: true` |
| Config exists with custom `filePatterns` missing copilot-instructions.md | **Add** `.github/copilot-instructions.md` to `filePatterns` |
| Config exists with defaults or explicit copilot-instructions.md | No action needed |

#### Create/Update Configuration

If configuration needs updating, create or modify `.coderabbit.yaml`:

```yaml
# .coderabbit.yaml
# Ensures CodeRabbit reads project conventions from copilot-instructions.md

knowledge_base:
  code_guidelines:
    enabled: true
    # Default patterns include .github/copilot-instructions.md
    # Add explicit pattern if using custom filePatterns:
    # filePatterns:
    #   - .github/copilot-instructions.md
    #   - CLAUDE.md
```

**Minimal config to ensure copilot-instructions.md is read:**

```yaml
knowledge_base:
  code_guidelines:
    enabled: true
```

This enables the default file patterns which include `.github/copilot-instructions.md`.

#### When to Update copilot-instructions.md

If CodeRabbit feedback conflicts with project conventions (INCORRECT category), update `.github/copilot-instructions.md` with the correct pattern. Since CodeRabbit reads this file, future reviews will respect the documented conventions.

### 1. Fetch Unresolved CodeRabbit Threads

Query review threads using GraphQL.

**IMPORTANT:** Use inline values, NOT `$variable` syntax. The `$` character causes shell escaping issues (`Expected VAR_SIGN, actual: UNKNOWN_CHAR`).

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
          path
          line
          comments(first: 10) {
            nodes {
              author { login }
              body
            }
          }
        }
      }
    }
  }
}'
```

**Filter for:** `isResolved: false` AND author login contains `coderabbitai`

### 2. Categorize Each Comment

For each unresolved CodeRabbit comment:

| Category | Indicator | Action |
|----------|-----------|--------|
| **Nitpick/Trivial** | Contains `_🧹 Nitpick_` or `_🔵 Trivial_` | Auto-resolve immediately |
| **Actionable with AI Prompt** | Has `🤖 Prompt for AI Agents` section | Extract prompt, delegate to coder |
| **Actionable with Committable** | Has `📝 Committable suggestion` | Apply suggestion directly |
| **General Feedback** | No special sections | Analyze and delegate to coder |
| **Deferred** | Valid but out of scope for this PR | Track in PROJECT.md, reply, resolve |

### 3. Process Each Category

#### Nitpicks/Trivial
- Resolve immediately without changes
- These are suggestions, not requirements

#### Actionable with AI Prompt (PREFERRED)

**When a comment contains `🤖 Prompt for AI Agents`, extract and use it directly:**

1. Parse the comment body to extract content between `<summary>🤖 Prompt for AI Agents</summary>` and the closing `</details>`
2. The extracted text contains explicit instructions - pass these to the coder agent verbatim
3. After fix is implemented, resolve the thread

Example extraction:
```
In src/lib/view-config.ts around lines 115 to 118, expand the JSDoc above
NUMERIC_OPERATORS to explicitly state that operators in this set expect numeric
values...
```

#### Actionable with Committable Suggestion

1. Extract the code block from `📝 Committable suggestion` section
2. Apply the suggested changes directly using Edit tool
3. Commit with message referencing the CodeRabbit suggestion
4. Resolve the thread

#### General Feedback

1. Read the feedback carefully
2. Determine if it's valid or conflicts with project conventions
3. If valid: Delegate to coder agent with context
4. If conflicts with project conventions (INCORRECT):
   - Reply with explanation and resolve
   - **Update `.github/copilot-instructions.md`** to document the correct pattern
   - This prevents both Copilot AND CodeRabbit from flagging it again (CodeRabbit reads this file via `knowledge_base.code_guidelines`)

#### Deferred (Out of Scope)

**When feedback is valid but out of scope for the current PR:**

1. **Load the `fx-dev:project-management` skill** to track the follow-up work
2. **Add task to PROJECT.md** under the appropriate feature/section:
   - Read current PROJECT.md structure
   - Add a concise task describing the improvement
   - Commit the PROJECT.md update
3. **Reply to the thread** explaining the deferral:
   - "Valid suggestion. Tracked as follow-up task in PROJECT.md for a future PR."
4. **Resolve the thread**

**CRITICAL:** Never defer feedback without tracking it. "Acknowledged for follow-up" without a PROJECT.md entry is INCOMPLETE WORK.

### 4. Resolve Threads

Use GraphQL mutation to resolve each processed thread.

**IMPORTANT:** Use inline values, NOT `$variable` syntax.

```bash
# Replace THREAD_ID with actual thread ID (e.g., PRRT_kwDONZ...)
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "THREAD_ID"}) {
    thread { isResolved }
  }
}'
```

### 5. Reply to Threads (When Needed)

For feedback that conflicts with conventions or is being declined.

**IMPORTANT:** Use inline values, NOT `$variable` syntax.

```bash
# Replace THREAD_ID and message with actual values
gh api graphql -f query='
mutation {
  addPullRequestReviewThreadReply(input: {
    pullRequestReviewThreadId: "PRRT_xxx",
    body: "Your explanation here"
  }) {
    comment { id }
  }
}'
```

## Parsing Helper

To extract the AI prompt from a CodeRabbit comment:

```bash
# Extract content between 🤖 Prompt for AI Agents and </details>
echo "$COMMENT_BODY" | sed -n '/🤖 Prompt for AI Agents/,/<\/details>/p' | sed '1d;$d' | sed 's/^```$//'
```

## Success Criteria

**Task is INCOMPLETE until ALL of these are done:**

1. CodeRabbit config verified/updated to read `.github/copilot-instructions.md`
2. All code changes pushed to the PR branch
3. **EVERY addressed thread resolved via GraphQL mutation**
4. **For INCORRECT feedback:** `.github/copilot-instructions.md` updated to prevent recurrence
5. **For DEFERRED feedback:** Task added to `docs/PROJECT.md` via project-management skill
6. Re-query confirms `isResolved: true` for all processed threads
7. Output summary table

### Required Output: Thread Summary Table

```
| Thread ID | File:Line | Category | Action Taken | Status |
|-----------|-----------|----------|--------------|--------|
| PRRT_xxx  | src/foo.ts:42 | Nitpick | Auto-resolved | ✅ Resolved |
| PRRT_yyy  | src/bar.ts:15 | AI Prompt | Applied JSDoc fix | ✅ Resolved |
| PRRT_zzz  | lib/util.js:8 | Committable | Applied suggestion | ✅ Resolved |
| PRRT_aaa  | src/ui.tsx:20 | Deferred | Tracked in PROJECT.md | ✅ Resolved |
```

## Error Handling

- API failures: Retry with proper auth
- Thread ID issues: Use alternative queries
- Parse failures for AI prompt: Fall back to manual analysis
- Partial resolution is better than none
