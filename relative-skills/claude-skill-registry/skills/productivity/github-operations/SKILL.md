---
name: github-operations
description: Manage GitHub Wiki, issues, and repository operations with memory-bank integration, business model validation, and SSH authentication. Automatically loads business context, applies documented lessons learned, and prevents common errors through validation automation.
allowed-tools: "Bash(git:*),Bash(gh:*),Bash(ssh:*),Bash(jq:*),Read,Write,Edit,Grep,Glob"
model: inherit
license: MIT
version: 2.0.0
---

# GitHub Operations Skill with Memory-Bank Integration

**🎯 Skill Purpose:** Intelligent GitHub automation for Wiki management, project/issue tracking, and repository operations with business context awareness and safety guardrails.

**📢 Announcement (REQUIRED):**
When this skill is invoked, immediately tell the user:

"I'm using the **GitHub Operations** skill to [specific action]. This skill will:
- Load business context from memory-bank (if available)
- Apply documented lessons learned from October 2025 audit
- Validate [relevant validations based on action]
- Use [specific tools: SSH/CLI/MCP] for the operation"

**Examples:**
- "I'm using the GitHub Operations skill to **update the Wiki**. I'll verify SSH auth, load business context, check cross-references, and run validation before pushing."
- "I'm using the GitHub Operations skill to **create sprint issues**. I'll load memory-bank WBS, apply issue templates, and link dependencies."
- "I'm using the GitHub Operations skill to **create a PR**. I'll analyze commits, apply PR template, and include deployment notes."

**🔗 Best Used With:**
- `/memory-bank` - Load business context first (recommended)
- `/documentation-writer` - Generate content, then validate here
- `/code-reviewer` - Review PRs created by this skill
- `/project-tracker` - Monitor issues created by this skill

**🤝 Skill Composition (obra/superpowers Integration):**
This skill complements obra/superpowers for complete GitHub workflows:

- **obra: Code Development** → **This skill: Wiki Documentation**
  - obra creates git worktrees for parallel branches
  - This skill validates Wiki in separate worktree (67% time savings)

- **obra: Code Review** → **This skill: Business Validation**
  - obra runs test suite and code quality checks
  - This skill validates Wiki + business model consistency

- **obra: Parallel Agents** → **This skill: Investor Docs**
  - obra dispatches agents for sprint tasks
  - This skill handles business-facing documentation

**When to delegate to obra/superpowers:**
- ✅ Git worktrees for parallel development
- ✅ Code review workflows (requesting/receiving)
- ✅ Branch merge/PR decision workflows
- ✅ Test-driven development (TDD)
- ✅ Parallel agent dispatch

**When to use this skill:**
- ✅ GitHub Wiki operations (clone, validate, push)
- ✅ Business model validation (B2C/B2B, investor docs)
- ✅ Memory-bank integration (business context)
- ✅ Domain-specific validation (tech stack, hardcoded patterns)

See `docs/skill-composition-examples.md` for detailed integration patterns.

---

You are assisting with GitHub operations including Wiki management, project/issue management, and repository operations. This skill integrates with the project's memory-bank structure to apply documented lessons learned and business context.

## 🎯 Core Capabilities

1. **Wiki Management** - Edit, validate, and maintain GitHub Wiki documentation
2. **Project Management** - Create and manage GitHub Projects, issues, and sprints
3. **Repository Operations** - Branch management, PRs, tags, and releases
4. **Memory-Bank Integration** - Auto-load business context and apply lessons learned

---

## ⚠️ Critical Red Flags

### NEVER Do These Things:
- ❌ **Use fine-grained tokens for Wiki push** → Will get 403 error. Wiki requires SSH authentication.
- ❌ **Hardcode database counts** → Numbers go stale. Use "Production database (verified: DATE)" instead.
- ❌ **Mix B2B/B2C messaging** → Creates investor confusion. Add explicit business model headers.
- ❌ **Update tech stack without grep** → Creates inconsistency. Always `grep -r "TechName" .` for cross-references.
- ❌ **Skip validation scripts** → Catches errors before publish. Always run validate-wiki.sh, check-tech-stack.sh, verify-business-model.sh.

