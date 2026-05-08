---
name: creating-variants
description: Create team-specific workflow variants by adapting aug marketplace content to existing tools and processes
---

# Creating Team Workflow Variants

Adapt aug marketplace content to team's existing tools and processes.

**Philosophy:** Prescriptive tools adapted to context beat generic tools. Fork aug content, adapt to team reality, maintain opinionated workflows.

## Finding Aug Marketplace Source

**Discovery sequence:**
1. Check `~/.claude/plugins/known_marketplaces.json` for aug location
2. Try common paths: `~/.claude/marketplaces/aug`, `~/aug`, `/opt/aug`
3. Ask user if detection fails

Verify by checking for `$AUG_PATH/aug-dev/commands/plan-chat.md`.

## Discovery Areas

### 1. Git Workflow
**Detect:** `.git/config` (remote URL), `git branch -a` (patterns)

**Key questions:**
- "What branches do releases come from?" (main, develop, release/*)
- "How are features developed?" (feature/*, user/*, TICKET-*)

**Options:** Trunk-based, Gitflow, GitHub Flow, Custom

**Adaptations:** Branch prefixes, PR targets, commit message format

### 2. Issue Tracking
**Detect:** `gh auth status`, `.jira/config`, `.github/`

**Key questions:**
- "Where do you track work?" (GitHub Issues, Jira, Linear, files, none)
- "How do you reference issues in commits?" (#123, PROJ-123, plain text)

**Options:** GitHub Issues, Jira, Linear, File-based, None

**Adaptations:** Issue commands, reference formats, metadata fields

### 3. CI/CD Platform
**Detect:** `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, `.circleci/config.yml`

**Key questions:**
- "What triggers CI?" (push, PR, manual dispatch)
- "What must pass before merge?" (tests, lint, coverage threshold)

**Adaptations:** CI config generation, quality check integration

### 4. Build Tool
**Detect:** `justfile`, `Makefile`, `package.json`, `pom.xml`, `build.gradle`

**Key questions:**
- "What runs your builds?" (just, make, npm, gradle, maven)
- "What quality gates are missing?" (coverage, complexity, security)

**Adaptations:** Build command interface, quality gates

### 5. Stack & Tooling
**Detect:** File extensions, config files, dependency files

**Key questions:**
- "What tools do you love?" (keep these unchanged)
- "What tools cause friction?" (candidates for replacement)

**Merge strategy:** Keep working tools, add for gaps, replace only if causing pain

### 6. Team Conventions
**Detect:** `git log` (commit format), `gh pr list` (PR naming), directory structure

**Key questions:**
- "What commit message format?" (conventional commits, Jira-prefix, freeform)
- "Where does documentation live?" (README, docs/, wiki, Confluence)

## Adaptation Patterns

### Command Adaptation
- **Branch patterns:** `feature/*` vs `{JIRA-KEY}-*`
- **Issue commands:** `gh issue` vs `jira issue`
- **Build commands:** `just check-all` vs `mvn verify`
- **Terminology:** "epic" vs "feature"

### Workflow Adaptation
Original: `/plan-chat` -> `/plan-breakdown` -> `/plan-create` -> `/work`

Adapted examples:
- Jira + Gitflow: `/plan-feature` -> `/plan-tasks` -> `/create-jira-epic` -> `/implement`
- File-based: `/design-epic` -> `/break-into-tasks` -> `/save-plan` -> `/build-task`

## Generation Process

1. **Discover:** Analyze environment, ask clarifying questions
2. **Select:** Choose workflows/components to adapt
3. **Adapt:** Replace patterns while preserving intent
4. **Generate:** Write to `.claude/{commands,skills,workflows}/`
5. **Document:** Create `VARIANT.md` explaining adaptations

## Output Structure

```
.claude/
├── commands/         # Adapted commands
├── skills/           # Merged stack configuration
├── workflows/        # Adapted workflows
└── VARIANT.md        # Adaptation documentation
```

## Maintenance

Variants are static forks:
- No automatic upstream sync
- Team owns and modifies files
- Re-run `/create-variant` to regenerate, use git diff to cherry-pick

## Anti-Patterns

- Do not create generic "works for everyone" variants
- Do not add runtime detection/branching logic
- Do not try to maintain automatic sync with aug
- Do not replace working tools without asking
