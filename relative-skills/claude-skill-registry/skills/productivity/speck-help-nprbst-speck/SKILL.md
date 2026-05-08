---
name: speck-help
description: "Answer questions about Speck specs, plans, tasks, requirements, progress, architecture, user stories, feature status, and constitution. Interprets spec.md, plan.md, tasks.md files. Use when users ask about feature requirements, implementation status, or Speck workflow artifacts."
---

# Speck Workflow Skill

**Purpose**: Automatically interpret Speck specification artifacts (spec.md,
plan.md, tasks.md) and answer natural language questions about features without
requiring explicit slash commands.

**Activation**: This skill activates when users ask questions about Speck
features, mention file types (spec/plan/tasks), or reference Speck concepts
(requirements, user stories, architecture, etc.).

**Scope**: Read-only operations. This skill NEVER modifies files. For creating
or updating files, guide users to appropriate slash commands.

**Additional Resources**:

- **[reference.md](reference.md)** - Detailed interpretation rules, file states,
  error formats
- **[examples.md](examples.md)** - Usage examples showing skill in action
- **[workflows.md](workflows.md)** - Advanced features (multi-repo, worktrees,
  session handoff)

---

## Core Capabilities

### 1. Feature Discovery

When users reference features, use **three-tier matching** to locate the correct
feature directory:

#### Tier 1: Exact Match (Highest Priority)

- Direct directory name match: `specs/005-speck-skill/`

#### Tier 2: Numeric Prefix Match (High Priority)

- User provides feature number (e.g., "005", "5", "feature 003")
- Zero-pad numbers to 3 digits: "5" → "005"
- Match against pattern: `specs/NNN-*/`

#### Tier 3: Fuzzy/Substring Match (Lower Priority)

- User provides partial name (e.g., "skill", "auth", "plugin")
- Filter by case-insensitive substring match
- If multiple matches, ask for clarification

**Disambiguation**: When multiple features match, check conversation context
first. If ambiguous, ask: "Did you mean: 003-user-auth or 012-auth-tokens?"

**Error Handling**: List all available features, use Levenshtein distance for
typo suggestions, explain matching rules.

**Worktree Context**: Worktrees share the same `specs/` directory as main
repository. Feature discovery works identically in worktrees and main repo.

---

### 2. Template References

Speck uses templates in `$PLUGIN_ROOT/templates/` to define expected structure
for artifacts:

**Template Locations**:

- Spec template: `$PLUGIN_ROOT/templates/spec-template.md`
- Plan template: `$PLUGIN_ROOT/templates/plan-template.md`
- Tasks template: `$PLUGIN_ROOT/templates/tasks-template.md`

**When to Reference Templates**:

- User asks "What should go in [section]?" → Extract HTML comments from template
- User asks "Does my [spec/plan/tasks] follow the template?" → Compare against
  template (see [reference.md](reference.md) for workflow)

**Template Structure**: Templates use consistent markdown patterns (H1/H2/H3)
with HTML comments for section purposes and guidelines.

---

### 3. Section Annotation Patterns

**Summary**: Templates use inline annotations to indicate section requirements.

- **Mandatory sections**: `## Section Name *(mandatory)*`
- **Conditional sections**: `## Section Name *(include if...)*`
- **HTML comments**: Provide guidance (ACTION REQUIRED, IMPORTANT, general
  purpose)

