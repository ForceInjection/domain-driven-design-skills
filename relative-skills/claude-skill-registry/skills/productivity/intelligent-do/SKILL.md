---
name: intelligent-do
description: |
  Context-aware task execution with Serena MCP backend. First time: Explores project, saves to Serena,
  runs spec if complex, executes waves. Returning: Loads from Serena (<1s), detects changes, executes
  with cached context. Intelligently decides when to research, when to spec, when to prime. One catch-all
  intelligent execution command. Use when: User wants task executed in any project (new or existing).

skill-type: PROTOCOL
shannon-version: ">=5.0.0"
complexity-triggers: [0.00-1.00]

invoked-by-commands:
  - /shannon:do

related-commands:
  - /shannon:exec: Structured execution with library discovery + validation
  - /shannon:task: Meta-command that orchestrates prime→spec→wave
  - /shannon:wave: Direct wave execution for parallel work

command-orchestration: |
  This skill is invoked by /shannon:do, which is the RECOMMENDED default for general task execution.

  WHEN TO USE /shannon:do (this skill):
  - General task execution in any project
  - Auto-detection of complexity, research needs, context
  - Both new and existing projects
  - Simple to complex tasks

  WHEN TO USE ALTERNATIVES:
  - /shannon:exec: When you want explicit library discovery + 3-tier validation + git commits
  - /shannon:task: When you want full automation (prime→spec→wave) from specification
  - /shannon:wave: When you already have spec analysis and just need parallel execution

  See docs/COMMAND_ORCHESTRATION.md for complete decision trees.

mcp-requirements:
  required:
    - name: serena
      version: ">=2.0.0"
      purpose: Persistent context backend for project memory
      fallback: ERROR - Cannot operate without Serena
      degradation: critical
  recommended:
    - name: sequential
      purpose: Deep analysis for complex decisions
    - name: context7
      purpose: Framework documentation lookup
    - name: tavily
      purpose: Library and best practice research

required-sub-skills:
  - wave-orchestration
  - memory-coordination

optional-sub-skills:
  - spec-analysis
  - mcp-discovery
  - goal-management
  - context-preservation

allowed-tools: [Read, Write, Bash, TodoWrite, AskUserQuestion, Serena, SlashCommand, Sequential, Context7, Tavily]
---

# Intelligent Do

## Purpose

Comprehensive intelligent task execution that automatically handles all scenarios: new projects, existing codebases, simple tasks, complex requirements, first-time work, and returning workflows - all with Serena MCP as the persistent context backend.

**Core Innovation**: One command that adapts to any scenario without configuration, learns from every execution, and gets faster on return visits.

---

## Workflow

### Step 1: Context Detection Using Serena

**Check if project exists in Serena memory**:

1. Determine project ID from current working directory:
   - Get current path: Use Bash tool to run `pwd`
   - Extract project name: Last component of path
   - Sanitize for memory key: Replace special characters with underscores

2. Check Serena for existing project memory:
   - Use Serena tool: `list_memories()`
   - Search for key: `"shannon_project_{project_id}"`
   - If key found → RETURNING_WORKFLOW
   - If key not found → FIRST_TIME_WORKFLOW

**Duration**: < 1 second

---

### Step 2a: FIRST_TIME_WORKFLOW

**For projects not yet in Serena**:

#### Sub-Step 1: Determine Project Type

Count files in current directory to determine if new or existing project:

```bash
# Use Bash tool
find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.tsx" -o -name "*.java" -o -name "*.go" \) | wc -l
```

- If count < 3: NEW_PROJECT (greenfield)
- If count >= 3: EXISTING_PROJECT (has codebase)

#### Sub-Step 2: NEW_PROJECT Path

For greenfield projects (empty or minimal files):

1. **Assess Task Complexity**:
   - Count words in task description
   - Count requirements (lines starting with -)
   - If task has 20+ words OR 3+ requirements → Complex task
   - If task mentions "system", "platform", "integrate" → Complex task

