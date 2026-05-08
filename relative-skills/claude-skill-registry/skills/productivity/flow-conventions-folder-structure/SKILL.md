---
name: flow-conventions-folder-structure
description: Validate and fix folder structure for Output SDK workflows. Use to ensure migrated workflows follow the correct structure conventions.
allowed-tools: [Bash, Read, Grep, Glob]
---

# Output SDK Folder Structure Conventions

## Overview

This skill documents the required folder structure for Output SDK workflows and helps validate/fix structure issues after migration.

## When to Use This Skill

**After Migration:**
- Validating folder structure is correct
- Fixing structure issues
- Renaming files to match conventions

**During Setup:**
- Creating new workflow directories
- Understanding project organization

## Folder Structure Comparison

### Flow SDK (Old Structure)

```
src/
└── workflows/
    └── example_workflow/
        ├── activities.ts      # Activity functions
        ├── helpers.ts         # Optional helpers
        ├── prompts.ts         # JS prompt arrays
        ├── prompts.xml        # XML prompts
        ├── readme.xml         # Documentation
        ├── types.ts           # Type definitions
        └── workflow.ts        # Workflow class
```

### Output SDK (New Structure)

```
src/
└── workflows/
    └── example_workflow/
        ├── workflow.ts              # Workflow function (export default)
        ├── steps.ts                 # Step definitions
        ├── types.ts                 # Types + Zod schemas
        ├── analyzeDocument@v1.prompt   # Prompt files
        ├── generateSummary@v1.prompt
        └── scenarios/               # Test input files
            ├── basic_input.json
            └── full_options.json
```

## File Naming Conventions

### Workflow Folder

- Use `snake_case` for folder names
- Match the workflow name

```
# Correct
user_onboarding/
generate_report/
analyze_document/

# Wrong
userOnboarding/
GenerateReport/
analyze-document/
```

### Core Files

| File | Naming | Purpose |
|------|--------|---------|
| `workflow.ts` | Exact name | Workflow definition |
| `steps.ts` | Exact name | All step definitions |
| `types.ts` | Exact name | Types and Zod schemas |

### Prompt Files

Format: `{descriptiveName}@{version}.prompt`

```
# Correct
analyzeDocument@v1.prompt
generateSummary@v1.prompt
extractEntities@v2.prompt

# Wrong
analyze.prompt           # Missing version
analyzeDocument.txt      # Wrong extension
analyze-document@v1.md   # Wrong extension
```

### Scenario Files

Format: `{descriptive_name}.json`

```
# Correct
basic_input.json
full_options.json
edge_case_empty.json
question_ada_lovelace.json

# Wrong
test1.json              # Not descriptive
BasicInput.json         # Not snake_case
```

## Required vs Optional Files

### Required Files

| File | Must Exist | Purpose |
|------|------------|---------|
| `workflow.ts` | Yes | Workflow entry point |
| `steps.ts` | Yes (if steps exist) | Step definitions |
| `types.ts` | Yes | Schemas and types |

### Optional Files/Folders

| File/Folder | Optional | Purpose |
|-------------|----------|---------|
| `*.prompt` | If LLM calls | Prompt templates |
| `scenarios/` | Recommended | Test inputs |
| `helpers.ts` | If needed | Utility functions |

### Files to Remove After Migration

| File | Action |
|------|--------|
| `activities.ts` | Rename to `steps.ts` or delete after conversion |
| `prompts.ts` | Delete after converting to `.prompt` files |
| `prompts.xml` | Delete after converting to `.prompt` files |
| `readme.xml` | Can keep for reference or delete |

## Validation Commands

### Check Folder Structure