### ALWAYS Do These Things:
- ✅ **Verify SSH auth first** → Run `ssh -T git@github.com` before any Wiki operation
- ✅ **Load memory-bank context** → Read `{baseDir}/memory-bank/quick-reference.json` for business context
- ✅ **Run validation before push** → Execute all 3 validation scripts on Wiki checkout
- ✅ **Check cross-references** → `grep -r "term-to-update" {baseDir}/tmp/[project]-wiki`
- ✅ **Use verification dates** → "Minnesota outdoor recreation destinations (verified: October 2025)"
- ✅ **Announce skill usage** → Tell user: "I'm using the GitHub Operations skill to [action]"

### Quick Error Prevention Checklist:
```bash
# Before Wiki operations:
[ ] SSH verified: ssh -T git@github.com
[ ] Memory-bank loaded: cat memory-bank/quick-reference.json
[ ] Wiki cloned: git clone git@github.com:org/repo.wiki.git
[ ] Cross-refs checked: grep -r "term" /tmp/project-wiki
[ ] Validation passed: ./scripts/validate-wiki.sh /tmp/project-wiki
```

**Impact:** Prevents 90% of documented errors from October 2025 audit.

---

## 🛠️ Tool Selection Decision Table

Choose the right tool for your GitHub operation:

| Task Category | Primary Tool | Authentication | Command Example | When NOT to Use |
|---------------|--------------|----------------|-----------------|-----------------|
| **Wiki Operations** | Git + SSH | SSH keys | `git clone git@github.com:org/repo.wiki.git` | ❌ Never use tokens (403 error) |
| **Security Alerts** | GitHub Project Manager MCP | PAT (enhanced) | Via MCP interface | ❌ Standard PAT lacks permissions |
| **Issue Creation** | GitHub CLI (`gh`) | PAT or SSH | `gh issue create --title "..." --body "..."` | ✅ MCP works too (slower) |
| **PR Creation** | GitHub CLI (`gh`) | PAT or SSH | `gh pr create --title "..." --body "..."` | ✅ Web interface for complex |
| **PR Review** | GitHub CLI (`gh`) | PAT or SSH | `gh pr view 123 --comments` | Use Web for visual diffs |
| **Bulk Operations** | GitHub CLI (`gh`) | PAT or SSH | `gh issue list --label bug` | ❌ MCP not optimized for bulk |
| **Project Boards** | GitHub Project Manager MCP | PAT | Via MCP interface | Use Web for drag-drop |
| **Releases** | GitHub CLI (`gh`) | PAT or SSH | `gh release create v1.0.0` | ✅ Either tool works |
| **Repository Settings** | Web Interface | Browser session | Manual navigation | ❌ No CLI/API for some settings |

### Quick Selection Rules:

**🔴 Wiki Operations = SSH ONLY**
```bash
# ALWAYS use SSH URL for Wiki
git clone git@github.com:org/repo.wiki.git
# Fine-grained tokens WILL FAIL with 403
```

**🟡 Security Operations = MCP Required**
```bash
# Security alerts require enhanced PAT permissions
# Use GitHub Project Manager MCP, not CLI
```

**🟢 Everything Else = GitHub CLI Preferred**
```bash
# Fast, scriptable, works in CI/CD
gh issue create | gh pr create | gh repo view
```

**Performance Note:** GitHub CLI saves 4+ hours/week per developer vs manual Web UI operations.

---

## 📋 Initialization Steps

When this skill is invoked, perform these steps:

### Step 1: Detect Project Context

```bash
# Check for memory-bank structure
if [ -f "memory-bank/quick-reference.json" ]; then
    # Load business context
    cat memory-bank/quick-reference.json
fi

# Detect GitHub repository
git remote get-url origin

# Check for Wiki
WIKI_URL=$(git remote get-url origin | sed 's/\.git$/.wiki.git/')
```

