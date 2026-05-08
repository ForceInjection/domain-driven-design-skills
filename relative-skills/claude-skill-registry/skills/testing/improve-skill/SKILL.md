---
name: improve-skill
description: Iteratively improve an existing skill or command based on feedback
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
---

Iteratively improve an existing skill or command based on feedback, corrections, or identified issues.

## Process

1. **Locate the Component**
   - Search `plugins/*/commands/` and `plugins/*/skills/` for the specified name
   - Read the current instruction file
   - Understand its purpose and current implementation

2. **Gather Context**
   If feedback is provided, analyze it. Otherwise, prompt for:
   - What's not working as expected?
   - What behavior should change?
   - Any specific scenarios that fail?

3. **Analyze Current Instructions**
   Evaluate the existing component for:
   - Clarity of description/trigger documentation
   - Completeness of process steps
   - Coverage of edge cases
   - Robustness of rules
   - Quality of examples

4. **Propose Improvements**
   Based on feedback and analysis, suggest specific changes:
   - Additional process steps
   - New rules to handle edge cases
   - Better examples
   - Clarified language
   - Error handling additions

5. **Present Changes**
   Show a diff-style view of proposed changes:

   ```
   ## Proposed Changes to {component-name}

   ### Addition: New Rule
   + - Handle edge case X by doing Y

   ### Modification: Process Step 3
   - 3. Old step description
   + 3. Improved step description with more detail

   ### Addition: Example
   + ## Example: Edge Case Handling
   + User: `/component-name --edge-case`
   + Result: Handles it gracefully
   ```

6. **Apply or Iterate**
   - If user approves, apply the changes
   - If user has more feedback, incorporate and re-propose
   - Track what was changed for potential rollback

## Arguments

| Argument | Required | Description                             |
| -------- | -------- | --------------------------------------- |
| name     | Yes      | Name of the skill or command to improve |
| feedback | No       | Specific feedback or issues to address  |

## Component Type Assessment

Before improving, verify the component is the right type:

**Commands** (`commands/*.md`) - Use when:

- User should invoke explicitly via `/command-name`
- Needs to appear in autocomplete
- Discrete, user-initiated action (commit, build, test, deploy)
- Format: YAML frontmatter with `name`, `description`, `allowed-tools`

**Skills** (`skills/*/INSTRUCTIONS.md`) - Use when:

- Agent should trigger proactively based on context
- No explicit user invocation needed
- Background behavior or analysis
- Format: Markdown with `## When to Use` description

If a skill should be a command (user-invoked action), recommend converting it.

## Improvement Categories

### Clarity Improvements

- Ambiguous language made specific
- Complex steps broken down
- Jargon explained or removed

### Robustness Improvements

- Edge cases handled
- Error scenarios addressed
- Fallback behaviors defined

### Completeness Improvements

- Missing steps added
- Examples included
- Rules expanded

### Consistency Improvements

- Alignment with other components in the repo
- Standardized formatting
- Consistent terminology

## Example

User: `/improve-skill commit`

Analysis reveals:

- Missing guidance on merge commits
- No example for breaking changes
- Unclear on when to use which commit type

Proposed additions:

```markdown
### Merge Commits

When committing a merge, use the format:
`merge: integrate {branch} into {target}`

### Breaking Changes

For breaking changes, use:
`feat!: description` or `fix!: description`
Include a BREAKING CHANGE footer explaining the impact.
```

## Important Rules

- Always show proposed changes before applying
- Preserve the component's original intent - don't change what it does, just how well it does it
- Make incremental improvements - don't rewrite entire components
- Reference specific feedback when explaining changes
- After applying changes, run `bun run typecheck` and `bun run build` to verify
