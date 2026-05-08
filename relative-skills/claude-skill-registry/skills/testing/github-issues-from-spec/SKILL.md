---
name: github-issues-from-spec
description: This skill transforms feature specifications, requirements documents, or plans into well-structured GitHub issues. It chunks large features into small, testable issues, creates them via gh CLI, and adds them to the appropriate GitHub project with labels. Use when converting specs to actionable issues.
---

<objective>
Parse feature specifications and create small, testable GitHub issues that are ready for development. Automatically create issues via gh CLI and add them to the appropriate project with proper labels and fields.
</objective>

<intake>
Provide the following:

1. **Specification source** - File path, pasted text, or plan file
2. **Repository** - GitHub repo (e.g., `LexiconIndonesia/backend`)
3. **Project name** - GitHub project to add issues to (e.g., `Lexicon`)
4. **System field** - Value for the System field
5. **Status field** - Initial status for issues (default: `Backlog`)
6. **Priority field** - Priority level for issues (default: `P1`)
7. **Size field** - Estimated size of the issue (default: `S`)

**Available Status Values:**
| Status | Description |
|--------|-------------|
| `Backlog` | This item hasn't been started |
| `Ready` | This is ready to be picked up |
| `In progress` | This is actively being worked on |
| `In review` | This item is in review |
| `Done` | This has been completed |

**Available Priority Values:**
| Priority | Description |
|----------|-------------|
| `P0` | Critical - Must be done immediately |
| `P1` | High - Important, do soon |
| `P2` | Medium - Normal priority |
| `P3` | Low - Nice to have |

**Available Size Values:**
| Size | Description |
|------|-------------|
| `XS` | Trivial change (~1 hour) |
| `S` | Small, focused change (~2-4 hours) |
| `M` | Medium, multiple files (~1 day) |
| `L` | Large, significant effort (~2-3 days) |
| `XL` | Extra large, should consider breaking down (~1 week) |

**Available System Values:**
| System | Description |
|--------|-------------|
| `Crawler` | Web crawling and scraping services |
| `Backend` | API and server-side services |
| `Frontend` | Web frontend applications |
| `Mobile` | Mobile applications |
| `Monitoring` | Monitoring and observability |
| `Infrastructure` | Infrastructure and DevOps |
| `ETL` | Data extraction, transformation, loading |

**Or paste your specification directly.**
</intake>

<workflow>
## Step 1: Parse Specification

Read and analyze the specification to identify:
- Feature components
- Dependencies between features
- Acceptance criteria
- Technical requirements

## Step 2: Chunk into Issues

Break down the specification into issues following these principles:

**Issue Sizing:**
- Each issue = 1-4 hours of work
- Single, testable commit
- Clear acceptance criteria
- No dependencies within the same issue

**Issue Types:**
| Size | Scope | Example |
|------|-------|---------|
| XS | Single file change | "Add field to response schema" |
| S | 2-3 file changes | "Implement new SQLC query" |
| M | Feature slice | "Add search endpoint with filters" |
| L | Full feature | "Implement caching layer" (should be broken down) |

## Step 3: Structure Each Issue

Use this template for each issue:

```markdown
## Description

Brief description of what needs to be done.

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Technical Notes

- Implementation hints
- Files to modify
- Dependencies

## Testing

- [ ] Unit tests added/updated
- [ ] Integration test (if applicable)
- [ ] Manual verification steps
```

## Step 4: Determine Labels

Assign labels based on issue content:

**Size labels:**
- `size: XS` - Trivial change
- `size: S` - Small, focused change
- `size: M` - Medium, multiple files
- `size: L` - Large, should consider breaking down

**Priority labels:**
- `priority: High` - Blocking or critical path
- `priority: Medium` - Important but not blocking
- `priority: Low` - Nice to have

**Type labels:**
- `enhancement` - New feature
- `bug` - Bug fix
- `documentation` - Docs only
- `refactor` - Code improvement

## Step 5: Create Issues via gh CLI

For each issue, create using gh CLI:

```bash
gh issue create \
  --repo "Owner/Repo" \
  --title "Issue title" \
  --body "$(cat <<'EOF'
## Description

Description here

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes

Notes here
EOF
)" \
  --label "size: S" \
  --label "priority: High" \
  --label "enhancement"
```

## Step 6: Add to Project

Add each created issue to the GitHub project:

```bash
# Get project ID
gh project list --owner "Owner" --format json | jq '.projects[] | select(.title=="ProjectName") | .number'

# Add issue to project
gh project item-add PROJECT_NUMBER --owner "Owner" --url "ISSUE_URL"

# Set project fields (if needed)
gh project item-edit --project-id PROJECT_ID --id ITEM_ID --field-id FIELD_ID --text "Value"
```

