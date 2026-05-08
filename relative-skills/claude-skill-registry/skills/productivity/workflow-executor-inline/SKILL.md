---
name: workflow-executor-inline
description: |
  Inline workflow executor for proxy providers (ZenMux, custom API providers).
  Executes workflow steps directly in the main context WITHOUT spawning Task subagents.

  Use this skill when:
  - Running looplia workflows via ZenMux or other proxy providers
  - Task subagents fail with "invalid_model" errors
  - You need inline execution without context isolation

  Architecture: Each workflow step is executed INLINE (no Task tool) - read skill, execute
  mission, write output, then proceed to next step. All steps share the main context.

  v0.6.6: Created for cross-provider compatibility with ZenMux.
---

# Workflow Executor Inline (v0.6.6)

Execute looplia workflows **without Task subagents**. This skill is specifically designed for proxy providers (ZenMux, custom) where the Claude Agent SDK's subagent spawning doesn't work due to model name incompatibility.

## When to Use

Use this skill when:
- The system has injected a hint to use inline execution
- Running workflows via ZenMux or other proxy providers
- Task subagents fail with "invalid_model" errors

## CRITICAL: Inline Execution (No Subagents)

**DO NOT spawn Task subagents.** Execute all workflow steps directly in the main context.

For each workflow step:

1. **Read the skill definition** using Skill tool: `Skill("{step.skill}")`
2. **Read input file(s)** if specified using Read tool
3. **Execute the mission** following skill instructions
4. **Write JSON output** to specified path using Write tool
5. **Validate output** (if validation rules defined)
6. **Proceed to next step**

---

## Execution Protocol

### Phase 1: Sandbox Setup

Same as standard workflow-executor:

1. Generate sandbox ID:
   ```
   {first-input-name}-{YYYY-MM-DD}-{random4chars}
   Example: video-transcript-2025-12-18-xk7m
   ```

2. Create folder structure:
   ```
   sandbox/{sandbox-id}/
   ├── inputs/
   │   └── {input-files}.md
   ├── outputs/
   ├── logs/
   └── validation.json
   ```

3. Copy input files to `inputs/`

### Phase 2: Workflow Parsing

1. Read workflow file: `workflows/{workflow-id}.md`
2. Parse YAML frontmatter for steps
3. Validate each step has `skill:` and `mission:` fields
4. Build dependency graph from `needs:` fields

### Phase 3: Inline Step Execution

**Execute steps ONE AT A TIME, INLINE (no Task tool):**

```
FOR EACH step in dependency order:
    │
    ▼
┌─────────────────────────────────────────┐
│ 1. INVOKE skill: Skill("{step.skill}")  │
│    → This loads skill context           │
│                                         │
│ 2. READ input file (if provided)        │
│    → Use Read tool                      │
│                                         │
│ 3. EXECUTE mission                      │
│    → Follow skill instructions          │
│    → Generate JSON output               │
│                                         │
│ 4. WRITE output file                    │
│    → Use Write tool                     │
│    → Output to step.output path         │
│                                         │
│ 5. VALIDATE output                      │
│    → Check required_fields              │
│    → Retry if failed (max 2x)           │
│                                         │
│ 6. UPDATE validation.json               │
│    → Mark step as validated: true       │
└─────────────────────────────────────────┘
         │
         ▼
    NEXT STEP
```

### Example: Inline Execution

For step:
```yaml
- id: analyze-content
  skill: media-reviewer
  mission: |
    Deep analysis of video transcript. Extract key themes,
    important quotes, and narrative structure.
  input: ${{ sandbox }}/inputs/content.md
  output: ${{ sandbox }}/outputs/analysis.json
  validate:
    required_fields: [contentId, headline, keyThemes]
```

**Inline execution sequence:**

1. **Invoke skill:**
   ```
   Skill("media-reviewer")
   ```

2. **Read input:**
   ```
   Read("sandbox/video-2025-12-18-xk7m/inputs/content.md")
   ```

3. **Execute mission:**
   - Follow media-reviewer skill instructions
   - Analyze the content
   - Generate structured JSON output

4. **Write output:**
   ```
   Write("sandbox/video-2025-12-18-xk7m/outputs/analysis.json", jsonContent)
   ```

5. **Validate:**
   - Check contentId, headline, keyThemes exist
   - Update validation.json

6. **Proceed to next step**

---

## Anti-Patterns

❌ **WRONG - Spawning Task subagents:**
```json
{
  "subagent_type": "workflow-step",
  "description": "Execute step...",
  "prompt": "..."
}
```
Task subagents don't work with proxy providers.

❌ **WRONG - Batching all steps:**
Execute all steps at once without validation between them.

✅ **CORRECT - Inline step-by-step:**
1. Skill("media-reviewer")
2. Read input
3. Execute mission
4. Write output
5. Validate
6. Proceed to next

---

## Variable Substitution

Same as standard workflow-executor:

| Variable | Resolution |
|----------|------------|
| `${{ sandbox }}` | `sandbox/{sandbox-id}` |
| `${{ inputs.{name} }}` | `sandbox/{id}/inputs/{name}.md` |
| `${{ steps.{id}.output }}` | Output path of step `{id}` |

---

## Error Handling

| Scenario | Action |
|----------|--------|
| Workflow not found | Error with available workflows |
| Step missing `skill:` | Error: "Step missing required 'skill' field" |
| Step missing `mission:` | Error: "Step missing required 'mission' field" |
| Validation fails | Retry inline with feedback (max 2 retries) |
| Max retries exceeded | Report failure with details |

---

## Key Differences from Standard workflow-executor

| Aspect | workflow-executor | workflow-executor-inline |
|--------|------------------|--------------------------|
| Execution | Task subagent per step | Inline in main context |
| Context | Isolated per step | Shared main context |
| Provider Support | Anthropic Direct only | All providers |
| Use Case | Production (Anthropic) | Proxy providers (ZenMux) |

---

## Version History

- **v0.6.6**: Created for ZenMux cross-provider compatibility
