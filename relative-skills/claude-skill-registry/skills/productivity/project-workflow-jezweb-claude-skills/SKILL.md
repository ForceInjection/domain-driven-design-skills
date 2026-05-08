---
name: project-workflow
description: |
  Seven integrated slash commands for complete project lifecycle: /explore-idea (validation), /plan-project (planning docs), /plan-feature (add features), /wrap-session (checkpoint), /continue-session (resume), /workflow (guidance), /release (safety checks).

  Use when: starting new projects, managing sessions across context windows, adding features to existing projects, or preparing releases with safety checks. Saves 35-55 minutes per project lifecycle.
---

# Project Workflow Skill

7 integrated slash commands for complete project lifecycle automation: idea validation → planning → execution → session management → release.

**Time savings**: 35-55 minutes per project lifecycle

## Installation

**Marketplace**: `/plugin install project-workflow@claude-skills`

**Manual**: Copy `commands/*.md` to `~/.claude/commands/`

## The 7 Commands

### 1. `/explore-idea` - Pre-Planning Exploration

**Use when**: Rough idea that needs tech stack validation, scope management, or research before planning.

**Creates**: PROJECT_BRIEF.md with validated decisions → hands off to /plan-project

**Time savings**: 10-15 min

---

### 2. `/plan-project` - Generate Project Planning Docs

**Use when**: Starting new project with clear requirements, or after /explore-idea.

**Creates**: IMPLEMENTATION_PHASES.md, SESSION.md, DATABASE_SCHEMA.md (if needed), API_ENDPOINTS.md (if needed), ARCHITECTURE.md

**Invokes**: project-planning skill

**Time savings**: 5-7 min

---

### 3. `/plan-feature` - Add Features to Existing Projects

**Use when**: Adding feature to existing project with SESSION.md + IMPLEMENTATION_PHASES.md.

**Does**: Generates new phases via project-planning skill, integrates into IMPLEMENTATION_PHASES.md with renumbering, updates SESSION.md.

**Time savings**: 7-10 min

---

### 4. `/wrap-session` - End-of-Session Checkpoint

**Use when**: Context full (>150k tokens), end of work session, or before task switch.

**Does**: Task agent analyzes session → updates SESSION.md (progress, Next Action, blockers) → git checkpoint commit → formatted handoff summary.

**Time savings**: 2-3 min

---

### 5. `/continue-session` - Start-of-Session Context Loading

**Use when**: Starting new session or after /wrap-session checkpoint.

**Does**: Explore agent loads SESSION.md + planning docs → shows git history + session summary (phase, progress, Next Action, blockers) → optionally opens file → asks permission to continue.

**Time savings**: 1-2 min

---

### 6. `/workflow` - Interactive Workflow Guide

**Use when**: First time user, unsure which command to use, or need quick reference.

**Does**: Shows all 7 commands → context-aware guidance with decision trees → offers to execute appropriate command.

---

### 7. `/release` - Pre-Release Safety Checks

**Use when**: Ready to push to public GitHub or create release.

**8 Phases**:
1. **Critical Safety** (BLOCKERS): Secrets scan (gitleaks), personal artifacts check, git remote verification
2. **Documentation** (REQUIRED): LICENSE, README (>100 words), CONTRIBUTING.md (>500 LOC), CODE_OF_CONDUCT (>1000 LOC)
3. **Configuration**: .gitignore, package.json, git branch warning
4. **Quality** (NON-BLOCKING): Build test, npm audit, large files (>1MB)
5. **Report**: Blockers/warnings/recommendations + safe to release verdict
6-8. **Auto-Fix & Publish**: Fix issues, release prep commit, optional git tag + GitHub release

**Time savings**: 10-15 min

---

## Workflow Examples

**Full**: /explore-idea → /plan-project → work → /wrap-session → /continue-session → /plan-feature (if needed) → repeat → /release

**Quick** (clear requirements): /plan-project → work → /wrap-session → /continue-session → /release

**Helpers**: /workflow (guidance), /plan-feature (add feature), /release (publish)

---

## Integration

**project-planning**: Invoked by /plan-project and /plan-feature (generates IMPLEMENTATION_PHASES.md, DATABASE_SCHEMA.md, API_ENDPOINTS.md)

**project-session-management**: SESSION.md protocol for /wrap-session and /continue-session

**Claude Code agents**: /wrap-session (Task agent), /continue-session + /explore-idea (Explore agent)

---

## Command Relationships

```
EXPLORATION PHASE
/explore-idea (optional)
    ↓
    Creates PROJECT_BRIEF.md
    ↓
PLANNING PHASE
/plan-project (reads PROJECT_BRIEF.md if exists)
    ↓
    Creates IMPLEMENTATION_PHASES.md + SESSION.md
    ↓
EXECUTION PHASE
Work on phases
    ↓
/wrap-session (when context full)
    ↓
    Updates SESSION.md, git checkpoint
    ↓
/continue-session (new session)
    ↓
    Loads SESSION.md, continues work
    ↓
/plan-feature (when need new features)
    ↓
    Adds phases to IMPLEMENTATION_PHASES.md
    ↓
Continue wrap → resume cycle
    ↓
RELEASE PHASE
/release (when ready to publish)
    ↓
    Safety checks → GitHub release

HELPER
/workflow (anytime)
    ↓
    Interactive guidance
```

---

## Time Savings Breakdown

| Command | Time Saved | Tasks Automated |
|---------|------------|-----------------|
| `/explore-idea` | 10-15 min | Research, validation, scope management, tech stack evaluation |
| `/plan-project` | 5-7 min | Planning doc generation, git setup, phase structuring |
| `/plan-feature` | 7-10 min | Feature planning, phase integration, doc updates |
| `/wrap-session` | 2-3 min | SESSION.md updates, git checkpoint, handoff summary |
| `/continue-session` | 1-2 min | Context loading, git history review, next action display |
| `/workflow` | Instant | Navigation, decision trees, command selection |
| `/release` | 10-15 min | Secret scanning, doc validation, build testing, release creation |

**Total per project lifecycle:** 35-55 minutes

---

## Prerequisites

**All**: Claude Code CLI, git repo (recommended)

**/plan-feature**: Existing SESSION.md + IMPLEMENTATION_PHASES.md

**/wrap-session, /continue-session**: SESSION.md (created by /plan-project)

**/release**: Git repo with commits, package.json (Node.js), remote URL (for publishing)

---

## Troubleshooting

**/plan-project "No project description"**: Use /explore-idea first or discuss project with Claude

**/plan-feature "Prerequisites not met"**: Run /plan-project first (creates SESSION.md + IMPLEMENTATION_PHASES.md)

**/wrap-session "No git repository"**: Run `git init`

**/continue-session "SESSION.md not found"**: Run /plan-project

**/release "Secrets detected"**: Add to .gitignore, remove from git history

---

## Version History

**1.0.0** (2025-11-12)
- Initial release
- 7 integrated slash commands
- Plugin marketplace distribution
- Command bundling via plugin.json

---

**Issues**: https://github.com/jezweb/claude-skills/issues | **Author**: Jeremy Dawes (jeremy@jezweb.net) | **License**: MIT