## Step 7: Set Project Fields

Update project-specific fields:

```bash
# Get field IDs
gh project field-list PROJECT_NUMBER --owner "Owner" --format json

# Set System field (text field)
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PROJECT_ID"
      itemId: "ITEM_ID"
      fieldId: "SYSTEM_FIELD_ID"
      value: { text: "Backend" }
    }) {
      projectV2Item { id }
    }
  }
'

# Set Status field (single select field)
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PROJECT_ID"
      itemId: "ITEM_ID"
      fieldId: "STATUS_FIELD_ID"
      value: { singleSelectOptionId: "OPTION_ID" }
    }) {
      projectV2Item { id }
    }
  }
'
```

**Single Select Option IDs:** Query the project to get option IDs for Status, Priority, and Size fields.
</workflow>

<issue_templates>
## Common Issue Templates

### API Endpoint Issue
```markdown
## Description

Implement `{METHOD} /api/v1/{path}` endpoint.

## Acceptance Criteria

- [ ] OpenAPI spec updated
- [ ] Handler implemented
- [ ] SQLC query added (if needed)
- [ ] Response matches spec
- [ ] Tests pass

## Technical Notes

- Files: `api/openapi.yaml`, `internal/api/handlers.go`
- Cache key: `{cache_key}` (if applicable)
```

### Database Migration Issue
```markdown
## Description

Add migration for {description}.

## Acceptance Criteria

- [ ] Migration file created
- [ ] UP migration works
- [ ] DOWN migration works
- [ ] SQLC queries updated

## Technical Notes

- Migration name: `{name}`
- Affected tables: {tables}
```

### Filter/Search Enhancement Issue
```markdown
## Description

Add {filter_name} filter to {endpoint} endpoint.

## Acceptance Criteria

- [ ] Filter parameter added to OpenAPI spec
- [ ] SQLC query updated with filter logic
- [ ] Handler processes filter correctly
- [ ] Empty filter returns all results
- [ ] Filter values validated

## Technical Notes

- Use `ANY(array)` pattern for multi-value filters
- Add to existing filter endpoint if applicable
```
</issue_templates>

<batch_creation_script>
## Batch Issue Creation

For creating multiple issues from a markdown file:

```bash
#!/bin/bash
# create_issues.sh

REPO="Owner/Repo"
PROJECT="ProjectName"
SYSTEM="Backend"
STATUS="Backlog"    # Options: Backlog, Ready, In progress, In review, Done
PRIORITY="P1"       # Options: P0, P1, P2, P3
SIZE="S"            # Options: XS, S, M, L, XL

# Find project number
PROJECT_NUM=$(gh project list --owner "Owner" --format json | jq -r '.projects[] | select(.title=="'"$PROJECT"'") | .number')

echo "Creating issues for $REPO, Project #$PROJECT_NUM"

# Parse Issues.md and create each issue
# (Implementation depends on file format)

# Example: Create single issue
ISSUE_URL=$(gh issue create \
  --repo "$REPO" \
  --title "Issue title" \
  --body "Issue body" \
  --label "size: S,priority: High" \
  2>&1 | grep -o 'https://.*')

echo "Created: $ISSUE_URL"

# Add to project
gh project item-add "$PROJECT_NUM" --owner "Owner" --url "$ISSUE_URL"
```
</batch_creation_script>

<validation>
## Pre-Creation Checklist

Before creating issues:
- [ ] Labels exist in repository (create if not)
- [ ] Project exists and is accessible
- [ ] System field exists in project
- [ ] Status field exists in project (Backlog, Ready, In progress, In review, Done)
- [ ] Priority field exists in project (P0, P1, P2, P3)
- [ ] Size field exists in project (XS, S, M, L, XL)
- [ ] Issues are properly sized (not too large)
- [ ] Dependencies are documented
- [ ] No duplicate issues exist
</validation>

<output>
## Output Format

After creating issues, provide summary:

```markdown
# Issue Creation Summary

**Repository:** Owner/Repo
**Project:** ProjectName
**Total Issues Created:** X

| # | Title | Size | Priority | URL |
|---|-------|------|----------|-----|
| 1 | Issue title | S | High | https://... |
| 2 | Issue title | M | Medium | https://... |

## Next Steps

1. Review created issues
2. Adjust priorities if needed
3. Assign to team members
4. Add to sprint/milestone
```
</output>

<success_criteria>
Issue creation is complete when:
- [ ] All spec components converted to issues
- [ ] Issues are appropriately sized
- [ ] Labels applied correctly
- [ ] Issues added to project
- [ ] Project fields set (System, Status, Priority, Size)
- [ ] Summary provided with all issue URLs
</success_criteria>
