---
name: roadmap-integration
description: "Standard Operating Procedure for /roadmap usage. Manage product roadmap via GitHub Issues (brainstorm, prioritize, track). Auto-validates features against project vision (from overview.md) before adding to roadmap. Triggers when user runs /roadmap or mentions 'roadmap', 'add feature', 'brainstorm ideas', or 'prioritize features'."
allowed-tools: Read, Write, Edit, Bash
---

# Roadmap Integration: Product Feature Management

> **Training Guide**: Execute the `/roadmap` command to manage features via GitHub Issues with ICE prioritization and vision alignment validation.

---

## Phase Overview

**Purpose**: Brainstorm features, validate against project vision, prioritize with ICE scoring, track shipped features

**Inputs**:
- Feature ideas (natural language descriptions)
- Project documentation (`docs/project/overview.md` for vision context)
- Existing GitHub Issues (roadmap state)

**Outputs**:
- GitHub Issues created with ICE metadata
- Priority labels auto-applied (high/medium/low)
- Vision alignment validation report
- Roadmap summary (Backlog/Next/In Progress/Shipped counts)

**Expected duration**: 5-15 minutes per feature add, 30-60 minutes for brainstorming

**Integration**: Feeds into `/feature` command (roadmap → spec → plan → implement → ship)

---

## Execution Steps

### Step 1: Initialize GitHub Context

**Actions**:
1. Check GitHub authentication (gh CLI or GITHUB_TOKEN)
2. Verify repository access
3. Source roadmap manager scripts

**Bash (macOS/Linux):**
```bash
# Source GitHub roadmap manager
source .spec-flow/scripts/bash/github-roadmap-manager.sh

# Check authentication
AUTH_METHOD=$(check_github_auth)

if [ "$AUTH_METHOD" = "none" ]; then
  echo "❌ GitHub authentication required"
  echo ""
  echo "Choose one option:"
  echo "  A) GitHub CLI: gh auth login"
  echo "  B) API Token: export GITHUB_TOKEN=ghp_your_token"
  echo ""
  echo "See: docs/github-roadmap-migration.md"
  exit 1
fi

# Verify repository
REPO=$(get_repo_info)

if [ -z "$REPO" ]; then
  echo "❌ Could not determine repository"
  echo "Ensure you're in a git repository with a GitHub remote"
  exit 1
fi

echo "✅ GitHub authenticated ($AUTH_METHOD)"
echo "✅ Repository: $REPO"
```

**PowerShell (Windows):**
```powershell
# Import GitHub roadmap manager
. .\.spec-flow\scripts\powershell\github-roadmap-manager.ps1

# Check authentication
$authMethod = Test-GitHubAuth

if ($authMethod -eq "none") {
  Write-Host "❌ GitHub authentication required" -ForegroundColor Red
  Write-Host ""
  Write-Host "Choose one option:"
  Write-Host "  A) GitHub CLI: gh auth login"
  Write-Host "  B) API Token: `$env:GITHUB_TOKEN = 'ghp_your_token'"
  Write-Host ""
  Write-Host "See: docs/github-roadmap-migration.md"
  exit 1
}

# Verify repository
$repo = Get-RepositoryInfo

if ([string]::IsNullOrEmpty($repo)) {
  Write-Host "❌ Could not determine repository" -ForegroundColor Red
  Write-Host "Ensure you're in a git repository with a GitHub remote"
  exit 1
}

Write-Host "✅ GitHub authenticated ($authMethod)" -ForegroundColor Green
Write-Host "✅ Repository: $repo" -ForegroundColor Green
```

**Output**:
```
✅ GitHub authenticated (gh-cli)
✅ Repository: owner/repo-name
```

---

### Step 2: Load Project Documentation Context (NEW - Critical)

**Purpose**: Load project vision, scope boundaries, and target users from `overview.md` to validate feature alignment.

**When to execute**:
- Always before adding features
- Always during brainstorming
- Skip during move/delete/search operations

**Actions**:

```bash
PROJECT_OVERVIEW="docs/project/overview.md"
HAS_PROJECT_DOCS=false