**For full details**: See
[reference.md](reference.md#section-annotation-patterns)

---

### 4. File State Classification

Every artifact file can be in one of **five states**:

1. **MISSING** - File doesn't exist → ERROR
2. **EMPTY** - File exists but has no content → ERROR
3. **MALFORMED** - Invalid markdown/structure → WARNING (extract partial info)
4. **INCOMPLETE** - Missing mandatory sections → WARNING (calculate completeness
   %)
5. **VALID** - All mandatory sections present → SUCCESS

**Graceful Degradation**: For MALFORMED and INCOMPLETE states, extract maximum
possible information, return completeness score, list warnings, provide recovery
guidance.

**For full details**: See [reference.md](reference.md#file-state-classification)

---

### 5. Error Message Format

**Summary**: Use structured format with severity, context, and recovery
guidance.

Example:

```
ERROR: Spec Not Found
┌──────────────────────────────────────────────────┐
│ spec.md not found at specs/006-feature/          │
├──────────────────────────────────────────────────┤
│ Recovery: Run /speck.specify "Feature desc"      │
└──────────────────────────────────────────────────┘
```

**Severity Levels**: ERROR (blocking), WARNING (non-blocking), INFO
(informational)

**For full details and examples**: See
[reference.md](reference.md#error-message-format)

---

### 6. Conversation Context Tracking

**Track**:

- Recently mentioned features (last 5)
- Current feature context
- Implicit references ("it", "that", "the spec")

**Usage**: Resolve implicit references to features discussed earlier in
conversation. Reset context when user explicitly mentions different feature or
after 10+ turns.

---

### 7. Multi-Repo Mode Detection

**Summary**: Detect if project uses multi-repo mode via `.speck/root` symlink.

**Key Concepts**:

- **Detection**: Check for `.speck/root` symlink → multi-repo child repo
- **Child repos**: Share specs/ directory, have local plan.md/tasks.md
- **Root repo**: Contains shared specs/, manages constitution

**Query Examples**:

- "Is this a multi-repo setup?" → Check for symlink
- "What's the parent spec?" → Read metadata from spec.md

**For full details**: See [workflows.md](workflows.md#multi-repo-mode-detection)

---

### 8. Worktree Mode Detection

**Summary**: Detect Git worktree integration for isolated parallel development.

**Key Concepts**:

- **Detection**: Check `.speck/config.json` for `worktree.enabled: true`
- **Metadata**: `.speck/worktrees/<branch>.json` tracks worktree associations
- **File rules**: Configuration files copied, dependencies symlinked
- **IDE auto-launch**: VSCode/Cursor/JetBrains launch automatically

**Query Examples**:

- "Is this in a worktree?" → Check metadata or git worktree list
- "What's the worktree config?" → Read config.json

**For full details**: See [workflows.md](workflows.md#worktree-mode-detection)

---

### 9. Session Handoff

**Summary**: Automatic context transfer when creating new feature worktrees.

**Key Concepts**:

- **Handoff document**: `.speck/handoff.md` written to new worktrees
- **SessionStart hook**: Automatically loads handoff context when Claude session
  starts
- **Self-cleanup**: Hook archives handoff after loading and removes itself from
  settings
- **Context transfer**: Feature context, spec location, and pending tasks
  transferred to new session

**How It Works**:

1. When `/speck.specify` creates a new worktree, it writes `.speck/handoff.md`
2. It also configures `.claude/settings.json` with a SessionStart hook
3. When a new Claude session starts in the worktree, the hook fires
4. The hook reads handoff.md and injects context via
   `hookSpecificOutput.additionalContext`
5. After loading, the hook archives the handoff file and removes itself

**Query Examples**:

- "What's in the handoff document?" → Read `.speck/handoff.md` in worktree
- "Did the session handoff work?" → Check for `.speck/handoff.done.md`
  (archived)
- "How do I create a feature with handoff?" → Use
  `/speck.specify "Feature description"`

**Handoff Document Contents**:

- Feature name and spec location
- Repository context (single/multi-repo mode)
- Pending implementation tasks
- Relevant file paths and references

---

## Artifact Interpretation Quick Reference

**For detailed artifact interpretation** (metadata blocks, mandatory sections,
parsing rules), see
[reference.md](reference.md#artifact-specific-interpretation).

**spec.md**: Requirements, user stories, success criteria **plan.md**:
Implementation approach, technical context, constitution check **tasks.md**:
Task breakdown, dependencies, checkpoints

---

## Limitations

**Read-Only Operations**: This skill NEVER modifies files. For creating or
updating Speck artifacts:

- Creating specs: `/speck.specify "Feature description"`
- Clarifying specs: `/speck.clarify`
- Generating plans: `/speck.plan`
- Generating tasks: `/speck.tasks`
- Creating checklists: `/speck.checklist`
- Analyzing consistency: `/speck.analyze`

**Non-Destructive Constraint**:

- Only reads existing files
- Never writes, modifies, or deletes files
- Never runs external commands or tools
- Provides guidance to appropriate slash commands when modifications needed

**Activation Limitations**: Skill may not activate if query is too vague, about
non-Speck topics, or doesn't establish feature context.

---

## Troubleshooting Activation Issues

**Issue: Too Vague** ❌ "What's left?" ✅ "What tasks are left for feature 005?"

**Issue: No Speck Context** ❌ "Show me the plan" ✅ "Show me plan.md for the
speck skill"

**Issue: Wrong Topic** ❌ "How do I implement this in TypeScript?" ✅ "What's
the technical approach in the plan for feature 005?"

**Best Practices**:

1. Mention feature explicitly (number or name)
2. Use Speck terminology (spec, plan, tasks, requirements)
3. Be specific about file types
4. Establish context first

---

## Slash Command Reference

This skill is for **reading and understanding** existing Speck artifacts. When
users need to **create or modify** files, guide them to these slash commands:

| Command            | Purpose                                                                  | Example Trigger Phrase                                            |
| ------------------ | ------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| `/speck.specify`   | Create or update feature specification (with optional worktree creation) | "Run /speck.specify to create a new spec"                         |
| `/speck.clarify`   | Resolve ambiguities and add missing sections                             | "Run /speck.clarify to resolve [NEEDS CLARIFICATION] markers"     |
| `/speck.plan`      | Generate implementation plan from spec                                   | "Run /speck.plan to create the implementation plan"               |
| `/speck.tasks`     | Generate actionable task breakdown                                       | "Run /speck.tasks to create a task list"                          |
| `/speck.analyze`   | Check cross-artifact consistency and quality                             | "Run /speck.analyze to validate spec/plan/tasks consistency"      |
| `/speck.implement` | Execute tasks from tasks.md                                              | "Run /speck.implement to start implementation"                    |
| `/speck.link`      | Link child repository to multi-repo root                                 | "Run /speck.link ../root to connect this repo to multi-repo root" |
| `/speck.init`      | Install Speck CLI globally via symlink                                   | "Run /speck.init to install the speck command"                    |
| `/speck.help`      | Load speck-help skill for natural language questions                     | "Run /speck.help to ask questions about Speck"                    |
| `/speck.env`       | Check Speck environment and configuration                                | "Run /speck.env to see current repo mode (single/multi-repo)"     |

**Worktree Flags for `/speck.specify`**:

- `--no-worktree`: Skip worktree creation
- `--no-ide`: Skip IDE auto-launch
- `--no-deps`: Skip dependency installation
- `--reuse-worktree`: Reuse existing worktree if present

**When to Suggest Commands**:

- **Missing spec.md** → Suggest `/speck.specify "Feature description"`
- **[NEEDS CLARIFICATION] markers** → Suggest `/speck.clarify`
- **Missing plan.md** → Suggest `/speck.plan`
- **Missing tasks.md** → Suggest `/speck.tasks`
- **Incomplete sections** → Suggest `/speck.clarify` or manual editing
- **After clarification** → Suggest `/speck.analyze` to check consistency
- **After task generation** → Suggest `/speck.implement` to execute tasks

**For complete command list**: Direct users to type `/help` in Claude Code.

---

## Plugin Extensibility

Speck follows a modular architecture where specialized capabilities are
delivered as optional plugins. This keeps the core Speck plugin focused on
specification workflows while enabling extensions for related tasks.

### Available Plugins

| Plugin             | Command    | Purpose                                                             |
| ------------------ | ---------- | ------------------------------------------------------------------- |
| **speck**          | `/speck.*` | Core specification workflow (specify, plan, tasks, implement)       |
| **speck-reviewer** | `/review`  | AI-assisted PR review with cluster analysis and Speck-aware context |

### Installing Extension Plugins

All Speck plugins are installed through the Claude Code plugin system:

```bash
# Install speck-reviewer for PR reviews
/plugin install speck-reviewer@speck-market
```

### speck-reviewer Plugin

The speck-reviewer plugin adds structured PR review capabilities:

- **Cluster-Based Review**: Groups related files for coherent review sessions
- **Speck-Aware Context**: References spec requirements when available
- **Comment Management**: Stage, refine, and batch-post review comments
- **Session Persistence**: Resume interrupted reviews

**When to use**: Use `/speck-reviewer:review` after creating a PR for a Speck
feature. The plugin will automatically load any spec context for your branch.

**Learn more**: See
[plugin documentation](https://beta.speck.codes/docs/plugins/speck-reviewer) for
full usage guide.

---

## Summary

This skill enables natural language interaction with Speck workflow artifacts:

- ✅ Automatically activates when users ask about features
- ✅ Interprets spec.md (requirements, user stories, success criteria)
- ✅ Interprets plan.md (technical approach, architecture, constitution)
- ✅ Interprets tasks.md (status, dependencies, progress)
- ✅ Compares files against templates
- ✅ Handles incomplete/malformed files gracefully
- ✅ Provides actionable recovery guidance
- ✅ Maintains conversation context for follow-up questions
- ✅ Read-only operations (non-destructive)

**Additional Resources**:

- **[reference.md](reference.md)** - Detailed rules, workflows, edge cases
- **[examples.md](examples.md)** - Usage examples
- **[workflows.md](workflows.md)** - Advanced features (multi-repo, worktrees,
  session handoff)

**Goal**: Reduce need for manual file reading and slash command usage by 80%,
enabling developers to ask natural questions and get accurate answers about
their Speck features.