### Step 2: Load Lessons Learned

Check for documented lessons in priority order:
1. `{baseDir}/memory-bank/wiki-content/lessons-learned.md`
2. Built-in lessons from this skill (see References section below)

### Step 3: Understand User Intent

Ask clarifying questions if needed:
- What GitHub operation? (Wiki edit, issue creation, PR, etc.)
- What's the goal? (Add documentation, fix bug, new feature, etc.)
- Any specific constraints? (Investor-ready, technical audience, etc.)

## 🔴 Critical Wiki Editing Lessons (Auto-Apply)

### Lesson 1: Database State Validation

**BEFORE** documenting any database/API statistics:

```bash
# Validate production data
curl -s "https://[production-url]/api/[endpoint]?limit=1" | jq '.count'
```

**Pattern to follow:**
- ❌ DON'T: "Database contains 138 POI locations"
- ✅ DO: "Production POI database (verified: October 2025)"
- ✅ DO: "Minnesota outdoor recreation destinations"

### Lesson 2: Technology Stack Consistency

**BEFORE** publishing Wiki updates, verify tech stack consistency:

```bash
cd /tmp/[project]-wiki
grep -r "FastAPI" .
grep -r "PostGIS" .
grep -r "Directus" .
grep -r "[deprecated-technology]" .
```

If found in multiple files, update ALL occurrences or add deprecation warnings.

### Lesson 3: Business Model Alignment

**For investor-facing docs**, add explicit business model headers:

```markdown
## Business Model

**Current Focus**: 100% B2C [description]

**NOT Pursuing**: B2B features are documented as far-future possibilities only
```

### Lesson 4: Deprecation Warnings

**Instead of deleting outdated docs**, add deprecation warnings:

```markdown
## ⚠️ **DEPRECATED DOCUMENT - DO NOT USE**

**Status**: This document contains outdated information from [DATE].

**Current Information**: See [Link to Updated Doc]

### **Outdated Information in This Document**:
- ❌ [Specific outdated claim 1]
- ❌ [Specific outdated claim 2]

**Deprecation Date**: [DATE]
**Replacement Document**: [Link]

---

[Original outdated content below...]
```

### Lesson 5: SSH Authentication for Wiki

**CRITICAL**: GitHub Wiki push requires SSH authentication.

```bash
# Verify SSH access BEFORE attempting Wiki operations
ssh -T git@github.com

# Use SSH URL for Wiki:
# git@github.com:[org]/[repo].wiki.git

# Fine-grained GitHub tokens will FAIL with 403 errors
```

### Lesson 6: Cross-Reference Validation

**BEFORE** updating technical details, check for cross-references:

```bash
cd /tmp/[project]-wiki
grep -r "[term-to-update]" .
```

Update all references or document which remain unchanged and why.

### Lesson 7: Investor Communication Standards

**For fundraising/investor materials:**
- Use consistent terminology across all docs
- Cite data sources and validation dates
- Include clear business model statements
- Avoid contradictory claims
- Professional tone, clear structure

## 🛠️ Wiki Editing Workflow

### Pre-Flight Checklist

- [ ] SSH authentication verified (`ssh -T git@github.com`)
- [ ] Memory-bank business context loaded
- [ ] Production data validated (if documenting statistics)
- [ ] Technology stack verified (if documenting architecture)
- [ ] Business model alignment checked (if investor-facing)
- [ ] Cross-references identified (grep for related terms)

### Editing Process

1. **Clone Wiki**
   ```bash
   cd /tmp
   git clone [wiki-ssh-url] [project]-wiki
   cd [project]-wiki
   ```

2. **Apply Changes**
   - Use memory-bank business context for accuracy
   - Follow lessons learned patterns
   - Validate all technical claims
   - Check cross-references

3. **Validation**
   ```bash
   # Search for potential issues
   grep -r "138 POI" .  # Hardcoded counts
   grep -r "FastAPI" .   # Deprecated tech
   grep -r "B2B" .       # Business model drift
   ```

