---
name: batch-operations
description: Use when performing 3+ similar operations like file edits, searches, or git operations. Triggers on repetitive tasks, "do the same for", loop-like patterns. Enables parallel tool calls and batch-editor delegation.
---

# Batch Operations Skill

**Persona:** Efficiency obsessive - one operation is fine, three identical operations is a code smell.

**Announce at start:** "I'm using the batch-operations skill to process these efficiently."

## Should NOT Attempt

- Batch operations that depend on previous results
- Batch across different file types without validation
- Use batch scripts on untested patterns
- Skip verification after batch changes

## When to Batch

Use batching for 3+ similar operations: file edits, searches, test runs, git operations.

## Batching Strategies

| Strategy | Example |
|----------|---------|
| Parallel Tool Calls | Read file1.py, file2.py, file3.py in same message |
| Chained Bash | `for f in src/*.py; do sed -i 's/old/new/g' "$f"; done` |
| Replace All | `Edit with replace_all: true` |
| batch-editor Agent | `Task(subagent_type=batch-editor, prompt="Rename userId to user_id")` |

## Scripts

```bash
~/.claude/scripts/batch-process.sh items.txt "prompt"
~/.claude/scripts/batch-select.sh 'find . -name "*.py"' 'test' 10
~/.claude/scripts/batch-annotate.sh item1 item2 item3
```

## Batch Indicators

- Third similar operation in a row
- "Now do the same for X"
- Loop in your head ("for each file...")
- Repetitive Edit tool calls

## When NOT to Batch

- Each operation depends on previous result
- Files need different/custom changes
- User wants to review each change
- Operations need individual verification
- Error handling differs per item
- Changes span multiple interdependent systems

## Examples

### Example 1: Rename Variable Across Files
**Task:** Rename `userId` to `user_id` in 8 Python files
**Approach:** batch-editor agent
```
Task(subagent_type=batch-editor, prompt="Rename userId to user_id in src/models/*.py")
```

### Example 2: Read Multiple Config Files
**Task:** Check settings in 4 config files
**Approach:** Parallel tool calls
```
Read(file_path="config/dev.json")
Read(file_path="config/prod.json")
Read(file_path="config/test.json")
Read(file_path="config/local.json")
```
All in same message → parallel execution

### Example 3: Update Import Statements
**Task:** Change `from utils import X` to `from core.utils import X`
**Approach:** Edit with replace_all
```
Edit(file_path="src/main.py", old_string="from utils import", new_string="from core.utils import", replace_all=true)
```
Repeat for each affected file

## Response Schema (for batch results)

When reporting batch results, use this format:
```
Batch: [operation type] on [N] items

Succeeded (N):
- file1.py: [brief result]
- file2.py: [brief result]

Failed (N):
- file3.py: [error reason]

Summary: N/M succeeded
```

## Failure Behavior

On partial batch failure:
1. Complete all possible operations (don't abort on first failure)
2. Report successes and failures separately using schema above
3. For failed items: explain why, suggest fix
4. Ask user: retry failed items, skip them, or abort remaining?

On total failure (0 successes):
1. Stop after 2 consecutive failures
2. Report common failure pattern
3. Suggest checking: permissions, file existence, pattern validity
4. Escalate to manual review

## Escalation Triggers

Use `Task(batch-editor)` instead of manual batching when:
- 5+ files need same change
- Change requires understanding file context
- Pattern-based replacement might have false positives

## Related Skills

- Use **batch-editor** agent for multi-file edits
- **subagent-driven-development**: Parallelize independent work

## Integration

- **batch-editor** agent - For complex multi-file changes requiring context
- **code-reviewer** agent - Review batch changes before committing
- **verification-before-completion** skill - Verify all changes after batch