if [ -f "$PROJECT_OVERVIEW" ]; then
  HAS_PROJECT_DOCS=true
  echo "✅ Project documentation found"
  echo ""

  # Read project context for validation
  # Claude Code: Read docs/project/overview.md

  # Extract key sections (see extraction logic below)
else
  echo "ℹ️  No project documentation found"
  echo "   Run /init-project to create project design docs"
  echo "   (Optional - roadmap works without it)"
  echo ""
fi
```

**Extraction logic** (from overview.md):

```bash
# Extract project vision (1 paragraph under "Vision" heading)
VISION=$(sed -n '/^## Vision/,/^##/p' "$PROJECT_OVERVIEW" | sed '1d;$d' | head -10)

# Extract out-of-scope items (bullet list under "Out of Scope")
OUT_OF_SCOPE=$(sed -n '/^### Out of Scope/,/^##/p' "$PROJECT_OVERVIEW" | grep -E '^\s*[-*]' | sed 's/^[[:space:]]*[-*][[:space:]]*//')

# Extract target users (bullet list under "Target Users")
TARGET_USERS=$(sed -n '/^## Target Users/,/^##/p' "$PROJECT_OVERVIEW" | grep -E '^\s*[-*]' | sed 's/^[[:space:]]*[-*][[:space:]]*//')

# Store for validation
export VISION OUT_OF_SCOPE TARGET_USERS
```

**Example extracted context**:
```
Vision:
AKTR helps flight instructors track student progress against ACS standards,
enabling data-driven instruction and transparent competency demonstration.

Out of Scope:
- Flight scheduling or aircraft management
- Payment processing or student billing
- General aviation weather briefings

Target Users:
- Certified Flight Instructors (CFIs)
- Flight students (private, instrument, commercial)
- Flight school administrators
```

**Token budget**: ~5-8K tokens (overview.md is typically 2-3 pages)

---

### Step 3: Parse User Intent

**Actions**:
1. Identify action type from natural language
2. Extract parameters (slug, title, requirements, filters)

**Action types**:
- `add` - Add new feature with ICE scoring
- `brainstorm` - Generate feature ideas via web research
- `move` - Change feature status (Backlog → Next → In Progress)
- `delete` - Remove feature from roadmap
- `prioritize` - Show sorted list by ICE score
- `search` - Find features by keyword/area/role
- `ship` - Mark feature as shipped

**Examples**:

| User Input | Detected Action | Parameters |
|------------|----------------|------------|
| "Add student progress widget" | add | title: "student progress widget" |
| "Brainstorm ideas for CFI tools" | brainstorm | topic: "CFI tools" |
| "Move auth-refactor to Next" | move | slug: "auth-refactor", target: "Next" |
| "Delete deprecated-feature" | delete | slug: "deprecated-feature" |
| "Prioritize backlog" | prioritize | section: "backlog" |
| "Search for export features" | search | keywords: "export" |

**Parse logic**:
```bash
INTENT="${1:-}"  # First argument to /roadmap

# Detect action
case "$INTENT" in
  add|create|new)
    ACTION="add"
    FEATURE_DESCRIPTION="${*:2}"  # All remaining args
    ;;
  brainstorm|ideas|suggest)
    ACTION="brainstorm"
    BRAINSTORM_TOPIC="${*:2}"
    ;;
  move|update|change)
    ACTION="move"
    SLUG="${2}"
    TARGET_SECTION="${3}"
    ;;
  delete|remove)
    ACTION="delete"
    SLUG="${2}"
    ;;
  # ... other actions
