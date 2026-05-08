---
name: command-creator
description: Creates slash commands for Claude Code following Sando's Golden Rule - only create commands that add intelligent value over bash (analysis, insights, multi-source aggregation, troubleshooting). Use when user requests new slash command or workflow automation that justifies token cost.
allowed-tools: Read, Write, Edit, Glob, Bash
---

# Command Creator Skill

This skill generates **slash commands** that follow Sando Design System philosophy: **only create commands that justify token cost by adding intelligent value**.

## Guidelines: Single Source of Truth

**CRITICAL**: Command functionality must respect Sando guidelines when analyzing/validating project artifacts.

**Primary Guidelines for Command Logic**:

- **02-architecture/MONOREPO_STRUCTURE.md** - Turborepo structure, package locations
- **03-development/GIT_WORKFLOW.md** - Git status, branch naming, conventional commits
- **05-quality/TEST_COVERAGE.md** - Coverage thresholds (>85% unit, 100% a11y)
- **05-quality/PERFORMANCE_BUDGETS.md** - Bundle size budgets (<10KB/component)
- **02-architecture/COMPONENT_ARCHITECTURE.md** - 7-file structure validation

**Full Index**: `.claude/guidelines/GUIDELINES_INDEX.md`

**Guideline Priority**:

1. **Sando Guidelines** - For validation/analysis logic
2. **Golden Rule** - Only create if adds intelligent value
3. **Bash Alternative** - Always prefer bash if no value added

## 🎯 GOLDEN RULE: Command Justification

**Before creating ANY slash command, validate:**

```
❌ NO if only executes bash command
   - Wrapper of package.json script
   - No analysis or context added
   - Example: /build → pnpm build
   - Action: Use bash directly (free)

✅ YES if adds intelligent value:
   ✓ Combines multiple sources
   ✓ Analyzes and interprets results
   ✓ Generates AI-powered recommendations
   ✓ Provides context requiring intelligence
   ✓ Debugging/troubleshooting automation
   ✓ Example: /status → git + builds + tests + analysis

✅ YES if skill shortcut (convenience):
   ✓ /new-component faster than full sentence
   ✓ Invokes skill explicitly
   ✓ Frequent workflow meriting shortcut
```

## Validation Checklist (4 Questions)

### 1. ¿Script exists in package.json?

```bash
cat package.json | grep -A 50 '"scripts"'
```

- **SÍ exists** → ❌ NO create command, use bash
- **NO exists** → ✅ Continue

### 2. ¿Command adds analysis/intelligence?

- **NO adds value** → ❌ NO create command
- **SÍ adds value** → ✅ Continue

### 3. ¿Combines multiple sources or provides insights?

- **NO combines** → ⚠️ Probably not worth it
- **SÍ combines** → ✅ Probably worth it

### 4. ¿User needs result interpretation?\*\*

- **NO needs interpretation** → ❌ Bash sufficient
- **SÍ needs interpretation** → ✅ Command justified

## ✅ Examples of GOOD Commands (Add Value)

### `/status` - Multi-Source Analysis

**Why good:**

- ✅ Combines git status + build artifacts + test results + coverage
- ✅ Analyzes timestamps (detects stale builds per MONOREPO_STRUCTURE.md)
- ✅ Generates actionable recommendations
- ✅ Cannot be replicated with single bash command

### `/coverage` - Intelligent Insights

**Why good:**

- ✅ Parses complex JSON coverage reports
- ✅ Identifies files <85% per TEST_COVERAGE.md threshold
- ✅ Prioritizes what to test (impact-based)
- ✅ Generates estimated effort

### `/review-component <name>` - 50+ Criteria Checklist

**Why good:**

- ✅ Validates 7 mandatory files per COMPONENT_ARCHITECTURE.md
- ✅ Checks token consumption (Recipes only per TOKEN_ARCHITECTURE.md)
- ✅ Validates WCAG 2.1 AA per WCAG_COMPLIANCE.md
- ✅ Analyzes test coverage across unit/E2E/a11y per TEST_COVERAGE.md
- ✅ Cannot be done with grep/find alone

## ❌ Examples of BAD Commands (No Value)

### `/build` - Simple Wrapper

**Why bad:**

- ❌ Only executes `pnpm build`
- ❌ No analysis or intelligence added
- ❌ Wastes tokens for zero value
- ✅ **Alternative:** Use `pnpm build` directly (free)

### `/test` - No Added Value

**Why bad:**

- ❌ Only executes `pnpm test`
- ❌ Doesn't parse results or suggest fixes
- ❌ Simple bash wrapper
- ✅ **Alternative:** Use `pnpm test` directly (free)

## Command File Structure