4. **Commit & Push**
   ```bash
   git add .
   git commit -m "docs: [description]

   [Details of changes]
   [Validation performed]
   "
   git push origin master
   ```

## 📊 Project/Issue Management

### Creating Issues from Templates

When creating GitHub issues:

1. **Load context** from memory-bank
2. **Apply templates** if available
3. **Link dependencies** if part of larger work
4. **Add labels** based on type and priority
5. **Assign to project** if part of sprint

### Issue Template Pattern

```markdown
## Summary
[One-line description]

## Context
[Business context from memory-bank]

## Acceptance Criteria
- [ ] [Specific, testable criteria]
- [ ] [Validation steps]

## Technical Notes
[From memory-bank technical patterns]

## Dependencies
- Depends on: #[issue-number]
- Blocks: #[issue-number]
```

## 🔧 Repository Operations

### Branch Management

**Safety checks before creating branches:**
- Verify working directory is clean
- Confirm base branch is up-to-date
- Check for existing branch with same name

### PR Creation

**Use PR templates that include:**
- Summary of changes
- Testing performed
- Breaking changes (if any)
- Related issues
- Deployment notes

### Tag Management

**Version tags should:**
- Follow semantic versioning
- Include release notes
- Link to deployment/milestone

---

## 🌳 Advanced: Git Worktrees for Parallel Operations

### What Are Git Worktrees?

Git worktrees enable multiple working directories from the same repository, allowing **parallel Wiki editing** without interference.

**Use Cases:**
- Multiple Claude instances editing different Wiki sections simultaneously
- Testing Wiki changes in isolation before merging
- Long-running Wiki updates while maintaining stable version

### When to Use Worktrees

**✅ Use Worktrees When:**
- Large Wiki updates requiring parallel edits to 5+ pages
- Multiple developers/AI instances working simultaneously
- Testing breaking changes without affecting main Wiki
- Long-running feature branches (multi-day updates)

**❌ Don't Use Worktrees For:**
- Simple single-page edits (overhead not worth it)
- Quick typo fixes or minor updates
- Solo editing with no concurrent work

### Worktree Setup Workflow

**Step 1: Create Main Wiki Checkout**
```bash
cd /tmp
git clone git@github.com:[org]/[repo].wiki.git [project]-wiki-main
cd [project]-wiki-main
```

**Step 2: Create Worktrees for Parallel Tasks**
```bash
# Create worktree for feature A
git worktree add ../[project]-wiki-feature-a feature-a

# Create worktree for feature B
git worktree add ../[project]-wiki-feature-b feature-b

# List all worktrees
git worktree list
```

**Step 3: Edit in Parallel**
```bash
# Claude Instance 1 in terminal 1
cd /tmp/[project]-wiki-feature-a
# Edit section A...
git add . && git commit -m "docs: update section A"

# Claude Instance 2 in terminal 2 (simultaneously)
cd /tmp/[project]-wiki-feature-b
# Edit section B...
git add . && git commit -m "docs: update section B"
```

**Step 4: Merge and Cleanup**
```bash
cd /tmp/[project]-wiki-main
git merge feature-a
git merge feature-b
git push origin master

# Remove worktrees
git worktree remove ../[project]-wiki-feature-a
git worktree remove ../[project]-wiki-feature-b
```

### Safety Checks for Worktrees

**Before Creating Worktree:**
- [ ] Main Wiki checkout is clean: `git status`
- [ ] Check CLAUDE.md for worktree preferences
- [ ] Worktree directory doesn't exist
- [ ] Sufficient disk space (3x Wiki size)

**Project-Local vs Global:**
- **Project-Local** (`.worktrees/`): Add to `.gitignore` ⚠️
- **Global** (`/tmp/`): No .gitignore needed ✅

### Example: Parallel Wiki Sections

**Scenario:** Update 3 independent sections (architecture, API, deployment)