esac
```

---

### Step 4: Vision Alignment Validation (NEW - For ADD/BRAINSTORM Actions)

**When to execute**: Before creating GitHub Issues during ADD or BRAINSTORM actions

**Validation checks**:
1. **Vision alignment**: Does feature support project vision?
2. **Out-of-scope check**: Is feature explicitly excluded?
3. **Target user check**: Does feature serve documented users?

**Validation logic**:

```bash
if [ "$HAS_PROJECT_DOCS" = true ] && [ "$ACTION" = "add" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 VISION ALIGNMENT CHECK"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Project Vision:"
  echo "$VISION"
  echo ""
  echo "Proposed Feature:"
  echo "  $FEATURE_DESCRIPTION"
  echo ""

  # Check 1: Out-of-scope validation
  IS_OUT_OF_SCOPE=false
  while IFS= read -r excluded_item; do
    # Fuzzy match (case-insensitive substring)
    if echo "$FEATURE_DESCRIPTION" | grep -qi "$(echo "$excluded_item" | cut -d' ' -f1-3)"; then
      IS_OUT_OF_SCOPE=true
      MATCHED_EXCLUSION="$excluded_item"
      break
    fi
  done <<< "$OUT_OF_SCOPE"

  if [ "$IS_OUT_OF_SCOPE" = true ]; then
    echo "❌ OUT-OF-SCOPE DETECTED"
    echo ""
    echo "This feature matches an explicit exclusion:"
    echo "  \"$MATCHED_EXCLUSION\" (overview.md:45)"
    echo ""
    echo "Options:"
    echo "  A) Skip (reject out-of-scope feature)"
    echo "  B) Update overview.md (remove exclusion if scope changed)"
    echo "  C) Add anyway (override with justification)"
    read -p "Choice (A/B/C): " alignment_choice

    case $alignment_choice in
      B|b)
        echo "Update overview.md to remove this exclusion, then retry"
        exit 0
        ;;
      C|c)
        echo "Provide justification for override:"
        read -p "> " JUSTIFICATION
        # Add note to issue body
        ALIGNMENT_NOTE="

---

⚠️  **Alignment Note**: Flagged as out-of-scope per overview.md, but added with justification:
> $JUSTIFICATION"
        ;;
      A|a|*)
        echo "Feature rejected (out of scope per overview.md)"
        exit 0
        ;;
    esac
  fi

  # Check 2: Vision alignment (semantic check via Claude)
  # Claude Code: Analyze if feature supports vision
  # Returns: aligned (true/false), concerns (list)

  if [ "$ALIGNED" = false ]; then
    echo "⚠️  Potential misalignment detected"
    echo ""
    echo "Concerns:"
    for concern in "${CONCERNS[@]}"; do
      echo "  - $concern"
    done
    echo ""
    echo "Options:"
    echo "  A) Add anyway (alignment override)"
    echo "  B) Revise feature to align"
    echo "  C) Skip (not aligned with vision)"
    read -p "Choice (A/B/C): " alignment_choice

    case $alignment_choice in
      B|b)
        echo "Describe how to revise:"
        read -p "> " revision
        # Update FEATURE_DESCRIPTION with revised approach
        FEATURE_DESCRIPTION="$revision"
        ;;
      C|c)
        echo "Feature rejected (vision misalignment)"
        exit 0
        ;;
      A|a)
        echo "Proceeding anyway (alignment override)"
        # Add note to issue body
        ALIGNMENT_NOTE="

---

⚠️  **Alignment Note**: Flagged as potentially misaligned with vision, but added per user request."
        ;;
    esac
  else
    echo "✅ Feature aligns with project vision"
  fi

  # Check 3: Target user validation
  # Ensure feature serves at least one documented target user
  echo ""
  echo "Target User Check:"
  echo "Does this feature serve: $TARGET_USERS"
  read -p "Confirm primary user (or 'skip'): " PRIMARY_USER

  if [ "$PRIMARY_USER" != "skip" ]; then
    # Will be stored in issue metadata
    ROLE_LABEL="role:$(echo "$PRIMARY_USER" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')"
  fi

  echo ""
fi
```

**Vision alignment decision tree**:

```
Feature proposed
    |
    v
Is overview.md present?
    |-- No --> Skip validation, proceed to ICE scoring
    |
    v (Yes)
Extract: Vision, Out-of-Scope, Target Users
    |
    v
Check 1: Is feature in Out-of-Scope list?
    |-- Yes --> Prompt: Skip / Update overview / Override
    |           |-- Skip --> Exit (rejected)
    |           |-- Update --> Exit (user updates overview.md first)
    |           |-- Override --> Add ALIGNMENT_NOTE, continue
    |
    v (No)
Check 2: Does feature support Vision? (semantic analysis)
    |-- No --> Prompt: Add anyway / Revise / Skip
    |           |-- Skip --> Exit (rejected)
    |           |-- Revise --> Update description, retry Check 2
    |           |-- Add anyway --> Add ALIGNMENT_NOTE, continue
    |
    v (Yes)