```bash
WORKFLOW="src/workflows/my_workflow"

# List all files
ls -la $WORKFLOW/

# Check for required files
[ -f "$WORKFLOW/workflow.ts" ] && echo "✓ workflow.ts" || echo "✗ workflow.ts missing"
[ -f "$WORKFLOW/steps.ts" ] && echo "✓ steps.ts" || echo "✗ steps.ts missing"
[ -f "$WORKFLOW/types.ts" ] && echo "✓ types.ts" || echo "✗ types.ts missing"

# Check for leftover files
[ -f "$WORKFLOW/activities.ts" ] && echo "⚠ activities.ts should be removed" || echo "✓ No activities.ts"
[ -f "$WORKFLOW/prompts.ts" ] && echo "⚠ prompts.ts should be removed" || echo "✓ No prompts.ts"
[ -f "$WORKFLOW/prompts.xml" ] && echo "⚠ prompts.xml should be removed" || echo "✓ No prompts.xml"
```

### Check Folder Naming

```bash
# List workflow folders
ls -d src/workflows/*/

# Check for non-snake_case folders
ls -d src/workflows/*/ | while read dir; do
  name=$(basename "$dir")
  if [[ "$name" =~ [A-Z] ]] || [[ "$name" =~ "-" ]]; then
    echo "⚠ Non-snake_case folder: $name"
  fi
done
```

### Check Prompt File Naming

```bash
# List prompt files
ls src/workflows/my_workflow/*.prompt 2>/dev/null

# Check for version in prompt names
for f in src/workflows/my_workflow/*.prompt; do
  if [[ ! "$f" =~ @v[0-9]+\.prompt$ ]]; then
    echo "⚠ Missing version: $f"
  fi
done
```

## Fixing Structure Issues

### Rename activities.ts to steps.ts

```bash
mv src/workflows/my_workflow/activities.ts src/workflows/my_workflow/steps.ts
```

### Create scenarios directory

```bash
mkdir -p src/workflows/my_workflow/scenarios
```

### Fix folder naming

```bash
# Rename from camelCase to snake_case
mv src/workflows/userOnboarding src/workflows/user_onboarding
```

### Remove old files

```bash
rm src/workflows/my_workflow/prompts.ts
rm src/workflows/my_workflow/prompts.xml
```

## Complete Example

### Before Migration

```
src/workflows/userReport/
├── activities.ts
├── helpers.ts
├── prompts.ts
├── prompts.xml
├── readme.xml
├── types.ts
└── workflow.ts
```

### After Migration

```
src/workflows/user_report/      # Renamed to snake_case
├── workflow.ts                 # Converted to workflow()
├── steps.ts                    # Converted from activities.ts
├── types.ts                    # Added Zod schemas
├── generateReport@v1.prompt    # Converted from prompts.ts
├── formatOutput@v1.prompt
└── scenarios/                  # NEW
    ├── daily_report.json
    ├── weekly_report.json
    └── full_options.json
```

## Project-Wide Structure

```
src/
├── workflows/
│   ├── user_onboarding/
│   │   ├── workflow.ts
│   │   ├── steps.ts
│   │   ├── types.ts
│   │   ├── welcome@v1.prompt
│   │   └── scenarios/
│   ├── generate_report/
│   │   ├── workflow.ts
│   │   ├── steps.ts
│   │   ├── types.ts
│   │   ├── analyze@v1.prompt
│   │   └── scenarios/
│   └── shared_steps/           # Optional: shared steps
│       └── shared_steps.ts
├── shared/                     # Optional: shared utilities
│   ├── types.ts
│   └── helpers.ts
└── index.ts                    # Exports
```

## Validation Checklist

- [ ] Workflow folder uses `snake_case`
- [ ] `workflow.ts` exists
- [ ] `steps.ts` exists (if workflow has steps)
- [ ] `types.ts` exists
- [ ] Prompt files use `name@version.prompt` format
- [ ] No leftover `activities.ts`
- [ ] No leftover `prompts.ts` or `prompts.xml`
- [ ] `scenarios/` directory exists (recommended)
- [ ] Scenario files use `snake_case.json` format

## Related Skills

- `flow-validation-checklist` - Complete migration validation
- `flow-create-scenario-files` - Creating test scenarios
- `flow-analyze-workflow-structure` - Pre-migration analysis