2. **For Complex Tasks - Run Spec Analysis**:
   ```
   Invoke sub-skill:
   @skill spec-analysis
   Specification: {task_description}
   ```
   - This will analyze complexity (8D score)
   - Create phase plan
   - Save results to Serena automatically
   - Use those results for wave execution

3. **For Simple Tasks - Skip Spec**:
   - Proceed directly to wave execution
   - No need for formal analysis

4. **Execute Task**:
   ```
   Invoke sub-skill:
   @skill wave-orchestration
   Task: {task_description}
   Spec: {spec_analysis_results if complex}
   ```

5. **Save Project to Serena**:
   ```
   Use Serena tool:
   write_memory("shannon_project_{project_id}", {
     project_path: "{full_path}",
     created: "{ISO_timestamp}",
     type: "NEW_PROJECT",
     initial_task: "{task_description}",
     complexity: "{simple|complex}",
     spec_id: "{spec_analysis_id if complex}"
   })
   ```

6. **Save Execution Results**:
   ```
   Use Serena tool:
   write_memory("shannon_execution_{timestamp}", {
     project_id: "{project_id}",
     task: "{task_description}",
     files_created: [list of files from wave results],
     duration_seconds: {duration},
     success: true,
     timestamp: "{ISO_timestamp}"
   })
   ```

#### Sub-Step 3: EXISTING_PROJECT Path

For projects with existing codebase:

1. **Explore Project Structure**:
   - Use Read tool to read: README.md, package.json, pyproject.toml, requirements.txt
   - Use Bash tool to find: `find . -name "*.py" | head -20` (sample files)
   - Use Grep tool to search: Look for main entry points, app initialization

2. **Detect Tech Stack**:
   From files found:
   - If package.json exists → Node.js/JavaScript
   - If pyproject.toml or requirements.txt → Python
   - If pom.xml → Java
   - If go.mod → Go
   - If Podfile → iOS/Swift

   Extract specific frameworks from file contents:
   - package.json dependencies → React, Express, Next.js, etc.
   - requirements.txt → Flask, Django, FastAPI, etc.

3. **Detect Validation Gates**:
   From package.json:
   - Look for "scripts" section
   - Extract "test", "build", "lint" commands

   From pyproject.toml:
   - Look for [tool.pytest], [tool.ruff] sections
   - Default gates: pytest, ruff check

4. **Research Decision**:
   Check if task mentions libraries NOT in current dependencies:
   - Parse task for library names (common libraries list)
   - Compare against detected dependencies
   - If new library found → Need research

5. **If Research Needed**:
   ```
   For each new library:
   - Use Tavily tool: Search "{library_name} best practices guide"
   - Use Context7 tool: Get library documentation if available
   - Save research to Serena:
     write_memory("shannon_research_{library}_{timestamp}", {
       library: "{library_name}",
       project_id: "{project_id}",
       best_practices: "{tavily_results}",
       documentation: "{context7_results}",
       timestamp: "{ISO_timestamp}"
     })
   ```

6. **Complexity Assessment**:
   - Simple task (< 12 words, starts with "create" or "add") → Skip spec
   - Complex task (multiple requirements, "system", "integrate") → Run spec

7. **Execute with Context**:
   ```
   Invoke sub-skill:
   @skill wave-orchestration
   Task: {task_description}
   Project Context:
     - Tech Stack: {detected_tech_stack}
     - Entry Points: {main_files}
     - Validation Gates: {detected_gates}
   Research: {research_results if any}
   Spec: {spec_analysis if complex}
   ```

8. **Save Project Context to Serena**:
   ```
   Use Serena tool:
   write_memory("shannon_project_{project_id}", {
     project_path: "{full_path}",
     explored: "{ISO_timestamp}",
     type: "EXISTING_PROJECT",
     tech_stack: [list of detected technologies],
     file_count: {file_count},
     entry_points: [list of main files],
     validation_gates: {
       test: "{test_command}",
       build: "{build_command}",
       lint: "{lint_command}"
     }
   })
   ```