Check 3: Does feature serve Target Users?
    |-- Yes --> Extract role label
    |
    v
✅ Validation passed, proceed to ICE scoring
```

**Output examples**:

**Case 1: Out-of-scope detected**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 VISION ALIGNMENT CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project Vision:
AKTR helps flight instructors track student progress against ACS standards.

Proposed Feature:
  Add flight scheduling and aircraft booking

❌ OUT-OF-SCOPE DETECTED

This feature matches an explicit exclusion:
  "Flight scheduling or aircraft management" (overview.md:45)

Options:
  A) Skip (reject out-of-scope feature)
  B) Update overview.md (remove exclusion if scope changed)
  C) Add anyway (override with justification)
Choice (A/B/C): A

Feature rejected (out of scope per overview.md)
```

**Case 2: Vision misalignment detected**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 VISION ALIGNMENT CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project Vision:
AKTR helps flight instructors track student progress against ACS standards.

Proposed Feature:
  Add social media integration for student profiles

⚠️  Potential misalignment detected

Concerns:
  - Feature focuses on social networking, not ACS tracking
  - No clear connection to competency demonstration
  - May distract from core learning objectives

Options:
  A) Add anyway (alignment override)
  B) Revise feature to align
  C) Skip (not aligned with vision)
Choice (A/B/C): B

Describe how to revise:
> Add ACS achievement badges that students can share to social media to demonstrate competency milestones

✅ Revised feature aligns with vision
```

**Case 3: Validation passed**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 VISION ALIGNMENT CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Project Vision:
AKTR helps flight instructors track student progress against ACS standards.

Proposed Feature:
  Add student progress widget showing mastery percentage by ACS area

✅ Feature aligns with project vision

Target User Check:
Does this feature serve: CFIs, Flight students, School admins
Confirm primary user (or 'skip'): Flight students

✅ Vision alignment complete
```

---

### Step 5: ICE Scoring and GitHub Issue Creation

**Actions** (after vision validation passes):
1. Extract title, requirements, area, role
2. Infer ICE scores (Impact, Effort, Confidence)
3. Calculate ICE score: (Impact × Confidence) / Effort
4. Generate URL-friendly slug
5. Check for duplicates
6. Create GitHub Issue with metadata

**ICE scoring defaults**:
- Impact: 3 (medium value)
- Effort: 3 (medium complexity)
- Confidence: 0.7 (medium certainty)

**Scoring heuristics**:

| Feature Characteristic | Impact | Effort | Confidence |
|------------------------|--------|--------|------------|
| "Quick win" mentioned | 3-4 | 1-2 | 0.9-1.0 |
| "Strategic" mentioned | 4-5 | 3-4 | 0.7-0.8 |
| >30 requirements | 4-5 | 4-5 | 0.6-0.7 |
| "Simple" or "basic" | 2-3 | 1-2 | 0.9-1.0 |
| "Complex" or "advanced" | 4-5 | 4-5 | 0.6-0.8 |
| Piggybacks existing feature | +0 | -1 | +0.1 |

**Create GitHub Issue**:

**Bash:**
```bash
source .spec-flow/scripts/bash/github-roadmap-manager.sh

# Generate slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | cut -c1-30)

# Format requirements as markdown body
BODY="## Problem

$PROBLEM_STATEMENT

## Proposed Solution

$SOLUTION_DESCRIPTION

## Requirements

$REQUIREMENTS_LIST${ALIGNMENT_NOTE:-}"

# Create issue
create_roadmap_issue \
  "$TITLE" \
  "$BODY" \
  "$IMPACT" \
  "$EFFORT" \
  "$CONFIDENCE" \
  "$AREA" \
  "$ROLE" \
  "$SLUG" \
  "type:feature,status:backlog"

# Output: Created issue #123
```

