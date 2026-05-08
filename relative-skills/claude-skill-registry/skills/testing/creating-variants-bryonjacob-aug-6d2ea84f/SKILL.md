---
name: creating-variants
description: Create team-specific workflow variants by adapting aug marketplace content to existing tools and processes
---

# Creating Team Workflow Variants

## Purpose

Generate customized workflow files in `.claude/` by adapting aug marketplace commands/skills/workflows to team's existing tools, processes, and conventions.

**Philosophy:** Prescriptive tools adapted to context beat generic tools trying to be everything. Fork aug content, adapt to team reality, maintain opinionated workflows.

## Finding Aug Marketplace Source

**Critical:** Must read aug source files to copy/adapt them.

**Discovery sequence:**
1. Check `~/.claude/plugins/known_marketplaces.json` for aug location
2. Try common installation paths
3. Ask user if detection fails

```bash
# Find aug marketplace
if [ -f ~/.claude/plugins/known_marketplaces.json ]; then
  AUG_PATH=$(jq -r '.aug.installLocation // empty' ~/.claude/plugins/known_marketplaces.json)
fi

# Fallback paths
if [ -z "$AUG_PATH" ]; then
  for path in \
    ~/.claude/marketplaces/aug \
    ~/aug \
    /opt/aug; do
    if [ -d "$path/aug-dev" ]; then
      AUG_PATH="$path"
      break
    fi
  done
fi

# Verify found location
if [ ! -f "$AUG_PATH/aug-dev/commands/plan-chat.md" ]; then
  echo "Cannot find aug marketplace. Please provide path."
fi
```

**Read source file:**
```bash
cat "$AUG_PATH/aug-dev/commands/plan-chat.md"
```

## Discovery Conversation

Interactive session to understand team context. User-standin helps detect from environment.

### 1. Version Control & Git Workflow

**Detect:**
- `.git/config` - Remote URL (GitHub, GitLab, Bitbucket)
- `git log --all --oneline | head -20` - Branch patterns
- `git branch -a` - Active branches

**Standard workflows:**
- **Trunk-based:** Single main branch, short-lived feature branches
- **Gitflow:** develop/main + feature/release/hotfix branches
- **GitHub Flow:** main + feature branches + PR before merge
- **Custom:** Analyze their actual patterns