9. **Save Execution**:
   ```
   Use Serena tool:
   write_memory("shannon_execution_{timestamp}", {
     project_id: "{project_id}",
     task: "{task_description}",
     files_created: [list from wave results],
     research_performed: {true|false},
     spec_analysis_ran: {true|false},
     duration_seconds: {duration},
     success: true,
     timestamp: "{ISO_timestamp}"
   })
   ```

---

### Step 2b: RETURNING_WORKFLOW

**For projects with Serena context**:

1. **Load Project Context from Serena**:
   ```
   Use Serena tool:
   const projectContext = read_memory("shannon_project_{project_id}")
   ```

   Extract:
   - tech_stack: List of technologies
   - file_count: Previous file count
   - entry_points: Main files
   - validation_gates: Test/build/lint commands
   - explored: Last exploration timestamp

2. **Check Context Currency**:
   - Parse explored timestamp
   - Calculate age in hours: (now - explored) / 3600
   - If age > 24 hours → Context may be stale

3. **Detect Changes**:
   ```bash
   # Use Bash tool
   current_file_count=$(find . -name "*.py" -o -name "*.js" -o -name "*.tsx" | wc -l)
   ```

   - Calculate change percentage: abs(current - cached) / cached * 100
   - If change > 5% → Codebase changed

4. **Update Context if Changed**:
   If changes detected OR context stale:
   - Re-read key files (README, package.json)
   - Re-count files
   - Update Serena memory:
     ```
     Use Serena tool:
     write_memory("shannon_project_{project_id}", {
       ...existing_context,
       file_count: {current_count},
       updated: "{ISO_timestamp}"
     })
     ```
   - Display: "Codebase changed - updated context"

5. **Load Context if Fresh**:
   If no changes:
   - Use cached context as-is
   - Display: "Using cached context (< 1s)"

6. **Research Decision** (same as first-time):
   - Check if task mentions new libraries
   - Compare against context.tech_stack
   - Research if new libraries found

7. **Complexity Decision**:
   - Simple task → Direct wave execution
   - Complex task → Run spec-analysis first

8. **Execute with Cached Context**:
   ```
   Invoke sub-skill:
   @skill wave-orchestration
   Task: {task_description}
   Cached Context:
     - Tech Stack: {context.tech_stack}
     - Validation Gates: {context.validation_gates}
   Research: {if performed}
   Spec: {if complex}
   ```

9. **Save Execution to Serena**:
   ```
   Use Serena tool:
   write_memory("shannon_execution_{timestamp}", {
     project_id: "{project_id}",
     task: "{task_description}",
     used_cache: true,
     context_age_hours: {age},
     files_created: [list],
     timestamp: "{ISO_timestamp}"
   })
   ```

---

## Anti-Rationalization

### Rationalization 1: "Simple task, skip Serena check"

**COUNTER**:
- ❌ NEVER skip Serena check
- ✅ Check takes <100ms via list_memories()
- ✅ Loading cached context saves 2-5 minutes on return
- ✅ Even "simple" tasks benefit from validation gates knowledge

**Rule**: Always check Serena first. Every time.

### Rationalization 2: "Project looks new, skip file exploration"

**COUNTER**:
- ❌ NEVER assume without checking
- ✅ File count check takes 1 second
- ✅ Wrong assumption = wrong execution context
- ✅ Exploration takes 10-30s, prevents hours of misaligned work

**Rule**: Check file count. Explore if files exist.

### Rationalization 3: "User knows libraries, skip research"

**COUNTER**:
- ❌ NEVER skip research when detecting new external libraries
- ✅ Research takes 30-60s, provides best practices
- ✅ User knowledge + framework patterns = better quality
- ✅ Prevents hours of debugging wrong implementation patterns

**Rule**: If external library detected in task but not in project dependencies, research it.

---

## Serena Memory Key Patterns

**Project Context**:
- Key: `"shannon_project_{project_id}"`
- Data: `{project_path, tech_stack, file_count, validation_gates, explored, type}`

**Execution History**:
- Key: `"shannon_execution_{timestamp}"`
- Data: `{project_id, task, files_created, duration, success, timestamp}`