**PowerShell:**
```powershell
. .\.spec-flow\scripts\powershell\github-roadmap-manager.ps1

# Generate slug
$slug = $title.ToLower() -replace '[^a-z0-9-]', '-' -replace '--+', '-' |
        Select-Object -First 1 | ForEach-Object { $_.Substring(0, [Math]::Min(30, $_.Length)) }

# Format body
$body = @"
## Problem

$problemStatement

## Proposed Solution

$solutionDescription

## Requirements

$requirementsList$(if ($alignmentNote) { $alignmentNote } else { '' })
"@

# Create issue
New-RoadmapIssue `
  -Title $title `
  -Body $body `
  -Impact $impact `
  -Effort $effort `
  -Confidence $confidence `
  -Area $area `
  -Role $role `
  -Slug $slug `
  -Labels "type:feature,status:backlog"
```

**Issue frontmatter** (auto-added by create_roadmap_issue):
```yaml
---
ice:
  impact: 4
  effort: 2
  confidence: 0.9
  score: 1.8
metadata:
  area: app
  role: student
  slug: student-progress-widget
---

## Problem
Students struggle to track mastery...

## Proposed Solution
Add a progress widget...

## Requirements
- [ ] Display mastery percentage
- [ ] Group by ACS area

---

⚠️  **Alignment Note**: Validated against project vision (overview.md)
```

**Priority label auto-applied**:
- `priority:high` if score >= 1.5
- `priority:medium` if 0.8 <= score < 1.5
- `priority:low` if score < 0.8

**Size label auto-applied**:
- `size:small` if effort 1-2
- `size:medium` if effort 3
- `size:large` if effort 4
- `size:xl` if effort 5

---

### Step 6: Return Roadmap Summary

**Actions**:
1. Fetch current roadmap state from GitHub Issues
2. Count features by status (Backlog/Next/In Progress/Shipped)
3. Show top 3 prioritized features
4. Suggest next action

**Summary generation**:

**Bash:**
```bash
source .spec-flow/scripts/bash/github-roadmap-manager.sh

REPO=$(get_repo_info)

# Count by status
BACKLOG_COUNT=$(gh issue list --repo "$REPO" --label "status:backlog" --json number --jq 'length')
NEXT_COUNT=$(gh issue list --repo "$REPO" --label "status:next" --json number --jq 'length')
IN_PROGRESS_COUNT=$(gh issue list --repo "$REPO" --label "status:in-progress" --json number --jq 'length')
SHIPPED_COUNT=$(gh issue list --repo "$REPO" --label "status:shipped" --state closed --json number --jq 'length')

echo "✅ Created issue #$ISSUE_NUMBER: $SLUG in Backlog"
echo "   Impact: $IMPACT | Effort: $EFFORT | Confidence: $CONFIDENCE | Score: $SCORE"
echo "   Priority: $PRIORITY | Area: $AREA | Role: $ROLE"
echo ""
echo "📊 Roadmap Summary:"
echo "   Backlog: $BACKLOG_COUNT | Next: $NEXT_COUNT | In Progress: $IN_PROGRESS_COUNT | Shipped: $SHIPPED_COUNT"
echo ""

# Show top 3 in Backlog (by priority)
echo "Top 3 in Backlog (by priority):"
gh issue list --repo "$REPO" --label "status:backlog,priority:high" --json number,title,body --limit 3 | \
  jq -r '.[] | "\(.number). \(.title) (Score: \(.body | capture("score: (?<score>[0-9.]+)").score))"'

echo ""
echo "💡 Next: /feature $SLUG"
```

**Output example**:
```
✅ Created issue #123: student-progress-widget in Backlog
   Impact: 4 | Effort: 2 | Confidence: 0.9 | Score: 1.8
   Priority: high | Area: app | Role: student

📊 Roadmap Summary:
   Backlog: 12 | Next: 3 | In Progress: 2 | Shipped: 45

Top 3 in Backlog (by priority):
1. #123 student-progress-widget (Score: 1.8)
2. #98 cfi-batch-export (Score: 1.5)
3. #87 study-plan-generator (Score: 1.2)