**Questions:**
- "What branches do releases come from?" (main, master, develop)
- "How are features developed?" (feature/*, user/*, ticket/*)
- "Where do you create PRs to?" (main, develop, staging)

**Adaptations:**
- Branch prefixes in commands
- PR target branches
- Commit message formats

### 2. Issue Tracking

**Detect:**
- `gh auth status` - GitHub CLI configured
- `jira config list` - Jira CLI configured
- `.github/`, `.jira/` - Config directories
- Environment variables: `JIRA_URL`, `GITHUB_TOKEN`

**Options:**
- **GitHub Issues:** Use `gh issue` commands
- **Jira:** Use `jira` CLI or API
- **Linear:** Use Linear CLI/API
- **File-based:** Markdown files in `issues/` or `.issues/`
- **None:** Skip issue creation, manual tracking

**Questions:**
- "Where do you track work?" (GitHub, Jira, Linear, files, none)
- "How do you reference issues?" (#123, PROJ-123, files)
- "Who creates issues?" (team lead, developers, automated)

**Adaptations:**
- Issue creation commands
- Issue reference formats
- Metadata fields (Jira components, GitHub labels)

### 3. CI/CD Platform

**Detect:**
- `.github/workflows/` - GitHub Actions
- `Jenkinsfile` - Jenkins
- `.gitlab-ci.yml` - GitLab CI
- `.circleci/config.yml` - CircleCI
- `azure-pipelines.yml` - Azure Pipelines

**Questions:**
- "Where does CI run?" (GitHub Actions, Jenkins, GitLab, etc.)
- "What triggers CI?" (push, PR, manual)
- "What's the quality gate?" (tests pass, coverage, linting)

**Adaptations:**
- CI config generation commands
- Integration with quality checks
- Deployment automation

### 4. Build Tool

**Detect:**
- `justfile` - just
- `Makefile` - make
- `package.json` scripts - npm/pnpm/yarn
- `build.gradle`, `pom.xml` - Gradle/Maven
- `pyproject.toml` - Python build tools

**Questions:**
- "What runs your builds?" (just, make, npm, gradle, maven, custom scripts)
- "What commands exist?" (test, lint, build, deploy)
- "What's missing?" (coverage, complexity, security scans)

**Adaptations:**
- Build commands interface
- Quality gate additions
- Tool-specific patterns

### 5. Stack & Tooling

**Detect from project:**
- Languages: File extensions, config files
- Frameworks: `package.json` deps, `requirements.txt`, `pom.xml`
- Linters: `.eslintrc`, `.ruff.toml`, `spotless` config
- Test frameworks: Imports, config files
- Coverage tools: `.coveragerc`, `vitest.config.ts`

**Questions:**
- "What tools do you love?" (keep these)
- "What tools cause friction?" (consider replacing)
- "What's missing?" (add opinionated defaults)

**Merge strategy:**
- Keep: Working tools team likes
- Add: Gaps filled with aug defaults
- Replace: Tools causing pain (ask first)

### 6. Team Conventions

**Detect:**
- Commit message format: `git log --oneline -20`
- PR naming: `gh pr list --state all`
- Branch naming: `git branch -a`
- Code organization: Directory structure

**Questions:**
- "Commit message format?" (conventional commits, custom)
- "Documentation location?" (README, docs/, wiki, Confluence)
- "Code review process?" (all PRs, pair programming, post-merge)

## Adaptation Patterns

### Command Adaptation

**Example: `/plan-chat` → team-specific planning**

**Trunk-based team:**
```markdown
# Keep mostly as-is
- Branch: feature/epic-{slug}
- PR target: main
```

**Gitflow team:**
```markdown
# Adapt branch strategy
- Branch: feature/epic-{slug} (from develop)
- PR target: develop
- Release branches: release/* (from develop)
```

**Jira-based team:**
```markdown
# Change issue references
- Branch: {JIRA-KEY}-{slug}
- Commit: {JIRA-KEY}: description
- Create Jira epic instead of GH issue
```

**File-based planning team:**
```markdown
# Skip GitHub issue creation
- Save planning to .planning/{epic-slug}/
- Create tasks as .planning/{epic-slug}/tasks/*.md
- Manual tracking, no API calls
```

### Workflow Adaptation

**Example: Epic development workflow**

**Original (aug):**
```
/plan-chat → /plan-breakdown → /plan-create → /work
(GitHub Issues + trunk-based)
```

**Jira + Gitflow:**
```
/plan-feature → /plan-tasks → /create-jira-epic → /implement
(Jira epics/stories + gitflow branches)
```

**File-based + trunk:**
```
/design-epic → /break-into-tasks → /save-plan → /build-task
(Markdown planning + trunk-based)
```

### Build Tool Adaptation

**Aug (just):**
```just
test:
    pytest -v --cov=. --cov-fail-under=96
```

**Team (npm scripts):**
```json
{
  "scripts": {
    "test": "vitest run --coverage --coverage.thresholds.lines=96"
  }
}
```

**Generated variant command:**
```markdown
# Run tests with coverage
npm test
```

## Generation Process

### 1. Discover Context

Use user-standin to analyze environment:
- Read config files
- Check installed tools
- Analyze git history
- Ask clarifying questions

### 2. Select Components

Ask which workflows to adapt:
- [ ] Epic planning workflow
- [ ] Task execution workflow
- [ ] Refactoring workflow
- [ ] Documentation workflow
- [ ] Build interface
- [ ] Stack configuration

### 3. Adapt Content

For each selected component:
1. Read source from aug marketplace
2. Apply adaptations:
   - Replace branch patterns
   - Replace issue tracker commands
   - Replace build tool commands
   - Adjust terminology
3. Preserve intent and workflow structure

### 4. Generate Files

Write to `.claude/` in current directory:
```
.claude/
├── commands/
│   ├── plan-feature.md      # Adapted from plan-chat
│   ├── plan-tasks.md        # Adapted from plan-breakdown
│   ├── create-epic.md       # Adapted from plan-create
│   └── implement.md         # Adapted from work
├── skills/
│   └── team-stack/
│       └── SKILL.md         # Merged stack configuration
└── workflows/
    └── feature-delivery.md  # Adapted epic-development
```

### 5. Document Adaptations

Create `VARIANT.md` explaining:
- What was adapted from aug
- Why each adaptation was made
- How to maintain files
- How to sync with aug updates (manual)

## File Structure Conventions

**Command files:** `.claude/commands/{name}.md`
```markdown
---
name: plan-feature
description: Interactive architecture session for new feature
---

# Plan Feature

[Adapted from aug-dev /plan-chat for {TEAM} workflow]

## Purpose
...
```

**Skill files:** `.claude/skills/{name}/SKILL.md`
```markdown
---
name: team-java-stack
description: {TEAM} Java stack with Maven + their conventions
---

# {TEAM} Java Stack

[Adapted from aug-dev configuring-java-stack]

## Stack Components

**Team Tools (keep):**
- Maven 3.9.x
- JUnit 5
- Mockito

**Added from aug:**
- Spotless (code formatting)
- SpotBugs (static analysis)
- JaCoCo (coverage, 96% threshold)
...
```

**Workflow files:** `.claude/workflows/{name}.md`
```markdown
---
name: feature-delivery
description: End-to-end feature delivery for {TEAM}
---

# Feature Delivery Workflow

[Adapted from aug-dev epic-development for {TEAM}]

## Phases

1. Design: /plan-feature (interactive)
2. Tasks: /plan-tasks (break into Jira stories)
3. Create: /create-jira-epic (API call)
4. Build: /implement {JIRA-KEY} (autonomous)
...
```

## Maintenance

**Variants are static forks:**
- No automatic upstream sync
- Team owns and modifies files
- Can manually review aug updates
- Can re-run `/create-variant` to regenerate

**Updating from aug:**
1. Check aug RELEASE_NOTES for relevant changes
2. Read updated aug source files
3. Manually apply changes to variant files
4. Test adaptations

**OR:** Re-run `/create-variant`, compare with git diff, cherry-pick desired changes.

## Anti-Patterns

**Don't:**
- ❌ Create generic "works for everyone" variants
- ❌ Add runtime detection/branching logic
- ❌ Try to maintain sync with aug automatically
- ❌ Over-generalize; be prescriptive for THIS team

**Do:**
- ✅ Create specific variants for specific teams
- ✅ Keep opinionated workflows adapted to context
- ✅ Accept team's working tools, add where gaps exist
- ✅ Document why each adaptation was made
