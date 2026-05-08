---
name: jira-workflow
description: Manage project tasks via Jira API using j4c. Use for ALL Jira project management tasks including creating tasks, checking ready work, linking dependencies, transitioning status, or adding comments.
---

# Jira Workflow Skill

Skill for managing Jira tasks using the `j4c` CLI.

**This skill MUST be used for ANY Jira project management work.**

## Handling Missing Config

If you see: `Error: no config file found`

Create a local config:

```bash
j4c init --server=https://yourcompany.atlassian.net --project=PROJ
```

This creates `.jira4claude.yaml` and adds it to `.gitignore`.

## MANDATORY: Issue Creation Template

**CRITICAL: ALL issues MUST use this template. Do not create issues without following this structure.**

```markdown
## Context

[What needs to be built and why - 1-3 sentences. No implementation details here.]

## Investigation Starting Points

- Examine [file/class] to understand existing patterns
- Review [reference] for similar functionality

## Scope Constraints

- Implement only what is specified
- Do not add [specific exclusions]
- [Other constraints]

## Validation Requirements

### Behavioral

- [Specific observable behavior to verify]
- [Another testable requirement]

### Quality

- All tests pass
- No linting errors
- Follows patterns in [reference file]
```

**Template Rules:**
1. Context explains WHAT and WHY, never HOW
2. Investigation points help discovery - reference specific files
3. Scope constraints prevent over-engineering
4. Validation requirements must be testable/observable

## Formatting Descriptions and Comments

**Always use GitHub-flavored markdown (GFM)** for descriptions and comments. The CLI automatically converts GFM to Jira's format. Do not use Jira wiki markup or plain unformatted text.

| Markdown | Result in Jira |
|----------|----------------|
| `## Heading` | Heading level 2 |
| `### Heading` | Heading level 3 |
| `- item` | Bullet list |
| `1. item` | Numbered list |
| `**bold**` | Bold text |
| `*italic*` | Italic text |
| `` `code` `` | Inline code |
| ` ``` ` blocks | Code blocks |
| `[text](url)` | Links |
| Blank lines | Paragraph breaks |

## Commands

All commands output human-readable text by default. Use `--json` when you need structured data for programmatic processing.

### List Open Tasks

Show all tasks not marked Done:

```bash
j4c issue list --jql="status NOT IN (Done)"
```

### Show Ready Tasks (Unblocked)

Find tasks with no unresolved blockers:

```bash
j4c issue ready
```

This shows tasks where all blockers are Done (or have no blockers).

### Show Task Details

Get full details for a specific task:

```bash
j4c issue view PROJ-123
```

### Create Task

Create a new task:

```bash
j4c issue create \
  --summary="Task title here" \
  --description="## Context

Description with markdown formatting.

## Validation Requirements

- Test requirement here"
```

### Link Tasks (Blocks Relationship)

**CRITICAL: Get the direction right or the dependency graph will be wrong!**

#### The Golden Rule

```
j4c link create FIRST Blocks SECOND
```

- **FIRST** = the blocker (do this first, shows in `ready`)
- **SECOND** = the blocked (do this after, NOT in `ready` until FIRST is Done)

**Memory aid:** Read it as a sentence: "FIRST blocks SECOND" or "FIRST must be done before SECOND"

#### Example

**Goal:** PROJ-7 (error handling) must be done before PROJ-8 (config loading)

```bash
j4c link create PROJ-7 Blocks PROJ-8
```

**After running this command:**

```bash
j4c issue view PROJ-7
# Shows: "blocks PROJ-8"

j4c issue view PROJ-8
# Shows: "is blocked by PROJ-7"

j4c issue ready
# Shows PROJ-7 (the blocker is ready to work on)
# Does NOT show PROJ-8 (blocked until PROJ-7 is Done)
```

#### MANDATORY Verification

**Always verify links using the `ready` command:**

```bash
j4c issue ready
```

Ask yourself:
- Does the blocker (prerequisite) appear in the ready list? It should.
- Does the blocked (dependent) appear in the ready list? It should NOT (unless its blocker is Done).

If the wrong task is blocked, you got the direction backwards. Delete and recreate.

#### Common Mistake

**Wrong:** You want A done before B, but you run `link create B Blocks A`
- Result: B appears blocked, A appears ready - the opposite of what you wanted!

**Fix:** Always read the command as a sentence. "A blocks B" means A is the prerequisite.

#### Quick Reference

| You want | Command | Ready shows |
|----------|---------|-------------|
| A before B | `link create A Blocks B` | A (not B) |
| B depends on A | `link create A Blocks B` | A (not B) |

### View Links

List all links for an issue:

```bash
j4c link list PROJ-123
```

### Delete Link

If you created a link with wrong direction, delete and recreate:

```bash
j4c link delete PROJ-7 PROJ-8
```

This removes any link between the two issues (regardless of direction).

### Transition Task

List available transitions for a task:

```bash
j4c issue transitions PROJ-123
```

Execute a transition by status name:

```bash
j4c issue transition PROJ-123 --status="Done"
```

Or by transition ID:

```bash
j4c issue transition PROJ-123 --id="21"
```

Common transitions (may vary by workflow):
- "Start Progress" (To Do -> In Progress)
- "Done" (In Progress -> Done)

### Add Comment

Add a comment to a task:

```bash
j4c issue comment PROJ-123 --body="Comment text here"
```

Comment bodies are always parsed as GitHub-flavored markdown.

## When to Use --json

Use `--json` flag when:
- Parsing output programmatically
- Extracting specific fields for further processing
- Chaining commands where structured data helps

For reading and understanding tasks, the default text output is preferred.

## Planning Dependencies

Before creating tasks with dependencies, draw the dependency graph first:

```
BLOCKER -> BLOCKED (arrow points to what depends on it)

Example:
  PROJ-6 (domain types) --> PROJ-13 (mocks)
  PROJ-7 (error handling) --> PROJ-8 (config)
  PROJ-9 (HTTP client) --> PROJ-11 (IssueService CRUD)
```

**Rules:**
1. Foundation tasks (no dependencies) should be done first
2. Only link immediate dependencies, not transitive ones
3. After creating links, run `j4c issue ready` to verify correct tasks are unblocked

## Notes

- **CLI auto-discovers config**: searches `./.jira4claude.yaml` then `~/.jira4claude.yaml`
- **CLI credentials**: reads from `.netrc`
- The CLI handles Atlassian Document Format (ADF) conversion automatically