💡 Next: /feature student-progress-widget
```

---

## Common Mistakes

**1. Skipping vision alignment validation**
- **Symptom**: Features added that don't align with project goals
- **Prevention**: Always run Step 2 (Load Project Docs) before Step 5 (Create Issue)
- **Detection**: Check if `HAS_PROJECT_DOCS=true` but validation was skipped

**2. Adding out-of-scope features without justification**
- **Symptom**: Roadmap grows with tangential features
- **Prevention**: Respect Out-of-Scope exclusions in overview.md
- **Fix**: Update overview.md if scope legitimately changed, don't just override

**3. Missing ICE scores in GitHub Issues**
- **Symptom**: Priority labels not applied, sorting fails
- **Prevention**: Always use `create_roadmap_issue()` function (auto-calculates ICE)
- **Detection**: Check issue body for YAML frontmatter with `ice:` section

**4. Duplicate slugs**
- **Symptom**: Multiple features with same slug
- **Prevention**: Check `get_issue_by_slug()` before creating
- **Fix**: Append `-v2` or `-alt` to duplicate slug

**5. Unclear feature descriptions**
- **Symptom**: Vision alignment check fails due to ambiguity
- **Prevention**: Require Problem + Solution + Requirements format
- **Fix**: Prompt user for more detail before creating issue

**6. Roadmap sync issues**
- **Symptom**: GitHub Issues don't match workflow state
- **Prevention**: Update issue labels when `/feature` creates spec
- **Fix**: Use `mark_issue_in_progress()` when spec created

---

## Completion Criteria

- [ ] **GitHub authentication** verified (gh CLI or token)
- [ ] **Project documentation** loaded (if exists)
- [ ] **Vision alignment** validated (out-of-scope check, vision match, target user)
- [ ] **ICE scores** calculated and applied
- [ ] **GitHub Issue** created with full metadata (YAML frontmatter)
- [ ] **Priority labels** auto-applied (high/medium/low)
- [ ] **Size labels** auto-applied (small/medium/large/xl)
- [ ] **Roadmap summary** displayed (counts by status, top 3 prioritized)
- [ ] **Next action** suggested (/feature [slug])

---

## Quality Gates

**Blocking validations** (must pass before issue creation):

1. **Out-of-Scope Gate**: Feature not in explicit exclusion list
   - **Blocks**: Creating GitHub Issue
   - **Override**: User provides justification, adds ALIGNMENT_NOTE

2. **Vision Alignment Gate**: Feature supports project vision
   - **Blocks**: Creating GitHub Issue
   - **Override**: User revises feature or adds ALIGNMENT_NOTE

**Non-blocking warnings**:

1. **Missing Project Docs**: overview.md not found
   - **Warning**: "Run /init-project to create project design docs"
   - **Impact**: Vision validation skipped, feature added anyway

2. **Large Feature**: >30 requirements OR effort >4
   - **Warning**: "Consider splitting before /feature"
   - **Impact**: `size:xl` label added, user prompted to split

---

## Integration with Project Documentation

**Project docs consulted**:

1. **`docs/project/overview.md`** (CRITICAL):
   - Vision statement (1 paragraph)
   - Out-of-Scope exclusions (bullet list)
   - Target Users (bullet list)

**When docs don't exist**:
- Skip vision validation
- Proceed with ICE scoring
- Add informational note: "Run /init-project for vision-aligned roadmap management"

**When docs are outdated**:
- Prompt user: "Update overview.md if scope changed"
- Don't override exclusions without updating source docs

---

## Performance Expectations

**Token budget per action**:
- **ADD** (with vision validation): ~8-12K tokens
  - overview.md read: ~5-8K
  - Vision alignment analysis: ~2-3K
  - GitHub Issue creation: ~1K
- **ADD** (without docs): ~2-3K tokens
- **BRAINSTORM** (quick): ~15-20K tokens
- **BRAINSTORM** (deep): ~40-60K tokens

**Execution time**:
- **ADD**: 30-60 seconds (with vision check)
- **MOVE/DELETE/SEARCH**: <10 seconds
- **BRAINSTORM quick**: 30-60 seconds
- **BRAINSTORM deep**: 2-5 minutes

---

## References

- **Command**: `.claude/commands/roadmap.md` (full command specification)
- **Scripts**:
  - `.spec-flow/scripts/bash/github-roadmap-manager.sh`
  - `.spec-flow/scripts/powershell/github-roadmap-manager.ps1`
- **Project docs**: `docs/project/overview.md` (vision, scope, users)
- **GitHub Issues**: Roadmap backend (label-based state management)

---

_This SOP guides vision-aligned roadmap management via GitHub Issues with ICE prioritization._