```bash
# Setup
cd /tmp
git clone git@github.com:org/repo.wiki.git wiki-main
cd wiki-main

git worktree add ../wiki-architecture architecture
git worktree add ../wiki-api api-docs
git worktree add ../wiki-deployment deployment

# Parallel editing (3 Claude instances)
# Terminal 1: Architecture updates
cd /tmp/wiki-architecture
# Make changes...

# Terminal 2: API documentation
cd /tmp/wiki-api
# Make changes...

# Terminal 3: Deployment guide
cd /tmp/wiki-deployment
# Make changes...

# Validate each independently
{baseDir}/.claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-architecture
{baseDir}/.claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-api
{baseDir}/.claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-deployment

# Merge all
cd /tmp/wiki-main
git merge architecture
git merge api-docs
git merge deployment
git push origin master

# Cleanup
git worktree remove ../wiki-architecture
git worktree remove ../wiki-api
git worktree remove ../wiki-deployment
```

### Performance Benefits

**Time Savings:**
- Traditional serial: 3 sections × 20 min = 60 minutes
- Parallel worktrees: max(20 min) = 20 minutes
- **Savings: 40 minutes (67% faster)**

**Worktree-Aware Announcement:**
```
"I'm using the GitHub Operations skill with git worktrees to [action].
This allows parallel editing of [section] without affecting other work.
I'll validate this worktree independently before merging."
```

---

## 🤖 CI/CD Integration

### GitHub Actions Workflow

Automate Wiki validation in your CI/CD pipeline.

**Create `.github/workflows/wiki-validation.yml`:**

```yaml
name: Wiki Validation

on:
  push:
    paths: ['wiki/**']
  pull_request:
    paths: ['wiki/**']
  workflow_dispatch:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Checkout Wiki
        run: |
          cd /tmp
          git clone git@github.com:${{ github.repository }}.wiki.git wiki
        env:
          GIT_SSH_COMMAND: 'ssh -i ${{ secrets.WIKI_SSH_KEY }} -o StrictHostKeyChecking=no'

      - name: Install dependencies
        run: sudo apt-get update && sudo apt-get install -y jq

      - name: Validate configuration
        run: |
          chmod +x .claude/skills/github/scripts/*.sh
          ./.claude/skills/github/scripts/validate-config.sh

      - name: Validate Wiki content
        run: ./.claude/skills/github/scripts/validate-wiki.sh /tmp/wiki

      - name: Check tech stack
        run: ./.claude/skills/github/scripts/check-tech-stack.sh /tmp/wiki

      - name: Verify business model
        run: ./.claude/skills/github/scripts/verify-business-model.sh /tmp/wiki
```

### Setup Instructions

**1. Add SSH Key Secret:**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "github-actions@project" -f wiki_deploy_key

# Add public key to GitHub: Settings → Wiki → Deploy keys
# Add private key to repo: Settings → Secrets → WIKI_SSH_KEY
```

**2. Enable Workflow:**
```bash
git add .github/workflows/wiki-validation.yml
git commit -m "ci: add Wiki validation workflow"
git push
```

### Pre-Commit Hook

**Local validation before commits:**

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "🔍 Running pre-commit Wiki validation..."

WIKI_FILES=$(git diff --cached --name-only | grep "^wiki/" || true)
if [ -n "$WIKI_FILES" ]; then
    if ! ./.claude/skills/github/scripts/validate-wiki.sh wiki/; then
        echo "❌ Wiki validation failed!"
        echo "Fix errors or use 'git commit --no-verify' to skip"
        exit 1
    fi
    echo "✅ Wiki validation passed"
fi
exit 0
```

```bash
chmod +x .git/hooks/pre-commit
```

### Headless Mode for Automation

**Run Claude validation from CLI:**
```bash
# Basic validation
claude -p "Validate Wiki using github-operations skill"

# With JSON output for parsing
claude -p "Validate Wiki using github-operations skill" \
  --output-format stream-json | jq -r '.content'

# In CI/CD
export CLAUDE_HEADLESS=true
export GITHUB_TOKEN="ghp_..."
claude -p "Check Wiki business model consistency"
```

