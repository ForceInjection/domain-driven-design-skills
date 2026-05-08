---
name: wm-workspace-manager
description: Workspace orchestration automation for the wm CLI multi-repo workflow. Use when user wants to start, resume, extend, or manage engineering workspaces with Git worktrees. Handles intent parsing ("start working on X"), repository resolution, feature slugging, branch naming, and wm command construction with proper flags and collision handling.
---

# WM Workspace Manager

Translate natural-language requests about engineering work into concrete `wm` CLI actions for multi-repo worktree management.

## Related Skills

**Use `brain-operating-system` skill** when:
- Including brain directory in workspace (`--folder brain` flag)
- Understanding brain repository structure and workflows
- Creating workspace notes or documentation

## Command Overview

| Command | Use Case | Key Flags |
|---------|----------|-----------|
| `wm init --feature "<label>" <repos...>` | Start new workspace session | `--checkout-existing`, `--base`, `--notes`, `--no-open` |
| `wm open <session-id>` | Reopen existing workspace | N/A |
| `wm extend <session-id> <repo>` | Add repo to session | N/A |
| `wm list` | Show active sessions | N/A |
| `wm prune <session-id>` | Tear down workspace | Confirm merges first |

## Intent Recognition

Treat these verbs as workspace management signals:
- "start working", "continue", "switch to", "resume", "spin up"
- "I need to migrate...", "I want to build...", "Help me with..."

## Feature Label Extraction

1. **Quoted text**: Use verbatim (`"flipper feature improvements"` → slug `flipper-feature-improvements`)
2. **Trailing description**: Infer from rest of sentence
3. **Normalization**: lowercase, replace spaces/slashes with `-`, drop punctuation
4. **Branch naming**: `feature/<slug>`

## Repository Resolution

1. **Search paths**: `~/github/*` and `~/code/*/*`
2. **Tokenization**: Split on commas, `and`, `+`, or whitespace; discard filler words (`on`, `in`, `for`, `the`)
3. **Multiple matches**: Offer numbered clarification, wait for choice
4. **Missing repos**: Provide clone command or offer to skip/replace

## Command Construction

### Base Command
```bash
wm init --feature "<feature label>" <repo1> <repo2> ...
```

### Optional Flags

- `--primary <repo>`: When user specifies different anchor
- `--base <branch>` or `<repo:branch>`: For custom base branches
- `--notes "<text>"`: Capture kickoff context
- `--checkout-existing`: Reuse existing worktree/branch
- `--folder brain`: Include brain directory without creating worktree
- `--dry-run`, `--no-open`, `--verbose`: Only when explicitly requested

### Preflight Checks

1. **Existing worktrees**: Detect slug conflicts; ask to reuse or create timestamped variant
2. **Environment variables**: Respect `WM_WORKTREES_ROOT`, `WM_WORKSPACES_ROOT`, `WM_HISTORY_FILE`, `WM_REPO_CONFIG`
3. **Collision handling**: Append timestamp or numeric suffix if slug exists; log original intent

## Execution Flow

1. **Confirm intent** before running (unless clear "yes" signal)
2. **Run command** via terminal tool
3. **Capture stdout/stderr** for summary
4. **On failure**: Surface error, propose remediation, ask whether to retry

## Post-Execution Reporting

Identify and report:
- **Session ID**: `<slug>--<primary-repo>+<other-repos-alphabetical>`
- **Worktree directories**: `<root>/<repo>/<slug>`
- **VS Code workspace**: `~/code/workspaces/<session-id>.code-workspace`
- **Manifest**: `~/code/workspaces/<session-id>.json`
- **Notes folder**: `~/code/workspaces/<session-id>/notes.md` (if created)

## Follow-Up Suggestions

- "Need to reopen? → `wm open <session-id>`"
- "Want to attach repo? → `wm extend <session-id> <repo>`"
- "Check active sessions → `wm list`"
- "Finish session → `wm prune <session-id>`" (confirm merges first)

## Session Lifecycle

### Start
```bash
wm init --feature "queue outcomes migration" hamzo spamurai-next
```

### Resume
```bash
wm open <session-id>
# or
wm recent 1
```

### Extend
```bash
wm extend <session-id> flipper
```

### Status
```bash
wm list
```

### Finish
```bash
wm prune <session-id>
```

## Edge Cases

- **Existing branches**: Offer reuse with `--checkout-existing` or create timestamped variant
- **Branch collisions**: Append suffix, log original intent in manifest
- **Missing repos**: Provide clone instructions; optionally run if credentials allow
- **VS Code trust**: Advise on trust workflow if repeated prompts occur
- **Non-interactive**: Never destructive without user confirmation

## Example Walkthrough

**User request**: "I need to start working on flipper feature improvements in hamzo and spamurai-next"

**Your steps**:
1. Extract feature: `flipper feature improvements` → slug `flipper-feature-improvements` → branch `feature/flipper-feature-improvements`
2. Identify repos: `hamzo`, `spamurai-next` (confirm directories exist)
3. Run: `wm init --feature "flipper feature improvements" hamzo spamurai-next`
4. Report:
   - Session ID: `flipper-feature-improvements--hamzo+spamurai-next`
   - Worktree paths: List each
   - VS Code launch status
   - Remind about `wm open` and `wm prune`

## Including Brain Directory

When user wants the brain workspace (second-brain notes) in the session:

```bash
wm init --feature "<label>" --folder brain <repo1> <repo2>
```

This adds brain to the workspace **without** creating a worktree (brain isn't a git repo managed by wm).

## Communication Guidelines

- **Concise task-focused responses**
- **Surface critical state immediately**: success/failure, workspace location, branch names
- **Actionable next steps**: especially for resume/finish flows
- **Clarify only when required**: multiple repo matches, unclear feature name
