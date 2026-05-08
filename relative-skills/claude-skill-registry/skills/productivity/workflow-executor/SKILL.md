---
name: workflow-executor
description: |
  This skill should be used when the user wants to execute a looplia workflow, run workflow
  steps, or process a workflow.md file. Use when someone says "run the looplia workflow",
  "execute this looplia pipeline", "/run writing-kit", "start the looplia automation", or
  "process these workflow steps".

  Architecture: One workflow step triggers one general-purpose subagent call, which then
  invokes skills to accomplish the step's mission. Each step = separate context window.
  Handles sandbox management, per-step orchestration, and validation state tracking.

  v0.6.9: Unified general-purpose subagent strategy for all providers (context offload).
---

# Workflow Executor Skill (v0.6.9)

Execute looplia workflows defined in `workflows/*.md` files using the skills-first architecture.

## When to Use

Use this skill when:
- Handling `/run` commands
- Executing workflow-as-markdown definitions
- Orchestrating multi-step skill workflows

---

## CRITICAL: Task Invocation with general-purpose Subagent

**v0.6.9:** Using built-in `general-purpose` subagent for ALL workflow steps (all providers).

When executing a step with `skill: {name}` and `mission:`:

```json
{
  "subagent_type": "general-purpose",
  "description": "Execute step: {step.id}",
  "prompt": "Execute skill '{step.skill}' for step '{step.id}'.\n\n## Mission\n{step.mission}\n\n## Execution Protocol\n1. Read input files (if provided)\n2. Invoke the skill using Skill tool\n3. Execute the mission with skill context\n4. Write JSON output to the specified path using Write tool\n\n## CRITICAL: Output Writing is MANDATORY\nYOU MUST CALL THE WRITE TOOL before completing. If you don't write the file, the workflow fails.\n\n## Rules\n- ALWAYS invoke the specified skill using Skill tool\n- ALWAYS write output to the exact path using Write tool\n- NEVER return results as text - always write JSON to output file\n- NEVER spawn Task subagents - execute skills directly\n- ALWAYS include contentId in JSON outputs\n\nInput: {resolved input path}\nOutput: {step.output}\nValidation: {step.validate JSON}"
}
```

**Example:**
```yaml
- id: analyze-content
  skill: media-reviewer
  mission: |
    Deep analysis of video transcript. Extract key themes,
    important quotes, and narrative structure.
  input: ${{ sandbox }}/inputs/content.md
  output: ${{ sandbox }}/outputs/analysis.json
```

**Task tool call:**
```json
{
  "subagent_type": "general-purpose",
  "description": "Execute step: analyze-content",
  "prompt": "Execute skill 'media-reviewer' for step 'analyze-content'.\n\n## Mission\nDeep analysis of video transcript. Extract key themes, important quotes, and narrative structure.\n\n## Execution Protocol\n1. Read input files (if provided)\n2. Invoke the skill using Skill tool\n3. Execute the mission with skill context\n4. Write JSON output to the specified path using Write tool\n\n## CRITICAL: Output Writing is MANDATORY\nYOU MUST CALL THE WRITE TOOL before completing. If you don't write the file, the workflow fails.\n\n## Rules\n- ALWAYS invoke the specified skill using Skill tool\n- ALWAYS write output to the exact path using Write tool\n- NEVER return results as text - always write JSON to output file\n- NEVER spawn Task subagents - execute skills directly\n- ALWAYS include contentId in JSON outputs\n\nInput: sandbox/video-2025-01-15-abc123/inputs/content.md\nOutput: sandbox/video-2025-01-15-abc123/outputs/analysis.json\nValidation: {\"required_fields\":[\"contentId\",\"headline\",\"keyThemes\"]}"
}
```

### Rules

- **ALWAYS** use `subagent_type: "general-purpose"` for ALL workflow steps
- **NEVER** use custom subagent_type per step (removed in v0.6.1)
- **VALIDATE** that step has both `skill:` and `mission:` fields
- **REJECT** steps using deprecated `run:` syntax