### Performance Metrics

- **Validation time:** 30-60 seconds
- **Feedback on PR:** Within 2 minutes
- **Time saved:** 5-10 minutes per Wiki update
- **Cost:** Free (GitHub Actions minutes)

---

## 🧠 Memory-Bank Integration

### Auto-Load Business Context

```json
{
  "businessFocus": "B2C outdoor recreation",
  "techStack": "Vercel + Neon + React",
  "primaryTable": "poi_locations",
  "redFlags": [
    "Cities appearing instead of parks",
    "B2B features being developed"
  ]
}
```

### Apply Red Flags

If user's request conflicts with documented red flags, **warn immediately**:

"⚠️ This conflicts with documented business model: [explain why]"

### Use Technical Patterns

Reference proven patterns from memory-bank when suggesting solutions.

---

## 🎭 Skill Composition Patterns

### What is Skill Composition?

Multiple skills working together in a single workflow, each providing specialized capabilities.

**Benefits:**
- ✅ Divide complex tasks into specialized steps
- ✅ Reuse skills across different workflows
- ✅ Claude automatically loads relevant skills
- ✅ Token-efficient (only active skills loaded)

### Composition Pattern 1: Sequential Workflow

**Load context → Generate → Validate → Publish**

```
User: "Create investor documentation and publish to Wiki"

Claude automatically:
1. Loads /memory-bank → Reads quick-reference.json
2. Loads /documentation-writer → Generates docs
3. Loads /github-operations → Validates and publishes
```

### Composition Pattern 2: Conditional Workflow

**Different skills based on task type**

```
User: "Prepare for investor meeting"

Claude detects "investor" keyword:
1. Loads /business-model-validator
2. Loads /github-operations
3. If docs incomplete → Loads /documentation-writer
```

### Practical Examples

**Example 1: Full Documentation Workflow**
```
User: "Document our authentication feature and publish to Wiki"

Skill composition:
1. /memory-bank → Load tech stack, security patterns
2. /security-analyzer → Analyze implementation
3. /documentation-writer → Generate comprehensive docs
4. /github-operations → Validate and publish

Time: 15 min (vs 2 hours manual)
Savings: 87% faster
```

**Example 2: Sprint Planning**
```
User: "Create sprint issues from memory-bank WBS"

Skill composition:
1. /memory-bank → Load WBS, patterns, red flags
2. /task-analyzer → Parse dependencies
3. /github-operations → Create issues with templates
4. /project-tracker → Monitor and report
```

### Cross-Skill Data Sharing

**Pattern: Skill Output → Next Skill Input**

```markdown
From memory-bank → to github-operations:
{
  "businessFocus": "B2C outdoor recreation",
  "techStack": "Vercel + Neon + React",
  "validated": true
}

github-operations checks:
- validated: true → Proceed
- validated: false → Reload memory-bank
```

### Composition Best Practices

**1. Load Context Early**
```markdown
✅ GOOD: Load memory-bank first, use in all operations
❌ BAD: Start operations, realize context needed, go back
```

**2. Validate Before Publishing**
```markdown
✅ GOOD: Generate → Validate → Fix → Publish
❌ BAD: Generate → Publish → Discover errors
```

**3. Report Composition**
```markdown
When composing skills, announce:
"I'm composing 3 skills:
1. memory-bank-loader - Loading business context
2. documentation-writer - Generating content
3. github-operations - Validating and publishing
Estimated time: 2 minutes"
```

### Performance Comparison

| Task | Solo Skill | With Composition | Improvement |
|------|------------|------------------|-------------|
| Wiki Update | 15 min | 5 min | 67% faster |
| Investor Docs | 45 min | 10 min | 78% faster |
| Sprint Planning | 30 min | 8 min | 73% faster |

**Recommendation:** 3-5 composed skills is optimal for token efficiency

---

## 📝 Response Format

When assisting with GitHub operations:

1. **Acknowledge** the request
2. **Load context** from memory-bank (if available)
3. **Apply lessons** from this skill
4. **Provide specific commands** or guidance
5. **Validate** before executing
6. **Document** what was done

## 🎯 Examples

### Example 1: Wiki Update Request

User: "Update the Wiki with our new POI count"

Response:
1. Load quick-reference.json for current count
2. Validate production API endpoint
3. Apply Lesson 1 (avoid hardcoded counts)
4. Suggest generic phrasing with verification date
5. Check for cross-references
6. Execute Wiki update with proper commit message

### Example 2: Issue Creation

User: "Create issues for current sprint"

Response:
1. Load memory-bank WBS or sprint plan
2. Apply issue template pattern
3. Link dependencies
4. Add appropriate labels
5. Assign to GitHub Project
6. Provide summary of created issues

### Example 3: PR Creation

User: "Create PR for React fix"

Response:
1. Verify branch is ready
2. Load recent commits for context
3. Apply PR template
4. Link related issues
5. Add deployment notes
6. Create PR with comprehensive description

## ⚠️ Error Handling

**Common Issues and Solutions:**

**403 Error on Wiki Push:**
- Problem: Using fine-grained token instead of SSH
- Solution: Switch to SSH authentication

**Inconsistent Documentation:**
- Problem: Technology stack varies across Wiki pages
- Solution: Search and update all references

**Business Model Drift:**
- Problem: B2B features mentioned in B2C project
- Solution: Add clarification or deprecation warning

## 🚀 Advanced Features

### Batch Operations

Support bulk operations:
- Update multiple Wiki pages
- Create multiple issues from WBS
- Tag multiple commits

### Validation Automation

Run automated checks:
- Technology consistency across Wiki
- Business model alignment
- Dead link detection
- Statistics verification

### Integration with Other Tools

Work alongside:
- GitHub CLI (`gh`)
- GitHub MCP servers
- Project management tools

---

## 🔗 Integration Points

This skill is designed to work seamlessly with other tools and workflows.

### Works Directly With:

**Memory-Bank Structure:**
- `memory-bank/quick-reference.json` → Business context, tech stack, red flags
- `memory-bank/skill-config.json` → Project-specific validation rules (Phase C)
- `memory-bank/wiki-content/lessons-learned.md` → Additional lessons beyond built-in

**Project Configuration:**
- `CLAUDE.md` → Project-specific GitHub operation standards
- `.github/workflows/` → CI/CD integration for validation automation
- `.claude/skills/` → Other skills (composition patterns)

**External Tools:**
- `git` + SSH → Wiki operations (required)
- `gh` (GitHub CLI) → API operations, bulk tasks, scripting
- GitHub Project Manager MCP → Security alerts, sprint planning
- `jq` → JSON parsing for memory-bank files

### Typical Multi-Skill Workflows:

**Workflow 1: Wiki Documentation Update**
```
1. /memory-bank-loader → Load business context
2. /documentation-writer → Generate content
3. /github-operations → Validate and publish to Wiki
```

**Workflow 2: Sprint Planning**
```
1. /memory-bank-loader → Load WBS and technical patterns
2. /github-operations → Create issues with templates and dependencies
3. /project-tracker → Monitor progress and update statuses
```

**Workflow 3: Feature PR Creation**
```
1. Developer writes code → Commits to branch
2. /github-operations → Create PR with template and analysis
3. /code-reviewer → Review PR for quality issues
4. /github-operations → Address feedback, merge
```

**Workflow 4: Investor Documentation**
```
1. /memory-bank-loader → Load business model and red flags
2. /documentation-writer → Generate investor-facing content
3. /github-operations → Validate business model consistency
4. /github-operations → Publish to Wiki with proper headers
```

### Invocation Patterns:

**Explicit Invocation:**
```
/github-operations
```

**Implicit Invocation (Auto-Triggered):**
- User says: "Update the Wiki with..."
- User says: "Create issues for..."
- User says: "Make a PR for..."
- User says: "Check business model consistency"

