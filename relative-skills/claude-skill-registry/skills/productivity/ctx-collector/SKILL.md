---
name: ctx-collector
description: Scan and aggregate task checkboxes from Speckit (.specify/) and context-planning (specs/) formats into a unified backlog.yaml, with automatic project context analysis and auto-update capabilities.
---

# ctx-collector

## Purpose

Aggregate task checkboxes from multiple task file formats across project repositories and maintain comprehensive project context reports. This skill operates in "no-clone mode"—it only reads from existing local directories under `projects/`, making it safe and fast for continuous scanning.

**Key Features:**
- **Multi-format support**: `.specify/` (Speckit) and `specs/` (context-planning) directories
- **Project context analysis**: Automatic tech stack, structure, and dependency extraction
- **Auto-update system**: Git hooks keep project reports synchronized
- **Priority detection**: `P1/P2/P3` and `[P]` (Speckit) formats

## When to Use This Skill

Use this skill when:
- The user requests to scan tasks across projects (e.g., `/ctx.scan`)
- Building or refreshing the project backlog before planning
- Collecting task status updates from multiple repositories
- Needing a unified view of all open and completed tasks

Do not use this skill when:
- Working with a single project's tasks directly
- The user wants to modify tasks (this skill only reads)
- Projects are not structured under `context/projects/`

## How It Works

### Task Collection Process

1. **Discover task files** recursively in `projects/` directory:
   - **Speckit format**: `.specify/` directories with task files
   - **Context-planning format**: `specs/` directories with `tasks.md`
   - Optional: `checklists/**/*.md` files (if configured)
   - Works with any project structure you prefer

2. **Parse checkboxes** from discovered files:
   - Open tasks: `- [ ] Task description`
   - Completed tasks: `- [X] Task description` or `- [x] Task description`

3. **Extract metadata** from task lines and headings:
   - Task ID: Pattern `T\d+` (e.g., T101, T250)
   - Priority: `P1|P2|P3` or `[P]` (Speckit format, treated as P1)
   - Scope: Last two heading levels as context
   - File location and line number for traceability

### Project Context Analysis

The skill also includes `scripts/analyze_project.py` for comprehensive project analysis:

1. **Overview**: Extract project name and description from README/pyproject.toml
2. **Tech Stack**: Detect languages and frameworks (Python, JavaScript/TypeScript, Rust)
3. **Structure**: Analyze directory organization and key files
4. **Entry Points**: Identify CLI commands and main modules
5. **Specs**: Detect Speckit or context-planning task specifications
6. **Tests**: Discover test frameworks and coverage tools
7. **Documentation**: Index markdown and RST documentation files

Results are saved to `reports/projects/` as both Markdown and JSON files.

### Auto-Update System

Git hooks automatically update project contexts on changes:

- **post-commit**: Updates changed projects after local commits
- **post-merge**: Updates changed projects after `git pull`
- **post-checkout**: Updates when switching branches

Install hooks with: `bash scripts/install_hooks.sh`

See `docs/AUTO_UPDATE.md` for detailed documentation.

4. **Generate unified backlog** at `state/backlog.yaml` with structure:
   ```yaml
   generated_at: "ISO-8601 timestamp"
   items:
     - uid: "my-project#T101"
       project: "my-project"
       file: "projects/my-project/specs/tasks.md"
       line: 42
       id: "T101"
       title: "Task description"
       priority: "P1"
       status: "open"
       scope:
         section: "Feature Name"
         subsection: "Phase 1"
   ```

**Note:** Project names are derived from the directory structure automatically.

### Using the Bundled Scripts

The skill includes two main scripts:

**1. Task Scanner** (`scripts/scan_tasks.py`):
```bash
# Scan all tasks across projects
python3 skills/ctx-collector/scripts/scan_tasks.py --verbose
```

The scanner automatically:
- Scans both `.specify/` and `specs/` directories
- Supports `P1/P2/P3` and `[P]` priority formats
- Handles missing YAML library (falls back to JSON)
- Generates unique IDs for tasks without explicit IDs
- Creates `state/` directory if needed
- Overwrites `state/backlog.yaml` with fresh scan

**2. Project Analyzer** (`scripts/analyze_project.py`):
```bash
# Analyze a specific project
python3 skills/ctx-collector/scripts/analyze_project.py \
  projects/my-org/my-project \
  --output reports/projects/my-project.md

# Or use the auto-update system
bash scripts/update_project_contexts.sh manual
```

The analyzer automatically:
- Extracts tech stack and dependencies
- Maps directory structure
- Finds entry points and CLI commands
- Detects test frameworks
- Indexes documentation
- Outputs both Markdown and JSON reports

### Task ID and UID Generation

- **Explicit IDs**: Tasks with `T\d+` pattern use that as ID
- **Implicit UIDs**: Tasks without IDs get hash-based UID from `project#path:line:title`
- **Project prefix**: All UIDs include `project#` for cross-project uniqueness

### Priority Detection

Priority is determined in order:
1. **Speckit format**: `[P]` in task line is treated as P1 (highest priority)
2. **Standard format**: `P1|P2|P3` marker in task line (e.g., `- [ ] T101 P1 Fix critical bug`)
3. Priority marker in nearest parent heading
4. Default to `P2` if not specified

**Examples:**
```markdown
- [ ] [P] Critical bug fix        # Treated as P1 (Speckit)
- [ ] T101 P1 High priority task  # P1 (standard)
- [ ] T102 P2 Normal task         # P2 (standard)
- [ ] T103 Regular task           # P2 (default)
```

## Workflow Examples

### Task Scanning (`/ctx.scan`)

1. Verify `projects/` contains your project directories
2. Execute `scripts/scan_tasks.py` or implement inline scanning
3. Report summary: "Scanned X files, found Y tasks (Z open, W done)"
4. Confirm `state/backlog.yaml` has been updated

### Project Analysis (`/ctx.analyze <project>`)

1. Verify project exists in `projects/` directory
2. Execute `scripts/analyze_project.py` for the specific project
3. Generate `reports/projects/<name>.md` and `<name>.json`
4. Update `reports/projects/INDEX.md` with new project entry

### Auto-Update on Git Operations

When you commit, pull, or checkout:
1. Git hook detects changed projects
2. `scripts/update_project_contexts.sh` runs automatically
3. Updated reports are generated for changed projects
4. Deleted projects have their reports removed
5. INDEX.md is regenerated

## Constraints

- **Read-only operation**: Never modifies source task files
- **Local files only**: No network access or git operations
- **No cloning**: Only processes existing local directories
- **Stable output format**: Other skills depend on backlog.yaml structure

## Related Skills

- `ctx-planning`: Consumes `state/backlog.yaml` to generate daily/weekly plans
- Use `/ctx.update` to modify planning parameters in `BaseContext.yaml`

## Troubleshooting

If scanning produces unexpected results, check:
- Task files use proper checkbox syntax: `- [ ]` or `- [X]`
- Task IDs follow `T\d+` pattern (e.g., T1, T100, not task-1)
- Priority markers use `P1`, `P2`, or `P3` format
- Files are UTF-8 encoded
- `state/` directory is writable