### Why Per-Step Task Calls (Context Isolation)

Each `Task(general-purpose)` creates a **separate context window**:
- Isolates step processing from main agent context
- Prevents context pollution across steps
- Enables focused execution with only relevant inputs

**NEVER batch multiple steps** - this defeats context isolation.

### Anti-Patterns

❌ **WRONG - Delegating entire workflow:**
```json
{
  "description": "Execute workflow: writing-kit",
  "prompt": "Run all workflow steps..."
}
```
This pollutes the subagent context with ALL steps.

✅ **CORRECT - One step per Task:**
```json
{
  "description": "Execute step: summary",
  "prompt": "Execute skill 'media-reviewer' for step 'summary'..."
}
```
Each step gets a fresh, focused context window.

---

## Step Field Validation (v0.6.3)

Before executing a step, validate:

| Field | Required | Error if Missing |
|-------|----------|------------------|
| `skill` | **Yes** | "Step '{id}' missing required 'skill' field" |
| `mission` | **Yes** | "Step '{id}' missing required 'mission' field" |
| `input` | **Conditional** | Required unless skill is input-less capable (e.g., `search`) |
| `output` | **Yes** | "Step '{id}' missing required 'output' field" |
| `run` | **FORBIDDEN** | "Step '{id}' uses deprecated 'run:' syntax. Migrate to 'skill:' + 'mission:'" |

### Input-less Capable Skills

These skills can operate without an `input` field:
- `search` - Executes search missions autonomously

Example input-less step:
```yaml
- id: find-news
  skill: search
  mission: |
    Search Hacker News for today's top 3 AI stories.
    Extract title, URL, points, and brief summary.
  output: ${{ sandbox }}/outputs/news.json
  # No input field - search operates autonomously
```

---

## Execution Protocol

### Phase 1: Sandbox Setup

**New Sandbox with Named Inputs** (v0.6.3 - when `--input` provided):

1. Generate sandbox ID:
   ```
   {first-input-name}-{YYYY-MM-DD}-{random4chars}
   Example: video-transcript-2025-12-18-xk7m
   ```

2. Create folder structure:
   ```
   sandbox/{sandbox-id}/
   ├── inputs/
   │   ├── video-transcript.md  # Named input files
   │   └── user-notes.md
   ├── outputs/             # Step outputs go here
   ├── logs/                # Session logs
   └── validation.json      # Validation state
   ```

3. Copy each input file to `inputs/{name}.md`

**New Sandbox with Single File** (legacy - when `--file` provided):

1. Generate sandbox ID:
   ```
   {content-slug}-{YYYY-MM-DD}-{random4chars}
   Example: my-article-2025-12-18-xk7m
   ```

2. Create folder structure and copy to `inputs/content.md`

**Input-less Sandbox** (v0.6.3 - no inputs required):

For workflows using only input-less capable skills (e.g., `search`):

1. Generate sandbox ID from workflow name:
   ```
   {workflow-slug}-{YYYY-MM-DD}-{random4chars}
   Example: hn-reporter-2025-12-18-xk7m
   ```

2. Create folder structure with empty `inputs/` directory

**Resume Sandbox** (when `--sandbox-id` provided):

1. Verify sandbox exists
2. Load `validation.json` to see completed steps
3. Continue from first incomplete step

### Phase 2: Workflow Parsing

1. Read workflow file: `workflows/{workflow-id}.md`

2. Parse YAML frontmatter:
   ```yaml
   name: workflow-name
   version: 1.0.0
   description: ...
   steps:
     - id: step-one
       skill: skill-name
       mission: |
         Task description...
       input: ...
       output: ...
   ```

3. **Validate each step** has `skill:` and `mission:` (reject `run:`)

4. Build dependency graph from `needs:` fields

### Phase 3: Validation State

**Generate validation.json** (new sandbox):