Slash commands stored in `.claude/commands/category-name/command-name.md`:

```
.claude/commands/
├── status/
│   ├── status.md              # /status command
│   ├── coverage.md            # /coverage command
│   └── why-failing.md         # /why-failing command
├── review/
│   ├── component.md           # /review-component command
│   ├── tokens.md              # /review-tokens command
│   └── a11y.md                # /review-a11y command
└── new/
    ├── component.md           # /new-component command
    ├── flavor.md              # /new-flavor command
    └── variant.md             # /add-variant command
```

## Command Template

Every command file follows this structure:

```markdown
---
description: Brief description (shown in /help)
allowed-tools: Tool1, Tool2, Tool3
argument-hint: [arg-name (optional)] # If accepts arguments
---

Brief introduction.

# Section 1: Data Gathering

Explain what information to collect from where.
Reference guidelines for validation thresholds.

# Section 2: Analysis

Explain how to interpret data.
Apply guideline standards (TEST_COVERAGE.md thresholds, etc.).

# Section 3: Recommendations

Provide actionable recommendations.

# Output Format

Show example output format.
```

## Command Creation Workflow

### Step 1: Validate Against Golden Rule

```bash
# Check package.json script
cat package.json | grep -A 50 '"scripts"' | grep "command-name"

# If exists → STOP, use bash
# If not exists → Continue
```

### Step 2: Determine Command Type

1. **Intelligent analysis?** (combines sources + insights)
2. **Troubleshooting?** (diagnoses + suggests fixes)
3. **Aggregated info?** (collects + organizes complex data)
4. **Skill shortcut?** (explicit invocation of existing skill)
5. **Performance analysis?** (metrics + regressions)

If **none** → ❌ Command NOT justified

### Step 3: Determine Command Location

- **Status/Info:** `.claude/commands/status/`
- **Review/Analysis:** `.claude/commands/review/`
- **Creation/Generation:** `.claude/commands/new/`
- **Troubleshooting:** `.claude/commands/debug/`
- **Performance:** `.claude/commands/performance/`

### Step 4: Create Command File

Using template structure with guideline references.

### Step 5: Add Justification Comment

At end of command file:

```markdown
---

## 💰 Token Cost Justification

**Why this command is worth token cost:**

- ✅ Combines X sources of information
- ✅ Analyzes per GUIDELINE.md standards (lines X-Y)
- ✅ Generates Z actionable recommendations
- ✅ Cannot be done with single bash command

**Estimated tokens per use:** ~XXX tokens
**Value added:** [Specific value]
**ROI:** Positive after X uses
```

### Step 6: Test Command

```bash
/command-name [arguments]

# Verify it:
# 1. Executes without errors
# 2. Provides intelligent analysis
# 3. Applies guideline standards correctly
# 4. Generates actionable recommendations
# 5. Justifies token cost
```

## Sando-Specific Command Considerations

### 1. Three-Layer Token Architecture Awareness

Commands working with tokens must understand per TOKEN_ARCHITECTURE.md:

- **Ingredients** (primitives, no references)
- **Flavors** (semantic, reference Ingredients only)
- **Recipes** (component-specific, reference Flavors only)

**Example:** `/review-tokens` validates this architecture

### 2. Monolithic Component Structure

Commands working with components must validate per COMPONENT_ARCHITECTURE.md:

- 7 mandatory files (implementation, types, stories, unit tests, E2E, a11y, index)
- Token consumption from Recipes layer only
- WCAG 2.1 AA compliance per WCAG_COMPLIANCE.md

**Example:** `/review-component` checks all 7 files

### 3. Quality Thresholds

Commands analyzing quality must apply per guidelines:

- TEST_COVERAGE.md: >85% unit, 100% a11y
- PERFORMANCE_BUDGETS.md: <10KB per component, Core Web Vitals
- WCAG_COMPLIANCE.md: WCAG 2.1 AA, 4.5:1 contrast ratio

**Example:** `/coverage` uses TEST_COVERAGE.md thresholds

### 4. Monorepo Structure

Commands must understand per MONOREPO_STRUCTURE.md:

- Turborepo task orchestration
- pnpm workspaces
- Build dependencies (@sando/tokens → @sando/components)

**Example:** `/status` checks build artifact timestamps

## ✨ Final Reminder

> "El mejor comando es el que no necesitas crear porque bash ya lo hace gratis."

Only create commands that **justify token cost** through **intelligent analysis**, **multi-source aggregation**, **troubleshooting automation**, or **convenience shortcuts** to existing skills.

**When in doubt:** "¿Puedo hacer esto con bash directamente?"

- **YES** → Use bash (free, no tokens)
- **NO** → Create command (adds value)