**Composition with Other Skills:**
```
# Load memory-bank first, then use GitHub operations
/memory-bank && /github-operations

# Generate docs, then validate with GitHub operations
/docs-generator && /github-operations validate
```

### Environment Variables:

Set these to customize skill behavior per project:

```bash
# Override default paths
export SKILL_CONFIG_PATH="./custom-config/github-skill.json"
export WIKI_LESSONS_PATH="./docs/wiki-lessons.md"
export MEMORY_BANK_PATH="./project-context"
export GITHUB_WIKI_URL="https://github.com/org/repo/wiki"

# CI/CD mode
export CLAUDE_HEADLESS=true
export GITHUB_TOKEN="ghp_..."
```

### Related Skills:

- **memory-bank-loader** - Loads business context before GitHub operations
- **documentation-writer** - Generates content that this skill validates
- **code-reviewer** - Reviews PRs created by this skill
- **project-tracker** - Monitors issues created by this skill
- **git-worktrees** - Enables parallel GitHub operations (see Phase D)

### Documentation Cross-References:

- Full tool guide: `{baseDir}/.claude/skills/github/docs/github-tools-guide.md`
- Quick reference: `{baseDir}/.claude/skills/github/docs/quick-reference.md`
- Memory-bank integration: `{baseDir}/.claude/skills/github/examples/memory-bank-integration.md`
- CLAUDE.md setup: `{baseDir}/.claude/skills/github/docs/claude-md-integration.md` (Phase B3)

---

## 📚 References

### **Core Documentation**
- **GitHub Tools Guide**: `{baseDir}/.claude/skills/github/docs/github-tools-guide.md` - Comprehensive tool selection, authentication, and troubleshooting
- **Quick Reference Card**: `{baseDir}/.claude/skills/github/docs/quick-reference.md` - Emergency reference for common operations
- **Wiki Editing Checklist**: `{baseDir}/.claude/skills/github/templates/wiki-editing-checklist.md` - Pre-flight checklist
- **Memory-Bank Integration**: `{baseDir}/.claude/skills/github/examples/memory-bank-integration.md` - Integration patterns

### **Validation Scripts**
- `{baseDir}/.claude/skills/github/scripts/validate-wiki.sh` - Comprehensive Wiki validation
- `{baseDir}/.claude/skills/github/scripts/check-tech-stack.sh` - Technology stack consistency
- `{baseDir}/.claude/skills/github/scripts/verify-business-model.sh` - Business model validation

### **Templates**
- `{baseDir}/.claude/skills/github/templates/business-model-header.md` - Investor doc template
- `{baseDir}/.claude/skills/github/templates/deprecation-warning.md` - Deprecation template
- `{baseDir}/.claude/skills/github/templates/wiki-editing-checklist.md` - Pre-flight checklist

## 🔐 Authentication Strategy

**CRITICAL LESSONS**:

### **Lesson 1: SSH Authentication for Wiki**
**ALWAYS** use SSH for Wiki push operations. Fine-grained tokens will fail with 403.

```bash
# Before ANY Wiki operation:
ssh -T git@github.com

# Clone Wiki with SSH:
git clone git@github.com:org/repo.wiki.git
```

### **Lesson 2: Security Alerts Require Enhanced Permissions**
Personal access tokens cannot access security alerts (HTTP 403).

**Solution**: Use GitHub Project Manager MCP with enhanced token permissions.

### **Lesson 3: Tool Selection Based on Task**
- **Security Operations**: GitHub Project Manager MCP (enhanced permissions)
- **Bulk Operations**: GitHub CLI (efficiency, scriptability)
- **Wiki Operations**: GitHub CLI + SSH authentication
- **Visual Operations**: Web Interface (complex layouts)

**See**: `{baseDir}/.claude/skills/github/docs/github-tools-guide.md` for complete decision tree and authentication setup.

---

**Skill Version**: 2.0.0
**Last Updated**: November 2025
**Designed For**: Multi-project reuse with memory-bank integration and comprehensive GitHub operations support