```json
{
  "workflow": "writing-kit",
  "version": "2.0.0",
  "sandboxId": "article-2025-12-18-xk7m",
  "createdAt": "2025-12-18T10:30:00Z",
  "steps": {
    "analyze-content": {
      "output": "outputs/analysis.json",
      "validated": false
    },
    "generate-ideas": {
      "output": "outputs/ideas.json",
      "validated": false
    },
    "build-writing-kit": {
      "output": "outputs/writing-kit.json",
      "validated": false
    }
  }
}
```

### Phase 4: Dependency Resolution

Compute execution order using topological sort:

```
Input:
  analyze-content: { needs: [] }
  generate-ideas: { needs: [analyze-content] }
  build-writing-kit: { needs: [analyze-content, generate-ideas] }

Computed order: [analyze-content, generate-ideas, build-writing-kit]
```

### Phase 5: Step Execution Loop

**Execute steps ONE AT A TIME (context isolation):**

1. Get first unvalidated step from dependency order
2. Make ONE `Task(general-purpose)` call for THIS step only
3. WAIT for Task completion before proceeding
4. Validate output, update validation.json
5. REPEAT for next unvalidated step
6. STOP when ALL steps are validated

**MANDATORY:** Each step = separate context window = separate Task call.

```
FOR EACH step in dependency order:
    │
    ▼
┌─────────────────────────────────────────┐
│ Check: output exists AND validated?      │
└────────────────┬────────────────────────┘
                 │
         ┌───────┴───────┐
         │               │
         ▼ YES           ▼ NO
    ┌─────────┐    ┌─────────────────────────────┐
    │ SKIP    │    │ 1. INVOKE Task tool:        │
    │ (done)  │    │    subagent_type:           │
    └─────────┘    │      "general-purpose"      │
                   │                              │
                   │ 2. Subagent invokes the      │
                   │    specified skill           │
                   │                              │
                   │ 3. VALIDATE output           │
                   │                              │
                   │ 4. UPDATE validation.json    │
                   │                              │
                   │ 5. IF FAILED: retry (max 2x) │
                   └─────────────────────────────┘
```

### Phase 6: Task Tool Invocation

For step:
```yaml
- id: analyze-content
  skill: media-reviewer
  mission: |
    Deep analysis of video transcript. Extract key themes,
    important quotes with timestamps, and narrative structure.
  input: ${{ sandbox }}/inputs/content.md
  output: ${{ sandbox }}/outputs/analysis.json
  validate:
    required_fields: [contentId, headline, keyThemes]
```

Invoke Task tool:
```json
{
  "subagent_type": "general-purpose",
  "description": "Execute step: analyze-content",
  "prompt": "Execute skill 'media-reviewer' for step 'analyze-content'.\n\n## Mission\nDeep analysis of video transcript. Extract key themes, important quotes with timestamps, and narrative structure.\n\n## Execution Protocol\n1. Read input files (if provided)\n2. Invoke the skill using Skill tool\n3. Execute the mission with skill context\n4. Write JSON output to the specified path using Write tool\n\n## CRITICAL: Output Writing is MANDATORY\nYOU MUST CALL THE WRITE TOOL before completing.\n\n## Rules\n- ALWAYS invoke the specified skill using Skill tool\n- ALWAYS write output to the exact path using Write tool\n- NEVER return results as text - always write JSON to output file\n- ALWAYS include contentId in JSON outputs\n\nInput: sandbox/article-2025-12-18-xk7m/inputs/content.md\nOutput: sandbox/article-2025-12-18-xk7m/outputs/analysis.json\nValidation: {\"required_fields\":[\"contentId\",\"headline\",\"keyThemes\"]}"
}
```

### Phase 7: Validation

After step output is written:

1. Use **workflow-validator** skill
2. Run validation script:
   ```bash
   bun .claude/skills/workflow-validator/scripts/validate.ts \
     sandbox/{id}/outputs/analysis.json \
     '{"required_fields":["contentId","headline","keyThemes"]}'
   ```

3. Parse result:
   ```json
   {
     "passed": true,
     "checks": [
       { "name": "has_contentId", "passed": true }
     ]
   }
   ```

4. If passed: Update `validation.json` with `validated: true`
5. If failed: Retry step with feedback (max 2 retries)