**Research Results**:
- Key: `"shannon_research_{library}_{timestamp}"`
- Data: `{library, best_practices, documentation, timestamp}`

**Spec Analysis** (when complex):
- Key: `"spec_analysis_{timestamp}"`
- Data: `{complexity_score, domain_percentages, phase_plan, ...}` (from spec-analysis skill)

---

## Examples

### Example 1: New Empty Project

```
User: /shannon:do "create authentication system using Auth0"
Working Directory: /tmp/new-auth-app/

Execution:
1. list_memories() → No "shannon_project_new-auth-app"
2. File count: 0 → NEW_PROJECT
3. Task assessment: "authentication system" (complex) → Run spec-analysis
4. Research: "Auth0" detected → Research Auth0 integration patterns
5. Execute: wave-orchestration with spec + research
6. Save: write_memory("shannon_project_new-auth-app", {...})
7. Save: write_memory("shannon_execution_{timestamp}", {...})

Result: Authentication system created, context saved for next time
Time: 5-8 minutes
```

### Example 2: Existing Project - First Time

```
User: /shannon:do "add password reset endpoint"
Working Directory: /projects/my-flask-api/

Execution:
1. list_memories() → No "shannon_project_my-flask-api"
2. File count: 45 → EXISTING_PROJECT
3. Explore: Read app.py, requirements.txt → Detect Python/Flask
4. Validation gates: Found pytest in pyproject.toml
5. Task: Simple ("add endpoint") → Skip spec
6. Research: None (internal feature)
7. Execute: wave-orchestration with Flask context
8. Save project: write_memory("shannon_project_my-flask-api", {tech_stack: ["Python/Flask"], ...})
9. Save execution: write_memory("shannon_execution_{timestamp}", {...})

Result: Endpoint added, project context cached
Time: 3-5 minutes
```

### Example 3: Returning - Cached Context

```
User: /shannon:do "add email verification"
Working Directory: /projects/my-flask-api/

Execution:
1. list_memories() → Found "shannon_project_my-flask-api" ✓
2. read_memory("shannon_project_my-flask-api") → Load tech_stack, validation_gates
3. Check age: 2 hours old → Fresh
4. File count: 45 files (same) → No changes
5. Display: "Using cached context (< 1s)"
6. Task: Simple → Skip spec
7. Research: None needed
8. Execute: wave-orchestration with loaded context
9. Save execution: write_memory("shannon_execution_{timestamp}", {...})

Result: Feature added using cached context
Time: 2-3 minutes (vs 5 first time)
Speedup: 2x faster
```

---

## Integration with Shannon CLI

Shannon CLI invokes this skill via Agent SDK:

```python
# In Shannon CLI unified_orchestrator.py
async for msg in self.sdk_client.invoke_skill(
    skill_name='intelligent-do',
    prompt_content=f"Task: {task}"
):
    # Skill handles all intelligence via Serena
    # CLI wraps with V3 features (cost optimization, analytics, dashboard)
```

**Division of Responsibilities**:

**intelligent-do Skill Provides** (Shannon Framework):
- Context detection and loading (Serena MCP)
- Research integration (Tavily, Context7)
- Spec analysis decision (when to run)
- Validation gate detection
- Wave execution coordination

**Shannon CLI Provides** (Platform Features):
- Cost optimization (model selection)
- Analytics tracking (session history)
- Dashboard streaming (WebSocket events)
- Local CLI interface

**Together**: Complete intelligent execution platform

---

## Testing Requirements

**Use functional-testing Skill Patterns**:

1. Test with sub-agents using Task tool
2. Validate Serena memory operations:
   - Context saved correctly
   - Context loaded correctly
   - Keys follow naming convention
3. Test scenarios:
   - New empty project
   - Existing project first time
   - Returning to project
   - Research integration
   - Complex task with spec

**Evidence Required**:
- Serena memories created (list_memories() output)
- Files created in correct locations
- Timing comparison (first vs return)
- Research results when libraries detected

---

**Status**: Skill template ready for proper implementation following Shannon patterns