### Phase 8: Return Final Output

When step with `final: true` passes validation:

1. Read final artifact from `sandbox/{id}/outputs/{artifact}`
2. Return structured result:
   ```json
   {
     "status": "success",
     "sandboxId": "article-2025-12-18-xk7m",
     "workflow": "writing-kit",
     "artifact": { ... }
   }
   ```

---

## Variable Substitution (v0.6.9)

Resolve variables before passing to general-purpose subagent:

| Variable | Resolution | Example |
|----------|------------|---------|
| `${{ sandbox }}` | `sandbox/{sandbox-id}` | `sandbox/article-2025-12-18-xk7m` |
| `${{ inputs.{name} }}` | `sandbox/{id}/inputs/{name}.md` | `sandbox/.../inputs/video1.md` |
| `${{ steps.{id}.output }}` | Output path of step `{id}` | `sandbox/.../outputs/analysis.json` |

### Named Inputs (v0.6.3)

Workflows can declare named inputs in their frontmatter:

```yaml
inputs:
  - name: video-transcript
    required: true
    description: The video transcript to analyze
  - name: user-notes
    required: false
    description: Optional user notes
```

Steps reference inputs via `${{ inputs.name }}`:

```yaml
steps:
  - id: analyze
    skill: media-reviewer
    mission: Analyze the video content
    input: ${{ inputs.video-transcript }}
    output: ${{ sandbox }}/outputs/analysis.json
```

CLI provides inputs via `--input`:
```bash
looplia run writing-kit --input video-transcript=video.md --input user-notes=notes.md
```

### Step Output References

```yaml
input: ${{ steps.analyze-content.output }}
# Resolves to: sandbox/article-2025-12-18-xk7m/outputs/analysis.json
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| Workflow not found | Error with available workflows |
| Step uses `run:` syntax | Error: "Migrate to skill: + mission: syntax" |
| Step missing `skill:` | Error: "Step missing required 'skill' field" |
| Step missing `mission:` | Error: "Step missing required 'mission' field" |
| Sandbox not found | Error with suggestion to use --file |
| Step fails | Retry up to 2 times with feedback |
| Validation fails | Provide specific failed checks to skill-executor |
| Max retries exceeded | Report failure with details |

---

## Example Execution Trace

```
/run writing-kit --file article.md

1. [SANDBOX] Created: sandbox/article-2025-12-18-xk7m/
   - inputs/content.md (copied)
   - validation.json (generated)

2. [WORKFLOW] Loaded: workflows/writing-kit.md
   - version: 2.0.0
   - steps: [analyze-content, generate-ideas, build-writing-kit]

3. [VALIDATE] Schema check passed
   - All steps have skill: field ✓
   - All steps have mission: field ✓
   - No deprecated run: syntax ✓

4. [ORDER] Computed: [analyze-content, generate-ideas, build-writing-kit]

5. [STEP] analyze-content
   - Task tool: subagent_type="general-purpose"
   - Skill: media-reviewer
   - Output: outputs/analysis.json
   - Validate: PASSED
   - Update: validation.json (analyze-content.validated = true)

6. [STEP] generate-ideas
   - Task tool: subagent_type="general-purpose"
   - Skill: idea-synthesis
   - Output: outputs/ideas.json
   - Validate: PASSED
   - Update: validation.json (generate-ideas.validated = true)

7. [STEP] build-writing-kit
   - Task tool: subagent_type="general-purpose"
   - Skill: writing-kit-assembler
   - Output: outputs/writing-kit.json
   - Validate: PASSED
   - Update: validation.json (build-writing-kit.validated = true)

8. [COMPLETE] Final output: writing-kit.json
```

---

## File References

- Workflow definitions: `workflows/*.md`
- Subagent: Built-in `general-purpose` agent (v0.6.9)
- Skill definitions: `plugins/*/skills/*/SKILL.md`
- Sandbox storage: `sandbox/{sandbox-id}/`
- Validator script: `.claude/skills/workflow-validator/scripts/validate.ts`
